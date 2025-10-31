import 'dart:io';
import 'package:cold_river_express_app/repositories/inventory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  QRScanScreenState createState() => QRScanScreenState();
}

class QRScanScreenState extends State<QRScanScreen> {
  final InventoryRepository _repository = InventoryRepository();

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();

    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }

    Future.delayed(const Duration(seconds: 1), () {
      controller?.resumeCamera();
    });
  }

  Future<void> _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    bool hasNavigated = false;

    controller.scannedDataStream.listen((scanData) async {
      if (hasNavigated || scanData.code == null) return;

      hasNavigated = true;

      if (!mounted) return;

      var inventory = await _repository.getInventoryById(scanData.code!);

      if (!mounted) return;

      if (inventory != null) {
        HapticFeedback.vibrate();

        Navigator.pushNamed(context, '/details', arguments: inventory);

        controller.pauseCamera();
      } else {
        Navigator.pushNamed(context, '/insert', arguments: scanData.code);
        controller.pauseCamera();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No inventory found')));
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.all(8),
                child: FutureBuilder(
                  future: controller?.getFlashStatus(),
                  builder: (context, snapshot) {
                    return IconButton(
                      icon: Icon(
                        snapshot.data == true
                            ? Icons.flash_on
                            : Icons.flash_off,
                        color:
                            snapshot.data == true
                                ? Colors.accents[1]
                                : Colors.grey,
                        size: snapshot.data == true ? 32 : 28,
                      ),
                      onPressed: () async {
                        await controller?.toggleFlash();
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.all(8),
                child: FutureBuilder(
                  future: controller?.getCameraInfo(),
                  builder: (context, snapshot) {
                    return IconButton(
                      icon: Icon(
                        Icons.flip_camera_ios,
                        color:
                            snapshot.data != null
                                ? Colors.accents[1]
                                : Colors.grey,
                        size: snapshot.data != null ? 32 : 28,
                      ),
                      onPressed: () async {
                        await controller?.flipCamera();
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Expanded(flex: 5, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea =
        (MediaQuery.of(context).size.width < 400 ||
                MediaQuery.of(context).size.height < 400)
            ? 180.0
            : 300.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.accents[1],
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
      formatsAllowed: const [BarcodeFormat.qrcode],
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('no Permission')));
    }
  }
}
