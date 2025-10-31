import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;
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
    // Web Bluetooth API non fornisce un modo diretto per verificare
    // se il Bluetooth è abilitato. Restituiamo true se è disponibile.
    return await isBluetoothAvailable();
  }

  @override
  Future<bool> isConnected() async {
    try {
      if (_currentDevice == null) return false;

      // Verifica se il dispositivo è ancora connesso
      final connected =
          js_util.getProperty(_currentDevice, 'gatt') != null &&
          js_util.callMethod(_currentDevice, 'gatt.connected', []);
      return connected ?? false;
    } catch (e) {
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

      // Richiede all'utente di selezionare un dispositivo Bluetooth
      final options = js_util.jsify({
        'filters': [
          {
            'services': [_printerServiceUuid],
          },
        ],
        'optionalServices': [_printerServiceUuid],
      });

      _currentDevice = await js_util.promiseToFuture(
        js_util.callMethod(bluetooth, 'requestDevice', [options]),
      );

      if (_currentDevice == null) return false;

      // Connette al dispositivo
      final gatt = js_util.getProperty(_currentDevice, 'gatt');
      _currentServer = await js_util.promiseToFuture(
        js_util.callMethod(gatt, 'connect', []),
      );

      // Ottiene il servizio di stampa
      _currentService = await js_util.promiseToFuture(
        js_util.callMethod(_currentServer, 'getPrimaryService', [
          _printerServiceUuid,
        ]),
      );

      // Ottiene la caratteristica per la scrittura
      _currentCharacteristic = await js_util.promiseToFuture(
        js_util.callMethod(_currentService, 'getCharacteristic', [
          _printerCharacteristicUuid,
        ]),
      );

      // Salva il dispositivo preferito
      final deviceName = js_util.getProperty(_currentDevice, 'name') as String?;
      if (deviceName != null) {
        await savePreferredDevice(deviceName);
      }

      return true;
    } catch (e) {
      print('Error connecting to Bluetooth device: $e');
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
      if (_currentCharacteristic == null) {
        print('No characteristic available for printing');
        return false;
      }

      // Genera i comandi ESC/POS per la stampa
      final commands = _generateEscPosCommands(qrCodeId, boxNumber, contents);

      // Invia i comandi alla stampante
      await js_util.promiseToFuture(
        js_util.callMethod(_currentCharacteristic, 'writeValue', [commands]),
      );

      return true;
    } catch (e) {
      print('Error printing label: $e');
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
