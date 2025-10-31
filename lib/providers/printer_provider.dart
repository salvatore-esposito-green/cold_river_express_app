import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:image/image.dart' as img;
import 'package:cold_river_express_app/core/platform_factory.dart';
import 'package:cold_river_express_app/core/interfaces/bluetooth_service_interface.dart';

class BluetoothPrinterProvider extends ChangeNotifier {
  String _platformVersion = 'Unknown';
  int _batteryLevel = 0;
  String? _preferredDeviceId;
  List _bluetoothDevices =
      []; // Changed to dynamic list for both mobile and web
  bool _isConnected = false;
  late final BluetoothServiceInterface _bluetoothService;

  BluetoothPrinterProvider() {
    _bluetoothService = PlatformFactory.createBluetoothService();
    _loadPreferredDevice();
  }

  // getters
  List get bluetoothDevices => _bluetoothDevices;
  String get preferredDevice => _preferredDeviceId ?? '';
  String get getPlatformVersion => _platformVersion;
  int get getBatteryLevel => _batteryLevel;
  bool get isConnected => _isConnected;

  Future<void> initPlatformState() async {
    try {
      if (kIsWeb) {
        _platformVersion = 'Web';
        _batteryLevel = 100;
      } else {
        _platformVersion = await PrintBluetoothThermal.platformVersion;
        _batteryLevel = await PrintBluetoothThermal.batteryLevel;
      }
      notifyListeners();
    } on PlatformException {
      _platformVersion = 'Failed to get platform version.';
    }
  }

  Future<bool> isEnabled() async {
    return await _bluetoothService.isBluetoothEnabled();
  }

  Future<void> checkConnection() async {
    _isConnected = await _bluetoothService.isConnected();
    notifyListeners();
  }

  Future<void> _loadPreferredDevice() async {
    _preferredDeviceId = await _bluetoothService.getPreferredDevice();

    if (_preferredDeviceId != null) {
      final bool bluetoothEnabled =
          await _bluetoothService.isBluetoothEnabled();
      if (bluetoothEnabled) {
        await connect(_preferredDeviceId!);
      }
    }
  }

  Future<void> _savePreferredDevice(String deviceId) async {
    await _bluetoothService.savePreferredDevice(deviceId);
  }

  Future<bool> connect(String deviceId) async {
    final bool result = await _bluetoothService.connect(deviceId);
    if (result) {
      await _savePreferredDevice(deviceId);
      _isConnected = true;
    }
    notifyListeners();
    return result;
  }

  Future<void> disconnect() async {
    final bool status = await _bluetoothService.disconnect();
    _isConnected = !status;
    notifyListeners();
  }

  Future<void> scanBluetoothDevices() async {
    if (kIsWeb) {
      // On web, calling connect will trigger the browser's device picker
      // scanDevices returns empty list on web as per Web Bluetooth API design
      final devices = await _bluetoothService.scanDevices();
      _bluetoothDevices = devices;
    } else {
      // On mobile, get paired devices
      _bluetoothDevices = await PrintBluetoothThermal.pairedBluetooths;
    }
    notifyListeners();
  }

  Future<void> print(String qrCodeId, String boxNumber, String contents) async {
    if (kDebugMode) {
      debugPrint(
        '[Provider] print() called - qrCodeId: $qrCodeId, boxNumber: $boxNumber',
      );
    }

    bool connectionStatus = await _bluetoothService.isConnected();
    if (kDebugMode) {
      debugPrint('[Provider] Connection status: $connectionStatus');
    }

    if (connectionStatus) {
      if (kIsWeb) {
        if (kDebugMode) {
          debugPrint('[Provider] Using web Bluetooth service');
        }
        // Use web Bluetooth service
        final success = await _bluetoothService.printLabel(
          qrCodeId: qrCodeId,
          boxNumber: boxNumber,
          contents: contents,
        );
        if (kDebugMode) {
          debugPrint('[Provider] Print result: $success');
        }
        if (!success) {
          _isConnected = false;
          notifyListeners();
        }
      } else {
        if (kDebugMode) {
          debugPrint('[Provider] Using mobile thermal printer');
        }
        // Use mobile thermal printer
        List<int> label = await _generatePrintLabel(
          qrCodeId,
          boxNumber,
          contents,
        );
        await PrintBluetoothThermal.writeBytes(label);
      }
    } else {
      if (kDebugMode) {
        debugPrint('[Provider] ERROR: Not connected!');
      }
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

  Future<List<int>> _generatePrintLabel(
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
