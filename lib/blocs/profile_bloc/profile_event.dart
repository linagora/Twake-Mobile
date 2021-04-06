import 'package:equatable/equatable.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class ReloadProfile extends ProfileEvent {
  const ReloadProfile();

  @override
  List<Object> get props => [];
}

class UpdateBadges extends ProfileEvent {
  const UpdateBadges();

  @override
  List<Object> get props => [];
}

class ClearProfile extends ProfileEvent {
  const ClearProfile();

  @override
  List<Object> get props => [];
}

class UpdateProfileStage extends ProfileEvent {
  const UpdateProfileStage();

  @override
  List<Object> get props => [];
}

class SetProfileFlowStage extends ProfileEvent {
  final ProfileFlowStage stage;

  const SetProfileFlowStage(this.stage);

  @override
  List<Object> get props => [stage];
}
