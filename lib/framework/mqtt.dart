import 'package:bakecode/framework/bakecode.dart';
import 'package:bakecode/framework/service.dart';
import 'package:equatable/equatable.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MQTTService extends Equatable {
  static String server = 'localhost';
  static int port = 1883;

  final MqttClient client;

  MQTTService(ServicePath identifier)
      : assert(identifier != null),
        client = MqttClient.withPort(server, identifier.path, port) {
    print(client.clientIdentifier);
  }

  @override
  List<Object> get props => [client.clientIdentifier];
}
