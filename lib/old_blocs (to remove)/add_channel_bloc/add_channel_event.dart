import 'package:equatable/equatable.dart';
import 'package:twake/repositories/add_channel_repository.dart';

abstract class AddChannelEvent extends Equatable {
  const AddChannelEvent();
}

class Clear extends AddChannelEvent {
  @override
  List<Object> get props => [];
}

class Create extends AddChannelEvent {
  @override
  List<Object> get props => [];
}

class CreateDirect extends AddChannelEvent {
  @override
  List<Object> get props => [];
}

class Update extends AddChannelEvent {
  final String? icon;
  final String? name;
  final String? description;
  final String? groupName;
  final ChannelType? type;
  final bool? automaticallyAddNew;
  final List<String?>? participants;

  Update({
    this.icon,
    this.name,
    this.description,
    this.groupName,
    this.type,
    this.automaticallyAddNew,
    this.participants,
  });

  @override
  List<Object?> get props => [
        icon,
        name,
        description,
        groupName,
        type,
        automaticallyAddNew,
        participants,
      ];
}

class UpdateDirect extends AddChannelEvent {
  final String? member;

  UpdateDirect({this.member});

  @override
  List<Object?> get props => [member];
}

class SetFlowType extends AddChannelEvent {
  final bool? isDirect;

  SetFlowType({this.isDirect});

  @override
  List<Object?> get props => [isDirect];
}

class SetFlowStage extends AddChannelEvent {
  final FlowStage stage;

  SetFlowStage(this.stage);

  @override
  List<Object> get props => [stage];
}
