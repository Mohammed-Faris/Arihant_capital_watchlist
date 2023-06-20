// ignore_for_file: deprecated_member_use

import 'package:acml/src/constants/app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../blocs/login/login_bloc.dart';
import '../../../../config/app_config.dart';
import '../../../../constants/keys/login_keys.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_color.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../validator/dob_validator.dart';
import '../../../validator/input_validator.dart';
import '../../../widgets/gradient_button_widget.dart';
import '../../../widgets/webview_widget.dart';
import '../../base/base_screen.dart';
import '../../route_generator.dart';
import '../support.dart';

class ForgotPasswordScreen extends BaseScreen {
  final dynamic arguments;

  const ForgotPasswordScreen({Key? key, this.arguments}) : super(key: key);

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends BaseScreenState<ForgotPasswordScreen> {
  late LoginBloc loginBloc;
  late AppLocalizations _appLocalizations;

  final TextEditingController _userIdController =
      TextEditingController(text: '');
  final TextEditingController _dobController = TextEditingController(text: '');
  FocusNode userNameFocusNode = FocusNode();
  FocusNode dobFocusNode = FocusNode();
  bool hidePassword = true;
  String selectedUidKey = userIdKey;
  bool isUserNameError = false;
  bool isDobError = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginBloc = BlocProvider.of<LoginBloc>(context)
        ..stream.listen(loginBlocListner);
      _userIdController.text = widget.arguments["uuid"];
    });
    if (widget.arguments["uuid"] != null) {
      dobFocusNode.requestFocus();
    }
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.forgetPasswordScreen);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (mounted) {
          if (ModalRoute.of(context)?.settings.name.toString() ==
              ScreenRoutes.forgetPasswordScreen) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (userNameFocusNode.hasFocus) {
                userNameFocusNode.unfocus();
                Future.delayed(const Duration(milliseconds: 200), () {
                  userNameFocusNode.requestFocus();
                });
              }

              if (dobFocusNode.hasFocus) {
                dobFocusNode.unfocus();
                Future.delayed(const Duration(milliseconds: 200), () {
                  dobFocusNode.requestFocus();
                });
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

  @override
  void dispose() {
    // _userIdController.clear();
    _dobController.clear();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  Future<void> loginBlocListner(LoginState state) async {
    if (state is! LoginProgressState) {
      stopLoader();
    }
    if (state is LoginProgressState) {
      startLoader();
    } else if (state is GenerateOtpDoneState) {
      var uid = state.generateOtpModel.data['uid'];
      showToast(
          isCenter: true,
          context: context,
          message: state.generateOtpModel.infoMsg);
      pushNavigation(
        ScreenRoutes.confirmOtpScreen,
        arguments: {
          'selectedUidKey': "uid",
          'uuid': uid,
          'infoMsg': state.generateOtpModel.infoMsg,
          'isNew': widget.arguments["userName"] != null,
          'dob': _dobController.text,
        },
      );
    } else if (state is LoginFailedState) {
      showToast(
        isCenter: true,
        context: context,
        message: state.errorMsg,
        isError: true,
      );
    }
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: false,
          elevation: 0.0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          title: backIconButton(
            onTap: () {
              exitToLogin();
            },
          ),
          actions: [appBarActionsWidget(context)],
        ),
        body: Padding(
          padding: EdgeInsets.only(bottom: 25.h),
          child: _buildBody(),
        ),
        bottomNavigationBar: const SupportAndCallBottom(),
        floatingActionButton: _buildBottomWidget(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Padding appBarActionsWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: AppWidgetSize.dimen_25),
      child: Center(
        child: GestureDetector(
          onTap: () {
            sendEventToFirebaseAnalytics(
              AppEvents.needHelp,
              ScreenRoutes.forgetPasswordScreen,
              'Need help button selected and will move to Arihant need help webview',
            );
            String? url = AppConfig.boUrls?.firstWhereOrNull(
                (element) => element["key"] == "contactUs")?["value"];
            Navigator.push(
              context,
              SlideRoute(
                  settings: const RouteSettings(
                    name: ScreenRoutes.inAppWebview,
                  ),
                  builder: (BuildContext context) =>
                      WebviewWidget("Contact Us", url ?? "")),
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

  Widget _buildBody() {
    return SingleChildScrollView(
      reverse: true,
      child: Padding(
          padding: EdgeInsets.only(
              bottom: AppWidgetSize.screenHeight(context) * 0.08),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.all(AppWidgetSize.dimen_30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTitleSection(),
                buildInputSection(),
              ],
            ),
          )),
    );
  }

  Widget buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: customTextWidget(
              widget.arguments["userName"] != null
                  ? "Welcome ${widget.arguments["userName"]}"
                  : _appLocalizations.forgotPassword,
              Theme.of(context).textTheme.displayLarge),
        ),
        customTextWidget(
          widget.arguments["userName"] != null
              ? _appLocalizations.verifyDetails
              : _appLocalizations.forgetPasswordDescription,
          Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget buildInputSection() {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_30),
      child: Column(
        children: [
          TextFormField(
            key: const Key(loginUserNameTextFieldKey),
            showCursor: !(widget.arguments["userName"] != null),
            toolbarOptions: const ToolbarOptions(
              copy: false,
              cut: false,
              paste: false,
              selectAll: false,
            ),
            autocorrect: false,
            enabled: true,
            readOnly: widget.arguments["userName"] != null,
            enableInteractiveSelection: true,
            keyboardType: TextInputType.text,
            focusNode: userNameFocusNode,
            onTap: () {
              if (!userNameFocusNode.hasFocus) {
                dobFocusNode.unfocus();
                userNameFocusNode.requestFocus();
              }
            },
            onChanged: (String text) {
              setState(() {});
            },
            style: Theme.of(context)
                .primaryTextTheme
                .labelLarge!
                .copyWith(fontWeight: FontWeight.w400),
            inputFormatters: InputValidator.username,
            textCapitalization: TextCapitalization.none,
            controller: _userIdController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                left: 15.w,
                top: 12.w,
                bottom: 12.w,
                right: 10.w,
              ),
              labelText: _appLocalizations.userIdTitle,
              labelStyle: Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(
                      color: isUserNameError
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .color),
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.w),
                borderSide: BorderSide(
                    color: isUserNameError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isUserNameError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).dividerColor,
                    width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isUserNameError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).dividerColor,
                    width: 1),
              ),
            ),
            maxLength: 50,
          ),
          SizedBox(
            height: AppWidgetSize.dimen_35,
          ),
          TextFormField(
            autocorrect: false,
            enabled: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            enableInteractiveSelection: false,
            focusNode: dobFocusNode,
            onChanged: (String text) {
              setState(() {});
            },
            inputFormatters: InputValidator.dob,
            onTap: () {
              if (!dobFocusNode.hasFocus) {
                userNameFocusNode.unfocus();
                dobFocusNode.requestFocus();
              }
            },
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            controller: _dobController,
            style: Theme.of(context)
                .primaryTextTheme
                .labelLarge!
                .copyWith(fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                left: 15.w,
                top: 12.w,
                bottom: 12.w,
                right: 10.w,
              ),
              hintText: "DD/MM/YYYY",
              errorStyle: Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(color: Theme.of(context).colorScheme.error),
              labelText: _appLocalizations.dob,
              labelStyle: Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(
                      color: isDobError
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .color),
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.w),
                borderSide: BorderSide(
                    color: isDobError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDobError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDobError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).dividerColor),
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  dobFocusNode.unfocus();

                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950, 1),
                    lastDate: DateTime.now(),
                    helpText: "",
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.fromSwatch(
                            primarySwatch: MaterialColor(
                                AppColors().positiveColor.value,
                                AppColors.calendarPrimaryColorSwatch),
                          ),
                          textTheme: TextTheme(
                            labelSmall: TextStyle(
                              fontSize: AppWidgetSize.fontSize16.w,
                            ),
                          ),
                          // dialogBackgroundColor:
                          //     Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: child!,
                      );
                    },
                  ).then(
                    (pickedDate) {
                      if (pickedDate != null) {
                        final String formatted = formatter.format(pickedDate);
                        setState(
                          () {
                            _dobController.text = formatted.toString();
                          },
                        );
                      }
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(AppWidgetSize.dimen_8),
                  child: AppImages.calendarIcon(
                    context,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ),
            ),
            maxLength: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomWidget() {
    return Opacity(
      opacity:
          (_userIdController.text.isNotEmpty && _dobController.text.isNotEmpty)
              ? 1
              : 0.3,
      child: gradientButtonWidget(
        onTap: () {
          if (_userIdController.text.isNotEmpty &&
              _dobController.text.isNotEmpty) {
            sendEventToFirebaseAnalytics(
              AppEvents.forgotpasswordProceed,
              ScreenRoutes.forgetPasswordScreen,
              'Proceed button is selected and will move to login screen',
            );
            _onTap();
          }
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

  void _onTap() {
    final String username = _userIdController.text.trim();
    String selectedDob = AppUtils().getDateFormat(_dobController.text.trim());

    if (username.isEmpty) {
      showToast(
        isCenter: true,
        context: context,
        message: _appLocalizations.usernameMinimumError,
        isError: true,
      );
    } else if (selectedDob.length < 8 ||
        !DateFormatter.isValidDOB(_dobController.text.trim(), "dd/MM/yyyy")) {
      showToast(
        isCenter: true,
        context: context,
        message: _appLocalizations.invalidDOBError,
        isError: true,
      );
    } else if (_userIdController.text.contains(RegExp(r'^\d{10}$'))) {
      selectedUidKey = mobileNumKey;
      sendOtp(mobileNumKey, _userIdController.text.trim(), selectedDob);
    } else if (_userIdController.text
        .contains(RegExp('[a-z0-9]+@[a-z]+.[a-z]{2,3}'))) {
      selectedUidKey = emailIdKey;
      sendOtp(emailIdKey, _userIdController.text.trim(), selectedDob);
    } else if (_userIdController.text.contains(RegExp(r"^[a-zA-Z0-9]+$"))) {
      selectedUidKey = userIdKey;
      sendOtp(userIdKey, _userIdController.text.trim(), selectedDob);
    } else {
      showToast(
        isCenter: true,
        context: context,
        message: _appLocalizations.invalidUid,
        isError: true,
      );
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
