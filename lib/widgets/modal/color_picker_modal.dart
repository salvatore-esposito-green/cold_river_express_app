import 'package:cold_river_express_app/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerModal extends StatefulWidget {
  const ColorPickerModal({super.key});

  @override
  State<ColorPickerModal> createState() => _ColorPickerModalState();
}

class _ColorPickerModalState extends State<ColorPickerModal> {
  Color selectedColor = AppConfig.primaryColor;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Primary Color', textAlign: TextAlign.center),
      titleTextStyle: TextStyle(
        color: AppConfig.primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: selectedColor,
          onColorChanged: (Color color) {
            selectedColor = color;
          },
          pickerAreaHeightPercent: 0.8,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Select'),
          onPressed: () {
            setState(() {
              AppConfig.updateTheme(selectedColor);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Primary color changed successfully!'),
                duration: Duration(seconds: 2),
              ),
            );

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
