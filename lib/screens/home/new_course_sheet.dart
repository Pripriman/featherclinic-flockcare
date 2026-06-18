import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/care_catalog.dart';
import '../../domain/flock_models.dart';
import '../../domain/flock_repository.dart';
import '../../theme/clinic_palette.dart';
import '../../theme/clinic_type.dart';
import '../../widgets/action_button.dart';

Future<MedicationCourse?> openNewCourseSheet(
  BuildContext context,
  FlockRepository repo,
) {
  return showModalBottomSheet<MedicationCourse>(
    context: context,
    isScrollControlled: true,
    backgroundColor: ClinicPalette.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => _NewCourseSheet(repo: repo),
  );
}

class _NewCourseSheet extends StatefulWidget {
  final FlockRepository repo;
  const _NewCourseSheet({required this.repo});

  @override
  State<_NewCourseSheet> createState() => _NewCourseSheetState();
}

class _NewCourseSheetState extends State<_NewCourseSheet> {
  final _subject = TextEditingController();
  String _medId = CareCatalog.medications.first.id;
  DateTime _startDate = DateTime.now();
  late int _eggDays;
  late int _meatDays;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _applyMedDefaults();
  }

  void _applyMedDefaults() {
    final m = CareCatalog.medById(_medId);
    _eggDays = m.eggWithdrawalDays;
    _meatDays = m.meatWithdrawalDays;
  }

  @override
  void dispose() {
    _subject.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: now.subtract(const Duration(days: 60)),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: ClinicPalette.tealDeep,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _create() async {
    setState(() => _busy = true);
    final subject = _subject.text.trim().isEmpty
        ? 'Flock treatment'
        : _subject.text.trim();
    final course = await widget.repo.startCourse(
      subject: subject,
      medId: _medId,
      startDate: DateTime(_startDate.year, _startDate.month, _startDate.day),
      eggDays: _eggDays,
      meatDays: _meatDays,
    );
    if (mounted) Navigator.of(context).pop(course);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: ClinicPalette.hairline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Start a treatment', style: ClinicType.title()),
              const SizedBox(height: 18),
              Text('Bird or group',
                  style: ClinicType.label(color: ClinicPalette.inkSoft)),
              const SizedBox(height: 8),
              TextField(
                controller: _subject,
                decoration: const InputDecoration(
                    hintText: 'e.g. Hen "Pepper" or whole coop'),
              ),
              const SizedBox(height: 18),
              Text('Medication',
                  style: ClinicType.label(color: ClinicPalette.inkSoft)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CareCatalog.medications.map((m) {
                  final sel = m.id == _medId;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _medId = m.id;
                      _applyMedDefaults();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: sel
                            ? ClinicPalette.tealWash
                            : ClinicPalette.surfaceDim,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel
                              ? ClinicPalette.teal
                              : ClinicPalette.hairline,
                          width: sel ? 1.4 : 1,
                        ),
                      ),
                      child: Text(m.name,
                          style: ClinicType.label(
                              color: sel
                                  ? ClinicPalette.tealDeep
                                  : ClinicPalette.ink)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(CareCatalog.medById(_medId).purpose,
                  style: ClinicType.caption()),
              const SizedBox(height: 18),
              Text('Start date',
                  style: ClinicType.label(color: ClinicPalette.inkSoft)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: ClinicPalette.surfaceDim,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ClinicPalette.hairline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded,
                          size: 18, color: ClinicPalette.tealDeep),
                      const SizedBox(width: 8),
                      Text(DateFormat('MMM d, y').format(_startDate),
                          style: ClinicType.bodyStrong()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _dayStepper(
                      'Egg withdrawal',
                      _eggDays,
                      (v) => setState(() => _eggDays = v),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _dayStepper(
                      'Meat withdrawal',
                      _meatDays,
                      (v) => setState(() => _meatDays = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ClinicPalette.amberWash,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 18, color: ClinicPalette.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Withdrawal days are typical defaults. Always use the period on your product label or from your vet.',
                        style: ClinicType.caption(color: ClinicPalette.ink),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ActionButton(
                label: 'Start tracking',
                busy: _busy,
                onPressed: _busy ? null : _create,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayStepper(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ClinicType.label(color: ClinicPalette.inkSoft)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: ClinicPalette.surfaceDim,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ClinicPalette.hairline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded),
                color: ClinicPalette.inkSoft,
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
              ),
              Text('$value', style: ClinicType.heading()),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                color: ClinicPalette.tealDeep,
                onPressed: value < 60 ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
