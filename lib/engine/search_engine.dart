import 'dart:math' as math;

import 'text_utils.dart';

/// Línea de una página: posición dentro del texto de la página.
/// [headingLevel] viene del propio archivo (estilos «Título 1», «Título 2» de Word):
/// 0 = texto normal, 1..9 = título. Si es null se deduce del texto.
class DocLine {
  const DocLine(this.start, this.end, {this.headingLevel});
  final int start;
  final int end;
  final int? headingLevel;
}

/// Texto de una página del documento, separado en líneas.
class DocPage {
  DocPage({required this.number, required this.text, required this.lines});

  /// Crea la página separando el texto en líneas por los saltos de línea.
  factory DocPage.fromText(int number, String text) {
    final lines = <DocLine>[];
    var start = 0;
    for (var i = 0; i <= text.length; i++) {
      if (i == text.length || text[i] == '\n') {
        if (i > start) lines.add(DocLine(start, i));
        start = i + 1;
      }
    }
    return DocPage(number: number, text: text, lines: lines);
  }

  final int number;
  final String text;
  final List<DocLine> lines;

  String line(int i) => text.substring(lines[i].start, lines[i].end);

  Map<String, dynamic> toJson() => {
        'n': number,
        't': text,
        'l': [
          for (final l in lines) [l.start, l.end, l.headingLevel ?? -1]
        ],
      };

  factory DocPage.fromJson(Map<String, dynamic> j) => DocPage(
        number: j['n'] as int,
        text: j['t'] as String,
        lines: [
          for (final l in (j['l'] as List))
            DocLine(l[0] as int, l[1] as int, headingLevel: l[2] == -1 ? null : l[2] as int),
        ],
      );
}

/// Fragmento del documento donde está una respuesta.
class SearchHit {
  SearchHit({
    required this.page,
    required this.section,
    required this.text,
    required this.charStart,
    required this.charEnd,
  });

  final int page;
  final String section;

  /// Texto del fragmento (tal como está en el documento).
  final String text;

  /// Posición del fragmento dentro del texto de la página (para recortar y resaltar).
  final int charStart;
  final int charEnd;
}

class SearchResult {
  SearchResult({required this.found, required this.hits, required this.related});
  final bool found;
  final List<SearchHit> hits;

  /// Si no se encontró: títulos de secciones parecidas para sugerir.
  final List<String> related;
}

class _Passage {
  _Passage(this.page, this.section, this.context);
  final DocPage page;
  final String section;
  final String context;
  final List<int> body = [];
  List<List<String>> lineTerms = const [];
  List<String> ctxTerms = const [];
  List<String> secTerms = const [];
  final Map<String, int> tf = {};
  int len = 0;
}

/// Índice de búsqueda de un documento (BM25 + reglas).
/// La misma lógica se usa en el prototipo de diseño (engine.js).
class DocIndex {
  DocIndex._(this.pages, this._passages, this._df, this._avg);

  final List<DocPage> pages;
  final List<_Passage> _passages;
  final Map<String, int> _df;
  final double _avg;

  static const double _minCoverage = 0.45;
  static const int _windowLines = 8;

  bool get isEmpty => _passages.isEmpty;

  factory DocIndex.build(List<DocPage> pages) {
    // 1. Encabezados y pies de página repetidos: se ignoran.
    final seen = <String, int>{};
    String key(String t) => normalize(t).replaceAll(RegExp(r'\d+'), '#').trim();
    for (final p in pages) {
      final keys = <String>{for (var i = 0; i < p.lines.length; i++) key(p.line(i))};
      for (final k in keys) {
        seen[k] = (seen[k] ?? 0) + 1;
      }
    }
    final np = pages.length;
    bool boiler(String t) => np >= 3 && (seen[key(t)] ?? 0) >= math.max(2, np * 0.5);

    // 2. Pasajes: de un título al siguiente, dentro de cada página.
    final passages = <_Passage>[];
    var path = <String>[];
    _Passage? cur;
    void close() {
      if (cur != null && cur!.body.isNotEmpty) passages.add(cur!);
      cur = null;
    }

    String ctx() => path.where((e) => e.isNotEmpty).join(' › ');

    for (final p in pages) {
      close();
      for (var i = 0; i < p.lines.length; i++) {
        final t = p.line(i).trim();
        if (t.isEmpty || boiler(t)) continue;
        final styled = p.lines[i].headingLevel;
        final isHead = styled != null ? styled > 0 : looksLikeHeading(t);
        if (isHead) {
          close();
          final lv = (styled != null && styled > 0) ? styled : headingLevel(t);
          path = [...path.take(lv - 1)];
          while (path.length < lv - 1) {
            path.add('');
          }
          path.add(t);
          cur = _Passage(p, t, ctx());
          continue;
        }
        cur ??= _Passage(p, path.isEmpty ? '' : path.last, ctx());
        // Un pasaje muy largo se corta al final de una oración.
        final c = cur!;
        if (c.body.isNotEmpty) {
          final len = c.body.fold<int>(0, (a, j) => a + p.line(j).length);
          final last = p.line(c.body.last).trim();
          if (len > 700 && (last.endsWith('.') || last.endsWith(':'))) {
            close();
            cur = _Passage(p, c.section, c.context);
          }
        }
        cur!.body.add(i);
      }
    }
    close();

    // 3. Índice BM25.
    final df = <String, int>{};
    var total = 0;
    for (final ps in passages) {
      ps.lineTerms = [for (final j in ps.body) terms(ps.page.line(j))];
      ps.ctxTerms = terms(ps.context);
      ps.secTerms = terms(ps.section);
      final all = [...ps.ctxTerms, for (final lt in ps.lineTerms) ...lt];
      for (final w in all) {
        ps.tf[w] = (ps.tf[w] ?? 0) + 1;
      }
      ps.len = all.length;
      total += all.length;
      for (final w in ps.tf.keys) {
        df[w] = (df[w] ?? 0) + 1;
      }
    }
    return DocIndex._(pages, passages, df, passages.isEmpty ? 1 : total / passages.length);
  }

  /// Una palabra que no está en el documento pesa como una palabra rara.
  double _idf(String w) {
    final n = _passages.length;
    final d = math.max(1, _df[w] ?? 0);
    return math.log(1 + (n - d + 0.5) / (d + 0.5));
  }

  SearchResult search(String question) {
    final qs = terms(question);
    final q = <String>[];
    for (final w in qs) {
      if (!q.contains(w)) q.add(w);
    }
    if (q.isEmpty || _passages.isEmpty) return SearchResult(found: false, hits: const [], related: const []);

    final wsum = q.fold<double>(0, (a, w) => a + _idf(w));
    const k1 = 1.2, b = 0.75;
    final scored = <({_Passage ps, double score, double cov, int order})>[];
    for (var order = 0; order < _passages.length; order++) {
      final ps = _passages[order];
      var s = 0.0, cov = 0.0;
      for (final w in q) {
        final f = ps.tf[w] ?? 0;
        if (f == 0) continue;
        final i = _idf(w);
        s += i * (f * (k1 + 1)) / (f + k1 * (1 - b + b * ps.len / _avg));
        cov += i;
        if (ps.secTerms.contains(w)) {
          s += i * 0.8; // palabra en el título de la sección
        } else if (ps.ctxTerms.contains(w)) {
          s += i * 0.3; // o en el capítulo
        }
      }
      // Dos palabras seguidas de la pregunta aparecen seguidas en el texto.
      final flat = [for (final lt in ps.lineTerms) ...lt];
      for (var k = 0; k + 1 < qs.length; k++) {
        for (var m = 0; m + 1 < flat.length; m++) {
          if (flat[m] == qs[k] && flat[m + 1] == qs[k + 1]) {
            s *= 1.15;
            break;
          }
        }
      }
      cov = wsum > 0 ? cov / wsum : 0;
      if (s > 0) scored.add((ps: ps, score: s * (0.5 + cov), cov: cov, order: order));
    }
    // Orden estable: a igual puntaje, primero el que aparece antes en el documento.
    scored.sort((a, b) {
      final c = b.score.compareTo(a.score);
      return c != 0 ? c : a.order.compareTo(b.order);
    });

    final ok = scored.where((r) => r.cov >= _minCoverage).toList();
    if (ok.isEmpty) {
      final rel = <String>[];
      for (final r in scored) {
        if (r.ps.section.isNotEmpty && !rel.contains(r.ps.section) && rel.length < 3) rel.add(r.ps.section);
      }
      return SearchResult(found: false, hits: const [], related: rel);
    }
    final top = ok.first.score;
    final pick = ok.where((r) => r.score >= top * 0.35).take(3);
    return SearchResult(found: true, hits: [for (final r in pick) _window(r.ps, q)], related: const []);
  }

  /// Elige hasta 8 líneas seguidas del pasaje con más coincidencias.
  SearchHit _window(_Passage ps, List<String> q) {
    final n = ps.body.length;
    var best = 0;
    if (n > _windowLines) {
      var bestScore = -1.0;
      for (var s = 0; s + _windowLines <= n; s++) {
        var sc = 0.0;
        for (var k = s; k < s + _windowLines; k++) {
          for (final w in ps.lineTerms[k]) {
            if (q.contains(w)) sc += _idf(w);
          }
        }
        if (sc > bestScore) {
          bestScore = sc;
          best = s;
        }
      }
    }
    final lines = ps.body.sublist(best, best + math.min(_windowLines, n));
    final p = ps.page;
    return SearchHit(
      page: p.number,
      section: ps.section,
      text: joinLines([for (final j in lines) p.line(j)]),
      charStart: p.lines[lines.first].start,
      charEnd: p.lines[lines.last].end,
    );
  }

  /// Títulos de secciones para mostrar como temas del manual.
  List<String> topics(int max) {
    final out = <String>[];
    final sub = RegExp(r'^\d+\.\d+');
    for (final ps in _passages) {
      if (ps.section.isNotEmpty && sub.hasMatch(ps.section) && !out.contains(ps.section)) out.add(ps.section);
    }
    if (out.length < max) {
      for (final ps in _passages) {
        if (ps.section.isNotEmpty && !out.contains(ps.section)) out.add(ps.section);
      }
    }
    return out.take(max).toList();
  }
}

/// Une las líneas cortadas del PDF en párrafos, respetando listas y tablas.
String joinLines(List<String> lines) {
  final b = StringBuffer();
  for (var k = 0; k < lines.length; k++) {
    final t = lines[k].trim();
    if (k == 0) {
      b.write(t);
      continue;
    }
    final prev = lines[k - 1].trim();
    final newLine = isListItem(t) ||
        prev.endsWith('.') ||
        prev.endsWith(':') ||
        prev.endsWith('!') ||
        prev.endsWith('?') ||
        prev.length < 60;
    b.write(newLine ? '\n$t' : ' $t');
  }
  return b.toString();
}
