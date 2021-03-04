import 'package:twake/models/message.dart';
import 'package:twake/repositories/user_repository.dart';
import 'package:twake/services/service_bundle.dart';

class MessagesRepository {
  List<Message> items;
  final String apiEndpoint;

  List<Message> get roItems => [...items];

  MessagesRepository({this.items, this.apiEndpoint});

  bool get isEmpty => items.isEmpty;

  Message get selected =>
      items.firstWhere((i) => i.isSelected == 1, orElse: () {
        if (items.isNotEmpty) return items[0];
        return null;
      });

  int get itemsCount => (items ?? []).length;

  final logger = Logger();
  static final _api = Api();
  static final _storage = Storage();

  void select(String itemId, {bool saveToStore: true}) {
    final item = items.firstWhere((i) => i.id == itemId);
    var oldSelected = selected;
    oldSelected.isSelected = 0;
    item.isSelected = 1;
    // assert(selected.id == item.id);
    saveOne(item);
    saveOne(oldSelected);
  }

  Future<bool> reload({
    Map<String, dynamic> queryParams,
    List<List> filters, // fields to filter by in store
    Map<String, bool> sortFields, // fields to sort by + sort direction
    bool forceFromApi: false,
    int limit,
  }) async {
    List<dynamic> itemsList = [];

    final messageCountQuery = 'SELECT count(id) as count '
        'FROM message';
    final List count =
        await _storage.customQuery(messageCountQuery, filters: filters);
    if (count[0]['count'] < 10) {
      forceFromApi = true;
    }
    if (!forceFromApi) {
      final maxDateQuery =
          // 'SELECT max(modification_date) as max_mod, '
          'SELECT max(creation_date) as max_create '
          'FROM message';
      final maxFilter = List.from(filters);
      maxFilter.removeLast();
      final List max =
          await _storage.customQuery(maxDateQuery, filters: filters);
      // logger.d('REQUESTING MESSAGES AFTER: $max');
      if (max.isNotEmpty && max[0]['max_create'] != null) {
        queryParams['after_date'] = max[0]['max_create'].toString();
      }
    }
    try {
      // logger.d('Query params is: $queryParams');
      itemsList = await _api.get(apiEndpoint, params: queryParams);
    } on ApiError catch (error) {
      logger.d('ERROR while reloading Messages from api\n${error.message}');
    }
    final Set<String> userIds =
        itemsList.map((i) => (i['user_id'] as String)).toSet();
    // logger.d('USERIDS: $userIds');
    await UserRepository().batchUsersLoad(userIds);
    await _storage.batchStore(
      items: itemsList.map((i) {
        final m = Message.fromJson(i).toJson();
        return m;
      }),
      type: StorageType.Message,
    );
    final query = 'SELECT message.*, '
        'user.username, '
        'user.firstname, '
        'user.lastname, '
        'user.thumbnail '
        'FROM message JOIN user ON user.id = message.user_id';
    itemsList = await _storage.customQuery(
      query,
      filters: filters,
      orderings: sortFields,
      limit: limit,
      offset: 0,
    );
    await _updateItems(itemsList, saveToStore: false);
    // logger.d('Loaded ${itemsList.length} messages');
    return true;
  }

  Future<bool> loadMore({
    Map<String, dynamic> queryParams,
    List<List> filters, // fields to filter by in store
    Map<String, bool> sortFields, // fields to sort by + sort direction
    int limit,
    int offset,
  }) async {
    List<dynamic> itemsList = [];
    logger.d('Loading more messages from storage...\nFilters: $filters');
    final query = 'SELECT message.*, '
        'user.username, '
        'user.firstname, '
        'user.lastname, '
        'user.thumbnail '
        'FROM message INNER JOIN user ON user.id = message.user_id';
    itemsList = await _storage.customQuery(
      query,
      filters: filters,
      orderings: sortFields,
      limit: limit,
      offset: 0,
    );
    // logger.d('Loaded ${itemsList.length} items');
    if (itemsList.isEmpty) {
      try {
        itemsList = await _api.get(apiEndpoint, params: queryParams);
        // logger.d('Loaded ${itemsList.length} MESSAGES FROM API');
      } on ApiError catch (error) {
        logger
            .d('ERROR while loading more Messages from api\n${error.message}');
        return false;
      }
      final Set<String> userIds =
          itemsList.map((i) => (i['user_id'] as String)).toSet();
      await UserRepository().batchUsersLoad(userIds);
      await _storage.batchStore(
        items: itemsList.map((i) => Message.fromJson(i).toJson()),
        type: StorageType.Message,
      );
      itemsList = await _storage.customQuery(
        query,
        filters: filters,
        orderings: sortFields,
        limit: limit,
        offset: 0,
      );
    }
    if (itemsList.isNotEmpty) {
      await _updateItems(itemsList, saveToStore: false, extendItems: true);
    }
    return true;
  }

  Future<Message> updateResponsesCount(String messageId) async {
    var m = await getItemById(messageId);
    if (m == null) return null;
    // print('BEFORE COUNT: ${m.responsesCount}\nID: $messageId');
    final sqlT = 'SELECT count(id) as count FROM message';
    var res;
    res = (await _storage.customQuery(sqlT, filters: [
      ['thread_id', '=', messageId]
    ]))[0]['count'];
    if (res != 0) {
      m.responsesCount = res;
      await _storage.store(item: m.toJson(), type: StorageType.Message);
    }
    // print('RESPONSES COUNT: $res');
    // final sql = 'UPDATE message SET responses_count = '
    // '(SELECT count(id) FROM message WHERE thread_id = ?) WHERE id = ?';
    // final args = [messageId, messageId];
    // await _storage.customUpdate(
    // sql: sql,
    // args: args,
    // );
    // print('MESSAGE AFTER UPDATE: ${m.toJson()}');
    // items.firstWhere((i) => i.id == m.id, orElse: () => null)?.responsesCount =
    // m.responsesCount;
    return m;
  }

  Future<bool> pullOne(
    Map<String, dynamic> queryParams, {
    bool addToItems = true,
  }) async {
    logger.d('Pulling item Message from api...\nPARAMS: $queryParams');
    List resp = [];
    try {
      resp = (await _api.get(apiEndpoint, params: queryParams));
    } on ApiError catch (error) {
      logger.e('ERROR while loading more Message from api\n${error.message}');
      return false;
    }
    if (resp.isEmpty) return false;
    var item = Message.fromJson(resp[0]);
    var isNew = true;
    if (await getItemById(queryParams['message_id']) != null) {
      logger.e("MESSAGE EXISTS");
      isNew = false;
    }
    saveOne(item);
    if (addToItems) {
      final query = 'SELECT message.*, '
          'user.username, '
          'user.firstname, '
          'user.lastname, '
          'user.thumbnail '
          'FROM message INNER JOIN user ON user.id = message.user_id';
      final List itemMapTemp = (await _storage.customQuery(
        query,
        filters: [
          ['message.id', '=', item.id]
        ],
        limit: 1,
        offset: 0,
      ));
      var itemMap;
      if (itemMapTemp.isNotEmpty) {
        itemMap = itemMapTemp[0];
      }
      if (itemMap == null) return false;

      final message = Message.fromJson(itemMap);
      final old =
          this.items.firstWhere((m) => m.id == message.id, orElse: () => null);
      if (old != null) this.items.remove(old);
      this.items.add(message);
    }

    logger.d('Pulled item: ${item.toJson()}');
    return isNew;
  }

  Future<bool> pushOne(
    Map<String, dynamic> body, {
    Function onError,
    Function(Message) onSuccess,
    addToItems = true,
  }) async {
    logger.d('Sending item Message to api...');
    var resp;
    try {
      resp = (await _api.post(apiEndpoint, body: body));
    } catch (error) {
      logger.e('Error while sending Message to api\n${error.message}');
      if (onError != null) onError();
      return false;
    }
    logger.d('RESPONSE AFTER SENDING ITEM: $resp');
    final item = Message.fromJson(resp);
    await saveOne(item);
    if (addToItems) this.items.add(item);
    if (onSuccess != null) onSuccess(item);
    return true;
  }

  Future<Message> getItemById(String id, [forceFromDB = false]) async {
    Message item;
    if (!forceFromDB)
      item = items.firstWhere((i) => i.id == id, orElse: () => null);
    if (item == null) {
      print('GETTING MESSAGE BY ID: $id');
      var map = await _storage.load(type: StorageType.Message, key: id);
      print('MESSAGE: $map');
      if (map == null) return null;
      item = Message.fromJson(map);
    }
    return item;
  }

  Future<void> clean() async {
    items.clear();
    await _storage.truncate(StorageType.Message);
  }

  Future<bool> delete(
    key, {
    bool apiSync: true,
    bool removeFromItems: true,
    Map<String, dynamic> requestBody,
  }) async {
    if (apiSync) {
      try {
        await _api.delete(apiEndpoint, body: requestBody);
      } catch (error) {
        logger.e('Error while sending Message to api\n${error.message}');
        return false;
      }
    }
    await _storage.delete(type: StorageType.Message, key: key);
    if (removeFromItems) items.removeWhere((i) => i.id == key);
    return true;
  }

  void clear() {
    this.items.clear();
  }

  Future<void> _updateItems(
    List<dynamic> itemsList, {
    bool saveToStore: false,
    bool extendItems: false,
  }) async {
    final items = itemsList.map((c) => Message.fromJson(c));
    if (extendItems)
      this.items.addAll(items);
    else
      this.items = items.toList();
    if (saveToStore) await this.save();
  }

  Future<void> save() async {
    logger.d('SAVING Messages items to store!');
    await _storage.batchStore(
      items: this.items.map((i) => i.toJson()),
      type: StorageType.Message,
    );
  }

  Future<void> saveOne(Message item) async {
    await _storage.store(
      item: item.toJson(),
      type: StorageType.Message,
      key: item,
    );
  }
}
