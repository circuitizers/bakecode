import 'dart:async';
import 'package:bakecode/framework/action_state.dart';
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

/// [BakeCodeService] abstract layer.
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

/// A collection group of [BakeCodeService]s as a [BakeCodeService].
abstract class BakeCodeServiceCollection<T> extends BakeCodeService {
  /// All the sub-services in [this] collection.
  final List<T> services = [];
}

/// [ToolsCollection] is a [BakeCodeService] that handles all the associated
/// [Tool]s in this runtime. [ToolsCollection] is a singleton service.
@sealed
class ToolsCollection extends BakeCodeServiceCollection<Tool> {
  ToolsCollection._();

  /// [Tools] singleton service instance.
  static final ToolsCollection instance = ToolsCollection._();

  factory ToolsCollection() => instance;

  /// All tools in [this] runtime.
  List<Tool> get tools => super.services;

  @override
  void onMessage(String message) {} // TODO: onMessage implementation pending.

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
    ToolsCollection.instance.tools.add(this);
  }

  /// returns the current sessionID of the [Tool].
  /// [sessionID] relies on the object's [hashCode].
  String get sessionID => hashCode.toString();

  /// [ServicePath] to this tool instance.
  @override
  ServicePath get servicePath =>
      ToolsCollection().servicePath.child(name).child(sessionID);
}

abstract class Recipe {
  String get name;
  Servings get servings;

  Stream<ActionState> make();
}

abstract class Beverage extends Recipe {}

abstract class Food extends Recipe {}

void make(Recipe recipe) {
  recipe.make();
}

// abstract class RecipeBuildTool {
//   String get name;

//   bool get available => true;
// }

// /// [Chef] is responsible for managing and handling the build pipeline of a
// /// recipe.
// class Chef {
//   /// Initializes the chef
//   void init() {}

//   Future make(Recipe recipe, {Servings servings}) =>
//       make(recipe, servings: servings);
// }

// abstract class BuildContext extends Loggable {
//   Recipe recipe;
//   Chef chef;

//   String get label => 'BuildContext (${recipe.name})';
// }

// class FoodBuildContext extends BuildContext {
//   @override
//   Recipe recipe;

//   @override
//   Chef chef;

//   FoodBuildContext({this.recipe, this.chef});

//   DateTime buildStartDateTime;
//   DateTime buildCompleteDateTime;
//   DateTime expiryDateTime;
// }

// @immutable
// class RecipeVersion {
//   final DateTime publishedOn;

//   const RecipeVersion({@required this.publishedOn})
//       : assert(publishedOn != null);
// }
