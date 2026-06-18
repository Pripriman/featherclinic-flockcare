import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/flock_models.dart';
import '../../domain/flock_repository.dart';
import '../../theme/clinic_palette.dart';
import '../../theme/clinic_type.dart';
import '../../widgets/action_button.dart';

const List<(String, String, String)> _speciesOptions = [
  ('chicken', 'Chicken', '🐔'),
  ('quail', 'Quail', '🥚'),
  ('duck', 'Duck', '🦆'),
  ('turkey', 'Turkey', '🦃'),
  ('guinea', 'Guinea fowl', '🐦'),
];

Future<FlockBatch?> openNewBatchSheet(
  BuildContext context,
  FlockRepository repo,
) {
  return showModalBottomSheet<FlockBatch>(
    context: context,
    isScrollControlled: true,
    backgroundColor: ClinicPalette.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => _NewBatchSheet(repo: repo),
  );
}

class _NewBatchSheet extends StatefulWidget {
  final FlockRepository repo;
  const _NewBatchSheet({required this.repo});

  @override
  State<_NewBatchSheet> createState() => _NewBatchSheetState();
}

class _NewBatchSheetState extends State<_NewBatchSheet> {
  final _name = TextEditingController();
  String _species = _speciesOptions.first.$1;
  DateTime _hatchDate = DateTime.now();
  int _birdCount = 6;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _hatchDate,
      firstDate: now.subtract(const Duration(days: 730)),
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
    if (picked != null) setState(() => _hatchDate = picked);
  }

  String _defaultName() {
    final label = _speciesOptions
        .firstWhere((s) => s.$1 == _species, orElse: () => _speciesOptions.first)
        .$2;
    final count = widget.repo.batches
            .where((b) => b.species == _species)
            .length +
        1;
    return '$label batch $count';
  }

  Future<void> _create() async {
    setState(() => _busy = true);
    final name =
        _name.text.trim().isEmpty ? _defaultName() : _name.text.trim();
    final batch = await widget.repo.addBatch(
      name: name,
      species: _species,
      hatchDate:
          DateTime(_hatchDate.year, _hatchDate.month, _hatchDate.day),
      birdCount: _birdCount,
    );
    if (mounted) Navigator.of(context).pop(batch);
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
              Text('New flock batch', style: ClinicType.title()),
              const SizedBox(height: 18),
              Text('Species',
                  style: ClinicType.label(color: ClinicPalette.inkSoft)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _speciesOptions.map((s) {
                  final sel = s.$1 == _species;
                  return GestureDetector(
                    onTap: () => setState(() => _species = s.$1),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s.$3, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 7),
                          Text(s.$2,
                              style: ClinicType.label(
                                  color: sel
                                      ? ClinicPalette.tealDeep
                                      : ClinicPalette.ink)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('Name',
                  style: ClinicType.label(color: ClinicPalette.inkSoft)),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                decoration: InputDecoration(hintText: _defaultName()),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hatch date',
                            style: ClinicType.label(
                                color: ClinicPalette.inkSoft)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: ClinicPalette.surfaceDim,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: ClinicPalette.hairline),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_rounded,
                                    size: 18,
                                    color: ClinicPalette.tealDeep),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('MMM d, y').format(_hatchDate),
                                  style: ClinicType.bodyStrong(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Birds',
                            style: ClinicType.label(
                                color: ClinicPalette.inkSoft)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: ClinicPalette.surfaceDim,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: ClinicPalette.hairline),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                    Icons.remove_circle_outline_rounded),
                                color: ClinicPalette.inkSoft,
                                onPressed: _birdCount > 1
                                    ? () => setState(() => _birdCount--)
                                    : null,
                              ),
                              Text('$_birdCount',
                                  style: ClinicType.heading()),
                              IconButton(
                                icon: const Icon(
                                    Icons.add_circle_outline_rounded),
                                color: ClinicPalette.tealDeep,
                                onPressed: _birdCount < 999
                                    ? () => setState(() => _birdCount++)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              ActionButton(
                label: 'Add batch',
                busy: _busy,
                onPressed: _busy ? null : _create,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
