import 'package:flutter/material.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});
  @override
  Widget build(BuildContext context) {
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
}
