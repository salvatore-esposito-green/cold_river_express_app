import 'dart:io';
import 'package:cold_river_express_app/providers/printer_provider.dart';
import 'package:flutter/material.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InventoryDetailsScreen extends StatefulWidget {
  final Inventory inventory;

  const InventoryDetailsScreen({super.key, required this.inventory});

  @override
  State<InventoryDetailsScreen> createState() => _InventoryDetailsScreenState();
}

class _InventoryDetailsScreenState extends State<InventoryDetailsScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final printerService = Provider.of<BluetoothPrinterProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              printerService.isConnected
                  ? "Stampante Connessa"
                  : "Nessuna Stampante Connessa",
            ),
            ElevatedButton(
              onPressed: () async {
                await printerService.scanBluetoothDevices();
                _showDeviceSelection(context, printerService);
              },
              child: Text("Trova Stampanti"),
            ),
            ElevatedButton(
              onPressed: () async {
                await printerService.disconnect();
              },
              child: Text("Disconnetti"),
            ),
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
                printerService.print(
                  widget.inventory.id,
                  widget.inventory.boxNumber,
                  widget.inventory.contents.join(', '),
                );
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

  void _showDeviceSelection(
    BuildContext context,
    BluetoothPrinterProvider printerService,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seleziona una stampante"),
          content:
              printerService.bluetoothDevices.isEmpty
                  ? Text("Nessun dispositivo trovato.")
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        printerService.bluetoothDevices.map((device) {
                          return ListTile(
                            title: Text(device.name ?? "Sconosciuto"),
                            subtitle: Text(device.macAdress),
                            onTap: () async {
                              await printerService.connect(device.macAdress);
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                  ),
        );
      },
    );
  }
}
