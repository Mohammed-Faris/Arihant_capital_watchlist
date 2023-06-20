import '../common/symbols_model.dart';
import 'package:msil_library/models/base/base_model.dart';

class WatchlistSymbolsModel extends BaseModel {
  late List<Symbols> symbols;

  WatchlistSymbolsModel(this.symbols);

  List<Symbols> getSymbols() {
    return symbols;
  }

  WatchlistSymbolsModel.fromJson(Map<String, dynamic> json)
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['symbols'] = symbols.map((dynamic v) => v.toJson()).toList();
    return data;
  }
  // WatchlistSymbolsModel.copyModel(Symbols symbol) : super.copyModel(symbol);
}
