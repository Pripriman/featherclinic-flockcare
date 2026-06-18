import 'package:flutter/material.dart';

import '../../domain/condition_library.dart';
import '../../theme/clinic_palette.dart';
import '../../theme/clinic_type.dart';
import '../../widgets/clinic_card.dart';
import '../../widgets/status_pill.dart';
import 'condition_detail_view.dart';

class ConditionLibraryView extends StatefulWidget {
  const ConditionLibraryView({super.key});

  @override
  State<ConditionLibraryView> createState() => _ConditionLibraryViewState();
}

class _ConditionLibraryViewState extends State<ConditionLibraryView> {
  final _search = TextEditingController();
  String _query = '';
  BodySystem? _system;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ConditionProfile> get _filtered {
    return ConditionLibrary.conditions.where((c) {
      if (_system != null && c.system != _system) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      if (c.name.toLowerCase().contains(q)) return true;
      if (c.summary.toLowerCase().contains(q)) return true;
      for (final id in c.symptomWeights.keys) {
        if (ConditionLibrary.symptomById(id).label.toLowerCase().contains(q)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v.trim()),
            decoration: InputDecoration(
              hintText: 'Search disease or symptom',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            children: [
              _filterChip('All', _system == null, () {
                setState(() => _system = null);
              }),
              for (final s in BodySystem.values)
                _filterChip(s.label, _system == s, () {
                  setState(() => _system = _system == s ? null : s);
                }),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 44, color: ClinicPalette.inkFaint),
                        const SizedBox(height: 12),
                        Text('No profiles match', style: ClinicType.heading()),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  itemCount: list.length,
                  itemBuilder: (context, i) => _conditionTile(list[i]),
                ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: active ? ClinicPalette.tealDeep : ClinicPalette.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? ClinicPalette.tealDeep : ClinicPalette.hairline,
            ),
          ),
          child: Text(
            label,
            style: ClinicType.label(
                color: active ? Colors.white : ClinicPalette.inkSoft),
          ),
        ),
      ),
    );
  }

  Widget _conditionTile(ConditionProfile c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClinicCard(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ConditionDetailView(condition: c),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ClinicPalette.surfaceDim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(c.emoji, style: const TextStyle(fontSize: 19)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: ClinicType.heading()),
                      const SizedBox(height: 2),
                      Text(c.system.label, style: ClinicType.caption()),
                    ],
                  ),
                ),
                StatusPill(tier: c.severity, dense: true),
              ],
            ),
            const SizedBox(height: 10),
            Text(c.summary,
                style: ClinicType.body(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              children: [
                _miniTag(c.contagion.label, c.contagion.tier.color),
                const SizedBox(width: 8),
                _miniTag(c.ageGroup.label, ClinicPalette.inkSoft),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(text, style: ClinicType.caption(color: color)),
    );
  }
}
