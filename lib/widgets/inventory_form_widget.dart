import 'package:cold_river_express_app/controllers/suggestion_controller.dart';
import 'package:cold_river_express_app/repositories/inventory_repository.dart';
import 'package:cold_river_express_app/widgets/autocomplete_field.dart';
import 'package:flutter/material.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/widgets/speech_to_text_field.dart';

typedef OnSubmitCallback = Future<void> Function(Inventory updatedInventory);

class InventoryFormWidget extends StatefulWidget {
  final Inventory? initialInventory;

  final OnSubmitCallback onSubmit;

  final List<String> boxSides;

  final String? imagePath;

  const InventoryFormWidget({
    super.key,
    this.initialInventory,
    required this.onSubmit,
    this.boxSides = const ['60x40x40', '80x40x40', 'Custom'],
    this.imagePath,
  });

  @override
  InventoryFormWidgetState createState() => InventoryFormWidgetState();
}

class InventoryFormWidgetState extends State<InventoryFormWidget> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _contentsController;
  late final TextEditingController _positionController;
  late final TextEditingController _environmentController;
  final SuggestionController _positionSuggestions = SuggestionController(
    suggestions: [],
  );
  final SuggestionController _environmentSuggestions = SuggestionController(
    suggestions: [],
  );

  late String _selectedSide;

  final InventoryRepository _repository = InventoryRepository();

  @override
  void initState() {
    super.initState();
    _contentsController = TextEditingController(
      text: widget.initialInventory?.contents.join(', ') ?? '',
    );
    _positionController = TextEditingController(
      text: widget.initialInventory?.position ?? '',
    );
    _environmentController = TextEditingController(
      text: widget.initialInventory?.environment ?? '',
    );
    _selectedSide = widget.initialInventory?.size ?? widget.boxSides.first;

    _loadPositionSuggestions();
    _loadEnvironmentSuggestions();
  }

  @override
  void dispose() {
    _contentsController.dispose();
    _positionController.dispose();
    _environmentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedInventory = Inventory(
        id: widget.initialInventory?.id ?? '',
        box_number: widget.initialInventory?.box_number ?? '',
        contents:
            _contentsController.text.split(',').map((s) => s.trim()).toList(),
        position: _positionController.text,
        environment: _environmentController.text,
        size: _selectedSide,
        image_path: widget.imagePath,
        last_updated: DateTime.now(),
      );
      await widget.onSubmit(updatedInventory);
    }
  }

  Future<void> _loadPositionSuggestions() async {
    final positions = await _repository.getLabelForPosition();

    setState(() {
      _positionSuggestions.updateSuggestions(positions);
    });
  }

  Future<void> _loadEnvironmentSuggestions() async {
    final environments = await _repository.getLabelForEnvironment();

    setState(() {
      _environmentSuggestions.updateSuggestions(environments);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 16),
          SpeechToTextField(controller: _contentsController),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedSide,
            decoration: const InputDecoration(labelText: 'Box Side'),
            items:
                widget.boxSides
                    .map(
                      (side) =>
                          DropdownMenuItem(value: side, child: Text(side)),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _selectedSide = value ?? ''),
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? 'Please select a box side'
                        : null,
          ),
          const SizedBox(height: 16),
          AutocompleteFormField(
            controller: _positionController,
            labelText: 'Position',
            suggestionController: _positionSuggestions,
          ),
          const SizedBox(height: 16),
          AutocompleteFormField(
            controller: _environmentController,
            labelText: 'Environment',
            suggestionController: _environmentSuggestions,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _handleSubmit,
            child: Text(widget.initialInventory == null ? "Insert" : "Save"),
          ),
        ],
      ),
    );
  }
}
