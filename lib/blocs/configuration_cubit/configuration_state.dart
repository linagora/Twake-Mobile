import 'package:equatable/equatable.dart';

abstract class ConfigurationState extends Equatable {
  const ConfigurationState();
}

class ConfigurationInitial extends ConfigurationState {
  @override
  List<Object> get props => [];
}
