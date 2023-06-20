// ignore_for_file: overridden_fields

import 'package:acml/src/constants/app_constants.dart';
import 'package:acml/src/models/common/sym_model.dart';
import 'package:acml/src/models/common/symbols_model.dart';
import 'package:msil_library/models/base/base_model.dart';

import '../../data/store/app_utils.dart';
import 'order_status_log.dart';

class OrderBook extends BaseModel {
  List<Orders>? orders;

  OrderBook({this.orders});

  OrderBook.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    if (data['orders'] != null) {
      orders = <Orders>[];
      data['orders'].forEach((v) {
        Orders order = Orders.fromJson(v);
        orders!.add(order);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orders'] = orders!.map((v) => v.toJson()).toList();
    return data;
  }
}

class Orders extends Symbols {
  String? undAsset;
  String? excOrdTime;
  String? ordAction;
  String? cancelledQty;
  bool? isAmo;
  bool isGtd = false;
  String? exitable;
  String? boOrdStatus;
  String? ordId;
  String? cancellable;
  String? ordDate;
  String? modifiable;
  String? gtdOrdDate;
  String? prdType;
  String? modifiedBy;
  bool? isModifiable;
  bool? isExecutable;
  String? ordStatus;
  String? ordDuration;
  String? childType;
  String? triggerPrice;
  String? limitPrice;
  String? disQty;
  String? parOrdId;
  String? actCode;
  String? actDisp;
  String? tradedQty;
  String? remainQty;
  String? rejReason;
  String? exchOrdId;
  String? ordType;
  String? status;
  String? orderValue;
  String? currentOrdStatus;
  String? triggerid;
  String? mainLegPrice;
  String? ordValidDte;
  String? basketId;
  String? comments;
  String? requiredMarigin;
  String? remarks;
  int? pos;
  String? basketOrderId;
  String? resetCount;
  String? boStpLoss;
  String? trailingSL;
  String? boTgtPrice;
  List<ListOfTrades>? listOfTrades;

  Orders(
      {this.undAsset,
      this.excOrdTime,
      this.ordAction,
      this.cancelledQty,
      this.isAmo,
      this.exitable,
      this.boOrdStatus,
      this.ordId,
      this.cancellable,
      this.ordDate,
      this.isGtd = false,
      this.prdType,
      this.modifiedBy,
      this.isModifiable,
      this.isExecutable,
      this.ordStatus,
      this.ordDuration,
      this.boStpLoss,
      this.trailingSL,
      this.boTgtPrice,
      this.childType,
      this.triggerPrice,
      this.limitPrice,
      this.disQty,
      this.parOrdId,
      this.tradedQty,
      this.gtdOrdDate,
      this.remainQty,
      this.rejReason,
      this.exchOrdId,
      this.ordType,
      this.status,
      this.orderValue,
      this.currentOrdStatus,
      this.triggerid,
      this.mainLegPrice,
      this.ordValidDte,
      this.comments,
      this.requiredMarigin,
      this.remarks,
      this.modifiable,
      this.pos,
      this.basketOrderId,
      this.resetCount,
      this.basketId});

  Orders.fromJson(Map<String, dynamic> json) {
    basketId = json['basketId'];
    undAsset = json['undAsset'];
    excOrdTime = json['excOrdTime'];
    ordAction = json['ordAction'];
    cancelledQty = json['cancelledQty'];
    isAmo = json['isAmo'];
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
    avgPrice = json['avgPrice'];
    exitable = json['exitable'];
    boOrdStatus = json['boOrdStatus'];
    ordId = json['ordId'] ?? json['basketOrderId'];
    if (json['listOfTrades'] != null) {
      listOfTrades = <ListOfTrades>[];
      json['listOfTrades'].forEach((v) {
        listOfTrades!.add(ListOfTrades.fromJson(v));
      });
    }
    isFno = json['isFno'] == "true";
    if (AppUtils().getsymbolTypeFromSym(sym) == AppConstants.fno) {
      isFno = true;
    }
    cancellable = json['cancellable'];
    ordDate = json['ordDate'];
    actDisp = json['actDisp'];
    actCode = json['actCode'];
    boStpLoss = json['boStpLoss'];
    trailingSL = json['trailingSL'];
    boTgtPrice = json['boTgtPrice'];

    isGtd = ((json['commentsV2'] ?? json["comments"]) == AppConstants.gtd);

    prdType = isGtd ? AppConstants.delivery : json["prdType"];
    modifiedBy = json['modifiedBy'];
    baseSym = json['baseSym'];
    isModifiable = json['isModified'];
    isExecutable = json['isExecuted'];
    ordStatus = json['ordStatus'];
    modifiable = json["modifiable"];
    dispSym = json['dispSym'];
    ordDuration = json['OrderDurationV2'] ?? json['ordDuration'];
    //v2 is added to resolve gtd issue
    childType = json['childType'];
    triggerPrice = json['triggerPrice'];
    limitPrice = json['limitPrice'];
    disQty = json['disQty'];
    parOrdId = json['parOrdId'];
    tradedQty = json['tradedQty'];
    remainQty = json['remainQty'];
    rejReason = json['rejReason'];
    qty = json['qty'];
    exchOrdId = json['exchOrdId'];
    ordType = (json['ordType'] == null && isGtd)
        ? ((triggerPrice?.isEmpty ?? false) ||
                double.tryParse(triggerPrice ?? "0") == 0)
            ? AppConstants.limit
            : AppConstants.sl
        : json["ordType"];
    status = json['status'];
    gtdOrdDate = json['gtdOrdDate'];
    currentOrdStatus = json['currentOrdStatus'];
    triggerid = json['triggerId'];
    mainLegPrice = json['mainLegPrice'];
    ordValidDte = json['ordValidDte'];
    comments = json['commentsV2'] ?? json["comments"];
    requiredMarigin = json['requiredMarigin'];
    remarks = "${json['basketOrderId']}_${json['resetCount']}";
    pos = json['pos'];
    basketOrderId = json['basketOrderId'];
    resetCount = json['resetCount'];
  }

  get lotSize => null;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['basketId'] = basketId;
    data['undAsset'] = undAsset;
    data['excOrdTime'] = excOrdTime;
    data['ordAction'] = ordAction;
    data['cancelledQty'] = cancelledQty;
    data['isAmo'] = isAmo;
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    data['ltp'] = ltp?.replaceAll(",", "");
    data['isFno'] = isFno.toString();
    data['actDisp'] = actDisp;
    data['modifiable'] = modifiable;

    data['actCode'] = actCode;

    data['avgPrice'] = avgPrice;
    data['exitable'] = exitable;
    data['boOrdStatus'] = boOrdStatus;
    data['ordId'] = ordId;
    data['cancellable'] = cancellable;
    data['ordDate'] = ordDate;
    data['prdType'] = prdType;
    data['modifiedBy'] = modifiedBy;
    data['gtdOrdDate'] = gtdOrdDate;
    data['baseSym'] = baseSym;
    data['isModified'] = isModifiable;
    data['isExecuted'] = isExecutable;
    data['ordStatus'] = ordStatus;
    data['dispSym'] = dispSym;
    data['ordDuration'] = ordDuration;
    data['OrderDurationV2'] = ordDuration;
    data['childType'] = childType;
    data['triggerPrice'] = triggerPrice;
    data['limitPrice'] = limitPrice;
    data['disQty'] = disQty;
    data['parOrdId'] = parOrdId;
    data['tradedQty'] = tradedQty;
    data['remainQty'] = remainQty;
    data['rejReason'] = rejReason;
    data['qty'] = qty;
    data['netQty'] = qty;

    data['exchOrdId'] = exchOrdId;
    data['ordType'] = ordType;
    data['status'] = status;
    data['currentOrdStatus'] = currentOrdStatus;
    data['triggerid'] = triggerid;
    data['mainLegPrice'] = mainLegPrice;
    data['ordValidDte'] = ordValidDte;
    data['requiredMarigin'] = requiredMarigin;
    data['remarks'] = remarks;
    data['pos'] = pos;
    data['boStpLoss'] = boStpLoss;
    data['trailingSL'] = trailingSL;
    data['boTgtPrice'] = boTgtPrice;
    data['commentsV2'] = comments;
    data['basketOrderId'] = basketOrderId;
    data['resetCount'] = resetCount;
    return data;
  }
}
