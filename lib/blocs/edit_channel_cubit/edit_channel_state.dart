import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class EditChannelState extends Equatable {
  const EditChannelState();
}

class EditChannelInitial extends EditChannelState {
  @override
  List<Object> get props => [];
}

class EditChannelLoading extends EditChannelState {
  @override
  List<Object> get props => [];
}

class EditChannelLoaded extends EditChannelState {
  @override
  List<Object> get props => [];
}

class EditChannelUpdate extends EditChannelState {
  @override
  List<Object> get props => [];
}

class EditChannelError extends EditChannelState {
  final String message;

  EditChannelError(this.message);

  @override
  List<Object> get props => [message];
}

class EditChannelStageUpdated extends EditChannelState {
  // final EditFlowStage stage;

  // EditChannelStageUpdated(this.stage);

  @override
  List<Object> get props => [];
}

class EditChannelMembersUpdated extends EditChannelState {
  final String workspaceId;
  final List<String> members;

  EditChannelMembersUpdated({
    @required this.workspaceId,
    @required this.members,
  });

  @override
  List<Object> get props => [workspaceId, members];
}
