// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:io';

import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../config/app_config.dart';
import '../../data/store/app_storage.dart';
import '../../localization/app_localization.dart';
import '../navigation/screen_routes.dart';
import '../screens/acml_app.dart';
import '../screens/base/base_screen.dart';
import '../styles/app_widget_size.dart';

class BiometricWidget {
  static final BiometricWidget _biometricWidget = BiometricWidget._();

  factory BiometricWidget() => _biometricWidget;

  BiometricWidget._() {
    init();
  }

  late LocalAuthentication auth;
  late FocusNode focus;

  void init() {
    auth = LocalAuthentication();
    focus = FocusNode();
  }

  Future<bool> checkBiometrics({bool checkSkipBio = true}) async {
    bool canCheckBiometrics = false;
    bool skipbiometric = false;
    try {
      if (checkSkipBio) {
        skipbiometric = (await AppStorage().getData("skipBiometric")) ?? false;
      }
      canCheckBiometrics = await auth.canCheckBiometrics;
      canCheckBiometrics = await isDeviceSupported();
    } on PlatformException catch (e) {
      debugPrint('$e');
    }
    return skipbiometric ? false : canCheckBiometrics;
  }

  Future<bool> isDeviceSupported() async {
    bool isDeviceSupported = false;
    try {
      isDeviceSupported = await auth.isDeviceSupported();
    } on PlatformException catch (e) {
      debugPrint('$e');
    }
    return isDeviceSupported;
  }

  Future<List> getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('$e');
    }
    return availableBiometrics;
  }

  Future<bool> authenticate(String localizedReason,
      {bool cancel = false}) async {
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        localizedReason: localizedReason,
        authMessages: [
          const AndroidAuthMessages(
              biometricNotRecognized:
                  "Oops! Your fingerprint didn’t match, wanna try again?"),
          const IOSAuthMessages(
            cancelButton: "Cancel",
            localizedFallbackTitle: "",
            lockOut: "Biometric has been locked Out, please try again later",
          ),
        ],
        options: const AuthenticationOptions(
          useErrorDialogs: false,
          biometricOnly: false,
          sensitiveTransaction: false,
          stickyAuth: false,
        ),
      );
      debugPrint(authenticated ? "Authenticated" : "Not Authenticated");
    } on PlatformException catch (e) {
      debugPrint("Exception $e");
      focus.requestFocus();
      showToast(message: "${e.message}", isError: true);
      if (e.code == "NotEnrolled") {
        FocusManager.instance.primaryFocus?.unfocus();
        enableBiometric(cancel: cancel);
      } else if (e.code == "NotAvailable" &&
          e.message != "Authentication canceled.") {
        FocusManager.instance.primaryFocus?.unfocus();
        showToast(message: "${e.message}", isError: true);
        enableBiometric(cancel: cancel);
      } else if (e.code == "LockedOut") {
        showToast(
            message:
                "Biometric has been disabled, please try again after 30 sec.",
            isError: true);

        throw PlatformException(
            code: e.code.toString(),
            message:
                "Biometric has been disabled, please try again after 30 sec.");
      } else {
        showToast(message: "${e.message}", isError: true);

        throw PlatformException(
            code: e.code.toString(),
            message: AppLocalizations().biometricNotRecognized);
      }
    } catch (e) {
      showToast(message: e.toString(), isError: true);
    }

    return authenticated;
  }

  void enableBiometric({bool cancel = false}) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.w),
      ),
      context: navigatorKey.currentContext!,
      builder: (BuildContext ctx) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_5),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(navigatorKey.currentContext!).primaryColor,
              width: 1.5,
            ),
            color:
                Theme.of(navigatorKey.currentContext!).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
              AppWidgetSize.dimen_30,
              AppWidgetSize.dimen_30,
              AppWidgetSize.dimen_30,
              AppWidgetSize.dimen_30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                Platform.isIOS
                    ? AppLocalizations().faceIdrequired
                    : AppLocalizations().fingerprintrequired,
                style: Theme.of(navigatorKey.currentContext!)
                    .textTheme
                    .displaySmall,
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: AppWidgetSize.dimen_20,
                      bottom: AppWidgetSize.dimen_20),
                  child: cancel
                      ? RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text:
                                    "Set the biometrics on your device by clicking on ",
                                style: Theme.of(navigatorKey.currentContext!)
                                    .textTheme
                                    .headlineSmall!),
                            TextSpan(
                                text: "Go to Settings",
                                style: Theme.of(navigatorKey.currentContext!)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(fontWeight: FontWeight.bold))
                          ]),
                        )
                      : RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text:
                                    "If you want to Login using OTP, Please click on the ",
                                style: Theme.of(navigatorKey.currentContext!)
                                    .textTheme
                                    .headlineSmall!),
                            TextSpan(
                                text: "Skip",
                                style: Theme.of(navigatorKey.currentContext!)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    " button or Set the Biometric on your device by clicking on ",
                                style: Theme.of(navigatorKey.currentContext!)
                                    .textTheme
                                    .headlineSmall!),
                            TextSpan(
                                text: "Go to Settings",
                                style: Theme.of(navigatorKey.currentContext!)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(fontWeight: FontWeight.bold))
                          ]),
                        )),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      Navigator.of(navigatorKey.currentContext!).pop();
                      if (cancel) {}

                      if (!cancel) {
                        if (AppConfig.twoFA) {
                          navigatorKey.currentState?.pushNamedAndRemoveUntil(
                              ScreenRoutes.smartLoginScreen, (e) => false,
                              arguments: {"generateOTP": true});
                          AppStorage().setData("skipBiometric", true);
                        } else {
                          navigatorKey.currentState?.pushNamedAndRemoveUntil(
                              ScreenRoutes.homeScreen, (e) => false);
                        }
                      }
                    },
                    child: Text(
                        cancel
                            ? AppLocalizations().cancel
                            : AppLocalizations().skip,
                        style: Theme.of(navigatorKey.currentContext!)
                            .textTheme
                            .headlineMedium),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(navigatorKey.currentContext!).pop();
                      AppSettings.openLockAndPasswordSettings();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_15),
                      child: Text(
                        AppLocalizations().gotoSettings,
                        style: Theme.of(navigatorKey.currentContext!)
                            .primaryTextTheme
                            .headlineMedium,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void retryBiometric(Function()? onTap, {bool cancel = false}) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.w),
      ),
      context: navigatorKey.currentContext!,
      builder: (BuildContext ctx) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_5),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(navigatorKey.currentContext!).primaryColor,
              width: 1.5,
            ),
            color:
                Theme.of(navigatorKey.currentContext!).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
              AppWidgetSize.dimen_30,
              AppWidgetSize.dimen_30,
              AppWidgetSize.dimen_30,
              AppWidgetSize.dimen_30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                AppLocalizations().biometricdisabled,
                style: Theme.of(navigatorKey.currentContext!)
                    .textTheme
                    .displaySmall,
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: AppWidgetSize.dimen_20,
                      bottom: AppWidgetSize.dimen_20),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: AppLocalizations().biometricdisabledContent,
                          style: Theme.of(navigatorKey.currentContext!)
                              .textTheme
                              .headlineSmall!),
                    ]),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      Navigator.of(navigatorKey.currentContext!).pop();

                      if (!cancel) {
                        if (AppConfig.twoFA) {
                          navigatorKey.currentState?.pushNamedAndRemoveUntil(
                              ScreenRoutes.smartLoginScreen, (e) => false,
                              arguments: {"generateOTP": true});
                        } else {
                          navigatorKey.currentState?.pushNamedAndRemoveUntil(
                              ScreenRoutes.homeScreen, (e) => false);
                        }
                      }
                    },
                    child: Text(
                        cancel
                            ? AppLocalizations().cancel
                            : AppLocalizations().skip,
                        style: Theme.of(navigatorKey.currentContext!)
                            .textTheme
                            .headlineMedium),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(navigatorKey.currentContext!).pop();
                      onTap!();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_15),
                      child: Text(
                        AppLocalizations().retry,
                        style: Theme.of(navigatorKey.currentContext!)
                            .primaryTextTheme
                            .headlineMedium,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
