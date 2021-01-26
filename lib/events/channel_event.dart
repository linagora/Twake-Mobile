import 'package:equatable/equatable.dart';

abstract class ChannelsEvent extends Equatable {
  const ChannelsEvent();
}

class ReloadChannels extends ChannelsEvent {
  final String workspaceId;
  // parent company id for directs
  final String companyId;
  final bool forceFromApi;
  const ReloadChannels({
    this.workspaceId,
    this.companyId,
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

class ModifyMessageCount extends ChannelsEvent {
  final String channelId;
  final String workspaceId;
  final String companyId;
  final int totalModifier;
  final int unreadModifier;
  final int timeStamp;

  ModifyMessageCount({
    this.channelId,
    this.workspaceId,
    this.companyId,
    this.totalModifier,
    this.unreadModifier,
    this.timeStamp,
  });

  @override
  List<Object> get props => [channelId];
}

class RemoveChannel extends ChannelsEvent {
  final String channelId;
  RemoveChannel(this.channelId);

  @override
  List<Object> get props => [channelId];
}
