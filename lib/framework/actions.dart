import 'package:meta/meta.dart';

/// Defines an [Action] for a function with return type [T].
@immutable
class Action<T> {
  /// Const constructor. This constructor enables subclasses to provide const
  /// constructors so that they can be used in const expressions.
  /// [T] is the return type of the [action] function.
  const Action({
    @required T Function(ActionContext context) action,
  })  : assert(action != null),
        _performAction = action;

  /// Creates a new [ActionContext] for [this] [Action].
  /// Optionally pass [parentContext] if the context to be created has a parent.
  ActionContext createContext() => ActionContext(this);

  /// The [action] function.
  final T Function(ActionContext context) _performAction;

  /// Perform the [action].
  Stream<ActionState> perform({@required ActionContext context}) async* {
    yield Executing(currentStep: 1, totalSteps: 1);
    await _performAction(context);
    yield Completed(totalSteps: 1);
  }
}

/// Abstract layer for implementing Action groups as an [Action].
abstract class MultipleActions extends Action {
  /// All the [Action]s of [this] Action group.
  final List<Action> actions;

  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const MultipleActions(this.actions);
}

class SeriesActions extends MultipleActions {
  final bool terminateOnError;

  /// Provides an [Action] to execute multple [Action]s in series / chain.
  /// [bool] [terminateOnError] parameter provides option to skip execution
  /// of rest of the [actions] on error.
  const SeriesActions({
    @required List<Action> actions,
    this.terminateOnError = false,
  }) : super(actions);

  @override
  Stream<ActionState> perform({ActionContext context}) async* {
    var steps = actions.length;

    yield Executing(currentStep: 0, totalSteps: steps);

    for (var i = 0; i < steps; ++i) {
      yield Executing(currentStep: i, totalSteps: steps);

      var caughtError = false;

      await actions.elementAt(i).perform(context: context).listen(
            (event) {},
            onError: () => caughtError = true,
          );

      if (terminateOnError & caughtError) break;
    }

    yield Completed(totalSteps: steps);
  }
}

class ParallelActions extends MultipleActions {
  const ParallelActions({
    @required List<Action> actions,
  }) : super(actions);

  @override
  Stream<ActionState> perform({ActionContext context}) async* {
    var steps = actions.length;

    yield Executing(currentStep: 0, totalSteps: steps);

    for (var i = 0; i < steps; ++i) {
      yield Executing(currentStep: i, totalSteps: steps);

      var errorCaught = false;

      await actions.elementAt(i).perform(context: context).listen(
            (event) {},
            onError: () => errorCaught = true,
          );

      if (errorCaught) break;
    }

    yield Completed(totalSteps: steps);
  }
}

/// Context for an [Action].
class ActionContext {
  /// The [Action] of [this] [ActionContext].
  final Action action;

  /// Creates a new [ActionContext] instance for an [Action].
  ActionContext(this.action);

  /// The current [state] of [this.action].
  ActionState state = Pending();

  /// Update the [state] of execution of [action].
  // void _updateState(ActionState _state) => state = _state;

  /// Perform the action on [this] context.
  void perform() {
    action.perform(context: this).listen((_state) => state = _state);
  }
}

/// [ActionState] contains information of the current state of an [Action].
@immutable
class ActionState {
  /// The current execution step position of an [Action].
  final int currentStep;

  /// Total number of steps to be executed by the [Action].
  final int totalSteps;

  /// All exceptions encountered while executing the steps.
  final List<Exception> exceptionsEncountered;

  /// Const constructor. This constructor enables subclasses to provide const
  /// constructors so that they can be used in const expressions.
  const ActionState._({
    @required this.currentStep,
    @required this.totalSteps,
    @required this.exceptionsEncountered,
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
  }) =>
      Completed(
        currentStep: currentStep ?? totalSteps,
        totalSteps: totalSteps,
        exceptions: exceptions,
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
  }) =>
      CompletedWithException(
        currentStep: currentStep ?? totalSteps,
        totalSteps: totalSteps,
        exceptions: exceptions,
      );

  /// To define when an [Action] failed to complete execution.
  factory ActionState.failed({
    @required int currentStep,
    @required int totalSteps,
    @required List<Exception> exceptions,
  }) =>
      Failed(
        currentStep: currentStep,
        totalSteps: totalSteps,
        exceptions: exceptions,
      );
}

/// To define when an [Action] is pending to be executed.
class Pending extends ActionState {
  /// Const constructor. This constructor enables subclasses to provide const
  /// constructors so that they can be used in const expressions.
  const Pending({
    int steps,
  }) : super._(
          currentStep: 0,
          totalSteps: steps,
          exceptionsEncountered: null,
        );

  @override
  String toString() => 'Action pending.';
}

/// To define when an [Action] is currently being executed.
class Executing extends ActionState {
  /// Const constructor. This constructor enables subclasses to provide const
  /// constructors so that they can be used in const expressions.
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
class Completed extends ActionState {
  /// Const constructor. This constructor enables subclasses to provide const
  /// constructors so that they can be used in const expressions.
  const Completed({
    int currentStep,
    @required int totalSteps,
    List<Exception> exceptions,
  }) : super._(
          currentStep: currentStep ?? totalSteps,
          totalSteps: totalSteps,
          exceptionsEncountered: exceptions,
        );

  @override
  String toString() => 'Completed succesfully.';
}

/// To define when an [Action] has completed execution and has encountered
/// one or more [Exceptions] during execution.
///
/// If [Action] couldn't complete execution, use [Failed] or
/// [ActionState.failed] to define the [ActionState].
class CompletedWithException extends Completed {
  /// Const constructor. This constructor enables subclasses to provide const
  /// constructors so that they can be used in const expressions.
  const CompletedWithException({
    int currentStep,
    @required int totalSteps,
    @required List<Exception> exceptions,
  }) : super(
          currentStep: currentStep ?? totalSteps,
          totalSteps: totalSteps,
          exceptions: exceptions,
        );

  @override
  String toString() =>
      'Completed w/ ${exceptionsEncountered.length} exceptions.';
}

/// To define when an [Action] failed to complete execution.
class Failed extends ActionState {
  /// Const constructor. This constructor enables subclasses to provide const
  /// constructors so that they can be used in const expressions.
  const Failed({
    @required int currentStep,
    @required int totalSteps,
    @required List<Exception> exceptions,
  }) : super._(
          currentStep: currentStep,
          totalSteps: totalSteps,
          exceptionsEncountered: exceptions,
        );

  @override
  String toString() => 'Action failed.';
}
