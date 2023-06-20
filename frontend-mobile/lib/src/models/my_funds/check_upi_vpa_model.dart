import 'package:msil_library/models/base/base_model.dart';

class CheckUPIVPAModel extends BaseModel {
  String? msg;

  CheckUPIVPAModel({this.msg});

  CheckUPIVPAModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    msg = data['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['msg'] = msg;
    return data;
  }
}
