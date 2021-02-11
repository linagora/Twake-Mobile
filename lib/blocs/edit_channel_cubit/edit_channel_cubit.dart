import 'package:bloc/bloc.dart';
import 'package:twake/pages/edit_channel.dart';
import 'package:twake/repositories/edit_channel_repository.dart';
import 'edit_channel_state.dart';

class EditChannelCubit extends Cubit<EditChannelState> {
  final EditChannelRepository repository;

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
    String channelId,
    String name,
    String description,
    bool automaticallyAddNew,
  }) {
    repository.channelId = channelId;
    repository.name = name ?? repository.name;
    repository.description = description ?? repository.description;
    repository.def = automaticallyAddNew ?? repository.def ?? true;

    var newRepo = EditChannelRepository(
      channelId: repository.channelId,
      name: repository.name,
      description: repository.description,
      icon: repository.icon,
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
