import 'package:flutter/material.dart';

class ClinicPalette {
  static const Color surface = Color(0xFFF6F8FA);
  static const Color surfaceDim = Color(0xFFEDF1F4);
  static const Color hairline = Color(0xFFDCE3E8);
  static const Color card = Color(0xFFFFFFFF);

  static const Color ink = Color(0xFF1C2A33);
  static const Color inkSoft = Color(0xFF5A6B76);
  static const Color inkFaint = Color(0xFF93A4AE);

  static const Color teal = Color(0xFF1F9D94);
  static const Color tealDeep = Color(0xFF0F7A72);
  static const Color tealWash = Color(0xFFE0F2F0);

  static const Color crimson = Color(0xFFD64550);
  static const Color crimsonDeep = Color(0xFFB22E39);
  static const Color crimsonWash = Color(0xFFFBE5E7);

  static const Color amber = Color(0xFFE39A2A);
  static const Color amberWash = Color(0xFFFBF0D9);

  static const Color healthy = Color(0xFF2E9E6B);
  static const Color watch = Color(0xFFE39A2A);
  static const Color critical = Color(0xFFD64550);

  static const LinearGradient clinicalWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFEFF4F6)],
  );
}
