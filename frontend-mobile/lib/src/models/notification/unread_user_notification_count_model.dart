import 'package:msil_library/models/base/base_model.dart';

class UnreadUserNotificationsCountModel extends BaseModel {
  String? unreadCount;

  UnreadUserNotificationsCountModel({this.unreadCount});

  UnreadUserNotificationsCountModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    unreadCount = data['unreadCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['unreadCount'] = unreadCount;
    return data;
  }
}
