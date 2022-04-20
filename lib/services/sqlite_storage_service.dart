part of 'storage_service.dart';

const String _DATABASE_FILE = 'twakesql.db';

class SqliteStorageService extends StorageService {
  late Database _db;
  final bool useSqlFFI;

  SqliteStorageService._({this.useSqlFFI = false}): super._();

  @override
  Future<void> init() async {
    await initSqlite();
  }

  Future<void> initSqlite() async {
    String databasesPath = await getDatabasesPath();
    if(useSqlFFI) {
      databasesPath = Directory.current.path;
    }
    final path = join(databasesPath, _DATABASE_FILE);

    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (e) {
      Logger().wtf('Failed to create databases directory!\nError: $e');
      throw e;
    }

    void onConfigure(Database db) async {
      // enable support for foreign key constraints
      await db.execute("PRAGMA foreign_keys = ON");
      // enable support for LIKE searches case sensitively
      await db.execute("PRAGMA case_sensitive_like = OFF");
    }

    void onCreate(Database db, int version) async {
      for (var ddl in CURRENT_MIGRATION) {
        print('Executing: $ddl');
        await db.execute(ddl);
      }
    }

    void onOpen(Database db) async {
      final v = await db.getVersion();
      Logger().d('Opened twake db v.$v');
    }

    void onUpgrade(db, oldVersion, newVersion) async {
      Logger().d('Migration to twake db v.$newVersion from v.$oldVersion');
      await dbUpgrade(db: db, oldVersion: oldVersion, newVersion: newVersion);
    }

    if(useSqlFFI) {
      var databaseFactory = databaseFactoryFfi;
      _db = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: DBVER,
          onConfigure: onConfigure,
          onCreate: onCreate,
          onOpen: onOpen,
          onUpgrade: onUpgrade,
        ),
      );
    } else {
      _db = await openDatabase(
        path,
        version: DBVER,
        onConfigure: onConfigure,
        onCreate: onCreate,
        onOpen: onOpen,
        onUpgrade: onUpgrade,
      );
    }
  }

  Future<void> insert({
    required Table table,
    required BaseModel data,
  }) async {
    await _db.insert(
      table.name,
      data.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> rawInsert(
      {required Table table,
        required List<String> fields,
        required List<dynamic> values}) async {
    final length = fields.length > 1 ? ',?' * (fields.length - 1) : '';
    await _db.rawInsert(
        "INSERT into $table (${fields.toString()})"
            " VALUES (?$length)",
        [values]);
  }

  // This function is used when we need a clean table to insert the data
  Future<void> cleanInsert({
    required Table table,
    required BaseModel data,
  }) async {
    final batch = _db.batch();
    batch.delete(table.name);
    batch.insert(table.name, data.toJson());
    await batch.commit(noResult: true);
  }

  // This function can be used both for inserts and updates
  Future<void> multiInsert({
    required Table table,
    required Iterable<BaseModel> data,
  }) async {
    final batch = _db.batch();
    for (final item in data) {
      batch.insert(
        table.name,
        item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, Object?>>> select({
    required Table table,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final result = await _db.query(
      table.name,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
    return result;
  }

  Future<Map<String, Object?>> first({
    required Table table,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final result = await select(
      table: table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
    );
    return result.length > 0 ? result[0] : const {};
  }

  Future<void> update({
    required Table table,
    required Map<String, dynamic> values,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    await _db.update(
      table.name,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete({
    required Table table,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    await _db.delete(table.name, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, Object?>>> rawSelect({
    required String sql,
    List<dynamic>? args,
  }) async {
    final result = await _db.rawQuery(sql, args);
    return result;
  }

  Future<void> truncate({required Table table}) async {
    await _db.delete(table.name);
  }

  Future<void> truncateAll() async {
    final batch = _db.batch();
    //TODO Remove when API for editing user profile is ready,integrate it into LanguageRepository
    for (final table in Table.values) {
      if (table.name != 'account') {
        batch.delete(table.name);
      }
    }
    await batch.commit(noResult: true);
  }
}