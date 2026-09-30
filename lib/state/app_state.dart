import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../engine/extractors.dart';
import '../l10n/l10n.dart';
import '../models.dart';
import '../services/library_service.dart';
import '../services/voice_service.dart';
import '../widgets/source_capture.dart' show PdfCaptureService;

enum AskResult { ok, limit, error }

/// Estado global de la app (idioma, documentos, preguntas del día, chat y voz).
/// Las respuestas se buscan en el propio teléfono, sin IA y sin internet.
class AppState extends ChangeNotifier {
  AppState({LibraryService? library}) : library = library ?? LibraryService();

  final LibraryService library;
  final VoiceService voice = VoiceService();

  // Preferencias
  String lang = 'es';
  bool autoRead = false;

  bool ready = false;

  /// Documentos guardados. En la básica hay como máximo uno.
  List<DocumentInfo> documents = [];

  /// Documento que se está procesando (se muestra en la pantalla Subir).
  DocumentInfo? importing;

  /// Código del último error al leer un documento: 'scanned' | 'oldDoc' | 'password' | 'damaged'
  String? importError;

  /// Documento abierto en el chat.
  String? currentId;
  Usage usage = Usage(usedToday: 0, limit: AppConfig.dailyQuestionLimit);
  final List<ChatMessage> messages = [];

  bool asking = false;

  // ---------- Voz ----------
  /// Panel de dictado abierto.
  bool listening = false;

  /// Preparando el micrófono (pidiendo permiso / iniciando el dictado).
  bool micStarting = false;

  /// El micrófono está captando audio en este momento.
  bool micActive = false;
  String transcript = '';

  /// Último problema del dictado:
  /// 'denied' | 'blocked' | 'unavailable' | 'busy' | 'network' | 'notHeard' | null
  String? voiceError;
  int? speakingIndex;
  bool _retriedLocale = false;

  L get l => L(lang);
  bool get isPro => AppConfig.isPro;

  DocumentInfo? get document {
    if (documents.isEmpty) return null;
    return documents.firstWhere((d) => d.id == currentId, orElse: () => documents.first);
  }

  bool get hasDocument => documents.isNotEmpty;

  /// En Pro no hay límite diario.
  bool get limitReached => !isPro && usage.limitReached;

  /// Temas del manual (títulos de sus secciones).
  List<String> get suggestions => document?.suggestions ?? const [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceLang = ui.PlatformDispatcher.instance.locale.languageCode;
    lang = prefs.getString('lang') ?? (L.supported.contains(deviceLang) ? deviceLang : 'es');
    autoRead = prefs.getBool('auto_read') ?? false;

    await voice.initTts();
    voice.onSpeakDone = () {
      speakingIndex = null;
      notifyListeners();
    };
    voice.onStatus = _onVoiceStatus;
    voice.onError = _onVoiceError;

    try {
      await library.init();
      documents = library.list();
      refreshUsage();
    } catch (_) {}
    ready = true;
    notifyListeners();
  }

  // ---------- Preferencias ----------
  Future<void> setLang(String value) async {
    lang = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString('lang', value);
  }

  Future<void> setAutoRead(bool value) async {
    autoRead = value;
    if (!value) await stopSpeaking();
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool('auto_read', value);
  }

  // ---------- Documentos ----------
  /// Lee el documento en el teléfono y crea su índice. Lanza [ExtractError] si no se puede leer.
  Future<void> uploadFile(File file, String fileName, {String? displayName}) async {
    await stopSpeaking();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final type = fileName.toLowerCase().endsWith('.docx') ? 'docx' : 'pdf';
    importError = null;
    importing = DocumentInfo(id: id, name: displayName ?? fileName, type: type, pages: 0, status: 'processing');
    notifyListeners();
    try {
      var doc = await library.importFile(
        file,
        fileName,
        id: id,
        onProgress: (step, pct) {
          importing = importing?.copyWith(progress: pct);
          notifyListeners();
        },
      );
      if (displayName != null) doc = doc.copyWith(name: displayName);
      if (isPro) {
        documents = [doc, ...documents];
      } else {
        // Versión básica: 1 documento. El anterior se borra del teléfono.
        for (final old in documents) {
          await PdfCaptureService.instance.close(library.sourcePath(old));
          await library.delete(old.id);
        }
        documents = [doc];
        messages.clear();
      }
      currentId = doc.id;
      await library.saveList(documents);
      importing = doc;
    } on ExtractError catch (e) {
      importError = e.code;
      importing = importing?.copyWith(status: 'error');
      rethrow;
    } catch (_) {
      importError = 'damaged';
      importing = importing?.copyWith(status: 'error');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  /// Carga el manual de ejemplo incluido en la app (se procesa igual que un archivo real).
  Future<void> useSample() async {
    final f = await library.sampleFile(lang);
    await uploadFile(f, 'sample_$lang.pdf', displayName: l.sampleName);
  }

  /// Abre un documento en el chat y, en Pro, carga su historial guardado.
  Future<void> openDocument(String id) async {
    await stopSpeaking();
    if (currentId == id && messages.isNotEmpty) return;
    currentId = id;
    messages.clear();
    if (isPro) messages.addAll(library.history(id));
    notifyListeners();
  }

  Future<void> deleteDocument(String id) async {
    for (final d in documents.where((d) => d.id == id)) {
      await PdfCaptureService.instance.close(library.sourcePath(d));
    }
    await library.delete(id);
    documents = documents.where((d) => d.id != id).toList();
    await library.saveList(documents);
    if (currentId == id) {
      currentId = null;
      messages.clear();
    }
    notifyListeners();
  }

  /// El contador se renueva cada día.
  Future<void> refreshUsage() async {
    if (isPro) return;
    try {
      usage = Usage(usedToday: library.usedToday(), limit: library.dailyLimit);
      notifyListeners();
    } catch (_) {}
  }

  /// Ruta del archivo original (para dibujar la captura de la página).
  String? sourcePathOf(DocumentInfo? d) => d == null ? null : library.sourcePath(d);

  // ---------- Preguntas ----------
  Future<AskResult> ask(String question, {bool byVoice = false}) async {
    final q = question.trim();
    final doc = document;
    if (q.isEmpty || asking || doc == null) return AskResult.error;
    await refreshUsage();
    if (limitReached) return AskResult.limit;
    await stopSpeaking();
    final questionAt = messages.length;
    messages.add(ChatMessage.user(q, byVoice: byVoice));
    asking = true;
    notifyListeners();
    try {
      final index = await library.index(doc);
      final r = index.search(q);
      final answer = Answer(
        found: r.found,
        sources: [
          for (final h in r.hits)
            SourceRef(page: h.page, section: h.section, excerpt: h.text, start: h.charStart, end: h.charEnd),
        ],
        related: r.related,
        language: doc.language,
      );
      messages.add(ChatMessage.answer(answer));
      if (isPro) {
        documents = [
          for (final d in documents) d.id == doc.id ? d.copyWith(questionCount: d.questionCount + 1) : d,
        ];
        await library.saveList(documents);
        await library.saveHistory(doc.id, messages);
      } else {
        usage = Usage(usedToday: await library.addQuestion(), limit: usage.limit);
      }
      asking = false;
      notifyListeners();
      if (autoRead && answer.found) await speak(messages.length - 1);
      return AskResult.ok;
    } catch (_) {
      // Quita la pregunta (y la respuesta, si alcanzó a agregarse).
      if (messages.length > questionAt) messages.removeRange(questionAt, messages.length);
      asking = false;
      notifyListeners();
      return AskResult.error;
    }
  }

  // ---------- Voz ----------
  void _onVoiceStatus(String s) {
    final active = s == 'listening';
    if (active != micActive) {
      micActive = active;
      micStarting = false;
      notifyListeners();
    }
  }

  void _onVoiceError(String e) {
    // Códigos de Android: error_no_match, error_speech_timeout, error_network, error_busy, error_client...
    if (e.contains('permission')) {
      voiceError = 'denied';
    } else if (e.contains('language')) {
      // El idioma no está instalado en el dictado: se reintenta con el idioma del teléfono.
      if (!_retriedLocale) {
        _retriedLocale = true;
        voice.fallbackToDefaultLocale();
        micActive = false;
        notifyListeners();
        startListening(retry: true);
        return;
      }
      voiceError = 'unavailable';
    } else if (e.contains('network') || e.contains('server')) {
      voiceError = 'network';
    } else if (e.contains('busy') || e.contains('client') || e.contains('audio')) {
      voiceError = 'busy';
    } else if (e.contains('no_match') || e.contains('timeout')) {
      voiceError = transcript.trim().isEmpty ? 'notHeard' : null;
    }
    micActive = false;
    micStarting = false;
    notifyListeners();
  }

  /// Abre el panel de voz de inmediato y luego activa el micrófono.
  Future<void> startListening({bool retry = false}) async {
    if (!retry) _retriedLocale = false;
    await stopSpeaking();
    listening = true;
    micStarting = true;
    micActive = false;
    transcript = '';
    voiceError = null;
    notifyListeners();

    final st = await voice.prepareMic();
    if (!listening) return; // el usuario canceló mientras tanto
    if (st != MicStatus.ok) {
      micStarting = false;
      voiceError = switch (st) {
        MicStatus.denied => 'denied',
        MicStatus.blocked => 'blocked',
        _ => 'unavailable',
      };
      notifyListeners();
      return;
    }
    final started = await voice.startListening(
      lang: lang,
      onText: (text, _) {
        transcript = text;
        voiceError = null;
        notifyListeners();
      },
    );
    if (!started) {
      micStarting = false;
      voiceError = 'busy';
      notifyListeners();
      return;
    }
    // Si el teléfono no avisa el estado, igual se muestra como activo.
    if (listening && voiceError == null && micStarting) {
      micStarting = false;
      micActive = true;
      notifyListeners();
    }
  }

  Future<void> cancelListening() async {
    listening = false;
    micActive = false;
    micStarting = false;
    transcript = '';
    notifyListeners();
    await voice.cancelListening();
  }

  /// Detiene el dictado y envía lo reconocido como pregunta.
  Future<AskResult> sendVoice() async {
    if (micActive) await voice.stopListening();
    listening = false;
    micActive = false;
    micStarting = false;
    final text = transcript;
    transcript = '';
    notifyListeners();
    if (text.trim().isEmpty) return AskResult.error;
    return ask(text, byVoice: true);
  }

  Future<void> openMicSettings() => voice.openSettings();

  Future<void> speak(int index) async {
    if (index < 0 || index >= messages.length) return;
    final m = messages[index];
    if (m.text.isEmpty) return;
    speakingIndex = index;
    notifyListeners();
    await voice.speak(m.text, m.language ?? lang);
  }

  Future<void> toggleSpeak(int index) async {
    if (speakingIndex == index) {
      await stopSpeaking();
    } else {
      await speak(index);
    }
  }

  Future<void> stopSpeaking() async {
    if (speakingIndex == null) return;
    speakingIndex = null;
    notifyListeners();
    await voice.stopSpeaking();
  }
}
