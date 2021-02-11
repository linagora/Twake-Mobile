import 'package:equatable/equatable.dart';
import 'package:twake/repositories/add_channel_repository.dart';

abstract class AddChannelState extends Equatable {
  const AddChannelState();
}

class AddChannelInitial extends AddChannelState {
  @override
  List<Object> get props => [];
}

class Updated extends AddChannelState {
  final AddChannelRepository repository;

  Updated(this.repository);

  @override
  List<Object> get props => [repository];
}

class Creation extends AddChannelState {
  @override
  List<Object> get props => [];
}

class Created extends AddChannelState {
  final String id;
  final ChannelType channelType;

  Created(this.id, this.channelType);

  @override
  List<Object> get props => [id, channelType];
}

class Error extends AddChannelState {
  final String message;

  Error(this.message);

  @override
  List<Object> get props => [message];
}

class FlowTypeSet extends AddChannelState {
  final bool isDirect;

  FlowTypeSet(this.isDirect);

  @override
  List<Object> get props => [isDirect];
}

class StageUpdated extends AddChannelState {
  final FlowStage stage;

  StageUpdated(this.stage);

  @override
  List<Object> get props => [stage];
}
