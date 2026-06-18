import 'package:flutter/material.dart';

import '../../domain/condition_library.dart';
import '../../theme/clinic_palette.dart';
import '../../theme/clinic_type.dart';
import '../../widgets/clinic_card.dart';
import '../../widgets/status_pill.dart';

class ConditionDetailView extends StatelessWidget {
  final ConditionProfile condition;
  const ConditionDetailView({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    final symptoms = condition.symptomWeights.keys
        .map(ConditionLibrary.symptomById)
        .toList();

    return Scaffold(
      backgroundColor: ClinicPalette.surface,
      appBar: AppBar(
        title: Text(condition.name, style: ClinicType.title()),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          ClinicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ClinicPalette.surfaceDim,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child:
                          Text(condition.emoji, style: const TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(condition.name, style: ClinicType.heading()),
                          const SizedBox(height: 6),
                          StatusPill(tier: condition.severity),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(condition.summary, style: ClinicType.body()),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _fact(Icons.coronavirus_rounded, condition.contagion.label,
                        condition.contagion.tier.color),
                    _fact(Icons.cake_rounded, 'Risk: ${condition.ageGroup.label}',
                        ClinicPalette.inkSoft),
                    _fact(condition.system.icon, condition.system.label,
                        ClinicPalette.tealDeep),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section('Symptoms to look for'),
          const SizedBox(height: 10),
          ClinicCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < symptoms.length; i++)
                  Container(
                    decoration: BoxDecoration(
                      border: i == symptoms.length - 1
                          ? null
                          : const Border(
                              bottom: BorderSide(color: ClinicPalette.hairline)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_right_rounded,
                            color: ClinicPalette.teal),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(symptoms[i].label,
                              style: ClinicType.bodyStrong(
                                  color: ClinicPalette.ink)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section('How to tell it apart'),
          const SizedBox(height: 10),
          ClinicCard(
            color: ClinicPalette.tealWash,
            border: Border.all(color: ClinicPalette.teal.withValues(alpha: 0.4)),
            child: Row(
              children: [
                const Icon(Icons.compare_arrows_rounded,
                    color: ClinicPalette.tealDeep),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(condition.differential,
                      style: ClinicType.bodyStrong(color: ClinicPalette.ink)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section('Treatment options'),
          const SizedBox(height: 10),
          ...condition.treatment.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ClinicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.healing_rounded,
                              size: 18, color: ClinicPalette.tealDeep),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(t.title, style: ClinicType.heading())),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(t.detail, style: ClinicType.body()),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 6),
          _section('Prevention'),
          const SizedBox(height: 10),
          ClinicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: condition.prevention
                  .map((p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline_rounded,
                                size: 18, color: ClinicPalette.healthy),
                            const SizedBox(width: 10),
                            Expanded(child: Text(p, style: ClinicType.body())),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ClinicPalette.crimsonWash,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: ClinicPalette.crimson.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: ClinicPalette.crimsonDeep, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Treatment notes are general education, not a prescription. Confirm any medicine, dose and withdrawal time with a licensed veterinarian.',
                    style: ClinicType.bodyStrong(color: ClinicPalette.crimsonDeep),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) =>
      Text(title, style: ClinicType.label(color: ClinicPalette.inkSoft));

  Widget _fact(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(text, style: ClinicType.caption(color: color)),
        ],
      ),
    );
  }
}
