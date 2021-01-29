part of '../../blocs/add_channel/add_channel_bloc.dart';

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

class Clear extends AddChannelEvent {
  @override
  List<Object> get props => [];
}

class Create extends AddChannelEvent {
  @override
  List<Object> get props => [];
}

class Update extends AddChannelEvent {
  final String name;
  final String description;
  final String groupName;
  final ChannelType type;
  final bool automaticallyAddNew;
  final List<String> participants;

  Update({
    this.name,
    this.description,
    this.groupName,
    this.type,
    this.automaticallyAddNew,
    this.participants,
  });

  @override
  List<Object> get props => [
        name,
        description,
        groupName,
        type,
        automaticallyAddNew,
        participants,
      ];
}

class SetFlowType extends AddChannelEvent {
  final bool isDirect;

  SetFlowType({this.isDirect});

  @override
  List<Object> get props => [isDirect];
}
