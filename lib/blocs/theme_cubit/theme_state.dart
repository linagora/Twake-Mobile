part of 'theme_cubit.dart';

enum ThemeStatus { init, awaiting, done }

class ThemeState extends Equatable {
  final String theme;
  final ThemeStatus themeStatus;
  const ThemeState({this.theme = 'system', required this.themeStatus});

  ThemeState copyWith({String? newtheme, ThemeStatus? themeStatus}) {
    return ThemeState(
        theme: newtheme ?? this.theme,
        themeStatus: themeStatus ?? this.themeStatus);
  }

  @override
  List<Object> get props => [theme, themeStatus];
}
