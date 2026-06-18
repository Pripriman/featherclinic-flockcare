import 'package:flutter/material.dart';
import '../../theme/clinic_palette.dart';
import '../../theme/clinic_type.dart';
import '../../widgets/action_button.dart';

class _Panel {
  final IconData icon;
  final Color tone;
  final String title;
  final String body;
  const _Panel(this.icon, this.tone, this.title, this.body);
}

class IntroFlow extends StatefulWidget {
  final VoidCallback onDone;
  const IntroFlow({super.key, required this.onDone});

  @override
  State<IntroFlow> createState() => _IntroFlowState();
}

class _IntroFlowState extends State<IntroFlow> {
  final _controller = PageController();
  int _index = 0;

  static const _panels = [
    _Panel(Icons.fact_check_rounded, ClinicPalette.tealDeep,
        'Triage symptoms in minutes',
        'Tick what you see and get a ranked shortlist of likely conditions, each flagged Healthy, Watch or Critical so you know how urgent it is.'),
    _Panel(Icons.menu_book_rounded, ClinicPalette.teal,
        'An offline disease library',
        'Browse clear profiles for the common poultry diseases — symptoms, treatment options, prevention and how contagious each one is.'),
    _Panel(Icons.event_available_rounded, ClinicPalette.amber,
        'Vaccinate by flock age',
        'Add a batch with its hatch date and the app builds an age-based vaccination plan, marking each shot as due, done or overdue.'),
    _Panel(Icons.shield_rounded, ClinicPalette.crimson,
        'Protect food and flock',
        'Track drug withdrawal for eggs and meat separately, and run quarantine and biosecurity checklists with countdown timers.'),
  ];

  bool get _last => _index == _panels.length - 1;

  void _next() {
    if (_last) {
      widget.onDone();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ClinicPalette.clinicalWash),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 4),
                  child: AnimatedOpacity(
                    opacity: _last ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextLink(
                      label: 'Skip',
                      onPressed: _last ? null : widget.onDone,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _panels.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final p = _panels[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 132,
                            height: 132,
                            decoration: BoxDecoration(
                              color: p.tone.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(36),
                              border: Border.all(
                                  color: p.tone.withValues(alpha: 0.4),
                                  width: 1.4),
                            ),
                            child: Icon(p.icon, size: 58, color: p.tone),
                          ),
                          const SizedBox(height: 40),
                          Text(p.title,
                              style: ClinicType.title(),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 14),
                          Text(p.body,
                              style: ClinicType.body(),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_panels.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? ClinicPalette.tealDeep
                          : ClinicPalette.hairline,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 28),
                child: ActionButton(
                  label: _last ? 'Open the health desk' : 'Next',
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
