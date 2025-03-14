import 'package:cold_river_express_app/config/app_config.dart';
import 'package:cold_river_express_app/services/bottom_sheet_service.dart';
import 'package:cold_river_express_app/widgets/color_picker_modal.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {
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
            child: Center(
              child: Text(
                'Customize Your App',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
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
        ],
      ),
    );
  }
}
