import 'package:equatable/equatable.dart';
import 'package:twake/repositories/edit_channel_repository.dart';

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
  final String companyId;
  final String workspaceId;
  final String channelId;
  final String icon;
  final String name;
  final String description;
  final bool def;

  EditChannelSaved({
    this.companyId,
    this.workspaceId,
    this.channelId,
    this.icon,
    this.name,
    this.description,
    this.def,
  });

  @override
  List<Object> get props => [
        this.companyId,
        this.workspaceId,
        this.channelId,
        this.icon,
        this.name,
        this.description,
        this.def,
      ];
}

class EditChannelUpdated extends EditChannelState {
  final EditChannelRepository repository;

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

class EditChannelDeleted extends EditChannelState {
  @override
  List<Object> get props => [];
}
