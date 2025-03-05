import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InventoryDetailsScreen extends StatelessWidget {
  final Inventory inventory;

  const InventoryDetailsScreen({super.key, required this.inventory});

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
                data: inventory.id,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 8),
            const Center(child: Text("QR Code for Inventory ID")),
            const SizedBox(height: 16),
            Text(
              "ID: ${inventory.id}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text("Box Number: ${inventory.boxNumber}"),
            const SizedBox(height: 16),
            Text("Contents: ${inventory.contents.join(', ')}"),
            const SizedBox(height: 16),
            inventory.imagePath != null && inventory.imagePath!.isNotEmpty
                ? Image.file(
                  File(inventory.imagePath!),
                  height: 200,
                  fit: BoxFit.cover,
                )
                : const Text("No image available"),
            const SizedBox(height: 16),
            Text("Box Side: ${inventory.size}"),
            const SizedBox(height: 16),
            Text("Position: ${inventory.position}"),
            const SizedBox(height: 16),
            Text("Last Updated: ${inventory.lastUpdated.toLocal().toString()}"),
          ],
        ),
      ),
    );
  }
}
