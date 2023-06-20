import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_constants.dart';
import '../../constants/storage_constants.dart';
import '../../data/store/app_storage.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitState()) {
    on<ThemeInitEvent>(_handleThemeInitEvent);
    on<ChangeThemeEvent>(_handleChangeThemeEvent);
  }

  void _handleThemeInitEvent(
      ThemeInitEvent event, Emitter<ThemeState> emit) async {
    try {
      final dynamic getTheme = await AppStorage().getData(themeType);
      final String themType = (getTheme ?? AppConstants.lightMode) as String;
      emit(ThemeUpdateState(themType));
    } catch (ex) {
      emit(ThemeUpdateState(AppConstants.lightMode));
    }
  }

  void _handleChangeThemeEvent(
      ChangeThemeEvent event, Emitter<ThemeState> emit) async {
    await AppStorage().setData(themeType, event.themeType);
    emit(ThemeUpdateState(event.themeType));
  }
}
