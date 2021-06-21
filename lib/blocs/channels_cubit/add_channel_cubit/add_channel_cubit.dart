import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:twake/blocs/channels_cubit/add_channel_cubit/add_channel_state.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/channel/channel_visibility.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/channels_repository.dart';

class AddChannelCubit extends Cubit<AddChannelState> {
  late final ChannelsRepository _channelsRepository;
  late final ChannelsCubit _channelsCubit;
  String _emoijIcon = '';

  ChannelVisibility _channelVisibility = ChannelVisibility.public;
  ChannelVisibility get channelVisibility => _channelVisibility;

  void setChannelVisibility(ChannelVisibility channelVisibility) => _channelVisibility = channelVisibility;

  AddChannelCubit({required ChannelsRepository channelsRepository, required ChannelsCubit channelsCubit})
      : super(AddChannelInitial()) {
    _channelsRepository = channelsRepository;
    _channelsCubit = channelsCubit;
  }

  void showEmoijKeyBoard(bool isShow) {
    emit(AddChannelValidation(validToCreateChannel: state.validToCreateChannel, showEmoijKeyboard: isShow, emoijIcon: state.emoijIcon));
  }

  void setEmoijIcon(String icon) {
    _emoijIcon = icon;
    emit(AddChannelValidation(
        validToCreateChannel: state.validToCreateChannel,
        showEmoijKeyboard: false,
        emoijIcon: _emoijIcon));
  }

  void validateAddChannelData({required String name}) {
    emit(AddChannelValidation(
        validToCreateChannel: name.isNotEmpty,
        showEmoijKeyboard: state.showEmoijKeyboard,
        emoijIcon: state.emoijIcon));
  }

  Future<void> create({
    required String name,
    String? description,
  }) async {
    emit(AddChannelInProgress(emoijIcon: state.emoijIcon));

    final now = DateTime.now().millisecondsSinceEpoch;
    var channel = Channel(
      id: now.toString(),
      name: name,
      icon: state.emoijIcon,
      description: description,
      companyId: Globals.instance.companyId!,
      workspaceId: Globals.instance.workspaceId!,
      members: const [],
      lastActivity: now,
      visibility: _channelVisibility,
      permissions: const [],
    );
    try {
      channel = await _channelsRepository.create(channel: channel);
    } catch (e) {
      Logger().e('Error occured during channel creation:\n$e');
      emit(AddChannelFailure());
      return;
    }

    emit(AddChannelSuccess());
    _channelsCubit.changeSelectedChannelAfterCreateSuccess(channel: channel);
  }
}
