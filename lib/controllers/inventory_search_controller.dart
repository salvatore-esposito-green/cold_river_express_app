import 'package:flutter/material.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/repositories/inventory_repository.dart';

class InventorySearchController extends ChangeNotifier {
  final InventoryRepository _repository = InventoryRepository();

  List<Inventory> inventories = [];
  List<String> selectedInventoryIds = [];
  bool isLoading = false;
  String? selectedEnvironment;
  String? selectedPosition;
  String query = '';

  Future<void> loadInventories() async {
    isLoading = true;
    notifyListeners();

    List<Inventory> items;
    if (query.trim().isEmpty) {
      items = await _repository.fetchAllInventories();
    } else {
      items = await _repository.freeSearchInventory(query.trim());
    }

    if (selectedEnvironment != null || selectedPosition != null) {
      items =
          items.where((inventory) {
            final matchesEnvironment =
                selectedEnvironment == null ||
                inventory.environment == selectedEnvironment;
            final matchesPosition =
                selectedPosition == null ||
                inventory.position == selectedPosition;
            return matchesEnvironment && matchesPosition;
          }).toList();
    }

    inventories = items;
    isLoading = false;
    selectedInventoryIds.clear();
    notifyListeners();
  }

  void onSearchChanged(String value) {
    query = value;
    loadInventories();
  }

  Future<void> updateInventoriesPositions(String newPositions) async {
    await _repository.updateInventoriesPosition(
      selectedInventoryIds,
      newPositions,
    );
    selectedInventoryIds.clear();
    await loadInventories();
  }

  void toggleSelectInventory(String inventoryId) {
    if (selectedInventoryIds.contains(inventoryId)) {
      selectedInventoryIds.remove(inventoryId);
    } else {
      selectedInventoryIds.add(inventoryId);
    }
    notifyListeners();
  }

  Future<void> changeFilter(String? environment, String? position) async {
    selectedEnvironment = environment;
    selectedPosition = position;
    await loadInventories();
  }

  Future<void> clearFilter() async {
    selectedEnvironment = null;
    selectedPosition = null;
    query = '';
    await loadInventories();
  }

  Future<void> deleteInventory(String inventoryId) async {
    await _repository.deleteInventoryById(inventoryId);
    await loadInventories();
  }
}
