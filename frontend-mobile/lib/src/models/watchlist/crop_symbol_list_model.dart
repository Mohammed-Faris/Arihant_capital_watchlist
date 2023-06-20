import 'package:msil_library/models/base/base_model.dart';

class CorpSymList extends BaseModel {
  List<String>? corpSymList;

  CorpSymList({this.corpSymList});

  CorpSymList.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    corpSymList = data['corpSymList'].cast<String>();
    if (data['corpSymList'] != null) {
      corpSymList = <String>[];
      data['corpSymList'].forEach((v) {
        corpSymList!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['corpSymList'] = corpSymList;
    return data;
  }
}
