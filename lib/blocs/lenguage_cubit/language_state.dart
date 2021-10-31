part of 'language_cubit.dart';

abstract class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object> get props => [];
}

class LanguageInitial extends LanguageState {
  final String language;

  const LanguageInitial({required this.language});


  @override
  List<Object> get props => [];
}

class LanguageNew extends LanguageState {
  final String language;

  const LanguageNew({required this.language});


  @override
  List<Object> get props => [];
}
