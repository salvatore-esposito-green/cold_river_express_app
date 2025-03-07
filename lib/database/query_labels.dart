class QueryLabels {
  static const String createInventoryTable = '''
    CREATE TABLE inventory (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      environment TEXT NOT NULL,
      position TEXT NOT NULL,
      name TEXT NOT NULL,
      description TEXT,
      quantity INTEGER NOT NULL
    )
  ''';

  static const String selectUniqueEnvironments =
      "SELECT DISTINCT environment FROM inventory";

  static const String selectUniquePositions =
      "SELECT DISTINCT position FROM inventory";
}
