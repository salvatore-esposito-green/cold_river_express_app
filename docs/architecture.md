- [Features](features.md)
- [Architecture](architecture.md)
- [Dependencies](dependencies.md)
- [Installation](installation.md)
- [Usage Guide](usage.md)
- [Contributing](contributing.md)
- [Customization](customization.md)

# Architecture

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
