import 'package:acml/src/models/order_pad/orderpad_ui_json_updated.dart';

class OrderPadUIModel {
  Exchange? nSE;
  Exchange? bSE;
  Exchange? nFO;
  Exchange? bFO;
  Exchange? cDS;
  Exchange? mCX;

  Map<String, Exchange>? tradeData;

  OrderPadUIModel({this.nSE, this.bSE, this.nFO, this.bFO, this.cDS, this.mCX});

  OrderPadUIModel.fromJson() {
    nSE = json['NSE'] != null ? Exchange.fromJson(json['NSE']!) : null;
    bSE = json['BSE'] != null ? Exchange.fromJson(json['BSE']!) : null;
    nFO = json['NFO'] != null ? Exchange.fromJson(json['NFO']!) : null;
    bFO = json['BFO'] != null ? Exchange.fromJson(json['BFO']!) : null;
    cDS = json['CDS'] != null ? Exchange.fromJson(json['CDS']!) : null;
    mCX = json['MCX'] != null ? Exchange.fromJson(json['MCX']!) : null;
    tradeData = {
      'NSE': nSE!,
      'BSE': bSE!,
      'NFO': nFO!,
      'BFO': bFO!,
      'CDS': cDS!,
      'MCX': mCX!,
    };
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (nSE != null) {
      data['NSE'] = nSE!.toJson();
    }
    if (bSE != null) {
      data['BSE'] = bSE!.toJson();
    }
    if (nFO != null) {
      data['NFO'] = nFO!.toJson();
    }
    if (bFO != null) {
      data['BFO'] = bFO!.toJson();
    }
    if (cDS != null) {
      data['CDS'] = cDS!.toJson();
    }
    if (mCX != null) {
      data['MCX'] = mCX!.toJson();
    }
    return data;
  }

  Exchange? getKeyValue(String exchangeKey) {
    return tradeData![exchangeKey];
  }
}

class Exchange {
  List<String>? instrument;
  List<String>? productTypes;
  ProductType? invest;
  ProductType? trade;
  ProductType? cover;
  ProductType? bracket;
  ProductType? gtd;

  Map<String, ProductType>? exchangeData;

  Exchange(
      {this.instrument,
      this.productTypes,
      this.invest,
      this.trade,
      this.cover,
      this.gtd,
      this.bracket});

  Exchange.fromJson(Map<String, dynamic> json) {
    instrument = json['instrument'].cast<String>();
    productTypes = json['productTypes'].cast<String>();
    invest =
        json['Invest'] != null ? ProductType.fromJson(json['Invest']) : null;
    trade = json['Trade'] != null ? ProductType.fromJson(json['Trade']) : null;
    cover = json['Cover'] != null ? ProductType.fromJson(json['Cover']) : null;
    bracket =
        json['Bracket'] != null ? ProductType.fromJson(json['Bracket']) : null;
    gtd = json['GTD'] != null ? ProductType.fromJson(json['GTD']) : null;
    exchangeData = {
      'Invest': invest ?? ProductType(),
      'Trade': trade ?? ProductType(),
      'Cover': cover ?? ProductType(),
      'Bracket': bracket ?? ProductType(),
      'GTD': gtd ?? ProductType(),
    };
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instrument'] = instrument;
    data['productTypes'] = productTypes;
    if (invest != null) {
      data['Invest'] = invest!.toJson();
    }
    if (trade != null) {
      data['Trade'] = trade!.toJson();
    }
    if (cover != null) {
      data['Cover'] = cover!.toJson();
    }
    if (bracket != null) {
      data['Bracket'] = bracket!.toJson();
    }
    if (gtd != null) {
      data['GTD'] = gtd!.toJson();
    }
    return data;
  }

  ProductType? getKeyValue(String productTypeKey) {
    return exchangeData![productTypeKey];
  }
}

class ProductType {
  List<String>? orderTypes;
  OrderType? market;
  OrderType? limit;
  OrderType? sL;
  OrderType? sLM;

  Map<String, OrderType>? productTypeData;

  ProductType({this.orderTypes, this.market, this.limit, this.sL, this.sLM});

  ProductType.fromJson(Map<String, dynamic> json) {
    orderTypes = json['orderTypes'].cast<String>();
    market = json['Market'] != null ? OrderType.fromJson(json['Market']) : null;
    limit = json['Limit'] != null ? OrderType.fromJson(json['Limit']) : null;
    sL = json['SL'] != null ? OrderType.fromJson(json['SL']) : null;
    sLM = json['SL-M'] != null ? OrderType.fromJson(json['SL-M']) : null;
    productTypeData = {
      'Limit': limit ?? OrderType(),
      'Market': market ?? OrderType(),
      'SL': sL ?? OrderType(),
      'SL-M': sLM ?? OrderType(),
    };
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderTypes'] = orderTypes;
    if (market != null) {
      data['Market'] = market!.toJson();
    }
    if (limit != null) {
      data['Limit'] = limit!.toJson();
    }
    if (sL != null) {
      data['SL'] = sL!.toJson();
    }
    if (sLM != null) {
      data['SL-M'] = sLM!.toJson();
    }
    return data;
  }

  OrderType getKeyValue(String orderTypeKey) {
    return productTypeData![orderTypeKey]!;
  }
}

class OrderType {
  bool? qty;
  bool? mktPrice;
  bool? price;
  bool? customPrice;
  bool? triggerPrice;
  bool? stopLossTrigger;
  bool? stopLossPrice;
  bool? targetPrice;
  bool? trailingStopLoss;
  List<String>? validity;
  bool? amo;
  bool? disQty;

  OrderType(
      {this.qty,
      this.mktPrice,
      this.price,
      this.customPrice,
      this.triggerPrice,
      this.stopLossTrigger,
      this.stopLossPrice,
      this.targetPrice,
      this.trailingStopLoss,
      this.validity,
      this.amo,
      this.disQty});

  OrderType.fromJson(Map<String, dynamic> json) {
    qty = json['qty'];
    mktPrice = json['mktPrice'];
    price = json['price'];
    customPrice = json['customPrice'];
    triggerPrice = json['triggerPrice'];
    stopLossTrigger = json['stopLossTrigger'];
    stopLossPrice = json['stopLossPrice'];
    targetPrice = json['targetPrice'];
    trailingStopLoss = json['trailingStopLoss'];
    validity = json['validity'].cast<String>();
    amo = json['Amo'];
    disQty = json['disQty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['qty'] = qty;
    data['mktPrice'] = mktPrice;
    data['price'] = price;
    data['customPrice'] = customPrice;
    data['triggerPrice'] = triggerPrice;
    data['stopLossTrigger'] = stopLossTrigger;
    data['stopLossPrice'] = stopLossPrice;
    data['targetPrice'] = targetPrice;
    data['trailingStopLoss'] = trailingStopLoss;
    data['validity'] = validity;
    data['Amo'] = amo;
    data['disQty'] = disQty;
    return data;
  }
}
