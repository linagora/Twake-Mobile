import 'package:equatable/equatable.dart';

abstract class RegistrationState extends Equatable {
  const RegistrationState();
}

class RegistrationInitial extends RegistrationState {
  const RegistrationInitial();

  @override
  List<Object?> get props => [];
}

class RegistrationReady extends RegistrationState {
  final String secretToken;
  final String code;

  const RegistrationReady({required this.secretToken, required this.code});

  @override
  List<Object?> get props => [secretToken];
}

class RegistrationSuccess extends RegistrationState {
  final String email;

  const RegistrationSuccess({required this.email});

  @override
  List<Object?> get props => [email];
}

class RegistrationFailed extends RegistrationState {
  final String email;

  const RegistrationFailed({required this.email});

  @override
  List<Object?> get props => [email];
}