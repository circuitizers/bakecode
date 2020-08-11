import 'package:meta/meta.dart';

@immutable
abstract class ActionState {}

class Executing implements ActionState {
  final int current, of;

  const Executing({this.current = 0, this.of = 0})
      : assert(current != null),
        assert(of != null);

  double get percentage => of == 0 ? null : (100 * current / of);

  @override
  String toString() => 'ActionState::Executing [$current of $of]';
}

class Completed implements ActionState {
  const Completed();

  @override
  String toString() => 'ActionState::Completed';
}

class CompletedWithException extends Completed {
  final Exception exception;

  const CompletedWithException(this.exception);

  @override
  String toString() => 'ActionState::CompletedWithException [$exception]';
}

class Failed implements ActionState {
  final String reason;

  const Failed({this.reason = ''});

  @override
  String toString() => 'ActionState::Failed [$reason]';
}
