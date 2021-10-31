import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/repositories/language_repository.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  // final LanguageRepository _repository;

  LanguageCubit() : super(LanguageInitial(language: 'en'));

  void swithLanguage() async {
    emit(LanguageNew(language: "es"));
  }
}
