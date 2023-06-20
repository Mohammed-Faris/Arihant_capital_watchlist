//json created using order matix and UI to rerender UI based on user selection
import 'package:acml/src/config/app_config.dart';

Map<String, Map<String, dynamic>> json = {
  "NSE": {
    "instrument": [
      "STK",
      "ETF",
    ],
    "productTypes": [
      "Regular",
      if (Featureflag.gTD) "GTD",
      if (Featureflag.coverOder) "Cover",
      if (Featureflag.bracketOder) "Bracket",
    ],
    "Invest": investJson,
    "Trade": tradeJson,
    "Cover": coverOrderjson,
    "Bracket": bracketOrderJson,
    "GTD": gtdOrderJson,
  },
  "BSE": {
    "instrument": [
      "STK",
      "ETF",
    ],
    "productTypes": [
      "Regular",
      if (Featureflag.gTD) "GTD",
      if (Featureflag.coverOder) "Cover",
      if (Featureflag.bracketOder) "Bracket",
    ],
    "Invest": investJson,
    "Trade": tradeJson,
    "Cover": coverOrderjson,
    "Bracket": bracketOrderJson,
    "GTD": gtdOrderJson,
  },
  "NFO": {
    "instrument": [
      "FUTSTK",
      "OPTSTK",
      "FUTIDX",
      "OPTIDX",
    ],
    "productTypes": [
      "Regular",
      if (Featureflag.gTD) "GTD",
      if (Featureflag.coverOder) "Cover",
      if (Featureflag.bracketOder) "Bracket",
    ],
    "Invest": investJson,
    "Trade": tradeJson,
    "Cover": coverOrderjson,
    "Bracket": bracketOrderJson,
    "GTD": gtdOrderJson,
  },
  "BFO": {
    "instrument": [
      "FUTSTK",
      "OPTSTK",
      "FUTIDX",
      "OPTIDX",
    ],
    "productTypes": [
      "Regular",
      if (Featureflag.gTD) "GTD",
      if (Featureflag.coverOder) "Cover",
      if (Featureflag.bracketOder) "Bracket",
    ],
    "Invest": investJson,
    "Trade": tradeJson,
    "Cover": coverOrderjson,
    "Bracket": bracketOrderJson,
  },
  "CDS": {
    "instrument": [
      "FUTCUR",
      "OPTCUR",
    ],
    "productTypes": [
      "Regular",
      if (Featureflag.coverOder && Featureflag.cdsCo) "Cover",
      if (Featureflag.bracketOder && Featureflag.cdsBo) "Bracket",
    ],
    "Invest": investJson,
    "Trade": tradeJson,
    "Cover": coverOrderjson,
    "Bracket": bracketOrderJson,
  },
  "MCX": {
    "instrument": [
      "FUTCOM",
      "OPTCOM",
    ],
    "productTypes": [
      "Regular",
      if (Featureflag.mcxGtd && Featureflag.gTD) "GTD",
      if (Featureflag.bracketOder && Featureflag.mcxBo) "Bracket",
    ],
    "Invest": investJson,
    "Trade": tradeJson,
    "Cover": coverOrderjson,
    "Bracket": bracketOrderJson,
    "GTD": gtdOrderJson
  }
};
Map<String, dynamic> investJson = {
  "orderTypes": [
    "Market",
    "Limit",
    "SL",
    "SL-M",
  ],
  "Market": {
    "qty": true,
    "customPrice": false,
    "triggerPrice": false,
    "stopLossTrigger": false,
    "stopLossPrice": false,
    "targetPrice": false,
    "trailingStopLoss": false,
    "validity": [
      "DAY",
      "IOC",
    ],
    "Amo": true,
    "disQty": true,
  },
  "Limit": {
    "qty": true,
    "customPrice": true,
    "triggerPrice": false,
    "stopLossTrigger": false,
    "stopLossPrice": false,
    "targetPrice": false,
    "trailingStopLoss": false,
    "validity": [
      "DAY",
      "IOC",
    ],
    "Amo": true,
    "disQty": true,
  },
  "SL": {
    "qty": true,
    "customPrice": true,
    "triggerPrice": true,
    "stopLossTrigger": false,
    "stopLossPrice": false,
    "targetPrice": false,
    "trailingStopLoss": false,
    "validity": [
      "DAY",
    ],
    "Amo": true,
    "disQty": true,
  },
  "SL-M": {
    "qty": true,
    "customPrice": false,
    "triggerPrice": true,
    "stopLossTrigger": false,
    "stopLossPrice": false,
    "targetPrice": false,
    "trailingStopLoss": false,
    "validity": [
      "DAY",
    ],
    "Amo": true,
    "disQty": true,
  },
};
Map<String, dynamic> tradeJson = {
  "orderTypes": [
    "Market",
    "Limit",
    "SL",
    "SL-M",
  ],
  "Market": {
    "qty": true,
    "customPrice": false,
    "triggerPrice": false,
    "stopLossTrigger": false,
    "stopLossPrice": false,
    "targetPrice": false,
    "trailingStopLoss": false,
    "validity": [
      "DAY",
      "IOC",
    ],
    "Amo": true,
    "disQty": true,
  },
  "Limit": {
    "qty": true,
    "customPrice": true,
    "triggerPrice": false,
    "stopLossTrigger": false,
    "stopLossPrice": false,
    "targetPrice": false,
    "trailingStopLoss": false,
    "validity": [
      "DAY",
      "IOC",
    ],
    "Amo": true,
    "disQty": true,
  },
  "SL": {
    "qty": true,
    "customPrice": true,
    "triggerPrice": true,
    "stopLossTrigger": false,
    "stopLossPrice": false,
    "targetPrice": false,
    "trailingStopLoss": false,
    "validity": [
      "DAY",
    ],
    "Amo": true,
    "disQty": true,
  },
  "SL-M": {
    "qty": true,
    "customPrice": false,
    "triggerPrice": true,
    "stopLossTrigger": false,
    "stopLossPrice": false,
    "targetPrice": false,
    "trailingStopLoss": false,
    "validity": [
      "DAY",
    ],
    "Amo": true,
    "disQty": true,
  },
};
Map<String, dynamic> coverOrderjson = {
  "orderTypes": [
    "Market",
    "Limit",
  ],
  "Market": {
    "qty": true,
    "customPrice": false,
    "triggerPrice": false,
    "stopLossTrigger": true,
    "stopLossPrice": false,
    "targetPrice": false,
    "trailingStopLoss": false,
    "validity": [
      "DAY",
    ],
    "Amo": false,
    "disQty": false,
  },
  "Limit": {
    "qty": true,
    "customPrice": true,
    "triggerPrice": false,
    "stopLossTrigger": true,
    "stopLossPrice": false,
    "targetPrice": false,
    "trailingStopLoss": false,
    "validity": [
      "DAY",
    ],
    "Amo": false,
    "disQty": false,
  },
};
Map<String, dynamic> bracketOrderJson = {
  "orderTypes": [
    "Limit",
    "SL",
  ],
  "Limit": {
    "qty": true,
    "customPrice": true,
    "triggerPrice": false,
    "stopLossTrigger": false,
    "stopLossPrice": true,
    "targetPrice": true,
    "trailingStopLoss": true,
    "validity": [
      "DAY",
    ],
    "Amo": false,
    "disQty": false,
  },
  "SL": {
    "qty": true,
    "customPrice": true,
    "triggerPrice": true,
    "stopLossTrigger": false,
    "stopLossPrice": true,
    "targetPrice": true,
    "trailingStopLoss": true,
    "validity": [
      "DAY",
    ],
    "Amo": false,
    "disQty": false,
  },
};
Map<String, dynamic> gtdOrderJson = {
  "orderTypes": [
    "Limit",
    "SL",
  ],
  "Limit": {
    "qty": true,
    "customPrice": true,
    "triggerPrice": false,
    "stopLossTrigger": false,
    "stopLossPrice": false,
    "targetPrice": false,
    "trailingStopLoss": false,
    "validity": [
      "GTD",
    ],
    "Amo": true,
    "disQty": false,
  },
  "SL": {
    "qty": true,
    "customPrice": true,
    "triggerPrice": true,
    "stopLossTrigger": false,
    "stopLossPrice": false,
    "targetPrice": false,
    "trailingStopLoss": false,
    "validity": [
      "GTD",
    ],
    "Amo": true,
    "disQty": false,
  },
};
