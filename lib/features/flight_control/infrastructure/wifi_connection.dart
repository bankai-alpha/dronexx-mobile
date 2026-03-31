import 'dart:async';
import 'dart:io';
import 'package:dronex/features/flight_control/domain/drone_connection.dart';

class WifiConnection implements DroneConnection {
  RawDatagramSocket? _udpSocket;
  InternetAddress? _droneAddress;
  final int _port = 4210;

  final _connectionStatusController = StreamController<bool>.broadcast();
  final _telemetryController = StreamController<String>.broadcast();

  bool _isConnected = false;
  Timer? _watchdogTimer;

  @override
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  @override
  Stream<String> get telemetryStream => _telemetryController.stream;

  void _resetWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(const Duration(seconds: 3), () {
      if (_isConnected) {
        print("Watchdog Timeout: Lost connection to drone!");
        disconnect(); // Auto-disconnect if 3 seconds pass with no data
      }
    });
  }

  @override
  Future<bool> connect(String ipAddress) async {
    try {
      _droneAddress = InternetAddress(ipAddress);

      // Close existing socket if we are reconnecting
      _udpSocket?.close();
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

      Completer<bool> connectionCompleter = Completer<bool>();

      // 1. Start listening for the ESP32's reply
      _udpSocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = _udpSocket!.receive();
          if (dg != null) {
            String msg = String.fromCharCodes(dg.data).trim();

            _resetWatchdog();

            // 2. Did we get the handshake response?
            if (msg == "CONNECTED" && !connectionCompleter.isCompleted) {
              _isConnected = true;
              _connectionStatusController.add(true);
              connectionCompleter.complete(true);
            } else if (_isConnected) {
              // If already connected, treat incoming data as telemetry
              _telemetryController.add(msg);
            }
          }
        }
      });

      // 3. Send the Handshake request to the ESP32
      _udpSocket!.send('CONNECT'.codeUnits, _droneAddress!, _port);

      // 4. Set a 2-second timeout. If the ESP32 doesn't reply, fail gracefully.
      Future.delayed(const Duration(seconds: 2), () {
        if (!connectionCompleter.isCompleted) {
          _isConnected = false;
          _connectionStatusController.add(false);
          _udpSocket?.close();
          connectionCompleter.complete(false);
        }
      });

      return connectionCompleter.future;
    } catch (e) {
      _isConnected = false;
      _connectionStatusController.add(false);
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    _watchdogTimer?.cancel();
    _udpSocket?.close();
    _udpSocket = null;
    _droneAddress = null;
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
    if (!_isConnected || _udpSocket == null || _droneAddress == null) return;
    String command =
        '${pitch.toStringAsFixed(2)},${roll.toStringAsFixed(2)},${yaw.toStringAsFixed(2)},${throttle.toStringAsFixed(2)}';
    _udpSocket!.send(command.codeUnits, _droneAddress!, _port);
  }

  @override
  void sendAction(String actionCode) {
    if (!_isConnected || _udpSocket == null || _droneAddress == null) return;
    String command = 'ACTION:$actionCode';
    _udpSocket!.send(command.codeUnits, _droneAddress!, _port);
  }
}
