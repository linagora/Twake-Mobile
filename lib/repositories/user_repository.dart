import 'package:twake/models/user.dart';
import 'package:twake/services/service_bundle.dart';

class UserRepository {
  Map<String, User> items = {};
  static UserRepository _userRepository;
  final String apiEndpoint;

  factory UserRepository([String apiEndpoint]) {
    if (_userRepository == null || apiEndpoint != null) {
      _userRepository = UserRepository._(apiEndpoint);
    }
    return _userRepository;
  }

  UserRepository._(this.apiEndpoint);

  final _api = Api();
  final _storage = Storage();
  final logger = Logger();

  Future<User> user(String userId) async {
    User item = items[userId];
    if (item == null) {
      final userMap = await _storage.load(type: StorageType.User, key: userId);
      if (userMap != null) {
        item = User.fromJson(userMap);
        items[userId] = item;
      }
    }
    if (item == null) {
      List list;
      try {
        list = await _api.get(apiEndpoint, params: {'id': userId});
      } on ApiError catch (error) {
        logger.d('ERROR WHILE FETCHING user FROM API\n${error.message}');
        throw error;
      }
      final Map userMap = list[0];
      if (userMap.isNotEmpty) {
        item = User.fromJson(userMap);
        items[userId] = item;
        save(item);
      }
    }
    return item;
  }

  Future<bool> batchUsersLoad(Set<String> userIds) async {
    items.removeWhere((id, _) => !userIds.contains(id));
    userIds.retainAll(items.keys);
    List<String> toBeFetched = [];
    for (String id in userIds) {
      final item = await _storage.load(type: StorageType.User, key: id);
      if (item == null)
        toBeFetched.add(id);
      else
        items[id] = User.fromJson(item);
    }
    if (toBeFetched.isNotEmpty) {
      List response = [];
      try {
        response = await _api.get(
          apiEndpoint,
          params: {
            'id': toBeFetched,
          },
        );
      } on ApiError catch (error) {
        logger.d('ERROR WHILE FETCHING users FROM API\n${error.message}');
        return false;
      }
      final users =
          response.map((u) => User.fromJson(u)).map((u) => MapEntry(u.id, u));
      items.addEntries(users);
    }
    _storage.batchStore(
      items: items.values.map((u) => u.toJson()),
      type: StorageType.User,
    );
    logger.d('Loaded ${items.length} users for messages');
    return true;
  }

  Future<void> save(User user) async {
    await _storage.store(
      item: user.toJson(),
      type: StorageType.User,
      key: user.id,
    );
  }

  Future<List<User>> users() async {
    return [];
  }
}
