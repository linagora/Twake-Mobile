import 'package:bloc/bloc.dart';
import 'package:twake/repositories/edit_channel_repository.dart';
import 'edit_channel_state.dart';

class EditChannelCubit extends Cubit<EditChannelState> {
  final EditChannelRepository repository;

  EditChannelCubit(this.repository) : super(EditChannelInitial());

  Future<void> load() async {}

  Future<void> save() async {
    final isSaved = await repository.edit();
    if (isSaved) {
      emit(EditChannelSaved(repository));
    } else {
      emit(EditChannelError('Error on channel editing.'));
    }
  }

  Future<void> delete() async {
    final isDeleted = await repository.delete();
    if (isDeleted) {
      emit(EditChannelDeleted());
    } else {
      emit(EditChannelError('Error on channel deletion.'));
    }
  }

  void update({
    String channelId,
    String icon,
    String name,
    String description,
    bool automaticallyAddNew,
  }) {
    repository.channelId = channelId;
    repository.icon = icon;
    repository.name = name ?? repository.name;
    repository.description = description ?? repository.description;
    repository.def = automaticallyAddNew ?? repository.def ?? true;

    var newRepo = EditChannelRepository(
      channelId: repository.channelId,
      icon: repository.icon,
      name: repository.name,
      description: repository.description,
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
