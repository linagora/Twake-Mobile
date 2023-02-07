import 'package:equatable/equatable.dart';
import 'package:model/channel/channels_type.dart';
import 'package:twake/models/channel/channel.dart';

abstract class NavigationInfo with EquatableMixin {}

class CommonNavigationInfo extends NavigationInfo {
  @override
  List<Object?> get props => [];
}

class ChatNavigationInfo extends NavigationInfo {
  final Channel? currentChannel;
  final ChannelsType? currentChannelType;

  ChatNavigationInfo({
    this.currentChannel,
    this.currentChannelType
  });

  @override
  List<Object?> get props => [];
}