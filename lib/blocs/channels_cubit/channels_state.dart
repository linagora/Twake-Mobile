import 'package:equatable/equatable.dart';
import 'package:twake/models/channel/channel.dart';

abstract class ChannelsState extends Equatable {
  const ChannelsState();
}

class ChannelsInitial extends ChannelsState {
  const ChannelsInitial();

  @override
  List<Object?> get props => [];
}

class ChannelsLoadInProgress extends ChannelsState {
  const ChannelsLoadInProgress();

  @override
  List<Object?> get props => [];
}

class ChannelsLoadedSuccess extends ChannelsState {
  final List<Channel> channels;
  final Channel? selected;
  final int hash;

  const ChannelsLoadedSuccess({
    required this.channels,
    required this.hash,
    this.selected,
  });

  @override
  List<Object?> get props => [hash, selected];
}
