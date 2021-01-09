import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class ReloadProfile extends ProfileEvent {
  const ReloadProfile();
  @override
  List<Object> get props => [];
}

class ClearProfile extends ProfileEvent {
  const ClearProfile();
  @override
  List<Object> get props => [];
}
