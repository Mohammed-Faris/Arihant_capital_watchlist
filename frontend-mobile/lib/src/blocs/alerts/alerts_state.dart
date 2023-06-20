part of 'alerts_bloc.dart';

abstract class AlertsState extends ScreenState {}

class AlertsLoading extends AlertsState {
  AlertsLoading();
}

class AlertSymStreamState extends AlertsState {
  Map<dynamic, dynamic> streamDetails;
  AlertSymStreamState(this.streamDetails);
}

class AlertsAddStreamDone extends AlertsState {
  AlertsAddStreamDone();
}

class AlertsChange extends AlertsState {
  AlertsChange();
}

class AlertsCreateOrModifyDone extends AlertsState {
  AlertsCreateOrModifyDone(this.msg);
  final String msg;
}

class PendingAlertsDone extends AlertsState {
  PendingAlertsDone();
  AlertModel alerts = AlertModel(alertList: []);
}

class TriggeredAlertsDone extends AlertsState {
  TriggeredAlertsDone();
  AlertModel alerts = AlertModel(alertList: []);
}

class AlertsError extends AlertsState {
  AlertsError();
}

class AlertsInitial extends AlertsState {
  AlertsInitial();
}
