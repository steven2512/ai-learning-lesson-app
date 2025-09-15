// FILE: lib/core/lesson/lesson_scaffold.dart
// Reusable lesson flow controller: handles steps, progress, Continue gating,
// and auto "End → Next Lesson" routing based on the global registry index.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/core/lesson_order.dart';

/// Controls passed to each step so it can signal the scaffold.
class LessonControls {
  final VoidCallback complete; // mark this step as completed (enables Continue)
  final VoidCallback reset; // mark this step as NOT completed (hide Continue)
  final VoidCallback next; // optionally auto-advance to the next step

  const LessonControls({
    required this.complete,
    required this.reset,
    required this.next,
  });
}

/// A reusable scaffold for any lesson. You provide:
/// - [registryIndex]: position in the global lessons list
/// - [buildSteps]: returns the step widgets, receiving [LessonControls]
/// - [gated]: indices of steps that require completion before Continue is enabled
/// - [onNavigate]: your app's navigation callback (accepts your route object)
/// - [buildEndRoute]: builds the "End of Lesson" route; given current + next indices
///
/// Optional:
/// - [title]/[lessonId]: for display/logging
/// - [progressBuilder]: custom progress UI
/// - [continueButtonBuilder]: custom Continue button UI
class LessonScaffold extends StatefulWidget {
  const LessonScaffold({
    super.key,
    required this.registryIndex,
    required this.buildSteps,
    required this.onNavigate,
    required this.buildEndRoute,
    this.lessonId = '',
    this.title,
    this.gated = const <int>{},
    this.progressBuilder,
    this.continueButtonBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.contentMaxWidth = 650.0,
    this.switchDuration = const Duration(milliseconds: 250),
  });

  /// Position in the global lessons list (from `lesson_order.dart`).
  final int registryIndex;

  /// Build the list of step widgets, using the provided [LessonControls].
  final List<Widget> Function(LessonControls controls) buildSteps;

  /// Steps that require completion (Continue disabled until `controls.complete()` is called).
  final Set<int> gated;

  /// App navigation callback (typically pushes your route).
  final LessonNav onNavigate;

  /// Build the "End of Lesson" route (Object) given current and next indices.
  /// - [currentIndex] is this lesson’s registry index
  /// - [nextIndex] is null if this is the last lesson
  final Object Function(int currentIndex, int? nextIndex) buildEndRoute;

  /// Optional metadata
  final String lessonId;
  final String? title;

  /// Optional UI customizations
  final Widget Function(BuildContext context, int currentStep, int totalSteps)?
      progressBuilder;

  final Widget Function(
    BuildContext context,
    bool enabled,
    VoidCallback onPressed,
    bool isLastStep,
  )? continueButtonBuilder;

  /// Layout tweaks
  final EdgeInsets padding;
  final double contentMaxWidth;
  final Duration switchDuration;

  @override
  State<LessonScaffold> createState() => _LessonScaffoldState();
}

class _LessonScaffoldState extends State<LessonScaffold> {
  late final List<Widget> _steps;
  final ValueNotifier<int> _currentStep = ValueNotifier<int>(0);
  final ValueNotifier<bool> _stepComplete = ValueNotifier<bool>(true);

  int get _totalSteps => _steps.length;

  @override
  void initState() {
    super.initState();

    // Wire controls used by step widgets.
    final controls = LessonControls(
      complete: () => _setStepComplete(true),
      reset: () => _setStepComplete(false),
      next: _goNextStep,
    );

    _steps = widget.buildSteps(controls);

    assert(
      _steps.isNotEmpty,
      'LessonScaffold requires at least one step widget. '
      'Check your buildSteps implementation.',
    );

    // Initialize completion state for step 0.
    final initialComplete = !widget.gated.contains(0);
    _stepComplete.value = initialComplete;
  }

  @override
  void dispose() {
    _currentStep.dispose();
    _stepComplete.dispose();
    super.dispose();
  }

  void _setStepComplete(bool value) {
    if (mounted) _stepComplete.value = value;
  }

  void _goNextStep() {
    final i = _currentStep.value;
    if (i + 1 < _totalSteps) {
      // Advance to the next step
      _currentStep.value = i + 1;

      // Reset completion state for the new step:
      final needsGate = widget.gated.contains(_currentStep.value);
      _stepComplete.value = !needsGate;
    } else {
      // End of lesson → navigate to End screen (auto-compute next lesson)
      final nextIndex =
          hasNextLesson(widget.registryIndex) ? widget.registryIndex + 1 : null;

      final endRoute = widget.buildEndRoute(widget.registryIndex, nextIndex);
      widget.onNavigate(endRoute);
    }
  }

  Widget _defaultProgress(BuildContext context, int step, int total) {
    final fraction = total == 0 ? 0.0 : (step + 1) / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.title != null && widget.title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.title!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: fraction),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _defaultContinueButton(
    BuildContext context,
    bool enabled,
    VoidCallback onPressed,
    bool isLastStep,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        child: Text(isLastStep ? 'Finish' : 'Continue'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxW = widget.contentMaxWidth.clamp(320.0, constraints.maxWidth);

      return Padding(
        padding: widget.padding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress (customizable)
                ValueListenableBuilder<int>(
                  valueListenable: _currentStep,
                  builder: (context, step, _) {
                    final progress = widget.progressBuilder ?? _defaultProgress;
                    return progress(context, step, _totalSteps);
                  },
                ),

                // Step content
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentStep,
                    builder: (context, step, _) {
                      return AnimatedSwitcher(
                        duration: widget.switchDuration,
                        child: KeyedSubtree(
                          // Unique key to trigger AnimatedSwitcher on step change
                          key: ValueKey<int>(step),
                          child: _steps[step],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Continue / Finish button (gated)
                ValueListenableBuilder2<bool, int>(
                  first: _stepComplete,
                  second: _currentStep,
                  builder: (context, enabled, step, _) {
                    final isLast = (step + 1) >= _totalSteps;
                    final btnBuilder =
                        widget.continueButtonBuilder ?? _defaultContinueButton;
                    return btnBuilder(context, enabled, _goNextStep, isLast);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Helper to listen to two ValueListenables without nesting.
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
  });

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget Function(BuildContext, A, B, Widget?) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, a, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, child) => builder(context, a, b, child),
        );
      },
    );
  }
}
