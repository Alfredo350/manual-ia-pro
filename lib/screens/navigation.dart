import 'package:flutter/material.dart';

import '../config.dart';
import 'home_screen.dart';
import 'library_screen.dart';

/// Pantalla principal según la edición: Inicio (básica) o Biblioteca (Pro).
Widget mainScreen() => AppConfig.isPro ? const LibraryScreen() : const HomeScreen();

/// Vuelve a la pantalla principal y limpia la pila de navegación.
void goToMain(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => mainScreen()),
    (_) => false,
  );
}
