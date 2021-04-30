import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/models/user.dart';
import 'package:twake/services/service_bundle.dart';

class MentionsRepository {
  final _storage = Storage();

  Future<List<User>> mentionableUsers(String match) async {
    // Logger().e("SEARCHING FOR: $match");
    final List<Map> result = await _storage.customQuery(
      'SELECT user.* FROM user '
      'JOIN user2workspace AS u2w ON '
      'user.id == u2w.user_id',
      filters: [
        ['workspace_id', '=', ProfileBloc.selectedWorkspaceId],
      ],
      likeFilters: [
        ['username', match],
        ['firstname', match],
        ['lastname', match]
      ],
      orderings: {'firstname': true},
    );
    final users = result.map((r) => User.fromJson(r)).toList();
    // Logger().e("FOUND: ${users.length} users for match");

    return users;
  }

  Future<String> getUserId(String username) async {
    final user = await _storage.customQuery(
      'SELECT id FROM user',
      filters: [
        ['username', '=', username]
      ],
    );
    return user['id'];
  }
}
