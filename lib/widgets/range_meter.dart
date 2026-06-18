import 'package:flutter/material.dart';
import '../theme/clinic_palette.dart';
import '../theme/clinic_type.dart';

class RangeMeter extends StatelessWidget {
  final String title;
  final double value;
  final double maxValue;
  final Color tone;
  final String trailing;

  const RangeMeter({
    super.key,
    required this.title,
    required this.value,
    required this.maxValue,
    required this.tone,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final frac = maxValue <= 0 ? 0.0 : (value / maxValue).clamp(0, 1).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: ClinicType.label(color: ClinicPalette.inkSoft)),
            Text(trailing, style: ClinicType.heading(color: tone)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: frac,
            minHeight: 8,
            backgroundColor: ClinicPalette.surfaceDim,
            color: tone,
          ),
        ),
      ],
    );
  }
}
