import 'dart:html' as html;
import 'dart:convert';
import 'package:cold_river_express_app/core/interfaces/database_service_interface.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/models/box_size.dart';
import 'package:flutter/foundation.dart';

/// Implementazione web del servizio Database usando localStorage
/// Nota: localStorage ha un limite di ~5-10MB. Per database più grandi considerare IndexedDB
class DatabaseServiceWeb implements DatabaseServiceInterface {
  static const String _inventoryKey = 'inventories';
  static const String _boxSizesKey = 'box_sizes';
  static const String _deletedInventoryKey = 'deleted_inventories';

  @override
  Future<void> initialize() async {
    if (kDebugMode) {
      print('Web Database: Initialized with localStorage');
    }
  }

  @override
  Future<void> close() async {
    // localStorage non richiede chiusura
  }

  List<Inventory> _getInventoriesFromStorage() {
    final jsonString = html.window.localStorage[_inventoryKey];
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Inventory.fromMap(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading inventories from localStorage: $e');
      }
      return [];
    }
  }

  void _saveInventoriesToStorage(List<Inventory> inventories) {
    final jsonString = jsonEncode(inventories.map((inv) => inv.toMap()).toList());
    html.window.localStorage[_inventoryKey] = jsonString;
  }

  List<Inventory> _getDeletedInventoriesFromStorage() {
    final jsonString = html.window.localStorage[_deletedInventoryKey];
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Inventory.fromMap(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading deleted inventories from localStorage: $e');
      }
      return [];
    }
  }

  void _saveDeletedInventoriesToStorage(List<Inventory> inventories) {
    final jsonString = jsonEncode(inventories.map((inv) => inv.toMap()).toList());
    html.window.localStorage[_deletedInventoryKey] = jsonString;
  }

  @override
  Future<int> insertInventory(Inventory inventory) async {
    final inventories = _getInventoriesFromStorage();
    inventories.add(inventory);
    _saveInventoriesToStorage(inventories);
    return 1; // Successo
  }

  @override
  Future<List<Inventory>> getInventories() async {
    return _getInventoriesFromStorage();
  }

  @override
  Future<Inventory?> getInventory(String id) async {
    final inventories = _getInventoriesFromStorage();
    try {
      return inventories.firstWhere((inv) => inv.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> updateInventory(Inventory inventory) async {
    final inventories = _getInventoriesFromStorage();
    final index = inventories.indexWhere((inv) => inv.id == inventory.id);

    if (index != -1) {
      inventories[index] = inventory;
      _saveInventoriesToStorage(inventories);
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteInventory(String id) async {
    final inventories = _getInventoriesFromStorage();
    final deletedInventories = _getDeletedInventoriesFromStorage();

    final index = inventories.indexWhere((inv) => inv.id == id);
    if (index != -1) {
      final inventory = inventories.removeAt(index);
      deletedInventories.add(inventory);
      _saveInventoriesToStorage(inventories);
      _saveDeletedInventoriesToStorage(deletedInventories);
      return 1;
    }
    return 0;
  }

  @override
  Future<void> archiveInventory(String id) async {
    await deleteInventory(id);
  }

  @override
  Future<void> recoverInventory(String id) async {
    final deletedInventories = _getDeletedInventoriesFromStorage();
    final inventories = _getInventoriesFromStorage();

    final index = deletedInventories.indexWhere((inv) => inv.id == id);
    if (index != -1) {
      final inventory = deletedInventories.removeAt(index);
      inventories.add(inventory);
      _saveInventoriesToStorage(inventories);
      _saveDeletedInventoriesToStorage(deletedInventories);
    }
  }

  @override
  Future<List<Inventory>> getDeletedInventories() async {
    return _getDeletedInventoriesFromStorage();
  }

  @override
  Future<void> deleteAllInventories() async {
    final inventories = _getInventoriesFromStorage();
    final deletedInventories = _getDeletedInventoriesFromStorage();

    deletedInventories.addAll(inventories);
    _saveInventoriesToStorage([]);
    _saveDeletedInventoriesToStorage(deletedInventories);
  }

  @override
  Future<void> restoreAllInventories() async {
    final deletedInventories = _getDeletedInventoriesFromStorage();
    final inventories = _getInventoriesFromStorage();

    inventories.addAll(deletedInventories);
    _saveInventoriesToStorage(inventories);
    _saveDeletedInventoriesToStorage([]);
  }

  @override
  Future<List<Inventory>> freeSearchInventory(String query) async {
    final inventories = _getInventoriesFromStorage();
    final lowerQuery = query.toLowerCase();

    return inventories.where((inv) {
      return inv.box_number.toLowerCase().contains(lowerQuery) ||
             inv.contents.any((content) => content.toLowerCase().contains(lowerQuery)) ||
             (inv.environment?.toLowerCase().contains(lowerQuery) ?? false) ||
             (inv.position?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  @override
  Future<List<Inventory>> filterInventory(String? environment, String? position) async {
    final inventories = _getInventoriesFromStorage();

    return inventories.where((inv) {
      bool matchesEnvironment = environment == null || inv.environment == environment;
      bool matchesPosition = position == null || inv.position == position;
      return matchesEnvironment && matchesPosition;
    }).toList();
  }

  @override
  Future<void> updateInventoriesPosition(List<String> ids, String position) async {
    final inventories = _getInventoriesFromStorage();

    for (var id in ids) {
      final index = inventories.indexWhere((inv) => inv.id == id);
      if (index != -1) {
        inventories[index] = inventories[index].copyWith(
          position: position,
        );
      }
    }

    _saveInventoriesToStorage(inventories);
  }

  @override
  Future<List<String>> getLabelForEnvironment() async {
    final inventories = _getInventoriesFromStorage();
    return inventories
        .where((inv) => inv.environment != null && inv.environment!.isNotEmpty)
        .map((inv) => inv.environment!)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  Future<List<String>> getLabelForPosition() async {
    final inventories = _getInventoriesFromStorage();
    return inventories
        .where((inv) => inv.position != null && inv.position!.isNotEmpty)
        .map((inv) => inv.position!)
        .toSet()
        .toList()
      ..sort();
  }

  List<BoxSize> _getBoxSizesFromStorage() {
    final jsonString = html.window.localStorage[_boxSizesKey];
    if (jsonString == null || jsonString.isEmpty) {
      // Ritorna box sizes di default
      return [
        BoxSize(id: 1, width: 10, length: 10, height: 10),
        BoxSize(id: 2, width: 20, length: 15, height: 10),
        BoxSize(id: 3, width: 30, length: 20, height: 15),
      ];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => BoxSize.fromMap(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading box sizes from localStorage: $e');
      }
      return [];
    }
  }

  void _saveBoxSizesToStorage(List<BoxSize> boxSizes) {
    final jsonString = jsonEncode(boxSizes.map((bs) => bs.toMap()).toList());
    html.window.localStorage[_boxSizesKey] = jsonString;
  }

  @override
  Future<List<BoxSize>> getBoxSizes() async {
    return _getBoxSizesFromStorage();
  }

  @override
  Future<int> insertBoxSize(BoxSize boxSize) async {
    final boxSizes = _getBoxSizesFromStorage();

    // Genera un nuovo ID
    final int newId = boxSizes.isEmpty ? 1 : boxSizes.map((bs) => bs.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    final newBoxSize = BoxSize(
      id: newId,
      width: boxSize.width,
      length: boxSize.length,
      height: boxSize.height,
    );

    boxSizes.add(newBoxSize);
    _saveBoxSizesToStorage(boxSizes);
    return newId;
  }

  @override
  Future<int> deleteBoxSize(int id) async {
    final boxSizes = _getBoxSizesFromStorage();
    final initialLength = boxSizes.length;

    boxSizes.removeWhere((bs) => bs.id == id);

    if (boxSizes.length < initialLength) {
      _saveBoxSizesToStorage(boxSizes);
      return 1;
    }
    return 0;
  }

  @override
  Future<bool> createBackup() async {
    // Esporta tutto il localStorage come JSON
    try {
      final backup = {
        'inventories': html.window.localStorage[_inventoryKey] ?? '[]',
        'box_sizes': html.window.localStorage[_boxSizesKey] ?? '[]',
        'deleted_inventories': html.window.localStorage[_deletedInventoryKey] ?? '[]',
      };

      final jsonString = jsonEncode(backup);
      final blob = html.Blob([jsonString], 'application/json');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'cold_river_backup_${DateTime.now().millisecondsSinceEpoch}.json')
        ..click();

      html.Url.revokeObjectUrl(url);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating backup: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> replaceDatabase(String backupFilePath) async {
    // TODO: Implementare import da file
    // Richiede file picker che non è implementato in questo stub
    return false;
  }

  @override
  Future<String?> getCurrentDbPath() async {
    return 'localstorage://cold_river_inventory';
  }

  @override
  Future<void> updateImagePath(String oldPath, String newPath) async {
    final inventories = _getInventoriesFromStorage();
    bool updated = false;

    for (int i = 0; i < inventories.length; i++) {
      if (inventories[i].image_path == oldPath) {
        inventories[i] = inventories[i].copyWith(
          image_path: newPath,
        );
        updated = true;
      }
    }

    if (updated) {
      _saveInventoriesToStorage(inventories);
    }
  }
}
