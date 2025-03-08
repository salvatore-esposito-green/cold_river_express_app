import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  static Future<void> requestBluetoothPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted) {
      if (kDebugMode) {
        print("Permesso BLUETOOTH_SCAN concesso");
      }
    } else {
      if (kDebugMode) {
        print("Permesso BLUETOOTH_SCAN negato");
      }
    }

    if (await Permission.bluetoothConnect.request().isGranted) {
      if (kDebugMode) {
        print("Permesso BLUETOOTH_CONNECT concesso");
      }
    } else {
      if (kDebugMode) {
        print("Permesso BLUETOOTH_CONNECT negato");
      }
    }
  }
}
