import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'domain/flock_repository.dart';
import 'runtime/alert_relay.dart';
import 'runtime/attribution_beacon.dart';
import 'runtime/clinic_link.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  try {
    await ClinicLink.boot();
  } catch (_) {}

  await AlertRelay.boot();
  AttributionBeacon.boot();

  final repo = FlockRepository();
  await repo.load();

  await _markFirstOpen();

  runApp(FlockCareApp(repo: repo));
}

Future<void> _markFirstOpen() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    const key = 'triage.firstOpenSent';
    if (!(prefs.getBool(key) ?? false)) {
      AttributionBeacon.firstOpen();
      await prefs.setBool(key, true);
    }
  } catch (_) {}
}
