import 'package:twake/models/user.dart';
import 'package:twake/services/service_bundle.dart';

class UserRepository {
  List<User> items = [];
  final String apiEndpoint;

  UserRepository(this.apiEndpoint);

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

  Future<void> save(User user) async {
    await _storage.store(item: user, type: StorageType.User, key: user.id);
  }
}
