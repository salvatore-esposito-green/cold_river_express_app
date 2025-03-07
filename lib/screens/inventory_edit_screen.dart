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
  late TextEditingController _environmentController;

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
    _environmentController = TextEditingController(
      text: widget.inventory.environment,
    );
    _selectedSide = widget.inventory.size;
    _imagePath = widget.inventory.imagePath;
  }

  @override
  void dispose() {
    _contentsController.dispose();
    _positionController.dispose();
    _environmentController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedInventory = widget.inventory.copyWith(
        contents:
            _contentsController.text.split(',').map((s) => s.trim()).toList(),
        position: _positionController.text,
        environment: _environmentController.text,
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
        centerTitle: true,
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
                  _imagePath != null && _imagePath!.isNotEmpty
                      ? Hero(
                        tag: widget.inventory.id,
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
                      onPressed: () async {
                        final pickedImagePath =
                            await _pickerService.pickImage();

                        if (pickedImagePath != null) {
                          setState(() {
                            _imagePath = pickedImagePath;
                          });
                        }
                      },
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      SpeechToTextField(controller: _contentsController),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedSide,
                        decoration: const InputDecoration(
                          labelText: 'Box Side',
                        ),
                        items:
                            _boxSides
                                .map(
                                  (side) => DropdownMenuItem(
                                    value: side,
                                    child: Text(side),
                                  ),
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
                        decoration: const InputDecoration(
                          labelText: 'Position',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _environmentController,
                        decoration: const InputDecoration(
                          labelText: 'Environment',
                        ),
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
            ]),
          ),
        ],
      ),
    );
  }
}
