import 'package:dronex/features/flight_control/application/drone_manager.dart';
import 'package:dronex/features/flight_control/infrastructure/wifi_connection.dart';
import 'package:dronex/features/flight_control/presentation/widgets/action_button.dart';
import 'package:dronex/features/flight_control/presentation/widgets/camera_view.dart';
import 'package:dronex/features/flight_control/presentation/widgets/connection_panel.dart';
import 'package:dronex/features/flight_control/presentation/widgets/telemetry_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class DroneControllerPage extends StatefulWidget {
  const DroneControllerPage({super.key});

  @override
  State<DroneControllerPage> createState() => _DroneControllerPageState();
}

class _DroneControllerPageState extends State<DroneControllerPage> {
  final DroneManager _droneManager = DroneManager(connection: WifiConnection());
  bool _isConnected = false;
  final String _flightMode = 'GPS HOLD';
  int _battery = 84;
  final int _satellites = 12;
  double _altitude = 14.5;
  final double _speed = 0.0;
  final DroneConnectionType _connectionType = DroneConnectionType.wifi;

  @override
  void initState() {
    super.initState();
    _droneManager.connectionState.listen((value) {
      setState(() => _isConnected = value);
    });
    _droneManager.telemetryStream.listen((line) {
      setState(() {
        // Keep the UI reactive with minimal state approximation
        if (line.contains('Battery')) {
          final extracted = RegExp(r'Battery (\d+)%').firstMatch(line);
          if (extracted != null) {
            _battery = int.tryParse(extracted.group(1) ?? '') ?? _battery;
          }
        }
        if (line.contains('ALT')) {
          final extracted = RegExp(r'ALT (\d+\.?\d*)m').firstMatch(line);
          if (extracted != null) {
            _altitude = double.tryParse(extracted.group(1) ?? '') ?? _altitude;
          }
        }
      });
    });

    // Default connection is Wi-Fi at 192.168.4.1 but user can change from UI.
    // _droneManager.connect(_targetController.text);
  }

  @override
  void dispose() {
    // _targetController.dispose();
    _droneManager.dispose();
    super.dispose();
  }

  void _onLeftJoystickMoved(StickDragDetails details) {
    if (!_isConnected) return;
    // y => throttle, x => yaw
    final throttle = details.y.clamp(-1.0, 1.0);
    final yaw = details.x.clamp(-1.0, 1.0);
    _droneManager.sendFlightCommand(0.0, 0.0, yaw, throttle);
  }

  void _onRightJoystickMoved(StickDragDetails details) {
    if (!_isConnected) return;
    // y => pitch, x => roll
    final pitch = details.y.clamp(-1.0, 1.0);
    final roll = details.x.clamp(-1.0, 1.0);
    _droneManager.sendFlightCommand(pitch, roll, 0.0, 0.0);
  }

  void _sendAction(String actionCode) {
    if (!_isConnected) return;
    _droneManager.sendAction(actionCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: CameraView()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // _buildConnectionPanel(),
                      _buildTopHUD(width),
                      _buildBottomControls(width),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHUD(double width) {
    final isNarrow = width < 650;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withAlpha(204), Colors.transparent],
        ),
      ),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildHudChip(Icons.flight, _flightMode, Colors.green),
                    _buildHudChip(
                      Icons.satellite_alt,
                      '$_satellites',
                      Colors.white,
                    ),
                    _buildHudChip(
                      Icons.battery_4_bar,
                      '$_battery%',
                      Colors.white,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => ConnectionPanel(
                        droneManager: _droneManager,
                        initialType: _connectionType,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isConnected
                          ? Colors.green.withAlpha(200)
                          : Colors.red.withAlpha(200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _isConnected ? 'Connected' : 'Disconnected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TelemetryCard(
                      label: 'ALT',
                      value: '${_altitude.toStringAsFixed(1)}m',
                    ),
                    TelemetryCard(
                      label: 'SPD',
                      value: '${_speed.toStringAsFixed(1)}m/s',
                    ),
                  ],
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildHudChip(Icons.flight, _flightMode, Colors.green),
                    const SizedBox(width: 12),
                    _buildHudChip(
                      Icons.satellite_alt,
                      '$_satellites',
                      Colors.white,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,

                      builder: (context) => Material(
                        child: ConnectionPanel(
                          droneManager: _droneManager,
                          initialType: _connectionType,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isConnected
                          ? Colors.green.withAlpha(200)
                          : Colors.red.withAlpha(200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _isConnected ? 'Connected' : 'Disconnected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    TelemetryCard(
                      label: 'ALT',
                      value: '${_altitude.toStringAsFixed(1)}m',
                    ),
                    const SizedBox(width: 24),
                    TelemetryCard(
                      label: 'SPD',
                      value: '${_speed.toStringAsFixed(1)}m/s',
                    ),
                  ],
                ),
                _buildHudChip(Icons.battery_4_bar, '$_battery%', Colors.white),
              ],
            ),
    );
  }

  Widget _buildBottomControls(double width) {
    final isNarrow = width < 760;
    final joystickSize = isNarrow ? 140.0 : 190.0;

    final actions = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(160),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          DroneActionButton(
            icon: Icons.power_settings_new,
            label: 'ARM',
            iconColor: Colors.redAccent,
            onPressed: () => _sendAction('ARM'),
          ),
          DroneActionButton(
            icon: Icons.flight_takeoff,
            label: 'TAKEOFF',
            iconColor: Colors.white,
            onPressed: () => _sendAction('TAKEOFF'),
          ),
          DroneActionButton(
            icon: Icons.home,
            label: 'RTH',
            iconColor: Colors.orangeAccent,
            onPressed: () => _sendAction('RTH'),
          ),
        ],
      ),
    );

    if (isNarrow) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: joystickSize,
                  height: joystickSize,
                  child: Joystick(
                    mode: JoystickMode.all,
                    listener: _onLeftJoystickMoved,
                  ),
                ),
                SizedBox(
                  width: joystickSize,
                  height: joystickSize,
                  child: Joystick(
                    mode: JoystickMode.all,
                    listener: _onRightJoystickMoved,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            actions,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: joystickSize,
            height: joystickSize,
            child: Joystick(
              mode: JoystickMode.all,
              listener: _onLeftJoystickMoved,
            ),
          ),
          actions,
          SizedBox(
            width: joystickSize,
            height: joystickSize,
            child: Joystick(
              mode: JoystickMode.all,
              listener: _onRightJoystickMoved,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHudChip(IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
