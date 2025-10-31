import 'package:cold_river_express_app/core/interfaces/permission_service_interface.dart';

class PermissionServiceMobile implements PermissionServiceInterface {
  @override Future<bool> requestBluetoothPermissions() => throw UnimplementedError();
  @override Future<bool> hasBluetoothPermissions() => throw UnimplementedError();
  @override Future<bool> requestCameraPermission() => throw UnimplementedError();
  @override Future<bool> requestMicrophonePermission() => throw UnimplementedError();
  @override Future<void> openAppSettings() => throw UnimplementedError();
}
