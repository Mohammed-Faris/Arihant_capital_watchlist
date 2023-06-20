import '../../common/symbols_model.dart';
import 'package:msil_library/models/base/base_model.dart';

class QuoteFuturesModel extends BaseModel {
  List<Symbols>? results;

  QuoteFuturesModel({this.results});

  QuoteFuturesModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    if (data['results'] != null) {
      results = <Symbols>[];
      data['results'].forEach((v) {
        results!.add(Symbols.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
