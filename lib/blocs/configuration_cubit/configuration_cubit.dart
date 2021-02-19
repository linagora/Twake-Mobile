import 'package:bloc/bloc.dart';
import 'configuration_state.dart';

class ConfigurationCubit extends Cubit<ConfigurationState> {
  ConfigurationCubit() : super(ConfigurationInitial());
}
