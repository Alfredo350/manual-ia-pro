import 'package:flutter/material.dart';

/// Colores del diseño de MANUAL IA.
class AppColors {
  static const bg = Color(0xFFF3F7FF);
  static const bgTop = Color(0xFFF8FBFF);
  static const bgBottom = Color(0xFFEDF3FF);
  static const primary = Color(0xFF0B4FD6);
  static const primaryDark = Color(0xFF083BA3);
  static const primaryLight = Color(0xFF1A64F0);
  static const navy = Color(0xFF0B1B3F);
  static const navyBlue = Color(0xFF0B2A7A);
  static const ink = Color(0xFF0B1B3F);
  static const muted = Color(0xFF56627E);
  static const body = Color(0xFF2E3A57);
  static const line = Color(0xFFDCE6F6);
  static const lineStrong = Color(0xFFC9D6EE);
  static const soft = Color(0xFFE4EDFF);
  static const soft2 = Color(0xFFEAF1FD);
  static const softest = Color(0xFFF7FAFF);
  static const barLight = Color(0xFF7FB0FF);
  static const amber = Color(0xFFFFB020);
  static const amberBg = Color(0xFFFFF1CF);
  static const amberText = Color(0xFF6B4500);
  static const warnBg = Color(0xFFFBEBC8);
  static const warnBorder = Color(0xFFEBD39C);
  static const warnText = Color(0xFF3F2A00);
  static const processing = Color(0xFF8A5A00);
  static const processingBg = Color(0xFFF1E6CC);
  static const pdfBg = Color(0xFFF8DEDA);
  static const pdfText = Color(0xFF8E2318);
  static const docBg = Color(0xFFDCE6F5);
  static const docText = Color(0xFF1F4A8A);
  static const danger = Color(0xFFA3261B);
  static const recording = Color(0xFFE0433A);
  static const teal = Color(0xFF0B8F86);
}

const kPrimaryGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.primaryLight, Color(0xFF0A45C8)],
);

const kCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.navyBlue, AppColors.primary],
);

const kPrimaryShadow = [
  BoxShadow(color: Color(0x400B4FD6), blurRadius: 18, offset: Offset(0, 8)),
];

const kCardShadow = [
  BoxShadow(color: Color(0x0F0B1B3F), blurRadius: 14, offset: Offset(0, 4)),
];

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'PlusJakartaSans',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.ink,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: AppColors.lineStrong),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: AppColors.lineStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
