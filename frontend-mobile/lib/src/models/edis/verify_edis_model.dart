import 'package:msil_library/models/base/base_model.dart';

class VerifyEdisModel extends BaseModel {
  List<Edis>? edis;

  VerifyEdisModel({this.edis});

  VerifyEdisModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    if (data['edis'] != null) {
      edis = <Edis>[];
      data['edis'].forEach((v) {
        edis!.add(Edis.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (edis != null) {
      data['edis'] = edis!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Edis {
  String? fName;
  String? listenUrl;
  String? name;
  String? reqId;
  String? reqTime;
  List<Params>? params;
  String? type;
  String? url;

  Edis(
      {this.fName,
      this.listenUrl,
      this.name,
      this.reqId,
      this.reqTime,
      this.params,
      this.type,
      this.url});

  Edis.fromJson(Map<String, dynamic> json) {
    fName = json['fName'];
    listenUrl = json['listenUrl'];
    name = json['name'];
    reqId = json['reqId'];
    reqTime = json['reqTime'];
    if (json['params'] != null) {
      params = <Params>[];
      json['params'].forEach((v) {
        params!.add(Params.fromJson(v));
      });
    }
    type = json['type'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fName'] = fName;
    data['listenUrl'] = listenUrl;
    data['name'] = name;
    data['reqId'] = reqId;
    data['reqTime'] = reqTime;
    if (params != null) {
      data['params'] = params!.map((v) => v.toJson()).toList();
    }
    data['type'] = type;
    data['url'] = url;
    return data;
  }
}

class Params {
  String? value;
  String? key;

  Params({this.value, this.key});

  Params.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    key = json['key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['key'] = key;
    return data;
  }
}
