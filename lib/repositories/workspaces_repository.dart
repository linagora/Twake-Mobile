import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/models/user.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/services/service_bundle.dart';

class WorkspacesRepository extends CollectionRepository<Workspace> {
  final _api = Api();
  final _storage = Storage();

  Future<void> fetchMembers({bool forceFromApi: false}) async {
    if (!forceFromApi) {
      final count = (await _storage.customQuery(
        'SELECT count(*) as count FROM user2workspace',
        filters: [
          ['workspace_id', '=', this.selected!.id]
        ],
      ))[0]['count'];
      // Logger().e("REQUEST: $count");
      if (count > 0) return;
    }
    final List tmembers = await (this._api.get(Endpoint.workspaceMembers,
        params: {
          'workspace_id': this.selected!.id,
          'company_id': ProfileBloc.selectedCompanyId
        }) as FutureOr<List<dynamic>>);
    List<User> members = [];
    for (var tm in tmembers) {
      members.add(User.fromJson(tm));
    }

    await _storage.batchStore(
      items: members.map((m) => m.toJson()),
      type: StorageType.User,
    );

    await _storage.batchStore(
      items: members
          .map((m) => {'user_id': m.id, 'workspace_id': this.selected!.id}),
      type: StorageType.User2Workspace,
    );
    Logger().w('Workspace members ${members.length} are saved!');
  }

  WorkspacesRepository(List<Workspace?>? items, String? apiEndpoint)
      : super(
          items: items,
          apiEndpoint: apiEndpoint,
        );

  factory WorkspacesRepository.fromCollection(
      CollectionRepository<Workspace> repository) {
    return WorkspacesRepository(repository.items, repository.apiEndpoint);
  }
}
