import 'dart:async';
import 'package:bakecode/framework/action_state.dart';
import 'package:bakecode/framework/logger.dart';
import 'package:bakecode/framework/quantities.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// [ServicePath] identifies all bakecode service in MQTT protocol.
@immutable
class ServicePath extends Equatable {
  /// [rootLevel] stores the root level name.
  static const rootLevel = 'bakecode';

  /// [levels] contains the level names to this service.
  final List<String> levels;

  /// [path] gives the actual path to this bakecode service.
  String get path => '$rootLevel/${levels.join('/')}';

  /// Creates a [ServicePath] instance by providing the level names as List.
  /// The first item in [levels] should contain the most-parent level name, and
  /// last item should contain the most-child level name.
  const ServicePath(this.levels) : assert(levels != null);

  /// Returns a new [ServicePath] instance with a new child level appended to
  /// this instance.
  ServicePath child(String level) => ServicePath(levels..add(level));

  @override
  List<Object> get props => levels;

  /// returns the actual path to this bakecode service as [String].
  @override
  String toString() => path;
}

abstract class BakeCodeService extends Equatable {
  ServicePath get servicePath;

  @override
  List<Object> get props => [servicePath];

  @override
  // TODO: implement stringify
  bool get stringify => super.stringify;
}

class Tool extends BakeCodeService {
  @override
  // TODO: implement servicePath
  ServicePath get servicePath => ServicePath(['tools']);
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
