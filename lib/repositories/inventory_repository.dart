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

  Future<int> deleteInventoryById(String id) async {
    return await dbHelper.deleteInventory(id);
  }

  Future<List<Inventory>> freeSearchInventory(String query) async {
    return await dbHelper.freeSearchInventory(query);
  }
}
