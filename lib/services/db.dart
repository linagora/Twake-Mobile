import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:twake_mobile/models/channel.dart';
import 'package:twake_mobile/models/profile.dart';
import 'package:twake_mobile/services/twake_api.dart';

class DB {
  static Database db;
  static StoreRef authStore = intMapStoreFactory.store(_authStore);
  static StoreRef profileStore = intMapStoreFactory.store(_profileStore);
  static StoreRef channelStore = stringMapStoreFactory.store(_channelStore);

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
    if (record == null) {
      throw Exception('Profile storage is empty');
    }
    return record;
  }

  /// Convenience method to perform full data store clean up
  static Future<void> fullClean() async {
    await authClean();
    await profileClean();
    await channelsClean();
  }

  /// Method for saving all the channels, that are downloaded during
  /// user's session, if there's an active internet connection, channels
  /// are always loaded over internet. Data store is used only when no connection
  /// to the server can be established
  static Future<void> channelsSave(List<Channel> channels) async {
    initCheck();
    for (int i = 0; i < channels.length; i++) {
      channelStore.record(channels[i].id).put(
            db,
            channels[i].toJson(),
            merge: true,
          );
    }
  }

  /// Load channels from data store in case if twake api is not available
  static Future<List<Map<String, dynamic>>> channelsLoad(
      String workspaceId) async {
    initCheck();
    final finder = Finder(
      filter: Filter.equals(
        'workspaceId',
        workspaceId,
      ),
      sortOrders: [SortOrder('name')],
    );
    final records = await channelStore.find(db, finder: finder);
    return records.map((r) => r.value).toList();
  }

  /// Remove all the channels downloaded during user's session, usually
  /// the method is invoked on logout
  static Future<void> channelsClean() async {
    await channelStore.delete(db);
  }

  /// Save messages that are downloaded during user's session
  /// data store is only accessed if connection to twake api cannot
  /// be established
  static Future<void> messagesSave() async {}
}

const String _DATABASE_FILE = 'twake.db';

const String _profileStore = 'profile';
const String _channelStore = 'channel';
const String _authStore = 'auth';
