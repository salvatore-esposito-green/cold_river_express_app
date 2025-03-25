import 'package:cold_river_express_app/models/box_size.dart';
import 'package:cold_river_express_app/repositories/box_sizes_repository.dart';
import 'package:cold_river_express_app/widgets/bottom_sheet/custom_box_size_bottom_sheet.dart';
import 'package:flutter/material.dart';

class BoxSizesSelect extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  const BoxSizesSelect({super.key, this.initialValue, this.onChanged});

  @override
  State<BoxSizesSelect> createState() => _BoxSizesSelectState();
}

class _BoxSizesSelectState extends State<BoxSizesSelect> {
  final BoxSizeRepository _boxSizeRepository = BoxSizeRepository();

  String? _selectedBoxSize;
  Future<List<BoxSize>>? _boxSizesFuture;

  @override
  void initState() {
    super.initState();
    _selectedBoxSize = widget.initialValue ?? '';
    _boxSizesFuture = _boxSizeRepository.getBoxSizes();
  }

  Future<void> _refreshBoxSizes(String value) async {
    setState(() {
      _boxSizesFuture = _boxSizeRepository.getBoxSizes();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      isBoxSizeValid(value).then((exists) {
        if (exists != null) {
          _showBoxSizeExistsDialog(value, exists).then((selected) {
            setState(() {
              _selectedBoxSize = selected;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(selected!);
            }
          });

          return;
        }

        setState(() {
          _selectedBoxSize = value;
        });

        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      });
    });
  }

  Future<void> _openCustomSheet() async {
    await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => CustomBoxSizeBottomSheet(
            labelText: 'Enter Custom Box Size',
            onBoxSizeInserted: (value) async {
              await _refreshBoxSizes(value);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BoxSize>>(
      future: _boxSizesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final boxSizes = snapshot.data!;

        final List<String> boxSizeValues =
            boxSizes.map((bs) => bs.value).toSet().toList();

        if (!boxSizeValues.contains('Custom')) {
          boxSizeValues.add('Custom');
        }

        if (_selectedBoxSize == null ||
            _selectedBoxSize!.isEmpty ||
            !boxSizeValues.contains(_selectedBoxSize)) {
          if (boxSizeValues.isNotEmpty) {
            _selectedBoxSize = boxSizeValues.first;
          }
        }

        return DropdownButtonFormField<String>(
          value: _selectedBoxSize,
          decoration: InputDecoration(labelText: 'Box Size'),
          items:
              boxSizeValues.map((sizeValue) {
                return DropdownMenuItem(
                  value: sizeValue,
                  child: Text(sizeValue),
                );
              }).toList(),
          onChanged: (value) async {
            if (value == 'Custom') {
              await _openCustomSheet();
            } else if (value != null && value.isNotEmpty) {
              setState(() {
                _selectedBoxSize = value;
              });

              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            }
          },
          validator:
              (value) =>
                  value == null || value.isEmpty
                      ? 'Please select a box size'
                      : null,
        );
      },
    );
  }

  Future<String?> _showBoxSizeExistsDialog(String value, String exists) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Box Size Exists'),
          content: Text(
            'A box size with these dimensions already exists. ($exists)\nDo you want to use the existing size?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(exists);
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(value);
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
    return result;
  }

  Future<String?> isBoxSizeValid(String value) async {
    if (value.isEmpty) {
      return null;
    }

    final boxSizes = await _boxSizesFuture!;
    List<List<int>> matrix =
        boxSizes
            .map((boxSize) => [boxSize.length, boxSize.width, boxSize.height])
            .toList();

    List<int> target =
        value.split('x').map((e) => int.parse(e.trim())).toList();

    List<List<int>> result = findRowsWithNumbers(matrix, target);

    if (result.isNotEmpty) {
      return result.first.join('x');
    }

    return null;
  }

  List<List<int>> findRowsWithNumbers(
    List<List<int>> matrix,
    List<int> target,
  ) {
    return matrix.where((row) {
      /**
       * Even if there isn't a perfect one-to-one matching for each line,
       * the suggestion remains valid. It is ultimately up to the user to decide whether
       * to accept the suggestion or not.
       */
      return target.every((num) => row.contains(num));
    }).toList();
  }
}
