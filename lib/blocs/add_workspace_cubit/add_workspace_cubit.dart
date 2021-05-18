import 'package:bloc/bloc.dart';
import 'package:twake/repositories/add_workspace_repository.dart';
import 'add_workspace_state.dart';

class AddWorkspaceCubit extends Cubit<AddWorkspaceState> {
  final AddWorkspaceRepository? repository;

  AddWorkspaceCubit(this.repository) : super(AddWorkspaceInitial());

  Future<void> create() async {
    emit(Creation());
    final result = await (repository!.create() as FutureOr<String>);
    if (result.isNotEmpty) {
      emit(Created(result));
    } else {
      emit(Error('Workspace creation failure!'));
    }
  }

  // void updateMembers({
  //   @required String workspaceId,
  //   @required List<String> members,
  // }) async {
  //   final result = await repository.updateMembers(
  //     members: members,
  //     workspaceId: workspaceId,
  //   );
  //   if (result) {
  //     emit(MembersUpdated(workspaceId: workspaceId, members: members));
  //   } else {
  //     emit(Error('Members update failure!'));
  //   }
  // }

  void clear() {
    repository!.clear();
  }

  void update({String? name, List<String>? members}) {
    repository!.name = name ?? repository!.name;
    repository!.members = members ?? repository!.members ?? [];

    var newRepo = AddWorkspaceRepository(
      name: repository!.name,
      members: repository!.members,
    );
    emit(Updated(newRepo));
  }

  void setFlowStage(FlowStage stage) {
    emit(StageUpdated(stage));
  }
}
