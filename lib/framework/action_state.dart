import 'package:bakecode/framework/actions.dart';
import 'package:meta/meta.dart';

class ActionContext {
  /// The [Action] of [this] [ActionContext].
  final Action action;

  /// Create a new [ActionContext] instance for an [Action].
  ActionContext(this.action);

  /// The current [state] of [this.action].
  ActionState state = Pending();

  /// Perform the action.
  void perform() => action.perform(context: this);
}

/// Defines the abstract layer of [ActionState].
///
/// [T] is the type of the final [result] to be returned after performing the
/// action.
@immutable
class ActionState<T> {
  final int currentStep;
  final int totalSteps;
  final List<Exception> exceptionsEncountered;
  final T result;

  const ActionState({
    @required this.currentStep,
    @required this.totalSteps,
    @required this.exceptionsEncountered,
    @required this.result,
  });

  factory ActionState.pending({int steps}) => Pending(steps: steps);

  factory ActionState.executing({
    @required int currentStep,
    @required int totalSteps,
    List<Exception> exceptions,
  }) =>
      Executing(
        currentStep: currentStep,
        totalSteps: totalSteps,
        exceptions: exceptions,
      );

  factory ActionState.completed({
    int currentStep,
    @required int totalSteps,
    List<Exception> exceptions,
    T result,
  }) =>
      ActionState(
        currentStep: currentStep ?? totalSteps,
        totalSteps: totalSteps,
        exceptionsEncountered: exceptions,
        result: result,
      );

  factory ActionState.completedWithExceptions({
    int currentStep,
    @required int totalSteps,
    @required List<Exception> exceptions,
    T result,
  }) =>
      ActionState(
        currentStep: currentStep ?? totalSteps,
        totalSteps: totalSteps,
        exceptionsEncountered: exceptions,
        result: result,
      );

  factory ActionState.failed({
    @required int currentStep,
    @required int totalSteps,
    @required List<Exception> exceptions,
    T result,
  }) =>
      ActionState(
        currentStep: currentStep,
        totalSteps: totalSteps,
        exceptionsEncountered: exceptions,
        result: result,
      );
}

class Pending<T> extends ActionState<T> {
  const Pending({
    int steps,
  }) : super(
          currentStep: 0,
          totalSteps: steps,
          exceptionsEncountered: null,
          result: null,
        );

  @override
  String toString() => 'Action pending.';
}

class Executing<T> extends ActionState<T> {
  const Executing({
    @required int currentStep,
    @required int totalSteps,
    List<Exception> exceptions,
  })  : assert(currentStep != null),
        assert(totalSteps != null),
        super(
          currentStep: currentStep,
          totalSteps: totalSteps,
          exceptionsEncountered: exceptions,
          result: null,
        );

  // double get percentage => of == 0 ? 0 : (100 * current / of);

  @override
  String toString() => 'Executing $currentStep of $totalSteps.';
}

class Completed<T> extends ActionState<T> {
  const Completed({
    int currentStep,
    @required int totalSteps,
    List<Exception> exceptions,
    T result,
  }) : super(
          currentStep: currentStep ?? totalSteps,
          totalSteps: totalSteps,
          exceptionsEncountered: exceptions,
          result: result,
        );

  @override
  String toString() => 'Completed succesfully.';
}

class CompletedWithException<T> extends Completed<T> {
  const CompletedWithException({
    int currentStep,
    @required int totalSteps,
    @required List<Exception> exceptions,
    T result,
  }) : super(
          currentStep: currentStep ?? totalSteps,
          totalSteps: totalSteps,
          exceptions: exceptions,
          result: result,
        );

  @override
  String toString() =>
      'Completed w/ ${exceptionsEncountered.length} exceptions.';
}

class Failed<T> extends ActionState<T> {
  const Failed({
    @required int currentStep,
    @required int totalSteps,
    @required List<Exception> exceptions,
    T result,
  }) : super(
          currentStep: currentStep,
          totalSteps: totalSteps,
          exceptionsEncountered: exceptions,
          result: result,
        );

  @override
  String toString() => 'Action failed.';
}
