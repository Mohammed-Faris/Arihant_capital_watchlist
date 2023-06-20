import 'package:acml/src/constants/app_events.dart';
import 'package:acml/src/ui/widgets/loader_widget.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/utils/config/httpclient_config.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../blocs/init/init_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/keys/init_config_keys.dart';
import '../../../constants/keys/login_keys.dart';
import '../../../constants/storage_constants.dart';
import '../../../data/store/app_store.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/config/config_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/default_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../base/base_screen.dart';
import 'splashwidget.dart';

class InitConfigScreen extends BaseScreen {
  const InitConfigScreen({Key? key}) : super(key: key);

  @override
  InitConfigScreenState createState() => InitConfigScreenState();
}

class InitConfigScreenState extends BaseScreenState<InitConfigScreen> {
  late InitBloc initBloc;
  bool isLoader = true;
  late ConfigModel configModel;
  final WebViewController _webcontroller = WebViewController();

  static const MethodChannel platform = MethodChannel('ACMLFlutterChannel');

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    initializeShieldPush();

    initBloc = BlocProvider.of<InitBloc>(context)
      ..add(InitFetchAppIDEvent())
      ..stream.listen((event) {
        initConfigListener(event);
      });

    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.initConfig);
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.initConfig;
  }

  Future<void> initializeShieldPush() async {
    try {
      await platform.invokeMethod('ShieldInit', {
        'isCrypto': HttpClientConfig.encryptionEnabled,
        'secretKey': HttpClientConfig.encryptionKey
      });
    } on PlatformException catch (e) {
      debugPrint("methodChannel PlatformException : '${e.message}'.");
    } on MissingPluginException catch (e) {
      debugPrint('MethodChannel MissingPluginException : ${e.message}');
    }
  }

  void initFetchCall() {
    initBloc.add(
      InitFetchAppIDEvent(),
    );
  }

  Future<void> initConfigListener(InitState state) async {
    if (mounted) {
      if (state is InitCompletedState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            isLoader = false;
          });
        });
        if (state.configModel.versionDetail != null) {
          configModel = state.configModel;
          if (updateDetails.currentWidget == null) {
            _showVersionUpdateDetails();
          }
        } else {
          _moveToLoginScreen();
        }
      } else if (state is InitFailedState) {
        if (state.errorCode == AppConstants.invalidAppInDErrorCode) {
          AppUtils().clearStorage(type: AppConstants.invalidAppInDErrorCode);
          initFetchCall();
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Container(
            width: AppWidgetSize.fullWidth(context),
            height: AppWidgetSize.fullHeight(context),
            decoration:
                BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
            child: const SpalshWidget(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BlocBuilder<InitBloc, InitState>(
              builder: (BuildContext context, InitState state) {
                if (state is InitProgressState ||
                    state is InitNotStartedState ||
                    (state is InitFailedState &&
                        state.errorCode ==
                            AppConstants.invalidAppInDErrorCode)) {
                  return Container();
                } else if (state is InitFailedState) {
                  return defaultWidget(
                    context,
                    errorCode: state.errorCode,
                    message: state.errorMsg,
                    onCallback: initFetchCall,
                  );
                }
                return Container();
              },
              buildWhen: (InitState prevState, InitState currentState) {
                return currentState is! InitCompletedState;
              },
            ),
          )
        ],
      ),
    );
  }

  GlobalKey<InitConfigScreenState> updateDetails =
      GlobalKey<InitConfigScreenState>();
  void _showVersionUpdateDetails() {
    setState(() {
      isLoader = false;
    });
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.w),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (BuildContext bct) {
        return WillPopScope(
          key: updateDetails,
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
            padding: EdgeInsets.only(
              left: 30.w,
              right: 30.w,
              top: 20.w,
            ),
            child: _buildVersionUpdateBlock(),
          ),
        );
      },
    );
  }

  Wrap _buildVersionUpdateBlock() {
    final bool isiOS = Theme.of(context).platform == TargetPlatform.iOS;
    return Wrap(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: AppWidgetSize.dimen_15,
                bottom: AppWidgetSize.dimen_15,
                right: 30.w,
                left: 30.w,
              ),
              child: Text(
                isiOS
                    ? AppLocalizations().versionUpdateiOSDesc
                    : AppLocalizations().versionUpdateAndroidDesc,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: 20.w,
              ),
              child: SizedBox(
                height: 200.w,
                child: _buildwebView(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                gradientButtonWidget(
                    onTap: () {
                      sendEventToFirebaseAnalytics(
                        AppEvents.initUpdate,
                        ScreenRoutes.initConfig,
                        'Update is selected in Update screen and will move to webview for store redirect',
                      );
                      _updateApp();
                    },
                    width: (AppWidgetSize.screenWidth(context) /
                            AppWidgetSize.dimen_2) -
                        AppWidgetSize.dimen_30,
                    key: const Key(updateButtonKey),
                    context: context,
                    title: AppLocalizations().update,
                    isGradient: true),
                if (!((configModel.versionDetail?.mandatory) ?? false))
                  gradientButtonWidget(
                      onTap: () {
                        sendEventToFirebaseAnalytics(
                          AppEvents.initSkip,
                          ScreenRoutes.initConfig,
                          'skip is selected in Update screen and will move to login screen',
                        );
                        _skipUpdate();
                      },
                      width: (AppWidgetSize.screenWidth(context) /
                              AppWidgetSize.dimen_2) -
                          AppWidgetSize.dimen_30,
                      key: const Key(skipButtonKey),
                      context: context,
                      title: AppLocalizations().skip,
                      isGradient: true),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildwebView() {
    String storyString = configModel.versionDetail?.releaseNotes ?? "";
    String themeBgColor =
        AppStore().getThemeData() == AppConstants.lightMode ? 'white' : 'black';
    String themeTextColor =
        AppStore().getThemeData() == AppConstants.darkMode ? 'white' : 'black';
    storyString = storyString.replaceAll('<body>',
        '<meta name="color-scheme" content="light dark"><body style="background-color:$themeBgColor;color:$themeTextColor;font-size:40px;">');
    _webcontroller
      ..loadHtmlString(storyString)
      ..setBackgroundColor(Theme.of(context).scaffoldBackgroundColor);
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 500)),
      builder: (context, state) {
        if (state.connectionState != ConnectionState.done) {
          return const LoaderWidget();
        }
        return WebViewWidget(
          controller: _webcontroller,
        );
      },
    );
  }

  Future<void> _updateApp() async {
    if (await canLaunchUrlString(configModel.versionDetail!.url)) {
      await launchUrlString(configModel.versionDetail!.url);
    } else {
      throw 'Could not launch';
    }
  }

  void _skipUpdate() {
    _moveToLoginScreen();
  }

  Future<void> _moveToLoginScreen() async {
    try {
      

      var getSmartLoginDetails = await AppUtils().getsmartDetails();
      if (getSmartLoginDetails == null) {
        pushReplaceNavigation(ScreenRoutes.onBoardingScreen);
      } else {
        final bool checkPin = getSmartLoginDetails != null &&
            (getSmartLoginDetails?['pin'] ?? false);
        final bool checkBiometric = getSmartLoginDetails != null &&
            (getSmartLoginDetails?['biometric'] ?? false);

        if (checkPin || checkBiometric) {
          if (getSmartLoginDetails != null) {
            if (getSmartLoginDetails[accNameConstants] == null ||
                getSmartLoginDetails["uid"] == null) {
              AppUtils().removeCurrentUser();
            }
            AppStore().setUserName(getSmartLoginDetails["userName"]);
            AppUtils()
                .saveDataInAppStorage(userIdKey, getSmartLoginDetails["uid"]);

            AppStore().setAccountName(getSmartLoginDetails[accNameConstants]);
            setUserIdInFirebaseAnalytics(getSmartLoginDetails?["uid"]);

            if (getSmartLoginDetails['pinStatus'] == 'setPin') {
              pushReplaceNavigation(ScreenRoutes.loginScreen);
            } else {
              pushReplaceNavigation(
                ScreenRoutes.smartLoginScreen,
                arguments: {
                  'loginPin': true,
                },
              );
            }
          } else {
            pushReplaceNavigation(
              ScreenRoutes.smartLoginScreen,
              arguments: {
                'loginPin': true,
              },
            );
          }
        } else {
          pushReplaceNavigation(ScreenRoutes.loginScreen);
        }
      }
    } catch (e) {
      FirebaseCrashlytics.instance.recordFlutterError(
        FlutterErrorDetails(exception: e),
      );
      pushReplaceNavigation(ScreenRoutes.loginScreen);
    }
    initBloc.close();
  }
}
