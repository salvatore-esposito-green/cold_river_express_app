import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/models/box_size.dart';

abstract class DatabaseServiceInterface {
  Future<void> initialize();

  Future<void> close();

  // ========== CRUD Inventory ==========

  Future<int> insertInventory(Inventory inventory);

  Future<List<Inventory>> getInventories();

  Future<Inventory?> getInventory(String id);

  Future<int> updateInventory(Inventory inventory);

  Future<int> deleteInventory(String id);

  /// (soft delete)
  Future<void> archiveInventory(String id);

  Future<void> recoverInventory(String id);

  Future<List<Inventory>> getDeletedInventories();

  Future<void> deleteAllInventories();

  Future<void> restoreAllInventories();

  // ========== Search & Filter ==========

  Future<List<Inventory>> freeSearchInventory(String query);

  Future<List<Inventory>> filterInventory(
    String? environment,
    String? position,
  );

  Future<void> updateInventoriesPosition(List<String> ids, String position);

  // ========== Labels ==========

  Future<List<String>> getLabelForEnvironment();

  Future<List<String>> getLabelForPosition();

  // ========== Box Sizes ==========

  Future<List<BoxSize>> getBoxSizes();

  Future<int> insertBoxSize(BoxSize boxSize);

  Future<int> deleteBoxSize(int id);

  // ========== Backup & Restore ==========

  Future<bool> createBackup();

  Future<bool> replaceDatabase(String backupFilePath);

  Future<String?> getCurrentDbPath();

  // ========== Utility ==========

  Future<void> updateImagePath(String oldPath, String newPath);
}
