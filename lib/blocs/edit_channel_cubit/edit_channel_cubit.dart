import 'package:bloc/bloc.dart';
import 'package:twake/pages/edit_channel.dart';
import 'package:twake/repositories/channel_repository.dart';
import 'edit_channel_state.dart';

class EditChannelCubit extends Cubit<EditChannelState> {
  final ChannelRepository repository;

  EditChannelCubit(this.repository) : super(EditChannelInitial());

  Future<void> load() async {}

  Future<void> save() async {
    final isSaved = await repository.edit();
    if (isSaved) {
      emit(EditChannelSaved());
    } else {
      emit(EditChannelError('Error on channel editing.'));
    };
  }

  void update({
    String name,
    String description,
    List<String> members,
    bool automaticallyAddNew,
  }) {
    repository.name = name ?? repository.name;
    repository.description = description ?? repository.description;
    repository.members = members ?? repository.members ?? [];
    repository.def = automaticallyAddNew ?? repository.def ?? true;

    var newRepo = ChannelRepository(
      repository.companyId,
      repository.workspaceId,
      repository.name,
      description: repository.description,
      members: repository.members,
      def: repository.def,
    );
    emit(EditChannelUpdated(newRepo));
  }

  void setFlowStage(EditFlowStage stage) {
    emit(EditChannelStageUpdated(stage));
  }

  void clear() {
    repository.clear();
  }
}
