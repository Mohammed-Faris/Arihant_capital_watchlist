import '../common/symbols_model.dart';
import 'package:msil_library/models/base/base_model.dart';

class GetSymbolModel extends BaseModel {
  Symbols? symbol;

  GetSymbolModel({this.symbol});

  GetSymbolModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    symbol = Symbols.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data = symbol!.toJson();
    return data;
  }
}
