import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/channels_cubit/edit_channel_cubit/edit_channel_state.dart';

class EditChannelCubit extends Cubit<EditChannelState> {
  late final ChannelsCubit _channelsCubit;

  EditChannelCubit({
    required ChannelsCubit channelsCubit,
  }) : super(EditChannelInitial()) {
    _channelsCubit = channelsCubit;
  }

  void showEmoijKeyBoard(bool isShow) {
    emit(EditChannelValidation(
        validToEditChannel: state.validToEditChannel,
        showEmoijKeyboard: isShow,
        emoijIcon: state.emoijIcon));
  }

  void setEmoijIcon(String icon) {
    emit(EditChannelValidation(
        validToEditChannel: state.validToEditChannel,
        showEmoijKeyboard: false,
        emoijIcon: icon));
  }

  void validateEditChannelData({required String name}) {
    emit(EditChannelValidation(
        validToEditChannel: name.isNotEmpty,
        showEmoijKeyboard: state.showEmoijKeyboard,
        emoijIcon: state.emoijIcon));
  }

  void editChannel(
  {
    required Channel currentChannel,
    required String name,
    String? description,
    required String icon
  }) async {
    emit(EditChannelInProgress(emoijIcon: state.emoijIcon));

    final result = await _channelsCubit.edit(
        channel: currentChannel,
        name: name,
        description: description,
        icon: icon);

    emit(result ? const EditChannelSuccess() : const EditChannelFailure());
  }
}
