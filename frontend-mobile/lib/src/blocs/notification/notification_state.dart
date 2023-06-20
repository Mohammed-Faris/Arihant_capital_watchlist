part of 'notification_bloc.dart';

abstract class NotificationState extends ScreenState {}

class NotificationInitial extends NotificationState {}

class NotificationProgressState extends NotificationState {}

class NotificationDoneState extends NotificationState {
  GlobalAndUserNotificationsModel globalAndUserNotificationsModel;
  NotificationDoneState(this.globalAndUserNotificationsModel);
}

class NotificationFailedState extends NotificationState {}

class NotificationServiceExceptionState extends NotificationState {}

class NotificationErrorState extends NotificationState {}

class UnreadUserNotificationCountState extends NotificationState {
  String unreadCount;

  UnreadUserNotificationCountState(this.unreadCount);
}

class UpdateNotificationStatusState extends NotificationState {}
