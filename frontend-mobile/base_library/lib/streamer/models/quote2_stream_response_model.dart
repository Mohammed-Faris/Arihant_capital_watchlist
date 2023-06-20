class Quote2StreamReponseModel {
  Qoute2Response? response;

  Quote2StreamReponseModel({this.response});

  Quote2StreamReponseModel.fromJson(Map<dynamic, dynamic> json) {
    response = json['response'] != null
        ? Qoute2Response.fromJson(json['response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (response != null) {
      data['response'] = response?.toJson();
    }

    return data;
  }
}

class Qoute2Response {
  Quote2Data? data;
  late String streamingType;

  Qoute2Response({this.data, required this.streamingType});

  Qoute2Response.fromJson(Map<dynamic, dynamic> json) {
    data = json['data'] != null ? Quote2Data.fromJson(json['data']) : null;
    streamingType = json['streaming_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    data['streaming_type'] = streamingType;
    return data;
  }
}

class Quote2Data {
  late List<SymbolData> ask;
  late List<SymbolData> bid;
  late String symbol;
  late String totBuyQty;
  late String totSellQty;

  Quote2Data({
    required this.ask,
    required this.bid,
    required this.symbol,
    required this.totBuyQty,
    required this.totSellQty,
  });

  Quote2Data.fromJson(Map<dynamic, dynamic> json) {
    if (json['ask'] != null) {
      ask = <SymbolData>[];
      json['ask'].forEach((dynamic v) {
        ask.add(SymbolData.fromJson(v));
      });
    }
    if (json['bid'] != null) {
      bid = <SymbolData>[];
      json['bid'].forEach((v) {
        bid.add(SymbolData.fromJson(v));
      });
    }
    symbol = json['symbol'];
    totBuyQty = json['totBuyQty'].toString();
    totSellQty = json['totSellQty'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['ask'] = ask.map((SymbolData v) => v.toJson()).toList();
    data['bid'] = bid.map((SymbolData v) => v.toJson()).toList();
    data['symbol'] = symbol;
    data['totBuyQty'] = totBuyQty.toString();
    data['totSellQty'] = totSellQty.toString();
    return data;
  }
}

class SymbolData {
  late String no;
  late String price;
  late String qty;

  SymbolData({required this.no, required this.price, required this.qty});

  SymbolData.fromJson(Map<dynamic, dynamic> json) {
    no = json['no'].toString();
    price = json['price'].toString();
    qty = json['qty'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['no'] = no;
    data['price'] = price;
    data['qty'] = qty;
    return data;
  }
}
