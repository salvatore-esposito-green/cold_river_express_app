import 'dart:io';

import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/repositories/inventory_repository.dart';
import 'package:cold_river_express_app/services/image_picking_service.dart';
import 'package:cold_river_express_app/widgets/speech_to_text_field.dart';
import 'package:flutter/material.dart';

class InventoryEditScreen extends StatefulWidget {
  final Inventory inventory;
  const InventoryEditScreen({super.key, required this.inventory});

  @override
  State<InventoryEditScreen> createState() => InventoryEditScreenState();
}

class InventoryEditScreenState extends State<InventoryEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _contentsController;
  late TextEditingController _positionController;

  String? _selectedSide;
  String? _imagePath;

  final List<String> _boxSides = ['60x40x40', '80x40x40', 'Custom'];

  final InventoryRepository _repository = InventoryRepository();
  final ImagePickingService _pickerService = ImagePickingService();

  @override
  void initState() {
    super.initState();

    _contentsController = TextEditingController(
      text: widget.inventory.contents.join(', '),
    );
    _positionController = TextEditingController(
      text: widget.inventory.position,
    );
    _selectedSide = widget.inventory.size;
    _imagePath = widget.inventory.imagePath;
  }

  @override
  void dispose() {
    _contentsController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedInventory = widget.inventory.copyWith(
        contents:
            _contentsController.text.split(',').map((s) => s.trim()).toList(),
        position: _positionController.text,
        size: _selectedSide,
        imagePath: _imagePath,
        lastUpdated: DateTime.now(),
      );

      await _repository.updateInventory(updatedInventory);

      Navigator.pop(context, updatedInventory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Box N. ${widget.inventory.boxNumber}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _imagePath != null && _imagePath!.isNotEmpty
                  ? Image.file(
                    File(_imagePath!),
                    height: 200,
                    fit: BoxFit.cover,
                  )
                  : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: Text("No image available")),
                  ),
              ElevatedButton(
                onPressed: () async {
                  final pickedImagePath = await _pickerService.pickImage();

                  if (pickedImagePath != null) {
                    setState(() {
                      _imagePath = pickedImagePath;
                    });
                  }
                },
                child: const Text("Change Image"),
              ),
              const SizedBox(height: 16),
              SpeechToTextField(controller: _contentsController),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSide,
                decoration: const InputDecoration(labelText: 'Box Side'),
                items:
                    _boxSides
                        .map(
                          (side) =>
                              DropdownMenuItem(value: side, child: Text(side)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSide = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: 'Position'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
