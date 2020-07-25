import 'dart:async';
import 'dart:html';
import 'package:bakecode/src/logger.dart';
import 'package:bakecode/src/quantities.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class ToolLocator {
  final String toolName;
  final String toolID;

  String get topic => '$toolName/$toolID';

  const ToolLocator({
    @required this.toolName,
    @required this.toolID,
  })  : assert(toolName != null),
        assert(toolID != null && toolID != '');
}

enum ActionState {
  CompletedSuccesfully,
  CompletedWithError,
  CouldNotComplete,
}

abstract class Action extends Equatable {
  String get name;

  String get description => '';

  Stream<ActionState> execute();

  @override
  List<Object> get props => [name];

  @override
  String toString() => 'Action[$name]';
}

class Dispense extends Action {
  @override
  String get name => 'Dispense';

  @override
  Stream<ActionState> execute() async* {}
}

abstract class Tool extends Equatable {
  String get name;

  Stream<ActionState> dispense() {
    yield ActionState.CouldNotComplete;
  }

  @override
  List<Object> get props => [name];

  @override
  String toString() => 'Tool[$name]';
}

class RecipeBuildOwner {}

abstract class RecipeBuildTool {
  String get name;

  bool get available => true;
}

/// [Chef] is responsible for managing and handling the build pipeline of a
/// recipe.
class Chef extends Useable<Chef> {
  /// Initializes the chef
  void init() {}

  Future make(Recipe recipe, {Servings servings}) =>
      make(recipe, servings: servings);
}

abstract class RecipeBuildContext extends Loggable {
  Recipe recipe;
  Chef chef;

  @override
  String get label => 'BuildContext (${recipe.name})';
}

class FoodBuildContext extends RecipeBuildContext {
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
  final Url url;

  Recipe({
    @required this.name,
    @required this.version,
    @required this.servings,
    this.url,
  })  : assert(name != null),
        assert(version != null),
        assert(servings != null);

  @override
  String get label => 'Recipe $name';

  @override
  List<Object> get props => [name, version, url];

  bool get canBuild => true;
  Future build(RecipeBuildContext context);
}

void make(Recipe recipe, [Servings servings]) {
  recipe.servings = servings ?? recipe.servings;

  if (recipe.canBuild) {
    // reserve tools to RecipeBuildContext

    RecipeBuildContext buildContext = FoodBuildContext();

    recipe.build(buildContext);
  }
}

// class RecipeBuilder {}

// class RecipeBuildContext {
//   DateTime initializedOn;
//   DateTime preparedOn;
//   DateTime expiresOn;
//   RecipeBuilder builder;
// }

// abstract class Action<T> {}

// abstract class Tool {
//   final String toolName;
//   final String path;

//   const Tool({this.toolName, this.path});
// }

// /// [RecipeVersion] holds the recipe version
// @immutable
// class RecipeVersion {
//   final DateTime publishedOn;

//   const RecipeVersion({@required this.publishedOn})
//       : assert(publishedOn != null);

//   @override
//   String toString() => publishedOn.toIso8601String();
// }

// abstract class Recipe extends Equatable {
//   final String name;
//   final RecipeVersion version;
//   final Servings servings;
//   final Url url;
//   final BakecodeLogger logger;

//   Recipe({
//     @required this.name,
//     @required this.version,
//     @required this.servings,
//     this.url,
//   })  : assert(name != null),
//         assert(version != null),
//         assert(servings != null),
//         logger = BakecodeLogger("Recipe '$name'");

//   @override
//   List<Object> get props => [name, version, url];

//   @mustCallSuper
//   Future init() {
//     logger.v('started init()');
//   }

//   @mustCallSuper
//   Future build(RecipeBuilder builder) {
//     logger.v('started build() w/ builder: ${builder.hashCode}');
//   }

//   Future dispatch() {
//     logger.v('started dispatch()');
//   }

//   @mustCallSuper
//   Future dispose() {
//     logger.v('started dispose()');
//   }
// }

// void make(Recipe recipe, Servings servings) {
//   final log = BakecodeLogger('make ${recipe.name}');
//   runZoned(
//     () {
//       recipe.init().then(
//             (result) => recipe.build(builder).then(
//                   (result) => recipe.dispatch().then(
//                         (result) => recipe.dispose(),
//                       ),
//                 ),
//           );
//     },
//     onError: (error, stackTrace) =>
//         log.e('runZoned::onError', error, stackTrace),
//   );
// }
