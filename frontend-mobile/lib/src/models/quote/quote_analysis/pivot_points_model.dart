import 'package:msil_library/models/base/base_model.dart';

class PivotPoints extends BaseModel {
  List<String>? keys;
  Map<String, dynamic>? values;

  PivotPoints({this.keys, this.values});

  PivotPoints.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    keys = data['keys'].cast<String>();
    values = data['values'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['keys'] = keys;
    if (values != null) {
      data['values'] = values;
    }
    return data;
  }
}
