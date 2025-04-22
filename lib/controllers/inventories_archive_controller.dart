import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/repositories/inventory_repository.dart';
import 'package:flutter/material.dart';

class InventoriesArchiveController extends ChangeNotifier {
  final InventoryRepository _repository = InventoryRepository();

  List<Inventory> inventories = [];
  bool isLoading = false;

  Future<void> loadInventories() async {
    isLoading = true;
    notifyListeners();

    try {
      final List<Inventory> allInventories =
          await _repository.getDeletedInventories();

      inventories = allInventories;
    } catch (e) {
      print('Error loading archived inventories: $e');
      inventories = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInventory(String inventoryId) async {
    await _repository.deleteInventoryById(inventoryId);
    await loadInventories();
  }

  Future<void> restoreInventory(String inventoryId) async {
    await _repository.restoreInventoryById(inventoryId);
    await loadInventories();
  }

  Future<void> deleteAllInventories() async {
    await _repository.deleteAllInventories();
    await loadInventories();
  }

  Future<void> restoreAllInventories() async {
    await _repository.restoreAllInventories();
    await loadInventories();
  }
}
