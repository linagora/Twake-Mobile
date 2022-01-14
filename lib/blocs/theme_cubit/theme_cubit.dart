import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:twake/repositories/theme_repository.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  late final ThemeRepository _repository;

  ThemeCubit({ThemeRepository? repository})
      : super(ThemeState(themeStatus: ThemeStatus.init)) {
    if (repository == null) {
      repository = ThemeRepository();
    }
    _repository = repository;

    initTheme();
  }

  void changeTheme({required String theme}) async {
    emit(ThemeState(themeStatus: ThemeStatus.awaiting));
    _repository.getStorage.write('theme', theme);
    Get.changeThemeMode(_repository.getThemeMode(theme: theme));

    emit(ThemeState(theme: theme, themeStatus: ThemeStatus.done));
  }

  void initTheme() async {
    emit(ThemeState(themeStatus: ThemeStatus.awaiting));
    final theme = await _repository.getTheme();

    emit(ThemeState(theme: theme, themeStatus: ThemeStatus.done));
  }
}
