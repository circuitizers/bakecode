import 'package:meta/meta.dart';

/// Defines the abstract layer of [Action].
abstract class Action {
  /// Creates a new [ActionContext] for [this] [Action].
  ActionContext createContext() => ActionContext(this);

  /// Perform [this] action.
  Stream<ActionState> perform({ActionContext context});
}

/// Context for an [Action].
class ActionContext {
  /// The [Action] of [this] [ActionContext].
  final Action action;

  /// Creates a new [ActionContext] instance for an [Action].
  ActionContext(this.action);

  /// The current [state] of [this.action].
  ActionState state = Pending();

  /// Perform the action on [this] context.
  void perform() => action.perform(context: this);
}

/// [ActionState] contains information of the current state of an [Action].
///
/// [T] is the type of the [result] to be returned after performing the action.
@immutable
class ActionState<T> {
  /// The current execution step position of an [Action].
  final int currentStep;

  /// Total number of steps to be executed by the [Action].
  final int totalSteps;

  /// All exceptions encountered while executing the steps.
  final List<Exception> exceptionsEncountered;

  /// The [result] object, after executing the [Action].
  final T result;

  /// [ActionState] constructor.
  const ActionState._({
    @required this.currentStep,
    @required this.totalSteps,
    @required this.exceptionsEncountered,
    @required this.result,
  });

  /// To define when an [Action] is pending to be executed.
  factory ActionState.pending({int steps}) => Pending(steps: steps);

  /// To define when an [Action] is currently being executed.
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

  /// To define when an [Action] has succesfully executed without encountering
  /// any [Exception].
  ///
  /// If one or more [Exception] has been encountered while executing, use
  /// [CompletedWithExceptions] or [ActionState.completedWithExceptions]
  /// to define the [ActionState].
  factory ActionState.completed({
    int currentStep,
    @required int totalSteps,
    List<Exception> exceptions,
    T result,
  }) =>
      Completed(
        currentStep: currentStep ?? totalSteps,
        totalSteps: totalSteps,
        exceptions: exceptions,
        result: result,
      );

  /// To define when an [Action] has completed execution and has encountered
  /// one or more [Exceptions] during execution.
  ///
  /// If [Action] couldn't complete execution, use [Failed] or
  /// [ActionState.failed] to define the [ActionState].
  factory ActionState.completedWithExceptions({
    int currentStep,
    @required int totalSteps,
    @required List<Exception> exceptions,
    T result,
  }) =>
      CompletedWithException(
        currentStep: currentStep ?? totalSteps,
        totalSteps: totalSteps,
        exceptions: exceptions,
        result: result,
      );

  /// To define when an [Action] failed to complete execution.
  factory ActionState.failed({
    @required int currentStep,
    @required int totalSteps,
    @required List<Exception> exceptions,
    T result,
  }) =>
      Failed(
        currentStep: currentStep,
        totalSteps: totalSteps,
        exceptions: exceptions,
        result: result,
      );
}

/// To define when an [Action] is pending to be executed.
class Pending<T> extends ActionState<T> {
  const Pending({
    int steps,
  }) : super._(
          currentStep: 0,
          totalSteps: steps,
          exceptionsEncountered: null,
          result: null,
        );

  @override
  String toString() => 'Action pending.';
}

/// To define when an [Action] is currently being executed.
class Executing<T> extends ActionState<T> {
  const Executing({
    @required int currentStep,
    @required int totalSteps,
    List<Exception> exceptions,
  })  : assert(currentStep != null),
        assert(totalSteps != null),
        super._(
          currentStep: currentStep,
          totalSteps: totalSteps,
          exceptionsEncountered: exceptions,
          result: null,
        );

  @override
  String toString() => 'Executing $currentStep of $totalSteps.';
}

/// To define when an [Action] has succesfully executed without encountering
/// any [Exception].
///
/// If one or more [Exception] has been encountered while executing, use
/// [CompletedWithExceptions] or [ActionState.completedWithExceptions]
/// to define the [ActionState].
class Completed<T> extends ActionState<T> {
  const Completed({
    int currentStep,
    @required int totalSteps,
    List<Exception> exceptions,
    T result,
  }) : super._(
          currentStep: currentStep ?? totalSteps,
          totalSteps: totalSteps,
          exceptionsEncountered: exceptions,
          result: result,
        );

  @override
  String toString() => 'Completed succesfully.';
}

/// To define when an [Action] has completed execution and has encountered
/// one or more [Exceptions] during execution.
///
/// If [Action] couldn't complete execution, use [Failed] or
/// [ActionState.failed] to define the [ActionState].
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

/// To define when an [Action] failed to complete execution.
class Failed<T> extends ActionState<T> {
  const Failed({
    @required int currentStep,
    @required int totalSteps,
    @required List<Exception> exceptions,
    T result,
  }) : super._(
          currentStep: currentStep,
          totalSteps: totalSteps,
          exceptionsEncountered: exceptions,
          result: result,
        );

  @override
  String toString() => 'Action failed.';
}
