part of 'language_cubit.dart';

abstract class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object> get props => [];
}

class LanguageInitial extends LanguageState {
  const LanguageInitial();

  @override
  List<Object> get props => [];
}

class NewLanguage extends LanguageState {
  final String language;

  const NewLanguage({required this.language});

  @override
  List<Object> get props => [];
}

class LanguageAwaiting extends LanguageState {
  const LanguageAwaiting();

  @override
  List<Object> get props => [];
}
