import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:twake/repositories/add_workspace_repository.dart';

part 'add_workspace_state.dart';

class AddWorkspaceCubit extends Cubit<AddWorkspaceState> {
  final AddWorkspaceRepository repository;

  AddWorkspaceCubit(this.repository) : super(AddWorkspaceInitial());

  void create({
    @required String companyId,
    @required String name,
  }) async {
    // final result = await repository
  }

  void updateMembers() {}

  void clear() {}
}
