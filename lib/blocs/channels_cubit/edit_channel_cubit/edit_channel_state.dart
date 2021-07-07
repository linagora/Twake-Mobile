import 'package:equatable/equatable.dart';

abstract class EditChannelState with EquatableMixin {
  final bool validToEditChannel;
  final bool showEmoijKeyboard;
  final String emoijIcon;

  const EditChannelState({
    this.validToEditChannel = false,
    this.showEmoijKeyboard = false,
    this.emoijIcon = '',
  });
}

class EditChannelInitial extends EditChannelState {
  const EditChannelInitial();

  @override
  List<Object?> get props => [];
}

class EditChannelValidation extends EditChannelState {
  const EditChannelValidation(
      {bool validToEditChannel = false,
      bool showEmoijKeyboard = false,
      String emoijIcon = ''})
      : super(
            validToEditChannel: validToEditChannel,
            showEmoijKeyboard: showEmoijKeyboard,
            emoijIcon: emoijIcon);

  @override
  List<Object?> get props => [validToEditChannel, showEmoijKeyboard, emoijIcon];
}

class EditChannelInProgress extends EditChannelState {
  const EditChannelInProgress({String emoijIcon = ''})
      : super(emoijIcon: emoijIcon);

  @override
  List<Object?> get props => [];
}

class EditChannelSuccess extends EditChannelState {
  const EditChannelSuccess();

  @override
  List<Object?> get props => [];
}

class EditChannelFailure extends EditChannelState {
  const EditChannelFailure();

  @override
  List<Object?> get props => [];
}
