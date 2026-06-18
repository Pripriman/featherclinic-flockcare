import 'package:flutter/widgets.dart';
import '../domain/flock_repository.dart';

class ClinicScope extends InheritedNotifier<FlockRepository> {
  const ClinicScope({
    super.key,
    required FlockRepository repo,
    required super.child,
  }) : super(notifier: repo);

  static FlockRepository of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ClinicScope>();
    assert(scope != null, 'ClinicScope not found in context');
    return scope!.notifier!;
  }

  static FlockRepository read(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<ClinicScope>()
        ?.widget as ClinicScope?;
    return scope!.notifier!;
  }
}
