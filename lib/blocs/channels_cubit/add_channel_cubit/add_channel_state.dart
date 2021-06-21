
import 'package:equatable/equatable.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';

abstract class AddChannelState extends Equatable {
  final bool validToCreateChannel;
  final bool showEmoijKeyboard;
  final String emoijIcon;
  final ChannelVisibility channelVisibility;

  const AddChannelState(
      {this.validToCreateChannel = false,
      this.showEmoijKeyboard = false,
      this.emoijIcon = '',
      this.channelVisibility = ChannelVisibility.public});
}

class AddChannelInitial extends AddChannelState {
  const AddChannelInitial();

  @override
  List<Object?> get props => [];
}

class AddChannelValidation extends AddChannelState {

  const AddChannelValidation(
      {bool validToCreateChannel = false,
      bool showEmoijKeyboard = false,
      String emoijIcon = '',
      ChannelVisibility channelVisibility = ChannelVisibility.public})
      : super(
            validToCreateChannel: validToCreateChannel,
            showEmoijKeyboard: showEmoijKeyboard,
            emoijIcon: emoijIcon,
            channelVisibility: channelVisibility);

  @override
  List<Object?> get props =>
      [validToCreateChannel, showEmoijKeyboard, emoijIcon, channelVisibility];
}

class AddChannelInProgress extends AddChannelState{

  const AddChannelInProgress(
      {String emoijIcon = '',
      ChannelVisibility channelVisibility = ChannelVisibility.public})
      : super(emoijIcon: emoijIcon, channelVisibility: channelVisibility);

  @override
  List<Object?> get props => [];
}

class AddChannelSuccess extends AddChannelState{
  const AddChannelSuccess();

  @override
  List<Object?> get props => [];
}

class AddChannelFailure extends AddChannelState{
  const AddChannelFailure();

  @override
  List<Object?> get props => [];
}
