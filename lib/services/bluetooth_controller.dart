import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

class BluetoothPrinterService {
  String platformVersion = 'Unknown';
  int porcentbatery = 0;

  String? preferredDeviceId;
  List<BluetoothInfo> _listResult = [];

  BluetoothPrinterService() {
    _loadPreferredDevice();
  }

  List<BluetoothInfo> get listResult => _listResult;

  Future<void> initPlatformState(BuildContext context) async {
    try {
      platformVersion = await PrintBluetoothThermal.platformVersion;
      porcentbatery = await PrintBluetoothThermal.batteryLevel;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    final bool result = await PrintBluetoothThermal.bluetoothEnabled;

    String message =
        result
            ? "Bluetooth enabled, please search and connect"
            : "Bluetooth not enabled";

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> isPermissionGranted() async {
    return await PrintBluetoothThermal.isPermissionBluetoothGranted;
  }

  Future<bool> isEnabled() async {
    return await PrintBluetoothThermal.bluetoothEnabled;
  }

  Future<bool> isConnected() async {
    return await PrintBluetoothThermal.connectionStatus;
  }

  Future<void> _loadPreferredDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    preferredDeviceId = prefs.getString('preferred_device_id');

    if (preferredDeviceId != null) {
      // await getBluetoots(preferredDeviceId!);
    }
  }

  Future<void> _savePreferredDevice(String deviceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('preferred_device_id', deviceId);
  }

  Future<void> connect(BuildContext context, String mac) async {
    final bool result = await PrintBluetoothThermal.connect(
      macPrinterAddress: mac,
    );

    if (result) {
      await _savePreferredDevice(mac);
    }

    String message = result ? "Connected successfully" : "Failed to connect";

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> disconnect(BuildContext context) async {
    final bool status = await PrintBluetoothThermal.disconnect;

    String message =
        status ? "Disconnected successfully" : "Failed to disconnect";

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> getBluetoots(BuildContext context) async {
    _listResult = await PrintBluetoothThermal.pairedBluetooths;

    final String message =
        _listResult.isEmpty
            ? "There are no bluetooths paired, go to settings and pair the printer"
            : "Touch an item in the list to connect";

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> print(BuildContext context, String qrCodeId) async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;

    if (connectionStatus) {
      List<int> ticket = await testTicket(qrCodeId);
      bool result = await PrintBluetoothThermal.writeBytes(ticket);

      String statusMessage = result ? "Print successful" : "Print failed";

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(statusMessage)));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No connected device")));
    }
  }

  Future<List<int>> testTicket(qrCodeId) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load();

    final generator = Generator(PaperSize.mm58, profile);

    //bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    bytes += generator.text(
      'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ',
    );

    bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
    bytes += generator.text(
      'Reverse text',
      styles: const PosStyles(reverse: true),
    );
    bytes += generator.text(
      'Underlined text',
      styles: const PosStyles(underline: true),
      linesAfter: 1,
    );
    bytes += generator.text(
      'Align left',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Align center',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Align right',
      styles: const PosStyles(align: PosAlign.right),
      linesAfter: 1,
    );

    bytes += generator.row([
      PosColumn(
        text: 'col3',
        width: 3,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col6',
        width: 6,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col3',
        width: 3,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
    ]);

    //barcode

    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    //QR code
    bytes += generator.qrcode(qrCodeId);

    bytes += generator.text(
      'Text size 50%',
      styles: const PosStyles(fontType: PosFontType.fontB),
    );
    bytes += generator.text(
      'Text size 100%',
      styles: const PosStyles(fontType: PosFontType.fontA),
    );
    bytes += generator.text(
      'Text size 200%',
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }
}
