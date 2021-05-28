import 'package:bloc/bloc.dart';
import 'configuration_state.dart';
import 'package:twake/repositories/configuration_repository.dart';

class ConfigurationCubit extends Cubit<ConfigurationState> {

  final ConfigurationRepository repository;

  ConfigurationCubit(this.repository) : super(ConfigurationInitial());

  void load() {
    emit(ConfigurationLoaded(host: repository.host));
  }

  Future<void> save(String host) async {
    emit(ConfigurationSaving(host: host));
    try {
      repository.host = host;
      await repository.save();
      emit(ConfigurationSaved(host: host));
      emit(ConfigurationLoaded(host: repository.host));
    } on Exception {
      emit(ConfigurationError(message: 'Error during the configuration saving'));
    }
  }
}
