import 'package:msil_library/models/base/base_model.dart';

class CoTriggerPriceRangeModel extends BaseModel {
  String? coverPerc;
  String? trigPriceRange;
  String? coFlag;
  String? precision;
  String? ltp;

  CoTriggerPriceRangeModel(
      {this.coverPerc,
      this.trigPriceRange,
      this.coFlag,
      this.precision,
      this.ltp});

  CoTriggerPriceRangeModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    coverPerc = data['coverPerc'];
    trigPriceRange = data['trigPriceRange'];
    coFlag = data['coFlag'];
    precision = data['precision'];
    ltp = data['ltp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['coverPerc'] = coverPerc;
    data['trigPriceRange'] = trigPriceRange;
    data['coFlag'] = coFlag;
    data['precision'] = precision;
    data['ltp'] = ltp;
    return data;
  }
}
