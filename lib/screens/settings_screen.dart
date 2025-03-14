import 'dart:io';

import 'package:cold_river_express_app/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:cold_river_express_app/services/file_service.dart';
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FileService _fileService = FileService();

  final TextEditingController _appNameController = TextEditingController(
    text: AppConfig.appName,
  );

  Future<void> shareDatabase(BuildContext context) async {
    final sharedRes = await _fileService.shareDatabase();

    if (sharedRes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database shared successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error sharing the database.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

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
  void dispose() {
    _appNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Options',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share Database'),
              subtitle: Text('Export and share your app database.'),
              onTap: () {
                shareDatabase(context);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Customize',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _appNameController,
              decoration: const InputDecoration(
                labelText: 'App Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  AppConfig.appName = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Logo:', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(width: 16),
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
                const SizedBox(width: 16),
                IconButton(icon: Icon(Icons.edit), onPressed: _pickNewLogo),
                IconButton(icon: Icon(Icons.delete), onPressed: _deleteLogo),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (AppConfig.logoPath.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  AppConfig.logoPath,
                  fit: BoxFit.contain,
                  height: 25,
                  width: 25,
                ),
              ),
            SizedBox(width: 2),
            Text('${DateTime.now().year} ${AppConfig.appName}'),
          ],
        ),
      ),
    );
  }
}
