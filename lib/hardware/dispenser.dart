import 'package:bakecode/framework/bakecode.dart';

class Dispenser extends Tool {
  @override
  String get name => 'Dispenser';

  static List<Dispenser> get dispensers =>
      ToolsCollection.instance.tools.whereType<Dispenser>().toList();

  static List<Dispenser> get dispatchable => dispensers
      .where((dispenser) => dispenser.isOnline && !dispenser.isBusy)
      .toList();

  @override
  void onMessage(String message) {}
}
