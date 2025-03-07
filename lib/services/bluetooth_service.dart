import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  static Future<void> requestBluetoothPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted) {
      print("Permesso BLUETOOTH_SCAN concesso");
    } else {
      print("Permesso BLUETOOTH_SCAN negato");
    }

    if (await Permission.bluetoothConnect.request().isGranted) {
      print("Permesso BLUETOOTH_CONNECT concesso");
    } else {
      print("Permesso BLUETOOTH_CONNECT negato");
    }
  }
}
