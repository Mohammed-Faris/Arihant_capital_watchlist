// ignore_for_file: overridden_fields

import 'package:acml/src/models/common/sym_model.dart';
import 'package:acml/src/models/common/symbols_model.dart';
import 'package:msil_library/models/base/base_model.dart';

class GlobalAndUserNotificationsModel extends BaseModel {
  List<Messages>? messages;

  GlobalAndUserNotificationsModel({this.messages});

  GlobalAndUserNotificationsModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    if (data['Messages'] != null) {
      messages = <Messages>[];
      data['Messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (messages != null) {
      data['Messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  String? pushMsg;
  String? extraInfo;
  int? isRead;
  String? createdAt;
  String? notificationID;
  String? title;
  String? target;
  String? msgType;

  Messages({
    this.pushMsg,
    this.extraInfo,
    this.isRead,
    this.createdAt,
    this.notificationID,
    this.target,
    this.title,
    this.msgType,
  });

  Messages.fromJson(Map<String, dynamic> json) {
    pushMsg = json['pushMsg'];
    extraInfo = json['extra_info'].toString().replaceAll(r"\'", "'");
    isRead = json['isRead'];
    createdAt = json['created_at'];
    notificationID = json['notificationID'];
    title = json['title'];
    target = json['target'];
    msgType = json['msgType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pushMsg'] = pushMsg;
    data['extra_info'] = extraInfo;
    data['isRead'] = isRead;
    data['created_at'] = createdAt;
    data['notificationID'] = notificationID;
    data['title'] = title;
    data['target'] = target;
    data['msgType'] = msgType;
    return data;
  }
}

class ExtraInfoModel extends Symbols {
  AlertCriteria? alertInfo;
  String? icon;
  String? image;
  String? video;
  @override
  Sym? sym;
  @override
  String? dispSym;
  String? exc;

  ExtraInfoModel({this.alertInfo, this.icon, this.image, this.video, this.sym});

  ExtraInfoModel.fromJson(Map<String, dynamic> json) {
    alertInfo = json['alertInfo'] != null
        ? AlertCriteria.fromJson(json['alertInfo'])
        : null;
    icon = json['icon'];
    image = json['image'];
    video = json['video'];
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
    dispSym = sym != null ? sym!.dispSym : '';
    exc = sym != null ? sym!.exc : '';
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (alertInfo != null) {
      data['alertInfo'] = alertInfo!.toJson();
    }
    data['icon'] = icon;
    data['image'] = image;
    data['video'] = video;
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    return data;
  }
}

class AlertCriteria {
  String? criteriaType;
  String? criteriaVal;
  String? criteriaValue;

  AlertCriteria({this.criteriaType, this.criteriaVal});

  AlertCriteria.fromJson(Map<String, dynamic> json) {
    criteriaType = json['criteriaType'];
    criteriaVal = json['criteriaVal'];
    criteriaValue = json['criteriaValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['criteriaType'] = criteriaType;
    data['criteriaVal'] = criteriaVal;
    data['criteriaValue'] = criteriaValue;
    return data;
  }
}
