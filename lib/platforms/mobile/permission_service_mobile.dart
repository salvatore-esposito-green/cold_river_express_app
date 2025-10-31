import 'package:cold_river_express_app/core/interfaces/permission_service_interface.dart';
import 'package:permission_handler/permission_handler.dart';

/// Implementazione mobile del servizio permessi
/// Utilizza permission_handler per Android/iOS
class PermissionServiceMobile implements PermissionServiceInterface {
  @override
  Future<bool> requestBluetoothPermissions() async {
    try {
      // Android 12+ richiede BLUETOOTH_SCAN e BLUETOOTH_CONNECT
      final bluetoothScanStatus = await Permission.bluetoothScan.request();
      final bluetoothConnectStatus = await Permission.bluetoothConnect.request();

      return bluetoothScanStatus.isGranted && bluetoothConnectStatus.isGranted;
    } catch (e) {
      // Su iOS o versioni Android più vecchie, alcuni permessi potrebbero non esistere
      return true; // Assume permessi garantiti per compatibilità
    }
  }

  @override
  Future<bool> hasBluetoothPermissions() async {
    try {
      final bluetoothScan = await Permission.bluetoothScan.status;
      final bluetoothConnect = await Permission.bluetoothConnect.status;

      return bluetoothScan.isGranted && bluetoothConnect.isGranted;
    } catch (e) {
      return true; // Assume permessi garantiti per compatibilità
    }
  }

  @override
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
