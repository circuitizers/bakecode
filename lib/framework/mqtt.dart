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
  final MqttQos _qos = MqttQos.atMostOnce;

  /// Current [connectionState] of [client].
  static MqttConnectionState connectionState = MqttConnectionState.disconnected;

  /// The [MqttClient] instance of this runtime.
  static final MqttClient client = MqttClient.withPort(server, 'bakecode', port)
    ..logging(on: true)
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

  /// Subscribes and adds callback.
  void addSubscription(String topic,
      {@required void Function(String message) onMessage}) {
    /// Appends [onMessageCallback] to callback stack of the topic.
    subscriptionCallbacks.containsKey(topic)
        ? subscriptionCallbacks[topic].add(onMessage)
        : subscriptionCallbacks[topic] = [onMessage];

    /// subscribe [client] to the [topic].
    client.subscribe(topic, _qos);
  }

  /// Publish [message] to [topic].
  void publishMessage({
    @required String topic,
    @required String message,
  }) =>
      client.publishMessage(topic, _qos,
          (MqttClientPayloadBuilder()..addString(message)).payload);

  /// Callback function when [client] gets connected to the broker.
  static void onConnected() {
    connectionState = MqttConnectionState.connected;
  }

  /// Callback function when [client] automatically tries to reconnects with
  /// the broker.
  /// Callback is invoked before auto reconnect is performed.
  static void onAutoReconnect() {
    connectionState = MqttConnectionState.connecting;
  }

  /// Callback function when [client] gets disconnected from the broker.
  static void onDisconnected() {
    connectionState = MqttConnectionState.disconnected;
  }

  /// Callback function when [client] sucesfully subscribes to a topic.
  /// TODO: implement [onSubscribed]
  static void onSubscribed(String callback) {}

  /// Callback function when [client] sucesfully unsibscribes from a topic.
  /// TODO: implement [onUnsubcribed]
  static void onUnsubscribed(String callback) {}

  /// Connects the [MqttRuntime] [client] [instance] to the broker service.
  // TODO: implement loggin;
  static Future<void> connect() async {
    try {
      connectionState = MqttConnectionState.connecting;
      connectionState = (await client.connect(username, password)).state;
    } catch (e) {
      connectionState = MqttConnectionState.faulted;
    }
  }

  /// Private constructor
  MqttRuntime._() {
    /// Listen to client updates and implement callbacks to listeners.
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> data) {
      data[0] as MqttPayload;
      subscriptionCallbacks[data[0].topic].forEach((fn) => fn(
          (AsciiPayloadConverter().convertFromBytes(
              (data[0].payload as MqttPublishMessage).payload.message))));
    });
    connect();
  }

  /// The current [MqttRuntime] singleton instance.
  static final MqttRuntime instance = MqttRuntime._();

  /// Returns the [MqttRuntime] instance.
  factory MqttRuntime() => instance;
}
