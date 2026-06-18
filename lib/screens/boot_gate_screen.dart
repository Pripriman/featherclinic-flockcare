import 'package:flutter/material.dart';

import '../runtime/attribution_beacon.dart';
import '../runtime/triage_gate.dart';
import '../theme/clinic_palette.dart';
import '../theme/clinic_type.dart';
import 'bad_connection_screen.dart';
import 'content/triage_board_view.dart';
import 'native_root.dart';

class BootGateScreen extends StatefulWidget {
  const BootGateScreen({super.key});

  @override
  State<BootGateScreen> createState() => _BootGateScreenState();
}

class _BootGateScreenState extends State<BootGateScreen>
    with SingleTickerProviderStateMixin {
  late Future<GateResult> _future;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    _future = TriageGate.resolve();
  }

  void _retry() {
    setState(() {
      _future = TriageGate.resolve();
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GateResult>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _splash();
        }
        final result = snap.data ?? const GateResult(GateOutcome.native);
        switch (result.outcome) {
          case GateOutcome.badConnection:
            return BadConnectionScreen(onRetry: _retry);
          case GateOutcome.content:
            AttributionBeacon.contentOpen();
            return TriageBoardView(endpoint: result.endpoint!);
          case GateOutcome.native:
            return const NativeRoot();
        }
      },
    );
  }

  Widget _splash() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ClinicPalette.clinicalWash),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: Tween(begin: 0.92, end: 1.06).animate(
                  CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                ),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: ClinicPalette.tealWash,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: ClinicPalette.teal.withValues(alpha: 0.5)),
                  ),
                  child: const Icon(Icons.health_and_safety_rounded,
                      size: 46, color: ClinicPalette.tealDeep),
                ),
              ),
              const SizedBox(height: 22),
              Text('Preparing the health desk…',
                  style: ClinicType.heading(color: ClinicPalette.tealDeep)),
            ],
          ),
        ),
      ),
    );
  }
}
