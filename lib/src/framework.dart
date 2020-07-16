import 'dart:async';
import 'dart:html';
import 'package:bakecode/src/logger.dart';
import 'package:bakecode/src/quantities.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum RecipeState {
  Queued,
  Initializing,
  Initialized,
  Building,
  Built,
  Dispatching,
  Dispatched,
  Stacking,
  Stacked,
  Disposing,
  Disposed,
}

class RecipeContext {
  DateTime initializedOn;
  DateTime preparedOn;
  DateTime expiresOn;
}

class RecipeBuilder {
  RecipeContext context;
}

/// [RecipeVersion] holds the recipe version
@immutable
class RecipeVersion {
  final DateTime publishedOn;

  const RecipeVersion({@required this.publishedOn})
      : assert(publishedOn != null);

  @override
  String toString() => publishedOn.toIso8601String();
}

abstract class Recipe extends Equatable {
  final String name;
  final RecipeVersion version;
  final Servings servings;
  final Url url;
  final BakecodeLogger logger;

  Recipe({
    @required this.name,
    @required this.version,
    @required this.servings,
    this.url,
  })  : assert(name != null),
        assert(version != null),
        assert(servings != null),
        logger = BakecodeLogger("Recipe '$name'");

  @override
  List<Object> get props => [name, version, url];

  @mustCallSuper
  Future init() {
    logger.v('started init()');
  }

  @mustCallSuper
  Future build(RecipeBuilder builder) {
    logger.v('started build() w/ builder: ${builder.hashCode}');
  }

  Future dispatch() {
    logger.v('started dispatch()');
  }

  @mustCallSuper
  Future dispose() {
    logger.v('started dispose()');
  }
}

void make(Recipe recipe, Servings servings) {
  final log = BakecodeLogger('make ${recipe.name}');
  runZoned(
    () {
      recipe.init().then(
            (result) => recipe.build(builder).then(
                  (result) => recipe.dispatch().then(
                        (result) => recipe.dispose(),
                      ),
                ),
          );
    },
    onError: (error, stackTrace) =>
        log.e('runZoned::onError', error, stackTrace),
  );
}
