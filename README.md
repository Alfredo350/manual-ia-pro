# MANUAL IA Pro (Flutter · Android)

App para consultar un manual **PDF o Word** escribiendo o hablando.
**No usa inteligencia artificial ni internet**: la app lee el documento en el teléfono,
crea un índice y responde buscando en el texto con reglas fijas. Cada respuesta muestra
**la captura de la página** donde está, con el texto resaltado.

Este mismo código genera las **dos apps**:

| | MANUAL IA (básica) | MANUAL IA Pro |
|---|---|---|
| Documentos | 1 (subir otro lo reemplaza) | Ilimitados, en una biblioteca |
| Preguntas | 5 por día | Ilimitadas |
| Historial | Se borra al cerrar | Guardado por documento |
| Aviso «Conoce Pro» | Sí, al llegar a 5 | No |
| Paquete Android | `com.manualia.manual_ia` | `com.manualia.manual_ia_pro` |

La diferencia está en `lib/config.dart` → `isPro`. Cada carpeta que te entrego ya viene configurada.

---

## Cómo responde (sin IA)

1. **Lectura:** el PDF se lee con PDFium (paquete `pdfrx`), que da el texto y la posición de cada letra.
   El Word (.docx) se lee directamente de su XML: párrafos, títulos (por estilo) y saltos de página.
2. **Secciones:** las líneas numeradas («4.2 Cierre de caja») o en MAYÚSCULAS se toman como títulos.
   Los encabezados y pies de página repetidos se ignoran.
3. **Índice:** cada sección se divide en pasajes. Las palabras se normalizan (sin tildes, sin
   plurales, raíz de 5 letras) y se quitan las palabras vacías en español, inglés y portugués.
4. **Búsqueda:** se puntúa cada pasaje con BM25, con más peso si la palabra está en el título.
   Si la pregunta no cubre al menos el 45 % de sus palabras importantes, la app dice
   «No encontré esto en el manual» y sugiere temas parecidos. **Nunca inventa una respuesta.**
5. **Captura:** se dibuja solo la zona de la página donde está el pasaje y se resaltan esas líneas.
   Al tocarla se abre la página completa, que se puede ampliar con dos dedos.
   En Word se muestra una vista del documento con el párrafo resaltado.

El código está en `lib/engine/`. El prototipo de diseño usa la misma lógica (`engine.js`).

## 1. Requisitos

1. **Flutter** 3.35 o superior: https://docs.flutter.dev/get-started/install
2. **Android Studio**, con el Android SDK instalado.
3. Ejecuta `flutter doctor` y resuelve lo que aparezca en rojo.

## 2. Preparar el proyecto (solo la primera vez)

En Windows, abre PowerShell dentro de esta carpeta y ejecuta:

```powershell
.\preparar.ps1
```

Si PowerShell bloquea el script, ejecuta antes:
`Set-ExecutionPolicy -Scope Process Bypass`

En macOS o Linux: `bash preparar.sh`

El script:
1. Crea la carpeta `android/` con `flutter create`. Tus archivos de `lib/` no se tocan.
2. Copia `android_config/AndroidManifest.xml` (permiso de micrófono).
3. Descarga los paquetes con `flutter pub get`.
4. Crea el ícono de la app.

**Si ya habías preparado el proyecto antes**, vuelve a ejecutar el script.

> La primera compilación descarga el motor PDFium (lo hace `pdfrx` automáticamente).
> Necesita internet **solo al compilar**; la app instalada no usa internet.

## 3. Probar y generar el APK

```bash
flutter test                  # pruebas del buscador con el manual de ejemplo
flutter run                   # en el teléfono conectado por USB
flutter build apk --release   # APK en build/app/outputs/flutter-apk/app-release.apk
```

Para Google Play se sube un App Bundle firmado: `flutter build appbundle --release`.
Guía de firma: https://docs.flutter.dev/deployment/android#signing-the-app

## 4. Configuración (`lib/config.dart`)

| Valor | Para qué sirve |
|---|---|
| `isPro` | `false` básica, `true` Pro. |
| `dailyQuestionLimit` | Preguntas por día en la básica (5). |
| `maxFileSizeMb` | Tamaño máximo del documento. |
| `proStoreUrl` | Enlace a MANUAL IA Pro en Google Play. |
| `privacyUrl` | Tu política de privacidad publicada en la web (Google Play la pide). |

Los textos están en `lib/l10n/l10n.dart` (ES / EN / PT).

## 5. Estructura

```
lib/
  main.dart                  Arranque, tema, idioma e inicio de PDFium
  config.dart                Configuración
  engine/
    text_utils.dart          Normalizar, palabras vacías, raíces, títulos, idioma
    search_engine.dart       Páginas, pasajes, índice BM25 y búsqueda
    extractors.dart          Lectura de PDF (pdfrx) y Word (.docx)
  services/
    library_service.dart     Guarda documentos, índice, historial y contador diario
    voice_service.dart       Permiso de micrófono, dictado y lectura en voz alta
  state/app_state.dart       Estado de la app
  widgets/source_capture.dart  Captura de la página y visor de página completa
  screens/                   Bienvenida, Inicio / Biblioteca, Subir, Chat, Pro, Ajustes, Idioma, Privacidad
assets/samples/              Manual de ejemplo en PDF (ES / EN / PT)
test/                        Pruebas del buscador
```

## 6. Micrófono

La app ahora:
- **Pide el permiso de micrófono de forma explícita** antes de dictar. Si el usuario lo bloqueó,
  muestra el botón **Abrir ajustes**.
- Abre el panel de voz **al instante** («Activando el micrófono…») y avisa qué pasó si falla.
- Busca el servicio de dictado aunque el teléfono no lo declare bien (`androidIntentLookup`).
- No pide el permiso de Bluetooth, que en Android 12+ podía impedir que el micrófono arrancara.
- Si el idioma no está instalado en el dictado, reintenta con el idioma del teléfono.
- Si el teléfono no tiene servicio de dictado, ofrece **usar el micrófono del teclado**.

Si aún no funciona:
1. *Ajustes → Apps → MANUAL IA → Permisos → Micrófono → Permitir*.
2. Instala o actualiza la app **Google** (el dictado de Android depende de ella).
3. Para dictar sin internet: *App Google → Ajustes → Voz → Reconocimiento sin conexión* y descarga el idioma.
4. En el emulador, activa el micrófono en *Extended controls → Microphone*, o prueba en un teléfono real.

## 7. Limitaciones

- **PDF escaneados** (imágenes sin texto): no se pueden leer. La app lo avisa. Leerlos requeriría OCR.
- **.doc antiguo:** no se lee; hay que guardarlo como .docx o PDF.
- **Word:** los números de página salen de los saltos de página que guarda Word. Si el archivo no los tiene,
  la app arma páginas aproximadas.
- La búsqueda encuentra **dónde** está la respuesta y muestra ese texto tal cual; no resume ni reformula.
- El contador de 5 preguntas se guarda en el teléfono. Borrar los datos de la app lo reinicia.

## 8. Privacidad (para el formulario de Google Play)

- La app **no recopila ni envía datos**: no tiene permiso de internet en la versión de producción.
- Documentos, índice, historial y contador quedan solo en el almacenamiento privado de la app.
- El dictado lo hace el servicio de voz del teléfono (por ejemplo, Google), que puede usar internet
  según su configuración. La pantalla Privacidad lo explica.
- El nombre «MANUAL IA» contiene «IA»; si quieres evitar confusiones, puedes cambiar `appName`
  en `lib/config.dart` y `android:label` en `android_config/AndroidManifest.xml`.
