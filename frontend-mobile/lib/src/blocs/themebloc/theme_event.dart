part of 'theme_bloc.dart';

abstract class ThemeEvent {}

class ThemeInitEvent extends ThemeEvent {}

class ChangeThemeEvent extends ThemeEvent {
  final String themeType;
  ChangeThemeEvent({required this.themeType});
}
