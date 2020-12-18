import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
  @override
  List<Object> get props => [];
}

class ClearProfile extends ProfileEvent {
  const ClearProfile();
  @override
  List<Object> get props => [];
}
