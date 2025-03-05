import 'package:cold_river_express_app/models/print_result.dart';
import 'package:flutter/services.dart';

class NetumPrinter {
  static const MethodChannel _channel = MethodChannel(
    'com.Salvad0r.netum_printer',
  );

  static Future<void> initBluetooth() async {
    await _channel.invokeMethod('initBluetooth');
  }

  static Future<void> connect() async {
    await _channel.invokeMethod('connect');
  }

  static Future<PrintResult> printQRCode(String qr) async {
    try {
      final result = await _channel.invokeMethod('printQRCode', {
        'qrcodeId': qr,
      });

      if (result is Map) {
        return PrintResult(
          success: result['success'] as bool,
          errorMessage: result['error'] as String?,
        );
      } else {
        return PrintResult(
          success: false,
          errorMessage: 'Risposta non valida dal canale nativo.',
        );
      }
    } catch (e) {
      return PrintResult(success: false, errorMessage: e.toString());
    }
  }
}
