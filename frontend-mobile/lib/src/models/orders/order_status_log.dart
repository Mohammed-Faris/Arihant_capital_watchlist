import 'package:msil_library/models/base/base_model.dart';

import '../common/sym_model.dart';
import 'order_book.dart';

class OrderStatusLog extends BaseModel {
  String? dispSym;
  Sym? sym;
  Orders? ordDtls;
  String? exchOrdId;
  List<History>? history;
  String? ordId;
  List<ListOfTrades>? listOfTrades;

  OrderStatusLog(
      {this.dispSym, this.sym, this.exchOrdId, this.history, this.ordId});

  OrderStatusLog.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    dispSym = data['dispSym'];
    sym = data['sym'] != null ? Sym.fromJson(data['sym']) : null;
    ordDtls = data['ordDtls'] != null ? Orders.fromJson(data['ordDtls']) : null;
    exchOrdId = data['exchOrdId'];
    if (data['history'] != null) {
      history = <History>[];
      data['history'].forEach((v) {
        history!.add(History.fromJson(v));
      });
    }

    if (data['listOfTrades'] != null) {
      listOfTrades = <ListOfTrades>[];
      data['listOfTrades'].forEach((v) {
        listOfTrades!.add(ListOfTrades.fromJson(v));
      });
    }
    ordId = data['ordId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dispSym'] = dispSym;
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    if (ordDtls != null) {
      data['ordDtls'] = ordDtls!.toJson();
    }
    data['exchOrdId'] = exchOrdId;
    if (history != null) {
      data['history'] = history!.map((v) => v.toJson()).toList();
    }
    data['ordId'] = ordId;
    return data;
  }
}

class History {
  String? ordStatus;
  String? ordDuration;
  String? limitPrice;
  String? lupdateTime;
  Sym? sym;
  int? qty;
  String? modifiedBy;
  String? status;
  String? lupdateDateTime;
  String? ordId;
  String? tradedQty;
  String? rejectQty;
  String? cancelQty;
  String? ordSource;
  String? noOfDays;
  History(
      {this.ordStatus,
      this.ordDuration,
      this.limitPrice,
      this.lupdateTime,
      this.sym,
      this.qty,
      this.lupdateDateTime,
      this.modifiedBy,
      this.status,
      this.ordId,
      this.tradedQty,
      this.rejectQty,
      this.cancelQty,
      this.ordSource,
      this.noOfDays});

  History.fromJson(Map<String, dynamic> json) {
    ordStatus = json['ordStatus'];
    ordDuration = json['ordDuration'];
    limitPrice = json['limitPrice'];
    lupdateTime = json['lupdateTime'];
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
    qty = json['qty'];
    lupdateDateTime = json['lupdateDateTime'];
    modifiedBy = json['modifiedBy'];
    status = json['status'];
    ordId = json["ordId"] ?? "";
    tradedQty = json["tradedQty"] ?? "";
    rejectQty = json["rejectQty"] ?? "";
    cancelQty = json["cancelQty"] ?? "";
    ordSource = json["ordSource"] ?? "";
    noOfDays = json["noOfDays"] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ordStatus'] = ordStatus;
    data['ordDuration'] = ordDuration;
    data['limitPrice'] = limitPrice;
    data['lupdateTime'] = lupdateTime;
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    data['qty'] = qty;
    data['modifiedBy'] = modifiedBy;
    data['status'] = status;
    data['lupdateDateTime'] = lupdateDateTime;

    return data;
  }
}

class ListOfTrades {
  String? tradedQty;
  String? prcPerShare;

  ListOfTrades(Orders orders, {this.tradedQty, this.prcPerShare});

  ListOfTrades.fromJson(Map<String, dynamic> json) {
    tradedQty = json['tradedQty'];
    prcPerShare = json['prcPerShare'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tradedQty'] = tradedQty;
    data['prcPerShare'] = prcPerShare;
    return data;
  }
}
