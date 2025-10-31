import 'package:cold_river_express_app/core/interfaces/permission_service_interface.dart';

/// Implementazione web del servizio permessi
/// Sul web, i permessi sono gestiti automaticamente dal browser
class PermissionServiceWeb implements PermissionServiceInterface {
  @override
  Future<bool> requestBluetoothPermissions() async {
    return true;
  }

  @override
  Future<bool> hasBluetoothPermissions() async {
    return true;
  }

  @override
  Future<bool> requestCameraPermission() async {
    return true;
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    return true;
  }

  @override
  Future<void> openAppSettings() async {
    print(
      'Web: Cannot open app settings. Please check browser permissions manually.',
    );
  }
}
