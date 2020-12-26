import 'dart:collection';

import 'package:twake/models/user.dart';
import 'package:twake/services/service_bundle.dart';

const _BUFFER_SIZE = 250;

class UserRepository {
  ListQueue<User> items = ListQueue(_BUFFER_SIZE);
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
    User item = items.firstWhere((i) => i.id == userId, orElse: () => null);
    if (item == null) {
      final userMap = await _storage.load(type: StorageType.User, key: userId);
      if (userMap != null) {
        item = User.fromJson(userMap);
        items.add(item);
      }
    }
    if (item == null) {
      final list = await _api.get(apiEndpoint, params: {'id': userId});
      final Map userMap = list[0];
      if (userMap.isNotEmpty) {
        item = User.fromJson(userMap);
        items.add(item);
        save(item);
      }
    }
    return item;
  }

  Future<void> batchUsersLoad(Set<String> userIds) async {
    final List response = await _api.get(apiEndpoint, params: {
      'id': userIds,
    });
    items.clear();
    final users = response.map((u) => User.fromJson(u));
    items.addAll(users);
    logger.d('Loaded ${items.length} users for messages');
  }

  Future<void> save(User user) async {
    await _storage.store(item: user, type: StorageType.User, key: user.id);
  }
}
