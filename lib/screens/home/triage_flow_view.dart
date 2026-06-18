import 'package:flutter/material.dart';

import '../../domain/condition_library.dart';
import '../../domain/flock_repository.dart';
import '../../state/clinic_scope.dart';
import '../../theme/clinic_palette.dart';
import '../../theme/clinic_type.dart';
import '../../widgets/action_button.dart';
import '../../widgets/clinic_card.dart';
import '../../widgets/status_pill.dart';
import 'condition_detail_view.dart';

class TriageFlowView extends StatefulWidget {
  const TriageFlowView({super.key});

  @override
  State<TriageFlowView> createState() => _TriageFlowViewState();
}

class _TriageFlowViewState extends State<TriageFlowView> {
  final Set<String> _selected = {};
  bool _showResults = false;

  Map<BodySystem, List<SymptomTrait>> get _grouped {
    final map = <BodySystem, List<SymptomTrait>>{};
    for (final s in ConditionLibrary.symptoms) {
      map.putIfAbsent(s.system, () => []).add(s);
    }
    return map;
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _runTriage(FlockRepository repo) {
    final hits = FlockRepository.rankConditions(_selected);
    repo.saveTriage(_selected.toList(), hits);
    setState(() => _showResults = true);
  }

  void _reset() {
    setState(() {
      _selected.clear();
      _showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ClinicScope.of(context);
    if (_showResults) {
      return _ResultsPanel(
        selected: _selected,
        onBack: () => setState(() => _showResults = false),
        onReset: _reset,
      );
    }

    final grouped = _grouped;
    final order = BodySystem.values;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          children: [
            ClinicCard(
              color: ClinicPalette.tealWash,
              border: Border.all(color: ClinicPalette.teal.withValues(alpha: 0.4)),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_rounded,
                      color: ClinicPalette.tealDeep),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tick every sign you can see. The more you mark, the sharper the shortlist.',
                      style: ClinicType.bodyStrong(color: ClinicPalette.ink),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            for (final system in order)
              if (grouped[system] != null) ...[
                _systemHeader(system),
                const SizedBox(height: 10),
                ...grouped[system]!.map(_symptomTile),
                const SizedBox(height: 18),
              ],
            _disclaimer(),
          ],
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 16,
          child: ActionButton(
            label: _selected.isEmpty
                ? 'Select symptoms to begin'
                : 'See likely conditions (${_selected.length})',
            icon: Icons.analytics_rounded,
            onPressed: _selected.isEmpty ? null : () => _runTriage(repo),
          ),
        ),
      ],
    );
  }

  Widget _systemHeader(BodySystem system) {
    return Row(
      children: [
        Text(system.emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(system.label, style: ClinicType.label(color: ClinicPalette.inkSoft)),
      ],
    );
  }

  Widget _symptomTile(SymptomTrait s) {
    final sel = _selected.contains(s.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClinicCard(
        onTap: () => _toggle(s.id),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        color: sel ? ClinicPalette.tealWash : ClinicPalette.card,
        border: Border.all(
          color: sel ? ClinicPalette.teal : ClinicPalette.hairline,
          width: sel ? 1.4 : 1,
        ),
        child: Row(
          children: [
            Icon(
              sel ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: sel ? ClinicPalette.tealDeep : ClinicPalette.inkFaint,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(s.label,
                  style: ClinicType.bodyStrong(
                      color: sel ? ClinicPalette.ink : ClinicPalette.inkSoft)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _disclaimer() => Text(
        'This triage offers hypotheses, not a diagnosis. For any worrying or fast-changing signs, contact a licensed veterinarian.',
        style: ClinicType.caption(),
        textAlign: TextAlign.center,
      );
}

class _ResultsPanel extends StatelessWidget {
  final Set<String> selected;
  final VoidCallback onBack;
  final VoidCallback onReset;

  const _ResultsPanel({
    required this.selected,
    required this.onBack,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final hits = FlockRepository.rankConditions(selected);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Row(
          children: [
            TextLink(
              label: 'Edit symptoms',
              icon: Icons.arrow_back_rounded,
              onPressed: onBack,
            ),
            const Spacer(),
            TextLink(label: 'Reset', onPressed: onReset),
          ],
        ),
        const SizedBox(height: 4),
        Text('${hits.length} possible ${hits.length == 1 ? 'match' : 'matches'}',
            style: ClinicType.title()),
        const SizedBox(height: 6),
        Text(
          'Ranked by how well your ${selected.length} selected signs fit each profile. High-risk conditions are prioritised.',
          style: ClinicType.body(),
        ),
        const SizedBox(height: 18),
        if (hits.isEmpty)
          ClinicCard(
            child: Column(
              children: [
                const Icon(Icons.search_off_rounded,
                    size: 40, color: ClinicPalette.inkFaint),
                const SizedBox(height: 12),
                Text('No clear match', style: ClinicType.heading()),
                const SizedBox(height: 6),
                Text(
                  'These signs do not point to a single profile. Add more observations or browse the disease library directly.',
                  style: ClinicType.body(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...hits.map((h) => _hitTile(context, h)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ClinicPalette.crimsonWash,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: ClinicPalette.crimson.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: ClinicPalette.crimsonDeep, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'This is a list of possibilities, not a diagnosis. Always confirm with a veterinarian before treating.',
                  style: ClinicType.bodyStrong(color: ClinicPalette.crimsonDeep),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hitTile(BuildContext context, TriageHit h) {
    final pct = (h.score * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClinicCard(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ConditionDetailView(condition: h.condition),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(h.condition.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(h.condition.name,
                      style: ClinicType.heading(),
                      overflow: TextOverflow.ellipsis),
                ),
                StatusPill(tier: h.condition.severity, dense: true),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: h.score,
                      minHeight: 8,
                      backgroundColor: ClinicPalette.surfaceDim,
                      color: h.condition.severity.color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('$pct% fit',
                    style: ClinicType.label(color: ClinicPalette.inkSoft)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${h.condition.contagion.label} · ${h.condition.system.label}',
                style: ClinicType.caption()),
          ],
        ),
      ),
    );
  }
}
