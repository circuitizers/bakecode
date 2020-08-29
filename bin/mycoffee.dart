import 'package:bakecode/framework/bakecode.dart';

class RecipeBuilder extends Action<Stream<ActionState>> {
  RecipeBuilder(Action action) : super(null);
}

class MyCoffee extends Beverage {
  @override
  String get name => 'My Coffee';

  @override
  Servings get servings => Servings(1);

  @override
  Duration get bestBefore => Duration(days: 1);

  @override
  RecipeBuilder make() {
    return RecipeBuilder(null);
  }
}
