import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/care_catalog.dart';
import '../../domain/flock_models.dart';
import '../../domain/flock_repository.dart';
import '../../theme/clinic_palette.dart';
import '../../theme/clinic_type.dart';
import '../../widgets/clinic_card.dart';
import '../../widgets/vital_ring.dart';
import 'routine_detail_view.dart';

class BiosecurityView extends StatefulWidget {
  final FlockRepository repo;
  const BiosecurityView({super.key, required this.repo});

  @override
  State<BiosecurityView> createState() => _BiosecurityViewState();
}

class _BiosecurityViewState extends State<BiosecurityView> {
  Future<void> _openRoutine(BiosecurityRoutine routine) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineDetailView(repo: widget.repo, routine: routine),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _removeWatch(QuarantineWatch w) async {
    await widget.repo.removeWatch(w.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final watches = widget.repo.watches;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        if (watches.isNotEmpty) ...[
          Text('Active timers',
              style: ClinicType.label(color: ClinicPalette.inkSoft)),
          const SizedBox(height: 10),
          ...watches.map((w) => _watchCard(w, now)),
          const SizedBox(height: 16),
        ],
        Text('Biosecurity routines',
            style: ClinicType.label(color: ClinicPalette.inkSoft)),
        const SizedBox(height: 10),
        ...CareCatalog.routines.map(_routineCard),
        const SizedBox(height: 14),
        Text(
          'Good biosecurity is the cheapest medicine. Pair these routines with your veterinarian’s local advice.',
          style: ClinicType.caption(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _watchCard(QuarantineWatch w, DateTime now) {
    final daysLeft = w.daysLeft(now);
    final cleared = w.cleared(now);
    final color = cleared ? ClinicPalette.healthy : ClinicPalette.tealDeep;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClinicCard(
        child: Row(
          children: [
            VitalRing(
              size: 58,
              progress: w.progress(now),
              stroke: 7,
              color: color,
              child: cleared
                  ? Icon(Icons.check_rounded, color: color, size: 22)
                  : Text('$daysLeft', style: ClinicType.numeral(20, color: color)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w.label, style: ClinicType.heading()),
                  const SizedBox(height: 2),
                  Text(
                    cleared
                        ? 'Quarantine complete'
                        : '$daysLeft of ${w.days} days left · clears ${DateFormat('MMM d').format(w.clearDate)}',
                    style: ClinicType.caption(),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              color: ClinicPalette.inkFaint,
              onPressed: () => _removeWatch(w),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routineCard(BiosecurityRoutine routine) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClinicCard(
        onTap: () => _openRoutine(routine),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ClinicPalette.surfaceDim,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(routine.emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(routine.title, style: ClinicType.heading()),
                  const SizedBox(height: 3),
                  Text(routine.purpose,
                      style: ClinicType.caption(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: ClinicPalette.inkFaint),
          ],
        ),
      ),
    );
  }
}
