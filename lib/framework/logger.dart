import 'dart:mirrors';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class CustomLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}

class CustomLogPrinter extends LogPrinter {
  final dynamic reflectee;
  CustomLogPrinter(this.reflectee);

  @override
  List<String> log(LogEvent event) {
    var name = reflect(reflectee).reflectee.toString();
    return [
      '[${DateFormat(DateFormat.HOUR24_MINUTE_SECOND).format(DateTime.now())}] Recipe of ${reflect(name).reflectee.toString().substring(13, name.length - 1)} | ${event.message}'
    ];
  }
}

class Loggable {
  Logger log;
  Loggable() {
    log = Logger(
      level: Level.verbose,
      filter: CustomLogFilter(),
      printer: CustomLogPrinter(this),
    );
  }
}

class Recipe extends Loggable {}

class CoffeCup extends Recipe {}

void main() {
  Recipe recipe = CoffeCup();
  recipe.log.d('hi');
}
