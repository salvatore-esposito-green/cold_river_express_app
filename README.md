# Flutter Inventory Management App

<div align="center">
	<br>
	<br>
	<picture>
		<source media="(prefers-color-scheme: dark)"
			srcset="https://github.com/salvatore-esposito-green/cold_river_express_app/blob/0cd4f8673de28a5de23619f34aa5161b261312e0/assets/logo/dark.png"
		>
		<img
			alt="logo light mode"
			src="https://github.com/salvatore-esposito-green/cold_river_express_app/blob/0cd4f8673de28a5de23619f34aa5161b261312e0/assets/logo/light.png"
		>
	</picture>
	<br>
	<br>
</div>

## Project Overview

The Flutter Inventory Management App is a mobile application designed to help users efficiently track and manage inventory items. It allows you to add items with details, organize them by location or category, and retrieve information quickly using search and QR code scanning. The app uses a local SQLite database for storage, ensuring your inventory data is available offline and can be easily shared or backed up. This project demonstrates a practical use of Flutter for business needs, combining database CRUD operations, camera integration for QR scanning, and even optional Bluetooth printing for labels.

<div align="center">
	<img alt="Detail View and Bluetooth Printer " src="https://i.ibb.co/QjvSwCwV/IMG-9673.jpg">
</div>

## Features

•	**Add, Edit, and Manage Items**: Create new inventory items with details like name, description, quantity, location, etc. Edit existing items or delete them as needed through a simple user interface.

•	**QR Code Scanning**: Use your device’s camera to scan QR codes associated with inventory items. Scanning a QR code quickly pulls up the corresponding item’s details, making it easy to retrieve information or verify stock.

•	**Full-Text Search with Filters**: Quickly find items using a search bar that supports full-text search through item names and descriptions. Apply filters by **position** (physical location or section) or **environment** (e.g., warehouse, office, cold storage) to narrow down search results and find exactly what you need.

•	**Database Sharing**: The app provides a settings option to share or export the SQLite database file. This allows you to back up your data or transfer the entire inventory to another device. For example, you can email the database file or upload it to cloud storage for safekeeping or collaborative use.

•	**Bluetooth Printing Support** (optional): If you have a compatible Bluetooth thermal printer, the app can connect to it and print inventory labels or summaries. This is useful for printing QR code labels for items or generating receipts of the current inventory list.

## Architecture

The project follows a structured approach, separating concerns into different directories under the `lib/` folder for clarity and maintainability. Below is an overview of the folder structure and their responsibilities:

•	**database/** – Contains database helper classes and utilities for interacting with SQLite. This includes database initialization, table creation scripts, and methods for CRUD operations (create, read, update, delete inventory records).

•	**models/** – Houses Dart data model classes that represent the core objects in the app (e.g., an `Item model` for inventory items). These model classes define the fields for inventory data and may include convenience methods or from/to JSON and SQLite map conversions.

•	**providers/** – Manages state and functionality for external devices or services, such as Bluetooth printers. For instance, a Bluetooth provider class here might handle connecting to a printer, maintaining the connection state, and exposing methods to send print jobs. (The app likely uses Flutter’s Provider package or similar for state management in this context.)

•	**repositories/** – Contains classes that act as an intermediary between the database and the rest of the app. Repository classes fetch data from the SQLite database (using the database helpers) and provide higher-level methods for the app to use, such as getting all items, searching items, or saving an item. This layer helps isolate data access logic.

•	**routes/** – Defines the navigation routes of the application. It includes a centralized configuration of the app’s screens and their route names, making it easy to navigate between different screens (pages) and manage navigation stack in one place.

•	**screens/** – Contains all the UI screens of the app, each typically in its own file or subfolder. Examples include screens for viewing the inventory list, adding or editing an item, scanning a QR code, settings, and any other major views. Each screen is built using Flutter’s widgets and utilizes data from models and providers.

•	**services/** – Provides auxiliary services and utility classes that don’t belong to a single screen or model. Examples include services for handling files (e.g., exporting the database file to share), image utilities (perhaps resizing or saving item photos), or any other helper functions (like formatting data, managing preferences, etc.).

•	**theme/** – Defines the styling and appearance of the app’s user interface. This includes theme data such as colors, font styles, and common UI component styles. By centralizing theme configuration, the app ensures a consistent look and feel across all screens and makes it easy to tweak the UI style from one place.

This architecture makes the app modular and easier to maintain. For example, if changes are needed in how data is stored, they would primarily affect the `database` and `repositories` layers without requiring significant changes to UI code in `screens/`. Similarly, UI design changes might be mostly handled in `screens/` and `theme/` without altering the underlying data logic.

## Dependencies

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

## Installation and Running

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

## Usage Guide

This section explains how to use the key features of the Inventory Management App:

•	**Adding a New Item**: On the main inventory list screen, tap the Add button (“+” floating action button). This opens the Add Item screen where you can enter item details like name, description, quantity, position (location in storage, e.g., “Aisle 3, Shelf B”), and environment (e.g., “Warehouse” or “Office”). Fill in the details and press Save. The item will be stored in the local database and appear in the inventory list.

•	**Editing or Deleting Items**: Tap on an item in your inventory list to view its details. On the item detail screen, use the Edit option (pencil icon or edit button) to modify the item’s information. After making changes, save to update the record in the database. To delete an item, you can currently only do so from the list item in the search page by swiping the item to the left. This will reveal an icon on the right and a red container highlighting the delete action. Confirm the deletion and the item will be removed from the database.

•	**Scanning a QR Code**: Tap the Scan button (QR icon in the app). This opens the camera scanner. Point your device’s camera at the QR code; the app will automatically detect it. Once scanned, the app looks up the code in the database and, if it matches an item, displays that item’s detail screen. This feature makes it quick to retrieve item info without manually searching. The app auto-generates a UUID (Universally Unique Identifier) of type string for each item, which is then used to generate the QR code.

•	**Searching Inventory**: On the inventory list screen, use the search bar at the top to find items. As you type, the app performs a full-text search across item names, descriptions, and other fields. The results update in real time to show matching items. You can also refine your search using filters. For example, use the position filter to only show results from a specific location (select a warehouse section or shelf) or the environment filter to limit results to a certain environment category. Combining filters with text search helps locate items even in a large inventory.

•	**Sharing/Exporting the Database**: In the app’s Settings menu, there is an option to export or share the inventory database. Selecting this option will prepare the SQLite database file (and possibly compress it or rename it for convenience) and open the system share sheet. You can then choose how to share it – for instance, email it to yourself or send via a messaging app. This is useful for creating backups of your data or transferring the inventory to another device. To import the data on another device, you would typically replace the database file in that device’s app directory (this might require a specialized process or a companion import feature, depending on the app’s implementation).

•	**Bluetooth Printing**: On an item’s detail screen, there will be a printer icon at the top right. If the icon is red, it indicates that there is no active connection to a Bluetooth printer. Clicking on the icon will display a submenu with the option "Find Printers". Selecting this option will show the available Bluetooth connections, allowing you to choose one. Once a successful connection is established, the printer icon will turn white, and the "Print Label" button will become active. When you press the "Print Label" button, the printer will generate a label with a sequential number, the QR code, and a text list of the item's contents. This feature is useful for labeling physical items or keeping a hard copy of inventory records.

Explore the app to discover all the features. The UI is designed to be intuitive, with icons and buttons that clearly indicate their function. Tooltips or brief on-screen instructions might be provided for first-time users when accessing features like QR scanning or sharing.

## Contribution Guidelines

Contributions to this project are welcome! If you would like to report issues, suggest improvements, or add new features, please follow these guidelines to contribute:

1.	**Fork the Repository**: Click the “Fork” button on the project’s GitHub page to create your own copy of the repository. Clone your fork to your local machine for development.

2.	**Create a Feature Branch**: Before making changes, create a new branch for your work:

```bash
git checkout -b feature/YourFeatureName
```

Use a descriptive branch name that identifies the feature or fix.

3.	**Implement Your Changes**: Write clear, well-documented code. Try to adhere to the existing code style and project structure. If you add new files, place them in the appropriate directory (models, services, etc.). Keep your functions and classes focused and document any complex logic with comments.

4.	**Test Thoroughly**: Before committing, run the app and test your changes. Ensure that all existing features still work as expected (no regressions). If the project has unit tests or widget tests, run them (flutter test) to verify nothing is broken. Consider writing new tests for any new functionality you add.

5.	**Commit and Push**: Commit your changes with a clear commit message explaining what you did and why. Push the branch to your fork on GitHub.

6.	**Open a Pull Request**: Go to the original repository and open a Pull Request from your fork’s feature branch. Provide a descriptive title and detailed description of your changes in the PR. Explain the problem your contribution addresses or the feature it adds. If there are related issues, reference them in the PR description.

7.	**Code Review**: Collaborate with the maintainers by responding to any code review comments. You might be asked to make adjustments; this is a normal part of the review process to maintain code quality.

8.	**Merge**: Once your PR is approved by the maintainers, it will be merged into the main codebase. You can then sync your fork’s main branch with the upstream repository.

### Additional Tips:

•   Follow the Flutter and Dart best practices. Format your code using dartfmt (or flutter format) and analyze for any linter warnings.

•   Keep contributions focused. If you plan multiple distinct features, prefer separate branches and PRs for each, rather than one large PR.

•   Update documentation: If your contribution changes how a feature works or adds a new feature, consider updating the README or any in-app help text to reflect that.

By following these guidelines, you help ensure the project remains maintainable and that your contributions can be integrated smoothly. Thank you for taking the time to contribute!