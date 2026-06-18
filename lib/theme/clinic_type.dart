import 'package:flutter/material.dart';
import 'clinic_palette.dart';

class ClinicType {
  static const String family = 'Nunito';

  static TextStyle _t(
    double wght,
    double size, {
    double? height,
    double? spacing,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: family,
      fontVariations: [FontVariation('wght', wght)],
      fontWeight: wght >= 700
          ? FontWeight.w700
          : (wght >= 600 ? FontWeight.w600 : FontWeight.w400),
      fontSize: size,
      height: height,
      letterSpacing: spacing,
      color: color ?? ClinicPalette.ink,
    );
  }

  static TextStyle display({Color? color}) =>
      _t(800, 28, height: 1.12, spacing: -0.3, color: color);
  static TextStyle title({Color? color}) =>
      _t(700, 21, height: 1.18, spacing: -0.1, color: color);
  static TextStyle heading({Color? color}) =>
      _t(700, 16, height: 1.22, color: color);
  static TextStyle body({Color? color}) =>
      _t(400, 14.5, height: 1.45, color: color ?? ClinicPalette.inkSoft);
  static TextStyle bodyStrong({Color? color}) =>
      _t(600, 14.5, height: 1.4, color: color);
  static TextStyle label({Color? color}) =>
      _t(700, 12.5, spacing: 0.4, color: color);
  static TextStyle caption({Color? color}) =>
      _t(600, 11.5, spacing: 0.3, color: color ?? ClinicPalette.inkFaint);
  static TextStyle numeral(double size, {Color? color}) =>
      _t(800, size, height: 1.0, spacing: -0.8, color: color);
  static TextStyle mono(double size, {Color? color}) =>
      _t(700, size, height: 1.0, spacing: 0.5, color: color);
}
