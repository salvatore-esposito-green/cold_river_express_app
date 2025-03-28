import 'dart:io';
import 'package:cold_river_express_app/services/image_picking_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/repositories/inventory_repository.dart';
import 'package:cold_river_express_app/widgets/inventory_form_widget.dart';

class InventoryInsertScreen extends StatefulWidget {
  final String? qrCode;

  const InventoryInsertScreen({super.key, this.qrCode});

  @override
  State<InventoryInsertScreen> createState() => _InventoryInsertScreenState();
}

class _InventoryInsertScreenState extends State<InventoryInsertScreen> {
  final ImagePickingService _pickerService = ImagePickingService();

  String? _imagePath;

  Future<void> _pickImage() async {
    final pickedImagePath = await _pickerService.pickImage();
    if (pickedImagePath != null) {
      setState(() {
        _imagePath = pickedImagePath;
      });
    }
  }

  Future<int> _getNextBoxNumber(InventoryRepository repo) async {
    final inventories = await repo.fetchAllInventories();
    if (inventories.isEmpty) return 1;
    final maxBoxNumber = inventories
        .map((inv) => int.tryParse(inv.box_number) ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return maxBoxNumber + 1;
  }

  @override
  Widget build(BuildContext context) {
    final InventoryRepository repository = InventoryRepository();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: true,
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _imagePath != null && _imagePath!.isNotEmpty
                      ? Hero(
                        tag: const Uuid().v4(),
                        child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                      )
                      : Container(color: Theme.of(context).colorScheme.primary),
                  Center(
                    child: IconButton(
                      iconSize: 60,
                      icon: Icon(
                        Icons.camera_alt,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: _pickImage,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              FutureBuilder<int>(
                future: _getNextBoxNumber(repository),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final newInventory = Inventory(
                    id: widget.qrCode ?? const Uuid().v4(),
                    box_number: snapshot.data.toString(),
                    contents: [],
                    image_path: _imagePath,
                    size: '60x40x40',
                    position: null,
                    environment: null,
                    last_updated: DateTime.now(),
                  );

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InventoryFormWidget(
                      initialInventory: newInventory,
                      imagePath: _imagePath,
                      onSubmit: (createdInventory) async {
                        await repository.addInventory(createdInventory);
                        Navigator.pushReplacementNamed(
                          context,
                          '/details',
                          arguments: createdInventory,
                        );
                      },
                    ),
                  );
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
