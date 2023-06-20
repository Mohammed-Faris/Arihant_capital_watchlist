import 'dart:async';
import 'dart:io';
import 'package:acml/src/ui/screens/base/base_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:msil_library/utils/config/errorMsgConfig.dart';

import '../../constants/keys/login_keys.dart';
import '../../data/store/app_store.dart';
import '../../data/utility/invalid_session_validator.dart';
import '../../localization/app_localization.dart';
import '../navigation/screen_routes.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import '../theme/light_theme.dart';
import '../widgets/custom_text_widget.dart';
import '../widgets/gradient_button_widget.dart';
import '../widgets/loader_widget.dart';
import 'acml_app.dart';
import 'login/support.dart';

final ValueNotifier<bool> checkingConnectivity = ValueNotifier<bool>(false);

Future? _dialog;
onNoInternet() async {
  NoInternetConnection.isNoInternet = true;

  _checkAndShowDialog();
}

final MyConnectivity connectivity = MyConnectivity.instance;

_checkAndShowDialog() async {
  if (NoInternetConnection.isNoInternet) {
    if (_dialog == null &&
        AppStore.currentRoute != ScreenRoutes.positionScreen &&
        AppStore.currentRoute != ScreenRoutes.holdingsScreen &&
        AppStore.currentRoute != ScreenRoutes.watchlistScreen &&
        AppStore.currentRoute != ScreenRoutes.myfundsScreen &&
        AppStore.currentRoute != ScreenRoutes.myAccount &&
        AppStore.currentRoute != ScreenRoutes.marketsTopPullDownIndicesScreen &&
        AppStore.currentRoute != ScreenRoutes.initConfig) {
      _dialog = showAlertNOINTERNET(
        AppLocalizations().noInternetConnnection,
        callBack: () {
          connectivity.initialise();
        },
      );
    }
    showToastFixed(
        message: ErrorMsgConfig.not_able_to_resolve_service,
        isError: true,
        color: noInternetColor,
        secondsToShowToast: 6);
    await _dialog;
    _dialog = null;
  } else {
    scaffoldkey.currentState?.clearSnackBars();

    if (navigatorKey.currentContext != null &&
        !NoInternetConnection.isNoInternet) {
      if (AppStore.currentRoute == ScreenRoutes.initConfig &&
          NoInternetConnection.isNoInternet !=
              NoInternetConnection.previsNoInternet) {
        navigatorKey.currentState?.pushReplacementNamed(
          ScreenRoutes.initConfig,
        );
      }
      if (_dialog != null && Navigator.canPop(navigatorKey.currentContext!)) {
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
      }
    }
  }
  NoInternetConnection.previsNoInternet = NoInternetConnection.isNoInternet;
}

onConnectedtoNet() async {
  NoInternetConnection.isNoInternet = false;
  _checkAndShowDialog();
}

Future<dynamic> onConnectionResult(bool result) async {
  if (result) {
    onConnectedtoNet();
  } else {
    onNoInternet();
  }
}

Future<Widget?> showAlertNOINTERNET(String message,
    {Function? callBack,
    bool showOkay = true,
    bool disableBack = false,
    Key? noInternet,
    bool isLight = false}) async {
  if (navigatorKey.currentContext == null) {
    return await null;
  } else {
    return await showModalBottomSheet(
      isScrollControlled: true,
      context: navigatorKey.currentContext!,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.w),
      ),
      enableDrag: false,
      builder: (BuildContext bct) {
        return WillPopScope(
          key: noInternet,
          onWillPop: () async => false,
          child: Container(
            width: AppWidgetSize.screenWidth(navigatorKey.currentContext!),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(navigatorKey.currentContext!).primaryColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(20.w),
              ),
            ),
            child: SafeArea(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 32.w, horizontal: 32.w),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  message,
                                  style: Theme.of(navigatorKey.currentContext!)
                                      .textTheme
                                      .displaySmall,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /*  if (MediaQuery.of(navigatorKey.currentContext!)
                                        .orientation !=
                                    Orientation.landscape) */
                              Container(
                                width: AppWidgetSize.dimen_250,
                                padding: EdgeInsets.only(
                                    top: AppWidgetSize.dimen_20),
                                child: AppImages.networkIssueImage(),
                              ),
                              Padding(
                                padding: EdgeInsets.all(AppWidgetSize.dimen_10),
                                child: CustomTextWidget(
                                  AppLocalizations().networkError,
                                  Theme.of(navigatorKey.currentContext!)
                                      .textTheme
                                      .headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: checkingConnectivity,
                            builder: (context, value, _) {
                              return Center(
                                child: value
                                    ? const LoaderWidget()
                                    : gradientButtonWidget(
                                        onTap: () async {
                                          checkingConnectivity.value = true;
                                          try {
                                            await Future.delayed(
                                                const Duration(seconds: 1));
                                            final result =
                                                await InternetAddress.lookup(
                                                    'google.com');
                                            if (result.isNotEmpty &&
                                                result[0]
                                                    .rawAddress
                                                    .isNotEmpty) {
                                              if (callBack != null) {
                                                callBack();
                                              }
                                            }
                                          } on SocketException catch (_) {
                                            checkingConnectivity.value = false;
                                          }

                                          Future.delayed(
                                              const Duration(seconds: 1), () {
                                            checkingConnectivity.value = false;
                                          });
                                        },
                                        bottom: 0,
                                        key: const Key(retryKey),
                                        width: 120.w,
                                        context: context,
                                        title: AppLocalizations().retry,
                                        isGradient: true,
                                      ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SupportAndCallBottom(
                      isForInternetPop: true,
                    )
                  ],
                ),
              ],
            )),
          ),
        );
      },
    );
  }
}

class MyConnectivity {
  MyConnectivity._();

  static final _instance = MyConnectivity._();
  static MyConnectivity get instance => _instance;
  final _connectivity = Connectivity();
  final _controller = StreamController.broadcast();
  Stream get myStream => _controller.stream;

  void initialise() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    _checkStatus(result);
    _connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add(isOnline);
  }

  void disposeStream() => _controller.close();
}
