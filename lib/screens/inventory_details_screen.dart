import 'dart:io';
import 'package:cold_river_express_app/services/netum_printer.dart';
import 'package:flutter/material.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InventoryDetailsScreen extends StatefulWidget {
  final Inventory inventory;

  const InventoryDetailsScreen({super.key, required this.inventory});

  @override
  State<InventoryDetailsScreen> createState() => _InventoryDetailsScreenState();
}

class _InventoryDetailsScreenState extends State<InventoryDetailsScreen> {
  bool isLoading = false;

  Future<void> printQR(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() {
      isLoading = true;
    });

    final printResult = await NetumPrinter.printQRCode(widget.inventory.id);

    final message =
        printResult.success
            ? 'Badge printed successfully!'
            : 'Printing failed: ${printResult.errorMessage}';

    setState(() {
      isLoading = false;
    });

    if (mounted) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: QrImageView(
                data: widget.inventory.id,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 8),
            const Center(child: Text("QR Code for Inventory ID")),
            const SizedBox(height: 16),
            Text(
              "ID: ${widget.inventory.id}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                printQR(context);
              },
              child: const Text("Print"),
            ),
            const SizedBox(height: 16),
            Text("Box Number: ${widget.inventory.boxNumber}"),
            const SizedBox(height: 16),
            Text("Contents: ${widget.inventory.contents.join(', ')}"),
            const SizedBox(height: 16),
            widget.inventory.imagePath != null &&
                    widget.inventory.imagePath!.isNotEmpty
                ? Image.file(
                  File(widget.inventory.imagePath!),
                  height: 200,
                  fit: BoxFit.cover,
                )
                : const Text("No image available"),
            const SizedBox(height: 16),
            Text("Box Side: ${widget.inventory.size}"),
            const SizedBox(height: 16),
            Text("Position: ${widget.inventory.position}"),
            const SizedBox(height: 16),
            Text(
              "Last Updated: ${widget.inventory.lastUpdated.toLocal().toString()}",
            ),
          ],
        ),
      ),
    );
  }
}
