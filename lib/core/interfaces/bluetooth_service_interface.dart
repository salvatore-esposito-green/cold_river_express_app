abstract class BluetoothServiceInterface {
  Future<bool> isBluetoothAvailable();

  Future<bool> isBluetoothEnabled();

  Future<bool> isConnected();

  Future<List<BluetoothDeviceInfo>> scanDevices();

  Future<bool> connect(String deviceId);

  Future<bool> disconnect();

  Future<bool> printLabel({
    required String qrCodeId,
    required String boxNumber,
    required String contents,
  });

  Future<String?> getPreferredDevice();

  Future<void> savePreferredDevice(String deviceId);

  Future<bool> requestPermissions();
}

class BluetoothDeviceInfo {
  final String id;
  final String name;
  final String? address; // MAC address per mobile, null per web

  BluetoothDeviceInfo({required this.id, required this.name, this.address});

  @override
  String toString() =>
      'BluetoothDevice(id: $id, name: $name, address: $address)';
}
