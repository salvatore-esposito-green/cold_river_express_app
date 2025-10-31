import 'package:cold_river_express_app/core/interfaces/bluetooth_service_interface.dart';

/// Stub per il web - non verrà mai chiamato
class BluetoothServiceMobile implements BluetoothServiceInterface {
  @override
  Future<bool> isBluetoothAvailable() => throw UnimplementedError();

  @override
  Future<bool> isBluetoothEnabled() => throw UnimplementedError();

  @override
  Future<bool> isConnected() => throw UnimplementedError();

  @override
  Future<List<BluetoothDeviceInfo>> scanDevices() => throw UnimplementedError();

  @override
  Future<bool> connect(String deviceId) => throw UnimplementedError();

  @override
  Future<bool> disconnect() => throw UnimplementedError();

  @override
  Future<bool> printLabel({
    required String qrCodeId,
    required String boxNumber,
    required String contents,
  }) => throw UnimplementedError();

  @override
  Future<String?> getPreferredDevice() => throw UnimplementedError();

  @override
  Future<void> savePreferredDevice(String deviceId) => throw UnimplementedError();

  @override
  Future<bool> requestPermissions() => throw UnimplementedError();
}
