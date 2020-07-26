import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// [ServicePath] identifies evrery bakecode services in MQTT protocol.
@immutable
class ServicePath extends Equatable {
  /// [levels] contains the level names to this service.
  final List<String> levels;

  /// [path] gives the actual path to this service.
  String get path => levels.join('/');

  /// Creates a [ServicePath] instance by providing the level names as List.
  /// The first item in [levels] should contain the most-parent level name, and
  /// last item should contain the most-child level name.
  const ServicePath(this.levels) : assert(levels != null);

  /// Returns a new [ServicePath] instance with a new child level appended to
  /// this instance.
  ServicePath child(String level) => ServicePath(levels..add(level));

  @override
  List<Object> get props => levels;

  /// returns the actual path to this service as [String].
  @override
  String toString() => path;
}
