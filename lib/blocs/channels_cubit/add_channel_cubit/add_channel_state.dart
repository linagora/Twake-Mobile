
import 'package:equatable/equatable.dart';

abstract class AddChannelState extends Equatable {
  final bool validToCreateChannel;
  final bool showEmoijKeyboard;
  final String emoijIcon;

  const AddChannelState({this.validToCreateChannel = false, this.showEmoijKeyboard = false, this.emoijIcon = ''});
}

class AddChannelInitial extends AddChannelState {
  const AddChannelInitial();

  @override
  List<Object?> get props => [];
}

class AddChannelValidation extends AddChannelState {

  const AddChannelValidation(
      {
        bool validToCreateChannel = false,
        bool showEmoijKeyboard = false,
        String emoijIcon = ''
      })
      : super(validToCreateChannel: validToCreateChannel, showEmoijKeyboard: showEmoijKeyboard, emoijIcon: emoijIcon);

  @override
  List<Object?> get props => [validToCreateChannel, showEmoijKeyboard, emoijIcon];
}

class AddChannelInProgress extends AddChannelState{
  const AddChannelInProgress();

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
