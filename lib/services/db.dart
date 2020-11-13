import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:twake_mobile/models/profile.dart';
import 'package:twake_mobile/services/twake_api.dart';

class DB {
  static Database db;
  static StoreRef authStore = intMapStoreFactory.store(_authStore);
  static StoreRef profileStore = intMapStoreFactory.store(_profileStore);
  static StoreRef channelStore = intMapStoreFactory.store(_channelStore);

  /// Make sure that db is initialized
  static void initCheck() {
    if (db == null) {
      throw Exception('Database not initialized\nCall init first!');
    }
  }

  /// Method that should be run, once the app starts,
  /// it will open the database file (establish connection) for
  /// further usage.
  static Future<void> init() async {
    // get the application documents directory
    var dir = await getApplicationDocumentsDirectory();
    // make sure it exists
    await dir.create(recursive: true);
    // build the database path
    final dbPath = join(dir.path, _DATABASE_FILE);
    db = await databaseFactoryIo.openDatabase(dbPath);
  }

  static Future<void> authSave(TwakeApi api) async {
    initCheck();

    /// Save value at index 0, overwrite existing one if present,
    /// create new one if absent
    await authStore.record(0).put(db, api.toMap(), merge: false);

    // await db.delete(_authTable);
    // await db.insert(_authTable, api.toMap());
  }

  static Future<void> authClean() async {
    initCheck();
    await authStore.delete(db);
  }

  /// Method for loading authentication data from database
  /// returns new instance of TwakeApi class with all fields initialized
  /// In case if there's no data available in database, method throws Exception
  static Future<Map> authLoad() async {
    initCheck();
    final record = await authStore.record(0).get(db);
    if (record == null) {
      throw Exception('Store is empty');
    }
    return record; // map containing auth data
  }

  /// Method for saving profile data in persistent storage
  /// Profile is saved with all of it's innards (companies, workspaces)
  static Future<void> profileSave(Profile profile) async {
    initCheck();

    /// Save value at index 0, overwrite existing one if present,
    /// create new one if absent
    await profileStore.record(0).put(db, profile.toJson(), merge: false);
    // await db.delete(_profileTable);
    // await db.insert(_profileTable, profile.toMap());
  }

  /// Method to clean the profiles table, basically completely
  /// truncates the whole table, leaving it empty
  static Future<void> profileClean() async {
    initCheck();
    await profileStore.delete(db);
  }

  /// Method for retrieving the profile from storage
  /// Because only one profile can be stored at any moment,
  /// we overwrite existing value
  static Future<Map<String, dynamic>> profileLoad() async {
    initCheck();
    final record = await profileStore.record(0).get(db);
    print('GOT PROFILE FROM STORE:\n$record');
    if (record == null) {
      throw Exception('Profile storage is empty');
    }
    return record;
    // List<Map<String, dynamic>> records =
    //     await db.query(_profileTable, limit: 1);
    // if (records.length == 0) {
    //   throw Exception('Table is empty');
    // }
    //
    // /// After we get the records we grab the first (and only) row and
    // /// extract the profileJSON field
    // final profileJsonText = records[0]['profilejson'];
    //
    // /// and pass it factory constructor of Profile
    // return Profile.fromJsonText(profileJsonText);
  }

  Future<void> channelsSave() async {}
}

// Database file, located in path returned by getDatabasesPath()
const String _DATABASE_FILE = 'twake.db';
// password for database encryption, used by sqlite_cipher
// const String __PASSWORD = 'oUlP6qM>/_,Yo)~qy{4HaWs_<';

const String _profileStore = 'profile';
const String _channelStore = 'channel';
const String _authStore = 'auth';

/// If database does not exist, these SQL statements
/// will ensure that we have basic database schema
// const String _ON_DB_CREATE_EXECUTE = '''
// CREATE TABLE $_authTable (
// authjwtoken TEXT NOT NULL,
// isauthorized INT NOT NULL,
// platform TEXT NOT NULL
// );
// CREATE TABLE $_profileTable (
// profilejson TEXT NOT NULL
// );
// CREATE TABLE $_channelTable(
// workspaceid TEXT NOT NULL,
// channeljson TEXT NOT NULL
// );
// ''';
