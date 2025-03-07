import 'package:cold_river_express_app/repositories/inventory_repository.dart';
import 'package:flutter/material.dart';

class FilterModal extends StatefulWidget {
  final String? selectedEnvironment;
  final String? selectedPosition;

  final void Function(String?, String?) onChangeFilter;

  const FilterModal({
    super.key,
    required this.onChangeFilter,
    this.selectedEnvironment,
    this.selectedPosition,
  });

  @override
  FilterModalState createState() => FilterModalState();
}

class FilterModalState extends State<FilterModal> {
  final InventoryRepository _repository = InventoryRepository();

  late String? _selectedEnvironment;
  late String? _selectedPosition;

  final List<String> _labelsEnvironment = [];
  final List<String> _labelsPosition = [];

  @override
  void initState() {
    super.initState();
    _selectedEnvironment = widget.selectedEnvironment;
    _selectedPosition = widget.selectedPosition;
    _loadLabels();
  }

  Future<void> _loadLabels() async {
    final labelsEnvironment = await _repository.getLabelForEnvironment();
    final labelsPosition = await _repository.getLabelForPosition();

    setState(() {
      _labelsEnvironment.addAll(labelsEnvironment);
      _labelsPosition.addAll(labelsPosition);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter Options',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Environment',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 0),
            ),
            isExpanded: true,
            value: _selectedEnvironment,
            icon: const Icon(Icons.arrow_drop_down),
            items:
                _labelsEnvironment.isNotEmpty
                    ? _labelsEnvironment.map((env) {
                      return DropdownMenuItem(value: env, child: Text(env));
                    }).toList()
                    : [],
            onChanged: (val) {
              setState(() {
                _selectedEnvironment = val;
              });
              widget.onChangeFilter(_selectedEnvironment, _selectedPosition);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Position'),
            value: _selectedPosition,
            items:
                _labelsPosition.isNotEmpty
                    ? _labelsPosition
                        .map(
                          (pos) =>
                              DropdownMenuItem(value: pos, child: Text(pos)),
                        )
                        .toList()
                    : [],
            onChanged: (val) {
              setState(() {
                _selectedPosition = val;
              });
              widget.onChangeFilter(_selectedEnvironment, _selectedPosition);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
