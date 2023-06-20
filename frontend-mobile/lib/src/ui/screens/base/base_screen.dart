// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

// ignore: unused_import
import 'package:acml/src/data/repository/login/login_repository.dart';
import 'package:acml/src/ui/widgets/custom_text_widget.dart';
import 'package:acml/src/ui/widgets/info_bottomsheet.dart';
// ignore: unused_import
import 'package:collection/collection.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:msil_library/streamer/models/id_properties_model.dart';
import 'package:msil_library/streamer/models/quote2_stream_response_model.dart';
import 'package:msil_library/streamer/models/stream_details_model.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/streamer/models/streaming_symbol_model.dart';
import 'package:msil_library/streamer/stream/streaming_manager.dart';
import 'package:msil_library/utils/config/httpclient_config.dart';

import '../../../blocs/common/screen_state.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/keys/login_keys.dart';
import '../../../constants/storage_constants.dart';
import '../../../data/api_services_urls.dart';
import '../../../data/cache/cache_repository.dart';
import '../../../data/store/app_helper.dart';
import '../../../data/store/app_storage.dart';
import '../../../data/store/app_store.dart';
import '../../../data/store/app_utils.dart';
import '../../../firebase/firebase_analytics_global.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/loader_widget.dart';
import '../acml_app.dart';

enum NAVIGATION {
  pushNamedRemoveUntil,
  pop,
  push,
  pushReplacement,
  popUntil,
  popAndPush
}

Future<void> handleLogout(
  String msg,
  bool isExit,
  isFromMyAccount, {
  bool isInvalidSession = false,
}) async {
  if (isExit) {
    //logout from my account
    AppStore().clearLoginSession();
  }
  CacheRepository().clearCache();

  var getSmartLoginDetails = await AppUtils().getsmartDetails();
  final bool checkPin =
      getSmartLoginDetails != null && (getSmartLoginDetails?['pin'] ?? false);
  final bool checkBiometric = getSmartLoginDetails != null &&
      (getSmartLoginDetails?['biometric'] ?? false);

  if (isExit) {
    await AppUtils().removeCurrentUser(removeData: false);
  }
  if (isInvalidSession) {
    pushAndRemoveUntilNavigation(ScreenRoutes.smartLoginScreen, arguments: {
      'loginPin': true,
    });
  } else if ((checkPin || checkBiometric) && !isExit && !isFromMyAccount) {
    pushAndRemoveUntilNavigation(ScreenRoutes.smartLoginScreen);
  } else if (!isFromMyAccount) {
    pushAndRemoveUntilNavigation(ScreenRoutes.loginScreen);
  }
}

void handleInvalidAppID() {
  AppUtils().clearStorage(type: AppConstants.invalidAppInDErrorCode);
  // AppStore().clearLoginSession();
  pushAndRemoveUntilNavigation(ScreenRoutes.initConfig,
      removeUntilPageName: '');
}

dynamic pageNavigation(
    NAVIGATION type, Map<String, dynamic> pageDetails) async {
  // scaffoldkey.currentState?.clearMaterialBanners();

  // ignore: unnecessary_null_comparison
  final NavigatorState? navigator = navigatorKey.currentState;
  final dynamic arguments = pageDetails['arguments'];
  if (type == NAVIGATION.pop) {
    return navigator?.pop(arguments);
  } else {
    final String pageName = pageDetails['pageName'];
    // ignore: unnecessary_null_comparison
    if (pageName != null && pageName != '') {
      if (type == NAVIGATION.pushNamedRemoveUntil) {
        final dynamic data = await navigator?.pushNamedAndRemoveUntil(
            pageName,
            pageDetails['removeUntilPageName'] != null
                ? ModalRoute.withName(pageDetails['removeUntilPageName'])
                : (Route<dynamic> route) => false,
            arguments: arguments);
        return data;
      } else if (type == NAVIGATION.push) {
        final dynamic data =
            await navigator?.pushNamed(pageName, arguments: arguments);
        return data;
      } else if (type == NAVIGATION.pushReplacement) {
        final dynamic data = await navigator?.pushReplacementNamed(pageName,
            arguments: arguments);
        return data;
      } else if (type == NAVIGATION.popUntil) {
        return navigator?.popUntil(ModalRoute.withName(pageName));
      } else if (type == NAVIGATION.popAndPush) {
        final dynamic data =
            await navigator?.popAndPushNamed(pageName, arguments: arguments);
        return data;
      }
    } else {
      return false;
    }
  }
}

dynamic pushAndRemoveUntilNavigation(String pageName,
    {dynamic arguments, String? removeUntilPageName}) {
  final Map<String, dynamic> pageDetails = <String, dynamic>{
    'pageName': pageName,
    'arguments': arguments,
    'removeUntilPageName': removeUntilPageName
  };
  return pageNavigation(NAVIGATION.pushNamedRemoveUntil, pageDetails);
}

dynamic popAndRemoveUntilNavigation(String pageName,
    {dynamic arguments, String? removeUntilPageName}) {
  final Map<String, dynamic> pageDetails = <String, dynamic>{
    'pageName': pageName,
    'arguments': arguments,
    'removeUntilPageName': removeUntilPageName
  };
  return pageNavigation(NAVIGATION.popUntil, pageDetails);
}

void showNotification(
    {String? message, BuildContext? ctx, int seconds = 5, bool error = false}) {
  Color backgroundcolor = error
      ? Theme.of(ctx ?? navigatorKey.currentContext!).colorScheme.onSecondary
      : Theme.of(ctx ?? navigatorKey.currentContext!)
          .snackBarTheme
          .backgroundColor!;
  ScaffoldMessenger.of(ctx ?? navigatorKey.currentContext!).clearSnackBars();
  ScaffoldMessenger.of(ctx ?? navigatorKey.currentContext!)
      .showSnackBar(SnackBar(
    padding: EdgeInsets.zero,
    backgroundColor:
        Theme.of(navigatorKey.currentContext!).scaffoldBackgroundColor,
    duration: Duration(seconds: seconds),
    content: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 500),
        curve: Curves.bounceOut,
        tween: Tween(begin: 1.0, end: 0.0),
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset((value * 60), 0.0),
            child: Container(child: child),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
              decoration: BoxDecoration(
                  color: backgroundcolor.withOpacity(0.1),
                  border: Border.all(
                      color: backgroundcolor.withOpacity(0.4), width: 1.w),
                  borderRadius: BorderRadius.circular(10.w)),
              width:
                  AppWidgetSize.fullWidth(ctx ?? navigatorKey.currentContext!) -
                      60.w,
              child: Row(
                children: [
                  error
                      ? AppImages.networkIssueImage(height: 30.w)
                      : AppImages.bankNotificationBadgelogo(
                          ctx ?? navigatorKey.currentContext!,
                          height: 25.w,
                          isColor: true),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.w),
                      child: CustomTextWidget(
                        message ?? "",
                        Theme.of(ctx ?? navigatorKey.currentContext!)
                            .primaryTextTheme
                            .labelSmall
                            ?.copyWith(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                alignment: Alignment.centerRight,
                height: AppWidgetSize.dimen_20,
                child: Container(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(ctx ?? navigatorKey.currentContext!)
                          .clearSnackBars();
                    },
                    child: AppImages.deleteIcon(
                      ctx ?? navigatorKey.currentContext!,
                      color: Theme.of(
                        ctx ?? navigatorKey.currentContext!,
                      ).primaryIconTheme.color,
                    ),
                  ),
                )),
          ],
        )),
    behavior: SnackBarBehavior.floating,
    elevation: 10,
  ));
}

void showToast({
  message,
  context,
  bool isError = false,
  bool isCenter = false,
  int secondsToShowToast = 4,
  double bottomMarigin = 10,
}) {
  scaffoldkey.currentState?.clearSnackBars();
  scaffoldkey.currentState?.showSnackBar(SnackBar(
    shape: const StadiumBorder(),
    elevation: 30,
    content: GestureDetector(
      onTap: () {
        scaffoldkey.currentState?.clearSnackBars();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_10),
          color: isError
              ? Theme.of(navigatorKey.currentContext!).colorScheme.error
              : Theme.of(navigatorKey.currentContext!)
                  .snackBarTheme
                  .backgroundColor,
        ),
        padding: EdgeInsets.symmetric(
            horizontal: AppWidgetSize.dimen_2,
            vertical: AppWidgetSize.dimen_10),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.w,
            fontFamily: "futura",
            color: AppStore().getThemeData() == AppConstants.darkMode
                ? isError
                    ? const Color(0xFFFBF2F4)
                    : const Color(0xFFE1F4E5)
                : isError
                    ? const Color(0xFFB00020)
                    : const Color(0xFF00C802),
          ),
        ),
      ),
    ),
    margin: EdgeInsets.only(
        bottom: 20.w + bottomMarigin.w,
        right: 20.w,
        left: AppWidgetSize.dimen_20),
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: isError ? 2 : secondsToShowToast),
    dismissDirection: DismissDirection.horizontal,
    backgroundColor: Colors.transparent,
  ));
}

void showToastFixed({
  message,
  context,
  Color? color,
  bool isError = false,
  bool isCenter = false,
  int secondsToShowToast = 4,
  double bottomMarigin = 10,
}) {
  scaffoldkey.currentState?.clearSnackBars();
  scaffoldkey.currentState?.showSnackBar(SnackBar(
    elevation: 10,
    content: Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13.w,
        fontFamily: "futura",
        color: color != null
            ? Colors.white
            : (AppStore().getThemeData() == AppConstants.darkMode
                ? isError
                    ? const Color(0xFFFBF2F4)
                    : const Color(0xFFE1F4E5)
                : isError
                    ? const Color(0xFFB00020)
                    : const Color(0xFF00C802)),
      ),
    ),
    behavior: SnackBarBehavior.fixed,
    duration:
        Duration(seconds: isError ? secondsToShowToast : secondsToShowToast),
    dismissDirection: DismissDirection.horizontal,
    backgroundColor: color ??
        (isError
            ? Theme.of(navigatorKey.currentContext!).colorScheme.error
            : Theme.of(navigatorKey.currentContext!)
                .snackBarTheme
                .backgroundColor),
  ));
}

abstract class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState();
}

abstract class BaseScreenState<Page extends BaseScreen> extends State<Page>
    with RouteAware, WidgetsBindingObserver {
  bool _loaderStared = false;

  MethodChannel methodChannel = const MethodChannel('ACMLFlutterChannel');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (getScreenRoute() != "") AppStore.currentRoute = getScreenRoute();

    WidgetsBinding.instance.addObserver(this);
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route is PageRoute) {
      FirebaseGlobal.analyticsObserver.subscribe(this, ModalRoute.of(context)!);
    }
  }

  //Firebase analytics functions

  Future<void> setCurrentScreenInFirebaseAnalytics(
    String currentPage,
  ) async {
    await FirebaseGlobal.analytics.setCurrentScreen(
      screenName: currentPage,
    );
  }

  void scrollToSelectedContent({GlobalKey? expansionTileKey}) {
    final keyContext = expansionTileKey?.currentContext;
    if (keyContext != null) {
      Future.delayed(const Duration(milliseconds: 400)).then((value) {
        Scrollable.ensureVisible(keyContext,
            duration: const Duration(milliseconds: 200));
      });
    }
  }

  Future<void> setUserIdInFirebaseAnalytics(
    String userID,
  ) async {
    await FirebaseGlobal.analytics.setUserId(
      id: userID,
    );
    await FirebaseCrashlytics.instance.setCustomKey("uid", userID);
    await FirebaseCrashlytics.instance
        .setCustomKey(userID, AppConfig.appVersion);
    await FirebaseAnalytics.instance.setUserProperty(
        name: "userName", value: AppStore().getAccDetails()?["uid"]);
    await FirebaseAnalytics.instance.setDefaultEventParameters({
      "version": AppConfig.appVersion,
      "userID": userID,
      AppConstants.platform: Platform.isAndroid ? "Android" : "Ios"
    });
  }

  Future<void> sendEventToFirebaseAnalytics(
      String event, String currentPage, String description,
      {String? key, String? value}) async {
    await FirebaseGlobal.analytics.logEvent(
      name: event,
      parameters: <String, dynamic>{
        AppConstants.event: event,
        AppConstants.description: description,
        if (key != null && value != null) key: value,
      },
    );

    AppUtils().logSuccess("EVENT ", event);
  }

  //End of Firebase analytics functions

  @override
  void didPush() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenFocusIn();
    });
    super.didPush();
  }

  dynamic arguments;

  @override
  void didPopNext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenFocusIn();
    });
    super.didPopNext();
  }

  showInfoBottomsheet(Widget child,
      {double? height,
      isdimissible = true,
      double? bottomMargin,
      bool horizontalMargin = true,
      bool isDirectChild = false,
      bool topMargin = true}) async {
    await InfoBottomSheet.showInfoBottomsheet(child, context,
        height: height,
        isdimissible: isdimissible,
        isDirectChild: isDirectChild,
        bottomMargin: bottomMargin,
        horizontalMargin: horizontalMargin,
        topMargin: topMargin);
  }

  void exitToLogin() {
    showInfoBottomsheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalizations().arihant,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Padding(
            padding: EdgeInsets.only(top: AppWidgetSize.dimen_20, bottom: 20.h),
            child: Text(
              AppLocalizations().exitToLoginScreen,
              style: Theme.of(context).textTheme.headlineMedium!,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations().cancel,
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  pushAndRemoveUntilNavigation(ScreenRoutes.loginScreen);
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 15.w),
                  child: Text(
                    AppLocalizations().proceed,
                    style: Theme.of(context).primaryTextTheme.headlineMedium,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void postFrame(Function()? function) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (function != null) {
        function();
      }
    });
  }

  @override
  void didPushNext() {
    screenFocusOut();
    super.didPopNext();
  }

  @override
  void dispose() {
    FirebaseGlobal.analyticsObserver.unsubscribe(this);
    screenFocusOut();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void screenFocusIn() {
    if (getScreenRoute() != "") AppStore.currentRoute = getScreenRoute();
  }

  String getScreenRoute() {
    return '';
  }

  Map? getStreamData() {
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  void screenFocusOut() {
    if (mounted) {
      stopLoader();
    }
    if (isStreamEnabled()) {
      unsubscribeLevel1();
      StreamingManager().unsubscribeLevel2(getScreenRoute());
    }
  }

  unsubscribeLevel1() {
    AppStore.subscribedPages.remove(getScreenRoute());
    StreamingManager().unsubscribeLevel1(getScreenRoute());
  }

  bool isStreamEnabled() {
    return getScreenRoute() != '' &&
        getScreenRoute() != ScreenRoutes.initConfig;
  }

  void handleError(ScreenState s) {}

  void stopLoader() {
    // ignore: unnecessary_null_comparison
    if (_loaderStared && context != null) {
      if (mounted) {
        Navigator.of(context).pop();
        _loaderStared = false;
      }
    }
  }

  void startLoader() {
    // ignore: unnecessary_null_comparison
    if (_loaderStared || context == null) return;

    _loaderStared = true;

    showDialog<WillPopScope>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Container(
            alignment: Alignment.center,
            child: const LoaderWidget(),
          ),
        );
      },
    );
  }

  Future<void> shieldRegistration() async {
    final String appID = await AppStorage().getData(appid) as String;
    final String username =
        await AppStore().getSavedDataFromAppStorage(userIdKey);
    const String userType = AppConstants.trade_user;
    if (appID.isNotEmpty && username.isNotEmpty && userType.isNotEmpty) {
      try {
        await methodChannel
            .invokeMethod('ShieldRegistration', <String, dynamic>{
          'appID': appID,
          'username': username,
          'userType': userType,
          'regUrl': ApiServicesUrls.shieldRegisterURL,
          'isCrypto': HttpClientConfig.encryptionEnabled,
          'secretKey': HttpClientConfig.encryptionKey,
          'appversion': AppConfig.appVersion,
        });
      } on PlatformException catch (e) {
        debugPrint('MethodChannel PlatformException : ${e.message}');
      } on MissingPluginException catch (e) {
        debugPrint('MethodChannel MissingPluginException : ${e.message}');
      } on Exception catch (e) {
        debugPrint('Exception  : $e');
      }
    }
  }

  Future<void> sendPushLogsToServer() async {
    final String? appID = await AppStorage().getData(appid);
    if (appID != null) {
      try {
        debugPrint('pushLogsToServer');
        await methodChannel.invokeMethod('pushLogsToServer', {
          'appID': appID,
          'regUrl': ApiServicesUrls.shieldPushLogURL,
          'isCrypto': HttpClientConfig.encryptionEnabled,
          'secretKey': HttpClientConfig.encryptionKey
        });
      } on PlatformException catch (e) {
        debugPrint("methodChannel PlatformException : '${e.message}'.");
      } on MissingPluginException catch (e) {
        debugPrint('MethodChannel MissingPluginException : ${e.message}');
      }
    }
  }

  dynamic pushNavigation(String pageName, {dynamic arguments}) {
    final Map<String, dynamic> pageDetails = <String, dynamic>{
      'pageName': pageName,
      'arguments': arguments,
    };
    scaffoldkey.currentState?.clearSnackBars();
    return pageNavigation(NAVIGATION.push, pageDetails);
  }

  dynamic popNavigation({dynamic arguments}) {
    final Map<String, dynamic> pageDetails = <String, dynamic>{
      'arguments': arguments,
    };
    return pageNavigation(NAVIGATION.pop, pageDetails);
  }

  dynamic pushReplaceNavigation(String pageName, {dynamic arguments}) {
    final Map<String, dynamic> pageDetails = <String, dynamic>{
      'pageName': pageName,
      'arguments': arguments,
    };
    return pageNavigation(NAVIGATION.pushReplacement, pageDetails);
  }

  dynamic navigateToUntil(String pageName, {dynamic arguments}) {
    final Map<String, dynamic> pageDetails = <String, dynamic>{
      'pageName': pageName,
      'arguments': arguments,
    };
    return pageNavigation(NAVIGATION.popUntil, pageDetails);
  }

  Future<void> showAlert(String message,
      {Function? callBack,
      bool isInvalid = false,
      bool showOkay = true,
      bool disableBack = false,
      Color? color,
      bool isDissmissble = false,
      bool isLight = false,
      String? header,
      buttonText}) async {
    Future.delayed(Duration.zero, () {
      if (!mounted) {
        return;
      }
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        isDismissible: isDissmissble,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.w),
        ),
        enableDrag: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(20.r),
                ),
              ),
              padding: EdgeInsets.all(AppWidgetSize.dimen_32),
              child: Wrap(
                children: <Widget>[
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextWidget(
                          header ?? AppLocalizations.of(context)!.arihant,
                          Theme.of(context).textTheme.displaySmall,
                        ),
                        Wrap(alignment: WrapAlignment.start, children: [
                          Padding(
                              padding:
                                  EdgeInsets.only(top: AppWidgetSize.dimen_20),
                              child: CustomTextWidget(
                                message,
                                Theme.of(context).textTheme.labelSmall,
                                textAlign: TextAlign.left,
                              ))
                        ])
                      ]),
                  Padding(
                    padding: EdgeInsets.only(top: 32.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            if (callBack != null) {
                              callBack();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              top: AppWidgetSize.dimen_1,
                              left: AppWidgetSize.dimen_12,
                              right: AppWidgetSize.dimen_12,
                              bottom: AppWidgetSize.dimen_1,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0.w),
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Text(
                              buttonText ?? AppLocalizations.of(context)!.ok,
                              style:
                                  Theme.of(context).primaryTextTheme.labelLarge,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void showAlertdismiss() {
    Navigator.of(context).pop();
  }

  GestureDetector backIconButton({
    GestureTapCallback? onTap,
    dynamic value,
    Color? customColor,
    double? width,
    double? height,
  }) {
    return GestureDetector(
      onTap: onTap ??
          () {
            popNavigation(arguments: value);
          },
      child: SizedBox(
        width: width ?? AppWidgetSize.dimen_30,
        height: height ?? AppWidgetSize.dimen_30,
        child: AppImages.backButtonIcon(
          context,
          isColor: true,
          color: customColor ?? Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }

  bool isScreenCurrent() {
    // ignore: unnecessary_null_comparison
    return context != null && ModalRoute.of(context)!.isCurrent;
  }

  bool isScreenActive() {
    if (mounted) {
      // ignore: unnecessary_null_comparison
      return context != null && ModalRoute.of(context)!.isActive;
    }
    return false;
  }

  void keyboardFocusOut() {
    // Keyboard focus out and tab outside the input field
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  }

  Future<void> subscribeLevel1(Map streamDetails) async {
    print('subscribelevel1 ${getScreenRoute()}');
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      _forceSubscribeLevel1(streamDetails);
    });
  }

  static int streaming = 0;
  Future<void> _forceSubscribeLevel1(Map streamDetails) async {
    try {
      AppStore.subscribedPages.add(getScreenRoute());

      final StreamDetailsModel streamDetailsModel =
          await AppHelper().getStreamDetails(
        getScreenRoute(),
        streamDetails['streamsymbols'],
        streamDetails['streamingKeys'],
        (ResponseData data) {
          if (isScreenActive()) {
            // debugPrint("${getScreenRoute()} -  $streaming");

            quote1responseCallback(data);
          }
        },
      );
      if ((isScreenActive()) && streamDetailsModel.symbols!.isNotEmpty) {
        List<StreamingSymbolModel> symbols =
            streamDetailsModel.symbols! as List<StreamingSymbolModel>;
        StreamingManager().forceSubscribeLevel1(
          streamDetailsModel.idProperties,
          symbols,
        );
      }
    } catch (e) {
      developer.log("Error $e");
    }
  }

  void quote1responseCallback(ResponseData data) {}

  void subscribeLevel2(Map streamDetails) {
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      _forceSubscribeLevel2(streamDetails);
    });
  }

  static int streaming2 = 0;

  void _forceSubscribeLevel2(Map streamDetails) {
    if (isScreenActive()) {
      final IdPropertiesModel idProperties =
          IdPropertiesModel.fromJson(<String, dynamic>{
        'screenName': getScreenRoute(),
        'streamingKeys': streamDetails['streamingKeys'],
        'callBack': (data) {
          if (isScreenActive()) {
            // debugPrint("${getScreenRoute()} -  $streaming2");

            quote2responseCallback(data);
          }
        }
      });
      StreamingManager().forceSubscribeLevel2(
        idProperties,
        streamDetails['streamsymbols'],
      );
    }
  }

  void quote2responseCallback(Quote2Data streamData) {}
}

abstract class BaseAuthScreenState<Page extends BaseScreen>
    extends BaseScreenState<Page> {
  @override
  // ignore: avoid_renaming_method_parameters
  void handleError(ScreenState screenState) {
    super.handleError(screenState);
  }

  @override
  void postFrame(Function()? function) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (function != null) {
        function();
      }
    });
  }

  void logInfo(String logName, dynamic msg) {
    developer.log('\x1B[34m$logName $msg\x1B[0m');
  }

  void logSuccess(String logName, dynamic msg) {
    developer.log('\x1B[32m$logName $msg\x1B[0m');
  }

  void logWarning(String logName, dynamic msg) {
    developer.log('\x1B[33m$logName $msg\x1B[0m');
  }

  void logError(String logName, dynamic msg) {
    developer.log('\x1B[31m$logName $msg\x1B[0m');
  }

  void handleInvalidAppID() {
    AppUtils().clearStorage(type: AppConstants.invalidAppInDErrorCode);
    // AppStore().clearLoginSession();
    pushAndRemoveUntilNavigation(ScreenRoutes.initConfig,
        removeUntilPageName: '');
  }
}
