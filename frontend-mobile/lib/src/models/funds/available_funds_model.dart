import 'package:msil_library/models/base/base_model.dart';

class AvailableFundsModel extends BaseModel {
  String? availableFunds;

  AvailableFundsModel({this.availableFunds});

  AvailableFundsModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    availableFunds = data['availableFunds'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['availableFunds'] = availableFunds;
    return data;
  }
}
