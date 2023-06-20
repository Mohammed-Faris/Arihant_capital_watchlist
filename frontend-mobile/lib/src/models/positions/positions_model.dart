// ignore_for_file: overridden_fields

import 'package:acml/src/models/common/sym_model.dart';
import 'package:acml/src/models/common/symbols_model.dart';
import 'package:msil_library/models/base/base_model.dart';

import '../../config/app_config.dart';
import '../../constants/app_constants.dart';
import '../../data/store/app_utils.dart';

class PositionsModel extends BaseModel {
  List<Positions>? positions;

  PositionsModel({this.positions});

  PositionsModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    if (data['positions'] != null) {
      positions = <Positions>[];
      data['positions'].forEach(
        (dynamic v) {
          positions!.add(Positions.fromJson(v));
        },
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (positions != null) {
      data['positions'] = positions!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  PositionsModel.copyModel(PositionsModel position) {
    copyModel(position);
  }
  void copyModel(PositionsModel position) {
    positions = position.positions;
  }
}

class Positions extends Symbols {
  String? undAsset;
  String? buyAmt;
  String? daySellAvgPrice;
  String? ordAction;
  String? sellAvgPrice;
  @override
  Sym? sym;
  @override
  String? avgPrice;
  @override
  String? companyName;
  String? transferable;
  String? cfBuyQty;
  String? type;
  String? netAmt;
  String? prdType;
  @override
  String? baseSym;
  String? buyAvgPrice;
  String? cfSellAvgPrice;
  @override
  String? dispSym;
  String? cfSellAmt;
  String? netQty;
  String? cfBuyAvgPrice;
  String? dayBuyAvgPrice;
  String? lotSize;
  @override
  String? ltp;
  @override
  String? close;
  String? prevPos;
  String? currPos;
  String? prevAvgPrice;
  String? netPnl;
  String? sellQty;
  String? cfSellQty;
  @override
  String? pnlPerc;
  String? buyQty;
  String? bookedPnl;
  String? currAvgPrice;
  String? sellAmt;
  @override
  String? unRealizedPnl;
  String? cfBuyAmt;
  String? isSquareoff;
  String? currentValue;
  String? investedValue;
  String? todayPL;
  String? todayPLPercentage;
  bool? isFUT = false;
  bool isOneDay = false;
  String? dayBuyQty;
  String? daySellQty;
  String? positionIdForInternalValidation;

  Positions({
    this.undAsset,
    this.buyAmt,
    this.daySellAvgPrice,
    this.ordAction,
    this.sellAvgPrice,
    this.sym,
    this.avgPrice,
    this.companyName,
    this.transferable,
    this.cfBuyQty,
    this.type,
    this.netAmt,
    this.prdType,
    this.baseSym,
    this.buyAvgPrice,
    this.cfSellAvgPrice,
    this.dispSym,
    this.cfSellAmt,
    this.netQty,
    this.cfBuyAvgPrice,
    this.dayBuyAvgPrice,
    this.lotSize,
    this.ltp,
    this.close,
    this.prevPos,
    this.currPos,
    this.prevAvgPrice,
    this.netPnl,
    this.sellQty,
    this.cfSellQty,
    this.pnlPerc,
    this.buyQty,
    this.bookedPnl,
    this.currAvgPrice,
    this.sellAmt,
    this.unRealizedPnl,
    this.cfBuyAmt,
    this.isSquareoff,
    this.currentValue,
    this.investedValue,
    this.todayPL,
    this.todayPLPercentage,
    this.isFUT,
    this.dayBuyQty,
    this.daySellQty,
  });

  Positions.fromJson(Map<String, dynamic> json) {
    undAsset = json['undAsset'];
    buyAmt = json['buyAmt'];
    daySellAvgPrice = json['daySellAvgPrice'];
    ordAction = json['ordAction'];
    sellAvgPrice = json['sellAvgPrice'];
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
    avgPrice = json['avgPrice'];
    companyName = json['companyName'];
    transferable = json['transferable'];
    close = json['close'];

    cfBuyQty = json['cfBuyQty'];
    type = json['type'];
    netAmt = json['netAmt'];
    prdType = json['prdType'];
    baseSym = json['baseSym'];
    isFno = json['isFno'] == "true";
    if (AppUtils().getsymbolTypeFromSym(sym) == AppConstants.fno) {
      isFno = true;
    }
    buyAvgPrice = json['buyAvgPrice'];
    if (Featureflag.isActualCFPrice) {
      cfBuyAvgPrice = json['cfActualBAP'];
      cfSellAvgPrice = json['cfActualSAP'];
    } else {
      cfSellAvgPrice = json['cfSellAvgPrice'];
      cfBuyAvgPrice = json['cfBuyAvgPrice'];
    }
    dispSym = json['dispSym'];
    cfSellAmt = json['cfSellAmt'];
    netQty = json['netQty'];
    dayBuyAvgPrice = json['dayBuyAvgPrice'];
    lotSize = json['lotSize'];
    ltp = json['ltp'];
    prevPos = json['prevPos'];
    currPos = json['currPos'];
    prevAvgPrice = json['prevAvgPrice'];
    netPnl = json['netPnl'];
    sellQty = json['sellQty'];
    cfSellQty = json['cfSellQty'];
    pnlPerc = json['pnlPerc'];
    buyQty = json['buyQty'];
    bookedPnl = json['bookedPnl'];
    currAvgPrice = json['currAvgPrice'];
    sellAmt = json['sellAmt'];
    unRealizedPnl = json['unRealizedPnl'];
    cfBuyAmt = json['cfBuyAmt'];
    isSquareoff = json['isSquareoff'];
    dayBuyQty = json['dayBuyQty'];
    daySellQty = json['daySellQty'];
    isFUT = _isFutures();
    positionIdForInternalValidation = (dispSym ?? "") + (prdType ?? "");
  }

  _isFutures() {
    if (sym!.asset == 'future') {
      return true;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['undAsset'] = undAsset;
    data['buyAmt'] = buyAmt;
    data['ordAction'] = ordAction;
    data['sellAvgPrice'] = sellAvgPrice;
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    data['avgPrice'] = avgPrice;
    data['companyName'] = companyName;
    data['transferable'] = transferable;
    data['cfBuyQty'] = cfBuyQty;
    data['type'] = type;
    data['netAmt'] = netAmt;
    data['close'] = close;

    data['prdType'] = prdType;
    data['baseSym'] = baseSym;
    data['buyAvgPrice'] = buyAvgPrice;
    data['isFno'] = isFno.toString();
    data['cfSellAvgPrice'] = cfSellAvgPrice;
    data['dispSym'] = dispSym;
    data['cfSellAmt'] = cfSellAmt;
    data['netQty'] = netQty;
    data['cfBuyAvgPrice'] = cfBuyAvgPrice;
    data['dayBuyAvgPrice'] = dayBuyAvgPrice;
    data['daySellAvgPrice'] = daySellAvgPrice;
    data['lotSize'] = lotSize;
    data['ltp'] = ltp;
    data['prevPos'] = prevPos;
    data['currPos'] = currPos;
    data['prevAvgPrice'] = prevAvgPrice;
    data['netPnl'] = netPnl;
    data['sellQty'] = sellQty;
    data['cfSellQty'] = cfSellQty;
    data['pnlPerc'] = pnlPerc;
    data['buyQty'] = buyQty;
    data['bookedPnl'] = bookedPnl;
    data['currAvgPrice'] = currAvgPrice;
    data['sellAmt'] = sellAmt;
    data['unRealizedPnl'] = unRealizedPnl;
    data['cfBuyAmt'] = cfBuyAmt;
    data['isSquareoff'] = isSquareoff;
    return data;
  }
}
