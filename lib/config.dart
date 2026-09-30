/// Configuración de MANUAL IA.
///
/// La app funciona 100 % en el teléfono: lee el PDF o Word, crea un índice
/// y responde buscando en el texto con reglas fijas (sin IA y sin internet).
class AppConfig {
  /// Edición de la app.
  ///   false = MANUAL IA (versión básica): 1 documento y 5 preguntas por día.
  ///   true  = MANUAL IA Pro: documentos y preguntas sin límite, historial por documento.
  static const bool isPro = true;

  static const String appName = isPro ? 'MANUAL IA Pro' : 'MANUAL IA';

  /// Límites de la versión básica (en Pro no se aplican).
  static const int dailyQuestionLimit = 5;
  static const int maxDocuments = 1;
  static const int maxFileSizeMb = 20; // [TAMAÑO MÁX.] definir

  /// Enlace a la ficha de MANUAL IA Pro en Google Play.
  static const String proStoreUrl =
      'https://play.google.com/store/apps/details?id=com.manualia.manual_ia_pro';

  /// Enlace a la política de privacidad (obligatoria en Google Play).
  static const String privacyUrl = 'https://TU-SITIO.com/privacidad';

  static const String appVersion = '1.1.0';
}
