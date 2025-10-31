import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:cold_river_express_app/core/interfaces/bluetooth_service_interface.dart';

/// Implementazione mobile del servizio Bluetooth
/// Utilizza print_bluetooth_thermal per stampanti termiche Bluetooth classiche
class BluetoothServiceMobile implements BluetoothServiceInterface {
  @override
  Future<bool> isBluetoothAvailable() async {
    try {
      // Su mobile, il Bluetooth è sempre disponibile (se il dispositivo lo ha)
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      return await PrintBluetoothThermal.connectionStatus;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<BluetoothDeviceInfo>> scanDevices() async {
    try {
      final devices = await PrintBluetoothThermal.pairedBluetooths;
      return devices
          .map((device) => BluetoothDeviceInfo(
                id: device.macAdress,
                name: device.name,
                address: device.macAdress,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> connect(String deviceId) async {
    try {
      final result = await PrintBluetoothThermal.connect(
        macPrinterAddress: deviceId,
      );
      if (result) {
        await savePreferredDevice(deviceId);
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> disconnect() async {
    try {
      final status = await PrintBluetoothThermal.disconnect;
      return status;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> printLabel({
    required String qrCodeId,
    required String boxNumber,
    required String contents,
  }) async {
    try {
      final connectionStatus = await isConnected();
      if (!connectionStatus) {
        return false;
      }

      final label = await _generatePrintLabel(
        qrCodeId,
        boxNumber,
        contents,
      );
      await PrintBluetoothThermal.writeBytes(label);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getPreferredDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('preferred_device_id');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> savePreferredDevice(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('preferred_device_id', deviceId);
    } catch (e) {
      // Ignore
    }
  }

  @override
  Future<bool> requestPermissions() async {
    // Le permission sono gestite a livello di sistema operativo
    // e richieste automaticamente quando necessario
    return true;
  }

  // ========== Metodi Privati ==========

  img.Image _createTextImage(String text, {int fontSize = 24}) {
    final image = img.Image(width: 400, height: 100);
    img.fill(image, color: img.ColorUint8.rgb(255, 255, 255));
    final font = img.arial48;

    img.drawString(
      image,
      text,
      font: font,
      x: (image.width ~/ 2) - (font.size ~/ 2),
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

    img.Image textImage = _createTextImage(boxNumber, fontSize: 40);
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
