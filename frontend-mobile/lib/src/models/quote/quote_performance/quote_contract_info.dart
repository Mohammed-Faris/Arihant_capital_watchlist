import 'package:msil_library/models/base/base_model.dart';

class QuoteContractInfo extends BaseModel {
  String? varMargin;
  String? maxOrdSize;
  String? faceValue;
  String? series;

  QuoteContractInfo({this.varMargin, this.maxOrdSize, this.faceValue});

  QuoteContractInfo.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    varMargin = data['varMargin'];
    maxOrdSize = data['maxOrdSize'];
    faceValue = data['faceValue'];
    series = data['series'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['varMargin'] = varMargin;
    data['maxOrdSize'] = maxOrdSize;
    data['faceValue'] = faceValue;
    data['series'] = series;

    return data;
  }
}
