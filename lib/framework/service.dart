import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// [ServicePath] identifies evrery bakecode services in MQTT protocol.
@immutable
class ServicePath extends Equatable {
  /// [levels] contains the level names to this service.
  final List<String> _levels;

  /// returns the levels of this [ServicePath] as [List<String>].
  List<String> get levels => _levels;

  /// [path] gives the actual path to this service.
  String get path => levels.join('/');

  /// Creates a [ServicePath] instance by providing the level names as List.
  /// The first item in [levels] should contain the most-parent level name, and
  /// last item should contain the most-child level name.
  const ServicePath(List<String> levels)
      : assert(levels != null),
        _levels = levels;

  /// returns [true] if this is the most-parent / root service, else [false].
  bool get isRoot => this == root;

  int get depth => levels.length;

  /// gives the current service name.
  String get name => levels.last;

  /// Returns [ServicePath] of the most-parent / root service.
  ServicePath get root => ServicePath([levels.first]);

  /// Returns a new [ServicePath] instance with a new child level appended to
  /// this instance.
  ServicePath child(String level) => ServicePath(levels.toList()..add(level));

  /// Returns the parent [ServicePath] of this.
  ServicePath get parent =>
      isRoot ? this : ServicePath(levels.sublist(0, depth - 1));

  @override
  List<Object> get props => levels;

  /// returns the actual path to this service as [String].
  @override
  String toString() => path;
}
