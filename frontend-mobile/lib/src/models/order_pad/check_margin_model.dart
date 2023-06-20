import 'package:msil_library/models/base/base_model.dart';

class CheckMarginModel extends BaseModel {
  String? availableCash;
  String? marginUsed;
  String? availMargin;
  String? orderMargin;

  CheckMarginModel({
    this.availableCash,
    this.marginUsed,
    this.availMargin,
    this.orderMargin,
  });

  CheckMarginModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    availableCash = data['availableCash'];
    marginUsed = data['marginUsed'];
    availMargin = data['AvailMargin'];
    orderMargin = data['orderMargin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['availableCash'] = availableCash;
    data['marginUsed'] = marginUsed;
    data['AvailMargin'] = availMargin;
    data['orderMargin'] = orderMargin;
    return data;
  }
}
