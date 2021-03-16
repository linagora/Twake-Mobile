import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class ConfigurationState extends Equatable {
  final String host;
  const ConfigurationState({@required this.host});
}

class ConfigurationInitial extends ConfigurationState {
  @override
  List<Object> get props => [];
}

class ConfigurationLoaded extends ConfigurationState {
  final String host;

  ConfigurationLoaded({@required this.host});

  @override
  List<Object> get props => [host];
}

class ConfigurationSaving extends ConfigurationState {
  final String host;

  ConfigurationSaving({@required this.host});
  @override
  List<Object> get props => [host];
}

class ConfigurationSaved extends ConfigurationState {
  final String host;

  ConfigurationSaved({@required this.host});

  @override
  List<Object> get props => [host];
}

class ConfigurationError extends ConfigurationState {
  final String message;

  ConfigurationError({@required this.message});

  @override
  List<Object> get props => [message];
}
