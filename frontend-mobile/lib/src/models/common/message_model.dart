import 'package:msil_library/models/base/base_model.dart';

class MessageModel extends BaseModel {
  String? message;
  MessageModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    message = data['infomsg'];
  }
}
