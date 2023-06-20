import 'package:msil_library/models/base/base_model.dart';

class SectorModel extends BaseModel {
  String? sctrNme;

  SectorModel({this.sctrNme});

  SectorModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    sctrNme = data['sctrNme'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sctrNme'] = sctrNme;
    return data;
  }
}
