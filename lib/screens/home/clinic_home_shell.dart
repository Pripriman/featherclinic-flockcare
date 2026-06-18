import 'package:flutter/material.dart';

import '../../runtime/alert_relay.dart';
import '../../runtime/clinic_link.dart';
import '../../state/clinic_scope.dart';
import '../../theme/clinic_palette.dart';
import '../../theme/clinic_type.dart';
import '../access/access_screen.dart';
import 'biosecurity_view.dart';
import 'condition_library_view.dart';
import 'triage_flow_view.dart';
import 'vaccine_calendar_view.dart';
import 'withdrawal_tracker_view.dart';

class ClinicHomeShell extends StatefulWidget {
  const ClinicHomeShell({super.key});

  @override
  State<ClinicHomeShell> createState() => _ClinicHomeShellState();
}

class _ClinicHomeShellState extends State<ClinicHomeShell> {
  int _tab = 0;

  static const _titles = [
    'Symptom triage',
    'Disease library',
    'Vaccination plan',
    'Withdrawal tracker',
    'Biosecurity',
  ];

  void _openAccount() {
    final signedIn = ClinicLink.signedIn;
    showModalBottomSheet(
      context: context,
      backgroundColor: ClinicPalette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account', style: ClinicType.heading()),
                const SizedBox(height: 6),
                Text(
                  signedIn
                      ? (ClinicLink.currentUser?.email ?? 'Signed in')
                      : 'You are using the health desk as a guest.',
                  style: ClinicType.body(),
                ),
                const SizedBox(height: 16),
                if (signedIn)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout_rounded,
                        color: ClinicPalette.crimsonDeep),
                    title: Text('Sign out',
                        style: ClinicType.bodyStrong(
                            color: ClinicPalette.crimsonDeep)),
                    onTap: () async {
                      await AlertRelay.unbindUser();
                      await ClinicLink.signOut();
                      if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                      if (mounted) setState(() {});
                    },
                  )
                else
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.login_rounded,
                        color: ClinicPalette.tealDeep),
                    title: Text('Sign in or create account',
                        style: ClinicType.bodyStrong(
                            color: ClinicPalette.tealDeep)),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AccessScreen(
                            onDone: () {
                              Navigator.of(context).maybePop();
                              if (mounted) setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ClinicScope.of(context);

    Widget body;
    switch (_tab) {
      case 0:
        body = const TriageFlowView();
        break;
      case 1:
        body = const ConditionLibraryView();
        break;
      case 2:
        body = VaccineCalendarView(repo: repo);
        break;
      case 3:
        body = WithdrawalTrackerView(repo: repo);
        break;
      case 4:
        body = BiosecurityView(repo: repo);
        break;
      default:
        body = const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: ClinicPalette.surface,
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(_titles[_tab], style: ClinicType.title()),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            color: ClinicPalette.ink,
            onPressed: _openAccount,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: body,
      bottomNavigationBar: _BottomBar(
        index: _tab,
        onChanged: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _BottomBar({required this.index, required this.onChanged});

  static const _items = [
    (Icons.fact_check_outlined, Icons.fact_check_rounded, 'Triage'),
    (Icons.menu_book_outlined, Icons.menu_book_rounded, 'Library'),
    (Icons.event_available_outlined, Icons.event_available_rounded, 'Vaccines'),
    (Icons.medication_outlined, Icons.medication_rounded, 'Drugs'),
    (Icons.shield_outlined, Icons.shield_rounded, 'Biosec'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ClinicPalette.card,
        border: Border(
          top: BorderSide(color: ClinicPalette.hairline),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == index;
              final item = _items[i];
              return Expanded(
                child: InkResponse(
                  onTap: () => onChanged(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? item.$2 : item.$1,
                        size: 23,
                        color: selected
                            ? ClinicPalette.tealDeep
                            : ClinicPalette.inkFaint,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$3,
                        style: ClinicType.caption(
                          color: selected
                              ? ClinicPalette.tealDeep
                              : ClinicPalette.inkFaint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
