import 'package:flutter/material.dart';
import 'clinic_palette.dart';
import 'clinic_type.dart';

class ClinicTheme {
  static ThemeData build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: ClinicPalette.teal,
      primary: ClinicPalette.tealDeep,
      secondary: ClinicPalette.crimson,
      surface: ClinicPalette.card,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ClinicPalette.surface,
      fontFamily: ClinicType.family,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: ClinicPalette.card,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: ClinicPalette.ink,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: ClinicPalette.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ClinicPalette.hairline,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ClinicPalette.surfaceDim,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: ClinicType.body(color: ClinicPalette.inkFaint),
        border: _inputBorder(ClinicPalette.hairline),
        enabledBorder: _inputBorder(ClinicPalette.hairline),
        focusedBorder: _inputBorder(ClinicPalette.teal),
        errorBorder: _inputBorder(ClinicPalette.crimson),
        focusedErrorBorder: _inputBorder(ClinicPalette.crimson),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ClinicPalette.ink,
        contentTextStyle: ClinicType.bodyStrong(color: Colors.white),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: 1.3),
      );
}
