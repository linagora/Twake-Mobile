import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/models/user.dart';
import 'package:twake/services/service_bundle.dart';

class MessageEditRepository {
  final _storage = Storage();

  Future<List<User>> users(String match) async {
    _storage.customQuery(
        'SELECT user.* FROM user '
        'JOIN user2workspace AS u2w ON '
        'user.id == u2w.user_id',
        filters: [
          ['workspace_id', '=', ProfileBloc.selectedWorkspaceId],
          ['', '=', ProfileBloc.selectedWorkspaceId],
        ]);
    return List<User>();
  }
}
