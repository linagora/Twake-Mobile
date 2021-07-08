import 'package:equatable/equatable.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';

abstract class ChannelSettingState with EquatableMixin {
  final ChannelVisibility channelVisibility;
  final bool validToEditChannel;

  const ChannelSettingState({this.channelVisibility = ChannelVisibility.public, this.validToEditChannel = false});

  @override
  List<Object?> get props => [channelVisibility, validToEditChannel];
}

class ChannelSettingInitial extends ChannelSettingState {
  @override
  List<Object?> get props => [];
}

class ChannelSettingInSettingState extends ChannelSettingState {
  const ChannelSettingInSettingState(
      {ChannelVisibility channelVisibility = ChannelVisibility.public, bool validToEditChannel = false})
      : super(channelVisibility: channelVisibility, validToEditChannel: validToEditChannel);

  @override
  List<Object?> get props => super.props;
}

class ChannelSettingInProgress extends ChannelSettingState {
  const ChannelSettingInProgress(
      {ChannelVisibility channelVisibility = ChannelVisibility.public, bool validToEditChannel = false})
      : super(channelVisibility: channelVisibility, validToEditChannel: validToEditChannel);

  @override
  List<Object?> get props => super.props;
}

class ChannelSettingSuccess extends ChannelSettingState {
  const ChannelSettingSuccess();
}

class ChannelSettingFailure extends ChannelSettingState {
  const ChannelSettingFailure();
}
