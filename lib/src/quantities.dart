import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Servings extends Equatable {
  final double value;

  const Servings(this.value) : assert(value != null);

  @override
  List<Object> get props => [value];
}

class Volume extends Equatable {
  final cubicMeter;

  const Volume({@required this.cubicMeter}) : assert(cubicMeter != null);

  @override
  List<Object> get props => [cubicMeter];
}

class Teaspoons extends Volume {
  const Teaspoons(double value) : super(cubicMeter: value / 202884);
}

class Tablespoons extends Teaspoons {
  const Tablespoons(double value) : super(value * 3);
}
