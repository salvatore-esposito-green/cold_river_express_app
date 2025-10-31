import 'dart:io';
import 'package:cold_river_express_app/services/image_picking_service.dart';
import 'package:flutter/material.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/repositories/inventory_repository.dart';
import 'package:cold_river_express_app/widgets/inventory_form_widget.dart';

class InventoryEditScreen extends StatefulWidget {
  final Inventory inventory;
  const InventoryEditScreen({super.key, required this.inventory});

  @override
  State<InventoryEditScreen> createState() => _InventoryEditScreenState();
}

class _InventoryEditScreenState extends State<InventoryEditScreen> {
  final InventoryRepository repository = InventoryRepository();
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

  @override
  void initState() {
    super.initState();
    _imagePath = widget.inventory.image_path;
  }

  @override
  Widget build(BuildContext context) {
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
                        tag: widget.inventory.id,
                        child: Builder(
                          builder: (context) {
                            final file = File(_imagePath!);
                            if (file.existsSync()) {
                              return Image.file(file, fit: BoxFit.cover);
                            } else {
                              return Container(
                                color: Theme.of(context).colorScheme.primary,
                              );
                            }
                          },
                        ),
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InventoryFormWidget(
                  initialInventory: widget.inventory,
                  imagePath: _imagePath,
                  onSubmit: (updatedInventory) async {
                    await repository.updateInventory(updatedInventory);
                    if (context.mounted) {
                      Navigator.pop(context, updatedInventory);
                    }
                  },
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
