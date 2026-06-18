import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/care_catalog.dart';
import '../../domain/flock_models.dart';
import '../../domain/flock_repository.dart';
import '../../theme/clinic_palette.dart';
import '../../theme/clinic_type.dart';
import '../../widgets/action_button.dart';
import '../../widgets/clinic_card.dart';
import 'new_course_sheet.dart';

class WithdrawalTrackerView extends StatefulWidget {
  final FlockRepository repo;
  const WithdrawalTrackerView({super.key, required this.repo});

  @override
  State<WithdrawalTrackerView> createState() => _WithdrawalTrackerViewState();
}

class _WithdrawalTrackerViewState extends State<WithdrawalTrackerView> {
  Future<void> _addCourse() async {
    final created = await openNewCourseSheet(context, widget.repo);
    if (created != null && mounted) setState(() {});
  }

  Future<void> _confirmRemove(MedicationCourse c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: ClinicPalette.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Remove treatment?', style: ClinicType.heading()),
        content: Text(
          'This clears the withdrawal countdown for "${c.subject}".',
          style: ClinicType.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: ClinicPalette.crimsonDeep),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.repo.removeCourse(c.id);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final courses = widget.repo.courses;
    final active = widget.repo.activeCourses(now);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: ClinicPalette.tealDeep,
        foregroundColor: Colors.white,
        onPressed: _addCourse,
        child: const Icon(Icons.add_rounded),
      ),
      body: courses.isEmpty
          ? _empty()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: [
                ClinicCard(
                  color: ClinicPalette.crimsonWash,
                  border: Border.all(
                      color: ClinicPalette.crimson.withValues(alpha: 0.4)),
                  child: Row(
                    children: [
                      const Icon(Icons.no_food_rounded,
                          color: ClinicPalette.crimsonDeep),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          active.isEmpty
                              ? 'No active withdrawals — all tracked products are clear.'
                              : '${active.length} treatment(s) active. Do not eat or sell products marked unsafe.',
                          style: ClinicType.bodyStrong(
                              color: ClinicPalette.crimsonDeep),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...courses.map((c) => _courseCard(c, now)),
              ],
            ),
    );
  }

  Widget _courseCard(MedicationCourse c, DateTime now) {
    final med = CareCatalog.medById(c.medId);
    final eggLeft = c.eggDaysLeft(now);
    final meatLeft = c.meatDaysLeft(now);
    final cleared = c.fullyCleared(now);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClinicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cleared
                        ? ClinicPalette.healthy.withValues(alpha: 0.12)
                        : ClinicPalette.tealWash,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    cleared
                        ? Icons.check_circle_rounded
                        : Icons.medication_rounded,
                    color: cleared
                        ? ClinicPalette.healthy
                        : ClinicPalette.tealDeep,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.subject, style: ClinicType.heading()),
                      const SizedBox(height: 2),
                      Text('${med.name} · started ${DateFormat('MMM d').format(c.startDate)}',
                          style: ClinicType.caption()),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: ClinicPalette.inkFaint,
                  onPressed: () => _confirmRemove(c),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _countdownTile(
                    icon: Icons.egg_rounded,
                    label: 'Eggs',
                    daysLeft: eggLeft,
                    clearDate: c.eggClearDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _countdownTile(
                    icon: Icons.set_meal_rounded,
                    label: 'Meat',
                    daysLeft: meatLeft,
                    clearDate: c.meatClearDate,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _countdownTile({
    required IconData icon,
    required String label,
    required int daysLeft,
    required DateTime clearDate,
  }) {
    final safe = daysLeft == 0;
    final color = safe ? ClinicPalette.healthy : ClinicPalette.crimson;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: ClinicType.label(color: color)),
            ],
          ),
          const SizedBox(height: 10),
          if (safe)
            Row(
              children: [
                Icon(Icons.check_rounded, size: 18, color: color),
                const SizedBox(width: 4),
                Text('Safe',
                    style: ClinicType.heading(color: color)),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('$daysLeft',
                    style: ClinicType.numeral(26, color: color)),
                const SizedBox(width: 4),
                Text(daysLeft == 1 ? 'day left' : 'days left',
                    style: ClinicType.caption(color: color)),
              ],
            ),
          const SizedBox(height: 4),
          Text(
            safe ? 'Cleared' : 'Clears ${DateFormat('MMM d').format(clearDate)}',
            style: ClinicType.caption(),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ClinicPalette.tealWash,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.medication_rounded,
                  size: 40, color: ClinicPalette.tealDeep),
            ),
            const SizedBox(height: 20),
            Text('No treatments tracked', style: ClinicType.title()),
            const SizedBox(height: 10),
            Text(
              'When you start a medicine, log it here. The app counts down the egg and meat withdrawal separately so you never use unsafe products.',
              style: ClinicType.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ActionButton(
              label: 'Start a treatment',
              icon: Icons.add_rounded,
              expand: false,
              onPressed: _addCourse,
            ),
          ],
        ),
      ),
    );
  }
}
