import 'package:equatable/equatable.dart';
import 'package:twake/models/base_channel.dart';

abstract class ChannelState extends Equatable {
  const ChannelState();
}

class ChannelsLoaded extends ChannelState {
  final List<BaseChannel> channels;
  final String force;
  const ChannelsLoaded({
    this.channels,
    this.force,
  });
  @override
  List<Object> get props => [channels, force];
}

class ChannelPicked extends ChannelsLoaded {
  final BaseChannel selected;
  const ChannelPicked({List<BaseChannel> channels, this.selected})
      : super(channels: channels);

  @override
  List<Object> get props => [selected.id];
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

class ErrorLoadingChannels extends ChannelsLoaded {
  const ErrorLoadingChannels({List<BaseChannel> channels})
      : super(channels: channels);

  @override
  List<Object> get props => [];
}
