
import 'package:equatable/equatable.dart';

abstract class AddChannelState extends Equatable {
  const AddChannelState();
}

class AddChannelInitial extends AddChannelState {
  const AddChannelInitial();

  @override
  List<Object?> get props => [];
}

class AddChannelValid extends AddChannelState{
  const AddChannelValid();

  @override
  List<Object?> get props => [];

}

class AddChannelInvalid extends AddChannelState{
  const AddChannelInvalid();

  @override
  List<Object?> get props => [];
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
