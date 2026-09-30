import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:xml/xml.dart';

import 'search_engine.dart';

/// Error al leer un documento. [code]: 'scanned' | 'oldDoc' | 'password' | 'damaged'
class ExtractError implements Exception {
  ExtractError(this.code);
  final String code;
  @override
  String toString() => 'ExtractError($code)';
}

/// Lee el texto de cada página de un PDF, en el propio teléfono.
Future<List<DocPage>> extractPdf(String path, {void Function(double done)? onProgress}) async {
  PdfDocument doc;
  try {
    doc = await PdfDocument.openFile(path);
  } on PdfPasswordException {
    throw ExtractError('password');
  } catch (_) {
    throw ExtractError('damaged');
  }
  try {
    final pages = <DocPage>[];
    var chars = 0;
    final count = doc.pages.length;
    for (var i = 0; i < count; i++) {
      final text = await doc.pages[i].loadStructuredText();
      // Se conserva el largo del texto para que cada letra siga en su posición.
      final t = text.fullText.replaceAll('\r', '\n');
      chars += t.trim().length;
      pages.add(DocPage.fromText(i + 1, t));
      onProgress?.call((i + 1) / count);
    }
    if (chars < 20) throw ExtractError('scanned');
    return pages;
  } finally {
    await doc.dispose();
  }
}

/// Lee un Word (.docx): párrafos, títulos (por su estilo) y saltos de página.
Future<List<DocPage>> extractDocx(String path) async {
  final Archive zip;
  try {
    zip = ZipDecoder().decodeBytes(await File(path).readAsBytes());
  } catch (_) {
    throw ExtractError('damaged');
  }
  final main = zip.findFile('word/document.xml');
  if (main == null) throw ExtractError('damaged');

  String read(ArchiveFile f) => utf8.decode(f.content as List<int>, allowMalformed: true);

  // Estilos de título: «Heading 1», «Título 1», «Title»…
  final styleLevel = <String, int>{};
  final stylesFile = zip.findFile('word/styles.xml');
  if (stylesFile != null) {
    try {
      final styles = XmlDocument.parse(read(stylesFile));
      final headingName = RegExp(r'(heading|titulo|título)\s*(\d)', caseSensitive: false);
      for (final st in styles.findAllElements('w:style')) {
        final id = st.getAttribute('w:styleId');
        if (id == null) continue;
        final name = st.findElements('w:name').firstOrNull?.getAttribute('w:val')?.toLowerCase() ?? '';
        final m = headingName.firstMatch(name);
        final outline = st.findAllElements('w:outlineLvl').firstOrNull?.getAttribute('w:val');
        if (m != null) {
          styleLevel[id] = int.parse(m.group(2)!);
        } else if (outline != null && int.tryParse(outline) != null && int.parse(outline) < 9) {
          styleLevel[id] = int.parse(outline) + 1;
        } else if (name == 'title' || name == 'título' || name == 'titulo') {
          styleLevel[id] = 1;
        }
      }
    } catch (_) {}
  }

  final XmlDocument xml;
  try {
    xml = XmlDocument.parse(read(main));
  } catch (_) {
    throw ExtractError('damaged');
  }

  final pages = <DocPage>[];
  var buf = StringBuffer();
  var lines = <DocLine>[];
  var sawBreaks = false;

  void flush() {
    if (lines.isEmpty) return;
    pages.add(DocPage(number: pages.length + 1, text: buf.toString(), lines: lines));
    buf = StringBuffer();
    lines = <DocLine>[];
  }

  void addLine(String t, int level) {
    if (buf.isNotEmpty) buf.write('\n');
    final start = buf.length;
    buf.write(t);
    lines.add(DocLine(start, buf.length, headingLevel: level));
  }

  for (final p in xml.findAllElements('w:p')) {
    // Párrafos dentro de cuadros de texto: su texto ya está en el párrafo que los contiene.
    if (p.ancestors.whereType<XmlElement>().any((a) => a.name.qualified == 'w:p')) continue;
    final text = StringBuffer();
    var breakBefore = false, breakAfter = false;
    for (final el in p.descendantElements) {
      switch (el.name.qualified) {
        case 'w:t':
          text.write(el.innerText);
        case 'w:tab':
        case 'w:cr':
          text.write(' ');
        case 'w:br':
          if (el.getAttribute('w:type') != 'page') {
            text.write(' ');
          } else {
            sawBreaks = true;
            if (text.isEmpty) {
              breakBefore = true;
            } else {
              breakAfter = true;
            }
          }
        case 'w:lastRenderedPageBreak':
          sawBreaks = true;
          if (text.isEmpty) {
            breakBefore = true;
          } else {
            breakAfter = true;
          }
      }
    }
    final pPr = p.findElements('w:pPr').firstOrNull;
    if (pPr?.findElements('w:pageBreakBefore').isNotEmpty ?? false) {
      breakBefore = true;
      sawBreaks = true;
    }
    final styleId = pPr?.findElements('w:pStyle').firstOrNull?.getAttribute('w:val');
    final outline = pPr?.findElements('w:outlineLvl').firstOrNull?.getAttribute('w:val');
    var level = styleLevel[styleId] ?? 0;
    if (level == 0 && outline != null && (int.tryParse(outline) ?? 9) < 9) level = int.parse(outline) + 1;

    if (breakBefore) flush();
    final t = text.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    // Sin estilo de título: la app decide por el texto (null).
    if (t.isNotEmpty) addLine(t, level);
    if (breakAfter) flush();
  }
  flush();

  // Si el archivo no guarda saltos de página, se arman páginas aproximadas de ~3000 letras.
  if (!sawBreaks && pages.length == 1 && pages.first.text.length > 3500) {
    final all = pages.first;
    pages.clear();
    for (var i = 0; i < all.lines.length; i++) {
      if (buf.length > 3000) flush();
      final l = all.lines[i];
      addLine(all.line(i), l.headingLevel ?? 0);
    }
    flush();
  }

  // Los párrafos sin estilo de título se evalúan por su texto (numeración, MAYÚSCULAS).
  final result = [
    for (final pg in pages)
      DocPage(number: pg.number, text: pg.text, lines: [
        for (final l in pg.lines) DocLine(l.start, l.end, headingLevel: (l.headingLevel ?? 0) > 0 ? l.headingLevel : null),
      ]),
  ];
  if (result.fold<int>(0, (a, p) => a + p.text.trim().length) < 20) throw ExtractError('damaged');
  return result;
}
