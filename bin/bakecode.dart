import 'dart:async';

import 'package:bakecode/src/framework.dart';
import 'package:bakecode/src/quantities.dart';
import 'package:bakecode/src/support.dart';

void main() => make(MyCoffee());

class MyCoffee extends Recipe {
  @override
  Servings get servings => super.servings;

  @override
  Future build(RecipeBuildContext context) async {
    final chef = context.chef;

    final boiledMilk = chef.make(BoiledMilk(), servings: Servings(1));
  }

  // Future build(RecipeBuilder builder) async {
  //   builder.setContainer(CoffeeCup());

  //   await Future.wait([
  //     builder.dispense(boiledMilk, quantity: Cups(0.1)),
  //     builder.dispense(Dispensable.FineSugar, quantity: Tablespoons(1.0)),
  //     builder.dispense(Dispensable.CoffeePowder, quantity: Teaspoon(2.0)),
  //   ]);

  //   builder.stir(stirSpeed: StirSpeed.Fast, duration: Duration(minutes: 1));
  //   builder.dispense(boiledMilk, quantity: Cups(0.9));
  //   builder.stir(stirSpeed: StirSpeed.Slow, duration: Duration(seconds: 10));

  //   return builder.content;
  // }
}

class BoiledMilk extends Recipe {
  @override
  Future build(RecipeBuildContext context) {
    using(() => context, perform: (cotext) {});
  }
}
