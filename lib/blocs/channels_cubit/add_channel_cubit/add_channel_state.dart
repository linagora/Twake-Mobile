import 'package:equatable/equatable.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/models/account/account.dart';

abstract class AddChannelState extends Equatable {
  final bool validToCreateChannel;
  final bool showEmoijKeyboard;
  final String emoijIcon;
  final ChannelVisibility channelVisibility;
  final List<Account> selectedMembers;

  const AddChannelState({
    this.validToCreateChannel = false,
    this.showEmoijKeyboard = false,
    this.emoijIcon = '',
    this.channelVisibility = ChannelVisibility.public,
    this.selectedMembers = const [],
  });
}

class AddChannelInitial extends AddChannelState {
  const AddChannelInitial();

  @override
  List<Object?> get props => [];
}

class AddChannelValidation extends AddChannelState {
  const AddChannelValidation({
    bool validToCreateChannel = false,
    bool showEmoijKeyboard = false,
    String emoijIcon = '',
    ChannelVisibility channelVisibility = ChannelVisibility.public,
    List<Account> selectedMembers = const [],
  }) : super(
          validToCreateChannel: validToCreateChannel,
          showEmoijKeyboard: showEmoijKeyboard,
          emoijIcon: emoijIcon,
          channelVisibility: channelVisibility,
          selectedMembers: selectedMembers,
        );

  @override
  List<Object?> get props => [
        validToCreateChannel,
        showEmoijKeyboard,
        emoijIcon,
        channelVisibility,
        selectedMembers,
      ];
}

class AddChannelInProgress extends AddChannelState {
  const AddChannelInProgress({
    String emoijIcon = '',
    ChannelVisibility channelVisibility = ChannelVisibility.public,
    List<Account> selectedMembers = const [],
  }) : super(
          emoijIcon: emoijIcon,
          channelVisibility: channelVisibility,
          selectedMembers: selectedMembers,
        );

  @override
  List<Object?> get props => [];
}

class AddChannelSuccess extends AddChannelState {
  const AddChannelSuccess();

  @override
  List<Object?> get props => [];
}

class AddChannelFailure extends AddChannelState {
  const AddChannelFailure();

  @override
  List<Object?> get props => [];
}
