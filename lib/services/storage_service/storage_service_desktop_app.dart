part of 'storage_service.dart';

class StorageServiceDesktop extends StorageService {

    StorageServiceDesktop._(): super._();

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

    if(Platform.isLinux) {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      final path = join(Directory.current.path, _DATABASE_FILE);
      _db = await databaseFactory.openDatabase(path, options: OpenDatabaseOptions(
      version: DBVER,
      onConfigure: onConfigure,
      onCreate: onCreate,
      onOpen: onOpen,
      onUpgrade: onUpgrade, 
      ));
      return ;
    }
  }
}