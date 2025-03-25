import 'package:cold_river_express_app/config/app_config.dart';
import 'package:cold_river_express_app/database/migrate_images_from_caches.dart';
import 'package:cold_river_express_app/repositories/inventory_repository.dart';
import 'package:cold_river_express_app/services/bottom_sheet_service.dart';
import 'package:cold_river_express_app/utils/get_app_info.dart';
import 'package:cold_river_express_app/widgets/modal/change_logo_modal.dart';
import 'package:cold_river_express_app/widgets/modal/color_picker_modal.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {
  InventoryRepository inventoryRepository = InventoryRepository();

  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();

    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final appInfo = await getAppInfo();

    setState(() {
      _version = appInfo['version'] ?? '';
      _buildNumber = appInfo['buildNumber'] ?? '';
    });
  }

  Future<void> _pickPrimaryColor() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ColorPickerModal();
      },
    );
  }

  void _openAppNameDialog(BuildContext context) async {
    final TextEditingController appNameController = TextEditingController(
      text: AppConfig.appName,
    );

    await openCustomBottomSheet(
      context: context,
      labelText: 'Enter new app name',
      controller: appNameController,
      suggestionController: null,
      onConfirm: (String value) {
        setState(() {
          AppConfig.appName = value;
        });
      },
      showConfirmButton: true,
    );
  }

  Future<void> _changeLogo() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangeLogoModal();
      },
    );
  }

  Future<void> importBackup() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      String backupFilePath = result.files.single.path!;
      try {
        await inventoryRepository.replaceInventory(backupFilePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup imported successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing backup: $e'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No file selected for import.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      clipBehavior: Clip.none,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Customize Your App',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                Text(
                  'Version: $_version - Build ($_buildNumber)',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),

          SwitchListTile(
            thumbIcon: WidgetStateProperty.all(
              Icon(AppConfig.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            ),
            title: const Text('Dark Mode'),
            value: AppConfig.isDarkMode,
            onChanged: (bool value) {
              setState(() {
                AppConfig.toggleDarkMode(value);
              });
            },
          ),
          ListTile(
            title: const Text('App Name'),
            onTap: () => _openAppNameDialog(context),
          ),
          ListTile(
            title: const Text('Primary Color'),
            onTap: _pickPrimaryColor,
          ),
          ListTile(title: const Text('Logo'), onTap: _changeLogo),
          ListTile(title: const Text('Backup'), onTap: importBackup),
          ListTile(
            title: const Text('Migrate Images From Caches'),
            onTap: () => migrateCacheImagesAndUpdateDB(),
          ),
        ],
      ),
    );
  }
}
