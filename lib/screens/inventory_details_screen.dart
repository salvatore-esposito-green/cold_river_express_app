import 'dart:io';
import 'package:cold_river_express_app/providers/printer_provider.dart';
import 'package:cold_river_express_app/utils/format_date.dart';
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
  late Inventory _currentInventory;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentInventory = widget.inventory;
  }

  @override
  Widget build(BuildContext context) {
    final printerService = Provider.of<BluetoothPrinterProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Box N. ${_currentInventory.box_number}'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.print,
              color:
                  printerService.isConnected
                      ? Theme.of(context).iconTheme.color
                      : Theme.of(context).colorScheme.error,
            ),
            onSelected: (value) async {
              if (value == 'find') {
                await printerService.scanBluetoothDevices();
                if (!mounted) return;
                _showDeviceSelection(context, printerService);
              } else if (value == 'disconnect') {
                await printerService.disconnect();
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'find',
                    child: Text('Find Printer'),
                  ),
                  PopupMenuItem<String>(
                    value: 'disconnect',
                    enabled: printerService.isConnected,
                    child: Text('Disconnect'),
                  ),
                ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _currentInventory.image_path != null &&
                          _currentInventory.image_path!.isNotEmpty
                      ? FutureBuilder<bool>(
                        future: File(_currentInventory.image_path!).exists(),
                        initialData: true,
                        builder: (context, snapshot) {
                          final file = File(_currentInventory.image_path!);
                          final fileExists = snapshot.data ?? false;

                          if (fileExists) {
                            return Hero(
                              tag: _currentInventory.id,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => Scaffold(
                                            appBar: AppBar(),
                                            body: Center(
                                              child: InteractiveViewer(
                                                child: Image.file(
                                                  file,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                    ),
                                  );
                                },
                                child: Image.file(file, fit: BoxFit.cover),
                              ),
                            );
                          } else {
                            return Container(
                              color: Theme.of(context).colorScheme.primary,
                              child: Center(
                                child: Text(
                                  "No image available",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      )
                      : Container(
                        color: Theme.of(context).colorScheme.primary,
                        child: Center(
                          child: Text(
                            "No image available",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      color: Colors.white.withValues(alpha: 0.7),
                      child: QrImageView(
                        data: _currentInventory.id,
                        version: QrVersions.auto,
                        size: 80.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed:
                              printerService.isConnected
                                  ? () {
                                    printerService.print(
                                      _currentInventory.id,
                                      _currentInventory.box_number,
                                      _currentInventory.contents.join(', '),
                                    );
                                  }
                                  : null,
                          child: const Text("Print Label"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            "ID: ${_currentInventory.id}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (
                            int i = 0;
                            i < _currentInventory.contents.length;
                            i++
                          ) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                              ),
                              child: Text(_currentInventory.contents[i]),
                            ),
                            if (i < _currentInventory.contents.length - 1)
                              Divider(
                                color: Colors.grey.shade300,
                                thickness: 1.0,
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Box Size:"),
                        Text(
                          _currentInventory.size,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_currentInventory.position?.isNotEmpty ?? false)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Position:"),
                          Text(
                            _currentInventory.position!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    if (_currentInventory.environment?.isNotEmpty ?? false)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Environment:"),
                          Text(
                            _currentInventory.environment!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Last Updated:"),
                        Text(
                          formatDate(_currentInventory.last_updated),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final updatedInventory = await Navigator.pushNamed(
                              context,
                              '/edit',
                              arguments: _currentInventory,
                            );
                            if (updatedInventory != null) {
                              setState(() {
                                _currentInventory =
                                    updatedInventory as Inventory;
                              });
                            }
                          },
                          child: const Text("Edit"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _showDeviceSelection(
    BuildContext context,
    BluetoothPrinterProvider printerService,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Select a Printer"),
          content:
              printerService.bluetoothDevices.isEmpty
                  ? Text("No devices found.")
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        printerService.bluetoothDevices.map((device) {
                          return ListTile(
                            title: Text(device.name),
                            subtitle: Text(device.macAdress),
                            onTap: () async {
                              await printerService.connect(device.macAdress);
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }
                            },
                          );
                        }).toList(),
                  ),
        );
      },
    );
  }
}
