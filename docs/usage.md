- [Features](features.md)
- [Architecture](architecture.md)
- [Dependencies](dependencies.md)
- [Installation](installation.md)
- [Usage Guide](usage.md)
- [Contributing](contributing.md)
- [Customization](customization.md)

# Usage Guide

This section explains how to use the key features of the Inventory Management App:

*   **Adding a New Item**: On the main inventory list screen, tap the Add button (“+” floating action button). This opens the Add Item screen where you can enter item details like name, description, quantity, position (location in storage, e.g., “Aisle 3, Shelf B”), and environment (e.g., “Warehouse” or “Office”). Fill in the details and press Save. The item will be stored in the local database and appear in the inventory list.

*   **Editing Items**: Tap on an item in your inventory list to view its details. On the item detail screen, use the Edit option (pencil icon or edit button) to modify the item’s information. After making changes, save to update the record in the database.

*   **Deleting Items (Soft Delete)**: To delete an item from the list on the search page, swipe the item to the left. This action will reveal a delete option and trigger a **confirmation dialog**.
    *   **Confirmation**: The dialog asks you to confirm if you really want to delete the item. This step prevents accidental deletions.
    *   **Soft Delete**: If you confirm, the item is **not permanently removed** from the database. Instead, it is marked as "deleted" (soft-deleted) and hidden from the main inventory list. This allows for potential recovery in the future if needed and prevents data loss from accidental swipes. Tap "Cancel" in the dialog to abort the deletion.

*   **Scanning a QR Code**: Tap the Scan button (QR icon in the app). This opens the camera scanner. Point your device’s camera at the QR code; the app will automatically detect it. Once scanned, the app looks up the code in the database and, if it matches an item, displays that item’s detail screen. This feature makes it quick to retrieve item info without manually searching. The app auto-generates a UUID (Universally Unique Identifier) of type string for each item, which is then used to generate the QR code.

*   **Searching Inventory**: On the inventory list screen, use the search bar at the top to find items. As you type, the app performs a full-text search across item names, descriptions, and other fields. The results update in real time to show matching items. You can also refine your search using filters. For example, use the position filter to only show results from a specific location (select a warehouse section or shelf) or the environment filter to limit results to a certain environment category. Combining filters with text search helps locate items even in a large inventory.

*   **Sharing/Exporting the Database**: In the app’s Settings menu, there is an option to export or share the inventory database. Selecting this option will prepare the SQLite database file (and possibly compress it or rename it for convenience) and open the system share sheet. You can then choose how to share it – for instance, email it to yourself or send via a messaging app. This is useful for creating backups of your data or transferring the inventory to another device. To import the data on another device, you would typically replace the database file in that device’s app directory (this might require a specialized process or a companion import feature, depending on the app’s implementation).

Explore the app to discover all the features. The UI is designed to be intuitive, with icons and buttons that clearly indicate their function. Tooltips or brief on-screen instructions might be provided for first-time users when accessing features like QR scanning or sharing.

