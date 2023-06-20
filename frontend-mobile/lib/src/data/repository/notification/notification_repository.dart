import '../../api_services_urls.dart';
import '../../../models/notification/global_user_notification_model.dart';
import '../../../models/notification/unread_user_notification_count_model.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_model.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/config/httpclient_config.dart';

class NotificationRepository {
  Future<GlobalAndUserNotificationsModel> fetchAllNotifications(
      BaseRequest request) async {
    final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
        url: ApiServicesUrls.getAllNotifications,
        data: request.getRequest(),
        isEncryption: HttpClientConfig.encryptionEnabled);
    return GlobalAndUserNotificationsModel.fromJson(resp);
  }

  Future<UnreadUserNotificationsCountModel> fetchUnreadUserNotificationCount(
      BaseRequest request) async {
    final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
        url: ApiServicesUrls.getUnreadUserNotificationCount,
        data: request.getRequest(),
        isEncryption: HttpClientConfig.encryptionEnabled);
    return UnreadUserNotificationsCountModel.fromJson(resp);
  }

  Future<BaseModel> updateNotificationStatus(BaseRequest request) async {
    final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
        url: ApiServicesUrls.updateNotificationStatus,
        data: request.getRequest(),
        isEncryption: HttpClientConfig.encryptionEnabled);
    return BaseModel.fromJSON(resp);
  }
}
