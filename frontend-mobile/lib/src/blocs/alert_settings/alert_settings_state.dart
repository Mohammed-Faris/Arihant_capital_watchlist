part of 'alert_settings_bloc.dart';

abstract class AlertSettingsState extends ScreenState {}

class AlertSettingsInitial extends AlertSettingsState {
  AlertSettingsInitial();
}

class AlertSettingsLoading extends AlertSettingsState {
  AlertSettingsLoading();
}

class AlertSettingsDone extends AlertSettingsState {
  List<String> settingsList;
  List<bool> settingsValue;

  AlertSettingsDone(this.settingsList, this.settingsValue);
}

class AlertSettingsFailure extends AlertSettingsState {
  AlertSettingsFailure();
}
