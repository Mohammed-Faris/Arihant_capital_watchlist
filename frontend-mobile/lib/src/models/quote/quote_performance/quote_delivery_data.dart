import 'package:msil_library/models/base/base_model.dart';

class QuoteDeliveryData extends BaseModel {
  String? deliveryPerChng;

  QuoteDeliveryData({this.deliveryPerChng});

  QuoteDeliveryData.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    deliveryPerChng = data['deliveryPerChng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deliveryPerChng'] = deliveryPerChng;
    return data;
  }
}
