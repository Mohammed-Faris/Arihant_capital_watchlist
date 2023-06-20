import 'package:acml/src/data/store/app_utils.dart';

import '../../constants/app_constants.dart';
import '../sort_filter/sort_filter_model.dart';
import 'sym_model.dart';

class Symbols {
  String? dispSym;
  Sym? sym;
  String? baseSym;
  bool? hasFutOpt;
  String? companyName;
  String? ltp;
  String? chng;
  String? chngPer;
  String? high;
  String? low;
  String? qty;
  String? lTradedTime;
  String? vol;
  String? atp;
  String? open;
  String? close;
  String? lcl;
  String? ucl;
  String? ylow;
  String? yhigh;
  String? excToken;
  String? pledgedQty;
  String? freeQty;
  String? lstTradeDte;

  String? openInterest;
  String? oiChangePer;
  List<FilterModel>? selectedFilter;
  SortModel? selectedSort;
  //Holdings
  String? avgPrice;
  String? marketValue;
  String? usedQty;
  String? pnlPerc;
  String? unRealizedPnl;
  String? invested;
  String? dayspnl;
  bool? isPrevClose;
  String? porfolioPercent;
  String? overallReturn;
  String? totalInvested;
  String? overallPnL;
  String? overallPnLPercent;
  String? mktValue;
  String? mktValueChng;
  String? oneDayPnL;
  String? expiryDate;
  String? ltd;

  String? oneDayPnLPercent;
  String? mktValuecurrentVal;
  String? investedVal;
  String? btst;
  bool isFno = false;
  //marketdepth Qty percent
  String? bidQtyPercent;
  String? askQtyPercent;
  bool? isBond = false;

  bool isChecked = false;
  bool isDeleted = false;

  //peer ratio
  String? ord;
  String? pB;
  String? mcap;
  String? pE;
  String? cE;
  String? dE;
  String? isin;
  String? roPer;
  String? roCost;

  String? netProftPerChnge;

  Symbols(
      {this.dispSym,
      this.sym,
      this.baseSym,
      this.hasFutOpt,
      this.companyName,
      this.ltp,
      this.chng,
      this.chngPer,
      this.qty,
      this.high,
      this.low,
      this.lTradedTime,
      this.vol,
      this.atp,
      this.open,
      this.close,
      this.lcl,
      this.ucl,
      this.ylow,
      this.yhigh,
      this.openInterest,
      this.oiChangePer,
      this.avgPrice,
      this.marketValue,
      this.usedQty,
      this.pnlPerc,
      this.unRealizedPnl,
      this.invested,
      this.ord,
      this.pB,
      this.mcap,
      this.pE,
      this.cE,
      this.dE,
      this.isin,
      this.roCost,
      this.roPer,
      this.netProftPerChnge,
      this.excToken,
      this.btst,
      this.isBond});

  Symbols.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

  void fromJson(Map<String, dynamic> json) {
    dispSym = json['dispSym'];
    sym = (json['sym'] != null ? Sym.fromJson(json['sym']) : null);
    baseSym = json['baseSym'];
    hasFutOpt = json['hasFutOpt'];
    lstTradeDte = json['lstTradeDte'];
    companyName = json['companyName'];
    ltp = json['ltp'];
    chng = json['chng'];
    chngPer = json['chngPer'];
    high = json['high'];
    low = json['low'];
    isFno = (json['isFno'] == "true");
    qty = json['qty'];
    lTradedTime = json['lTradedTime'];
    vol = json['vol'];
    atp = json['atp'];
    open = json['open'];
    mktValue = json['marketValue'];
    close = json['close'];
    lcl = json['lcl'];
    pledgedQty = json['pledgeQty'];
    freeQty = json['freeQty'];
    ucl = json['ucl'];
    roPer = json['roPer'];
    roCost = json['roCost'];

    ylow = json['ylow'];
    yhigh = json['yhigh'];
    openInterest = json['openInterest'];
    oiChangePer = json['oiChangePer'];
    avgPrice = json['avgPrice'];
    marketValue = json['marketValue'];
    usedQty = json['usedQty'];
    pnlPerc = json['pnlPerc'];
    unRealizedPnl = json['unRealizedPnl'];
    invested = json['invested'];
    ord = json['ord'];
    pB = json['P/B'];
    mcap = json['mcap'];
    pE = json['P/E'];
    cE = json['C/E'];
    dE = json['D/E'];
    isin = json['isin'];
    netProftPerChnge = json['netProftPerChnge'];
    excToken = json['excToken'];
    btst = json['btst'];
    if (AppUtils().getsymbolTypeFromSym(sym) == AppConstants.fno) {
      isFno = true;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dispSym'] = dispSym;
    data['sym'] = sym!.toJson();
    data['baseSym'] = baseSym;
    data['hasFutOpt'] = hasFutOpt;
    data['companyName'] = companyName;
    data['ltp'] = ltp;
    data['chng'] = chng;
    data['chngPer'] = chngPer;
    data['high'] = high;
    data['low'] = low;
    data['qty'] = qty;
    data['lTradedTime'] = lTradedTime;
    data['vol'] = vol;
    data['atp'] = atp;
    data['lstTradeDte'] = lstTradeDte;

    data['open'] = open;
    data['close'] = close;
    data['lcl'] = lcl;
    data['ucl'] = ucl;
    data['ylow'] = ylow;
    data['isFno'] = isFno.toString();
    data['yhigh'] = yhigh;
    data['openInterest'] = openInterest;
    data['oiChangePer'] = oiChangePer;
    data['avgPrice'] = avgPrice;
    data['marketValue'] = marketValue;
    data['pledgeQty'] = pledgedQty;
    data['freeQty'] = freeQty;

    data['usedQty'] = usedQty;

    data['pnlPerc'] = pnlPerc;
    data['unRealizedPnl'] = unRealizedPnl;
    data['invested'] = invested;
    data['ord'] = ord;
    data['pB'] = pB;
    data['mcap'] = mcap;
    data['pE'] = pE;
    data['cE'] = cE;
    data['dE'] = dE;
    data['isin'] = isin;
    data['netProftPerChnge'] = netProftPerChnge;
    data['excToken'] = excToken;
    data['roPer'] = roPer;
    data['roCost'] = roCost;

    data['btst'] = btst;
    return data;
  }

  Symbols.copyModel(Symbols symbolModel) {
    copyModel(symbolModel);
  }

  copyModel(Symbols symbolModel) {
    chngPer = symbolModel.chngPer;
    dispSym = symbolModel.dispSym;
    baseSym = symbolModel.baseSym;
    sym = symbolModel.sym;
    companyName = symbolModel.companyName;
    ltp = symbolModel.ltp;
    chng = symbolModel.chng;
    hasFutOpt = symbolModel.hasFutOpt;
    high = symbolModel.high;
    low = symbolModel.low;
    isFno = symbolModel.isFno;
    qty = symbolModel.qty;
    lTradedTime = symbolModel.lTradedTime;
    vol = symbolModel.vol;
    atp = symbolModel.atp;
    open = symbolModel.open;
    close = symbolModel.close;
    lcl = symbolModel.lcl;
    ucl = symbolModel.ucl;
    ylow = symbolModel.ylow;
    yhigh = symbolModel.yhigh;
    openInterest = symbolModel.openInterest;
    oiChangePer = symbolModel.oiChangePer;
    excToken = symbolModel.excToken;
  }
}
