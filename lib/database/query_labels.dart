class QueryLabels {
  static const String createInventoryTable = '''
    CREATE TABLE inventory (
      id TEXT PRIMARY KEY,
      box_number TEXT NOT NULL,
      contents TEXT NOT NULL,
      image_path TEXT,
      size TEXT NOT NULL,
      position TEXT,
      environment TEXT,
      last_updated TEXT NOT NULL,
      is_deleted INTEGER NOT NULL DEFAULT 0,
    )
  ''';

  static const String createBoxSizesTable = '''
    CREATE TABLE box_sizes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      length INTEGER NOT NULL,
      width INTEGER NOT NULL,
      height INTEGER NOT NULL
    )
  ''';

  static const String selectUniqueEnvironments =
      "SELECT DISTINCT environment FROM inventory";

  static const String selectUniquePositions =
      "SELECT DISTINCT position FROM inventory";
}
