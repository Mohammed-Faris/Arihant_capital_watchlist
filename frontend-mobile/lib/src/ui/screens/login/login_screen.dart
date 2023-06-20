import 'package:acml/src/config/app_config.dart';
import 'package:acml/src/constants/app_events.dart';
import 'package:acml/src/ui/screens/login/support.dart';
import 'package:acml/src/ui/widgets/acml_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:msil_library/streamer/stream/streaming_manager.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../blocs/login/login_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/keys/login_keys.dart';
import '../../../constants/storage_constants.dart';
import '../../../data/store/app_storage.dart';
import '../../../data/store/app_store.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../validator/input_validator.dart';
import '../../widgets/biometric_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/webview_widget.dart';
import '../base/base_screen.dart';
import '../route_generator.dart';
import 'change_password/change_password_screen.dart';
import 'smart_login/smart_login/switch_account.dart';

class LoginScreenArgs {
  String? clientId;
  String? userName;
  bool enableBiometric;
  String? isForgotPin;
  bool verifiedUid;
  LoginScreenArgs(
      {this.clientId,
      this.userName,
      this.enableBiometric = false,
      this.isForgotPin,
      this.verifiedUid = false});
}

class LoginScreen extends BaseScreen {
  final LoginScreenArgs? loginArgs;
  const LoginScreen(
    this.loginArgs, {
    Key? key,
  }) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends BaseScreenState<LoginScreen>
    with TickerProviderStateMixin {
  late LoginBloc loginBloc;
  late AppLocalizations _appLocalizations;
  final TextEditingController _userIdController =
      TextEditingController(text: '');
  final TextEditingController _passwordController =
      TextEditingController(text: '');
  bool hidePassword = true;
  bool isError = false;
  String errorMessage = "";
  bool isSuccessMessage = false;
  bool enablePasswordIcon = false;
  String pinStatus = "";
  String uid = "";
  bool isUserNameError = false;
  bool isPasswordError = false;
  bool enableBiometric = false;
  FocusNode usernameFocusNode = FocusNode();
  FocusNode passwordFocus = FocusNode();

  @override
  void initState() {
    getlastThreeUser();
    _clearDataRelatedToFunds();
    WidgetsBinding.instance.addObserver(this);
    loginBloc = BlocProvider.of<LoginBloc>(context)
      ..stream.listen(loginBlocListener);
    loginBloc.add(LoginInitEvent());

    super.initState();
    if (widget.loginArgs != null) {
      _userIdController.text = widget.loginArgs!.clientId ?? "";
      pinStatus = widget.loginArgs!.isForgotPin == "true" ? 'forgotPin' : "";
      enableBiometric = widget.loginArgs!.enableBiometric;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginBloc = BlocProvider.of<LoginBloc>(context)
        ..stream.listen(_loginBlocListner);
    });
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.loginScreen);
  }

  void _clearDataRelatedToFunds() {
    AppStorage().removeData('getBankdetailkey');
    AppStorage().removeData('getPaymentOptionkey');
    AppStorage().removeData('getRecentFundTransaction');
    AppStorage().removeData('getFundHistorydata');
    AppStorage().removeData('getFundViewUpdatedModel');
  }

  Future<void> _loginBlocListner(LoginState state) async {
    if (state is LoginProgressState) {
      startLoader();
    }
    if (state is! LoginProgressState) {
      stopLoader();
    }
    if (state is RegisterBiometricDoneState) {
      pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen);
    } else if (state is LoginFailedState) {}
    if (state is RetriveUserDoneState) {
      AppStore().setUserName(state.retriveUser.uName);

      if (state.retriveUser.userType == "NEW") {
        pushNavigation(ScreenRoutes.forgetPasswordScreen, arguments: {
          "uuid": _userIdController.text,
          "userName": state.retriveUser.uName
        });
      } else {
        var data =
            await AppUtils().getsmartDetails(uid: _userIdController.text);
        await pushNavigation(ScreenRoutes.loginScreen,
            arguments: LoginScreenArgs(
                enableBiometric: widget.loginArgs?.enableBiometric ?? false,
                isForgotPin: (data?[isForgotPinConstants]) ?? 'false',
                clientId: _userIdController.text,
                userName: state.retriveUser.uName,
                verifiedUid: true));
        _passwordController.clear();
        widget.loginArgs?.verifiedUid = false;
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    usernameFocusNode.dispose();
    passwordFocus.dispose();
    _userIdController.dispose();
    _passwordController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  Future<void> getBiometricAuthentication() async {
    bool checkBiometrics;

    try {
      checkBiometrics = await BiometricWidget()
          .authenticate(_appLocalizations.authenticateFingerPrint);
    } catch (e) {
      checkBiometrics = false;
    }
    if (checkBiometrics) {
      loginBloc.add(RegisterBiometricEvent());
    } else {
      if (!mounted) {
        return;
      }
      showToast(
        isCenter: true,
        message: AppLocalizations().biometricNotVerified,
        context: context,
        isError: true,
      );

      enableBiometric = false;
      pushNavigation(ScreenRoutes.smartLoginScreen);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (mounted) {
          if (ModalRoute.of(context)?.settings.name.toString() ==
              ScreenRoutes.loginScreen) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!((widget.loginArgs?.verifiedUid) ?? false)) {
                if (usernameFocusNode.hasFocus) {
                  usernameFocusNode.unfocus();
                  Future.delayed(const Duration(milliseconds: 200), () {
                    usernameFocusNode.requestFocus();
                  });
                }
              } else {
                if (passwordFocus.hasFocus) {
                  passwordFocus.unfocus();
                  Future.delayed(const Duration(milliseconds: 200), () {
                    passwordFocus.requestFocus();
                  });
                }
              }
            });
          }
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> loginBlocListener(LoginState state) async {
    if (state is! LoginProgressState) {
      stopLoader();
    }
    if (state is LoginProgressState) {
      startLoader();
    } else if (state is LoginDoneState) {
      _clearFields();
      shieldRegistration();
      StreamingManager().initConnection();
      if (enableBiometric) {
        FocusManager.instance.primaryFocus?.unfocus();
        getBiometricAuthentication();
      } else {
        if (state.tradingLoginModel.data["pinStatus"] == 'enterPin') {
          pushNavigation(ScreenRoutes.smartLoginScreen);
        } else {
          pushNavigation(ScreenRoutes.setPinScreen);
        }
      }
    } else if (state is LoginFailedState) {
      errorMessage = state.errorMsg;
      _passwordController.clear();
      showToast(
          isCenter: true,
          message: errorMessage,
          context: context,
          isError: true);
      if (state.errorCode == AppConstants.accountBlockedErrorCode) {
        setState(() {
          isError = true;
        });
        if (errorMessage.contains(AppConstants.pinBlockedErrorMessage)) {
          setState(() {
            pinStatus = 'forgotPin';
            uid = _userIdController.text;
          });

          _showBottomSheetAccount(
            _appLocalizations.pinBlocked,
            state.errorMsg,
            _appLocalizations.unblockPin,
            false,
            true,
          );
        } else {
          _showBottomSheetAccount(
            _appLocalizations.accountBlocked,
            _appLocalizations.accountBlockedDescription,
            _appLocalizations.unblockAccount,
            true,
            false,
          );
        }
      } else if (state.errorCode == AppConstants.changePasswordErrorCode) {
        _showBottomSheetAccount(
          _appLocalizations.passwordExpired,
          _appLocalizations.passwordExpiredDescription,
          _appLocalizations.passwordExpiryButton,
          false,
          false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0.0,
        leadingWidth: 40.w,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: (widget.loginArgs?.verifiedUid ?? false)
            ? Padding(
                padding: EdgeInsets.only(left: 10.w), child: backIconButton())
            : null,
        iconTheme: Theme.of(context).iconTheme.copyWith(
            color: Theme.of(context).primaryTextTheme.labelLarge!.color!,
            size: 30),
        actions: [
          (lastThreeUserLoginDetails?.isNotEmpty ?? false)
              ? appBarActionsWidget(context)
              : appBarActionsNeedHelpWidget(context)
        ],
      ),
      resizeToAvoidBottomInset: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: proceedButton(),
      body: Padding(
        padding: EdgeInsets.only(bottom: 70.0.w),
        child: _buildBody(),
      ),
      bottomNavigationBar: SafeArea(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildBottomWidget(), const SupportAndCallBottom()],
      )),
    );
  }

  BlocBuilder<LoginBloc, LoginState> proceedButton() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if (state is RetrivingUser) {
          return SizedBox(height: 50.w, child: const LoaderWidget());
        } else {
          return Opacity(
            opacity: _userIdController.text.isEmpty ||
                    ((widget.loginArgs?.verifiedUid ?? false)
                        ? _passwordController.text.isEmpty
                        : false)
                ? 0.3
                : 1,
            child: gradientButtonWidget(
              onTap: () {
                sendEventToFirebaseAnalytics(
                  AppEvents.usernameProceed,
                  ScreenRoutes.loginScreen,
                  'Username is entered and proceed is selected if success will take you to password screen else will throw error',
                );
                if (_userIdController.text.isNotEmpty &&
                    _passwordController.text.isEmpty &&
                    !(widget.loginArgs?.verifiedUid ?? false)) {
                  loginBloc
                      .add(RetriveUserEvent(uidtype(), _userIdController.text));
                }
                if (_userIdController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty) _onTap();
              },
              bottom: 0,
              width: AppWidgetSize.dimen_280,
              key: const Key(loginSubmitButtonKey),
              context: context,
              title: _appLocalizations.proceed,
              isGradient: true,
            ),
          );
        }
      },
    );
  }

  Padding appBarActionsWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: AppWidgetSize.dimen_25),
      child: Center(
        child: GestureDetector(
          onTap: () async {
            sendEventToFirebaseAnalytics(
              AppEvents.loginSwitchaccount,
              ScreenRoutes.loginScreen,
              'Login screen switch account is selected. It will given a set of possible users to login',
            );
            await SwitchAccount.switchAccount(
              context,
            );
          },
          child: CustomTextWidget(
            _appLocalizations.switchAccount,
            Theme.of(context).primaryTextTheme.headlineSmall,
          ),
        ),
      ),
    );
  }

  Padding appBarActionsNeedHelpWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: AppWidgetSize.dimen_25),
      child: Center(
        child: GestureDetector(
          onTap: () {
            sendEventToFirebaseAnalytics(
              AppEvents.loginNeedhelp,
              ScreenRoutes.loginScreen,
              'needhelp button selected and will move to need help webview',
            );
            pushNavigation(ScreenRoutes.loginNeedhelp);
          },
          child: CustomTextWidget(
            _appLocalizations.needHelp,
            Theme.of(context).primaryTextTheme.headlineSmall,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      reverse: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: 30.w, top: 10.w, bottom: AppWidgetSize.dimen_40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppImages.arihantlaunchlogo(
                  context,
                  height: 40.w,
                  width: AppWidgetSize.dimen_280,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.h),
                  child: AppImages.arihantpluslogo(
                    context,
                    height: 40.w,
                    width: AppWidgetSize.dimen_280,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.h),
                  child: CustomTextWidget(
                      widget.loginArgs?.userName != null
                          ? '${_appLocalizations.welcomeBack} ${widget.loginArgs?.userName}'
                          : _appLocalizations.login,
                      Theme.of(context).textTheme.displayLarge,
                      textOverflow: TextOverflow.visible,
                      textAlign: TextAlign.start),
                ),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_35,
                right: AppWidgetSize.dimen_35,
                bottom: AppWidgetSize.dimen_60,
                top: AppWidgetSize.dimen_10),
            child: buildInputSection(),
          ),
        ],
      ),
    );
  }

  Widget buildInputSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!((widget.loginArgs?.verifiedUid) ?? false))
          usernameField()
        else
          Column(
            children: [
              passwordfield(),
              Container(
                padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_15,
                ),
                alignment: Alignment.topRight,
                child: GestureDetector(
                  key: const Key(loginForgotPasswordKey),
                  onTap: () {
                    sendEventToFirebaseAnalytics(
                      AppEvents.loginForgotpassword,
                      ScreenRoutes.loginScreen,
                      'Forgot password button selected and will move to forgot password screen',
                    );
                    setState(() {
                      enablePasswordIcon = false;
                    });
                    _clearFields();
                    pushNavigation(
                      ScreenRoutes.forgetPasswordScreen,
                      arguments: {
                        'uuid': _userIdController.text,
                      },
                    );
                    //username = "";
                  },
                  child: Text(
                    _appLocalizations.forgotPassword,
                    style: Theme.of(context).primaryTextTheme.titleLarge,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  ACMLTextField usernameField() {
    return ACMLTextField(
      label: _appLocalizations.userIdTitle,
      textEditingController: _userIdController,
      isError: isUserNameError,
      focusNode: usernameFocusNode,
      autofocus: false,
      key: const Key(loginUserNameTextFieldKey),
      onFieldSubmitted: (s) {
        passwordFocus.requestFocus();
      },
      onChange: ((value) => setState(() {})),
      inputFormatters: InputValidator.username,
      maxLength: 50,
    );
  }

  ACMLTextField passwordfield() {
    return ACMLTextField(
      label: _appLocalizations.passwordTitle,
      textEditingController: _passwordController,
      isError: isPasswordError,
      focusNode: passwordFocus,
      key: const Key(loginPasswordTextFieldKey),
      onChange: (String text) {
        if (text.isNotEmpty) {
          setState(() {
            isPasswordError = false;
            enablePasswordIcon = true;
          });
        } else {
          setState(() {
            enablePasswordIcon = false;
          });
        }
      },
      suffixIcon: suffixIconPassword(),
      obscure: hidePassword,
      inputFormatters: InputValidator.loginPassword,
    );
  }

  suffixIconPassword() {
    return enablePasswordIcon
        ? hidePassword
            ? GestureDetector(
                key: const Key(loginEyeIconFieldKey),
                onTap: () {
                  sendEventToFirebaseAnalytics(
                    AppEvents.passwordEyeicon,
                    ScreenRoutes.loginScreen,
                    hidePassword
                        ? 'password eye icon clicked and is visible'
                        : 'password eye icon is clicked and is hidden',
                  );
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(AppWidgetSize.dimen_8),
                  child: hidePassword
                      ? AppImages.eyeOpenIcon(
                          context,
                          color: Theme.of(context).iconTheme.color,
                        )
                      : AppImages.eyeClosedIcon(
                          context,
                          color: Theme.of(context).iconTheme.color,
                        ),
                ),
              )
            : GestureDetector(
                key: const Key(loginEyeIconFieldKey),
                onTap: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(AppWidgetSize.dimen_8),
                  child: hidePassword
                      ? AppImages.eyeOpenIcon(
                          context,
                          color: Theme.of(context).iconTheme.color,
                        )
                      : AppImages.eyeClosedIcon(
                          context,
                          color: Theme.of(context).iconTheme.color,
                        ),
                ),
              )
        : Container(
            padding: EdgeInsets.all(AppWidgetSize.dimen_8),
            width: 20.w,
          );
  }

  Widget _buildBottomWidget() {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: AppWidgetSize.dimen_1),
                  child: CustomTextWidget(
                    _appLocalizations.signUpDescription,
                    Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: GestureDetector(
                    onTap: () async {
                      sendEventToFirebaseAnalytics(
                        AppEvents.loginSignup,
                        ScreenRoutes.loginScreen,
                        'sign up button selected and will move to Arihant signup webview',
                      );
                      _clearFields();

                      await Permission.microphone.request();
                      await Permission.camera.request();
                      await Permission.location.request();
                      await Permission.locationWhenInUse.request();
                      await Permission.accessMediaLocation.request();

                      if (mounted) {
                        Navigator.push(
                          context,
                          SlideRoute(
                            settings: const RouteSettings(
                              name: ScreenRoutes.inAppWebview,
                            ),
                            builder: (BuildContext context) => WebviewWidget(
                              _appLocalizations.signUp,
                              AppConfig.signUpUrl.trim(),
                              key: Key(_appLocalizations.signUp),
                            ),
                          ),
                        );
                      }
                    },
                    child: CustomTextWidget(
                      _appLocalizations.signUp,
                      Theme.of(context).primaryTextTheme.headlineSmall,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: AppWidgetSize.dimen_1, bottom: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextWidget(
                    _appLocalizations.poweredby,
                    Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                  CustomTextWidget(
                    _appLocalizations.arihantcapName,
                    Theme.of(context)
                        .primaryTextTheme
                        .labelSmall
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String uidtype() {
    if (_userIdController.text.contains(RegExp(r"^\d{10}$"))) {
      return mobileNumKey;
    } else if (_userIdController.text
        .contains(RegExp('[a-z0-9]+@[a-z]+.[a-z]{2,3}'))) {
      return emailIdKey;
    } else if (_userIdController.text.contains(RegExp(r"^[a-zA-Z0-9]+$"))) {
      return userIdKey;
    } else {
      return "";
    }
  }

  void _onTap() {
    _sendResetPassword();
    if (!isError) {
      if (_userIdController.text.contains(RegExp(r"^\d{10}$"))) {
        sendLoginRequest(mobileNumKey, _userIdController.text.trim(),
            _passwordController.text.trim());
      } else if (_userIdController.text
          .contains(RegExp('[a-z0-9]+@[a-z]+.[a-z]{2,3}'))) {
        sendLoginRequest(emailIdKey, _userIdController.text.trim(),
            _passwordController.text.trim());
      } else if (_userIdController.text.contains(RegExp(r"^[a-zA-Z0-9]+$"))) {
        sendLoginRequest(userIdKey, _userIdController.text.trim(),
            _passwordController.text.trim());
      } else {
        errorMessage = _appLocalizations.invalidUid;
        _clearFields();
        showToast(
            isCenter: true,
            context: context,
            message: errorMessage,
            isError: true);
        setState(() {
          isError = true;
        });
      }
    }
  }

  void _sendResetPassword() {
    final String password = _passwordController.text.trim();

    if (password.isEmpty) {
      _clearFields();
      errorMessage = _appLocalizations.passwordEmptyError;
      setState(() {
        isError = true;
      });
      _clearFields();
      showToast(
          isCenter: true,
          message: errorMessage,
          context: context,
          isError: true);
    } else {
      errorMessage = "";
      setState(() {
        isError = false;
        isUserNameError = false;
        isPasswordError = false;
      });
    }
  }

  Future<void> sendLoginRequest(
      String enteredIdKey, String enteredIdValue, String password) async {
    pinStatus = await getPinStatus(enteredIdValue);
    loginBloc.add(
      LoginSubmitEvent(
        enteredIdKey,
        enteredIdValue,
        password,
        pinStatus,
      ),
    );
  }

  Future<String> getPinStatus(String enteredIdValue) async {
    if (uid != enteredIdValue && pinStatus != 'forgotPin') {
      pinStatus = "";
    }
    List<dynamic>? lastThreeUserLoginDetails =
        await AppStorage().getData(lastThreeUserLoginDetailsKey);
    if (lastThreeUserLoginDetails != null) {
      for (var element in lastThreeUserLoginDetails) {
        if (element[uidConstants] == enteredIdValue &&
            element[isForgotPinConstants] != null &&
            element[isForgotPinConstants] == 'true') {
          pinStatus = 'forgotPin';
        }
      }
    }

    return pinStatus;
  }

  void _onUnblockAccountTapped() {
    _clearFields();
    Navigator.of(context).pop();
    pushNavigation(
      ScreenRoutes.unBlockAccountScreen,
      arguments: {
        'uuid': _userIdController.text,
      },
    );
  }

  void _onChangePasswordTapped() {
    _clearFields();
    Navigator.of(context).pop();
    pushNavigation(ScreenRoutes.changePasswordScreen,
        arguments: ChangePasswordScreenArgs(_userIdController.text));
  }

  void _showBottomSheetAccount(
    String title,
    String description,
    String buttonTitle,
    bool isUnblockAccount,
    bool isPinBlocked,
  ) {
    showInfoBottomsheet(
        WillPopScope(
          onWillPop: (() async => false),
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
              isUnblockAccount
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppWidgetSize.dimen_24,
                        bottom: 50.w,
                      ),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                                text: description,
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    showInfoBottomsheet(
                                      Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                CustomTextWidget(
                                                  _appLocalizations
                                                      .myaacountBlockedHeading,
                                                  Theme.of(context)
                                                      .textTheme
                                                      .displayMedium,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: AppImages.closeIcon(
                                                      context,
                                                      width: AppWidgetSize
                                                          .dimen_20,
                                                      height: AppWidgetSize
                                                          .dimen_20,
                                                      color: Theme.of(context)
                                                          .primaryIconTheme
                                                          .color,
                                                      isColor: true),
                                                )
                                              ],
                                            ),
                                            CustomTextWidget(
                                              "\n${_appLocalizations.myaacountBlocked}\n",
                                              Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .headlineSmall
                                                          ?.color,
                                                      fontWeight:
                                                          FontWeight.w500),
                                            ),
                                            CustomTextWidget(
                                                "${_appLocalizations.myaacountBlockeddesc1}\n",
                                                Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall),
                                            CustomTextWidget(
                                              "${_appLocalizations.myaacountBlockeddesc2}\n",
                                              Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall,
                                            ),
                                          ]),
                                    );
                                  },
                                text: _appLocalizations.learnMore,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context).primaryColor))
                          ])),
                    )
                  : Padding(
                      padding: EdgeInsets.only(
                        top: AppWidgetSize.dimen_24,
                        bottom: 50.w,
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
                  onTap: () {
                    isPinBlocked
                        ? Navigator.of(context).pop()
                        : isUnblockAccount
                            ? _onUnblockAccountTapped()
                            : _onChangePasswordTapped();
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

  format(DateTime date) {
    var suffix = "th";
    var digit = date.day % 10;
    if ((digit > 0 && digit < 4) && (date.day < 11 || date.day > 13)) {
      suffix = ["st", "nd", "rd"][digit - 1];
    }
    return DateFormat("dd'$suffix' MMM, yyyy hh:mm a").format(date);
  }

  void _clearFields() {
    // _passwordController.text = "";
  }

  List<dynamic>? lastThreeUserLoginDetails = [];
  Future<void> getlastThreeUser() async {
    lastThreeUserLoginDetails = await AppUtils().getAlluserDetails();
    setState(() {});
  }
}
