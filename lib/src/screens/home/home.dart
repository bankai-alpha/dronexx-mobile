import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

import '../../../features/flight_control/presentation/widgets/camera_view.dart';

class DroneControllerPage extends StatefulWidget {
  const DroneControllerPage({super.key});

  @override
  State<DroneControllerPage> createState() => _DroneControllerPageState();
}

class _DroneControllerPageState extends State<DroneControllerPage> {
  // Mock telemetry data
  final String _flightMode = "GPS HOLD";
  final int _battery = 84;
  final int _satellites = 12;
  final double _altitude = 14.5;
  final double _speed = 0.0;

  void _onLeftJoystickMoved(StickDragDetails details) {
    // Left Joystick: Throttle (Up/Down) & Yaw (Left/Right)
     print(details.x);
    print(details.y); 
  }

  void _onRightJoystickMoved(StickDragDetails details) {
    // Right Joystick: Pitch (Up/Down) & Roll (Left/Right)
    print(details.x); // For debugging - shows the joystick position
    print(details.y); // For debugging - shows the joystick position
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. The Background Video Feed (Placeholder)
          CameraView(),

          // 2. The HUD Overlay (Telemetry & Controls)
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // TOP: Telemetry Dashboard
                _buildTopHUD(),

                // BOTTOM: Joysticks and Action Buttons
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Components ---

  Widget _buildCameraFeedPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF1c1c1c)),
      child: Center(
        // Simple crosshair for the FPV feed
        child: Icon(Icons.add, color: Colors.white.withAlpha(77), size: 64),
      ),
    );
  }

  Widget _buildTopHUD() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withAlpha(204), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Mode & Status
          Row(
            children: [
              _buildHudChip(Icons.flight, _flightMode, Colors.green),
              const SizedBox(width: 12),
              _buildHudChip(Icons.satellite_alt, "$_satellites", Colors.white),
            ],
          ),

          // Center: Crucial Flight Data (Altitude & Speed)
          Row(
            children: [
              _buildTelemetryText("ALT", "${_altitude.toStringAsFixed(1)}m"),
              const SizedBox(width: 24),
              _buildTelemetryText("SPD", "${_speed.toStringAsFixed(1)}m/s"),
            ],
          ),

          // Right: Battery
          _buildHudChip(Icons.battery_4_bar, "$_battery%", Colors.white),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.only(left: 48.0, right: 48.0, bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left Joystick (Throttle / Yaw)
          Joystick(mode: JoystickMode.all, listener: _onLeftJoystickMoved),

          // Center Action Buttons
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(128),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildActionButton(
                  Icons.power_settings_new,
                  "ARM",
                  Colors.redAccent,
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  Icons.flight_takeoff,
                  "TAKEOFF",
                  Colors.white,
                ),
                const SizedBox(width: 16),
                _buildActionButton(Icons.home, "RTH", Colors.orangeAccent),
              ],
            ),
          ),

          // Right Joystick (Pitch / Roll)
          Joystick(mode: JoystickMode.all, listener: _onRightJoystickMoved),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

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

  Widget _buildTelemetryText(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white10,
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: () {
              // Handle action
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
