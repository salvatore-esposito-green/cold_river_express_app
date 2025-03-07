import 'dart:io';

import 'package:cold_river_express_app/services/image_picking_service.dart';
import 'package:cold_river_express_app/widgets/speech_to_text_field.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/repositories/inventory_repository.dart';

class InventoryInsertScreen extends StatefulWidget {
  const InventoryInsertScreen({super.key});

  @override
  InventoryInsertScreenState createState() => InventoryInsertScreenState();
}

class InventoryInsertScreenState extends State<InventoryInsertScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _contentsController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _environmentController = TextEditingController();

  String? _selectedSide = '60x40x40';
  String? _imagePath;

  final List<String> _boxSides = ['60x40x40', '80x40x40', 'Custom'];

  final InventoryRepository _repository = InventoryRepository();
  final ImagePickingService _imagePickingService = ImagePickingService();

  @override
  void initState() {
    super.initState();
  }

  List<String> _parseContents(String text) {
    return text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<int> _getNextBoxNumber() async {
    List<Inventory> inventories = await _repository.fetchAllInventories();
    if (inventories.isEmpty) return 1;

    int maxBoxNumber = inventories
        .map((inv) => int.tryParse(inv.boxNumber) ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return maxBoxNumber + 1;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      var uuid = Uuid();
      String id = uuid.v4();

      int nextBoxNumber = await _getNextBoxNumber();

      List<String> contentsList = _parseContents(_contentsController.text);

      Inventory newInventory = Inventory(
        id: id,
        boxNumber: nextBoxNumber.toString(),
        contents: contentsList,
        imagePath: _imagePath ?? '',
        size: _selectedSide ?? _boxSides.first,
        position: _positionController.text,
        environment: _environmentController.text,
        lastUpdated: DateTime.now(),
      );

      await _repository.addInventory(newInventory);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Inventory item added!')));

        setState(() {
          _contentsController.clear();
          _positionController.clear();
          _imagePath = null;
          _selectedSide = null;
        });

        Navigator.pushReplacementNamed(
          context,
          '/details',
          arguments: newInventory,
        );
      }
    }
  }

  @override
  void dispose() {
    _contentsController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Insert Inventory'), centerTitle: true),
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
                        tag: _imagePath!,
                        transitionOnUserGestures: true,
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
                        var imagePath = await _imagePickingService.pickImage();

                        if (imagePath != null) {
                          setState(() {
                            _imagePath = imagePath;
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
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedSide,
                        decoration: InputDecoration(labelText: 'Box Side'),
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
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please select a box side'
                                    : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _positionController,
                        decoration: InputDecoration(labelText: 'Position'),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _environmentController,
                        decoration: InputDecoration(labelText: 'Environment'),
                      ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Insert'),
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
