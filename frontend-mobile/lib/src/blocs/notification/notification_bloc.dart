import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_model.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../data/repository/notification/notification_repository.dart';
import '../../models/notification/global_user_notification_model.dart';
import '../../models/notification/unread_user_notification_count_model.dart';
import '../common/base_bloc.dart';
import '../common/screen_state.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends BaseBloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial());

  @override
  Future<void> eventHandlerMethod(
      NotificationEvent event, Emitter<NotificationState> emit) async {
    if (event is GetAllNotificationEvent) {
      await _handleGetAllGlobalNotificationEvent(event, emit);
    } else if (event is GetUnreadNotificationCountEvent) {
      await _handleGetUnreadNotificationCountEvent(event, emit);
    } else if (event is UpdateNotificationStatusEvent) {
      await _handleUpdateNotificationStatusEvent(event, emit);
    }
  }

  Future<void> _handleGetAllGlobalNotificationEvent(
    GetAllNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationProgressState());
    try {
      final GlobalAndUserNotificationsModel response =
          await NotificationRepository().fetchAllNotifications(BaseRequest());

      if (response.isSuccess()) emit(NotificationDoneState(response));
    } on ServiceException catch (ex) {
      emit(NotificationServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(NotificationFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleGetUnreadNotificationCountEvent(
    GetUnreadNotificationCountEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final UnreadUserNotificationsCountModel response =
          await NotificationRepository()
              .fetchUnreadUserNotificationCount(BaseRequest());

      if (response.isSuccess()) {
        emit(
          UnreadUserNotificationCountState(response.unreadCount!),
        );
      }
    } on ServiceException catch (ex) {
      emit(NotificationServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(NotificationFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleUpdateNotificationStatusEvent(
    UpdateNotificationStatusEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('notificationList', event.notificationList);
      final BaseModel response =
          await NotificationRepository().updateNotificationStatus(request);

      if (response.isSuccess()) emit(UpdateNotificationStatusState());
    } on ServiceException catch (ex) {
      emit(NotificationServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(NotificationFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  @override
  NotificationState getErrorState() {
    return NotificationErrorState();
  }
}
