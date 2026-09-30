// Textos de la app en español, inglés y portugués.
// Para cambiar un texto, edita el mapa de su idioma.

class L {
  const L(this.lang);
  final String lang;

  static const supported = ['es', 'en', 'pt'];

  String get proBadge => _t('proBadge');
  String get pb1 => _t('pb1');
  String get pb2 => _t('pb2');
  String get pb3 => _t('pb3');
  String get pb4 => _t('pb4');
  String get library => _t('library');
  String get searchPh => _t('searchPh');
  String get options => _t('options');
  String get deleteDoc => _t('deleteDoc');
  String get deleteBody => _t('deleteBody');
  String get deleteBtn => _t('deleteBtn');
  String get proUploadNote => _t('proUploadNote');
  String get historySaved => _t('historySaved');
  String get versionPro => _t('versionPro');
  String get docsRow => _t('docsRow');
  String get emptyLibTitle => _t('emptyLibTitle');
  String get emptyLibText => _t('emptyLibText');
  String get goLibrary => _t('goLibrary');
  String get unlimited => _t('unlimited');
  String docsCount(int n) => _t('docsCount').replaceAll('{n}', '$n');
  String questionsN(int n) => _t('questionsN').replaceAll('{n}', '$n');
  String deleteQ(String doc) => _t('deleteQ').replaceAll('{doc}', doc);
  String get priv3pro => _t('priv3pro');
  String get priv5pro => _t('priv5pro');
  String get appNamePro => _t('appNamePro');
  String get noResults => _t('noResults');
  String get privTitle => _t('privTitle');
  String get privLead => _t('privLead');
  String get aiTitle => _t('aiTitle');
  String get aiBody => _t('aiBody');
  String get aiNote => _t('aiNote');
  String get priv1 => _t('priv1');
  String get priv2 => _t('priv2');
  String get priv3 => _t('priv3');
  String get priv4 => _t('priv4');
  String get priv5 => _t('priv5');
  String get notHeard => _t('notHeard');
  String get voiceNetwork => _t('voiceNetwork');
  String get brandSub => _t('brandSub');
  String get tag1 => _t('tag1');
  String get tag2 => _t('tag2');
  String get sub => _t('sub');
  String get guides => _t('guides');
  String get basicBadge => _t('basicBadge');
  String get b1 => _t('b1');
  String get b2 => _t('b2');
  String get b3 => _t('b3');
  String get b4 => _t('b4');
  String get uploadMine => _t('uploadMine');
  String get useSample => _t('useSample');
  String get settings => _t('settings');
  String get today => _t('today');
  String get renews => _t('renews');
  String get ready => _t('ready');
  String get ask => _t('ask');
  String get voiceTitle => _t('voiceTitle');
  String get replace => _t('replace');
  String get suggested => _t('suggested');
  String get noDocTitle => _t('noDocTitle');
  String get noDocText => _t('noDocText');
  String get upload => _t('upload');
  String get oneDocNote => _t('oneDocNote');
  String get pick => _t('pick');
  String get choose => _t('choose');
  String get s1 => _t('s1');
  String get s2 => _t('s2');
  String get s3 => _t('s3');
  String get s4 => _t('s4');
  String get leaveNote => _t('leaveNote');
  String get goHome => _t('goHome');
  String get onlyDoc => _t('onlyDoc');
  String get doneToday => _t('doneToday');
  String get pg => _t('pg');
  String get askPh => _t('askPh');
  String get send => _t('send');
  String get voiceAsk => _t('voiceAsk');
  String get listening => _t('listening');
  String get listeningHint => _t('listeningHint');
  String get cancel => _t('cancel');
  String get sendVoice => _t('sendVoice');
  String get listen => _t('listen');
  String get pause => _t('pause');
  String get limitTitle => _t('limitTitle');
  String get limitBody => _t('limitBody');
  String get proTitle => _t('proTitle');
  String get proPitch => _t('proPitch');
  String get seeProBtn => _t('seeProBtn');
  String get gotIt => _t('gotIt');
  String get pageWord => _t('pageWord');
  String get highlightNote => _t('highlightNote');
  String get copy => _t('copy');
  String get proH1 => _t('proH1');
  String get proSub => _t('proSub');
  String get youHave => _t('youHave');
  String get getPro => _t('getPro');
  String get proNote => _t('proNote');
  String get language => _t('language');
  String get docRow => _t('docRow');
  String get proRow => _t('proRow');
  String get privacy => _t('privacy');
  String get about => _t('about');
  String get version => _t('version');
  String get autoRead => _t('autoRead');
  String get autoReadSub => _t('autoReadSub');
  String get appLang => _t('appLang');
  String get instant => _t('instant');
  String get langNote => _t('langNote');
  String get back => _t('back');
  String get close => _t('close');
  String get appTitle => _t('appTitle');
  String usedOf(int n) => _t('usedOf').replaceAll('{n}', '$n');
  String left(int n) => _t('left').replaceAll('{n}', '$n');
  String limits(int mb) => _t('limits').replaceAll('{mb}', '$mb');
  String docPages(int pages) => _t('docPages').replaceAll('{pages}', '$pages');
  String get processing => _t('processing');
  String get uploadError => _t('uploadError');
  String get retry => _t('retry');
  String get micDenied => _t('micDenied');
  String get sttUnavailable => _t('sttUnavailable');
  String get copied => _t('copied');
  String get pf1 => _t('pf1');
  String get pf2 => _t('pf2');
  String get pf3 => _t('pf3');
  String get pf4 => _t('pf4');
  String get nameEs => _t('nameEs');
  String get nameEn => _t('nameEn');
  String get namePt => _t('namePt');
  String get errorGeneric => _t('errorGeneric');
  String get replaceTitle => _t('replaceTitle');
  String get replaceBody => _t('replaceBody');
  String get replaceOk => _t('replaceOk');
  String get thinking => _t('thinking');
  String fileTooBig(int mb) => _t('fileTooBig').replaceAll('{mb}', '$mb');
  String pagesShort(int n) => _t('pagesShort').replaceAll('{n}', '$n');
  String get emptyChat => _t('emptyChat');
  String get pickFileError => _t('pickFileError');
  String get errScanned => _t('errScanned');
  String get errOldDoc => _t('errOldDoc');
  String get errPassword => _t('errPassword');
  String get errDamaged => _t('errDamaged');
  String foundIn(int n) => _t('foundIn').replaceAll('{n}', '$n');
  String get otherMatches => _t('otherMatches');
  String get notFoundTitle => _t('notFoundTitle');
  String get notFoundBody => _t('notFoundBody');
  String get relatedTopics => _t('relatedTopics');
  String get tapCapture => _t('tapCapture');
  String get fullPage => _t('fullPage');
  String captureOf(int n) => _t('captureOf').replaceAll('{n}', '$n');
  String get docView => _t('docView');
  String get sampleName => _t('sampleName');
  String get micPreparing => _t('micPreparing');
  String get micBlocked => _t('micBlocked');
  String get openSettings => _t('openSettings');
  String get useKeyboard => _t('useKeyboard');
  String get micBusy => _t('micBusy');
  String get tryAgain => _t('tryAgain');

  String _t(String k) => _data[lang]?[k] ?? _data['es']![k] ?? k;

  static const Map<String, Map<String, String>> _data = {
    'es': {
      'proBadge': 'Versión Pro',
      'pb1': 'Documentos ilimitados',
      'pb2': 'Preguntas ilimitadas, sin límite diario',
      'pb3': 'Pregunta por voz y escucha las respuestas',
      'pb4': 'Historial guardado en cada documento',
      'library': 'Biblioteca',
      'searchPh': 'Buscar en tus manuales',
      'options': 'Opciones',
      'deleteDoc': 'Eliminar documento',
      'deleteBody': 'Se borrarán el documento y su historial de preguntas.',
      'deleteBtn': 'Eliminar',
      'proUploadNote': 'Versión Pro: sube todos los documentos que necesites.',
      'historySaved': 'Historial guardado',
      'versionPro': 'Versión Pro 1.0',
      'docsRow': 'Documentos',
      'emptyLibTitle': 'Tu biblioteca está vacía',
      'emptyLibText': 'Sube tu primer manual en PDF o Word.',
      'goLibrary': 'Ir a la biblioteca',
      'unlimited': 'Sin límites',
      'docsCount': '{n} documentos · sin límites',
      'questionsN': '{n} preguntas',
      'deleteQ': '¿Eliminar «{doc}»?',
      'priv3pro': 'Tus documentos y conversaciones se guardan solo en este teléfono. Puedes eliminarlos cuando quieras.',
      'priv5pro': 'Sin publicidad ni rastreo. No compartimos ni vendemos nada, porque no recibimos nada.',
      'appNamePro': 'MANUAL IA Pro',
      'noResults': 'Sin resultados',
      'privTitle': 'Privacidad',
      'privLead': 'MANUAL IA no recopila ninguna información.',
      'aiTitle': 'Sin inteligencia artificial',
      'aiBody': 'Las respuestas se buscan con reglas en el texto de tu documento: no se generan ni se inventan. Siempre ves la página de donde salen.',
      'aiNote': 'Respuestas tomadas del texto del manual, con la página de origen.',
      'priv1': 'No pide nombre, correo, teléfono ni contraseña. No hay cuentas.',
      'priv2': 'Funciona sin internet: tus documentos y preguntas nunca salen del teléfono.',
      'priv3': 'Tu documento se guarda solo en este teléfono. Al reemplazarlo, el anterior se borra.',
      'priv4': 'El micrófono se usa solo mientras dictas. El dictado lo hace el servicio de voz de tu teléfono (por ejemplo, Google), que puede usar internet según su configuración.',
      'priv5': 'Sin publicidad ni rastreo. El contador de preguntas diarias se guarda solo en el teléfono.',
      'notHeard': 'No te escuché bien. Toca el micrófono y habla de nuevo.',
      'voiceNetwork': 'El dictado de tu teléfono necesita internet, o descargar el idioma para usarlo sin conexión (Ajustes de Google → Voz).',
      'brandSub': 'Tus documentos,\nrespuestas al instante',
      'tag1': 'Tu manual.',
      'tag2': 'Tu conocimiento.',
      'sub': 'Pregunta y encuentra la respuesta dentro de tus documentos.',
      'guides': 'Guías',
      'basicBadge': 'Versión básica · Gratis',
      'b1': '1 documento PDF o Word',
      'b2': '5 preguntas por día',
      'b3': 'Sin registro. Funciona sin internet',
      'b4': 'Pregunta por voz y escucha las respuestas',
      'uploadMine': 'Subir mi documento',
      'useSample': 'Probar con un manual de ejemplo',
      'settings': 'Ajustes',
      'today': 'Preguntas de hoy',
      'renews': 'Se renuevan cada día a las 00:00.',
      'ready': 'Listo para preguntar',
      'ask': 'Preguntar',
      'voiceTitle': 'Voz',
      'replace': 'Reemplazar documento',
      'suggested': 'Temas del manual',
      'noDocTitle': 'Aún no subiste tu documento',
      'noDocText': 'La versión básica permite 1 documento PDF o Word.',
      'upload': 'Subir documento',
      'oneDocNote': 'La versión básica permite 1 documento. Si subes otro, reemplaza al actual.',
      'pick': 'Selecciona un PDF o Word',
      'choose': 'Elegir archivo',
      's1': 'Archivo copiado al teléfono',
      's2': 'Leyendo el texto de cada página',
      's3': 'Detectando títulos y secciones',
      's4': 'Creando el índice de búsqueda',
      'leaveNote': 'Todo se procesa en tu teléfono, sin internet.',
      'goHome': 'Ir al inicio',
      'onlyDoc': 'Responde solo con el contenido de este documento',
      'doneToday': 'Usaste tus 5 preguntas de hoy',
      'pg': 'pág.',
      'askPh': 'Pregunta sobre este manual…',
      'send': 'Enviar pregunta',
      'voiceAsk': 'Preguntar por voz',
      'listening': 'Escuchando…',
      'listeningHint': 'Habla con naturalidad. Toca Enviar cuando termines.',
      'cancel': 'Cancelar',
      'sendVoice': 'Enviar',
      'listen': 'Escuchar',
      'pause': 'Pausar',
      'limitTitle': 'Usaste tus 5 preguntas de hoy',
      'limitBody': 'Mañana tendrás 5 preguntas nuevas. Si necesitas más, prueba la versión Pro.',
      'proTitle': 'MANUAL IA Pro',
      'proPitch': 'Documentos y preguntas sin límite, con historial guardado.',
      'seeProBtn': 'Conocer la versión Pro',
      'gotIt': 'Entendido',
      'pageWord': 'Página',
      'highlightNote': 'Recorte de la página original. Lo resaltado es donde está la respuesta.',
      'copy': 'Copiar',
      'proH1': 'Pásate a MANUAL IA Pro',
      'proSub': 'Para quienes consultan sus manuales todos los días.',
      'youHave': 'Tienes la versión básica: 1 documento · 5 preguntas por día.',
      'getPro': 'Ver en Google Play',
      'proNote': 'MANUAL IA Pro es una app aparte. Tu versión básica sigue funcionando.',
      'language': 'Idioma',
      'docRow': 'Documento',
      'proRow': 'Versión Pro',
      'privacy': 'Privacidad',
      'about': 'Acerca de',
      'version': 'Versión básica 1.0',
      'autoRead': 'Leer respuestas en voz alta',
      'autoReadSub': 'La app lee la respuesta en voz alta',
      'appLang': 'Idioma de la app',
      'instant': 'El cambio se aplica al instante en toda la app.',
      'langNote': 'Las respuestas son el texto original del documento, en su idioma. El idioma de la app cambia botones y mensajes.',
      'back': 'Volver',
      'close': 'Cerrar',
      'appTitle': 'MANUAL IA',
      'usedOf': '{n} de 5',
      'left': 'Te quedan {n} de 5 preguntas hoy',
      'limits': '.pdf o .docx · hasta {mb} MB',
      'docPages': '{pages} páginas',
      'processing': 'Procesando documento…',
      'uploadError': 'No se pudo leer el documento.',
      'retry': 'Reintentar',
      'micDenied': 'Para preguntar por voz, permite el uso del micrófono.',
      'sttUnavailable': 'Tu teléfono no tiene el servicio de dictado activo. Instala o actualiza la app «Google», o usa el micrófono del teclado.',
      'copied': 'Copiado',
      'pf1': 'Preguntas sin límite',
      'pf2': 'Documentos sin límite',
      'pf3': 'Historial de conversaciones guardado',
      'pf4': 'Español, inglés y portugués',
      'nameEs': 'Español',
      'nameEn': 'Inglés',
      'namePt': 'Portugués',
      'errorGeneric': 'Algo salió mal. Inténtalo de nuevo.',
      'replaceTitle': '¿Reemplazar documento?',
      'replaceBody': 'Se borrará el documento actual y su conversación. La versión básica permite 1 documento.',
      'replaceOk': 'Reemplazar',
      'thinking': 'Buscando en el manual…',
      'fileTooBig': 'El archivo supera el tamaño máximo de {mb} MB.',
      'pagesShort': '{n} pág.',
      'emptyChat': 'Escribe o dicta tu pregunta sobre el manual.',
      'pickFileError': 'Solo se permiten archivos PDF o Word (.docx).',
      'errScanned': 'Este PDF no tiene texto (parece escaneado). Usa un PDF con texto seleccionable o un archivo Word.',
      'errOldDoc': 'Los archivos .doc antiguos no se pueden leer. Guárdalo como .docx o PDF.',
      'errPassword': 'El PDF está protegido con contraseña. Quita la contraseña e inténtalo de nuevo.',
      'errDamaged': 'No se pudo abrir el archivo. Puede estar dañado.',
      'foundIn': 'Encontrado en la página {n}',
      'otherMatches': 'También aparece en',
      'notFoundTitle': 'No encontré esto en el manual.',
      'notFoundBody': 'Prueba con otras palabras, por ejemplo las que usa el documento.',
      'relatedTopics': 'Temas parecidos',
      'tapCapture': 'Toca la captura para ver la página completa.',
      'fullPage': 'Página completa',
      'captureOf': 'Captura de la página {n}',
      'docView': 'Vista del documento',
      'sampleName': 'Manual Operativo de Caja (ejemplo)',
      'micPreparing': 'Activando el micrófono…',
      'micBlocked': 'El permiso del micrófono está bloqueado. Actívalo en Ajustes de la app → Permisos → Micrófono.',
      'openSettings': 'Abrir ajustes',
      'useKeyboard': 'Usar el micrófono del teclado',
      'micBusy': 'El micrófono está ocupado por otra app. Inténtalo de nuevo.',
      'tryAgain': 'Hablar de nuevo',
    },
    'en': {
      'proBadge': 'Pro version',
      'pb1': 'Unlimited documents',
      'pb2': 'Unlimited questions, no daily limit',
      'pb3': 'Ask by voice and listen to the answers',
      'pb4': 'Saved history for each document',
      'library': 'Library',
      'searchPh': 'Search your manuals',
      'options': 'Options',
      'deleteDoc': 'Delete document',
      'deleteBody': 'The document and its question history will be deleted.',
      'deleteBtn': 'Delete',
      'proUploadNote': 'Pro version: upload as many documents as you need.',
      'historySaved': 'History saved',
      'versionPro': 'Pro version 1.0',
      'docsRow': 'Documents',
      'emptyLibTitle': 'Your library is empty',
      'emptyLibText': 'Upload your first PDF or Word manual.',
      'goLibrary': 'Go to library',
      'unlimited': 'No limits',
      'docsCount': '{n} documents · no limits',
      'questionsN': '{n} questions',
      'deleteQ': 'Delete “{doc}”?',
      'priv3pro': 'Your documents and conversations are stored only on this phone. You can delete them anytime.',
      'priv5pro': 'No ads or tracking. We don’t share or sell anything, because we don’t receive anything.',
      'appNamePro': 'MANUAL IA Pro',
      'noResults': 'No results',
      'privTitle': 'Privacy',
      'privLead': 'MANUAL IA doesn’t collect any information.',
      'aiTitle': 'No artificial intelligence',
      'aiBody': 'Answers are found with search rules in your document’s text: nothing is generated or made up. You always see the page they come from.',
      'aiNote': 'Answers taken from the manual’s text, with the source page.',
      'priv1': 'It doesn’t ask for your name, email, phone or password. There are no accounts.',
      'priv2': 'Works offline: your documents and questions never leave the phone.',
      'priv3': 'Your document is stored only on this phone. When you replace it, the previous one is deleted.',
      'priv4': 'The microphone is used only while you dictate. Dictation is done by your phone’s voice service (for example, Google), which may use the internet depending on its settings.',
      'priv5': 'No ads or tracking. The daily question counter is stored only on the phone.',
      'notHeard': 'I didn’t catch that. Tap the microphone and speak again.',
      'voiceNetwork': 'Your phone’s dictation needs internet, or download the language to use it offline (Google settings → Voice).',
      'brandSub': 'Your documents,\ninstant answers',
      'tag1': 'Your manual.',
      'tag2': 'Your knowledge.',
      'sub': 'Ask and find the answer inside your documents.',
      'guides': 'Guides',
      'basicBadge': 'Basic version · Free',
      'b1': '1 PDF or Word document',
      'b2': '5 questions per day',
      'b3': 'No sign-up. Works offline',
      'b4': 'Ask by voice and listen to the answers',
      'uploadMine': 'Upload my document',
      'useSample': 'Try with a sample manual',
      'settings': 'Settings',
      'today': 'Questions today',
      'renews': 'They reset every day at 12:00 AM.',
      'ready': 'Ready to ask',
      'ask': 'Ask',
      'voiceTitle': 'Voice',
      'replace': 'Replace document',
      'suggested': 'Topics in the manual',
      'noDocTitle': 'You haven’t uploaded your document yet',
      'noDocText': 'The basic version allows 1 PDF or Word document.',
      'upload': 'Upload document',
      'oneDocNote': 'The basic version allows 1 document. Uploading another one replaces the current one.',
      'pick': 'Select a PDF or Word file',
      'choose': 'Choose file',
      's1': 'File copied to the phone',
      's2': 'Reading the text of each page',
      's3': 'Finding titles and sections',
      's4': 'Building the search index',
      'leaveNote': 'Everything is processed on your phone, offline.',
      'goHome': 'Go to home',
      'onlyDoc': 'Answers only from this document',
      'doneToday': 'You’ve used your 5 questions for today',
      'pg': 'p.',
      'askPh': 'Ask about this manual…',
      'send': 'Send question',
      'voiceAsk': 'Ask by voice',
      'listening': 'Listening…',
      'listeningHint': 'Speak naturally. Tap Send when you’re done.',
      'cancel': 'Cancel',
      'sendVoice': 'Send',
      'listen': 'Listen',
      'pause': 'Pause',
      'limitTitle': 'You’ve used your 5 questions for today',
      'limitBody': 'You’ll have 5 new questions tomorrow. If you need more, try the Pro version.',
      'proTitle': 'MANUAL IA Pro',
      'proPitch': 'Unlimited documents and questions, with saved history.',
      'seeProBtn': 'See the Pro version',
      'gotIt': 'Got it',
      'pageWord': 'Page',
      'highlightNote': 'Clip of the original page. The highlight shows where the answer is.',
      'copy': 'Copy',
      'proH1': 'Upgrade to MANUAL IA Pro',
      'proSub': 'For people who check their manuals every day.',
      'youHave': 'You have the basic version: 1 document · 5 questions per day.',
      'getPro': 'View on Google Play',
      'proNote': 'MANUAL IA Pro is a separate app. Your basic version keeps working.',
      'language': 'Language',
      'docRow': 'Document',
      'proRow': 'Pro version',
      'privacy': 'Privacy',
      'about': 'About',
      'version': 'Basic version 1.0',
      'autoRead': 'Read answers aloud',
      'autoReadSub': 'The app reads the answer aloud',
      'appLang': 'App language',
      'instant': 'The change applies instantly across the app.',
      'langNote': 'Answers are the original text of the document, in its language. The app language changes buttons and messages.',
      'back': 'Back',
      'close': 'Close',
      'appTitle': 'MANUAL IA',
      'usedOf': '{n} of 5',
      'left': '{n} of 5 questions left today',
      'limits': '.pdf or .docx · up to {mb} MB',
      'docPages': '{pages} pages',
      'processing': 'Processing document…',
      'uploadError': 'The document couldn’t be read.',
      'retry': 'Try again',
      'micDenied': 'To ask by voice, allow microphone access.',
      'sttUnavailable': 'Your phone has no active dictation service. Install or update the “Google” app, or use the keyboard microphone.',
      'copied': 'Copied',
      'pf1': 'Unlimited questions',
      'pf2': 'Unlimited documents',
      'pf3': 'Saved conversation history',
      'pf4': 'Spanish, English and Portuguese',
      'nameEs': 'Spanish',
      'nameEn': 'English',
      'namePt': 'Portuguese',
      'errorGeneric': 'Something went wrong. Please try again.',
      'replaceTitle': 'Replace document?',
      'replaceBody': 'The current document and its conversation will be deleted. The basic version allows 1 document.',
      'replaceOk': 'Replace',
      'thinking': 'Searching the manual…',
      'fileTooBig': 'The file is larger than the {mb} MB limit.',
      'pagesShort': 'p. {n}',
      'emptyChat': 'Type or speak your question about the manual.',
      'pickFileError': 'Only PDF or Word (.docx) files are allowed.',
      'errScanned': 'This PDF has no text (it looks scanned). Use a PDF with selectable text or a Word file.',
      'errOldDoc': 'Old .doc files can’t be read. Save it as .docx or PDF.',
      'errPassword': 'The PDF is password-protected. Remove the password and try again.',
      'errDamaged': 'The file couldn’t be opened. It may be damaged.',
      'foundIn': 'Found on page {n}',
      'otherMatches': 'Also appears on',
      'notFoundTitle': 'I couldn’t find this in the manual.',
      'notFoundBody': 'Try other words, for example the ones the document uses.',
      'relatedTopics': 'Similar topics',
      'tapCapture': 'Tap the clip to see the full page.',
      'fullPage': 'Full page',
      'captureOf': 'Clip of page {n}',
      'docView': 'Document view',
      'sampleName': 'Cash Register Operations Manual (sample)',
      'micPreparing': 'Turning on the microphone…',
      'micBlocked': 'Microphone permission is blocked. Turn it on in App settings → Permissions → Microphone.',
      'openSettings': 'Open settings',
      'useKeyboard': 'Use the keyboard microphone',
      'micBusy': 'The microphone is being used by another app. Try again.',
      'tryAgain': 'Speak again',
    },
    'pt': {
      'proBadge': 'Versão Pro',
      'pb1': 'Documentos ilimitados',
      'pb2': 'Perguntas ilimitadas, sem limite diário',
      'pb3': 'Pergunte por voz e ouça as respostas',
      'pb4': 'Histórico salvo em cada documento',
      'library': 'Biblioteca',
      'searchPh': 'Buscar nos seus manuais',
      'options': 'Opções',
      'deleteDoc': 'Excluir documento',
      'deleteBody': 'O documento e seu histórico de perguntas serão excluídos.',
      'deleteBtn': 'Excluir',
      'proUploadNote': 'Versão Pro: envie todos os documentos que precisar.',
      'historySaved': 'Histórico salvo',
      'versionPro': 'Versão Pro 1.0',
      'docsRow': 'Documentos',
      'emptyLibTitle': 'Sua biblioteca está vazia',
      'emptyLibText': 'Envie seu primeiro manual em PDF ou Word.',
      'goLibrary': 'Ir para a biblioteca',
      'unlimited': 'Sem limites',
      'docsCount': '{n} documentos · sem limites',
      'questionsN': '{n} perguntas',
      'deleteQ': 'Excluir “{doc}”?',
      'priv3pro': 'Seus documentos e conversas ficam salvos só neste celular. Você pode excluí-los quando quiser.',
      'priv5pro': 'Sem publicidade nem rastreamento. Não compartilhamos nem vendemos nada, porque não recebemos nada.',
      'appNamePro': 'MANUAL IA Pro',
      'noResults': 'Sem resultados',
      'privTitle': 'Privacidade',
      'privLead': 'O MANUAL IA não coleta nenhuma informação.',
      'aiTitle': 'Sem inteligência artificial',
      'aiBody': 'As respostas são buscadas com regras no texto do seu documento: nada é gerado nem inventado. Você sempre vê a página de onde vêm.',
      'aiNote': 'Respostas tiradas do texto do manual, com a página de origem.',
      'priv1': 'Não pede nome, e-mail, telefone nem senha. Não há contas.',
      'priv2': 'Funciona sem internet: seus documentos e perguntas nunca saem do celular.',
      'priv3': 'Seu documento fica salvo só neste celular. Ao substituí-lo, o anterior é apagado.',
      'priv4': 'O microfone é usado só enquanto você dita. O ditado é feito pelo serviço de voz do celular (por exemplo, Google), que pode usar a internet conforme a configuração dele.',
      'priv5': 'Sem publicidade nem rastreamento. O contador de perguntas diárias fica salvo só no celular.',
      'notHeard': 'Não entendi bem. Toque no microfone e fale de novo.',
      'voiceNetwork': 'O ditado do celular precisa de internet, ou baixe o idioma para usar sem conexão (Configurações do Google → Voz).',
      'brandSub': 'Seus documentos,\nrespostas na hora',
      'tag1': 'Seu manual.',
      'tag2': 'Seu conhecimento.',
      'sub': 'Pergunte e encontre a resposta dentro dos seus documentos.',
      'guides': 'Guias',
      'basicBadge': 'Versão básica · Grátis',
      'b1': '1 documento PDF ou Word',
      'b2': '5 perguntas por dia',
      'b3': 'Sem cadastro. Funciona sem internet',
      'b4': 'Pergunte por voz e ouça as respostas',
      'uploadMine': 'Enviar meu documento',
      'useSample': 'Testar com um manual de exemplo',
      'settings': 'Ajustes',
      'today': 'Perguntas de hoje',
      'renews': 'Renovam todos os dias às 00:00.',
      'ready': 'Pronto para perguntar',
      'ask': 'Perguntar',
      'voiceTitle': 'Voz',
      'replace': 'Substituir documento',
      'suggested': 'Temas do manual',
      'noDocTitle': 'Você ainda não enviou seu documento',
      'noDocText': 'A versão básica permite 1 documento PDF ou Word.',
      'upload': 'Enviar documento',
      'oneDocNote': 'A versão básica permite 1 documento. Se você enviar outro, ele substitui o atual.',
      'pick': 'Selecione um PDF ou Word',
      'choose': 'Escolher arquivo',
      's1': 'Arquivo copiado para o celular',
      's2': 'Lendo o texto de cada página',
      's3': 'Detectando títulos e seções',
      's4': 'Criando o índice de busca',
      'leaveNote': 'Tudo é processado no seu celular, sem internet.',
      'goHome': 'Ir para o início',
      'onlyDoc': 'Responde apenas com o conteúdo deste documento',
      'doneToday': 'Você usou suas 5 perguntas de hoje',
      'pg': 'pág.',
      'askPh': 'Pergunte sobre este manual…',
      'send': 'Enviar pergunta',
      'voiceAsk': 'Perguntar por voz',
      'listening': 'Ouvindo…',
      'listeningHint': 'Fale naturalmente. Toque em Enviar quando terminar.',
      'cancel': 'Cancelar',
      'sendVoice': 'Enviar',
      'listen': 'Ouvir',
      'pause': 'Pausar',
      'limitTitle': 'Você usou suas 5 perguntas de hoje',
      'limitBody': 'Amanhã você terá 5 perguntas novas. Se precisar de mais, experimente a versão Pro.',
      'proTitle': 'MANUAL IA Pro',
      'proPitch': 'Documentos e perguntas sem limite, com histórico salvo.',
      'seeProBtn': 'Conhecer a versão Pro',
      'gotIt': 'Entendi',
      'pageWord': 'Página',
      'highlightNote': 'Recorte da página original. O destaque mostra onde está a resposta.',
      'copy': 'Copiar',
      'proH1': 'Passe para o MANUAL IA Pro',
      'proSub': 'Para quem consulta seus manuais todos os dias.',
      'youHave': 'Você tem a versão básica: 1 documento · 5 perguntas por dia.',
      'getPro': 'Ver no Google Play',
      'proNote': 'O MANUAL IA Pro é um app separado. Sua versão básica continua funcionando.',
      'language': 'Idioma',
      'docRow': 'Documento',
      'proRow': 'Versão Pro',
      'privacy': 'Privacidade',
      'about': 'Sobre',
      'version': 'Versão básica 1.0',
      'autoRead': 'Ler respostas em voz alta',
      'autoReadSub': 'O app lê a resposta em voz alta',
      'appLang': 'Idioma do app',
      'instant': 'A mudança se aplica na hora em todo o app.',
      'langNote': 'As respostas são o texto original do documento, no idioma dele. O idioma do app muda botões e mensagens.',
      'back': 'Voltar',
      'close': 'Fechar',
      'appTitle': 'MANUAL IA',
      'usedOf': '{n} de 5',
      'left': 'Restam {n} de 5 perguntas hoje',
      'limits': '.pdf ou .docx · até {mb} MB',
      'docPages': '{pages} páginas',
      'processing': 'Processando documento…',
      'uploadError': 'Não foi possível ler o documento.',
      'retry': 'Tentar novamente',
      'micDenied': 'Para perguntar por voz, permita o uso do microfone.',
      'sttUnavailable': 'Seu celular não tem o serviço de ditado ativo. Instale ou atualize o app “Google”, ou use o microfone do teclado.',
      'copied': 'Copiado',
      'pf1': 'Perguntas sem limite',
      'pf2': 'Documentos sem limite',
      'pf3': 'Histórico de conversas salvo',
      'pf4': 'Espanhol, inglês e português',
      'nameEs': 'Espanhol',
      'nameEn': 'Inglês',
      'namePt': 'Português',
      'errorGeneric': 'Algo deu errado. Tente novamente.',
      'replaceTitle': 'Substituir documento?',
      'replaceBody': 'O documento atual e a conversa serão apagados. A versão básica permite 1 documento.',
      'replaceOk': 'Substituir',
      'thinking': 'Buscando no manual…',
      'fileTooBig': 'O arquivo ultrapassa o limite de {mb} MB.',
      'pagesShort': 'pág. {n}',
      'emptyChat': 'Digite ou fale sua pergunta sobre o manual.',
      'pickFileError': 'Somente arquivos PDF ou Word (.docx).',
      'errScanned': 'Este PDF não tem texto (parece digitalizado). Use um PDF com texto selecionável ou um arquivo Word.',
      'errOldDoc': 'Arquivos .doc antigos não podem ser lidos. Salve como .docx ou PDF.',
      'errPassword': 'O PDF está protegido por senha. Remova a senha e tente novamente.',
      'errDamaged': 'Não foi possível abrir o arquivo. Ele pode estar danificado.',
      'foundIn': 'Encontrado na página {n}',
      'otherMatches': 'Também aparece em',
      'notFoundTitle': 'Não encontrei isso no manual.',
      'notFoundBody': 'Tente outras palavras, por exemplo as que o documento usa.',
      'relatedTopics': 'Temas parecidos',
      'tapCapture': 'Toque no recorte para ver a página inteira.',
      'fullPage': 'Página inteira',
      'captureOf': 'Recorte da página {n}',
      'docView': 'Visualização do documento',
      'sampleName': 'Manual Operacional de Caixa (exemplo)',
      'micPreparing': 'Ativando o microfone…',
      'micBlocked': 'A permissão do microfone está bloqueada. Ative em Configurações do app → Permissões → Microfone.',
      'openSettings': 'Abrir configurações',
      'useKeyboard': 'Usar o microfone do teclado',
      'micBusy': 'O microfone está sendo usado por outro app. Tente novamente.',
      'tryAgain': 'Falar de novo',
    },
  };
}
