import 'package:msil_library/models/base/base_model.dart';

class PutCallRatioModel extends BaseModel {
  String? expiry;
  List<SymList>? symList;

  PutCallRatioModel({this.expiry, this.symList});

  PutCallRatioModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    expiry = data['expiry'];
    if (data['symList'] != null) {
      symList = <SymList>[];
      data['symList'].forEach((v) {
        symList!.add(SymList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['expiry'] = expiry;
    if (symList != null) {
      data['symList'] = symList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SymList {
  String? dispSym;
  String? callOI;
  String? putVol;
  String? callVol;
  String? volPCR;
  String? putOI;
  String? oiPCR;
  String? baseSym;

  SymList(
      {this.dispSym,
      this.callOI,
      this.putVol,
      this.callVol,
      this.volPCR,
      this.putOI,
      this.oiPCR,
      this.baseSym});

  SymList.fromJson(Map<String, dynamic> json) {
    dispSym = json['dispSym'];
    callOI = json['callOI'];
    putVol = json['putVol'];
    callVol = json['callVol'];
    volPCR = json['volPCR'];
    putOI = json['putOI'];
    oiPCR = json['oiPCR'];
    baseSym = json['baseSym'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dispSym'] = dispSym;
    data['callOI'] = callOI;
    data['putVol'] = putVol;
    data['callVol'] = callVol;
    data['volPCR'] = volPCR;
    data['putOI'] = putOI;
    data['oiPCR'] = oiPCR;
    data['baseSym'] = baseSym;
    return data;
  }
}
