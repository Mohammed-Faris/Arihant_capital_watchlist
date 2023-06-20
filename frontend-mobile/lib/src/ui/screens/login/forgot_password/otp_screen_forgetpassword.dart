import 'dart:async';

import 'package:acml/src/constants/app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/login/login_bloc.dart';
import '../../../../config/app_config.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/secure_input_widget.dart';
import '../../../widgets/webview_widget.dart';
import '../../base/base_screen.dart';
import '../../route_generator.dart';
import '../support.dart';

class ConfirmOtpScreen extends BaseScreen {
  final dynamic arguments;
  const ConfirmOtpScreen({Key? key, this.arguments}) : super(key: key);

  @override
  ConfirmOtpScreenState createState() => ConfirmOtpScreenState();
}

class ConfirmOtpScreenState extends BaseScreenState<ConfirmOtpScreen>
    with TickerProviderStateMixin {
  late AppLocalizations _appLocalizations;
  late LoginBloc loginBloc;
  ValueNotifier<bool> isError = ValueNotifier<bool>(false);
  int start = 30;
  int errorStartValue = 0;
  bool wait = false;
  bool isSuccessMessage = false;

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
            isSuccessMessage = false;
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginBloc = BlocProvider.of<LoginBloc>(context)
        ..stream.listen(_loginBlocListner);
    });
    starttimer();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.confirmOtpScreen);
  }

  Future<void> _loginBlocListner(LoginState state) async {
    if (state is LoginProgressState) {
      startLoader();
    }
    if (state is! LoginProgressState) {
      stopLoader();
    }
    if (state is GenerateOtpDoneState) {
      showToast(
        isCenter: true,
        context: context,
        message: state.generateOtpModel.infoMsg,
      );
      start = 30;

      starttimer();
    } else if (state is ValidateOtpDoneState) {
      if (mounted) {
        setState(() {
          start == 0;
        });
      }

      pushAndRemoveUntilNavigation(ScreenRoutes.setNewPasswordScreen,
          arguments: {'uuid': widget.arguments['uuid']});
    } else if (state is LoginFailedState) {
      showToast(
        isCenter: true,
        context: context,
        message: state.errorMsg,
        isError: true,
      );
      pin.clear();
      pinfocus.requestFocus();
      isError.value = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Padding appBarActionsWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: AppWidgetSize.dimen_25),
      child: Center(
        child: GestureDetector(
          onTap: () {
            sendEventToFirebaseAnalytics(
              AppEvents.needHelp,
              ScreenRoutes.confirmOtpScreen,
              'Need help button selected and will move to Arihant need help webview',
            );
            Navigator.push(
              context,
              SlideRoute(
                settings: const RouteSettings(
                  name: ScreenRoutes.inAppWebview,
                ),
                builder: (BuildContext context) => WebviewWidget(
                  _appLocalizations.needHelp,
                  AppConfig.needHelpUrl,
                  key: Key(_appLocalizations.needHelp),
                ),
              ),
            );
          },
          child: customTextWidget(
            _appLocalizations.needHelp,
            Theme.of(context).primaryTextTheme.headlineSmall,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () {
        exitToLogin();
        return Future.delayed(const Duration(seconds: 0), () => false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          iconTheme: Theme.of(context)
              .iconTheme
              .copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
          centerTitle: false,
          elevation: 0.0,
          leadingWidth: 40.w,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: backIconButton(
                onTap: () {
                  exitToLogin();
                },
              )),
          actions: [appBarActionsWidget(context)],
        ),
        body: SingleChildScrollView(
          reverse: true,
          child: _buildBody(),
        ),
        bottomNavigationBar: const SupportAndCallBottom(),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(AppWidgetSize.dimen_30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTitleSection(),
          inputFieldSection(),
          resendOtpSection(),
        ],
      ),
    );
  }

  Widget buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: customTextWidget(
            widget.arguments["isNew"]
                ? _appLocalizations.verifyItsyou
                : _appLocalizations.forgotPassword,
            Theme.of(context).textTheme.displayLarge,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 35.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customTextWidget(
                widget.arguments["infoMsg"],
                Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  FocusNode pinfocus = FocusNode();

  Container inputFieldSection() {
    return Container(
      margin: EdgeInsets.only(top: AppWidgetSize.dimen_50),
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 30.w),
            child: customTextWidget(
              _appLocalizations.enterOtp,
              Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isError,
            builder: (context, value, _) {
              return SecureTextInputWidget(
                changeInput,
                pincode: pin,
                focusNode: pinfocus,
                key: const Key("otpverify"),
                error: isError.value,
                autoFocus: true,
              );
            },
          ),
        ],
      ),
    );
  }

  TextEditingController pin = TextEditingController();
  resendOtpSection() {
    return Container(
      margin: EdgeInsets.only(top: AppWidgetSize.dimen_5),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 220.w,
            child: Padding(
              padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_14,
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
                          child: customTextWidget(
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
                      isError.value = false;
                      sendEventToFirebaseAnalytics(
                        AppEvents.resentOtp,
                        ScreenRoutes.confirmOtpScreen,
                        'Resend otp is selected ',
                      );
                      sendOtp(
                        widget.arguments['selectedUidKey'],
                        widget.arguments['uuid'],
                        AppUtils().getDateFormat(widget.arguments['dob']),
                      );
                      isError.value = false;
                      setState(() {
                        wait = true;
                      });
                    }
                  : null,
              child: Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: customTextWidget(
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

  Future<void> changeInput(String data, {String? type}) async {
    isError.value = false;
    if (data.length == 4) {
      loginBloc.add(ValidateOtpEvent(widget.arguments['uuid'], data));
    }
  }

  void sendOtp(String key, String uid, String panNumber) {
    loginBloc.add(
      GenerateOtpEvent(key, uid, panNumber),
    );
  }

  Text customTextWidget(String title, TextStyle? style) {
    return Text(
      title,
      style: style,
    );
  }
}
