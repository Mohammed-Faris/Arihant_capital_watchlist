import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/base_bloc.dart';
import '../common/screen_state.dart';

part 'alert_settings_event.dart';
part 'alert_settings_state.dart';

class AlertSettingsBloc
    extends BaseBloc<AlertSettingsEvent, AlertSettingsState> {
  AlertSettingsBloc() : super(AlertSettingsInitial());
  final List<String> _settingsList = <String>[
    "Email",
    "SMS",
    "Push Notification"
  ];
  List<bool> _settingsValue = <bool>[];

  @override
  Future<void> eventHandlerMethod(
      AlertSettingsEvent event, Emitter<AlertSettingsState> emit) async {
    if (event is FetchAlertSettingsEvent) {
      await _fetchAlertSettings(event, emit);
    } else if (event is UpdateAlertSettingsEvent) {
      await _updateAlertSettings(event, emit);
    }
  }

  @override
  AlertSettingsState getErrorState() {
    return AlertSettingsFailure();
  }

  Future<void> _fetchAlertSettings(
      FetchAlertSettingsEvent event, Emitter<AlertSettingsState> emit) async {
    emit(AlertSettingsLoading());
    _settingsValue = List.generate(_settingsList.length, (index) => false);
    emit(AlertSettingsDone(_settingsList, _settingsValue));
  }

  Future<void> _updateAlertSettings(
      UpdateAlertSettingsEvent event, Emitter<AlertSettingsState> emit) async {
    if (event.index != -1) {
      emit(AlertSettingsLoading());
      bool val = _settingsValue[event.index];
      _settingsValue[event.index] = !val;
      emit(AlertSettingsDone(_settingsList, _settingsValue));
    }
  }
}
