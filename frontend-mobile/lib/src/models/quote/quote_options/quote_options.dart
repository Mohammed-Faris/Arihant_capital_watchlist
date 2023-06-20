import '../../common/symbols_model.dart';
import 'package:msil_library/models/base/base_model.dart';

class OptionQuoteModel extends BaseModel {
  OptionsResults? results;

  OptionQuoteModel({this.results});

  OptionQuoteModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    results = data['results'] != null
        ? OptionsResults.fromJson(data['results'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results!.toJson();
    }
    return data;
  }
}

class OptionsResults extends BaseModel {
  List<Symbols>? call;
  List<Symbols>? put;
  List<Symbols>? spot;

  OptionsResults({this.call, this.put});

  OptionsResults.fromJson(Map<String, dynamic> json) {
    if (json['call'] != null) {
      call = <Symbols>[];
      json['call'].forEach((v) {
        call!.add(Symbols.fromJson(v));
      });
    }
    if (json['put'] != null) {
      put = <Symbols>[];
      json['put'].forEach((v) {
        put!.add(Symbols.fromJson(v));
      });
    }
    if (json['spotSym'] != null) {
      spot = <Symbols>[];
      json['spotSym'].forEach((v) {
        spot!.add(Symbols.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (call != null) {
      data['call'] = call!.map((v) => v.toJson()).toList();
    }
    if (put != null) {
      data['put'] = put!.map((v) => v.toJson()).toList();
    }
    if (spot != null) {
      data['spotSym'] = spot!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
