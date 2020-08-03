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
  BakeCodeRuntime._();

  /// Provides the singleton instance of the [BakeCodeRuntime].
  static BakeCodeRuntime instance = BakeCodeRuntime._();

  /// returns the [BakeCodeRuntime] singleton instance upon constructing.
  factory BakeCodeRuntime() => instance;

  /// Provides access to the [MqttRuntime] instance.
  final mqtt = MqttRuntime.instance;

  /// BakeCode Runtime service path.
  ServicePath get servicePath => ServicePath(['bakecode-$hashCode']);
}

/// Provides an abstract layer for implementing BakeCode compatible services.
abstract class BakeCodeService {
  /// Provides access to the [BakeCodeRuntime] instance.
  BakeCodeRuntime get runtime => BakeCodeRuntime.instance;

  /// [BakeCode Runtime] service path.
  ServicePath get servicePath => runtime.servicePath;

  /// Default constructor of [BakeCodeService].
  BakeCodeService() {
    /// Makes subscription for this service.
    runtime.mqtt.addSubscription(
      topic: servicePath.path,
      onMessageCallbacks: [onMessage],
    );
  }

  /// Invoked when a new message is received on this service.
  /// Implements a callback. Must call super from every sub service.
  void onMessage(String message);

  /// Publish a message on this service.
  void publish(String messsage) =>
      runtime.mqtt.publishMessage(topic: servicePath.path, message: messsage);
}

/// A zone of [BakeCodeService]s to contain and manage all the tools.
class ToolsCollection extends BakeCodeService {
  /// Contains all [Tool]s.
  static final List<Tool> tools = [];

  @override
  @mustCallSuper
  void onMessage(String message) {
    print('$message');
  }

  /// [ServicePath] to the [ToolsCollection]
  @override
  ServicePath get servicePath => super.servicePath.child('tools');
}

/// Provides an abstract layer for implementing a BakeCode compatible [Tool].
abstract class Tool extends ToolsCollection {
  /// returns the name of the [Tool].
  String get name;

  Tool() {
    ToolsCollection.tools.add(this);
  }

  /// returns the current sessionID of the [Tool].
  ///
  /// sessionID is the [hashCode] of the [Tool] instance.
  String get sessionID => hashCode.toString();

  // void publish(String message) {
  //   mqttService.client.publishMessage(topic, qualityOfService, data)
  // }

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
  // ignore: override_on_non_overriding_member
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
  // ignore: override_on_non_overriding_member
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
