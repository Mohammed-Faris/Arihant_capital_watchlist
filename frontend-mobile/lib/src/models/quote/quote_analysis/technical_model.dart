import 'package:msil_library/models/base/base_model.dart';

class Technical extends BaseModel {
  String? sma100;
  String? sma10;
  String? sma200;
  String? sma20;
  String? macd12269;
  String? ema20;
  String? sma50;
  String? ema50;
  String? rsi;
  String? ema10;
  String? macd1226;

  Technical(
      {sma100,
      sma10,
      sma200,
      sma20,
      macd12269,
      ema20,
      sma50,
      ema50,
      rsi,
      ema10,
      macd1226});

  Technical.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    sma100 = data['sma100'];
    sma10 = data['sma10'];
    sma200 = data['sma200'];
    sma20 = data['sma20'];
    macd12269 = data['macd12269'];
    ema20 = data['ema20'];
    sma50 = data['sma50'];
    ema50 = data['ema50'];
    rsi = data['rsi'];
    ema10 = data['ema10'];
    macd1226 = data['macd1226'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sma100'] = sma100;
    data['sma10'] = sma10;
    data['sma200'] = sma200;
    data['sma20'] = sma20;
    data['macd12269'] = macd12269;
    data['ema20'] = ema20;
    data['sma50'] = sma50;
    data['ema50'] = ema50;
    data['rsi'] = rsi;
    data['ema10'] = ema10;
    data['macd1226'] = macd1226;
    return data;
  }
}
