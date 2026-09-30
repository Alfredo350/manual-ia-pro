import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../engine/extractors.dart';
import '../engine/search_engine.dart';
import '../engine/text_utils.dart';
import '../models.dart';

/// Guarda los documentos, su índice de búsqueda, el historial y el contador diario.
/// Todo queda en el teléfono: la app no usa internet.
class LibraryService {
  late Directory _root;
  late SharedPreferences _prefs;
  final Map<String, Future<DocIndex>> _indexCache = {};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final dir = await getApplicationDocumentsDirectory();
    _root = Directory('${dir.path}/manuals');
    await _root.create(recursive: true);
  }

  // ---------- Documentos ----------
  List<DocumentInfo> list() {
    final raw = _prefs.getString('library_v2');
    if (raw == null) return [];
    try {
      return [for (final e in jsonDecode(raw) as List) DocumentInfo.fromJson(e as Map<String, dynamic>)]
          .where((d) => d.isReady)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveList(List<DocumentInfo> docs) =>
      _prefs.setString('library_v2', jsonEncode([for (final d in docs.where((d) => d.isReady)) d.toJson()]));

  String sourcePath(DocumentInfo d) => '${_root.path}/${d.id}/source.${d.type}';

  /// Copia el archivo, lee su texto y crea el índice de búsqueda.
  /// [onProgress] recibe el paso (0..3) y el porcentaje (0..100).
  Future<DocumentInfo> importFile(
    File file,
    String name, {
    required String id,
    void Function(int step, int percent)? onProgress,
  }) async {
    final lower = name.toLowerCase();
    if (lower.endsWith('.doc')) throw ExtractError('oldDoc');
    final type = lower.endsWith('.docx') ? 'docx' : 'pdf';

    final dir = Directory('${_root.path}/$id');
    await dir.create(recursive: true);
    try {
      // 1. Copia al teléfono
      onProgress?.call(0, 5);
      final dest = File('${dir.path}/source.$type');
      await file.copy(dest.path);

      // 2. Lectura del texto
      onProgress?.call(1, 10);
      final pages = type == 'pdf'
          ? await extractPdf(dest.path, onProgress: (f) => onProgress?.call(1, 10 + (f * 70).round()))
          : await extractDocx(dest.path);

      // 3. Títulos y secciones · 4. Índice
      onProgress?.call(2, 85);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final index = DocIndex.build(pages);
      if (index.isEmpty) throw ExtractError(type == 'pdf' ? 'scanned' : 'damaged');
      onProgress?.call(3, 95);
      await File('${dir.path}/index.json').writeAsString(jsonEncode([for (final p in pages) p.toJson()]));
      _indexCache[id] = Future.value(index);

      final sample = pages.take(5).map((p) => p.text).join('\n');
      return DocumentInfo(
        id: id,
        name: _cleanName(name),
        type: type,
        pages: pages.length,
        status: 'ready',
        progress: 100,
        language: detectLanguage(sample),
        suggestions: index.topics(4),
      );
    } catch (e) {
      if (await dir.exists()) await dir.delete(recursive: true);
      rethrow;
    }
  }

  /// Copia el manual de ejemplo incluido en la app y lo procesa como cualquier otro.
  Future<File> sampleFile(String lang) async {
    final code = ['es', 'en', 'pt'].contains(lang) ? lang : 'es';
    final data = await rootBundle.load('assets/samples/sample_$code.pdf');
    final tmp = await getTemporaryDirectory();
    final f = File('${tmp.path}/sample_$code.pdf');
    await f.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return f;
  }

  /// Índice del documento. Se guarda el mismo Future para no recargarlo en cada pantalla.
  Future<DocIndex> index(DocumentInfo d) => _indexCache.putIfAbsent(d.id, () => _loadIndex(d.id));

  Future<DocIndex> _loadIndex(String id) async {
    try {
      final raw = await File('${_root.path}/$id/index.json').readAsString();
      final pages = [for (final e in jsonDecode(raw) as List) DocPage.fromJson(e as Map<String, dynamic>)];
      return DocIndex.build(pages);
    } catch (e) {
      _indexCache.remove(id);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    _indexCache.remove(id);
    final dir = Directory('${_root.path}/$id');
    if (await dir.exists()) await dir.delete(recursive: true);
    await _prefs.remove('history_$id');
  }

  static String _cleanName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    final base = dot > 0 ? fileName.substring(0, dot) : fileName;
    return base.replaceAll('_', ' ').trim();
  }

  // ---------- Historial (versión Pro) ----------
  List<ChatMessage> history(String id) {
    final raw = _prefs.getString('history_$id');
    if (raw == null) return [];
    try {
      return [for (final e in jsonDecode(raw) as List) ChatMessage.fromJson(e as Map<String, dynamic>)];
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(String id, List<ChatMessage> messages) =>
      _prefs.setString('history_$id', jsonEncode([for (final m in messages) m.toJson()]));

  // ---------- Preguntas del día (versión básica) ----------
  String get _today {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  int usedToday() => _prefs.getString('usage_date') == _today ? (_prefs.getInt('usage_count') ?? 0) : 0;

  Future<int> addQuestion() async {
    final n = usedToday() + 1;
    await _prefs.setString('usage_date', _today);
    await _prefs.setInt('usage_count', n);
    return n;
  }

  int get dailyLimit => AppConfig.dailyQuestionLimit;
}
