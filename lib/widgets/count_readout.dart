import 'package:flutter/material.dart';
import '../theme/clinic_palette.dart';
import '../theme/clinic_type.dart';

class CountReadout extends StatelessWidget {
  final String value;
  final String caption;
  final String? unit;
  final Color? color;

  const CountReadout({
    super.key,
    required this.value,
    required this.caption,
    this.unit,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value,
                style: ClinicType.numeral(40,
                    color: color ?? ClinicPalette.ink)),
            if (unit != null) ...[
              const SizedBox(width: 3),
              Text(unit!,
                  style: ClinicType.label(color: ClinicPalette.inkFaint)),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(caption,
            style: ClinicType.caption(color: ClinicPalette.inkSoft)),
      ],
    );
  }
}
