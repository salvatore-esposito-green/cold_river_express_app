import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

class BluetoothPrinterProvider extends ChangeNotifier {
  String _platformVersion = 'Unknown';
  int _batteryLevel = 0;
  String? _preferredDeviceId;
  List<BluetoothInfo> _bluetoothDevices = [];
  bool _isConnected = false;

  BluetoothPrinterProvider() {
    _loadPreferredDevice();
  }

  // getters
  List<BluetoothInfo> get bluetoothDevices => _bluetoothDevices;
  String get preferredDevice => _preferredDeviceId ?? '';
  String get getPlatformVersion => _platformVersion;
  int get getBatteryLevel => _batteryLevel;
  bool get isConnected => _isConnected;

  Future<void> initPlatformState() async {
    try {
      _platformVersion = await PrintBluetoothThermal.platformVersion;
      _batteryLevel = await PrintBluetoothThermal.batteryLevel;
      notifyListeners();
    } on PlatformException {
      _platformVersion = 'Failed to get platform version.';
    }
  }

  Future<bool> isEnabled() async {
    return await PrintBluetoothThermal.bluetoothEnabled;
  }

  Future<void> checkConnection() async {
    _isConnected = await PrintBluetoothThermal.connectionStatus;
    notifyListeners();
  }

  Future<void> _loadPreferredDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _preferredDeviceId = prefs.getString('preferred_device_id');

    if (_preferredDeviceId != null) {
      await connect(_preferredDeviceId!);
    }
  }

  Future<void> _savePreferredDevice(String deviceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_device_id', deviceId);
  }

  Future<void> connect(String mac) async {
    final bool result = await PrintBluetoothThermal.connect(
      macPrinterAddress: mac,
    );
    if (result) {
      await _savePreferredDevice(mac);
      _isConnected = true;
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    final bool status = await PrintBluetoothThermal.disconnect;
    _isConnected = !status ? _isConnected : false;
    notifyListeners();
  }

  Future<void> scanBluetoothDevices() async {
    _bluetoothDevices = await PrintBluetoothThermal.pairedBluetooths;
    notifyListeners();
  }

  Future<void> print(String qrCodeId, String boxNumber, String contents) async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      List<int> ticket = await _generatePrintTicket(
        qrCodeId,
        boxNumber,
        contents,
      );
      await PrintBluetoothThermal.writeBytes(ticket);
    } else {
      _isConnected = false;
      notifyListeners();
    }
  }

  img.Image createTextImage(String text, {int fontSize = 24}) {
    final img.Image image = img.Image(width: 400, height: 100);

    img.fill(image, color: img.ColorUint8.rgb(255, 255, 255));

    final img.BitmapFont font = img.arial48;

    img.drawString(
      image,
      text,
      font: font,
      x: (image.width ~/ 2) - (font.size ~/ 2), // centralize the text
      y: (image.height - font.lineHeight) ~/ 2,
      color: img.ColorUint8.rgb(0, 0, 0),
    );

    return image;
  }

  Future<List<int>> _generatePrintTicket(
    String qrCodeId,
    String boxNumber,
    String contents,
  ) async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    bytes += generator.reset();

    bytes += generator.text(
      'Box Number:',
      styles: const PosStyles(
        align: PosAlign.center,
        fontType: PosFontType.fontB,
      ),
    );

    img.Image textImage = createTextImage(boxNumber, fontSize: 40);
    bytes += generator.imageRaster(textImage);

    bytes += generator.feed(1);

    bytes += generator.qrcode(qrCodeId, size: QRSize.size8);

    bytes += generator.text(
      contents,
      styles: const PosStyles(
        align: PosAlign.center,
        fontType: PosFontType.fontB,
      ),
    );

    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}
