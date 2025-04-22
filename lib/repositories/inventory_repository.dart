import 'package:cold_river_express_app/database/db_helper.dart';
import 'package:cold_river_express_app/models/inventory.dart';

class InventoryRepository {
  final DBHelper dbHelper = DBHelper();

  Future<void> addInventory(Inventory inventory) async {
    await dbHelper.insertInventory(inventory);
  }

  Future<List<Inventory>> fetchAllInventories() async {
    return await dbHelper.getInventories();
  }

  Future<Inventory?> getInventoryById(String id) async {
    return await dbHelper.getInventory(id);
  }

  Future<int> updateInventory(Inventory inventory) async {
    return await dbHelper.updateInventory(inventory);
  }

  Future<void> updateInventoriesPosition(
    List<String> ids,
    String position,
  ) async {
    await dbHelper.updateInventoriesPosition(ids, position);
  }

  Future<List<Inventory>> getDeletedInventories() async {
    return await dbHelper.getDeletedInventories();
  }

  Future<void> archiveInventoryById(String id) async {
    await dbHelper.archiveInventory(id);
  }

  Future<void> restoreInventoryById(String id) async {
    await dbHelper.recoverInventory(id);
  }

  Future<void> restoreAllInventories() async {
    await dbHelper.restoreAllInventories();
  }

  Future<int> deleteInventoryById(String id) async {
    return await dbHelper.deleteInventory(id);
  }

  Future<void> deleteAllInventories() async {
    await dbHelper.deleteAllInventories();
  }

  Future<List<Inventory>> freeSearchInventory(String query) async {
    return await dbHelper.freeSearchInventory(query);
  }

  Future<List<Inventory>> filterInventory(
    String? environment,
    String? position,
  ) async {
    if (environment == null && position == null) {
      return await fetchAllInventories();
    }

    return await dbHelper.filterInventory(environment, position);
  }

  Future<List<String>> getLabelForEnvironment() async {
    return await dbHelper.getLabelForEnvironment();
  }

  Future<List<String>> getLabelForPosition() async {
    return await dbHelper.getLabelForPosition();
  }

  Future<bool> replaceInventory(String backupFilePath) async {
    return await dbHelper.replaceDatabase(backupFilePath);
  }

  Future<void> updateImagePath(String oldPath, String newPath) async {
    return await dbHelper.updateImagePath(oldPath, newPath);
  }
}
