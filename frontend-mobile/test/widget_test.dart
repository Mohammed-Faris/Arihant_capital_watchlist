// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';
import 'dart:developer';

import 'package:acml/main_qa.dart';
import 'package:acml/src/blocs/login/login_bloc.dart';
import 'package:acml/src/data/api_services_urls.dart';
import 'package:acml/src/data/repository/login/login_repository.dart';
import 'package:acml/src/data/repository/order/order_repository.dart';
import 'package:acml/src/data/repository/order_pad/order_pad_repository.dart';
import 'package:acml/src/models/login/trading_login_model.dart';
import 'package:acml/src/models/order_pad/order_pad_place_order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/lib_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setConfig();
  LibStore().setAppID("4e1ae98e3159023f9e625a35baf3ce9a");

  test("Testing Web Socket", () async {
    LoginSubmitEvent event =
        LoginSubmitEvent('uid', 'TEST011', "Akash@99", "enterPin");
    BaseRequest request = BaseRequest();

    request.addToData('uid', event.enteredUidValue);
    request.addToData('pwd', event.password);
    final TradingLoginModel tradingLoginModel =
        await LoginRepository().sendLoginRequest(request);

    log(tradingLoginModel.data.toString());

    String sessionId = tradingLoginModel.data["userSessionId"];
    final HTTPClient httpClient = HTTPClient();
    request = BaseRequest();
    request.addToData('user', event.enteredUidValue);
    request.addToData('token', sessionId);
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.ordersocketUrl,
        data: request.getRequest(),
        isEncryption: false);
    log(resp.toString());
    request = BaseRequest();
    request.addToData('user', event.enteredUidValue);
    request.addToData('token', sessionId);

    final Map<String, dynamic> respOrderUpdate =
        await httpClient.postJSONRequest(
      url: ApiServicesUrls.orderUpdateUrl,
      isEncryption: false,
      data: request.getRequest(),
    );

    log(respOrderUpdate.toString());
    await OrderRepository().getOrderBookRequest(request);

    Timer.periodic(const Duration(seconds: 3), (timer) async {
      request = BaseRequest(data: {
        "sym": {
          "exc": "NSE",
          "streamSym": "11536_NSE",
          "instrument": "STK",
          "id": "STK_TCS_EQ_NSE",
          "asset": "equity",
          "excToken": "11536",
          "otherExch": ["BSE"],
          "expiry": null,
          "optionType": null,
          "lotSize": "1",
          "strike": null,
          "baseSym": "TCS",
          "tickSize": "0.05",
          "multiplier": "1",
          "series": "EQ",
          "dispSym": null
        },
        "prdType": "DELIVERY",
        "ordType": "MARKET",
        "triggerPrice": "",
        "requiredMarigin": "3375.00",
        "isAmo": false,
        "qty": "1",
        "disQty": "0",
        "ordDuration": "DAY",
        "ordAction": "BUY",
        "ltp": "3375.00",
        "currentDateTime": ""
      });
      OrderPadPlaceOrderModel orderPadPlaceOrderModel =
          await OrderPadRepository().placeOrderRequest(request);
      log(orderPadPlaceOrderModel.data.toString());

      request = BaseRequest();
      request.addToData('user', event.enteredUidValue);
      request.addToData('token', sessionId);

      final Map<String, dynamic> respOrderUpdate =
          await httpClient.postJSONRequest(
        url: ApiServicesUrls.orderUpdateUrl,
        isEncryption: false,
        data: request.getRequest(),
      );

      log(respOrderUpdate.toString());
    });
    await Future.delayed(const Duration(seconds: 100));
  });
}
