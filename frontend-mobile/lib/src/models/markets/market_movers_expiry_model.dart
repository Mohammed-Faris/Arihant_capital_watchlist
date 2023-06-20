import 'package:msil_library/models/base/base_model.dart';

class MarketMoversExpiryModel extends BaseModel {
  List<String>? expList;

  MarketMoversExpiryModel({this.expList});

  MarketMoversExpiryModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    expList = data['expList'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['expList'] = expList;
    return data;
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'expList': expList,
    };
  }
}
