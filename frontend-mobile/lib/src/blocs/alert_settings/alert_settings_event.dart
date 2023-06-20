part of 'alert_settings_bloc.dart';

abstract class AlertSettingsEvent {}

class FetchAlertSettingsEvent extends AlertSettingsEvent {
  FetchAlertSettingsEvent();
}

class UpdateAlertSettingsEvent extends AlertSettingsEvent {
  int index = -1;
  UpdateAlertSettingsEvent(this.index);
}
