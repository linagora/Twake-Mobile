import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:twake_mobile/models/profile.dart';
import 'package:twake_mobile/services/twake_api.dart';

class DB {
  static Database db;

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
    db = await openDatabase(
      _DATABASE_PATH,
      password: __PASSWORD,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(_ON_DB_CREATE_EXECUTE);
      },
      readOnly: false,
    );
  }

  static Future<void> authSave(TwakeApi api) async {
    initCheck();

    /// Make sure, that table is empty before saving
    await db.delete(_authTable);
    await db.insert(_authTable, api.toMap());
  }

  static Future<void> authClean() async {
    initCheck();
    await db.delete(_authTable);
  }

  /// Method for loading authentication data from database
  /// returns new instance of TwakeApi class with all fields initialized
  /// In case if there's no data available in database, method throws Exception
  static Future<Map> authLoad() async {
    initCheck();
    List<Map<String, dynamic>> records = await db.query(_authTable);
    if (records.length == 0) {
      throw Exception('Table is empty');
    }
    return records[0]; // map containing auth data
  }

  /// Method for saving profile data in persistent storage
  /// Profile is converted completely to JSON string first
  static Future<void> profileSave(Profile profile) async {
    initCheck();

    /// Clear all the data that might have persisted in database
    await db.delete(_profileTable);
    await db.insert(_profileTable, profile.toMap());
  }

  /// Method to clean the profiles table, basically completely
  /// truncates the whole table, leaving it empty
  static Future<void> profileClean() async {
    initCheck();
    await db.delete(_profileTable);
  }

  /// Method for retrieving the profile from database
  /// Because only one profile can be stored in database at any moment,
  /// we trucate the table first
  static Future<Profile> profileLoad() async {
    initCheck();
    List<Map<String, dynamic>> records =
        await db.query(_profileTable, limit: 1);
    if (records.length == 0) {
      throw Exception('Table is empty');
    }

    /// After we get the records we grab the first (and only) row and
    /// extract the profileJSON field
    final profileJsonText = records[0]['profilejson'];

    /// and pass it factory constructor of Profile
    return Profile.fromJsonText(profileJsonText);
  }
}

// Database file, located in path returned by getDatabasesPath()
const String _DATABASE_PATH = 'twake.db';
// password for database encryption, used by sqlite_cipher
const String __PASSWORD = 'oUlP6qM>/_,Yo)~qy{4HaWs_<';

const String _profileTable = 'profile';
const String _channelTable = 'channel';
const String _authTable = 'auth';

/// If database does not exist, these SQL statements
/// will ensure that we have basic database schema
const String _ON_DB_CREATE_EXECUTE = '''
    CREATE TABLE $_authTable (
        authjwtoken TEXT NOT NULL,
        isauthorized INT NOT NULL,
        platform TEXT NOT NULL
    );
    CREATE TABLE $_profileTable (
        profilejson TEXT NOT NULL
    );
    CREATE TABLE $_channelTable(
        workspaceid TEXT NOT NULL,
        channeljson TEXT NOT NULL
    );
    ''';
