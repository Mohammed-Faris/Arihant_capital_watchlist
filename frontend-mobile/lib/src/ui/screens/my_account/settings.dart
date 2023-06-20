// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/utils/config/httpclient_config.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../blocs/themebloc/theme_bloc.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_constants.dart';
import '../../../data/store/app_storage.dart';
import '../../../data/store/app_store.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/biometric_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/list_tile_widget.dart';
import '../../widgets/webview_widget.dart';
import '../base/base_screen.dart';
import '../login/change_password/change_password_screen.dart';
import '../login/login_screen.dart';
import '../route_generator.dart';

class Settings extends BaseScreen {
  const Settings({
    Key? key,
  }) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends BaseAuthScreenState<Settings> {
  late AppLocalizations appLocalizations;
  bool isBioMetricEnabled = true;
  late ThemeBloc _themeBloc;
  bool isDarkTheme = false;

  ValueNotifier<bool> reviewOrder = ValueNotifier<bool>(true);
  String experience = '';
  String light = AppLocalizations().lightMode;
  String dark = AppLocalizations().darkMode;
  String? selectedTheme;
  ValueNotifier<bool> isPushNotification = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    getrevieworderStatus();
    checkBiometricEnabled();
    getnotificationStatus();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.settings);
    experience = AppStore().getThemeData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _themeBloc = BlocProvider.of<ThemeBloc>(context);
    });
  }

  getrevieworderStatus() async {
    var data = await AppUtils().getsmartDetails();

    reviewOrder.value = data["reviewOrder"] == "true" ? true : false;
  }

  getnotificationStatus() async {
    isPushNotification.value = await Permission.notification.isGranted;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        getnotificationStatus();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  static const MethodChannel platform = MethodChannel('ACMLFlutterChannel');

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

  bool canCheckbiometric = false;
  checkBiometricEnabled() async {
    canCheckbiometric =
        await BiometricWidget().checkBiometrics(checkSkipBio: false);
    dynamic getSmartLoginDetails = await AppUtils().getsmartDetails();
    final List getAvailableBiometrics =
        await BiometricWidget().getAvailableBiometrics();
    if (getSmartLoginDetails['biometric'] == true &&
        getAvailableBiometrics.isNotEmpty) {
      setState(() {
        isBioMetricEnabled = true;
      });
    }
    bool skipbiometric = (await AppStorage().getData("skipBiometric")) ?? false;
    isBioMetricEnabled = skipbiometric ? false : isBioMetricEnabled;
    setState(() {});
  }

  List<Widget> getSettingsOptions(BuildContext context) {
    return [
      ListTileWidget(
        title: AppLocalizations().pushNotifications,
        subtitle: '',
        switchValue: isPushNotification.value,
        isSwitch: true,
        onChanged: (value) async {
          PermissionStatus status = await Permission.notification.request();
          if (status != PermissionStatus.granted || isPushNotification.value) {
            AppSettings.openNotificationSettings();
          } else {
            getnotificationStatus();
          }
        },
        leadingImage: AppImages.pushNotification(context),
      ),
      ListTileWidget(
        title: AppLocalizations().themeSettings,
        subtitle: '',
        onTap: () {
          themeSetting();
          //pushNavigation(ScreenRoutes.helpAndSupport);
        },
        leadingImage: AppImages.themesettings(context),
      ),
      ListTileWidget(
        title: AppLocalizations().changePassword,
        subtitle: '',
        onTap: () async {
          String clientId =
              await AppStore().getSavedDataFromAppStorage("userIdKey");
          pushNavigation(ScreenRoutes.changePasswordScreen,
              arguments: ChangePasswordScreenArgs(clientId));
        },
        leadingImage: AppImages.changePasswordd(context),
      ),
      if (!isBioMetricEnabled || !canCheckbiometric)
        ListTileWidget(
          title: AppLocalizations().biometric,
          subtitle: '',
          onChanged: (value) async {
            if (value) {
              await onenablebiometric(value, context);
            } else {
              await onenablebiometric(value, context);
            }
          },
          switchValue: isBioMetricEnabled && canCheckbiometric,
          isSwitch: true,
          leadingImage: AppImages.biometric(context),
        ),
      ValueListenableBuilder<bool>(
          valueListenable: reviewOrder,
          builder: (context, value, _) {
            return ListTileWidget(
              title: AppLocalizations().review,
              subtitle: '',
              onChanged: (value) async {
                await AppUtils().saveLastThreeUserData(
                    key: "reviewOrder", value: value.toString());
                getrevieworderStatus();
              },
              switchValue: value,
              isSwitch: true,
              leadingImage: Icon(
                CupertinoIcons.checkmark_circle,
                size: 25.w,
                color:
                    Theme.of(context).primaryIconTheme.color?.withOpacity(0.8),
              ),
            );
          }),
      ListTileWidget(
        onTap: () {
          Navigator.push(
            context,
            SlideRoute(
              settings: const RouteSettings(
                name: ScreenRoutes.inAppWebview,
              ),
              builder: (BuildContext context) => WebviewWidget(
                AppLocalizations().privacyPolicy,
                AppConfig.boUrls?[0]["value"],
                key: Key(AppLocalizations().privacyPolicy),
              ),
            ),
          );
        },
        title: AppLocalizations().privacyPolicy,
        subtitle: '',
        leadingImage: AppImages.privacyPolicy(context),
      ),
      ListTileWidget(
        onTap: () {
          Navigator.push(
            context,
            SlideRoute(
              settings: const RouteSettings(
                name: ScreenRoutes.inAppWebview,
              ),
              builder: (BuildContext context) => WebviewWidget(
                AppLocalizations().termandConditions,
                AppConfig.boUrls?[1]["value"],
                key: Key(AppLocalizations().termandConditions),
              ),
            ),
          );
        },
        title: AppLocalizations().termandConditions,
        subtitle: '',
        leadingImage: AppImages.termsandCondition(context),
      ),

      // ListTileWidget(
      //   onTap: () {
      //     pushNavigation(ScreenRoutes.tOtpscreen);
      //   },
      //   title: "OTP",
      //   subtitle: '',
      //   leadingImage: AppImages.termsandCondition(context),
      // ),

      /* ListTileWidget(
        title: AppLocalizations().helpandSupport,
        subtitle: '',
        onTap: () {
          pushNavigation(ScreenRoutes.helpAndSupport);
        },
        leadingImage: AppImages.helpSupport(context),
      ), */
    ];
  }

  Future<void> onenablebiometric(bool value, BuildContext context) async {
    await AppStorage().setData("skipBiometric", false);
    final List getAvailableBiometrics =
        await BiometricWidget().getAvailableBiometrics();
    if (getAvailableBiometrics.isNotEmpty) {
      if (value) {
        final bool checkBiometrics =
            await BiometricWidget().checkBiometrics(checkSkipBio: false);

        if (checkBiometrics) {
          setState(() {
            isBioMetricEnabled = value;
          });
          if (!mounted) {
            return;
          }
          showToast(
            message: appLocalizations.loginToSetBiometric,
            context: context,
          );
          String clientId =
              await AppStore().getSavedDataFromAppStorage("userIdKey");
          pushAndRemoveUntilNavigation(ScreenRoutes.loginScreen,
              arguments: LoginScreenArgs(clientId: clientId));
          AppUtils().saveLastThreeUserData(
              key: AppConstants.lastLoggedInWithOTP, value: null);
        } else {
          if (Platform.isIOS) {
            if (!mounted) {
              return;
            }
            showToast(
                message: appLocalizations.iOSbiometricDisabled,
                context: context,
                isError: true);
          } else {
            if (!mounted) {
              return;
            }
            showToast(
                message: appLocalizations.biometricNotAvailable,
                context: context,
                isError: true);
          }
        }
      } else {
        showInfoBottomsheet(
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "Arihant",
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.w, bottom: 20.h),
                child: Text(
                  "Are you sure you want Disable Biometric?",
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
                    child: Text(AppConstants.no,
                        style: Theme.of(context).textTheme.headlineMedium),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await AppUtils().saveLastThreeUserData(
                        biometric: false,
                      );
                      setState(() {
                        isBioMetricEnabled = false;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.w),
                      child: Text(
                        AppConstants.yes,
                        style:
                            Theme.of(context).primaryTextTheme.headlineMedium,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }
    } else {
      if (Platform.isIOS) {
        if (!mounted) {
          return;
        }
        showToast(
            message: appLocalizations.iOSbiometricDisabled,
            context: context,
            isError: true);
      } else {
        if (!mounted) {
          return;
        }
        showToast(
            message: appLocalizations.biometricNotAvailable,
            context: context,
            isError: true);
      }
      BiometricWidget().enableBiometric(cancel: true);
    }
  }

  Future<void> themeSetting() async {
    showInfoBottomsheet(
        SafeArea(
            child: Padding(
                padding: EdgeInsets.only(top: 10.w, bottom: 10.w),
                child: Wrap(children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 10.w,
                      bottom: 25.w,
                      left: 30.w,
                      right: 30.w,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CustomTextWidget(
                          appLocalizations.themeSettings,
                          Theme.of(context).primaryTextTheme.titleSmall,
                          textAlign: TextAlign.justify,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: AppImages.closeIcon(
                            context,
                            color: Theme.of(context).primaryIconTheme.color,
                            isColor: true,
                            width: AppWidgetSize.dimen_22,
                            height: AppWidgetSize.dimen_22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                          onTap: () {
                            popNavigation();
                            experience = AppConstants.lightMode;
                            _themeBloc.add(ChangeThemeEvent(
                                themeType: AppConstants.lightMode));
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 30.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: AppWidgetSize.dimen_35,
                                    bottom: 30.w,
                                  ),
                                  child: Text(
                                    AppLocalizations().lightMode,
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall,
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                                /*  const SizedBox(
                                  width: 150,
                                ), */
                                if (experience == AppConstants.lightMode ||
                                    experience == "")
                                  SizedBox(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 30.w,
                                      ),
                                      child: AppImages.greenTickIcon(
                                        context,
                                        width: AppWidgetSize.dimen_22,
                                        height: AppWidgetSize.dimen_22,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )),
                      InkWell(
                          onTap: () {
                            popNavigation();

                            experience = AppConstants.darkMode;
                            _themeBloc.add(ChangeThemeEvent(
                                themeType: AppConstants.darkMode));
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 30.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: AppWidgetSize.dimen_35,
                                  ),
                                  child: Text(
                                    AppLocalizations().darkMode,
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall,
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                                /*  const SizedBox(
                                  width: 150,
                                ), */
                                if (experience == AppConstants.darkMode)
                                  SizedBox(
                                    child: AppImages.greenTickIcon(
                                      context,
                                      width: AppWidgetSize.dimen_22,
                                      height: AppWidgetSize.dimen_22,
                                    ),
                                  ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ]))),
        bottomMargin: Platform.isIOS ? 0 : 25.w,
        horizontalMargin: false,
        topMargin: false);
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: backIconButton(),
              ),
              Padding(
                padding: EdgeInsets.only(left: AppWidgetSize.dimen_25),
                child: CustomTextWidget(
                  AppLocalizations().settings,
                  Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          toolbarHeight: AppWidgetSize.dimen_60,
        ),
        /*   appBar: PreferredSize(
          preferredSize: const Size(400, 400),
          child: SafeArea(
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                AppImages.settingsBanner(context),
                topBar(context),
              ],
            ),
          ),
        ), */
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                /* Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                AppImages.settingsBanner(context),
                topBar(context),
              ],
            ), */
                ValueListenableBuilder(
                    valueListenable: isPushNotification,
                    builder: (context, value, child) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppWidgetSize.dimen_15),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(
                              horizontal: AppWidgetSize.dimen_10),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: getSettingsOptions(context).length,
                          itemBuilder: (context, index) {
                            return getSettingsOptions(context)[index];
                          },
                        ),
                      );
                    }),
              ],
            ),
          ),
        ));
  }

  Container topBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_18, left: 30.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: backIconButton(),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.w),
            child: CustomTextWidget(
                AppLocalizations().settings,
                Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
