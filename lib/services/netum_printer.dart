import 'package:flutter/services.dart';

class NetumPrinter {
  static const MethodChannel _channel = MethodChannel('netum_printer');

  static Future<void> initBluetooth() async {
    await _channel.invokeMethod('initBluetooth');
  }

  static Future<void> connect() async {
    await _channel.invokeMethod('connect');
  }

  static Future<void> printQRCode(String text) async {
    await _channel.invokeMethod('printQRCode', {'text': text});
  }
}
