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

class UpdateProfile extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String language;
  final String oldPassword;
  final String newPassword;

  const UpdateProfile({
    this.firstName,
    this.lastName,
    this.language,
    this.oldPassword,
    this.newPassword,
  });

  @override
  List<Object> get props => [
        firstName,
        lastName,
        language,
        oldPassword,
        newPassword,
      ];
}
