- [Features](features.md)
- [Architecture](architecture.md)
- [Dependencies](dependencies.md)
- [Installation](installation.md)
- [Usage Guide](usage.md)
- [Contributing](contributing.md)

# Installation and Running

Follow these steps to get the project up and running on your local machine:

1.	**Clone the Repository**: Open your terminal or command prompt and run:

```bash
git clone <REPOSITORY_URL>
```

2.	**Install Dependencies**: Run Flutter’s package get command to install all required packages:

```bash
flutter pub get
```

This will download all the dependencies listed in pubspec.yaml.

3. **Run the App**: Launch the app on an emulator or physical device:

```bash
flutter run
```

This will compile the Flutter app and install it on the connected emulator/device.

4. **Additional Platform Setup**:

•	For Android, no additional setup is usually needed beyond enabling Developer Options and USB debugging on a physical device. The Flutter tool will handle deploying the APK to the device/emulator.

•	For iOS, you might need to open the project in Xcode (located in the ios/ folder of the project) to configure signing & capabilities if you plan to run on a physical iPhone. On simulator, simply running flutter run is sufficient.

•	Ensure the camera permission is granted on whichever device you run (the app should prompt for camera access when you first attempt to scan a QR code). Similarly, for Bluetooth, allow location/Bluetooth permissions if prompted, so the app can scan and connect to printers.

After these steps, you should have the app running. You can then add some sample inventory items to test features like search and QR scanning.

