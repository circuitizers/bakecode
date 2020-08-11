import 'dart:async';
import 'package:bakecode/framework/action_state.dart';
import 'package:bakecode/framework/logger.dart';
import 'package:bakecode/framework/mqtt.dart';
import 'package:bakecode/framework/quantities.dart';
import 'package:bakecode/framework/service.dart';
import 'package:meta/meta.dart';

/// [BakeCodeRuntime] singleton service.
class BakeCodeRuntime {
  BakeCodeRuntime._();

  /// [BakeCodeRuntime] singleton service instance.
  static BakeCodeRuntime instance = BakeCodeRuntime._();

  /// [MqttRuntime] service instance.
  final mqtt = MqttRuntime.instance;

  /// [BakeCodeRuntime]'s [ServicePath].
  ServicePath get servicePath => ServicePath(['bakecode-$hashCode']);
}

/// [BakeCodeSerice] abstract layer.
abstract class BakeCodeService {
  /// [BakeCodeRuntime] service instance.
  BakeCodeRuntime get runtime => BakeCodeRuntime.instance;

  /// [ServicePath] of [this] [BakeCodeService].
  ServicePath get servicePath => runtime.servicePath;

  BakeCodeService() {
    /// Subscribes and implements callbacks for using mqtt service.
    runtime.mqtt.addSubscription(servicePath.path, onMessage: onMessage);
  }

  /// [onMessage] callback abstract implementation.
  /// Override and implement the handler.
  void onMessage(String message);

  /// Publish a [message] on [this] [BakeCodeService].
  void publish(String messsage) =>
      runtime.mqtt.publishMessage(topic: servicePath.path, message: messsage);
}

/// [ToolsCollection] is a [BakeCodeService] that handles all the associated
/// [Tool]s in this runtime. [ToolsCollection] is a singleton service.
@sealed
class ToolsCollection extends BakeCodeService {
  ToolsCollection._();

  /// [Tools] singleton service instance.
  static final ToolsCollection instance = ToolsCollection._();

  factory ToolsCollection() => instance;

  /// A map of tool name and iall session instances.
  /// Map<Name, Map<SessionID, Tool>.
  static final Map<String, Map<String, Tool>> tools = {};

  void toolMessage({@required Tool tool, @required String message}) {
    tool.isOnline = true;

    message = message.toLowerCase();
  }

  @override
  void onMessage(String message) {
    // filter tool message and invoke toolMessage.
  }

  /// [Tools]'s [ServicePath].
  @override
  ServicePath get servicePath => super.servicePath.child('tools');
}

/// [Tool] abstact layer.
abstract class Tool extends BakeCodeService {
  bool isOnline = false;
  bool isBusy = false;

  /// returns the name of the [Tool].
  String get name;

  /// [Tool] default constructor adds [this] to [ToolsCollection.tools].
  Tool() {
    ToolsCollection.tools[name][sessionID] = this;
  }

  /// returns the current sessionID of the [Tool].
  ///
  /// [sessionID] relies on the object's [hashCode].
  /// Hence, [hashCode] should not be overriden by sub-classes, unless
  /// safely handled.
  String get sessionID => hashCode.toString();

  /// [ServicePath] to this tool instance.
  @override
  ServicePath get servicePath =>
      ToolsCollection().servicePath.child(name).child(sessionID);
}

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

abstract class Recipe {
  String get name;
  RecipeVersion get version;
  Servings get servings;

  Stream<ActionState> build(BuildContext context);
}

void make(Recipe recipe) {
  recipe.build(null);
}

class Coffee implements Recipe {
  @override
  String get name => 'Coffee';

  @override
  RecipeVersion get version => RecipeVersion(publishedOn: DateTime.now());

  @override
  Servings get servings => Servings(1);

  @override
  Stream<ActionState> build(BuildContext context) async* {
    yield Executing();
  }
}
