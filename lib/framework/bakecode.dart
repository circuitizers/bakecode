import 'dart:async';
import 'package:bakecode/framework/action_state.dart';
import 'package:bakecode/framework/logger.dart';
import 'package:bakecode/framework/quantities.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class ServicePath extends Equatable {
  static const rootLevel = 'bakecode';

  final List<String> levels;

  String get path => '$rootLevel/${levels.join('/')}';

  const ServicePath(this.levels) : assert(levels != null);

  @override
  List<Object> get props => levels;

  @override
  String toString() => path;
}

abstract class Tool extends Equatable {
  ServicePath get path;

  @override
  List<Object> get props => [path];

  @override
  String toString() => '${idnetity.toolName} (Tool)';
}

class Dispenser extends Tool {
  @override
  String get name => 'Dispenser';

  Stream<ActionState> dispense() async* {
    /// ... perform hardware mqtt stuffs here..
  }
}

class RecipeBuildOwner {}

abstract class RecipeBuildTool {
  String get name;

  bool get available => true;
}

/// [Chef] is responsible for managing and handling the build pipeline of a
/// recipe.
class Chef {
  /// Initializes the chef
  void init() {}

  Future make(Recipe recipe, {Servings servings}) =>
      make(recipe, servings: servings);
}

abstract class BuildContext extends Loggable {
  Recipe recipe;
  Chef chef;

  @override
  String get label => 'BuildContext (${recipe.name})';
}

class FoodBuildContext extends BuildContext {
  @override
  Recipe recipe;

  @override
  Chef chef;

  FoodBuildContext({this.recipe, this.chef});

  DateTime buildStartDateTime;
  DateTime buildCompleteDateTime;
  DateTime expiryDateTime;
}

@immutable
class RecipeVersion {
  final DateTime publishedOn;

  const RecipeVersion({@required this.publishedOn})
      : assert(publishedOn != null);
}

abstract class Recipe extends Equatable with Loggable {
  final String name;
  final RecipeVersion version;
  Servings servings;

  Recipe({
    @required this.name,
    @required this.version,
    @required this.servings,
  })  : assert(name != null),
        assert(version != null),
        assert(servings != null);

  @override
  String get label => 'Recipe $name';

  @override
  List<Object> get props => [name, version];

  bool get canBuild => true;
  Future build(BuildContext context);
}

void make(Recipe recipe, [Servings servings]) {
  recipe.servings = servings ?? recipe.servings;

  if (recipe.canBuild) {
    // reserve tools to RecipeBuildContext

    BuildContext buildContext = FoodBuildContext();

    recipe.build(buildContext);
  }
}
