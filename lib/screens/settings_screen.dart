import 'package:cold_river_express_app/config/app_config.dart';
import 'package:cold_river_express_app/widgets/platform_image.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> shareDatabase(BuildContext context) async {
    final sharedRes = await _fileService.shareDatabase();

    if (!mounted) return;

    if (sharedRes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb
              ? 'Database exported successfully!'
              : 'Database shared successfully!',
          ),
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

  Future<void> importDatabase(BuildContext context) async {
    // Mostra un dialog di conferma
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Import Database'),
        content: Text(
          'This will replace all current data with the imported backup. '
          'Make sure you have exported your current data before proceeding.\n\n'
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final importRes = await _fileService.importDatabase();

    if (!mounted) return;

    if (importRes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database imported successfully! Please reload the app.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error importing the database.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickNewLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (!mounted) return;

    if (pickedFile != null) {
      await AppConfig.saveLogoPath(pickedFile.path);

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logo changed successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteLogo() async {
    await AppConfig.resetLogoPath();

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logo removed successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Share'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.upload_file),
              title: Text(kIsWeb ? 'Export Database' : 'Share Database'),
              subtitle: Text(
                kIsWeb
                  ? 'Download a backup of your data and images.'
                  : 'Export and share your app database.',
              ),
              onTap: () {
                shareDatabase(context);
              },
            ),
            if (kIsWeb) ...[
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.download),
                title: Text('Import Database'),
                subtitle: Text('Restore data from a backup file.'),
                onTap: () {
                  importDatabase(context);
                },
              ),
            ],
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
                        return PlatformImage(
                          imagePath: AppConfig.logoPath,
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
