import 'package:flutter/material.dart';
import '../theme/clinic_palette.dart';
import '../theme/clinic_type.dart';
import '../widgets/action_button.dart';

class BadConnectionScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const BadConnectionScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ClinicPalette.clinicalWash),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: ClinicPalette.amberWash,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.cloud_off_rounded,
                      size: 38, color: ClinicPalette.amber),
                ),
                const SizedBox(height: 24),
                Text('Connection unavailable',
                    style: ClinicType.title(), textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Text(
                  'We could not reach the health service. Check your network and try again.',
                  style: ClinicType.body(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ActionButton(
                  label: 'Retry',
                  icon: Icons.refresh_rounded,
                  expand: false,
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
