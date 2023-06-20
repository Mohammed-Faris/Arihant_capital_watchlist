import 'package:intl/intl.dart';
import 'package:msil_library/models/base/base_model.dart';

import '../../constants/app_constants.dart';
import '../common/symbols_model.dart';

class AlertModel extends BaseModel {
  AlertModel({
    required this.alertList,
  });
  late List<AlertList> alertList;
  List<AlertBySymbol> equityList = [];
  List<AlertBySymbol> futureList = [];
  List<AlertBySymbol> optionList = [];

  AlertModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    alertList = List.from(data['alertList'] ?? [])
        .map((e) => AlertList.fromJson(e))
        .toList();

    Map<String, List<AlertList>> alertsBySymName = {};
    for (AlertList alert in alertList) {
      if (!alertsBySymName.containsKey(alert.symName)) {
        alertsBySymName[alert.symName] = [];
      }
      alertsBySymName[alert.symName]!.add(alert);
    }

    for (String symName in alertsBySymName.keys) {
      List<AlertList> alerts = alertsBySymName[symName]!;
      Symbols symbol = alerts.first.symbol;
      AlertBySymbol alertBySymbol =
          AlertBySymbol(symName, symbol, "0.00", alerts);
      if (alerts.first.symbol.sym?.exc == AppConstants.nse ||
          alerts.first.symbol.sym?.exc == AppConstants.bse) {
        equityList.add(alertBySymbol);
      } else if (alerts.first.symbol.sym!.instrument == AppConstants.opt) {
        optionList.add(alertBySymbol);
      } else if (alerts.first.symbol.sym!.instrument!
          .contains(AppConstants.fut)) {
        futureList.add(alertBySymbol);
      }
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['alertList'] = alertList.map((e) => e.toJson()).toList();
    return data;
  }
}

class AlertList {
  AlertList({
    required this.alertID,
    required this.alertName,
    required this.createdAt,
    required this.criteriaType,
    required this.criteriaValue,
    required this.notificationType,
    required this.sym,
    required this.symName,
    required this.symbol,
    required this.triggerPrice,
    required this.triggeredAt,
    required this.userID,
  });
  late final String alertID;
  late final String alertName;
  late final String createdAt;
  late final String triggeredAt;

  late final String criteriaType;
  late final String criteriaValue;
  late final String notificationType;
  late final String sym;
  late final String symName;
  late final Symbols symbol;
  late final String triggerPrice;
  late final String userID;

  AlertList.fromJson(Map<String, dynamic> json) {
    alertID = json['alertID'];
    alertName = json['alertName'];
    createdAt = json['createdAt'];
    criteriaType = json['criteriaType'];
    criteriaValue = json['criteriaValue'];
    notificationType = json['notification_type'];
    sym = json['sym'];
    symName = json['symName'];
    symbol = Symbols.fromJson(json['symbol']);
    triggerPrice = json['triggerPrice'];
    try {
      triggeredAt = json['triggeredAt'] != null && json['triggeredAt'] != ""
          ? DateFormat("dd MMM yyyy hh:mm").format(
              DateFormat("dd-MM-yyyy hh:mm:ss").parse(json['triggeredAt']))
          : json['triggeredAt'] ?? "";
    } catch (e) {
      triggeredAt = json['triggeredAt'] ?? "";
    }
    userID = json['userID'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['alertID'] = alertID;
    data['alertName'] = alertName;
    data['createdAt'] = createdAt;
    data['criteriaType'] = criteriaType;
    data['criteriaValue'] = criteriaValue;
    data['notification_type'] = notificationType;
    data['sym'] = sym;
    data['symName'] = symName;
    data['symbol'] = symbol.toJson();
    data['triggerPrice'] = triggerPrice;
    data['userID'] = userID;
    data['triggeredAt'] = triggeredAt;
    return data;
  }
}

class AlertBySymbol {
  final String symName;
  final Symbols symbol;
  final String ltp;
  final List<AlertList> alertList;
  AlertBySymbol(this.symName, this.symbol, this.ltp, this.alertList);
}
