import 'package:logger/logger.dart';

class BakecodeLogger extends Logger {
  final String name;

  BakecodeLogger(this.name) : super(printer: PrettyPrinter(printTime: true));

  @override
  void log(Level level, message, [error, StackTrace stackTrace]) {
    super.log(level, '$name');
    super.log(level, message, error, stackTrace);
  }
}
