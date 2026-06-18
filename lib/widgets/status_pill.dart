import 'package:flutter/material.dart';
import '../theme/clinic_palette.dart';
import '../theme/clinic_type.dart';

enum SeverityTier { healthy, watch, critical }

extension SeverityTierMeta on SeverityTier {
  String get label {
    switch (this) {
      case SeverityTier.healthy:
        return 'Healthy';
      case SeverityTier.watch:
        return 'Watch';
      case SeverityTier.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case SeverityTier.healthy:
        return ClinicPalette.healthy;
      case SeverityTier.watch:
        return ClinicPalette.watch;
      case SeverityTier.critical:
        return ClinicPalette.critical;
    }
  }

  IconData get icon {
    switch (this) {
      case SeverityTier.healthy:
        return Icons.check_circle_rounded;
      case SeverityTier.watch:
        return Icons.visibility_rounded;
      case SeverityTier.critical:
        return Icons.warning_rounded;
    }
  }
}

class StatusPill extends StatelessWidget {
  final SeverityTier tier;
  final String? text;
  final bool dense;

  const StatusPill({
    super.key,
    required this.tier,
    this.text,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = tier.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 9 : 11,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tier.icon, size: dense ? 12 : 14, color: color),
          const SizedBox(width: 5),
          Text(text ?? tier.label,
              style: ClinicType.label(color: color)),
        ],
      ),
    );
  }
}
