import 'package:msil_library/models/base/base_model.dart';

class InitModel extends BaseModel {
  late String appID;

  InitModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    appID = data['appID'] as String;
  }
}
