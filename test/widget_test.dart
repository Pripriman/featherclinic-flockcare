import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flockcare/domain/condition_library.dart';
import 'package:flockcare/domain/flock_repository.dart';
import 'package:flockcare/widgets/vital_ring.dart';

void main() {
  testWidgets('VitalRing renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: VitalRing(size: 80, progress: 0.5)),
        ),
      ),
    );
    expect(find.byType(VitalRing), findsOneWidget);
  });

  test('condition library covers core diseases', () {
    expect(ConditionLibrary.byId('mareks').lifeThreatening, true);
    expect(ConditionLibrary.byId('coccidiosis').system, BodySystem.digestive);
    expect(ConditionLibrary.conditions.length, greaterThanOrEqualTo(9));
  });

  test('triage ranking surfaces a matching condition', () {
    final hits = FlockRepository.rankConditions({'bloodyDropping', 'lethargy'});
    expect(hits, isNotEmpty);
    expect(hits.first.condition.id, 'coccidiosis');
  });
}
