// recipe prototype

abstract class RitEspressoCoffee extends Recipe {
  @override
  Future<Null> build(BuildContext context) {
    context.chef
      ..dispense();
      ..stir();
      ..dispense();
      ..dispense();
      ..dispense();
      ..dispense();
      ..dispense();
      ..dispense();
      ..dispense();
  }
}

class RitEspressoCoffee extends Recipe {
  final _customCheckpoint = CheckPoint();

  @override
  Future build(context) {
    context.chef
      ..dispense();
      ..stir();
      ..shake();
      ..heat(profile: CustomHeatProfile());
      ..cool();
      ..heavymix();
    
    context.chef.build(CustomRecipeClass(), serving: Serving(10));

    context.chef
      ..checkpoint(id: _customCheckpoint);
      ..cut();
      ..fry();
      ..repeat(from: _customCheckpoint, condition: ());

      ..loop(until: 3, (context) {
        
      });
  }
}

abstract class RitBlackTea extends Recipe {
  @override
  Future<Null> build(BuildContext context) {
    context.chef
      ..dispense();
      ..stir();
      ..dispense();
      ..dispense();
      ..dispense();
  }
}

main() {
  make(RitEspressoCoffee(), Serving(10)).then(() =>
    make(RitBlackTea(), Serving(10)).then(() =>
      make(RitBlackTea(), Serving(10)),
    ),
  );
};


