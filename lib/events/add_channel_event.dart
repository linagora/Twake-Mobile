part of '../blocs/add_channel_bloc.dart';

abstract class AddChannelEvent extends Equatable {
  const AddChannelEvent();
}

class LoadFromCache extends AddChannelEvent {
  @override
  List<Object> get props => [];
}

class Cache extends AddChannelEvent {
  @override
  List<Object> get props => [];
}

class ClearCache extends AddChannelEvent {
  @override
  List<Object> get props => [];
}

class SetFlowStage extends AddChannelEvent {
  final FlowStage stage;

  SetFlowStage(this.stage);

  @override
  List<Object> get props => [];
}