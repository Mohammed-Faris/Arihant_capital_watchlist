import 'package:msil_library/models/base/base_model.dart';

class MarketStatusModel extends BaseModel {
  bool? isClose;
  bool? isOpen;
  bool? isPreOpen;
  bool? isAmo;
  MarketStatusModel({this.isClose, this.isOpen, this.isPreOpen});

  MarketStatusModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    isClose = data['isClose'];
    isOpen = data['isOpen'];
    isPreOpen = data['isPreOpen'];
    isAmo = data['isAmo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isClose'] = isClose;
    data['isOpen'] = isOpen;
    data['isPreOpen'] = isPreOpen;
    data['isAmo'] = isAmo;
    return data;
  }
}
