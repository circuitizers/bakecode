import 'package:logger/logger.dart';

// class _LabeledLogger extends Logger {
//   String label = '';
//   _LabeledLogger(this.label) : super(printer: PrettyPrinter(printTime: true));

//   @override
//   void log(Level level, message, [error, StackTrace stackTrace]) {
//     super.log(level, '${label}');
//     super.log(level, message, error, stackTrace);
//   }
// }

abstract class Loggable {
  String get label;

  final _logger = Logger(printer: PrettyPrinter(printTime: true));

  void log(Level level, message, [error, StackTrace stackTrace]) {
    _logger.log(level, label);
    _logger.log(level, message);
  }
}
