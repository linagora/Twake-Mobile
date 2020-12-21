import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
}

class ProfileLoaded extends ProfileState {
  final String userId;
  final String firstname;
  final String lastname;
  final String thumbnail;

  const ProfileLoaded({
    this.userId,
    this.firstname,
    this.lastname,
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
