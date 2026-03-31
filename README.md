# DroneX Mobile Controller 🚁

A sleek, cross-platform Flutter application designed to act as the primary remote control and telemetry dashboard for ESP32-based custom drones.

## Features

* **Dual Network Strategy:** Seamlessly switch between Wi-Fi (UDP for low-latency flight control) and Bluetooth Low Energy (BLE).
* **Two-Way UDP Handshake:** Ensures a verified connection before unlocking flight controls.
* **Smart Watchdog Timer:** Automatically disconnects the UI if telemetry from the drone is lost for more than 3 seconds.
* **Ergonomic UI:** Landscape-locked layout featuring dual virtual joysticks (`flutter_joystick`) and a real-time dark-mode telemetry dashboard.
* **Clean Architecture:** Feature-first folder structure separating UI presentation from the messy network infrastructure.

## Architecture & Folder Structure

This project follows strict Clean Architecture principles to ensure scalability:

```text
lib/
├── core/                   # Shared themes, constants, and utilities
├── features/
│   └── flight_control/     # Core drone interaction feature
│       ├── application/    # DroneManager (State management & connection routing)
│       ├── domain/         # DroneConnection (Abstract interface/contract)
│       ├── infrastructure/ # WifiConnection (UDP) & BluetoothConnection (BLE)
│       └── presentation/   # UI components (Joysticks, Telemetry HUD, Dashboards)
└── main.dart