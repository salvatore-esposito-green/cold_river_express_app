import 'package:cold_river_express_app/core/interfaces/database_service_interface.dart';
import 'package:cold_river_express_app/core/platform_factory.dart';
import 'package:cold_river_express_app/models/box_size.dart';

class BoxSizeRepository {
  final DatabaseServiceInterface _dbService;

  BoxSizeRepository() : _dbService = PlatformFactory.createDatabaseService();

  Future<List<BoxSize>> getBoxSizes() async {
    return await _dbService.getBoxSizes();
  }

  Future<int> insertBoxSize(BoxSize boxSize) async {
    return await _dbService.insertBoxSize(boxSize);
  }

  Future<int> deleteBoxSize(int id) async {
    return await _dbService.deleteBoxSize(id);
  }
}
