import 'package:bakecode/framework/action_state.dart';
import 'package:bakecode/framework/bakecode.dart';
import 'package:bakecode/framework/quantities.dart';
import 'package:bakecode/hardware/dispenser.dart';

class MyCoffee extends Beverage {
  @override
  String get name => 'MyCoffee';

  @override
  Servings get servings => Servings(1);

  @override
  Duration get bestBefore => Duration(days: 1);

  /// =========================================================================
  ///
  /// Assume the following [Dispenser], [Mixer] and [Oven] are inherited from
  /// [Tool] class.
  ///
  /// The static getter [dispatchable] is implemented.
  /// In which class / layer do you think the [dispatchable] getter is
  /// implemented?
  final dispenser = Dispenser.dispatchable.first;

  ///
  /// =========================================================================

  @override
  Stream<ActionState> make() async* {
    yield dispenser as ActionState;
  }
}
