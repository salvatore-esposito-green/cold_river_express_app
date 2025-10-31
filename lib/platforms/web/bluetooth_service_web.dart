import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'dart:typed_data';
import 'package:cold_river_express_app/core/interfaces/bluetooth_service_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementazione web del servizio Bluetooth
/// Utilizza Web Bluetooth API per stampanti Bluetooth LE
class BluetoothServiceWeb implements BluetoothServiceInterface {
  dynamic _currentDevice;
  dynamic _currentServer;
  dynamic _currentService;
  dynamic _currentCharacteristic;

  // UUID standard per servizi di stampa Bluetooth LE
  static const String _printerServiceUuid =
      '000018f0-0000-1000-8000-00805f9b34fb';
  static const String _printerCharacteristicUuid =
      '00002af1-0000-1000-8000-00805f9b34fb';

  @override
  Future<bool> isBluetoothAvailable() async {
    try {
      // Verifica se il browser supporta Web Bluetooth API
      final navigator = html.window.navigator;
      return js_util.hasProperty(navigator, 'bluetooth');
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    return await isBluetoothAvailable();
  }

  @override
  Future<bool> isConnected() async {
    try {
      if (_currentDevice == null) {
        print('[BT Web] isConnected: No device');
        return false;
      }

      final gatt = js_util.getProperty(_currentDevice, 'gatt');
      if (gatt == null) {
        print('[BT Web] isConnected: No GATT');
        return false;
      }

      final connected = js_util.getProperty(gatt, 'connected') ?? false;
      print('[BT Web] isConnected: $connected');
      return connected;
    } catch (e) {
      print('[BT Web] isConnected error: $e');
      return false;
    }
  }

  @override
  Future<List<BluetoothDeviceInfo>> scanDevices() async {
    return [];
  }

  @override
  Future<bool> connect(String deviceId) async {
    try {
      final navigator = html.window.navigator;
      final bluetooth = js_util.getProperty(navigator, 'bluetooth');

      final options = js_util.jsify({
        'acceptAllDevices': true,
        'optionalServices': [
          _printerServiceUuid,
          _printerCharacteristicUuid,
          '000018f0-0000-1000-8000-00805f9b34fb', // Printer service
          '00001101-0000-1000-8000-00805f9b34fb', // Serial Port Profile
        ],
      });

      print('[BT Web] Requesting device...');
      _currentDevice = await js_util.promiseToFuture(
        js_util.callMethod(bluetooth, 'requestDevice', [options]),
      );

      if (_currentDevice == null) {
        print('[BT Web] No device selected');
        return false;
      }

      final deviceName = js_util.getProperty(_currentDevice, 'name') as String?;
      print('[BT Web] Device selected: $deviceName');

      // Connette al dispositivo
      final gatt = js_util.getProperty(_currentDevice, 'gatt');
      print('[BT Web] Connecting to GATT server...');
      _currentServer = await js_util.promiseToFuture(
        js_util.callMethod(gatt, 'connect', []),
      );

      print('[BT Web] Connected! Discovering services...');

      try {
        final services = await js_util.promiseToFuture(
          js_util.callMethod(_currentServer, 'getPrimaryServices', []),
        );
        print(
          '[BT Web] Found ${js_util.getProperty(services, 'length')} services',
        );

        for (int i = 0; i < js_util.getProperty(services, 'length'); i++) {
          final service = js_util.getProperty(services, i.toString());
          final serviceUuid = js_util.getProperty(service, 'uuid');
          print('[BT Web] Service $i UUID: $serviceUuid');

          try {
            final characteristics = await js_util.promiseToFuture(
              js_util.callMethod(service, 'getCharacteristics', []),
            );

            for (
              int j = 0;
              j < js_util.getProperty(characteristics, 'length');
              j++
            ) {
              final char = js_util.getProperty(characteristics, j.toString());
              final charUuid = js_util.getProperty(char, 'uuid');
              final properties = js_util.getProperty(char, 'properties');
              final canWrite =
                  js_util.getProperty(properties, 'write') ?? false;
              final canWriteWithoutResponse =
                  js_util.getProperty(properties, 'writeWithoutResponse') ??
                  false;

              print(
                '[BT Web]   Char $j UUID: $charUuid, write: $canWrite, writeWR: $canWriteWithoutResponse',
              );

              if (canWrite || canWriteWithoutResponse) {
                _currentService = service;
                _currentCharacteristic = char;
                print('[BT Web] Using writable characteristic: $charUuid');
                break;
              }
            }

            if (_currentCharacteristic != null) break;
          } catch (e) {
            print('[BT Web] Error reading service $i: $e');
          }
        }

        if (_currentCharacteristic == null) {
          print('[BT Web] No writable characteristic found!');
          return false;
        }
      } catch (e) {
        print('[BT Web] Error discovering services: $e');
        return false;
      }

      // Salva il dispositivo preferito
      if (deviceName != null) {
        await savePreferredDevice(deviceName);
      }

      print('[BT Web] Connection successful!');
      return true;
    } catch (e) {
      print('[BT Web] Error connecting to Bluetooth device: $e');
      return false;
    }
  }

  @override
  Future<bool> disconnect() async {
    try {
      if (_currentServer != null) {
        js_util.callMethod(_currentServer, 'disconnect', []);
      }
      _currentDevice = null;
      _currentServer = null;
      _currentService = null;
      _currentCharacteristic = null;
      return true;
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
      print('[BT Web] Starting print...');

      if (_currentCharacteristic == null) {
        print('[BT Web] ERROR: No characteristic available for printing');
        return false;
      }

      if (_currentServer == null) {
        print('[BT Web] ERROR: Not connected to device');
        return false;
      }

      final connected = js_util.getProperty(
        js_util.getProperty(_currentDevice, 'gatt'),
        'connected',
      );
      print('[BT Web] Connection status: $connected');

      if (connected != true) {
        print('[BT Web] ERROR: Device disconnected');
        return false;
      }

      print('[BT Web] Generating ESC/POS commands...');
      final commands = _generateEscPosCommands(qrCodeId, boxNumber, contents);
      print('[BT Web] Generated ${commands.length} bytes');

      // Bluetooth LE ha un MTU limitato (di solito 20-512 bytes)
      const chunkSize = 20; // MTU minimo sicuro
      for (int i = 0; i < commands.length; i += chunkSize) {
        final end =
            (i + chunkSize < commands.length) ? i + chunkSize : commands.length;
        final chunk = commands.sublist(i, end);

        print(
          '[BT Web] Sending chunk ${i ~/ chunkSize + 1}/${(commands.length / chunkSize).ceil()} (${chunk.length} bytes)',
        );

        try {
          // Converti in Uint8List per JavaScript
          final uint8list = Uint8List.fromList(chunk);

          await js_util.promiseToFuture(
            js_util.callMethod(_currentCharacteristic, 'writeValue', [
              uint8list,
            ]),
          );

          await Future.delayed(const Duration(milliseconds: 50));
        } catch (e) {
          print('[BT Web] ERROR sending chunk: $e');
          return false;
        }
      }

      print('[BT Web] Print completed successfully!');
      return true;
    } catch (e) {
      print('[BT Web] ERROR printing label: $e');
      return false;
    }
  }

  @override
  Future<String?> getPreferredDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('preferred_device_id_web');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> savePreferredDevice(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('preferred_device_id_web', deviceId);
    } catch (e) {
      // Ignore
    }
  }

  @override
  Future<bool> requestPermissions() async {
    // Le permission sono gestite automaticamente dal browser
    // quando l'utente seleziona un dispositivo
    return await isBluetoothAvailable();
  }

  // ========== Metodi Privati ==========

  /// Genera comandi ESC/POS per la stampa dell'etichetta
  List<int> _generateEscPosCommands(
    String qrCodeId,
    String boxNumber,
    String contents,
  ) {
    List<int> commands = [];

    // ESC @ - Inizializza stampante
    commands.addAll([0x1B, 0x40]);

    // Allineamento centro
    commands.addAll([0x1B, 0x61, 0x01]);

    // Testo "Box Number:"
    commands.addAll('Box Number:\n'.codeUnits);

    // Imposta dimensione carattere grande
    commands.addAll([0x1D, 0x21, 0x11]);
    commands.addAll('$boxNumber\n'.codeUnits);

    // Reset dimensione carattere
    commands.addAll([0x1D, 0x21, 0x00]);

    // Feed
    commands.addAll([0x0A]);

    // QR Code (se supportato dalla stampante)
    // Formato: ESC/POS QR Code
    commands.addAll([
      0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, 0x08, // Model
      0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x45, 0x30, // Error correction
    ]);

    // Dati QR
    final qrData = qrCodeId.codeUnits;
    final qrLength = qrData.length + 3;
    commands.addAll([
      0x1D,
      0x28,
      0x6B,
      qrLength & 0xFF,
      (qrLength >> 8) & 0xFF,
      0x31,
      0x50,
      0x30,
      ...qrData,
    ]);

    // Stampa QR
    commands.addAll([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30]);

    // Feed
    commands.addAll([0x0A]);

    // Contenuto
    commands.addAll('$contents\n'.codeUnits);

    // Feed e taglio
    commands.addAll([0x0A, 0x0A]);
    commands.addAll([0x1D, 0x56, 0x00]); // Cut paper

    return commands;
  }
}
