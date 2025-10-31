abstract class PermissionServiceInterface {
  Future<bool> requestBluetoothPermissions();

  Future<bool> hasBluetoothPermissions();

  Future<bool> requestCameraPermission();

  Future<bool> requestMicrophonePermission();

  Future<void> openAppSettings();
}
