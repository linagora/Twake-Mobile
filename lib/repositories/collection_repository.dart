import 'package:twake/models/direct.dart';
import 'package:twake/models/member.dart';
import 'package:twake/models/message.dart';
import 'package:twake/models/company.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/collection_item.dart';
import 'package:twake/services/service_bundle.dart';

class CollectionRepository<T extends CollectionItem> {
  List<T> items;
  final String apiEndpoint;

  // Ugly hack, but there's no other way to get constructor from generic type
  static Map<Type, CollectionItem Function(Map<String, dynamic>)>
      _typeToConstructor = {
    Company: (Map<String, dynamic> json) => Company.fromJson(json),
    Workspace: (Map<String, dynamic> json) => Workspace.fromJson(json),
    Channel: (Map<String, dynamic> json) {
      json = Map.from(json);
      return Channel.fromJson(json);
    },
    Message: (Map<String, dynamic> json) {
      json = Map.from(json);
      return Message.fromJson(json);
    },
    Direct: (Map<String, dynamic> json) {
      json = Map.from(json);
      return Direct.fromJson(json);
    },
    Member: (Map<String, dynamic> json) => Member.fromJson(json),
  };

  List<T> get roItems => [...items];

  static Map<Type, StorageType> _typeToStorageType = {
    Company: StorageType.Company,
    Workspace: StorageType.Workspace,
    Channel: StorageType.Channel,
    Message: StorageType.Message,
    Direct: StorageType.Direct,
    Member: StorageType.Member,
  };

  CollectionRepository({this.items, this.apiEndpoint});

  bool get isEmpty => items.isEmpty;

  T get selected => items.firstWhere((i) => i.isSelected == 1, orElse: () {
        if (items.isNotEmpty) return items[0];
        return null;
      });

  int get itemsCount => (items ?? []).length;

  final logger = Logger();
  static final api = Api();
  static final storage = Storage();

  static Future<CollectionRepository> load<T extends CollectionItem>(
    String apiEndpoint, {
    Map<String, dynamic> queryParams,
    List<List> filters,
    Map<String, bool> sortFields, // fields to sort by + sort direction
  }) async {
    List<dynamic> itemsList = await storage.batchLoad(
      type: _typeToStorageType[T],
      filters: filters,
      orderings: sortFields,
    );
    bool saveToStore = false;
    if (itemsList.isEmpty) {
      // Logger().d('Requesting $T items from api...');
      try {
        itemsList = await api.get(apiEndpoint, params: queryParams);
      } on ApiError catch (error) {
        Logger().d('ERROR WHILE FETCHING $T items FROM API\n${error.message}');
        throw error;
      }
      saveToStore = true;
    }
    final items =
        itemsList.map((i) => (_typeToConstructor[T](i) as T)).toList();
    final collection =
        CollectionRepository<T>(items: items, apiEndpoint: apiEndpoint);
    if (saveToStore) collection.save();
    return collection;
  }

  void select(
    String itemId, {
    bool saveToStore: true,
    String apiEndpoint,
    Map<String, dynamic> params,
  }) {
    // logger.w('BEFORE SELECT $T ${selected.id}');
    final item = items.firstWhere((i) => i.id == itemId, orElse: () => null);
    if (item == null) return;
    var oldSelected = selected;
    oldSelected.isSelected = 0;
    item.isSelected = 1;
    assert(selected.id == item.id);
    if (saveToStore) saveOne(item);
    saveOne(oldSelected);
    if (apiEndpoint != null && params != null)
      api.post(
        apiEndpoint,
        body: params,
      );
    // logger.w('AFTER SELECT $T ${selected.id}');
  }

  Future<bool> reload({
    Map<String, dynamic> queryParams,
    List<List> filters, // fields to filter by in store
    Map<String, bool> sortFields, // fields to sort by + sort direction
    Function onApiLoaded,
    int limit,
    int offset,
  }) async {
    List<dynamic> itemsList = [];
    itemsList = await storage.batchLoad(
      type: _typeToStorageType[T],
      filters: filters,
      orderings: sortFields,
      limit: limit,
      offset: offset,
    );

    api.get(apiEndpoint, params: queryParams).then((itemsList) {
      storage.batchDelete(type: _typeToStorageType[T], filters: filters);
      _updateItems(itemsList, saveToStore: true);

      if (onApiLoaded != null) onApiLoaded();
    }).catchError((error) {
      logger.d('ERROR while reloading $T items from api\n${error.message}');
      return false;
    });
    _updateItems(itemsList, saveToStore: false);
    return true;
  }

  Future<bool> didChange({
    Map<String, dynamic> queryParams,
    List<List> filters, // fields to filter by in store
  }) async {
    final itemsList = await storage.batchLoad(
      type: _typeToStorageType[T],
      filters: filters,
      limit: 100000,
      offset: 0,
    );
    List remote;
    if (itemsList.isEmpty) return false;
    try {
      remote = await api.get(apiEndpoint, params: queryParams);
      // logger.w("GOT WORKSPACES: ${remote.map((w) => w['name']).toSet()}");
    } on ApiError catch (error) {
      logger.d('ERROR while reloading $T items from api\n${error.message}');
      return false;
    }
    if (remote.length != itemsList.length) {
      logger.w("LOCAL != REMOTE");
      await storage.batchDelete(type: _typeToStorageType[T], filters: filters);
      _updateItems(remote, saveToStore: true);
      return true;
    }
    return false;
  }

  Future<bool> pullOne(
    Map<String, dynamic> queryParams, {
    bool addToItems = true,
  }) async {
    // logger.d('Pulling item $T from api...');
    List resp = [];
    try {
      resp = (await api.get(apiEndpoint, params: queryParams));
    } on ApiError catch (error) {
      logger.d('ERROR while loading more $T items from api\n${error.message}');
      return false;
    }
    if (resp.isEmpty) return false;
    final item = _typeToConstructor[T](resp[0]);
    if (addToItems) this.items.add(item);
    saveOne(item);
    return true;
  }

  Future<bool> pushOne(
    Map<String, dynamic> body, {
    Function onError,
    Function(T) onSuccess,
    addToItems = true,
  }) async {
    // logger.d('Sending item $T to api...');
    var resp;
    try {
      resp = (await api.post(apiEndpoint, body: body));
    } catch (error) {
      logger.e('Error while sending $T item to api\n${error.message}');
      if (onError != null) onError();
      return false;
    }
    logger.d('RESPONSE AFTER SENDING ITEM: $resp');
    final item = _typeToConstructor[T](resp);
    if (addToItems) this.items.add(item);
    if (onSuccess != null) onSuccess(item);
    saveOne(item);
    return true;
  }

  Future<T> getItemById(String id) async {
    var item = items.firstWhere((i) => i.id == id, orElse: () => null);
    if (item == null) {
      final map = await storage.load(type: _typeToStorageType[T], key: id);
      if (map == null) return null;
      item = _typeToConstructor[T](map);
    }
    return item;
  }

  Future<dynamic> customGet(
      String method, Map<String, dynamic> queryParams) async {
    return (await api.get(method, params: queryParams));
  }

  Future<void> clean() async {
    items.clear();
    await storage.truncate(_typeToStorageType[T]);
  }

  Future<bool> delete(
    key, {
    bool apiSync: true,
    bool removeFromItems: true,
    Map<String, dynamic> requestBody,
  }) async {
    if (apiSync) {
      try {
        await api.delete(apiEndpoint, body: requestBody);
      } catch (error) {
        logger.e('Error while sending $T item to api\n${error.message}');
        return false;
      }
    }
    await storage.delete(type: _typeToStorageType[T], key: key);
    if (removeFromItems) items.removeWhere((i) => i.id == key);
    return true;
  }

  void clear() {
    this.items.clear();
  }

  void _updateItems(
    List<dynamic> itemsList, {
    bool saveToStore: false,
    bool extendItems: false,
  }) {
    final items = itemsList.map((c) => (_typeToConstructor[T](c) as T));
    if (extendItems)
      this.items.addAll(items);
    else
      this.items = items.toList();
    if (saveToStore) this.save();
  }

  Future<void> save() async {
    // logger.d('SAVING $T items to store!');
    await storage.batchStore(
      items: this.items.map((i) => i.toJson()),
      type: _typeToStorageType[T],
    );
  }

  Future<void> saveOne(T item) async {
    await storage.store(
      item: item.toJson(),
      type: _typeToStorageType[T],
      key: item,
    );
  }
}
