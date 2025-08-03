import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/text_entry.dart';
import '../config/app_config.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), AppConfig.databaseName);
    
    return await openDatabase(
      path,
      version: AppConfig.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE text_entries (
        id TEXT PRIMARY KEY,
        text TEXT NOT NULL,
        source TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        originalLanguage TEXT,
        translatedText TEXT,
        targetLanguage TEXT,
        category TEXT DEFAULT 'Otro',
        tags TEXT,
        imagePath TEXT,
        isHandwritten INTEGER DEFAULT 0,
        confidence REAL,
        isSynced INTEGER DEFAULT 0,
        cloudId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entryId TEXT NOT NULL,
        action TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // Crear índices para mejorar el rendimiento
    await db.execute('CREATE INDEX idx_text_entries_timestamp ON text_entries(timestamp)');
    await db.execute('CREATE INDEX idx_text_entries_category ON text_entries(category)');
    await db.execute('CREATE INDEX idx_text_entries_source ON text_entries(source)');
    await db.execute('CREATE INDEX idx_text_entries_synced ON text_entries(isSynced)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Manejar actualizaciones de base de datos aquí
    if (oldVersion < 2) {
      // Ejemplo de migración
      // await db.execute('ALTER TABLE text_entries ADD COLUMN newColumn TEXT');
    }
  }

  // CRUD para TextEntry
  Future<int> insertTextEntry(TextEntry entry) async {
    final db = await database;
    return await db.insert(
      'text_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TextEntry>> getAllTextEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'text_entries',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return TextEntry.fromMap(maps[i]);
    });
  }

  Future<TextEntry?> getTextEntry(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'text_entries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TextEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTextEntry(TextEntry entry) async {
    final db = await database;
    return await db.update(
      'text_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteTextEntry(String id) async {
    final db = await database;
    return await db.delete(
      'text_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Búsqueda y filtrado
  Future<List<TextEntry>> searchTextEntries(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'text_entries',
      where: 'text LIKE ? OR translatedText LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return TextEntry.fromMap(maps[i]);
    });
  }

  Future<List<TextEntry>> getTextEntriesByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'text_entries',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return TextEntry.fromMap(maps[i]);
    });
  }

  Future<List<TextEntry>> getTextEntriesBySource(String source) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'text_entries',
      where: 'source = ?',
      whereArgs: [source],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return TextEntry.fromMap(maps[i]);
    });
  }

  Future<List<TextEntry>> getTextEntriesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'text_entries',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return TextEntry.fromMap(maps[i]);
    });
  }

  Future<List<TextEntry>> getUnsyncedEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'text_entries',
      where: 'isSynced = ?',
      whereArgs: [0],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return TextEntry.fromMap(maps[i]);
    });
  }

  // Estadísticas
  Future<Map<String, int>> getCategoryStats() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT category, COUNT(*) as count 
      FROM text_entries 
      GROUP BY category 
      ORDER BY count DESC
    ''');

    Map<String, int> stats = {};
    for (var row in result) {
      stats[row['category']] = row['count'];
    }
    return stats;
  }

  Future<Map<String, int>> getSourceStats() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT source, COUNT(*) as count 
      FROM text_entries 
      GROUP BY source 
      ORDER BY count DESC
    ''');

    Map<String, int> stats = {};
    for (var row in result) {
      stats[row['source']] = row['count'];
    }
    return stats;
  }

  // Historial de búsqueda
  Future<void> saveSearchQuery(String query) async {
    final db = await database;
    await db.insert(
      'search_history',
      {
        'query': query,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<String>> getSearchHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'search_history',
      orderBy: 'timestamp DESC',
      limit: 10,
    );

    return maps.map((map) => map['query'] as String).toList();
  }

  // Limpieza y mantenimiento
  Future<void> clearOldEntries(DateTime before) async {
    final db = await database;
    await db.delete(
      'text_entries',
      where: 'timestamp < ?',
      whereArgs: [before.toIso8601String()],
    );
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('text_entries');
    await db.delete('search_history');
    await db.delete('sync_log');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Backup y restauración
  Future<List<Map<String, dynamic>>> exportData() async {
    final db = await database;
    return await db.query('text_entries');
  }

  Future<void> importData(List<Map<String, dynamic>> data) async {
    final db = await database;
    final batch = db.batch();

    for (var item in data) {
      batch.insert('text_entries', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }
}
