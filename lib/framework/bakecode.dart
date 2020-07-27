import 'dart:async';
import 'package:bakecode/framework/action_state.dart';
import 'package:bakecode/framework/logger.dart';
import 'package:bakecode/framework/mqtt.dart';
import 'package:bakecode/framework/quantities.dart';
import 'package:bakecode/framework/service.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Entry point of the BakeCode Runtime
class BakeCodeRuntime {
  /// Private Constructor for making runtime instance singleton.
  const BakeCodeRuntime._();

  /// Provides the singleton instance of the BakeCode Runtime.
  static const BakeCodeRuntime instance = BakeCodeRuntime._();

  factory BakeCodeRuntime() => instance;

  /// BakeCode Runtime service path.
  ServicePath get servicePath => ServicePath(['bakecode-$hashCode']);
}

/// Provides an abstract layer for implementing BakeCode compatible services.
abstract class BakeCodeService {
  /// Provides access to [BakeCodeRuntime] instance of the service.
  static BakeCodeRuntime get runtime => BakeCodeRuntime.instance;

  MQTTService mqttService;

  /// Constructor for [BakeCodeService] instance.
  BakeCodeService() {
    mqttService = MQTTService(servicePath);
  }

  /// [BakeCode Runtime] service path.
  ServicePath get servicePath => runtime.servicePath;
}

/// A zone of [BakeCodeService]s to contain and manage all the tools.
class ToolsCollection extends BakeCodeService {
  /// Contains all [Tool]s.
  static final List<Tool> tools = [];

  /// [ServicePath] to the [ToolsCollection]
  @override
  ServicePath get servicePath => super.servicePath.child('tools');
}

/// Provides an abstract layer for implementing a BakeCode compatible [Tool].
abstract class Tool extends ToolsCollection {
  /// returns the name of the [Tool].
  String get name;

  /// returns the current sessionID of the [Tool].
  ///
  /// sessionID is the [hashCode] of the [Tool] instance.
  String get sessionID => hashCode.toString();

  void publish(String message) {}

  @override
  ServicePath get servicePath => super.servicePath.child(name).child(sessionID);
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

abstract class Recipe extends Equatable {
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
