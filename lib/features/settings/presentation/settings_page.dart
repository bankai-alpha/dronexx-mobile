import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text('Connection Type'),
            subtitle: Text('Wi-Fi / Bluetooth'),
          ),
          ListTile(title: Text('Telemetry Rate'), subtitle: Text('10 Hz')),
          ListTile(
            title: Text('Flight Mode'),
            subtitle: Text('GPS Hold / Manual'),
          ),
        ],
      ),
    );
  }
}
