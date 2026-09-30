import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Resultado de preparar el micrófono.
enum MicStatus { ok, denied, blocked, unavailable }

/// Dictado de preguntas (voz a texto) y lectura de respuestas (texto a voz).
/// Usa el reconocimiento y la voz del propio teléfono.
class VoiceService {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _sttReady = false;
  List<LocaleName> _locales = const [];
  bool _useDefaultLocale = false;

  void Function()? onSpeakDone;
  void Function(String status)? onStatus;
  void Function(String error)? onError;

  /// Idiomas preferidos para cada idioma.
  static const _ttsCandidates = {
    'es': ['es-419', 'es-US', 'es-MX', 'es-ES'],
    'en': ['en-US', 'en-GB'],
    'pt': ['pt-BR', 'pt-PT'],
  };

  Future<void> initTts() async {
    try {
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(false);
      _tts.setCompletionHandler(() => onSpeakDone?.call());
      _tts.setCancelHandler(() => onSpeakDone?.call());
      _tts.setErrorHandler((_) => onSpeakDone?.call());
    } catch (_) {}
  }

  /// 1) Pide el permiso de micrófono de forma explícita.
  /// 2) Prepara el reconocimiento de voz del teléfono.
  Future<MicStatus> prepareMic() async {
    final PermissionStatus st;
    try {
      st = await Permission.microphone.request();
    } catch (_) {
      return MicStatus.denied;
    }
    if (st.isPermanentlyDenied) return MicStatus.blocked;
    if (!st.isGranted) return MicStatus.denied;
    if (_sttReady) return MicStatus.ok;
    try {
      _sttReady = await _speech.initialize(
        onStatus: (s) => onStatus?.call(s),
        onError: (SpeechRecognitionError e) => onError?.call(e.errorMsg),
        finalTimeout: const Duration(seconds: 3),
        options: [
          // Algunos teléfonos no declaran bien el servicio de dictado: se busca de otra forma.
          SpeechToText.androidIntentLookup,
          // No se usan auriculares Bluetooth: evita pedir un permiso extra que bloqueaba el micrófono.
          SpeechToText.androidNoBluetooth,
        ],
      );
    } catch (_) {
      // Por ejemplo "recognizerNotAvailable": el teléfono no tiene servicio de dictado.
      _sttReady = false;
    }
    if (!_sttReady) return MicStatus.unavailable;
    try {
      _locales = await _speech.locales();
    } catch (_) {
      _locales = const [];
    }
    return MicStatus.ok;
  }

  String? _sttLocaleFor(String lang) {
    if (_useDefaultLocale) return null;
    for (final l in _locales) {
      final id = l.localeId.toLowerCase().replaceAll('_', '-');
      if (id.startsWith('$lang-') || id == lang) return l.localeId;
    }
    return null;
  }

  /// El idioma pedido no está instalado: se usa el idioma del teléfono.
  void fallbackToDefaultLocale() => _useDefaultLocale = true;

  /// Devuelve false si el micrófono no pudo empezar (por ejemplo, lo usa otra app).
  Future<bool> startListening({
    required String lang,
    required void Function(String text, bool isFinal) onText,
  }) async {
    try {
      await _tts.stop();
      if (_speech.isListening) await _speech.cancel();
      // localeId / listenFor / pauseFor se pasan aquí porque así funcionan en todas las versiones 7.x.
      // ignore: deprecated_member_use
      await _speech.listen(
        onResult: (SpeechRecognitionResult r) => onText(r.recognizedWords, r.finalResult),
        // ignore: deprecated_member_use
        localeId: _sttLocaleFor(lang),
        // ignore: deprecated_member_use
        listenFor: const Duration(seconds: 60),
        // ignore: deprecated_member_use
        pauseFor: const Duration(seconds: 5),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenMode: ListenMode.dictation,
          cancelOnError: true,
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } catch (_) {}
  }

  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
    } catch (_) {}
  }

  Future<void> openSettings() => openAppSettings();

  Future<void> speak(String text, String lang) async {
    try {
      await _tts.stop();
      for (final code in _ttsCandidates[lang] ?? const ['es-ES']) {
        final ok = await _tts.isLanguageAvailable(code);
        if (ok == true || ok == 1) {
          await _tts.setLanguage(code);
          break;
        }
      }
      // Quita la numeración "1." para que la lectura suene natural.
      final clean = text.replaceAll(RegExp(r'^\d+\.\s*', multiLine: true), '');
      await _tts.speak(clean);
    } catch (_) {
      onSpeakDone?.call();
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
