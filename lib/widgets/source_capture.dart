import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';

import '../engine/search_engine.dart';
import '../models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'common.dart';

/// Recorte de la página donde está la respuesta, con el texto resaltado.
class CaptureData {
  CaptureData(this.image, this.crop, this.highlights);

  /// Imagen de la zona recortada.
  final ui.Image image;

  /// Zona recortada, en puntos de la página.
  final Rect crop;

  /// Líneas resaltadas, en puntos, relativas a la zona recortada.
  final List<Rect> highlights;
}

/// Dibuja recortes de páginas PDF en el teléfono (con pdfrx / PDFium).
class PdfCaptureService {
  PdfCaptureService._();
  static final instance = PdfCaptureService._();

  final Map<String, Future<PdfDocument>> _docs = {};
  final LinkedHashMap<String, Future<CaptureData?>> _cache = LinkedHashMap();

  Future<PdfDocument> _open(String path) => _docs.putIfAbsent(
        path,
        () => PdfDocument.openFile(path).catchError((Object e) {
          _docs.remove(path);
          throw e;
        }),
      );

  Future<CaptureData?> capture(String path, int pageNumber, int start, int end, {bool fullPage = false}) {
    final key = '$path|$pageNumber|$start|$end|$fullPage';
    final hit = _cache.remove(key);
    if (hit != null) {
      _cache[key] = hit;
      return hit;
    }
    final f = _render(path, pageNumber, start, end, fullPage).catchError((_) {
      _cache.remove(key); // no se guarda un fallo: se reintenta la próxima vez
      return null;
    });
    _cache[key] = f;
    while (_cache.length > 16) {
      _cache.remove(_cache.keys.first);
    }
    return f;
  }

  /// Cierra el PDF (al eliminar o reemplazar el documento).
  Future<void> close(String path) async {
    _cache.removeWhere((k, _) => k.startsWith('$path|'));
    final d = _docs.remove(path);
    if (d != null) {
      try {
        await (await d).dispose();
      } catch (_) {}
    }
  }

  Future<CaptureData?> _render(String path, int pageNumber, int start, int end, bool fullPage) async {
    final doc = await _open(path);
    if (pageNumber < 1 || pageNumber > doc.pages.length) return null;
    final page = doc.pages[pageNumber - 1];
    final text = await page.loadStructuredText();

    // Rectángulos de cada letra del fragmento → una franja por línea.
    final n = math.min(text.charRects.length, text.fullText.length);
    final s = math.min(math.max(start, 0), n);
    final e = math.min(math.max(end, s), n);
    final chars = <Rect>[];
    for (var i = s; i < e; i++) {
      if (text.fullText[i].trim().isEmpty) continue;
      final r = text.charRects[i];
      if (r.isEmpty) continue;
      chars.add(r.toRect(page: page));
    }
    final lines = _mergeLines(chars);

    final pw = page.width, ph = page.height;
    Rect crop;
    if (fullPage || lines.isEmpty) {
      crop = Rect.fromLTWH(0, 0, pw, ph);
    } else {
      final minLeft = lines.map((r) => r.left).reduce(math.min);
      final maxRight = lines.map((r) => r.right).reduce(math.max);
      final top = math.max(0.0, lines.first.top - 30);
      final bottom = math.min(ph, math.min(lines.last.bottom + 22, top + 420));
      final left = math.max(0.0, math.min(pw * 0.06, minLeft - 12));
      final right = math.min(pw, math.max(pw * 0.94, maxRight + 12));
      crop = Rect.fromLTRB(left, top, right, bottom);
    }

    // Píxeles por punto: nítido en pantallas de alta densidad.
    final scale = (fullPage ? 1400 : 1000) / crop.width;
    final img = await page.render(
      x: (crop.left * scale).round(),
      y: (crop.top * scale).round(),
      width: math.max(1, (crop.width * scale).round()),
      height: math.max(1, (crop.height * scale).round()),
      fullWidth: pw * scale,
      fullHeight: ph * scale,
    );
    if (img == null) return null;
    final image = await img.createImage();
    img.dispose();
    return CaptureData(image, crop, [for (final r in lines) r.shift(-crop.topLeft)]);
  }

  static List<Rect> _mergeLines(List<Rect> chars) {
    final sorted = [...chars]..sort((a, b) => a.center.dy.compareTo(b.center.dy));
    final lines = <Rect>[];
    for (final r in sorted) {
      if (lines.isNotEmpty && (r.center.dy - lines.last.center.dy).abs() < math.max(2.0, lines.last.height * 0.6)) {
        lines[lines.length - 1] = lines.last.expandToInclude(r);
      } else {
        lines.add(r);
      }
    }
    return [for (final l in lines) l.inflate(2)];
  }
}

class _CapturePainter extends CustomPainter {
  _CapturePainter(this.data);
  final CaptureData data;

  @override
  void paint(Canvas canvas, Size size) {
    final img = data.image;
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.high,
    );
    final k = size.width / data.crop.width;
    final paint = Paint()
      ..color = const Color(0xFFFFD54A)
      ..blendMode = BlendMode.multiply;
    for (final r in data.highlights) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(r.left * k, r.top * k, r.right * k, r.bottom * k), const Radius.circular(3)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CapturePainter old) => old.data != data;
}

/// Captura del documento en el lugar de la respuesta.
/// PDF: recorte real de la página. Word: vista del documento con el párrafo resaltado.
class SourceCapture extends StatelessWidget {
  const SourceCapture({super.key, required this.doc, required this.source, this.fullPage = false, this.onTap});
  final DocumentInfo doc;
  final SourceRef source;
  final bool fullPage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final l = context.select<AppState, String>((s) => s.lang);
    final label = state.l.captureOf(source.page);

    Widget body;
    if (doc.type == 'pdf') {
      final path = state.sourcePathOf(doc)!;
      body = FutureBuilder<CaptureData?>(
        key: ValueKey('${doc.id}-${source.page}-${source.start}-$fullPage'),
        future: PdfCaptureService.instance.capture(path, source.page, source.start, source.end, fullPage: fullPage),
        builder: (context, snap) {
          final d = snap.data;
          if (snap.connectionState != ConnectionState.done) return const _CaptureLoading();
          if (d == null) return _DocxSnippet(doc: doc, source: source, fullPage: fullPage);
          return AspectRatio(
            aspectRatio: d.crop.width / d.crop.height,
            child: CustomPaint(painter: _CapturePainter(d)),
          );
        },
      );
    } else {
      body = _DocxSnippet(doc: doc, source: source, fullPage: fullPage);
    }

    return Semantics(
      label: label,
      button: onTap != null,
      image: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          key: ValueKey(l),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lineStrong),
            boxShadow: const [BoxShadow(color: Color(0x140B1B3F), blurRadius: 10, offset: Offset(0, 3))],
          ),
          child: Stack(children: [
            body,
            if (onTap != null)
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: const Color(0xCC0B1B3F), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.zoom_out_map_rounded, size: 18, color: Colors.white),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class _CaptureLoading extends StatelessWidget {
  const _CaptureLoading();

  @override
  Widget build(BuildContext context) => Container(
        height: 120,
        color: AppColors.softest,
        alignment: Alignment.center,
        child: const SizedBox(
            width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary)),
      );
}

/// Word (o PDF sin dibujo): muestra las líneas de la página con el fragmento resaltado.
class _DocxSnippet extends StatelessWidget {
  const _DocxSnippet({required this.doc, required this.source, required this.fullPage});
  final DocumentInfo doc;
  final SourceRef source;
  final bool fullPage;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return FutureBuilder<DocIndex>(
      future: state.library.index(doc),
      builder: (context, snap) {
        final ix = snap.data;
        if (ix == null) return const _CaptureLoading();
        final page = ix.pages.where((p) => p.number == source.page).firstOrNull;
        if (page == null) return const SizedBox(height: 40);
        var first = page.lines.indexWhere((l) => l.end > source.start);
        var last = page.lines.lastIndexWhere((l) => l.start < source.end);
        if (first < 0) first = 0;
        if (last < first) last = first;
        final from = fullPage ? 0 : math.max(0, first - 1);
        final to = fullPage ? page.lines.length - 1 : math.min(page.lines.length - 1, last + 1);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          color: Colors.white,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (var i = from; i <= to; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _line(page.line(i).trim(), i >= first && i <= last,
                    (page.lines[i].headingLevel ?? 0) > 0 || (page.lines[i].headingLevel == null && _isTitle(page.line(i)))),
              ),
          ]),
        );
      },
    );
  }

  static bool _isTitle(String t) => RegExp(r'^\d+(\.\d+)*\.?\s+[A-ZÁÉÍÓÚÑ]').hasMatch(t.trim()) && !t.trim().endsWith('.');

  Widget _line(String t, bool hit, bool title) {
    final style = TextStyle(
      fontFamily: 'serif',
      fontSize: title ? 15 : 13.5,
      height: 1.5,
      fontWeight: title ? FontWeight.w700 : FontWeight.w400,
      color: hit ? AppColors.ink : AppColors.muted,
    );
    if (!hit) return Text(t, style: style);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(color: const Color(0xFFFFE9A8), borderRadius: BorderRadius.circular(3)),
      child: Text(t, style: style),
    );
  }
}

/// Página completa con la respuesta resaltada (se puede ampliar con dos dedos).
class PageViewerScreen extends StatelessWidget {
  const PageViewerScreen({super.key, required this.doc, required this.source});
  final DocumentInfo doc;
  final SourceRef source;

  @override
  Widget build(BuildContext context) {
    final l = context.watch<AppState>().l;
    return Scaffold(
      backgroundColor: const Color(0xFFE9EEF7),
      appBar: BackHeader(title: '${l.pageWord} ${source.page}'),
      body: Column(children: [
        if (source.section.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(source.section, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ),
        Expanded(
          child: InteractiveViewer(
            maxScale: 5,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: [SourceCapture(doc: doc, source: source, fullPage: true)],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(children: [
              Text(l.highlightNote,
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.muted)),
              const SizedBox(height: 10),
              SecondaryButton(
                label: l.copy,
                icon: Icons.copy_rounded,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: source.excerpt));
                  showSnack(context, l.copied);
                },
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
