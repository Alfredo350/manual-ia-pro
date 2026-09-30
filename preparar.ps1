# Prepara el proyecto MANUAL IA en Windows (PowerShell).
# Uso: abre PowerShell en esta carpeta y ejecuta:  .\preparar.ps1
$ErrorActionPreference = "Stop"
Write-Host "1/4 Creando la carpeta android..." -ForegroundColor Cyan
flutter create --org com.manualia --project-name manual_ia_pro --platforms android .
Write-Host "2/4 Copiando permisos de Android (micrófono)..." -ForegroundColor Cyan
Copy-Item -Force android_config\AndroidManifest.xml android\app\src\main\AndroidManifest.xml
Write-Host "3/4 Descargando paquetes..." -ForegroundColor Cyan
flutter pub get
Write-Host "4/4 Creando el ícono de la app..." -ForegroundColor Cyan
dart run flutter_launcher_icons
Write-Host "Listo. Conecta tu teléfono y ejecuta:  flutter run" -ForegroundColor Green
Write-Host "Para generar el APK:  flutter build apk --release" -ForegroundColor Green
