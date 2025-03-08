import 'package:flutter/material.dart';
import 'package:cold_river_express_app/services/file_service.dart';

class SettingsScreen extends StatelessWidget {
  final FileService _fileService = FileService();

  SettingsScreen({super.key});

  Future<void> shareDatabase(BuildContext context) async {
    final sharedRes = await _fileService.shareDatabase();

    if (sharedRes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database condiviso con successo!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Errore durante la condivisione del database.'),
        duration: Duration(seconds: 2),
      ),
    );
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
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/icons/icon-appbar.png',
                fit: BoxFit.contain,
                height: 25,
                width: 25,
              ),
            ),
            SizedBox(width: 2),
            Text('2025 Cold River Express'),
          ],
        ),
      ),
    );
  }
}
