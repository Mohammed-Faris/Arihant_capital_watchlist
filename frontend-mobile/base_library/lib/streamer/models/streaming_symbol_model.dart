class StreamingSymbolModel {
  late String symbol;

  StreamingSymbolModel({required this.symbol});

  StreamingSymbolModel.fromJson(Map<String, dynamic> json) {
    symbol = json['symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['symbol'] = symbol;
    return data;
  }
}
