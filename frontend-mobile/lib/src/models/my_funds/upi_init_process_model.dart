import 'package:msil_library/models/base/base_model.dart';

class UPIInitProcessModel extends BaseModel {
  String? msg;
  String? transID;

  UPIInitProcessModel({this.msg, this.transID});

  UPIInitProcessModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    msg = data['msg'];
    transID = data['transID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['msg'] = msg;
    data['transID'] = transID;
    return data;
  }
}
