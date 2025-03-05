import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  final TextEditingController _boxNumberController = TextEditingController();
  final TextEditingController _contentsController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  String? _selectedSide = '60x40x40';
  String? _imagePath;

  final List<String> _boxSides = ['60x40x40', '80x40x40', 'Custom'];

  final InventoryRepository _repository = InventoryRepository();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? media = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 768,
        imageQuality: 80,
      );

      if (media != null) {
        setState(() {
          _imagePath = media.path;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  List<String> _parseContents(String text) {
    return text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      var uuid = Uuid();
      String id = uuid.v4();

      List<String> contentsList = _parseContents(_contentsController.text);

      Inventory newInventory = Inventory(
        id: id,
        boxNumber: _boxNumberController.text,
        contents: contentsList,
        imagePath: _imagePath ?? '',
        size: _selectedSide ?? _boxSides.first,
        position: _positionController.text,
        lastUpdated: DateTime.now(),
      );

      await _repository.addInventory(newInventory);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Inventory item added!')));

        setState(() {
          _boxNumberController.clear();
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
    _boxNumberController.dispose();
    _contentsController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Insert Inventory')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _boxNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Box Number'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a box number'
                            : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contentsController,
                decoration: InputDecoration(
                  labelText: 'Contents',
                  hintText:
                      'Enter items separated by commas, e.g. item1, item2, item3',
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter contents'
                            : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _imagePath == null
                          ? 'No image selected'
                          : 'Image selected',
                    ),
                  ),
                  IconButton(icon: Icon(Icons.image), onPressed: _pickImage),
                ],
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSide,
                decoration: InputDecoration(labelText: 'Box Side'),
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
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a position'
                            : null,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Insert Inventory'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
