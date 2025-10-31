import 'package:cold_river_express_app/core/interfaces/database_service_interface.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/models/box_size.dart';

class DatabaseServiceWeb implements DatabaseServiceInterface {
  @override Future<void> initialize() => throw UnimplementedError();
  @override Future<void> close() => throw UnimplementedError();
  @override Future<int> insertInventory(Inventory inventory) => throw UnimplementedError();
  @override Future<List<Inventory>> getInventories() => throw UnimplementedError();
  @override Future<Inventory?> getInventory(String id) => throw UnimplementedError();
  @override Future<int> updateInventory(Inventory inventory) => throw UnimplementedError();
  @override Future<int> deleteInventory(String id) => throw UnimplementedError();
  @override Future<void> archiveInventory(String id) => throw UnimplementedError();
  @override Future<void> recoverInventory(String id) => throw UnimplementedError();
  @override Future<List<Inventory>> getDeletedInventories() => throw UnimplementedError();
  @override Future<void> deleteAllInventories() => throw UnimplementedError();
  @override Future<void> restoreAllInventories() => throw UnimplementedError();
  @override Future<List<Inventory>> freeSearchInventory(String query) => throw UnimplementedError();
  @override Future<List<Inventory>> filterInventory(String? environment, String? position) => throw UnimplementedError();
  @override Future<void> updateInventoriesPosition(List<String> ids, String position) => throw UnimplementedError();
  @override Future<List<String>> getLabelForEnvironment() => throw UnimplementedError();
  @override Future<List<String>> getLabelForPosition() => throw UnimplementedError();
  @override Future<List<BoxSize>> getBoxSizes() => throw UnimplementedError();
  @override Future<int> insertBoxSize(BoxSize boxSize) => throw UnimplementedError();
  @override Future<int> deleteBoxSize(int id) => throw UnimplementedError();
  @override Future<bool> createBackup() => throw UnimplementedError();
  @override Future<bool> replaceDatabase(String backupFilePath) => throw UnimplementedError();
  @override Future<String?> getCurrentDbPath() => throw UnimplementedError();
  @override Future<void> updateImagePath(String oldPath, String newPath) => throw UnimplementedError();
}
