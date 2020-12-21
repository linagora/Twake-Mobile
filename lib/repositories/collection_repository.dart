import 'package:json_annotation/json_annotation.dart';

import 'package:twake/services/service_bundle.dart';
import 'package:twake/models/company.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/models/channel.dart';

class CollectionRepository<T extends JsonSerializable> {
  List<T> items;
  final String apiLoadMethod;

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

  CollectionRepository({this.items, this.apiLoadMethod});

  int get itemsCount => (items ?? []).length;

  @JsonKey(ignore: true)
  static final _logger = Logger();
  @JsonKey(ignore: true)
  static final _api = Api();
  @JsonKey(ignore: true)
  static final _storage = Storage();

  // Sort of a constructor method
  // to load and build instance of class from either
  // storage or api request
  static Future<CollectionRepository> load<T extends JsonSerializable>(
    String apiLoadMethod,
  ) async {
    _logger.d('Loading $T from storage');
    var itemsList = await _storage.loadList(type: _typeToStorageType[T]);
    if (itemsList == null) {
      _logger.d('No $T items found in storage, requesting from api...');
      itemsList = await _api.get(apiLoadMethod);
    }
    final items = itemsList.map((i) => _typeToConstuctor[T](i));
    return CollectionRepository<T>(items: items, apiLoadMethod: apiLoadMethod);
  }

  Future<void> reload() async {
    _logger.d('Reloading $T items from api...');
    final itemsList = await _api.get(apiLoadMethod);
    _updateItems(itemsList);
  }

  Future<void> addFromApi() async {
    _logger.d('Reloading $T items from api...');
    final itemsList = await _api.get(apiLoadMethod);
    _updateItems(itemsList);
  }

  void _updateItems(List<Map<String, dynamic>> itemsList) {
    final items = itemsList.map((c) => _typeToConstuctor[T](c)).toList();
    this.items = items;
  }

  Future<void> save() async {
    await _storage.storeList(
      items: this.items,
      type: _typeToStorageType[T],
    );
  }
}
