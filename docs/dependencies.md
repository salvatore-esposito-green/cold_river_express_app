- [Features](features.md)
- [Architecture](architecture.md)
- [Dependencies](dependencies.md)
- [Installation](installation.md)
- [Usage Guide](usage.md)
- [Contributing](contributing.md)

# Dependencies

The app relies on several Flutter packages (plugins) to implement its functionality. Below is a list of key dependencies you need to have in the project (specified in `pubspec.yaml`):

•	**Flutter SDK (stable channel)** – The app is built with Flutter, so ensure you have the appropriate Flutter version installed.

•	**sqflite** – Used for SQLite database operations. This plugin enables creating the local database, running queries, and managing data persistence on the device.

•	**path_provider** – Helps in locating the device directories (e.g., documents folder) to store and access the SQLite database file. It’s often used in tandem with sqflite to get the correct file path.

•	**provider** (or Riverpod) – Used for state management, particularly to handle the Bluetooth printer state and possibly other app-wide state like theme or settings. This allows different parts of the app to listen to changes (e.g., printer connection status).

•	**QR code scanner plugin** – A camera QR scanning library such as `qr_code_scanner` or `mobile_scanner` is used to scan QR codes. This provides a widget to show the camera preview and detect QR codes, returning the scanned data to the app.

•	**share_plus** – (If using for database sharing) Allows sharing files and text with other apps. This is used to share the SQLite database file via email or other share targets.

•	**bluetooth printer plugin** – A Flutter plugin to handle Bluetooth printing (for example, `esc_pos_bluetooth` or `bluetooth_print`). This is used to discover Bluetooth printers, connect to them, and send print jobs (such as printing text or QR code images for labels).

•	**Other utilities** – The app may include other common packages like `image_picker` (if the app allows adding images for items via camera or gallery), and Flutter’s `cupertino_icons` for icons. All required packages are listed in the `pubspec.yaml` file.

Make sure to run flutter pub get after cloning the project to install all these dependencies.

