import 'package:msil_library/models/base/base_model.dart';

class QuoteExpiry extends BaseModel {
  List<String>? results;

  QuoteExpiry({this.results});

  QuoteExpiry.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    results = data['results'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['results'] = results;
    return data;
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'results': results,
    };
  }
}
