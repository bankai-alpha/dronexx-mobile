import 'package:dronex/features/flight_control/application/drone_manager.dart';
import 'package:dronex/features/flight_control/infrastructure/bluetooth_connection.dart';
import 'package:dronex/features/flight_control/infrastructure/wifi_connection.dart';
import 'package:flutter/material.dart';

class ConnectionPanel extends StatefulWidget {
  final DroneManager droneManager;
  final DroneConnectionType initialType;
  const ConnectionPanel({
    super.key,
    required this.droneManager,
    required this.initialType,
  });

  @override
  State<ConnectionPanel> createState() => _ConnectionPanelState();
}

class _ConnectionPanelState extends State<ConnectionPanel> {
  late DroneConnectionType _connectionType;
  final TextEditingController _targetController = TextEditingController();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectionType = widget.initialType;
    _targetController.text = _connectionType == DroneConnectionType.wifi
        ? '192.168.4.1'
        : 'DroneBLE';

    widget.droneManager.connectionState.listen((status) {
      if (mounted) {
        setState(() => _isConnected = status);
      }
    });

    _isConnected = widget.droneManager.isConnected;
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final target = _targetController.text.trim();
    if (target.isEmpty) return;

    final success = await widget.droneManager.connect(target);
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to drone')),
      );
    }
  }

  Future<void> _disconnect() async {
    await widget.droneManager.disconnect();
  }

  void _switchConnection(DroneConnectionType type) {
    if (_connectionType == type) return;

    setState(() {
      _connectionType = type;
      widget.droneManager.setConnection(
        type == DroneConnectionType.wifi
            ? WifiConnection()
            : BluetoothConnection(deviceName: 'DroneBLE'),
      );
      _targetController.text = type == DroneConnectionType.wifi
          ? '192.168.4.1'
          : 'DroneBLE';
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connection',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ToggleButtons(
            isSelected: [
              _connectionType == DroneConnectionType.wifi,
              _connectionType == DroneConnectionType.bluetooth,
            ],
            onPressed: (index) {
              _switchConnection(
                index == 0
                    ? DroneConnectionType.wifi
                    : DroneConnectionType.bluetooth,
              );
            },
            color: Colors.white70,
            selectedColor: Colors.white,
            fillColor: Colors.blueAccent.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Wi-Fi'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Bluetooth'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _targetController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white12,
              hintText: _connectionType == DroneConnectionType.wifi
                  ? '192.168.4.1'
                  : 'Drone BLE device ID',
              hintStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white38),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isConnected ? null : _connect,
                  child: const Text('Connect'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isConnected ? _disconnect : null,
                  child: const Text('Disconnect'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isConnected ? 'Status: Connected' : 'Status: Disconnected',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
