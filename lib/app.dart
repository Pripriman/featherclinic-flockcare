import 'package:flutter/material.dart';

import 'domain/flock_repository.dart';
import 'screens/boot_gate_screen.dart';
import 'state/clinic_scope.dart';
import 'theme/clinic_theme.dart';

class FlockCareApp extends StatelessWidget {
  final FlockRepository repo;
  const FlockCareApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return ClinicScope(
      repo: repo,
      child: MaterialApp(
        title: 'Poultry Health Guard',
        debugShowCheckedModeBanner: false,
        theme: ClinicTheme.build(),
        home: const BootGateScreen(),
      ),
    );
  }
}
