part of 'notification_bloc.dart';

abstract class NotificationEvent {}

class GetAllNotificationEvent extends NotificationEvent {}

class GetUnreadNotificationCountEvent extends NotificationEvent {}

class UpdateNotificationStatusEvent extends NotificationEvent {
  List<String> notificationList;
  UpdateNotificationStatusEvent(
    this.notificationList,
  );
}
