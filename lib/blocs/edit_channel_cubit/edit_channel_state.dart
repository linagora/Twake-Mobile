import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:twake/repositories/channel_repository.dart';

abstract class EditChannelState extends Equatable {
  const EditChannelState();
}

class EditChannelInitial extends EditChannelState {
  @override
  List<Object> get props => [];
}

class EditChannelLoaded extends EditChannelState {
  @override
  List<Object> get props => [];
}

class EditChannelSaved extends EditChannelState {
  @override
  List<Object> get props => [];
}

class EditChannelUpdated extends EditChannelState {
  final ChannelRepository repository;

  EditChannelUpdated(this.repository);

  @override
  List<Object> get props => [repository];
}

class EditChannelError extends EditChannelState {
  final String message;

  EditChannelError(this.message);

  @override
  List<Object> get props => [message];
}

class EditChannelStageUpdated extends EditChannelState {
  final EditFlowStage stage;

  EditChannelStageUpdated(this.stage);

  @override
  List<Object> get props => [stage];
}