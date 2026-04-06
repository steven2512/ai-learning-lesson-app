import 'package:flutter/widgets.dart';
import 'package:running_robot/services/app_progression_controller.dart';

class ProgressionScope extends InheritedNotifier<AppProgressionController> {
  const ProgressionScope({
    super.key,
    required AppProgressionController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppProgressionController watch(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ProgressionScope>();
    assert(scope != null, 'No ProgressionScope found in context');
    return scope!.notifier!;
  }

  static AppProgressionController read(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<ProgressionScope>();
    final scope = element?.widget as ProgressionScope?;
    assert(scope != null, 'No ProgressionScope found in context');
    return scope!.notifier!;
  }
}
