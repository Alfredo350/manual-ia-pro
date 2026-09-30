/// Documento del usuario (la versión básica admite solo uno).
class DocumentInfo {
  DocumentInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.pages,
    required this.status,
    this.progress = 0,
    this.language = 'es',
    this.suggestions = const [],
    this.questionCount = 0,
  });

  final String id;
  final String name;

  /// 'pdf' o 'docx'
  final String type;
  final int pages;

  /// 'processing' | 'ready' | 'error'
  final String status;

  /// 0..100 mientras se procesa.
  final int progress;

  /// Idioma detectado del documento.
  final String language;

  /// Temas del documento (títulos de sus secciones).
  final List<String> suggestions;

  /// Preguntas hechas sobre este documento (versión Pro).
  final int questionCount;

  DocumentInfo copyWith({String? name, String? status, int? progress, int? questionCount}) => DocumentInfo(
        id: id,
        name: name ?? this.name,
        type: type,
        pages: pages,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        language: language,
        suggestions: suggestions,
        questionCount: questionCount ?? this.questionCount,
      );

  bool get isReady => status == 'ready';
  bool get isProcessing => status == 'processing';
  bool get hasError => status == 'error';

  factory DocumentInfo.fromJson(Map<String, dynamic> j) => DocumentInfo(
        id: j['id'].toString(),
        name: j['name'] as String? ?? '',
        type: j['type'] as String? ?? 'pdf',
        pages: (j['pages'] as num?)?.toInt() ?? 0,
        status: j['status'] as String? ?? 'processing',
        progress: (j['progress'] as num?)?.toInt() ?? 0,
        language: j['language'] as String? ?? 'es',
        suggestions: (j['suggestions'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        questionCount: (j['question_count'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'pages': pages,
        'status': status,
        'progress': progress,
        'language': language,
        'suggestions': suggestions,
        'question_count': questionCount,
      };
}

/// Lugar del documento donde está la respuesta.
class SourceRef {
  SourceRef({required this.page, required this.section, required this.excerpt, this.start = 0, this.end = 0});

  final int page;
  final String section;

  /// Texto original del documento.
  final String excerpt;

  /// Posición del fragmento en el texto de la página (para recortar la captura y resaltarla).
  final int start;
  final int end;

  factory SourceRef.fromJson(Map<String, dynamic> j) => SourceRef(
        page: (j['page'] as num?)?.toInt() ?? 0,
        section: j['section'] as String? ?? '',
        excerpt: j['excerpt'] as String? ?? '',
        start: (j['start'] as num?)?.toInt() ?? 0,
        end: (j['end'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {'page': page, 'section': section, 'excerpt': excerpt, 'start': start, 'end': end};
}

/// Resultado de buscar una pregunta en el documento.
class Answer {
  Answer({required this.found, required this.sources, this.related = const [], this.language});

  /// false cuando el documento no contiene la respuesta.
  final bool found;

  /// La primera fuente es la respuesta; las demás, otras coincidencias.
  final List<SourceRef> sources;

  /// Si no se encontró: títulos de secciones parecidas.
  final List<String> related;

  /// Idioma del documento (para leerlo en voz alta con la voz correcta).
  final String? language;

  String get text => found && sources.isNotEmpty ? sources.first.excerpt : '';
}

/// Mensaje del chat.
class ChatMessage {
  ChatMessage.user(this.text, {this.byVoice = false})
      : fromUser = true,
        found = true,
        sources = const [],
        related = const [],
        language = null;

  ChatMessage.answer(Answer a)
      : fromUser = false,
        byVoice = false,
        text = a.text,
        found = a.found,
        sources = a.sources,
        related = a.related,
        language = a.language;

  ChatMessage._(this.fromUser, this.byVoice, this.text, this.found, this.sources, this.related, this.language);

  final bool fromUser;
  final bool byVoice;
  final String text;
  final bool found;
  final List<SourceRef> sources;
  final List<String> related;
  final String? language;

  /// Historial guardado (versión Pro).
  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage._(
        j['role'] == 'user',
        j['by_voice'] as bool? ?? false,
        j['text'] as String? ?? '',
        j['found'] as bool? ?? true,
        (j['sources'] as List?)?.map((e) => SourceRef.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
        (j['related'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        j['language'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'role': fromUser ? 'user' : 'ai',
        'by_voice': byVoice,
        'text': text,
        'found': found,
        'language': language,
        'sources': sources.map((s) => s.toJson()).toList(),
        'related': related,
      };
}

/// Uso diario de preguntas.
class Usage {
  Usage({required this.usedToday, required this.limit});
  final int usedToday;
  final int limit;

  int get remaining => usedToday >= limit ? 0 : limit - usedToday;
  bool get limitReached => usedToday >= limit;

}
