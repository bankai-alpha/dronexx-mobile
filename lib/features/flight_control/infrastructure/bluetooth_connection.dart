import 'dart:async';

import 'package:dronex/features/flight_control/domain/drone_connection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothConnection implements DroneConnection {
  final String deviceName;
  BluetoothConnection({required this.deviceName});

  BluetoothDevice? _device;
  BluetoothCharacteristic? _commandCharacteristic;

  final _connectionStatusController = StreamController<bool>.broadcast();
  final _telemetryController = StreamController<String>.broadcast();

  bool _isConnected = false;

  @override
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  @override
  Stream<String> get telemetryStream => _telemetryController.stream;

  @override
  Future<bool> connect(String deviceId) async {
    // 1. Scan for the specific drone UUID
    // 2. Connect to the device
    // 3. Discover services and find the TX (transmit) characteristic

    await Future.delayed(const Duration(milliseconds: 500));
    _device = null;
    _isConnected = true;
    _connectionStatusController.add(true);

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }
      _telemetryController.add(
        'BT telemetry: RSSI ${-40 + DateTime.now().second % 10}dBm',
      );
    });

    return true;
  }

  @override
  Future<void> disconnect() async {
    await _device?.disconnect();
    _isConnected = false;
    _connectionStatusController.add(false);
  }

  @override
  void sendFlightCommand(
    double pitch,
    double roll,
    double yaw,
    double throttle,
  ) {
    if (!_isConnected || _commandCharacteristic == null) return;

    String command =
        '${pitch.toStringAsFixed(2)},${roll.toStringAsFixed(2)},${yaw.toStringAsFixed(2)},${throttle.toStringAsFixed(2)}';
    _commandCharacteristic!.write(command.codeUnits, withoutResponse: true);
  }

  @override
  void sendAction(String actionCode) {
    if (!_isConnected || _commandCharacteristic == null) return;

    String command = 'ACTION:$actionCode';
    _commandCharacteristic!.write(command.codeUnits, withoutResponse: true);
  }
}
