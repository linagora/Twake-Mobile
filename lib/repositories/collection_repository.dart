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
    Message: (Map<String, dynamic> json) => Message.fromJson(json),
    Direct: (Map<String, dynamic> json) => Direct.fromJson(json),
  };

  static Map<Type, StorageType> _typeToStorageType = {
    Company: StorageType.Company,
    Workspace: StorageType.Workspace,
    Channel: StorageType.Channel,
    Message: StorageType.Message,
    Direct: StorageType.Direct,
  };

  CollectionRepository({this.items, this.apiEndpoint});

  CollectionItem get selected =>
      items.firstWhere((i) => i.isSelected, orElse: () => items[0]);

  int get itemsCount => (items ?? []).length;

  static final logger = Logger();
  static final _api = Api();
  static final _storage = Storage();

  // Sort of a constructor method
  // to load and build instance of class from either
  // storage or api request
  static Future<CollectionRepository> load<T extends CollectionItem>(
    String apiEndpoint, {
    Map<String, dynamic> queryParams,
    List<List> filters,
  }) async {
    List<dynamic> itemsList = await _storage.loadList(
      type: _typeToStorageType[T],
      filters: filters,
    );
    if (itemsList.isEmpty) {
      logger.d('No $T items found in storage, requesting from api...');
      itemsList = await _api.get(apiEndpoint, params: queryParams);
    }
    final items = itemsList.map((i) => (_typeToConstuctor[T](i) as T)).toList();
    final collection =
        CollectionRepository<T>(items: items, apiEndpoint: apiEndpoint);
    collection.save();
    return collection;
  }

  void select(String itemId) {
    final item =
        items.firstWhere((i) => i.id == itemId, orElse: () => items[0]);
    final oldSelected = selected..isSelected = false;
    item.isSelected = true;
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
    bool saveToStore: false,
  }) async {
    List<dynamic> itemsList = [];
    if (!forceFromApi) {
      logger.d('Reloading $T items from storage...');
      itemsList = await _storage.loadList(
        type: _typeToStorageType[T],
        filters: filters,
        sortFields: sortFields,
      );
    }
    if (itemsList.isEmpty) {
      // logger.d('Reloading $T items from api...');
      itemsList = await _api.get(apiEndpoint, params: queryParams);
    }
    if (saveToStore) await this.save();
    _updateItems(itemsList);
  }

  Future<void> pullOne(
    Map<String, dynamic> queryParams, {
    bool addToItems = true,
  }) async {
    logger.d('Pulling item $T from api...');
    final resp = (await _api.get(apiEndpoint, params: queryParams))[0];
    final item = _typeToConstuctor[T](resp);
    if (addToItems) this.items.add(item);
    saveOne(item);
  }

  Future<void> pushOne(
    Map<String, dynamic> body, {
    addToItems = true,
  }) async {
    logger.d('Sending item $T to api...');
    final resp = (await _api.post(apiEndpoint, body: body));
    final item = _typeToConstuctor[T](resp);
    if (addToItems) this.items.add(item);
    saveOne(item);
  }

  Future<void> clean() async {
    await _storage.clearList(_typeToStorageType[T]);
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

  void _updateItems(List<dynamic> itemsList) {
    final items = itemsList.map((c) => (_typeToConstuctor[T](c) as T)).toList();
    this.items = items;
  }

  Future<void> save() async {
    await _storage.storeList(
      items: this.items,
      type: _typeToStorageType[T],
    );
  }

  Future<void> saveOne(T item) async {
    await _storage.store(
      item: item,
      type: _typeToStorageType[T],
      key: item,
    );
  }
}
