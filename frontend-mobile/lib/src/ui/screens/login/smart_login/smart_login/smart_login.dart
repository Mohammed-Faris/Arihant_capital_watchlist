import 'dart:async';
import 'dart:io';

import 'package:acml/src/constants/app_events.dart';
import 'package:acml/src/data/cache/cache_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:msil_library/streamer/stream/streaming_manager.dart';

import '../../../../../blocs/login/login_bloc.dart';
import '../../../../../config/app_config.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../constants/keys/login_keys.dart';
import '../../../../../constants/storage_constants.dart';
import '../../../../../data/repository/my_account/my_account_repository.dart';
import '../../../../../data/store/app_storage.dart';
import '../../../../../data/store/app_store.dart';
import '../../../../../data/store/app_utils.dart';
import '../../../../../localization/app_localization.dart';
import '../../../../navigation/screen_routes.dart';
import '../../../../styles/app_images.dart';
import '../../../../styles/app_widget_size.dart';
import '../../../../widgets/biometric_image.dart';
import '../../../../widgets/biometric_widget.dart';
import '../../../../widgets/custom_text_widget.dart';
import '../../../../widgets/gradient_button_widget.dart';
import '../../../../widgets/secure_input_widget.dart';
import '../../../acml_app.dart';
import '../../../base/base_screen.dart';
import '../../login_screen.dart';
import '../../support.dart';
import 'switch_account.dart';

class SmartLoginScreen extends BaseScreen {
  final dynamic arguments;
  const SmartLoginScreen({
    Key? key,
    this.arguments,
  }) : super(key: key);

  @override
  SmartLoginScreenState createState() => SmartLoginScreenState();
}

class SmartLoginScreenState extends BaseAuthScreenState<SmartLoginScreen> {
  late AppLocalizations _appLocalizations;
  late LoginBloc loginBloc;
  ValueNotifier<bool> isError = ValueNotifier<bool>(false);
  bool isBiometricAvailable = false;
  bool biometricOption = false;
  BiometricType? biometricType;
  String biometricToken = '';
  late String username;
  bool isLoginPin = false;
  void starttimer() async {
    const onssec = Duration(seconds: 1);
    Timer.periodic(onssec, (timer) {
      if (start == 0) {
        if (mounted) {
          setState(() {
            timer.cancel();
            wait = false;
          });
        }
      } else if (start == 27) {
        if (mounted) {
          setState(() {
            start--;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            start--;
          });
        }
      }
    });
  }

  DateTime? fromTime;
  DateTime? toTime;
  bool showMaintenance() {
    DateTime now = DateTime.now();
    if (AppConfig.maintenance != null) {
      fromTime = DateTime.utc(
              now.year,
              now.month,
              now.day,
              AppUtils()
                  .intValue(AppConfig.maintenance?["fromDte"]!.split(":")[0]),
              AppUtils()
                  .intValue(AppConfig.maintenance?["fromDte"]!.split(":")[1]))
          .subtract(const Duration(hours: 5, minutes: 30));
      toTime = DateTime.utc(
              now.year,
              now.month,
              now.day,
              AppUtils()
                  .intValue(AppConfig.maintenance?["toDte"]!.split(":")[0]),
              AppUtils()
                  .intValue(AppConfig.maintenance?["toDte"]!.split(":")[1]))
          .subtract(const Duration(hours: 5, minutes: 30));
      if (fromTime != null && toTime != null) {
        return (now.toUtc().isBetween(fromTime!, toTime!) ?? false);
      } else {
        return false;
      }
    }
    return false;
  }

  bool generateOTP = false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (showMaintenance()) {
        scheduledmaintenceBottomsheet();
      }
    });

    biometricType =
        Platform.isIOS ? BiometricType.face : BiometricType.fingerprint;

    super.initState();
    generateOTP = widget.arguments?["generateOTP"] ?? false;

    _clearDataRelatedToFunds();
    username = AppStore().getAccountName();
    if (widget.arguments != null && widget.arguments['loginPin'] != null) {
      isLoginPin = widget.arguments['loginPin'];
    }
    loginBloc = BlocProvider.of<LoginBloc>(context)
      ..stream.listen(_loginBlocListner);
    getBiometricStatus();
    fetchData();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.smartLoginScreen);
    pinfocus = FocusNode();
  }

  List<dynamic> users = [];
  fetchData() async {
    users = await AppUtils().getAlluserDetails();
  }

  void _clearDataRelatedToFunds() {
    AppStorage().removeData('getBankdetailkey');
    AppStorage().removeData('getPaymentOptionkey');
    AppStorage().removeData('getRecentFundTransaction');
    AppStorage().removeData('getFundHistorydata');
    AppStorage().removeData('getFundViewUpdatedModel');
  }

  ValueNotifier<bool> validateOtp = ValueNotifier<bool>(false);
  ValueNotifier<bool> enterPin = ValueNotifier<bool>(true);

  Future<void> _loginBlocListner(LoginState state) async {
    if (state is LoginProgressState) {
      startLoader();
    }
    if (state is! LoginProgressState) {
      stopLoader();
    }
    if (state is GenerateOtpDoneState) {
      showToast(message: state.generateOtpModel.infoMsg);
      // showToast(message: state.generateOtpModel.infoMsg);
      validateOtp.value = true;
      start = 30;
      wait = false;
      starttimer();
    }
    if (state is LoginBiometricDoneState) {
      resetPIN();

      pushToHomeScreen();
    } else if (state is LoginPinDoneState) {
      if (isOTPValidatedin24Hours) {
        resetPIN();
        pinfocus.unfocus();
        pushToHomeScreen();
      } else {
        pinCode.clear();

        final bool bio = await BiometricWidget().checkBiometrics();
        if (AppConfig.twoFA) {
          if (bio && !biometricOption) {
            pinfocus.unfocus();
            CacheRepository().clearCache(fromLogin: true);
            StreamingManager().initConnection();
            Future.delayed(
                const Duration(milliseconds: 500),
                () => {
                      if (AppConfig.twoFA)
                        {
                          pushAndRemoveUntilNavigation(
                              ScreenRoutes.setBiometricScreen)
                        }
                      else
                        {
                          pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen),
                          sendUserId()
                        }
                    });
          } else {
            loginBloc.add(TwoFOTPGenerate());
          }
        } else {
          resetPIN();
          pushToHomeScreen();
        }
      }
    } else if (state is ValidateOtpDoneState) {
      resetPIN();
      if (Featureflag.setOtpExpiry != 0) {
        AppUtils().saveLastThreeUserData(
            key: AppConstants.lastLoggedInWithOTP,
            value: DateTime.now().toString());
      }
      pushToHomeScreen();
    } else if (state is LoginFailedState) {
      pinCode.clear();
      pinfocus.unfocus();

      if (state.errorCode == AppConstants.accountBlockedErrorCode) {
        resetPIN();
        loginBloc.add(UpdateIsForgotPinForUserEvent(
            await AppStore().getSavedDataFromAppStorage(userIdKey), 'true'));

        _showErrorBottomSheet(
          _appLocalizations.pinBlocked,
          state.errorMsg,
          _appLocalizations.unblockPin,
          true,
        );
      } else if (state.errorCode == AppConstants.reregisterMpinErrorCode) {
        resetPIN();
        _showErrorBottomSheet(
          _appLocalizations.reregisterMpin,
          state.errorMsg,
          _appLocalizations.reregisterPin,
          true,
        );
      } else if (state.errorCode == AppConstants.passwordChangedErrorCode ||
          state.errorCode == AppConstants.passwordChangedErrorCode2) {
        List<dynamic>? lastThreeUserLoginDetails =
            await AppStorage().getData(lastThreeUserLoginDetailsKey);
        late String uid;
        for (var element in lastThreeUserLoginDetails!) {
          if (element[accNameConstants] == username) {
            uid = element[uidConstants];
          }
        }
        if (!mounted) {
          return;
        }
        showToast(
          isCenter: true,
          context: context,
          message: state.errorMsg,
          isError: true,
        );
        await AppUtils().removeCurrentUser();
        pushAndRemoveUntilNavigation(ScreenRoutes.loginScreen,
            arguments: LoginScreenArgs(clientId: uid));
      } else if (state.isInvalidException) {
        handleError(state);
        validateOtp.value = false;
      } else {
        isError.value = true;
        showToast(
          isCenter: true,
          context: context,
          message: state.errorMsg,
          isError: true,
        );
        pinfocus.requestFocus();
      }
    }
  }

  scheduledmaintenceBottomsheet() {
    showDialog(
        barrierColor: Colors.black.withOpacity(0.8),
        useSafeArea: true,
        context: navigatorKey.currentContext!,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'Maintenance Activity',
                        style: Theme.of(context).primaryTextTheme.titleSmall),
                    TextSpan(
                        text: "⏳",
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleMedium!
                            .copyWith(fontSize: 20.w)),
                  ]),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: AppImages.closeIcon(context,
                      width: AppWidgetSize.dimen_20,
                      height: AppWidgetSize.dimen_20,
                      color: Theme.of(context).primaryIconTheme.color,
                      isColor: true),
                )
              ],
            ),
            content: CustomTextWidget(
              "To ensure that you always get the best digital experience,we have daily maintenance activities scheduled from ${fromTime == null ? "--" : DateFormat("hh:mm aa").format(fromTime!.toLocal())} to ${toTime == null ? "--" : DateFormat("hh:mm aa").format(toTime!.toLocal())}.During this time,few features might not function properly.\n\nPlease login in post ${toTime == null ? "--" : DateFormat("hh:mm aa").format(toTime!.toLocal())} for a smooth experience.we're sorry for any inconvenience this may cause you.",
              Theme.of(context).primaryTextTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          );
        });
  }

  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> pushToHomeScreen() async {
    scaffoldkey.currentState?.hideCurrentMaterialBanner();

    scaffoldkey.currentState?.removeCurrentMaterialBanner();
    CacheRepository().clearCache(fromLogin: true);
    await StreamingManager().initConnection();
    pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen);
    sendUserId();
    String userId = await AppStore().getSavedDataFromAppStorage(userIdKey);
    setUserIdInFirebaseAnalytics(userId);
    showCampaign();
  }

  showCampaign() async {
    if (await CacheRepository.groupCache.get('getClientDetails') == null &&
        Featureflag.nomineeCampaign) {
      var data = await AppUtils().getsmartDetails();

      await MyAccountRepository().getClientDetails();
      if (!AppStore.isNomineeAvailable.value &&
          data["NomineeCampaign"] != "tapped") {
        await pushNavigation(ScreenRoutes.nomineeCampagin);
        AppUtils()
            .saveLastThreeUserData(key: "NomineeCampaign", value: "tapped");
      }
    }
  }

  Future<void> sendUserId() async {
    AppUtils.setAccDetails();
    String userId = await AppStore().getSavedDataFromAppStorage(userIdKey);
    setUserIdInFirebaseAnalytics(userId);
  }

  Future<void> resetPIN() async {
    await AppUtils().saveLastThreeUserData();
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        exitToLogin();
        return false;
      },
      child: Scaffold(
        key: scaffoldMessengerKey,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: false,
          elevation: 0.0,
          toolbarHeight: AppWidgetSize.dimen_80,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          actions: [appBarActionsWidget(context)],
        ),
        body: SingleChildScrollView(reverse: true, child: _buildBody()),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (skipbiometric && enterPin.value)
              Padding(
                padding: EdgeInsets.all(AppWidgetSize.dimen_20),
                child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(children: [
                      TextSpan(
                        text: _appLocalizations.note,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: _appLocalizations.enableBiometricsfromSettings,
                        style: Theme.of(context).primaryTextTheme.labelSmall!,
                      )
                    ])),
              ),
            const SupportAndCallBottom(),
          ],
        ),
      ),
    );
  }

  Padding appBarActionsWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: AppWidgetSize.dimen_25),
      child: Center(
        child: GestureDetector(
          onTap: () async {
            sendEventToFirebaseAnalytics(
              AppEvents.smartloginSwitchaccount,
              ScreenRoutes.smartLoginScreen,
              'Switch account button selected and will show switch account popup to switch accounts',
            );
            isError.value = false;
            await SwitchAccount.switchAccount(context);
          },
          child: CustomTextWidget(
            _appLocalizations.switchAccount,
            Theme.of(context).primaryTextTheme.headlineSmall,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<bool>(
        valueListenable: validateOtp,
        builder: (context, value, _) {
          return ValueListenableBuilder<Object>(
              valueListenable: enterPin,
              builder: (context, value, _) {
                return Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10.w, bottom: 20.h),
                        child: AppImages.arihantlaunchlogo(
                          context,
                          height: 40.w,
                          width: AppWidgetSize.dimen_280,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildTitleSection(),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: Column(
                              children: [
                                inputFieldSection(),
                                SizedBox(
                                  height: 40.w,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              });
        });
  }

  buildTitleSection() {
    return FutureBuilder<Object>(
        future: AppStore().getSavedDataFromAppStorage(userIdKey),
        builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  sendEventToFirebaseAnalytics(
                    AppEvents.smartloginEnterpin,
                    ScreenRoutes.smartLoginScreen,
                    'smart login enter pin focus is requested and will show keypad to enter pin',
                  );
                  pinfocus.requestFocus();
                },
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: CustomTextWidget(_appLocalizations.welcomeBack,
                      Theme.of(context).textTheme.displayLarge,
                      textAlign: TextAlign.left),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 8.h),
                child: CustomTextWidget(
                    "${AppStore().getuserName()} /s(${snapshot.data.toString()})/s",
                    Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.left),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 34.w),
                child: (!validateOtp.value)
                    ? CustomTextWidget(
                        enterPin.value
                            ? _appLocalizations.welcomeBackDescription
                            : _appLocalizations.welcomeBackDescriptionBiometric,
                        Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(fontWeight: FontWeight.w400),
                      )
                    : Container(),
              ),
            ],
          );
        });
  }

  int start = 30;
  bool wait = false;

  resendOtpSection() {
    return Container(
      margin: EdgeInsets.only(top: AppWidgetSize.dimen_5),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 200.w,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 20.w,
              ),
              child: start == 0
                  ? Container()
                  : Row(
                      children: [
                        CustomTextWidget(
                          _appLocalizations.setResentOtpDescription,
                          Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(fontWeight: FontWeight.w400),
                        ),
                        Flexible(
                          child: CustomTextWidget(
                            start.toString(),
                            Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(fontWeight: FontWeight.w400),
                          ),
                        ),
                        CustomTextWidget(
                          _appLocalizations.setResentSecs,
                          Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(
            child: InkWell(
              onTap: start == 0
                  ? () async {
                      sendEventToFirebaseAnalytics(
                        AppEvents.smartloginResendotp,
                        ScreenRoutes.smartLoginScreen,
                        'Resend otp is selected',
                      );
                      loginBloc.add(TwoFOTPGenerate());
                      isError.value = false;
                    }
                  : null,
              child: Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: CustomTextWidget(
                  _appLocalizations.setResentOtp,
                  start == 0
                      ? Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.w400)
                      : Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(fontWeight: FontWeight.w400),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  FocusNode pinfocus = FocusNode();

  Container inputFieldSection() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_20,
              right: 20.w,
            ),
            child: Column(
              children: [
                if (enterPin.value)
                  InkWell(
                      onTap: () {
                        sendEventToFirebaseAnalytics(
                          AppEvents.smartloginEnterpin,
                          ScreenRoutes.smartLoginScreen,
                          'smart login enter pin focus is requested and will show keypad to enter pin',
                        );
                        pinfocus.requestFocus();
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 30.w),
                            child: CustomTextWidget(
                              validateOtp.value
                                  ? _appLocalizations.enterOtp
                                  : _appLocalizations.enterPin,
                              Theme.of(context)
                                  .primaryTextTheme
                                  .labelLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: isError,
                            builder: (context, value, _) {
                              return SecureTextInputWidget(
                                validateOtp.value
                                    ? changeInputOtp
                                    : changeInput,
                                pincode: pinCode,
                                focusNode: pinfocus,
                                error: isError.value,
                                autoFocus: false,
                              );
                            },
                          )
                        ],
                      )),
                if (!validateOtp.value && enterPin.value) forgotPin(),
                if (validateOtp.value) resendOtpSection(),
                if (!enterPin.value)
                  InkWell(
                    onTap: () {
                      sendEventToFirebaseAnalytics(
                        AppEvents.smartloginBiometric,
                        ScreenRoutes.smartLoginScreen,
                        'Biometric option is selected to login',
                      );
                      biometricButtonPressed();
                    },
                    child: BiometricImage(
                      context: context,
                    ),
                  ),
                if (!enterPin.value)
                  Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_40),
                    child: GestureDetector(
                      onTap: () {
                        sendEventToFirebaseAnalytics(
                          AppEvents.smartloginEnterpin,
                          ScreenRoutes.smartLoginScreen,
                          'smart login enter pin focus is requested and will show keypad to enter pin',
                        );
                        enterPin.value = true;
                        pinfocus.requestFocus();
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomTextWidget(
                            isOTPValidatedin24Hours
                                ? _appLocalizations.orElseEnterPin
                                : _appLocalizations.enterPinandOtp,
                            Theme.of(context).primaryTextTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (biometricOption && !validateOtp.value && enterPin.value)
                  useBiometrics()
                else if (isBiometricAvailable && validateOtp.value)
                  enableBiometrics()
              ],
            ),
          ),
        ],
      ),
    );
  }

  enableBiometrics() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_40),
      child: GestureDetector(
        onTap: () {
          sendEventToFirebaseAnalytics(
            AppEvents.smartloginsetBiometric,
            ScreenRoutes.smartLoginScreen,
            'Set Biometric option is selected to login',
          );
          AppStorage().setData("skipBiometric", false);
          CacheRepository().clearCache(fromLogin: true);
          StreamingManager().initConnection();
          pinfocus.unfocus();
          enterPin.value = false;
          pushReplaceNavigation(ScreenRoutes.setBiometricScreen);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: BiometricImageSmall(
                  context: context,
                )),
            CustomTextWidget(
              _appLocalizations.setBiometrics,
              Theme.of(context).primaryTextTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }

  useBiometrics() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_40),
      child: GestureDetector(
        onTap: () {
          sendEventToFirebaseAnalytics(
            AppEvents.smartloginBiometric,
            ScreenRoutes.smartLoginScreen,
            'Biometric option is selected to login',
          );
          pinfocus.unfocus();
          enterPin.value = false;
          biometricButtonPressed();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: BiometricImageSmall(
                  context: context,
                )),
            CustomTextWidget(
              _appLocalizations.loginWithBiometrics,
              Theme.of(context).primaryTextTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }

  Align forgotPin() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(
          top: 10.w,
          right: 40.w,
        ),
        child: GestureDetector(
          onTap: () async {
            sendEventToFirebaseAnalytics(
              AppEvents.smartloginForgotpin,
              ScreenRoutes.smartLoginScreen,
              'Forgot pin is selected and will move to Login screen',
            );
            isError.value = false;
            List<dynamic>? lastThreeUserLoginDetails =
                await AppStorage().getData(lastThreeUserLoginDetailsKey);
            late String uid;
            for (var element in lastThreeUserLoginDetails!) {
              if (element[accNameConstants] == username) {
                uid = element[uidConstants];
              }
            }
            AppUtils().saveLastThreeUserData(
                key: isForgotPinConstants, value: 'true');
            pushAndRemoveUntilNavigation(
              ScreenRoutes.loginScreen,
              arguments: LoginScreenArgs(
                isForgotPin: "true",
                clientId: uid,
              ),
            );
          },
          child: CustomTextWidget(
            _appLocalizations.forgotPin,
            Theme.of(context).primaryTextTheme.titleLarge,
          ),
        ),
      ),
    );
  }

  Future<void> changeInput(dynamic data, {String? type}) async {
    pinCode.text = data;
    if (data.length == 4) {
      loginBloc.add(LoginPinEvent(
        data,
        isLoginPin,
      ));
      isError.value = false;
    }
  }

  Future<void> changeInputOtp(dynamic data, {String? type}) async {
    pinCode.text = data;
    if (data.length == 4) {
      loginBloc.add(Validate2FOtpEvent(
        data,
      ));
      isError.value = false;
    }
  }

  TextEditingController pinCode = TextEditingController();

  void _showErrorBottomSheet(
    String title,
    String description,
    String buttonTitle,
    bool isUnblockAccount,
  ) {
    showInfoBottomsheet(
        WillPopScope(
          onWillPop: () async => false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextWidget(
                      title, Theme.of(context).textTheme.displayMedium),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_24,
                  bottom: 30.w,
                ),
                child: CustomTextWidget(
                  description,
                  Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(fontWeight: FontWeight.w400),
                ),
              ),
              Center(
                child: gradientButtonWidget(
                  onTap: () async {
                    List<dynamic>? lastThreeUserLoginDetails =
                        await AppStorage()
                            .getData(lastThreeUserLoginDetailsKey);

                    late String uid;
                    for (var element in lastThreeUserLoginDetails!) {
                      if (element[accNameConstants] == username) {
                        uid = element[uidConstants];
                      }
                    }
                    if (title == _appLocalizations.reregisterMpin) {
                      sendEventToFirebaseAnalytics(
                        AppEvents.reregisterMpinSubmit,
                        ScreenRoutes.smartLoginScreen,
                        'ReregisterPin is selected and will move to login screen ',
                      );
                      await AppUtils().removeCurrentUser(uid: uid);
                      pushAndRemoveUntilNavigation(ScreenRoutes.loginScreen,
                          arguments: LoginScreenArgs(clientId: uid));
                    } else {
                      sendEventToFirebaseAnalytics(
                        AppEvents.forgotpinSubmit,
                        ScreenRoutes.smartLoginScreen,
                        'Forgot pin is selected and will move to login screen',
                      );
                      loginBloc.add(UpdateIsForgotPinForUserEvent(uid, 'true'));
                      pushAndRemoveUntilNavigation(ScreenRoutes.loginScreen,
                          arguments: LoginScreenArgs(clientId: uid));
                    }
                  },
                  width: AppWidgetSize.dimen_280,
                  key: const Key(bottomSheetButtonKey),
                  context: context,
                  title: buttonTitle,
                  isGradient: true,
                ),
              ),
            ],
          ),
        ),
        isdimissible: false);
  }

  bool skipbiometric = false;
  bool isOTPValidatedin24Hours = false;
  Future<void> getBiometricStatus() async {
    if (Featureflag.setOtpExpiry == 0) {
      await AppUtils().saveLastThreeUserData(
          key: AppConstants.lastLoggedInWithOTP, value: null);
    }
    var userDetails = await AppUtils().getsmartDetails();
    isOTPValidatedin24Hours =
        ((userDetails?[AppConstants.lastLoggedInWithOTP] != null
            ? DateTime.now()
                    .difference(DateTime.parse(
                        userDetails?[AppConstants.lastLoggedInWithOTP]))
                    .inHours <
                Featureflag.setOtpExpiry
            : false));

    if (isOTPValidatedin24Hours || !generateOTP) {
      username = AppStore().getAccountName();
      bool checkBiometrics =
          await BiometricWidget().checkBiometrics(checkSkipBio: false);
      skipbiometric = (await AppStorage().getData("skipBiometric")) ?? false;
      isBiometricAvailable = checkBiometrics;
      checkBiometrics = skipbiometric ? false : checkBiometrics;
      final dynamic getSmartLoginDetails =
          await AppUtils().getsmartDetails(userName: username);
      if (getSmartLoginDetails != null) {
        if (username == getSmartLoginDetails['accName']) {
          postSetState(function: () {
            biometricToken = getSmartLoginDetails['token'] ?? "";
          });

          if (((getSmartLoginDetails['biometric'] ?? false)) &&
              (getSmartLoginDetails['token'] != null)) {
            biometricOption = checkBiometrics;
          } else {
            biometricOption = false;
          }
        } else {
          biometricOption = false;
        }
      }
      if (biometricOption) {
        enterPin.value = false;
        await Future.delayed(const Duration(milliseconds: 500));
        await biometricButtonPressed();
      } else {
        enterPin.value = true;
        pinfocus.requestFocus();
      }
    } else {
      enterPin.value = true;
      validateOtp.value = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        pinfocus.requestFocus();
      });
      loginBloc.add(TwoFOTPGenerate());
    }
  }

  void postSetState({Function()? function}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          if (function != null) {
            function();
          }
        });
      }
    });
  }

  Future<void> biometricButtonPressed() async {
    try {
      final bool checkBiometrics = await BiometricWidget().authenticate(
          _appLocalizations.authenticateFingerPrint,
          cancel: true);
      if (biometricOption) {
        if (checkBiometrics) {
          loginBloc.add(LoginBiometricEvent(biometricToken));
        } else {
          Future.delayed(const Duration(milliseconds: 200), () {
            pinfocus.requestFocus();
          });
        }
      }
    } catch (e) {
      pinfocus.requestFocus();
    }
  }

  @override
  exitToLogin() {
    showInfoBottomsheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            _appLocalizations.arihant,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.w, bottom: 20.h),
            child: Text(
              _appLocalizations.exitAppMsg,
              style: Theme.of(context).textTheme.headlineMedium!,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  sendEventToFirebaseAnalytics(
                    AppEvents.exitloginCancel,
                    ScreenRoutes.smartLoginScreen,
                    'cancel is selected from exit login popup',
                  );
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations().cancel,
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              GestureDetector(
                onTap: () {
                  sendEventToFirebaseAnalytics(
                    AppEvents.exitloginProcced,
                    ScreenRoutes.smartLoginScreen,
                    'Procced is selected from exit login popup',
                  );
                  Navigator.pop(context);
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
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

  enableBiometricsToast() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_40),
      child: GestureDetector(
        onTap: () {
          AppStorage().setData("skipBiometric", false);

          showToast(
              message:
                  "Biometrics is Enabled, Now Enter Pin to Set Biometrics");
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: BiometricImageSmall(
                  context: context,
                )),
            CustomTextWidget(
              _appLocalizations.setBiometrics,
              Theme.of(context).primaryTextTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
