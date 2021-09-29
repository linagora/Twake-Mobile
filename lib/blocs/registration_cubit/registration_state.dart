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
  final bool emailExists;

  const RegistrationFailed({
    required this.email,
    required this.emailExists,
  });

  @override
  List<Object?> get props => [email];
}

class EmailResendSuccess extends RegistrationState {
  const EmailResendSuccess();

  @override
  List<Object?> get props => [];
}

class EmailResendFailed extends RegistrationState {
  const EmailResendFailed();

  @override
  List<Object?> get props => [];
}

class RegistrationAwaiting extends RegistrationState {
  const RegistrationAwaiting();

  @override
  List<Object?> get props => [];
}
