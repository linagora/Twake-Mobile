import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:twake/models/collection_item.dart';

const String _DATABASE_FILE = 'twake.db';

class Storage {
  static Storage _storage;
  StoreRef _authStore = intMapStoreFactory.store('auth');
  StoreRef _profileStore = intMapStoreFactory.store('profile');
  StoreRef _companyStore = stringMapStoreFactory.store('company');
  StoreRef _workspaceStore = stringMapStoreFactory.store('workspace');
  StoreRef _channelStore = stringMapStoreFactory.store('channel');
  StoreRef _messageStore = stringMapStoreFactory.store('message');
  Database _db;

  final logger = Logger();

  factory Storage() {
    if (_storage == null) {
      _storage = Storage._();
    }
    return _storage;
  }

  Storage._();

  /// Initialize store, create file if doesn't exist
  Future<void> initDb() async {
    // Initialize database
    // First get application directory on device
    final dir = await getApplicationDocumentsDirectory();
    // create application directory if doesn't exist
    await dir.create(recursive: true);
    // join database file name with application directory path
    final dbPath = join(dir.path, _DATABASE_FILE);
    // create database file in application directory
    this._db = await databaseFactoryIo.openDatabase(dbPath);
  }

  /// Load data of particular type from specified key
  Future<Map<String, dynamic>> load({
    StorageType type,
    dynamic key,
  }) async {
    StoreRef storeRef = _mapTypeToStore(type);
    return await storeRef.record(key).get(this._db);
  }

  /// Store data of particular type at particular key
  Future<void> store({
    item, // JsonSerializable
    StorageType type,
    dynamic key,
  }) async {
    StoreRef storeRef = _mapTypeToStore(type);
    await storeRef.record(key).put(
          this._db,
          item.toJson(),
          merge: true,
        );
  }

  Future<void> storeList({
    List<CollectionItem> items,
    StorageType type,
  }) async {
    StoreRef storeRef = _mapTypeToStore(type);
    await _db.transaction((txn) async {
      for (int i = 0; i < items.length; i++) {
        await storeRef
            .record(items[i].id)
            .put(txn, items[i].toJson(), merge: true);
      }
    });
  }

  /// Method for loading list of items from store.
  /// If filtered result is wanted, then filter of type
  /// Filters should be passed, same goes for sorting.
  /// More on how to make queries:
  /// https://github.com/tekartik/sembast.dart/blob/master/sembast/doc/queries.md
  Future<List<Map<String, dynamic>>> loadList({
    StorageType type,
    List<List> filters,
    Map<String, bool> sortFields,
  }) async {
    Filter filter;
    if (filters != null) {
      filter = filterBuild(filters);
    }
    List<SortOrder> sortOrders;
    if (sortFields != null) {
      sortOrders = [];
      sortFields.entries.forEach((entry) {
        sortOrders.add(SortOrder(entry.key, entry.value));
      });
    }
    logger.v('Requesting $type from storage');
    StoreRef storeRef = _mapTypeToStore(type);
    Finder finder = Finder(filter: filter, sortOrders: sortOrders);
    final records = await storeRef.find(_db, finder: finder);
    return records.map((r) => r.value as Map<String, dynamic>).toList();
  }

  /// Selectively remove a record from store
  Future<void> clean({
    StorageType type,
    dynamic key,
  }) async {
    StoreRef storeRef = _mapTypeToStore(type);
    await storeRef.record(key).delete(_db);
  }

  Future<void> clearList(StorageType type) async {
    StoreRef storeRef = _mapTypeToStore(type);
    await storeRef.delete(_db);
  }

  /// Be carefull! This method clears all the data from store
  Future<void> fullClean() async {
    await _db.transaction((txn) async {
      await _authStore.delete(txn);
      await _profileStore.delete(txn);
      await _channelStore.delete(txn);
      await _messageStore.delete(txn);
    });
  }

  StoreRef _mapTypeToStore(StorageType type) {
    StoreRef storeRef;
    if (type == StorageType.Auth)
      storeRef = _authStore;
    else if (type == StorageType.Profile)
      storeRef = _profileStore;
    else if (type == StorageType.Company)
      storeRef = _companyStore;
    else if (type == StorageType.Workspace)
      storeRef = _workspaceStore;
    else if (type == StorageType.Channel)
      storeRef = _channelStore;
    else if (type == StorageType.Message)
      storeRef = _messageStore;
    else
      throw 'Storage type does not exist';
    return storeRef;
  }
}

enum StorageType {
  Auth,
  Profile,
  Company,
  Workspace,
  Channel,
  Message,
}

Filter filterBuild(List<List> expressions) {
  List<Filter> andFilter = [];
  for (List e in expressions) {
    assert(e.length == 3);
    final lhs = e[0];
    final op = e[1];
    final rhs = e[2];
    Filter filter;

    if (op == '=') filter = Filter.equals(lhs, rhs);
    if (op == '>') filter = Filter.greaterThan(lhs, rhs);
    if (op == '<') filter = Filter.lessThan(lhs, rhs);
    if (op == '!=') filter = Filter.notEquals(lhs, rhs);
    if (op == '!=' && rhs == null) filter = Filter.notNull(lhs);
    if (op == '=' && rhs == null) filter = Filter.isNull(lhs);
    andFilter.add(filter);
  }
  return Filter.and(andFilter);
}
