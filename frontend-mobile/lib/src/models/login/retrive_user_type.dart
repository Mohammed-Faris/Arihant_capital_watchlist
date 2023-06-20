import 'package:msil_library/models/base/base_model.dart';

class RetriveUser extends BaseModel {
  RetriveUser({
    required this.uid,
    required this.uName,
    required this.userType,
  });
  late final String uid;
  late final String uName;
  late final String userType;

  RetriveUser.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    uid = data['uid'];
    uName = data['uName'];
    userType = data['userType'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['uName'] = uName;
    data['userType'] = userType;
    return data;
  }
}
