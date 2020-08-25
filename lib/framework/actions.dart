import 'package:meta/meta.dart';
import 'package:path/path.dart';

/// Defines an [Action] for a function with return type [T].
@immutable
class Action {
  /// Const constructor. This constructor enables subclasses to provide const
  /// constructors so that they can be used in const expressions.
  const Action(this.computation) : assert(computation != null);

  /// Creates a new [ActionContext] for [this] [Action].
  ActionContext createContext(ActionContext parent) =>
      ActionContext(this, parent: parent);

  /// The [computation] function to be performed.
  final Function(ActionContext context) computation;

  /// Perform the [action].
  Future perform(ActionContext context) async {
    /// Creates a child context from the passed parent action's context.
    context = createContext(context);

    context.state = Executing(currentStep: 1, totalSteps: 1);

    /// Performs the computation.
    await computation(context);

    context.state = Completed(totalSteps: 1);
  }
}

/// Abstract layer for implementing Action groups as an [Action].
abstract class MultipleActions extends Action {
  /// All the [Action]s of [this] Action group.
  final List<Action> actions;

  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  /// [actions] is an [Iterable<Action>] containing all the actions to be
  /// performed by the [actionHandler].
  const MultipleActions(this.actions) : super(null);
}

class SeriesActions extends MultipleActions {
  /// Provides an [Action] to execute multple [Action]s in series.
  SeriesActions({@required List<Action> actions}) : super(actions);

  @override
  Future perform(ActionContext context) async {
    context = createContext(context);

    for (var i = 0; i < actions.length; ++i) {
      context.state = Executing(currentStep: i, totalSteps: actions.length);
      await actions.elementAt(i).perform(context);
    }

    context.state = Completed(totalSteps: actions.length);
  }
}

class ParallelActions extends MultipleActions {
  /// Provides an [Action] to execute multple [Action]s in parallel.
  const ParallelActions({@required List<Action> actions}) : super(actions);

  @override
  Future perform(ActionContext context) async {
    context = createContext(context);

    await Future.wait([
      for (var i = 0; i < actions.length; ++i)
        actions
            .elementAt(i)
            .perform(context)
            .then((_) => context.state = Executing(
                  currentStep: context.state.currentStep + 1,
                  totalSteps: actions.length,
                ))
    ]);

    context.state = Completed(totalSteps: actions.length);
  }
}

/// Context for an [Action].
class ActionContext {
  /// The [Action] of [this] [ActionContext].
  final Action action;

  /// [ActionContext] of the parent of [action].
  final ActionContext parent;

  /// Creates a new [ActionContext] instance for an [Action].
  ActionContext(this.action, {this.parent});

  /// The current [state] of [this.action].
  ActionState state = Pending();

  /// Perform the action on [this] context.
  void perform() => action.perform(this);
}

/// [ActionState] contains information of the current state of an [Action].
@immutable
class ActionState {
  /// The current execution step position of an [Action].
  final int currentStep;

  /// Total number of steps to be executed by the [Action].
  final int totalSteps;

  /// Const constructor. This constructor enables subclasses to provide const
  /// constructors so that they can be used in const expressions.
  const ActionState._({
    @required this.currentStep,
    @required this.totalSteps,
  });

  /// To define when an [Action] is pending to be executed.
  factory ActionState.pending({int steps}) => Pending(steps: steps);

  /// To define when an [Action] is currently being executed.
  factory ActionState.executing({
    @required int currentStep,
    @required int totalSteps,
  }) =>
      Executing(
        currentStep: currentStep,
        totalSteps: totalSteps,
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
  }) =>
      Completed(
        currentStep: currentStep ?? totalSteps,
        totalSteps: totalSteps,
      );

  /// To define when an [Action] has completed execution and has encountered
  /// one or more [Exceptions] during execution.
  ///
  /// If [Action] couldn't complete execution, use [Failed] or
  /// [ActionState.failed] to define the [ActionState].
  factory ActionState.completedWithExceptions({
    int currentStep,
    @required int totalSteps,
  }) =>
      CompletedWithException(
        currentStep: currentStep ?? totalSteps,
        totalSteps: totalSteps,
      );

  /// To define when an [Action] failed to complete execution.
  factory ActionState.failed({
    @required int currentStep,
    @required int totalSteps,
  }) =>
      Failed(
        currentStep: currentStep,
        totalSteps: totalSteps,
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
  })  : assert(currentStep != null),
        assert(totalSteps != null),
        super._(
          currentStep: currentStep,
          totalSteps: totalSteps,
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
class Completed<T> extends ActionState {
  final T result;

  /// Const constructor. This constructor enables subclasses to provide const
  /// constructors so that they can be used in const expressions.
  const Completed({
    int currentStep,
    @required int totalSteps,
    this.result,
  }) : super._(
          currentStep: currentStep ?? totalSteps,
          totalSteps: totalSteps,
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
  /// Exception encountered when performing the action.
  final Exception exception;

  /// Const constructor. This constructor enables subclasses to provide const
  /// constructors so that they can be used in const expressions.
  const CompletedWithException({
    int currentStep,
    @required int totalSteps,
    @required this.exception,
    T result,
  }) : super(
          currentStep: currentStep ?? totalSteps,
          totalSteps: totalSteps,
          result: result,
        );

  @override
  String toString() => 'Completed w/ an exception.';
}

/// To define when an [Action] failed to complete execution.
class Failed extends ActionState {
  /// Const constructor. This constructor enables subclasses to provide const
  /// constructors so that they can be used in const expressions.
  const Failed({
    @required int currentStep,
    @required int totalSteps,
  }) : super._(
          currentStep: currentStep,
          totalSteps: totalSteps,
        );

  @override
  String toString() => 'Action failed.';
}
