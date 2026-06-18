import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/clinic_palette.dart';

class VitalRing extends StatelessWidget {
  final double size;
  final double progress;
  final Color color;
  final Color track;
  final double stroke;
  final Widget? child;

  const VitalRing({
    super.key,
    required this.size,
    required this.progress,
    this.color = ClinicPalette.teal,
    this.track = ClinicPalette.surfaceDim,
    this.stroke = 10,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _VitalRingPainter(
          progress: progress.clamp(0, 1).toDouble(),
          color: color,
          track: track,
          stroke: stroke,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _VitalRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color track;
  final double stroke;

  _VitalRingPainter({
    required this.progress,
    required this.color,
    required this.track,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - stroke) / 2;
    const start = -math.pi / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final sweep = progress * 2 * math.pi;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + 2 * math.pi,
        colors: [color, ClinicPalette.teal, color],
        transform: GradientRotation(start),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _VitalRingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.track != track ||
      old.stroke != stroke;
}
