import '../common/symbols_model.dart';
import 'package:msil_library/models/base/base_model.dart';

class SearchSymbolsModel extends BaseModel {
  List<Symbols> symbols = [];

  SearchSymbolsModel();

  List<Symbols>? getSymbols() {
    return symbols;
  }

  SearchSymbolsModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    if (data['symbols'] != null) {
      symbols = <Symbols>[];
      data['symbols'].forEach(
        (dynamic v) {
          symbols.add(Symbols.fromJson(v));
        },
      );
    }
  }

  SearchSymbolsModel.symbolsFromJson(Map<String, dynamic> json) {
    if (json['symbols'] != null) {
      symbols = <Symbols>[];
      json['symbols'].forEach((dynamic v) {
        final Symbols data = Symbols.fromJson(v);
        symbols.add(data);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['symbols'] = symbols.map((dynamic v) => v.toJson()).toList();
    return data;
  }
}
