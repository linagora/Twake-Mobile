import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_cubit/channel_settings_cubit/channel_setting_state.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';

class ChannelSettingCubit extends Cubit<ChannelSettingState> {
  late final ChannelsCubit _channelsCubit;

  ChannelSettingCubit({
    required ChannelsCubit channelsCubit,
  }) : super(ChannelSettingInitial()) {
    _channelsCubit = channelsCubit;
  }

  void setChannelVisibility(
      Channel? currentChannel, ChannelVisibility channelVisibility) {
    emit(ChannelSettingInSettingState(
        channelVisibility: channelVisibility,
        validToEditChannel: currentChannel?.visibility != channelVisibility ? true : false));
  }

  void editChannel({
    required Channel currentChannel,
  }) async {
    emit(ChannelSettingInProgress(channelVisibility: state.channelVisibility));

    final result = await _channelsCubit.edit(
        channel: currentChannel,
        visibility: state.channelVisibility);

    emit(result ? const ChannelSettingSuccess() : const ChannelSettingFailure());
  }
}
