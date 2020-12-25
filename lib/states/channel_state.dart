import 'package:equatable/equatable.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/direct.dart';

abstract class ChannelState extends Equatable {
  const ChannelState();
}

class ChannelsLoaded extends ChannelState {
  final List<Channel> channels;
  final Channel selected;

  const ChannelsLoaded({
    this.channels,
    this.selected,
  });
  @override
  List<Object> get props => [channels];
}

class DirectsLoaded extends ChannelState {
  final List<Direct> directs;
  final Direct selected;

  const DirectsLoaded({
    this.directs,
    this.selected,
  });
  @override
  List<Object> get props => [directs];
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
