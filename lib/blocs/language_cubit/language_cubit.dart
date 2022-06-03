import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:twake/repositories/language_repository.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  late final LanguageRepository _repository;

  LanguageCubit({LanguageRepository? repository}) : super(LanguageInitial()) {
    if (repository == null) {
      repository = LanguageRepository();
    }
    _repository = repository;

    initLanguage();
  }

  void changeLanguage({required String language}) async {
    emit(LanguageAwaiting());

    await _repository.updateLanguageDB(language: language);
    final newLanguage = await _repository.getLanguage();

    Get.updateLocale(Locale("$language"));

    emit(NewLanguage(language: newLanguage));
  }

  void initLanguage() async {
    emit(LanguageAwaiting());

    final language = await _repository.getLanguage();

    emit(NewLanguage(language: language));
  }
}
