import 'package:logger/logger.dart';

abstract class Loggable {
  String get label;

  final _logger = Logger(printer: PrettyPrinter(printTime: true));

  void log(Level level, message, [error, StackTrace stackTrace]) {
    _logger.log(level, label);
    _logger.log(level, message);
  }
}
