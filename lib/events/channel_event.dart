import 'package:equatable/equatable.dart';

abstract class ChannelsEvent extends Equatable {
  const ChannelsEvent();
}

class ReloadChannels extends ChannelsEvent {
  // parent company id
  final String workspaceId;
  final bool forceFromApi;
  const ReloadChannels({
    this.workspaceId,
    this.forceFromApi: false,
  });
  @override
  List<Object> get props => [];
}

class ClearChannels extends ChannelsEvent {
  const ClearChannels();
  @override
  List<Object> get props => [];
}

class LoadSingleChannel extends ChannelsEvent {
  final String channelId;
  LoadSingleChannel(this.channelId);

  @override
  List<Object> get props => [channelId];
}

class ChangeSelectedChannel extends ChannelsEvent {
  final String channelId;
  ChangeSelectedChannel(this.channelId);

  @override
  List<Object> get props => [channelId];
}

class RemoveChannel extends ChannelsEvent {
  final String channelId;
  RemoveChannel(this.channelId);

  @override
  List<Object> get props => [channelId];
}
