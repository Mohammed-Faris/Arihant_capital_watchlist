import 'package:msil_library/models/base/base_model.dart';

class NsdlAckModel extends BaseModel {
  String? msg;
  String? status;

  NsdlAckModel({this.msg, this.status});

  NsdlAckModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    msg = data['msg'];
    status = data['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    data['status'] = status;
    return data;
  }
}
