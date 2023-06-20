import 'package:msil_library/models/base/base_model.dart';

class HistoryData extends BaseModel {
  HistoryData({
    required this.dataPoints,
  });
  late final List<DataPoints> dataPoints;

  HistoryData.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    dataPoints = List.from(data['dataPoints'])
        .map((e) => DataPoints.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['dataPoints'] = dataPoints.map((e) => e.toJson()).toList();
    return data;
  }
}

class DataPoints {
  DataPoints({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.date,
  });
  late final String open;
  late final String high;
  late final String low;
  late final String close;
  late final String volume;
  late final String date;

  DataPoints.fromJson(List json) {
    open = json[0].toString();
    high = json[1].toString();
    low = json[2].toString();
    close = json[3].toString();
    volume = json[4].toString();
    date = json[5];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['open'] = open;
    data['high'] = high;
    data['low'] = low;
    data['close'] = close;
    data['volume'] = volume;
    data['date'] = date;
    return data;
  }
}
