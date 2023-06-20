import 'package:msil_library/models/base/base_model.dart';

import '../common/symbols_model.dart';

class RollOverModel extends BaseModel {
  RollOverModel({
    required this.symList,
  });
    List<Symbols> symList=[];

  RollOverModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    symList =
        List.from(data['symList']).map((e) => Symbols.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['symList'] = symList.map((e) => e.toJson()).toList();
    return data;
  }
}
