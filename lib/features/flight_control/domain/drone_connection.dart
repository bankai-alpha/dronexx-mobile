import 'dart:async';

abstract class DroneConnection {
  // Connection management
  Future<bool> connect(String targetAddress);
  Future<void> disconnect();

  // Sending commands (Values from -1.0 to 1.0)
  void sendFlightCommand(
    double pitch,
    double roll,
    double yaw,
    double throttle,
  );
  void sendAction(String actionCode); // e.g., "TAKEOFF", "LAND"

  // Receiving data (Telemetry)
  Stream<String> get telemetryStream;

  // Connection status
  Stream<bool> get connectionStatus;
}
