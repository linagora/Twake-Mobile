import 'package:equatable/equatable.dart';
import 'package:twake/models/base_channel.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/direct.dart';

abstract class ChannelState extends Equatable {
  const ChannelState();
}

class BaseChannelsLoaded extends ChannelState {
  final List<BaseChannel> channels;

  const BaseChannelsLoaded({
    this.channels,
  });
  @override
  List<Object> get props => [channels];
}

class ChannelsLoaded extends BaseChannelsLoaded {
  const ChannelsLoaded({
    channels,
  }) : super(channels: channels);
}

class ChannelPicked extends ChannelsLoaded {
  final BaseChannel selected;
  const ChannelPicked({List<Channel> channels, this.selected})
      : super(channels: channels);
}

class DirectsLoaded extends BaseChannelsLoaded {
  const DirectsLoaded({
    channels,
  }) : super(channels: channels);
}

class DirectPicked extends DirectsLoaded {
  final BaseChannel selected;
  const DirectPicked({List<Direct> directs, this.selected})
      : super(channels: directs);
}

class ChannelsLoading extends ChannelState {
  const ChannelsLoading();
  @override
  List<Object> get props => [];
}

class ChannelsEmpty extends ChannelState {
  const ChannelsEmpty();
  @override
  List<Object> get props => [];
}
