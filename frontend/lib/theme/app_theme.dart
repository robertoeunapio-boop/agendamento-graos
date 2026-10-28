import 'package:flutter/material.dart';

class Cores {
  static const verdeProfundo = Color(0xFF1F4D2B);
  static const verdeFolha = Color(0xFF3E8E41);
  static const verdeClaro = Color(0xFFE6F0E3);
  static const dourado = Color(0xFFE0A526);
  static const douradoEscuro = Color(0xFF8A6410);
  static const creme = Color(0xFFFBF7EC);
  static const terra = Color(0xFF6B4A2B);
  static const perigo = Color(0xFFB3261E);
}

ThemeData temaDoApp() {
  final esquema = ColorScheme.fromSeed(seedColor: Cores.verdeFolha).copyWith(
    primary: Cores.verdeProfundo,
    onPrimary: Cores.creme,
    secondary: Cores.dourado,
    onSecondary: Cores.verdeProfundo,
    surface: Cores.creme,
    onSurface: Cores.verdeProfundo,
  );

  final formaDosBotoes = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: Cores.creme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Cores.verdeProfundo,
      foregroundColor: Cores.creme,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Cores.creme,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Cores.dourado,
      foregroundColor: Cores.verdeProfundo,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Cores.dourado,
        foregroundColor: Cores.verdeProfundo,
        minimumSize: const Size(64, 56),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        shape: formaDosBotoes,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Cores.verdeProfundo,
        minimumSize: const Size(64, 56),
        side: const BorderSide(color: Cores.verdeProfundo, width: 1.5),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        shape: formaDosBotoes,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Cores.verdeFolha, width: 2),
      ),
    ),
  );
}