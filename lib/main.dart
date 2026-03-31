import 'package:dronex/core/theme/app_theme.dart';
import 'package:dronex/features/flight_control/presentation/pages/drone_controller_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DroneX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const DroneControllerPage(),
    );
  }
}
