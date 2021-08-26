import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/registration_cubit/registration_state.dart';

export 'registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit() : super(RegistrationInitial());
}
