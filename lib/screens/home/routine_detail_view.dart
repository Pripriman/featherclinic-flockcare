import 'package:flutter/material.dart';

import '../../domain/care_catalog.dart';
import '../../domain/flock_models.dart';
import '../../domain/flock_repository.dart';
import '../../theme/clinic_palette.dart';
import '../../theme/clinic_type.dart';
import '../../widgets/action_button.dart';
import '../../widgets/clinic_card.dart';

class RoutineDetailView extends StatefulWidget {
  final FlockRepository repo;
  final BiosecurityRoutine routine;
  const RoutineDetailView({
    super.key,
    required this.repo,
    required this.routine,
  });

  @override
  State<RoutineDetailView> createState() => _RoutineDetailViewState();
}

class _RoutineDetailViewState extends State<RoutineDetailView> {
  final Set<String> _checked = {};

  void _toggle(String id) {
    setState(() {
      if (_checked.contains(id)) {
        _checked.remove(id);
      } else {
        _checked.add(id);
      }
    });
  }

  Future<void> _startTimer() async {
    final routine = widget.routine;
    var days = routine.defaultQuarantineDays ?? 30;
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              backgroundColor: ClinicPalette.card,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text('Start ${routine.title.toLowerCase()}',
                  style: ClinicType.heading()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                        hintText: 'Label (e.g. New hens, June)'),
                  ),
                  const SizedBox(height: 16),
                  Text('Days', style: ClinicType.label(color: ClinicPalette.inkSoft)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        onPressed:
                            days > 1 ? () => setLocal(() => days--) : null,
                      ),
                      Text('$days', style: ClinicType.numeral(28)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        onPressed:
                            days < 90 ? () => setLocal(() => days++) : null,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: ClinicPalette.tealDeep),
                  onPressed: () => Navigator.pop(dialogCtx, true),
                  child: const Text('Start'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      final label = controller.text.trim().isEmpty
          ? widget.routine.title
          : controller.text.trim();
      await widget.repo.startWatch(
        label: label,
        routineId: widget.routine.id,
        startDate: DateTime.now(),
        days: days,
      );
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final routine = widget.routine;
    final done = _checked.length;
    final total = routine.tasks.length;

    return Scaffold(
      backgroundColor: ClinicPalette.surface,
      appBar: AppBar(
        title: Text(routine.title, style: ClinicType.title()),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          ClinicCard(
            color: ClinicPalette.tealWash,
            border: Border.all(color: ClinicPalette.teal.withValues(alpha: 0.4)),
            child: Row(
              children: [
                Text(routine.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(routine.purpose,
                      style: ClinicType.bodyStrong(color: ClinicPalette.ink)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Checklist',
                  style: ClinicType.label(color: ClinicPalette.inkSoft)),
              const Spacer(),
              Text('$done / $total',
                  style: ClinicType.label(color: ClinicPalette.tealDeep)),
            ],
          ),
          const SizedBox(height: 10),
          ClinicCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < routine.tasks.length; i++)
                  _taskRow(routine.tasks[i], last: i == routine.tasks.length - 1),
              ],
            ),
          ),
          if (routine.defaultQuarantineDays != null) ...[
            const SizedBox(height: 18),
            ActionButton(
              label: 'Start a countdown timer',
              icon: Icons.timer_outlined,
              onPressed: _startTimer,
            ),
          ],
        ],
      ),
    );
  }

  Widget _taskRow(ChecklistTask task, {required bool last}) {
    final checked = _checked.contains(task.id);
    return InkWell(
      onTap: () => _toggle(task.id),
      child: Container(
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(
                  bottom: BorderSide(color: ClinicPalette.hairline)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(
              checked
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: checked ? ClinicPalette.tealDeep : ClinicPalette.inkFaint,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.text,
                style: ClinicType.bodyStrong(
                  color: checked ? ClinicPalette.inkFaint : ClinicPalette.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
