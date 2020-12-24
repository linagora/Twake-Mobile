import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
}

class ProfileLoaded extends ProfileState {
  final String userId;
  final String firstName;
  final String lastName;
  final String thumbnail;

  const ProfileLoaded({
    this.userId,
    this.firstName,
    this.lastName,
    this.thumbnail,
  });
  @override
  // TODO: implement props
  List<Object> get props => [userId];
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
