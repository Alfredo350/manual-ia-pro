#!/usr/bin/env bash
# Prepara el proyecto MANUAL IA en macOS o Linux.  Uso: bash preparar.sh
set -e
flutter create --org com.manualia --project-name manual_ia_pro --platforms android .
cp -f android_config/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
flutter pub get
dart run flutter_launcher_icons
echo "Listo. Ejecuta: flutter run   |   APK: flutter build apk --release"
