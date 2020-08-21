import 'package:bakecode/framework/action_state.dart';
import 'package:meta/meta.dart';

Map<String, Action> _actions = {};

void addAction({
  @required String name,
  @required Action action,
}) {
  assert(name != null);
  assert(action != null);

  if (_actions.containsKey(name)) {
    throw Exception(
        "Another action '$name' already exists in the actions stack.");
  } else {
    _actions[name] = action;
  }

  if (_actions.containsKey(name)) _actions[name] = action;
}

abstract class Action {
  /// Name of the action.
  String get name;

  /// Creates a new [ActionContext] for [this] [Action].
  ActionContext createContext() => ActionContext(this);

  /// Performs the action.
  Stream<ActionState> perform({ActionContext context});
}
