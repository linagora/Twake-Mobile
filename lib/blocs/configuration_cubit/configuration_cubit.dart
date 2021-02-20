import 'package:bloc/bloc.dart';
import 'package:twake/repositories/configuration_repository.dart';
import 'configuration_state.dart';

class ConfigurationCubit extends Cubit<ConfigurationState> {
  final ConfigurationRepository repository;

  ConfigurationCubit(this.repository) : super(ConfigurationInitial());
}
