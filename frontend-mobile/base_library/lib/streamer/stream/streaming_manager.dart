import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/config/streamer_config.dart';
import '../../utils/constants/lib_constants.dart';
import '../../utils/lib_store.dart';
import '../models/id_properties_model.dart';
import '../models/quote2_stream_response_model.dart';
import '../models/stream_request_model.dart' as request_model;
import '../models/stream_response_model.dart';
import '../models/streaming_symbol_model.dart';
import 'binary_default_spec.dart';
import 'binary_parser.dart';
import 'json_parser.dart';
import 'socket_controller.dart';

class StreamingManager with WidgetsBindingObserver {
  static StreamingManager? _instance;
  StreamingManager._internal();
  factory StreamingManager() {
    if (_instance == null) {
      _instance = StreamingManager._internal();
      WidgetsBinding.instance.addObserver(_instance!);
    }
    return _instance!;
  }
  bool _snapshot = false;
  String subscribe = StreamRequestType.subscribe;
  String unsubscribe = StreamRequestType.unsubscribe;
  static Map<String, List<StreamingSymbolModel>>? l1SymSubscribers;
  static Map<String, List<IdPropertiesModel>?>? l1SubscribersSym;

  static Map<String, dynamic>? l2SymSubscribers;
  static Map<String, dynamic>? l2SubscribersSym;

  static Map<String, dynamic>? alertSymbols;

  SocketController? socketController;

  request_model.StreamRequestModel requestModel =
      request_model.StreamRequestModel.fromJson({
    'request': <String, dynamic>{
      'streaming_type': 'quote',
      'request_type': 'subscribe',
      'session': LibStore().getSESSIONID(),
      'data': <String, dynamic>{}
    }
  });

  Map pktInfo = {
    'PKT_SPEC': defaultPktINFO['PKT_SPEC'],
    'BID_ASK_OBJ_LEN': defaultPktINFO['BID_ASK_OBJ_LEN']
  };
  BinaryParser? binaryParser;
  JsonParser? jsonParser;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        onSocketInit();
        break;
      case AppLifecycleState.paused:
        onPaused();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  void onSocketInit() {
    socketController?.initSocket();
  }

  void onPaused() {
    socketController?.close();
  }

  void onResumed() {
    resetData();
    if (l1SymSubscribers?.keys.isNotEmpty ?? false) {
      l1SubscribeSymbols();
    }
    if (l2SymSubscribers?.keys.isNotEmpty ?? false) {
      l2SubscribeSymbols();
    }
  }

  Future<void> initConnection() async {
    socketController = socketController ?? SocketController();
    setInitialState();
    if (binaryParser == null) {
      binaryParser = new BinaryParser(onMesageJSONResp);
    }
    if (jsonParser == null) {
      jsonParser = new JsonParser(onMesageJSONResp);
    }
    socketController?.initSocket();
  }

  setInitialState() {
    l1SymSubscribers = <String, List<StreamingSymbolModel>>{};
    l1SubscribersSym = <String, List<IdPropertiesModel>>{};
    l2SymSubscribers = {};
    l2SubscribersSym = {};
    alertSymbols = {};
  }

  void subscribeLevel1(
      IdPropertiesModel idProperties, List<StreamingSymbolModel> symbols,
      {bool forceStreamCall = false}) {
    unsubscribeLevel1(idProperties.screenName);
    bool streamcall = forceStreamCall;
    l1SymSubscribers?[idProperties.screenName] = symbols;
    symbols.forEach((StreamingSymbolModel symbolItem) {
      final String symbol = symbolItem.symbol;
      if (l1SubscribersSym?[symbol] == null) {
        streamcall = true;
      }
      final List<IdPropertiesModel> symbolObject =
          l1SubscribersSym?[symbol] ?? <IdPropertiesModel>[];
      symbolObject.add(idProperties);
      l1SubscribersSym?[symbol] = symbolObject;
      return;
    });
    if (streamcall) {
      l1SubscribeSymbols();
    }
  }

  void forceSubscribeLevel1(
      IdPropertiesModel idProperties, List<StreamingSymbolModel> symbols) {
    subscribeLevel1(idProperties, symbols, forceStreamCall: true);
  }

  void forceSubscribeLevel2(
      IdPropertiesModel idProperties, List<StreamingSymbolModel> symbols) {
    subscribeLevel2(idProperties, symbols, forceStreamCall: true);
  }

  void setSnapshot(bool value) {
    if (value) {
      sendUnsubscribeLevel1();
      sendUnsubscribeLevel2();
    }
    _snapshot = value;
    if (!_snapshot) {
      l1SubscribeSymbols();
      l2SubscribeSymbols();
    }
  }

  void l1SubscribeSymbols() {
    final List<Map<String, dynamic>> symbols = <Map<String, dynamic>>[];
    l1SubscribersSym?.keys.forEach((String streamItem) {
      final Map<String, dynamic> symbolItem = <String, dynamic>{
        'symbol': streamItem
      };
      symbols.add(symbolItem);
      return;
    });
    if (symbols.isNotEmpty) {
      requestModel.request?.streamingType =
          _snapshot ? StreamLevel.L1S : StreamLevel.quote;
      requestModel.request?.requestType = subscribe;
      requestModel.request?.data =
          request_model.Data.fromJson(<String, dynamic>{'symbols': symbols});

      final String packets = (json.encode(requestModel.toJson())) + ' \n';

      socketController?.requestSocket(packets);
    } else {
      sendUnsubscribeLevel1();
    }
  }

  void sendUnsubscribeLevel1() {
    requestModel.request?.streamingType =
        _snapshot ? StreamLevel.L1S : StreamLevel.quote;
    requestModel.request?.requestType = unsubscribe;
    requestModel.request?.data =
        request_model.Data.fromJson(<String, dynamic>{});

    final String packets = (json.encode(requestModel.toJson())) + ' \n';
    socketController?.requestSocket(packets);
  }

  void unsubscribeLevel1(String screenName) {
    bool streamcall = false;
    final List<StreamingSymbolModel>? symbols = l1SymSubscribers?[screenName];
    if (symbols != null) {
      symbols.forEach((StreamingSymbolModel symbolsItem) {
        final String symbol = symbolsItem.symbol;
        final List<IdPropertiesModel>? streamingSymbol =
            l1SubscribersSym?[symbol];
        if (streamingSymbol?.length == 1) {
          streamcall = true;
          l1SubscribersSym?.remove(symbol);
        } else {
          final int indexValue = streamingSymbol?.indexWhere(
                  (dynamic pageItem) => pageItem.screenName == screenName) ??
              -1;
          if (indexValue != -1) {
            streamingSymbol?.removeAt(indexValue);
          }
          l1SubscribersSym?[symbol] = streamingSymbol;
        }
      });
      l1SymSubscribers?.remove(screenName);
      if (streamcall) {
        l1SubscribeSymbols();
      }
    }
  }

  void subscribeLevel2(
      IdPropertiesModel idProperties, List<StreamingSymbolModel> symbols,
      {forceStreamCall = false}) {
    unsubscribeLevel2(idProperties.screenName);
    bool streamcall = forceStreamCall ?? false;
    l2SymSubscribers?[idProperties.screenName] = symbols;
    symbols.forEach((StreamingSymbolModel symbolItem) {
      final String symbol = symbolItem.symbol;
      if (l2SubscribersSym?[symbol] == null) {
        streamcall = true;
      }
      final List<IdPropertiesModel> symbolObject =
          l2SubscribersSym![symbol] ?? <IdPropertiesModel>[];
      symbolObject.add(idProperties);
      l2SubscribersSym?[symbol] = symbolObject;
      return;
    });
    if (streamcall) {
      l2SubscribeSymbols();
    }
  }

  void l2SubscribeSymbols() {
    final List<Map<String, dynamic>> symbols = <Map<String, dynamic>>[];
    l2SubscribersSym?.keys.forEach((String streamItem) {
      final Map<String, dynamic> symbolItem = <String, dynamic>{
        'symbol': streamItem
      };
      symbols.add(symbolItem);
      return;
    });
    if (symbols.isNotEmpty) {
      requestModel.request?.streamingType =
          _snapshot ? StreamLevel.L2S : StreamLevel.quote2;
      requestModel.request?.requestType = subscribe;
      requestModel.request?.data =
          request_model.Data.fromJson(<String, dynamic>{'symbols': symbols});

      final String packets = (json.encode(requestModel.toJson())) + ' \n';
      socketController?.requestSocket(packets);
    } else {
      sendUnsubscribeLevel2();
    }
  }

  void sendUnsubscribeLevel2() {
    requestModel.request?.streamingType =
        _snapshot ? StreamLevel.L2S : StreamLevel.quote2;
    requestModel.request?.requestType = unsubscribe;
    requestModel.request?.data =
        request_model.Data.fromJson(<String, dynamic>{});

    final String packets = (json.encode(requestModel.toJson())) + ' \n';
    socketController?.requestSocket(packets);
  }

  void unsubscribeLevel2(String screenName) {
    bool streamcall = false;
    final List<StreamingSymbolModel>? symbols = l2SymSubscribers?[screenName];
    if (symbols != null) {
      symbols.forEach((StreamingSymbolModel symbolsItem) {
        final String symbol = symbolsItem.symbol;
        final List<IdPropertiesModel> streamingSymbol =
            l2SubscribersSym?[symbol];
        if (streamingSymbol.length == 1) {
          streamcall = true;
          l2SubscribersSym?.remove(symbol);
        } else {
          final int indexValue = streamingSymbol.indexWhere(
              (dynamic pageItem) => pageItem.screenName == screenName);
          if (indexValue != -1) {
            streamingSymbol.removeAt(indexValue);
          }
          l2SubscribersSym?[symbol] = streamingSymbol;
        }
      });
      l2SymSubscribers?.remove(screenName);
      if (streamcall) {
        l2SubscribeSymbols();
      }
    }
  }

  void subscribeAlerts(Map<String, dynamic> requestData) {
    alertSymbols?[requestData['PageName']] =
        alertSymbols?[requestData['details']];
  }

  void unsubscribeAlerts(Map<String, dynamic> requestData) {
    alertSymbols?.remove(<String>[requestData['PageName']]);
  }

  void onMessageRecv(dynamic data) {
    if (StreamerConfig.binaryStream) {
      binaryParser?.setBinaryData(data);
    } else {
      jsonParser?.setJsonData(data);
    }
  }

  void onMesageJSONResp(Map<String, dynamic> decodeResponse) {
    final StreamReponseModel responseData =
        StreamReponseModel.fromJson(decodeResponse);
    final Response? _response = responseData.response;
    List<IdPropertiesModel>? pageDetails;
    if (_response?.streamingType == StreamLevel.quote) {
      pageDetails = l1SubscribersSym?[_response?.data?.symbol];
      if (pageDetails != null) {
        pageDetails.forEach(
          (IdPropertiesModel pageItem) {
            final Function? callBack = pageItem.callBack;
            bool haskey = true;
            if (pageItem.streamingKeys.isNotEmpty) {
              haskey = pageItem.streamingKeys.indexWhere((String keyItem) =>
                      _response?.data?.getKeyValue(keyItem) != null) !=
                  -1;
            }
            if (haskey) {
              callBack!(_response!.data);
            }
          },
        );
      }
    } else if (_response?.streamingType == StreamLevel.quote2) {
      final Quote2StreamReponseModel responseData =
          Quote2StreamReponseModel.fromJson(decodeResponse);
      pageDetails = l2SubscribersSym?[_response?.data?.symbol];

      if (pageDetails != null) {
        pageDetails.forEach((IdPropertiesModel pageItem) {
          final Function? callBack = pageItem.callBack;
          callBack!(responseData.response?.data);
        });
      }
    }
  }

  void setPacketInfo(info) {
    if (info != null) {
      pktInfo['PKT_SPEC'] =
          info['PKT_SPEC'] ? info['PKT_SPEC'] : defaultPktINFO['PKT_SPEC'];
      pktInfo['BID_ASK_OBJ_LEN'] = info['BID_ASK_OBJ_LEN']
          ? info['BID_ASK_OBJ_LEN']
          : defaultPktINFO['BID_ASK_OBJ_LEN'];
    }
  }

  void streamClose() {
    socketController?.close();
    setInitialState();
    resetData();
  }

  void resetData() {
    binaryParser?.resetBinary();
    jsonParser?.resetJsonString();
  }
}
