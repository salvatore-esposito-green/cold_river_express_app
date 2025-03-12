- [Features](features.md)
- [Architecture](architecture.md)
- [Dependencies](dependencies.md)
- [Installation](installation.md)
- [Usage Guide](usage.md)
- [Contributing](contributing.md)
- [Customization](customization.md)

# Usage Guide

This section explains how to use the key features of the Inventory Management App:

•	**Adding a New Item**: On the main inventory list screen, tap the Add button (“+” floating action button). This opens the Add Item screen where you can enter item details like name, description, quantity, position (location in storage, e.g., “Aisle 3, Shelf B”), and environment (e.g., “Warehouse” or “Office”). Fill in the details and press Save. The item will be stored in the local database and appear in the inventory list.

•	**Editing or Deleting Items**: Tap on an item in your inventory list to view its details. On the item detail screen, use the Edit option (pencil icon or edit button) to modify the item’s information. After making changes, save to update the record in the database. To delete an item, you can currently only do so from the list item in the search page by swiping the item to the left. This will reveal an icon on the right and a red container highlighting the delete action. Confirm the deletion and the item will be removed from the database.

•	**Scanning a QR Code**: Tap the Scan button (QR icon in the app). This opens the camera scanner. Point your device’s camera at the QR code; the app will automatically detect it. Once scanned, the app looks up the code in the database and, if it matches an item, displays that item’s detail screen. This feature makes it quick to retrieve item info without manually searching. The app auto-generates a UUID (Universally Unique Identifier) of type string for each item, which is then used to generate the QR code.

•	**Searching Inventory**: On the inventory list screen, use the search bar at the top to find items. As you type, the app performs a full-text search across item names, descriptions, and other fields. The results update in real time to show matching items. You can also refine your search using filters. For example, use the position filter to only show results from a specific location (select a warehouse section or shelf) or the environment filter to limit results to a certain environment category. Combining filters with text search helps locate items even in a large inventory.

•	**Sharing/Exporting the Database**: In the app’s Settings menu, there is an option to export or share the inventory database. Selecting this option will prepare the SQLite database file (and possibly compress it or rename it for convenience) and open the system share sheet. You can then choose how to share it – for instance, email it to yourself or send via a messaging app. This is useful for creating backups of your data or transferring the inventory to another device. To import the data on another device, you would typically replace the database file in that device’s app directory (this might require a specialized process or a companion import feature, depending on the app’s implementation).

•	**Bluetooth Printing**: On an item’s detail screen, there will be a printer icon at the top right. If the icon is red, it indicates that there is no active connection to a Bluetooth printer. Clicking on the icon will display a submenu with the option "Find Printers". Selecting this option will show the available Bluetooth connections, allowing you to choose one. Once a successful connection is established, the printer icon will turn white, and the "Print Label" button will become active. When you press the "Print Label" button, the printer will generate a label with a sequential number, the QR code, and a text list of the item's contents. This feature is useful for labeling physical items or keeping a hard copy of inventory records.

Explore the app to discover all the features. The UI is designed to be intuitive, with icons and buttons that clearly indicate their function. Tooltips or brief on-screen instructions might be provided for first-time users when accessing features like QR scanning or sharing.

