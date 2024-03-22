import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/features/app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(InitAppState());
}