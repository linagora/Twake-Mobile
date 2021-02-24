import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:twake/services/storage/storage.dart';

const String _DATABASE_FILE = 'twake.db';

class Sembast with Storage {
  @override
  final settingsField = null;

  StoreRef _authStore = stringMapStoreFactory.store('auth');
  StoreRef _profileStore = stringMapStoreFactory.store('profile');
  StoreRef _companyStore = stringMapStoreFactory.store('company');
  StoreRef _workspaceStore = stringMapStoreFactory.store('workspace');
  StoreRef _channelStore = stringMapStoreFactory.store('channel');
  StoreRef _directStore = stringMapStoreFactory.store('direct');
  StoreRef _messageStore = stringMapStoreFactory.store('message');
  StoreRef _userStore = stringMapStoreFactory.store('user');
  Database _db;

  final logger = Logger();

  Sembast();

  /// Initialize store, create file if doesn't exist
  @override
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

  @override
  Future<Map<String, dynamic>> load({
    StorageType type,
    dynamic key,
    List<String> fields,
  }) async {
    StoreRef storeRef = mapTypeToStore(type);
    final Map<String, dynamic> item = await storeRef.record(key).get(this._db);
    return item;
  }

  @override
  Future<void> store({
    Map<String, dynamic> item, // JsonSerializable
    StorageType type,
    dynamic key,
  }) async {
    StoreRef storeRef = mapTypeToStore(type);
    if (key != null)
      await storeRef.record(key).put(
            this._db,
            item,
            merge: true,
          );
    else
      storeRef.add(this._db, item);
  }

  @override
  Future<void> batchStore({
    Iterable<Map<String, dynamic>> items,
    StorageType type,
  }) async {
    StoreRef storeRef = mapTypeToStore(type);
    await _db.transaction((txn) async {
      for (Map i in items) {
        await storeRef.record(i['id']).put(txn, i, merge: true);
      }
    });
  }

  @override
  Future<List<Map<String, dynamic>>> batchLoad({
    StorageType type,
    List<List> filters,
    Map<String, bool> orderings,
    int limit,
    int offset,
  }) async {
    Filter filter;
    if (filters != null) {
      logger.d('Filters were: $filters');
      filter = filtersBuild(filters);
    }
    List<SortOrder> sortOrders = orderingsBuild(orderings);
    logger.v('Requesting $type from storage');
    StoreRef storeRef = mapTypeToStore(type);
    Finder finder = Finder(filter: filter, sortOrders: sortOrders);
    final records = await storeRef.find(_db, finder: finder);
    logger.d('GOT RECORDS: $records FROM STORAGE');
    return records.map((r) => r.value as Map<String, dynamic>).toList();
  }

  @override
  Future<void> delete({
    StorageType type,
    dynamic key,
  }) async {
    StoreRef storeRef = mapTypeToStore(type);
    await storeRef.record(key).delete(_db);
  }

  @override
  Future<void> truncate(StorageType type) async {
    StoreRef storeRef = mapTypeToStore(type);
    await storeRef.delete(_db);
  }

  @override
  Future<void> truncateAll({List<StorageType> except}) async {
    await _db.transaction((txn) async {
      for (StoreRef s in getAllStorages()) {
        await s.delete(txn);
      }
    });
  }

  @override
  StoreRef mapTypeToStore(StorageType type) {
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
    else if (type == StorageType.Direct)
      storeRef = _directStore;
    else if (type == StorageType.Message)
      storeRef = _messageStore;
    else if (type == StorageType.User)
      storeRef = _userStore;
    else
      throw 'Storage type does not exist';
    return storeRef;
  }

  @override
  Filter filtersBuild(List<List> expressions) {
    List<Filter> andFilter = [];
    for (List e in expressions) {
      assert(e.length == 3);
      final lhs = e[0];
      final op = e[1];
      final rhs = e[2];
      Filter filter;

      if (op == '=')
        filter = Filter.equals(lhs, rhs);
      else if (op == '>')
        filter = Filter.greaterThan(lhs, rhs);
      else if (op == '<')
        filter = Filter.lessThan(lhs, rhs);
      else if (op == '>=')
        filter = Filter.greaterThanOrEquals(lhs, rhs);
      else if (op == '<=')
        filter = Filter.lessThanOrEquals(lhs, rhs);
      else if (op == '!=' && rhs == null)
        filter = Filter.notNull(lhs);
      else if (op == '=' && rhs == null)
        filter = Filter.isNull(lhs);
      else if (op == '!=') filter = Filter.notEquals(lhs, rhs);

      if (filter != null) andFilter.add(filter);
    }
    return Filter.and(andFilter);
  }

  @override
  List<SortOrder> orderingsBuild(Map<String, bool> orderings) {
    List<SortOrder> sortOrders;
    if (orderings != null) {
      sortOrders = [];
      orderings.entries.forEach((entry) {
        sortOrders.add(SortOrder(entry.key, entry.value));
      });
    }
    return sortOrders;
  }

  @override
  Future<void> batchDelete({StorageType type, List<List> filters}) {
    // TODO: implement batchDelete
    throw UnimplementedError();
  }

  @override
  Future customQuery(String query, {List<List> filters, Map<String, bool> orderings, int limit, int offset}) {
    // TODO: implement customQuery
    throw UnimplementedError();
  }

  @override
  Future customUpdate({String sql, List args}) {
    // TODO: implement customUpdate
    throw UnimplementedError();
  }
}
