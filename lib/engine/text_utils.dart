/// Utilidades de texto para la búsqueda: normalizar, separar palabras y reducirlas a su raíz.
/// Todo funciona con reglas fijas (sin IA) y en español, inglés y portugués.
library;

const _accents = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n',
};

final _combining = RegExp('[\u0300-\u036f]');

/// Minúsculas y sin tildes: "Anulación" → "anulacion".
String normalize(String s) {
  final lower = s.toLowerCase().replaceAll(_combining, '');
  final b = StringBuffer();
  for (final ch in lower.split('')) {
    b.write(_accents[ch] ?? ch);
  }
  return b.toString();
}

final _wordRe = RegExp(r'[a-z0-9]+');

List<String> words(String s) => _wordRe.allMatches(normalize(s)).map((m) => m.group(0)!).toList();

/// Palabras vacías (artículos, preposiciones, palabras de pregunta) en ES / EN / PT.
final Set<String> stopWords = {
  ...'de la que el en y a los del se las por un para con no una su al lo como mas pero sus le ya o este si porque esta entre cuando muy sin sobre tambien me hasta hay donde quien desde todo nos durante todos uno les ni contra otros ese eso ante ellos e esto mi antes algunos unos yo otro otras otra el tanto esa estos mucho quienes nada muchos cual poco ella estar estas algunas algo nosotros mis tu te ti tus ellas cuales cuanto cuanta cuantos es son fue ser hacer hago hace hacen puedo puede pueden debo debe deben tengo tiene tienen dice decir manual documento favor quiero saber necesito sea estan estoy sucede pasa ocurre'
      .split(' '),
  ...'a an the of to in on for and or is are was were be been do does did how what when where who whom which why can could should would i me my we you your it its this that these those there here with by from at as about into than then so if not no yes please tell say says must need have has get doesn don isn aren didn up us am oh'
      .split(' '),
  ...'de a o que e do da em um para com nao uma os no se na por mais as dos como mas foi ao ele das tem seu sua ou ser quando muito ha nos ja esta eu tambem so pelo pela ate isso ela entre era depois sem mesmo aos ter seus quem nas me esse eles estao voce tinha foram essa num nem suas meu minha numa pelos elas havia seja qual sera tenho lhe deles essas esses pelas este fosse dele tu te voces vos lhes meus minhas teu tua teus tuas nosso nossa nossos nossas dela delas estes estas aquele aquela aqueles aquelas isto aquilo onde quanto posso pode devo deve fazer faco diz fica ficam feito feita houver acontece preciso un ni yo su al lo le em na ao um'
      .split(' '),
};

final _digits = RegExp(r'^\d+$');

/// Raíz aproximada: quita plural, -ing/-ed y la vocal final, y se queda con 5 letras.
/// "anulaciones" y "anular" → "anula"; "closing" y "close" → "clos".
String stem(String w) {
  if (_digits.hasMatch(w)) return w;
  if (w.length > 3 && w.endsWith('s')) w = w.substring(0, w.length - 1);
  if (w.length > 4 && w.endsWith('ing')) {
    w = w.substring(0, w.length - 3);
  } else if (w.length > 4 && w.endsWith('ed')) {
    w = w.substring(0, w.length - 2);
  }
  if (w.length > 3 && (w.endsWith('a') || w.endsWith('e') || w.endsWith('o'))) w = w.substring(0, w.length - 1);
  return w.length > 5 ? w.substring(0, 5) : w;
}

/// Palabras útiles de un texto, ya reducidas a su raíz.
List<String> terms(String s) {
  final out = <String>[];
  for (final w in words(s)) {
    if (w.length < 2 || stopWords.contains(w)) continue;
    out.add(stem(w));
  }
  return out;
}

final _numbered = RegExp(r'^\d+(\.\d+)*\.?\s+[A-ZÁÉÍÓÚÑÇÂÊÔÃÕ]');
final _endPunct = RegExp(r'[.;,]$');
final _nonLetters = RegExp(r'[^A-Za-zÁÉÍÓÚÑÇÂÊÔÃÕáéíóúñçâêôãõ]');
final _spaces = RegExp(r'\s+');

/// ¿La línea parece un título? ("4.2 Cierre de caja", "SEGURIDAD")
bool looksLikeHeading(String t) {
  t = t.trim();
  if (t.length < 2 || t.length > 90) return false;
  if (_endPunct.hasMatch(t)) return false;
  final n = t.split(_spaces).length;
  if (n > 12) return false;
  if (_numbered.hasMatch(t)) return true;
  final letters = t.replaceAll(_nonLetters, '');
  return letters.length >= 4 && letters == letters.toUpperCase() && n <= 8;
}

final _levelRe = RegExp(r'^(\d+(?:\.\d+)*)');

/// Nivel del título según su numeración: "4" → 1, "4.2" → 2.
int headingLevel(String t) {
  final m = _levelRe.firstMatch(t.trim());
  return m == null ? 1 : m.group(1)!.split('.').length;
}

final _listItem = RegExp(r'^\s*(\d+[.)]|[-•·*])\s+');
bool isListItem(String t) => _listItem.hasMatch(t);

/// Idioma probable de un texto: 'es', 'en' o 'pt'.
String detectLanguage(String text) {
  final w = words(text).take(400);
  const markers = {
    'es': {'el', 'la', 'los', 'las', 'del', 'que', 'para', 'por', 'con', 'una', 'es', 'se', 'al', 'lo', 'como', 'pero'},
    'en': {'the', 'and', 'of', 'to', 'is', 'for', 'with', 'that', 'this', 'are', 'be', 'on', 'you'},
    'pt': {'o', 'os', 'da', 'do', 'das', 'dos', 'que', 'para', 'com', 'uma', 'nao', 'voce', 'sao', 'em', 'ao', 'pelo'},
  };
  final count = {'es': 0, 'en': 0, 'pt': 0};
  for (final x in w) {
    markers.forEach((k, set) {
      if (set.contains(x)) count[k] = count[k]! + 1;
    });
  }
  var best = 'es';
  count.forEach((k, v) {
    if (v > count[best]!) best = k;
  });
  return best;
}
