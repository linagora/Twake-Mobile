import 'package:equatable/equatable.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/direct.dart';

abstract class ChannelState extends Equatable {
  const ChannelState();
}

class ChannelsLoaded extends ChannelState {
  final List<Channel> channels;

  const ChannelsLoaded({
    this.channels,
  });
  @override
  List<Object> get props => [channels];
}

class ChannelPicked extends ChannelsLoaded {
  final Channel selected;
  const ChannelPicked({List<Channel> channels, this.selected})
      : super(channels: channels);

  @override
  List<Object> get props => [selected.id];
}

class DirectsLoaded extends ChannelState {
  final List<Direct> directs;

  const DirectsLoaded({
    this.directs,
  });
  @override
  List<Object> get props => [directs];
}

class DirectPicked extends DirectsLoaded {
  final Direct selected;
  const DirectPicked({List<Direct> directs, this.selected})
      : super(directs: directs);

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
