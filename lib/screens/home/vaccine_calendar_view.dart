import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/care_catalog.dart';
import '../../domain/flock_models.dart';
import '../../domain/flock_repository.dart';
import '../../theme/clinic_palette.dart';
import '../../theme/clinic_type.dart';
import '../../widgets/action_button.dart';
import '../../widgets/clinic_card.dart';
import '../../widgets/count_readout.dart';
import '../../widgets/range_meter.dart';
import 'new_batch_sheet.dart';

enum _VaccineStatus { done, due, overdue, upcoming }

class VaccineCalendarView extends StatefulWidget {
  final FlockRepository repo;
  const VaccineCalendarView({super.key, required this.repo});

  @override
  State<VaccineCalendarView> createState() => _VaccineCalendarViewState();
}

class _VaccineCalendarViewState extends State<VaccineCalendarView> {
  String? _activeId;

  FlockBatch? _resolveActive() {
    final list = widget.repo.batches;
    if (list.isEmpty) return null;
    if (_activeId != null) {
      for (final b in list) {
        if (b.id == _activeId) return b;
      }
    }
    return list.first;
  }

  Future<void> _addBatch() async {
    final created = await openNewBatchSheet(context, widget.repo);
    if (created != null) setState(() => _activeId = created.id);
  }

  _VaccineStatus _statusFor(FlockBatch batch, VaccineSlot slot, int ageDays) {
    if (batch.isDone(slot.id)) return _VaccineStatus.done;
    if (ageDays < slot.windowStartDay) return _VaccineStatus.upcoming;
    if (ageDays <= slot.windowEndDay) return _VaccineStatus.due;
    return _VaccineStatus.overdue;
  }

  @override
  Widget build(BuildContext context) {
    final batch = _resolveActive();
    if (batch == null) {
      return _EmptyBatches(onAdd: _addBatch);
    }

    final now = DateTime.now();
    final ageDays = batch.ageDays(now);
    final ageWeeks = batch.ageWeeks(now);
    final doneCount =
        CareCatalog.vaccineSchedule.where((v) => batch.isDone(v.id)).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: ClinicPalette.tealDeep,
        foregroundColor: Colors.white,
        onPressed: _addBatch,
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          if (widget.repo.batches.length > 1) _batchSelector(batch),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                ClinicCard(
                  child: Row(
                    children: [
                      CountReadout(
                        value: '$ageDays',
                        caption: 'days old',
                      ),
                      Container(
                        width: 1,
                        height: 48,
                        color: ClinicPalette.hairline,
                        margin: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(batch.name, style: ClinicType.heading()),
                            const SizedBox(height: 4),
                            Text(
                              '$ageWeeks weeks · ${batch.birdCount} birds',
                              style: ClinicType.caption(),
                            ),
                            const SizedBox(height: 4),
                            const SizedBox(height: 10),
                            RangeMeter(
                              title: 'Plan progress',
                              value: doneCount.toDouble(),
                              maxValue:
                                  CareCatalog.vaccineSchedule.length.toDouble(),
                              tone: ClinicPalette.healthy,
                              trailing:
                                  '$doneCount/${CareCatalog.vaccineSchedule.length}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Age-based schedule',
                    style: ClinicType.label(color: ClinicPalette.inkSoft)),
                const SizedBox(height: 10),
                ...CareCatalog.vaccineSchedule.map(
                  (slot) => _vaccineRow(batch, slot, ageDays),
                ),
                const SizedBox(height: 14),
                Text(
                  'Vaccination windows are typical guidance. Confirm the right plan and products with a veterinarian and local requirements.',
                  style: ClinicType.caption(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _batchSelector(FlockBatch active) {
    final list = widget.repo.batches;
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final b = list[i];
          final sel = b.id == active.id;
          return GestureDetector(
            onTap: () => setState(() => _activeId = b.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? ClinicPalette.tealDeep : ClinicPalette.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel ? ClinicPalette.tealDeep : ClinicPalette.hairline,
                ),
              ),
              child: Text(
                b.name,
                style: ClinicType.label(
                    color: sel ? Colors.white : ClinicPalette.ink),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _vaccineRow(FlockBatch batch, VaccineSlot slot, int ageDays) {
    final status = _statusFor(batch, slot, ageDays);
    final meta = _statusMeta(status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClinicCard(
        onTap: () => widget.repo
            .markVaccine(batch.id, slot.id, !batch.isDone(slot.id)),
        border: Border.all(
          color: status == _VaccineStatus.overdue
              ? ClinicPalette.crimson.withValues(alpha: 0.5)
              : (status == _VaccineStatus.due
                  ? ClinicPalette.amber.withValues(alpha: 0.5)
                  : ClinicPalette.hairline),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: meta.$2.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(meta.$3, size: 20, color: meta.$2),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(slot.name, style: ClinicType.bodyStrong()),
                  const SizedBox(height: 2),
                  Text(
                    'Age ${_window(slot)} · ${slot.route}',
                    style: ClinicType.caption(),
                  ),
                  if (batch.isDone(slot.id))
                    Text(
                      'Marked ${DateFormat('MMM d').format(batch.doneVaccines[slot.id]!)}',
                      style: ClinicType.caption(color: ClinicPalette.healthy),
                    ),
                ],
              ),
            ),
            Text(meta.$1, style: ClinicType.label(color: meta.$2)),
          ],
        ),
      ),
    );
  }

  String _window(VaccineSlot slot) {
    if (slot.windowStartDay == slot.windowEndDay) {
      return 'day ${slot.windowStartDay}';
    }
    if (slot.windowEndDay >= 28) {
      final w1 = (slot.windowStartDay / 7).round();
      final w2 = (slot.windowEndDay / 7).round();
      return 'wk $w1–$w2';
    }
    return 'day ${slot.windowStartDay}–${slot.windowEndDay}';
  }

  (String, Color, IconData) _statusMeta(_VaccineStatus s) {
    switch (s) {
      case _VaccineStatus.done:
        return ('Done', ClinicPalette.healthy, Icons.check_circle_rounded);
      case _VaccineStatus.due:
        return ('Due now', ClinicPalette.amber, Icons.notifications_active_rounded);
      case _VaccineStatus.overdue:
        return ('Overdue', ClinicPalette.crimson, Icons.error_rounded);
      case _VaccineStatus.upcoming:
        return ('Upcoming', ClinicPalette.inkFaint, Icons.schedule_rounded);
    }
  }
}

class _EmptyBatches extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyBatches({required this.onAdd});

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.event_available_rounded,
                  size: 40, color: ClinicPalette.tealDeep),
            ),
            const SizedBox(height: 20),
            Text('No flock added yet', style: ClinicType.title()),
            const SizedBox(height: 10),
            Text(
              'Add a batch with its hatch date and the app builds an age-based vaccination plan for it.',
              style: ClinicType.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ActionButton(
              label: 'Add a flock batch',
              icon: Icons.add_rounded,
              expand: false,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}
