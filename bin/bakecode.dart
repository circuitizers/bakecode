import 'dart:async';

import 'package:bakecode/src/framework.dart';
import 'package:bakecode/src/quantities.dart';

void main() => make(MyCoffee());

class MyCoffee extends Recipe {
  @override
  Servings get servings => super.servings;

  @override
  Future build(RecipeBuildContext context) async {}
}
