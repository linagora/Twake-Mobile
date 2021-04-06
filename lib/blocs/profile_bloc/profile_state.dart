import 'package:equatable/equatable.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
}

class ProfileLoaded extends ProfileState {
  final String userId;
  final String firstName;
  final String lastName;
  final String thumbnail;
  final Map<String, dynamic> badges;

  const ProfileLoaded({
    this.userId,
    this.firstName,
    this.lastName,
    this.thumbnail,
    this.badges = const {},
  });

  @override
  List<Object> get props => [userId, badges];

  int getBadgeForCompany(String id) {
    if (badges['companies'] == null) return 0;
    final items = badges['companies'] as Map<String, dynamic>;
    return items[id] ?? 0;
  }

  int getBadgeForWorkspace(String id) {
    if (badges['workspaces'] == null) return 0;
    final items = badges['workspaces'] as Map<String, dynamic>;
    return items[id] ?? 0;
  }

  int getBadgeForChannel(String id) {
    if (badges['channels'] == null) return 0;
    final items = badges['channels'] as Map<String, dynamic>;
    return items[id] ?? 0;
  }
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();

  @override
  List<Object> get props => [];
}

class ProfileEmpty extends ProfileState {
  const ProfileEmpty();

  @override
  List<Object> get props => [];
}

class ProfileFlowStageUpdated extends ProfileState {
  final ProfileFlowStage stage;

  const ProfileFlowStageUpdated(this.stage);

  @override
  List<Object> get props => [stage];
}
