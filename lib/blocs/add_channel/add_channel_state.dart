part of '../../blocs/add_channel/add_channel_bloc.dart';

abstract class AddChannelState extends Equatable {
  const AddChannelState();
}

class AddChannelInitial extends AddChannelState {
  @override
  List<Object> get props => [];
}

class AddChannelLoading extends AddChannelState {
  @override
  List<Object> get props => [];
}

class AddChannelLoaded extends AddChannelState {
  final InitData initData;

  AddChannelLoaded(this.initData);

  @override
  List<Object> get props => [];
}

class AddChannelCaching extends AddChannelState {
  @override
  List<Object> get props => [];
}

class AddChannelCached extends AddChannelState {
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
  @override
  List<Object> get props => [];
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

