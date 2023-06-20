import 'dart:convert';
import 'dart:io';
import 'package:acml/src/ui/screens/acml_app.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/config/httpclient_config.dart';
import 'package:msil_library/utils/lib_store.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../blocs/common/screen_state.dart';
import '../../config/app_config.dart';
import '../../constants/app_constants.dart';
import '../../data/api_services_urls.dart';
import '../../data/store/app_store.dart';
import '../../data/store/app_utils.dart';
import '../../localization/app_localization.dart';
import '../screens/base/base_screen.dart';
import '../styles/app_widget_size.dart';
import 'loader_widget.dart';
// ignore: depend_on_referenced_packages

class ChartWebviewWidgetArguments {
  final Map<String, dynamic> symbolObject;
  final String chartView;
  ChartWebviewWidgetArguments(
    this.symbolObject,
    this.chartView,
  );
}

class ChartWebviewWidget extends BaseScreen {
  final ChartWebviewWidgetArguments chartArgs;

  const ChartWebviewWidget(
    Key key,
    this.chartArgs,
  ) : super(key: key);

  @override
  ChartWebviewWidgetState createState() => ChartWebviewWidgetState();
}

class ChartWebviewWidgetState extends BaseAuthScreenState<ChartWebviewWidget> {
  String url = '';
  bool chatStreamEnabled = false;
  final ValueNotifier<bool> webviewLoaded = ValueNotifier<bool>(false);
  late final WebViewController controller;

  @override
  void initState() {
    final Map<String, dynamic> symbolObject = widget.chartArgs.symbolObject;
    url = _frameURL(symbolObject);

    // ignore: no_leading_underscores_for_local_identifiers
    final WebViewController _controller = WebViewController();
    // #enddocregion platform_features
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
          Theme.of(navigatorKey.currentContext!).scaffoldBackgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              Future.delayed(const Duration(milliseconds: 500), () {
                webviewLoaded.value = true;
              });
            } else {
              webviewLoaded.value = false;
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..enableZoom(true)
      ..addJavaScriptChannel(
        'tradingView',
        onMessageReceived: _onMessageReceived,
      )
      ..loadRequest(Uri.parse(url));
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(true);
    }
    controller = _controller;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: webviewLoaded,
        builder: (context, value, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              chartWebView(context),
              if (!value)
                Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: AppWidgetSize.screenWidth(context),
                    height: AppWidgetSize.screenHeight(context),
                    child: const LoaderWidget()),
            ],
          );
        });
  }

  chartWebView(BuildContext context) {
    return WebViewWidget(
      key: const Key('chatWebView'),
      controller: controller,
      gestureRecognizers: {Factory(() => EagerGestureRecognizer())},
    );
  }

  void _onMessageReceived(JavaScriptMessage msg) {
    if (msg.message.isNotEmpty) {
      final Map messageDecode = json.decode(msg.message);
      if (messageDecode['id'] == 'startStream') {
        enableChartStream();
      } else if (messageDecode['id'] == 'invalidSession') {
        if (isScreenActive()) {
          final ScreenState screenState = ScreenState()
            ..errorMsg = AppLocalizations().invalidUid
            ..errorCode = AppConstants.invalidSessionErrorCode
            ..isInvalidException = true;
          handleError(screenState);
        }
      }
    }
  }

  void enableChartStream() {
    chatStreamEnabled = true;
  }

  String _frameURL(Map<String, dynamic> symbolObject,
      {String orientation = ''}) {
    final Map<String, dynamic> data =
        _frameData(symbolObject, orientation: orientation);

    final String encodedData = Uri.encodeComponent('data=${json.encode(data)}');
    String chartUrl = AppConfig.chartUrl;
    url = '$chartUrl?$encodedData';
    return url;
  }

  Map<String, dynamic> _frameData(Map<String, dynamic> symbolObject,
      {String orientation = ''}) {
    String? session = AppStore().getJSESSIONID();
    session = session!.replaceAll(' ', '');
    final Map<String, dynamic> data = <String, dynamic>{
      'appID': AppStore().getAppID(),
      'sessionID': session,
      'view': widget.chartArgs.chartView,
      'deviceType': 'mobile',
      'userMode': 'TRADING',
      'selectedTheme': AppUtils().isLightTheme() ? 'LIGHT' : 'DARK',
      'symbolObject': symbolObject,
      'encryptionKey': HttpClientConfig.encryptionKey,
      'isEncryptionEnabled': HttpClientConfig.encryptionEnabled,
      'platform': Platform.isAndroid ? 'android' : 'ios',
      'intradayURL': ApiServicesUrls.getIntradayChartUrl,
      'historicalURL': ApiServicesUrls.getHistoryChartUrl,
      'authToken': LibStore()
          .getSessionCookie()!
          .substring(LibStore().getSessionCookie()!.indexOf('Auth-Token') + 11),
    };
    return data;
  }

  void reloadFullChart({String orientation = ''}) {
    var dataobj = _frameData(widget.chartArgs.symbolObject);
    url = _frameURL(dataobj);
    controller.reload();
  }

  void chatIqWebCall(ResponseData quoteOverviewData) {
    if (chatStreamEnabled) {
      final Map<dynamic, dynamic> dataJson = quoteOverviewData.toJson();
      final String encodeData = jsonEncode(dataJson).trim();
      final String data = "sendStreamingDataToChart('$encodeData')";
      controller.runJavaScript(data);
    }
  }
}
