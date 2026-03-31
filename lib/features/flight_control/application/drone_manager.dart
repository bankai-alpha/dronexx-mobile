import 'dart:async';

import 'package:dronex/features/flight_control/domain/drone_connection.dart';

enum DroneConnectionType { wifi, bluetooth }

class DroneManager {
  DroneManager({required this.connection}) {
    _bindConnection(connection);
  }

  DroneConnection connection;

  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<String>? _telemetrySubscription;

  final _connectionStateController = StreamController<bool>.broadcast();
  final _telemetryController = StreamController<String>.broadcast();

  Stream<bool> get connectionState => _connectionStateController.stream;
  Stream<String> get telemetryStream => _telemetryController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void _bindConnection(DroneConnection connection) {
    _connectionSubscription?.cancel();
    _telemetrySubscription?.cancel();

    _connectionSubscription = connection.connectionStatus.listen((status) {
      _isConnected = status;
      _connectionStateController.add(status);
    });

    _telemetrySubscription = connection.telemetryStream.listen((telemetry) {
      _telemetryController.add(telemetry);
    });
  }

  Future<bool> connect(String targetAddress) async {
    final result = await connection.connect(targetAddress);
    print(
      'Connection attempt to $targetAddress: ${result ? "Success" : "Failure"}',
    );
    _isConnected = result;
    _connectionStateController.add(result);
    return result;
  }

  Future<void> disconnect() async {
    await connection.disconnect();
    _isConnected = false;
    _connectionStateController.add(false);
  }

  void setConnection(DroneConnection newConnection) {
    connection.disconnect();
    connection = newConnection;
    _bindConnection(newConnection);
  }

  void sendFlightCommand(
    double pitch,
    double roll,
    double yaw,
    double throttle,
  ) {
    connection.sendFlightCommand(pitch, roll, yaw, throttle);
  }

  void sendAction(String actionCode) {
    connection.sendAction(actionCode);
  }

  void dispose() {
    _connectionStateController.close();
    _telemetryController.close();
    _connectionSubscription?.cancel();
    _telemetrySubscription?.cancel();
  }
}
