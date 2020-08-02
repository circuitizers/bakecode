import 'package:bakecode/framework/service.dart';
import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';

@immutable
class MqttRuntime {
  static String server = 'localhost';
  static int port = 1883;
  static String username = '';
  static String password = '';

  static final MqttQos _qos = MqttQos.atMostOnce;
  static final MqttClient client =
      MqttClient.withPort(server, 'bakecode', port);

  static final List<ServicePath> _subscriptions = [];

  static void addSubscription(ServicePath servicePath) {
    if (!_subscriptions.contains(servicePath)) {
      // subscribe(servicePath);
      // bindListeners();
    }
  }

  MqttRuntime._() {
    // connect();
  }

  static final MqttRuntime instance = MqttRuntime._();
}

// abstract class MqttService extends Equatable {
//   static String server = 'localhost';
//   static int port = 1883;
//   static String username = '';
//   static String password = '';

//   final String _topic;
//   final MqttQos _qos = MqttQos.atMostOnce;
//   final MqttClient client;

//   MqttConnectionState connectionState = MqttConnectionState.disconnected;
//   MqttSubscriptionStatus subscriptionStatus = MqttSubscriptionStatus.pending;

//   MqttService(ServicePath identifier)
//       : _topic = identifier.path,
//         assert(identifier != null),
//         client = MqttClient.withPort(server, identifier.path, port) {
//     client.logging(on: false);
//     client.keepAlivePeriod = 20;
//     client.autoReconnect = true;
//     client.onConnected = onConnected;
//     client.onDisconnected = onDisconnected;

//     connect();
//     subscribe();
//   }

//   /// Callback function, when client disconnects.
//   void onDisconnected();

//   /// Callback function, when client connects.
//   void onConnected();

//   /// Callback function, when message is received.
//   void onMessageReceived(String message);

//   int publish(String message) =>
//       client.publishMessage(_topic, _qos, message as Uint8Buffer);

//   @override
//   List<Object> get props => [client.clientIdentifier];

//   Future<void> connect() async {
//     try {
//       connectionState = MqttConnectionState.connecting;
//       connectionState = (await client.connect(username, password)).state;
//     } catch (e) {
//       connectionState = MqttConnectionState.faulted;
//       client.disconnect();
//     }
//   }

//   void subscribe() {
//     client.subscribe(_topic, _qos);
//     client.updates.listen((List<MqttReceivedMessage<MqttMessage>> messages) =>
//         onMessageReceived(MqttPublishPayload.bytesToStringAsString(
//             (messages[0].payload as MqttPublishMessage).payload.message)));
//   }
// }
