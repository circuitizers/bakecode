import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';

@immutable
class MqttRuntime {
  /// Server host address of the MQTT Broker Serivce.
  static final String server = 'localhost';

  /// Port at which the MQTT Broker service is running.
  static final int port = 1883;

  /// MQTT Broker security, [username].
  static final String username = '';

  /// MQTT Broker security, [password].
  static final String password = '';

  /// MQTT Quality of Service level of all transactions.
  static final MqttQos _qos = MqttQos.atMostOnce;

  /// Current [connectionState] of [client].
  static MqttConnectionState connectionState = MqttConnectionState.disconnected;

  /// The [MqttClient] instance of this runtime.
  static final MqttClient client = MqttClient.withPort(server, 'bakecode', port)
    ..logging(on: false)
    ..keepAlivePeriod = 20
    ..autoReconnect = true
    ..onAutoReconnect = onAutoReconnect
    ..onConnected = onConnected
    ..onDisconnected = onDisconnected
    ..onSubscribed = onSubscribed
    ..onUnsubscribed = onUnsubscribed;

  /// Subscriptions and it's onMessageReceived callbacks.
  static final Map<String, List<void Function(String message)>>
      subscriptionCallbacks = {};

  /// Subscribes and binds the callback for onMessage for the particular topic.
  void addSubscription({
    @required String topic,
    @required List<void Function(String message)> onMessageCallbacks,
  }) {
    /// Appends [onMessageCallbacks] to existing callbacks of the specified
    /// topic.
    subscriptionCallbacks.containsKey(topic)
        ? subscriptionCallbacks[topic].addAll(onMessageCallbacks)
        : subscriptionCallbacks[topic] = onMessageCallbacks;

    /// subscribe [client] to the [topic].
    client.subscribe(topic, _qos);
  }

  /// Callback function when [client] gets connected to the broker.
  static void onConnected() {}

  /// Callback function when [client] automatically reconnects with the broker.
  static void onAutoReconnect() {}

  /// Callback function when [client] gets disconnected from the broker.
  static void onDisconnected() {}

  /// Callback function when [client] sucesfully subscribes to a topic.
  static void onSubscribed(String callback) {}

  /// Callback function when [client] sucesfully unsibscribes from a topic.
  static void onUnsubscribed(String callback) {}

  /// Connects the [MqttRuntime] [client] [instance] to the broker service.
  // TODO: implement loggin;
  static Future<void> connect() async {
    try {
      connectionState = MqttConnectionState.connecting;
      connectionState = (await client.connect()).state;
    } catch (e) {
      connectionState = MqttConnectionState.faulted;
    }
  }

  /// Private constructor
  MqttRuntime._() {
    /// Listen to client updates and implement callbacks to listeners.
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> data) =>
        subscriptionCallbacks[data[0].topic].forEach((fn) => fn(
            (MqttPublishPayload.bytesToStringAsString(
                (data[0].payload as MqttPublishMessage).payload.message)))));

    // connect();
  }

  /// The current [MqttRuntime] singleton instance.
  static final MqttRuntime instance = MqttRuntime._();

  /// Returns the [MqttRuntime] instance.
  factory MqttRuntime() => instance;
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
// client.updates.listen((List<MqttReceivedMessage<MqttMessage>> messages) =>
//     onMessageReceived(MqttPublishPayload.bytesToStringAsString(
//         (messages[0].payload as MqttPublishMessage).payload.message)));
//   }
// }
