import 'dart:mirrors';

import 'package:logger/logger.dart';

class CustomLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}

class CustomLogPrinter extends LogPrinter {
  final dynamic classname;
  CustomLogPrinter(this.classname);

  @override
  List<String> log(LogEvent event) {
    var name = reflect(classname).reflectee.toString();
    return [
      '[${DateTime.now().toString().substring(0, 19)}] Recipe of ${reflect(name).reflectee.toString().substring(13, name.length - 1)} | ${event.message}'
    ];
  }
}

class Loggable {
  Logger log;
  void init(dynamic classname) {
    log = Logger(
      level: Level.verbose,
      filter: CustomLogFilter(),
      printer: CustomLogPrinter(classname),
    );
  }
}

class Recipe extends Loggable {}

class CoffeCup extends Recipe {
  CoffeCup() {
    init(this);
  }
}

void main() {
  Recipe recipe = CoffeCup();
  recipe.log.d('hi');
}
