import 'package:equatable/equatable.dart';
import 'package:twake/models/base_channel.dart';

abstract class ChannelState extends Equatable {
  const ChannelState();
}

class ChannelsLoaded extends ChannelState {
  final List<BaseChannel> channels;
  const ChannelsLoaded({
    this.channels,
  });
  @override
  List<Object> get props => [channels];
}

class ChannelPicked extends ChannelsLoaded {
  final BaseChannel selected;
  const ChannelPicked({List<BaseChannel> channels, this.selected})
      : super(channels: channels);

  @override
  List<Object> get props => [selected.id];
}

// class DirectsLoaded extends ChannelState {
// final List<Direct> channels;
// const DirectsLoaded({
// this.channels,
// });
// @override
// List<Object> get props => [channels];
// }
//
// class DirectPicked extends DirectsLoaded {
// final Direct selected;
// const DirectPicked({List<Direct> directs, this.selected})
// : super(channels: directs);
//
// @override
// List<Object> get props => [selected.id];
// }
//
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
