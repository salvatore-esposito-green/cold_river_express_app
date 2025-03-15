import 'package:cold_river_express_app/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChangeLogoModal extends StatefulWidget {
  const ChangeLogoModal({super.key});

  @override
  State<ChangeLogoModal> createState() => _ChangeLogoModalState();
}

class _ChangeLogoModalState extends State<ChangeLogoModal> {
  Color selectedColor = AppConfig.primaryColor;

  Future<void> _pickNewLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        AppConfig.logoPath = pickedFile.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logo changed successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteLogo() async {
    setState(() {
      AppConfig.logoPath = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logo removed successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Logo', textAlign: TextAlign.center),
      titleTextStyle: TextStyle(
        color: AppConfig.primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      content: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppConfig.logoPath.isNotEmpty
                ? Image.asset(
                  AppConfig.logoPath,
                  height: 50,
                  width: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.file(
                      File(AppConfig.logoPath),
                      height: 50,
                      width: 50,
                    );
                  },
                )
                : const Icon(Icons.image, size: 50),
            if (AppConfig.logoPath.isNotEmpty) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.clear_rounded),
                onPressed: _deleteLogo,
              ),
            ],
          ],
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
          child: const Text('Change'),
          onPressed: () async {
            await _pickNewLogo();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Logo changed successfully!'),
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
