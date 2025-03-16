import 'package:cold_river_express_app/models/box_size.dart';
import 'package:cold_river_express_app/repositories/box_sizes_repository.dart';
import 'package:flutter/material.dart';

class CustomBoxSizeBottomSheet extends StatefulWidget {
  final String labelText;

  final Future<void> Function(String value)? onBoxSizeInserted;

  const CustomBoxSizeBottomSheet({
    super.key,
    required this.labelText,
    this.onBoxSizeInserted,
  });

  @override
  CustomBoxSizeBottomSheetState createState() =>
      CustomBoxSizeBottomSheetState();
}

class CustomBoxSizeBottomSheetState extends State<CustomBoxSizeBottomSheet> {
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _confirm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final int length = int.parse(_lengthController.text);
      final int width = int.parse(_widthController.text);
      final int height = int.parse(_heightController.text);

      final BoxSize boxSize = BoxSize(
        length: length,
        width: width,
        height: height,
      );

      await BoxSizeRepository().insertBoxSize(boxSize);

      if (widget.onBoxSizeInserted != null) {
        await widget.onBoxSizeInserted!(boxSize.value);
      }

      Navigator.of(context).pop(boxSize.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SizedBox(
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.labelText,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lengthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Length (cm)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter length';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _widthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Width (cm)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter width';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter height';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const Spacer(),
              ElevatedButton(onPressed: _confirm, child: const Text('Confirm')),
            ],
          ),
        ),
      ),
    );
  }
}
