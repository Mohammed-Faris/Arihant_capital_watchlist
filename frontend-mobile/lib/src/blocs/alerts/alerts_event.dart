part of 'alerts_bloc.dart';

abstract class AlertsEvent {}

class FetchPendingAlertsEvent extends AlertsEvent {
  FetchPendingAlertsEvent();
}

class FetchTriggeredAlertsEvent extends AlertsEvent {
  FetchTriggeredAlertsEvent();
}

class CreateAlertAlertsEvent extends AlertsEvent {
  CreateAlertAlertsEvent(
      this.symbols, this.criteria, this.fromStockQuote, this.alertName);
  final Symbols symbols;
  final bool fromStockQuote;
  final AlertCriteria criteria;
  final String alertName;
}

class AlertsAddStreamEvent extends AlertsEvent {
  AlertsAddStreamEvent();
}

class ModifyAlertAlertsEvent extends AlertsEvent {
  ModifyAlertAlertsEvent(this.symbols, this.criteria, this.alertId, this.alertName);
  final Symbols symbols;
  final String alertId;
  final String alertName;

  final AlertCriteria criteria;
}

class AlertsStreamingResponseEvent extends AlertsEvent {
  ResponseData data;
  AlertsStreamingResponseEvent(this.data);
}

class DeleteAlertEvent extends AlertsEvent {
  DeleteAlertEvent(this.alertId);
  final String alertId;
}

class DisableAlertAlertsEvent extends AlertsEvent {
  DisableAlertAlertsEvent(this.alertId);
  final int alertId;
}
