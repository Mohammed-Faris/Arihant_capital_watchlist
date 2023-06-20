import '../common/symbols_model.dart';
import 'package:msil_library/models/base/base_model.dart';

class QuotePeerModel extends BaseModel {
  List<Symbols>? peerRatioList;

  QuotePeerModel({this.peerRatioList});

  QuotePeerModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    if (data['peerRatioList'] != null) {
      peerRatioList = <Symbols>[];
      data['peerRatioList'].forEach((v) {
        peerRatioList!.add(Symbols.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (peerRatioList != null) {
      data['peerRatioList'] = peerRatioList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
