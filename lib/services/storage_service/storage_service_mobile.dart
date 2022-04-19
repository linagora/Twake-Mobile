
part of 'storage_service.dart';

class StorageServiceMobile extends StorageService {

  StorageServiceMobile._(): super._();

  Future<void> init() async {
    
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

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _DATABASE_FILE);

    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (e) {
      Logger().wtf('Failed to create databases directory!\nError: $e');
      throw e;
    }

    
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