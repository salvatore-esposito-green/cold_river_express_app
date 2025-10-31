import 'package:cold_river_express_app/core/interfaces/database_service_interface.dart';
import 'package:cold_river_express_app/database/db_helper.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/models/box_size.dart';

/// Implementazione mobile del servizio Database (SQLite)
/// Questa è un wrapper attorno a DBHelper esistente
class DatabaseServiceMobile implements DatabaseServiceInterface {
  final DBHelper _dbHelper = DBHelper();

  @override
  Future<void> initialize() async {
    // Il database viene inizializzato automaticamente da DBHelper
    await _dbHelper.database;
  }

  @override
  Future<void> close() async {
    // SQLite non richiede chiusura esplicita in questa implementazione
  }

  @override
  Future<int> insertInventory(Inventory inventory) =>
      _dbHelper.insertInventory(inventory);

  @override
  Future<List<Inventory>> getInventories() => _dbHelper.getInventories();

  @override
  Future<Inventory?> getInventory(String id) => _dbHelper.getInventory(id);

  @override
  Future<int> updateInventory(Inventory inventory) =>
      _dbHelper.updateInventory(inventory);

  @override
  Future<int> deleteInventory(String id) => _dbHelper.deleteInventory(id);

  @override
  Future<void> archiveInventory(String id) => _dbHelper.archiveInventory(id);

  @override
  Future<void> recoverInventory(String id) => _dbHelper.recoverInventory(id);

  @override
  Future<List<Inventory>> getDeletedInventories() =>
      _dbHelper.getDeletedInventories();

  @override
  Future<void> deleteAllInventories() => _dbHelper.deleteAllInventories();

  @override
  Future<void> restoreAllInventories() => _dbHelper.restoreAllInventories();

  @override
  Future<List<Inventory>> freeSearchInventory(String query) =>
      _dbHelper.freeSearchInventory(query);

  @override
  Future<List<Inventory>> filterInventory(String? environment, String? position) =>
      _dbHelper.filterInventory(environment, position);

  @override
  Future<void> updateInventoriesPosition(List<String> ids, String position) =>
      _dbHelper.updateInventoriesPosition(ids, position);

  @override
  Future<List<String>> getLabelForEnvironment() =>
      _dbHelper.getLabelForEnvironment();

  @override
  Future<List<String>> getLabelForPosition() =>
      _dbHelper.getLabelForPosition();

  @override
  Future<List<BoxSize>> getBoxSizes() async {
    // TODO: Implementare getBoxSizes in DBHelper
    return [];
  }

  @override
  Future<int> insertBoxSize(BoxSize boxSize) async {
    // TODO: Implementare insertBoxSize in DBHelper
    return 0;
  }

  @override
  Future<int> deleteBoxSize(int id) async {
    // TODO: Implementare deleteBoxSize in DBHelper
    return 0;
  }

  @override
  Future<bool> createBackup() => _dbHelper.createBackup();

  @override
  Future<bool> replaceDatabase(String backupFilePath) =>
      _dbHelper.replaceDatabase(backupFilePath);

  @override
  Future<String?> getCurrentDbPath() => _dbHelper.getCurrentDbPath();

  @override
  Future<void> updateImagePath(String oldPath, String newPath) =>
      _dbHelper.updateImagePath(oldPath, newPath);
}
