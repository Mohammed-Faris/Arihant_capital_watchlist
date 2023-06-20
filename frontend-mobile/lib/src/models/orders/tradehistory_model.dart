import 'package:intl/intl.dart';
import 'package:msil_library/models/base/base_model.dart';

class TradeHistory extends BaseModel {
  TradeHistory({
    required this.reportList,
  });
  List<ReportList> reportList = [];

  TradeHistory.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    reportList = List.from(data['reportList'])
        .map((e) => ReportList.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['reportList'] = reportList.map((e) => e.toJson()).toList();
    return data;
  }
}

class ReportList {
  ReportList({
    required this.netAmt,
    required this.ordAction,
    required this.netQty,
    required this.orderNo,
    required this.sym,
    required this.companyName,
    required this.tradeDate,
  });
  late final String netAmt;
  late final String ordAction;
  late final String netQty;
  late final String orderNo;
  late final Sym sym;
  String avgPrice = "";
  late final String companyName;
  late final String tradeDate;
  DateTime? tradeddate;
  DateTime? tradeTime;

  ReportList.fromJson(Map<String, dynamic> json) {
    netAmt = json['netAmt'];
    ordAction = json['ordAction'];
    netQty = json['netQty'];
    orderNo = json['orderNo'];
    sym = Sym.fromJson(json['sym']);
    companyName = json['companyName'];
    // tradedDateTime =
    //     DateFormat('dd MMM yy - HH:MM:ss').parse(json['tradeDate']);
    tradeddate = DateFormat("dd/MM/yyyy").parse(json["date"]);
    if (json["tradeTime"] != "" && json["tradeTime"] != null) {
      tradeTime = DateFormat("HH:mm").parse(json["tradeTime"]);
    }
    avgPrice = json["avgPrice"] ?? "";
    tradeDate = DateFormat("dd/MM/yyyy ${tradeTime != null ? "hh:mm a" : ""}")
        .format(DateTime(
            tradeddate!.year,
            tradeddate!.month,
            tradeddate!.day,
            tradeTime?.hour ?? 0,
            tradeTime?.minute ?? 0,
            tradeTime?.second ?? 0));
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['netAmt'] = netAmt;
    data['ordAction'] = ordAction;
    data['netQty'] = netQty;
    data['orderNo'] = orderNo;
    data['sym'] = sym.toJson();
    data['companyName'] = companyName;
    data['tradeDate'] = tradeDate;
    return data;
  }
}

class Sym {
  Sym({
    required this.exc,
  });
  late final String exc;

  Sym.fromJson(Map<String, dynamic> json) {
    exc = json['exc'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['exc'] = exc;
    return data;
  }
}
