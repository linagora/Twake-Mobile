import 'package:twake/models/direct.dart';
import 'package:twake/models/message.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/models/company.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/collection_item.dart';

class CollectionRepository<T extends CollectionItem> {
  List<T> items;
  final String apiEndpoint;

  // Ugly hack, but there's no other way to get constructor from generic type
  static Map<Type, CollectionItem Function(Map<String, dynamic>)>
      _typeToConstuctor = {
    Company: (Map<String, dynamic> json) => Company.fromJson(json),
    Workspace: (Map<String, dynamic> json) => Workspace.fromJson(json),
    Channel: (Map<String, dynamic> json) => Channel.fromJson(json),
    Message: (Map<String, dynamic> json) {
      json = Map.from(json);
      return Message.fromJson(json);
    },
    Direct: (Map<String, dynamic> json) {
      json = Map.from(json);
      return Direct.fromJson(json);
    }
  };

  List<T> get roItems => [...items];

  static Map<Type, StorageType> _typeToStorageType = {
    Company: StorageType.Company,
    Workspace: StorageType.Workspace,
    Channel: StorageType.Channel,
    Message: StorageType.Message,
    Direct: StorageType.Direct,
  };

  CollectionRepository({this.items, this.apiEndpoint});

  bool get isEmpty => items.isEmpty;

  T get selected => items.firstWhere((i) => i.isSelected == 1, orElse: () {
        if (items.isNotEmpty) return items[0];
        return null;
      });

  int get itemsCount => (items ?? []).length;

  final logger = Logger();
  static final _api = Api();
  static final _storage = Storage();

  static Future<CollectionRepository> load<T extends CollectionItem>(
    String apiEndpoint, {
    Map<String, dynamic> queryParams,
    List<List> filters,
    Map<String, bool> sortFields, // fields to sort by + sort direction
  }) async {
    List<dynamic> itemsList = await _storage.batchLoad(
      type: _typeToStorageType[T],
      filters: filters,
      orderings: sortFields,
    );
    bool saveToStore = false;
    if (itemsList.isEmpty) {
      Logger().d('No $T items found in storage, requesting from api...');
      itemsList = await _api.get(apiEndpoint, params: queryParams);
      saveToStore = true;
    }
    final items = itemsList.map((i) => (_typeToConstuctor[T](i) as T)).toList();
    final collection =
        CollectionRepository<T>(items: items, apiEndpoint: apiEndpoint);
    if (saveToStore) collection.save();
    return collection;
  }

  void select(String itemId, {bool saveToStore: true}) {
    final item = items.firstWhere((i) => i.id == itemId);
    var oldSelected = selected;
    oldSelected.isSelected = 0;
    item.isSelected = 1;
    assert(selected.id == item.id);
    if (saveToStore)
      Future.wait([
        saveOne(oldSelected),
        saveOne(item),
      ]);
  }

  Future<void> reload({
    Map<String, dynamic> queryParams,
    List<List> filters, // fields to filter by in store
    Map<String, bool> sortFields, // fields to sort by + sort direction
    bool forceFromApi: false,
    int limit,
    int offset,
  }) async {
    List<dynamic> itemsList = [];
    if (!forceFromApi) {
      logger.d('Reloading $T items from storage...\nFilters: $filters');
      itemsList = await _storage.batchLoad(
        type: _typeToStorageType[T],
        filters: filters,
        orderings: sortFields,
        limit: limit,
        offset: offset,
      );
    }
    bool saveToStore = false;
    if (itemsList.isEmpty) {
      logger.d('Non in storage. Reloading $T items from api...');
      itemsList = await _api.get(apiEndpoint, params: queryParams);
      saveToStore = true;
    }
    _updateItems(itemsList, saveToStore: saveToStore);
  }

  Future<bool> loadMore({
    Map<String, dynamic> queryParams,
    List<List> filters, // fields to filter by in store
    Map<String, bool> sortFields, // fields to sort by + sort direction
    int limit,
    int offset,
  }) async {
    List<dynamic> itemsList = [];
    logger.d('Loading more $T items from storage...\nFilters: $filters');
    itemsList = await _storage.batchLoad(
      type: _typeToStorageType[T],
      filters: filters,
      orderings: sortFields,
      limit: limit,
      offset: offset,
    );
    bool saveToStore = false;
    if (itemsList.isEmpty) {
      logger.d('Non in storage. Reloading $T items from api...');
      itemsList = await _api.get(apiEndpoint, params: queryParams);
      saveToStore = true;
    }
    if (itemsList.isNotEmpty) {
      _updateItems(itemsList, saveToStore: saveToStore, extendItems: true);
    } else {
      return false;
    }
    return true;
  }

  Future<void> pullOne(
    Map<String, dynamic> queryParams, {
    bool addToItems = true,
  }) async {
    logger.d('Pulling item $T from api...');
    final List resp = (await _api.get(apiEndpoint, params: queryParams));
    if (resp.isEmpty) return;
    final item = _typeToConstuctor[T](resp[0]);
    if (addToItems) this.items.add(item);
    saveOne(item);
  }

  Future<bool> pushOne(
    Map<String, dynamic> body, {
    addToItems = true,
  }) async {
    logger.d('Sending item $T to api...');
    var resp;
    try {
      resp = (await _api.post(apiEndpoint, body: body));
    } catch (error) {
      logger.e('Error while sending $T item to api\n${error.message}');
      return false;
    }
    logger.d('RESPONSE AFTER SENDING ITEM: $resp');
    final item = _typeToConstuctor[T](resp);
    if (addToItems) this.items.add(item);
    saveOne(item);
    return true;
  }

  Future<T> getItemById(String id) async {
    var item = items.firstWhere((i) => i.id == id, orElse: () => null);
    if (item == null) {
      final map = await _storage.load(type: _typeToStorageType[T], key: id);
      if (map == null) return null;
      item = _typeToConstuctor[T](map);
    }
    return item;
  }

  Future<void> clean() async {
    await _storage.truncate(_typeToStorageType[T]);
    items.clear();
  }

  Future<void> delete(
    key, {
    bool apiSync: true,
    bool removeFromItems: true,
    Map<String, dynamic> requestBody,
  }) async {
    await _storage.delete(type: _typeToStorageType[T], key: key);
    if (apiSync) {
      await _api.delete(apiEndpoint, body: requestBody);
    }
    if (removeFromItems) items.removeWhere((i) => i.id == key);
  }

  void _updateItems(
    List<dynamic> itemsList, {
    bool saveToStore: false,
    bool extendItems: false,
  }) {
    final items = itemsList.map((c) => (_typeToConstuctor[T](c) as T));
    if (extendItems)
      this.items.addAll(items);
    else
      this.items = items.toList();
    if (saveToStore) this.save();
  }

  Future<void> save() async {
    logger.d('SAVING $T items to store!');
    await _storage.batchStore(
      items: this.items.map((i) => i.toJson()),
      type: _typeToStorageType[T],
    );
  }

  Future<void> saveOne(T item) async {
    await _storage.store(
      item: item.toJson(),
      type: _typeToStorageType[T],
      key: item,
    );
  }
}
