import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_workspace_state.dart';

class AddWorkspaceCubit extends Cubit<AddWorkspaceState> {
  AddWorkspaceCubit() : super(AddWorkspaceInitial());
}
