import 'dart:async';

import 'package:bakecode/src/framework.dart';

void main() => make(MyCoffee());

class MyCoffee extends Recipe {
  Dispensable boiledMilk;

  void init() {
    boiledMilk = Dispensable.prepare(
      using: FreshMilk(quantity: Quantity(litres: 1)),
      build: (builder) => builder.boil(
          heatLevel: HeatLevel.Medium, maxDuration: Duration(minutes: 10)),
      dispenser: HeatedDispenser(
          temperature: Temperature.celsius(80),
          maxDeviation: Temperature.celsius(10)),
    );
  }

  Future<Beverage> build(RecipeBuilder builder) async {
    builder.setContainer(CoffeeCup());

    await Future.wait([
      builder.dispense(boiledMilk, quantity: Cups(0.1)),
      builder.dispense(Dispensable.FineSugar, quantity: Tablespoons(1.0)),
      builder.dispense(Dispensable.CoffeePowder, quantity: Teaspoon(2.0)),
    ]);

    builder.stir(stirSpeed: StirSpeed.Fast, duration: Duration(minutes: 1));
    builder.dispense(boiledMilk, quantity: Cups(0.9));
    builder.stir(stirSpeed: StirSpeed.Slow, duration: Duration(seconds: 10));

    return builder.content;
  }
}
