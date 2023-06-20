part of 'theme_bloc.dart';

abstract class ThemeState {
  final String themeType;
  ThemeState(this.themeType);
}

class ThemeInitState extends ThemeState {
  ThemeInitState() : super(AppConstants.lightMode);
}

class ThemeUpdateState extends ThemeState {
  ThemeUpdateState(String themeType) : super(themeType);
}
