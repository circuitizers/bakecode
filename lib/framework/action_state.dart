import 'package:bakecode/framework/bakecode.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ActionState {}

class Executing implements ActionState {
  final int current, of;

  const Executing(this.current, {@required this.of})
      : assert(current != null),
        assert(of != null);

  double get percentage => 100 * current / of;

  @override
  String toString() => 'executing $current of $of';
}

class Completed implements ActionState {
  const Completed();
}

class CompletedWithException extends Completed {
  final Exception exception;

  const CompletedWithException(this.exception);
}

class Failed implements ActionState {
  const Failed();
}
