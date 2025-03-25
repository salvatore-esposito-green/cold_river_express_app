import 'package:cold_river_express_app/database/db_helper.dart';
import 'package:cold_river_express_app/models/box_size.dart';
import 'package:sqflite/sqflite.dart';

class BoxSizeRepository {
  final DBHelper _dbHelper = DBHelper();

  Future<List<BoxSize>> getBoxSizes() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'box_sizes',
      orderBy: 'length ASC',
    );

    return maps.map((map) => BoxSize.fromMap(map)).toSet().toList();
  }

  Future<int> insertBoxSize(BoxSize boxSize) async {
    final db = await _dbHelper.database;

    return await db.insert(
      'box_sizes',
      boxSize.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteBoxSize(int id) async {
    final db = await _dbHelper.database;

    return await db.delete('box_sizes', where: 'id = ?', whereArgs: [id]);
  }
}
