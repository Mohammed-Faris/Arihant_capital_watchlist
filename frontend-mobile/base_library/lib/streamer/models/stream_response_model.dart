class StreamReponseModel {
  Response? response;

  StreamReponseModel({this.response});

  StreamReponseModel.fromJson(Map<String, dynamic> json) {
    response =
        json['response'] != null ? Response.fromJson(json['response']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (response != null) {
      data['response'] = response!.toJson();
    }
    return data;
  }
}

class Response {
  ResponseData? data;
  late String streamingType;

  Response({this.data, required this.streamingType});

  Response.fromJson(json) {
    data = json['data'] != null ? ResponseData.fromJson(json['data']) : null;
    streamingType = json['streaming_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['streaming_type'] = streamingType;
    return data;
  }
}

class ResponseData {
  String? oI;
  String? oIChngPer;
  String? ttv;
  String? atp;
  String? chng;
  String? chngPer;
  String? close;
  String? high;
  String? lcl;
  String? low;
  String? ltp;
  String? ltq;
  String? ltt;
  String? open;
  String? symbol;
  String? ucl;
  String? vol;
  String? yHigh;
  String? yLow;
  String? bidPrice;
  String? askPrice;
  late Map<String, String?> responseData;

  ResponseData({
    this.oI,
    this.oIChngPer,
    this.ttv,
    this.atp,
    this.chng,
    this.chngPer,
    this.close,
    this.high,
    this.lcl,
    this.low,
    this.ltp,
    this.ltq,
    this.ltt,
    this.open,
    this.symbol,
    this.ucl,
    this.vol,
    this.yHigh,
    this.yLow,
    this.askPrice,
    this.bidPrice,
  });

  ResponseData.fromJson(json) {
    oI = json['OI'];
    oIChngPer = json['OIChngPer'];
    ttv = json['ttv'];
    atp = json['atp'];
    chng = json['chng'];
    chngPer = json['chngPer'];
    close = json['close'];
    high = json['high'];
    lcl = json['lcl'];
    low = json['low'];
    ltp = json['ltp'];
    ltq = json['ltq'];
    ltt = json['ltt'];
    open = json['open'];
    symbol = json['symbol'];
    ucl = json['ucl'];
    vol = json['vol'];
    yHigh = json['yHigh'];
    yLow = json['yLow'];
    askPrice = json['askPrice'];
    bidPrice = json['bidPrice'];
    responseData = {
      'OI': oI,
      'OIChngPer': oIChngPer,
      'ttv': ttv,
      'atp': atp,
      'chng': chng,
      'chngPer': chngPer,
      'close': close,
      'high': high,
      'lcl': lcl,
      'low': low,
      'ltp': ltp,
      'ltq': ltq,
      'ltt': ltt,
      'open': open,
      'symbol': symbol,
      'ucl': ucl,
      'vol': vol,
      'yHigh': yHigh,
      'yLow': yLow,
      'askPrice': askPrice,
      'bidPrice': bidPrice
    };
  }

  Map toJson() {
    final Map data = Map();
    data['OI'] = oI;
    data['OIChngPer'] = oIChngPer;
    data['ttv'] = ttv;
    data['atp'] = atp;
    data['chng'] = chng;
    data['chngPer'] = chngPer;
    data['close'] = close;
    data['high'] = high;
    data['lcl'] = lcl;
    data['low'] = low;
    data['ltp'] = ltp;
    data['ltq'] = ltq;
    data['ltt'] = ltt;
    data['open'] = open;
    data['symbol'] = symbol;
    data['ucl'] = ucl;
    data['vol'] = vol;
    data['yHigh'] = yHigh;
    data['yLow'] = yLow;
    data['askPrice'] = askPrice;
    data['bidPrice'] = bidPrice;

    return data;
  }

  dynamic getKeyValue(String keyName) {
    return responseData[keyName];
  }
}
