import 'package:msil_library/models/base/base_model.dart';

class QuoteCompanyModel extends BaseModel {
  String? compName;
  String? desc;

  QuoteCompanyModel({this.compName, this.desc});

  QuoteCompanyModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    compName = data['compName'];
    desc = data['desc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['compName'] = compName;
    data['desc'] = desc;
    return data;
  }
}
