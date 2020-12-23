import 'package:twake/services/service_bundle.dart';
import 'package:twake/models/company.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/collection_item.dart';

class CollectionRepository<T extends CollectionItem> {
  List<T> items;
  final String apiEndpoint;

  // Ugly hack, but there's no other way to get constructor from generic type
  static Map<Type, Function> _typeToConstuctor = {
    Company: (Map<String, dynamic> json) => Company.fromJson(json),
    Workspace: (Map<String, dynamic> json) => Workspace.fromJson(json),
    // TODO remove null, once API returns workspaceId
    Channel: (Map<String, dynamic> json) => Channel.fromJson(json, null),
  };

  static Map<Type, StorageType> _typeToStorageType = {
    Company: StorageType.Company,
    Workspace: StorageType.Workspace,
    Channel: StorageType.Channel,
  };

  CollectionRepository({this.items, this.apiEndpoint});

  int get itemsCount => (items ?? []).length;

  static final _logger = Logger();
  static final _api = Api();
  static final _storage = Storage();

  // Sort of a constructor method
  // to load and build instance of class from either
  // storage or api request
  static Future<CollectionRepository> load<T extends CollectionItem>(
    String apiEndpoint,
  ) async {
    _logger.d('Loading $T from storage');
    var itemsList = await _storage.loadList(type: _typeToStorageType[T]);
    if (itemsList == null) {
      _logger.d('No $T items found in storage, requesting from api...');
      itemsList = await _api.get(apiEndpoint);
    }
    final items = itemsList.map((i) => _typeToConstuctor[T](i));
    return CollectionRepository<T>(items: items, apiEndpoint: apiEndpoint);
  }

  Future<void> reload({
    Map<String, dynamic> queryParams,
  }) async {
    _logger.d('Reloading $T items from api...');
    final itemsList = await _api.get(apiEndpoint, params: queryParams);
    _updateItems(itemsList);
  }

  Future<void> pullOne(Map<String, dynamic> queryParams) async {
    _logger.d('Pulling item $T from api...');
    final item = (await _api.get(apiEndpoint, params: queryParams))[0];
    this.items.add(_typeToConstuctor[T](item));
    _storage.store(
      item: item,
      type: _typeToStorageType[T],
      key: item,
    );
  }

  Future<void> clean() async {
    await _storage.clearList(_typeToStorageType[T]);
    items.clear();
  }

  Future<void> delete(
    key, {
    bool apiSync,
    Map<String, dynamic> requestBody,
  }) async {
    await _storage.clean(type: _typeToStorageType[T], key: key);
    if (apiSync) {
      await _api.delete(apiEndpoint, body: requestBody);
    }
    items.removeWhere((i) => i.id == key);
  }

  void _updateItems(List<Map<String, dynamic>> itemsList) {
    final items = itemsList.map((c) => _typeToConstuctor[T](c)).toList();
    this.items = items;
    this.save();
  }

  Future<void> save() async {
    await _storage.storeList(
      items: this.items,
      type: _typeToStorageType[T],
    );
  }
}
