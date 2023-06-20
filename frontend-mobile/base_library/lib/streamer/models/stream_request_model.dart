import 'streaming_symbol_model.dart';

class StreamRequestModel {
  Request? request;

  StreamRequestModel({this.request});

  StreamRequestModel.fromJson(Map<String, dynamic> json) {
    request =
        json['request'] != null ? Request.fromJson(json['request']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (request != null) {
      data['request'] = request!.toJson();
    }
    return data;
  }
}

class Request {
  late String streamingType;
  late String requestType;
  late String session;
  Data? data;

  Request({
    required this.streamingType,
    required this.requestType,
    required this.session,
    this.data,
  });

  Request.fromJson(Map<String, dynamic> json) {
    streamingType = json['streaming_type'];
    requestType = json['request_type'];
    session = json['session'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['streaming_type'] = streamingType;
    data['request_type'] = requestType;
    data['session'] = session;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<StreamingSymbolModel> symbols = [];

  Data({required this.symbols});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['symbols'] != null) {
      symbols = <StreamingSymbolModel>[];
      json['symbols'].forEach((dynamic v) {
        symbols.add(StreamingSymbolModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['symbols'] =
        symbols.map((StreamingSymbolModel v) => v.toJson()).toList();
    return data;
  }
}
