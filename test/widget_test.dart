import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:manual_ia_pro/engine/search_engine.dart';
import 'package:manual_ia_pro/engine/text_utils.dart';
import 'package:manual_ia_pro/l10n/l10n.dart';

/// Pruebas del buscador (sin IA) con el manual de ejemplo en ES / EN / PT.
/// Ejecuta:  flutter test
void main() {
  final fixture = jsonDecode(File('test/fixtures/sample_pages.json').readAsStringSync()) as Map<String, dynamic>;
  DocIndex indexFor(String lang) => DocIndex.build([
        for (final p in fixture[lang] as List) DocPage.fromText(p['n'] as int, p['text'] as String),
      ]);

  void expectSection(DocIndex ix, String q, String section) {
    final r = ix.search(q);
    expect(r.found, isTrue, reason: q);
    expect(r.hits.first.section, section, reason: q);
  }

  test('raíces de palabras', () {
    expect(stem('anulaciones'), stem('anular'));
    expect(stem('closing'), stem('close'));
    expect(normalize('Anulación'), 'anulacion');
  });

  test('español', () {
    final ix = indexFor('es');
    expectSection(ix, '¿Cómo se realiza el cierre de caja?', '4.2 Cierre de caja');
    expectSection(ix, '¿Quién autoriza una anulación de venta?', '3.3 Anulaciones');
    expectSection(ix, '¿Qué hacer si hay una diferencia en el arqueo?', '4.3 Diferencias');
    expectSection(ix, '¿Dónde se guarda el acta de cierre?', '4.4 Archivo del acta');
    expectSection(ix, 'que hago con un billete falso', '5.2 Billetes sospechosos');
    expectSection(ix, 'como pago con QR', '3.2 Medios de pago');
    expect(ix.search('¿Cuál es el horario del supervisor?').found, isFalse);
  });

  test('inglés', () {
    final ix = indexFor('en');
    expectSection(ix, 'How do I close the cash register?', '4.2 Closing the register');
    expectSection(ix, 'Who authorizes a sale cancellation?', '3.3 Cancellations');
    expect(ix.search('What are the supervisor’s hours?').found, isFalse);
  });

  test('portugués', () {
    final ix = indexFor('pt');
    expectSection(ix, 'Como é feito o fechamento de caixa?', '4.2 Fechamento de caixa');
    expectSection(ix, 'Onde fica guardada a ata de fechamento?', '4.4 Arquivo da ata');
  });

  test('la respuesta apunta al texto exacto de la página', () {
    final ix = indexFor('es');
    final h = ix.search('¿Quién autoriza una anulación de venta?').hits.first;
    final page = ix.pages.firstWhere((p) => p.number == h.page);
    expect(page.text.substring(h.charStart, h.charEnd), contains('Solo el supervisor de turno'));
  });

  test('idioma del documento y textos', () {
    expect(detectLanguage('El cajero cuenta el efectivo y lo compara con el reporte'), 'es');
    expect(detectLanguage('The cashier counts the cash and compares it with the report'), 'en');
    expect(const L('es').left(3), 'Te quedan 3 de 5 preguntas hoy');
    expect(const L('en').foundIn(4), 'Found on page 4');
  });
}
