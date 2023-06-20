// ignore_for_file: deprecated_member_use

import 'package:acml/src/constants/app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/login/login_bloc.dart';
import '../../../../config/app_config.dart';
import '../../../../constants/keys/login_keys.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../validator/input_validator.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/gradient_button_widget.dart';
import '../../../widgets/webview_widget.dart';
import '../../base/base_screen.dart';
import '../../route_generator.dart';
import '../login_screen.dart';
import '../support.dart';

class NewPasswordScreen extends BaseScreen {
  final dynamic arguments;
  const NewPasswordScreen({Key? key, this.arguments}) : super(key: key);

  @override
  NewPasswordScreenState createState() => NewPasswordScreenState();
}

class NewPasswordScreenState extends BaseScreenState<NewPasswordScreen> {
  late LoginBloc loginBloc;
  late AppLocalizations _appLocalizations;

  final TextEditingController _newpasswordController =
      TextEditingController(text: '');
  final TextEditingController _passwordController =
      TextEditingController(text: '');

  FocusNode passwordFocusNode = FocusNode();
  bool isSuccessMessage = false;
  bool isPasswordError = false;

  bool obscureCurrentPwd = true;
  bool obscureNewPwd = true;
  bool obscureConfirmPwd = true;
  bool isNewPwdError = false;
  bool isCnfPwdError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginBloc = BlocProvider.of<LoginBloc>(context)
        ..stream.listen(_loginBlocListner);
    });
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.setNewPasswordScreen);
  }

  Future<void> _loginBlocListner(LoginState state) async {
    if (state is LoginProgressState) {
      startLoader();
    }
    if (state is! LoginProgressState) {
      stopLoader();
    }

    if (state is ResetPasswordDoneState) {
      resetPIN();

      showToast(context: context, message: state.resetPasswordModel.infoMsg);
      pushAndRemoveUntilNavigation(
        ScreenRoutes.loginScreen,
        arguments: LoginScreenArgs(
          clientId: widget.arguments['uuid'],
        ),
      );
    } else if (state is LoginFailedState) {
      showToast(
        context: context,
        message: state.errorMsg,
        isError: true,
      );
    }
  }

  Future<void> resetPIN() async {
    await AppUtils().saveLastThreeUserData();
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
        body: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            centerTitle: false,
            elevation: 0.0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            automaticallyImplyLeading: false,
            title: backIconButton(onTap: () => exitToLogin()),
            actions: [appBarActionsWidget(context)],
          ),
          body: SingleChildScrollView(child: _buildBody()),
          bottomNavigationBar: _buildBottomWidget(),

          //  floatingActionButton: _buildBottomWidget(),
        ),
        bottomNavigationBar: const SupportAndCallBottom(),
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
              ScreenRoutes.setNewPasswordScreen,
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
      child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_35,
              right: AppWidgetSize.dimen_35,
              bottom: AppWidgetSize.dimen_60,
              top: AppWidgetSize.dimen_10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitleSection(),
              buildInputSection(),
              notesection(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      right: AppWidgetSize.dimen_7,
                      top: AppWidgetSize.dimen_7,
                    ),
                    child: Icon(
                      Icons.circle,
                      size: AppWidgetSize.dimen_6,
                      color: Theme.of(context).textTheme.displaySmall?.color,
                    ),
                  ),
                  Flexible(
                    child: CustomTextWidget(
                      _appLocalizations.minimumPasswordError,
                      Theme.of(context).textTheme.labelLarge!.copyWith(
                          fontWeight: FontWeight.w400, fontSize: 15.w),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              )
            ],
          )),
    );
  }

  Column notesection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: AppWidgetSize.dimen_35,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_5),
          child: CustomTextWidget(
            "Note : ",
            Theme.of(context).textTheme.labelLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.w,
                ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: CustomTextWidget(
            _appLocalizations.setNewPassword,
            Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: CustomTextWidget(
            _appLocalizations.setPasswordDescription,
            Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(fontWeight: FontWeight.w400),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: CustomTextWidget(
            _appLocalizations.setPasswordheader,
            Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  bool validateStructure(String value) {
    String pattern = ('^(?=.*[a-z])(?=.*[A-Z])(?=.*[-({}):;?!@#\$%^&*])');
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  validate() {
    _sendResetPassword();
  }

  Widget buildInputSection() {
    return Padding(
      padding: EdgeInsets.only(
        top: 20.w,
        bottom: 20.w,
      ),
      child: Column(
        children: [
          TextFormField(
            autocorrect: false,
            enabled: true,
            autofocus: true,
            textInputAction: TextInputAction.next,
            inputFormatters: InputValidator.loginPassword,
            showCursor: true,
            enableInteractiveSelection: true,
            toolbarOptions: const ToolbarOptions(
              copy: false,
              cut: false,
              paste: false,
              selectAll: false,
            ),
            onChanged: (t) {
              setState(() {});
            },
            controller: _newpasswordController,
            style: Theme.of(context)
                .primaryTextTheme
                .labelLarge!
                .copyWith(fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                left: AppWidgetSize.fontSize15.w,
                top: 7.w,
                bottom: 7.w,
                right: 10.w,
              ),
              labelText: _appLocalizations.newPassword,
              counterText: '',
              labelStyle: Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(
                      color: isNewPwdError
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .color),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.w),
                borderSide: BorderSide(
                    color: isNewPwdError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).dividerColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isNewPwdError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).dividerColor,
                    width: 1),
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    obscureNewPwd = !obscureNewPwd;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(AppWidgetSize.dimen_8),
                  child: _newpasswordController.text != ""
                      ? obscureNewPwd
                          ? AppImages.eyeOpenIcon(
                              context,
                              color: Theme.of(context).iconTheme.color,
                            )
                          : AppImages.eyeClosedIcon(
                              context,
                              color: Theme.of(context).iconTheme.color,
                            )
                      : null,
                ),
              ),
            ),
            obscureText: obscureNewPwd,
            maxLength: 16,
          ),
          SizedBox(
            height: AppWidgetSize.dimen_35,
          ),
          TextFormField(
            autocorrect: false,
            enabled: true,
            enableInteractiveSelection: true,
            toolbarOptions: const ToolbarOptions(
              copy: false,
              cut: false,
              paste: false,
              selectAll: false,
            ),
            onChanged: (String text) {
              setState(() {});
            },
            controller: _passwordController,
            style: Theme.of(context)
                .primaryTextTheme
                .labelLarge!
                .copyWith(fontWeight: FontWeight.w400),
            inputFormatters: InputValidator.loginPassword,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                left: AppWidgetSize.fontSize15.w,
                top: 7.w,
                bottom: 7.w,
                right: 10.w,
              ),
              labelText: _appLocalizations.confirmPassword,
              counterText: '',
              labelStyle: Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(
                      color: isCnfPwdError
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .color),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.w),
                borderSide: BorderSide(
                    color: isCnfPwdError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).dividerColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isCnfPwdError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).dividerColor,
                    width: 1),
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  sendEventToFirebaseAnalytics(
                    AppEvents.passwordEyeicon,
                    ScreenRoutes.setNewPasswordScreen,
                    obscureConfirmPwd
                        ? 'password is hidden'
                        : 'password is not hidden',
                  );
                  setState(() {
                    obscureConfirmPwd = !obscureConfirmPwd;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(AppWidgetSize.dimen_8),
                  child: _passwordController.text.isNotEmpty
                      ? obscureConfirmPwd
                          ? AppImages.eyeOpenIcon(
                              context,
                              color: Theme.of(context).iconTheme.color,
                            )
                          : AppImages.eyeClosedIcon(
                              context,
                              color: Theme.of(context).iconTheme.color,
                            )
                      : null,
                ),
              ),
            ),
            obscureText: obscureConfirmPwd,
            maxLength: 16,
          ),
        ],
      ),
    );
  }

  // Widget _buildBottomWidget() {
  //   return Center(
  //     child: Column(
  //       children: [
  //         SizedBox(
  //           height:20.w,
  //         ),
  //         Opacity(
  //           opacity: _newpasswordController.text.isEmpty ||
  //                   _passwordController.text.isEmpty
  //               ? 0.3
  //               : 1,
  //           child: gradientButtonWidget(
  //             onTap: () {
  //               validate();
  //             },
  //             bottom: 0,
  //             width: AppWidgetSize.dimen_280,
  //             key: const Key(loginSubmitButtonKey),
  //             context: context,
  //             title: _appLocalizations.proceed,
  //             isGradient: true,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildBottomWidget() {
    return Opacity(
      opacity: _newpasswordController.text.isEmpty ||
              _passwordController.text.isEmpty
          ? 0.3
          : 1,
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: AppWidgetSize.dimen_50,
            vertical: AppWidgetSize.dimen_25),
        child: gradientButtonWidget(
          onTap: () {
            if (_newpasswordController.text.isNotEmpty &&
                _passwordController.text.isNotEmpty) {
              sendEventToFirebaseAnalytics(
                AppEvents.setnewpasswordProceed,
                ScreenRoutes.setNewPasswordScreen,
                'Proceed button is selected in New password screen',
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
      ),
    );
  }

  void _onTap() {
    bool hasDigits = _newpasswordController.text.contains(RegExp(r'[0-9]'));
    bool hasLowercase =
        _newpasswordController.text.contains(RegExp(r'[a-z]')) ||
            _newpasswordController.text.contains(RegExp(r'[A-Z]'));
    if (_passwordController.text == _newpasswordController.text) {
      if (_passwordController.text.isEmpty ||
          _passwordController.text.length < 8) {
        showToast(
          context: context,
          message: _appLocalizations.minimumPasswordError,
          isError: true,
        );
      } else if (!(hasDigits && hasLowercase)) {
        showToast(
          context: context,
          message: _appLocalizations.passwordAlphaNumValidation,
          isError: true,
        );
      } else {
        setnewPassword(
            widget.arguments['uuid'], _passwordController.text.trim());
      }
    } else {
      showToast(
        context: context,
        message: _appLocalizations.passwordMismatch,
        isError: true,
      );
    }
  }

  void _sendResetPassword() {
    final String password = _newpasswordController.text.trim();

    if (password.isEmpty || password.length < 8) {
      showToast(
        context: context,
        message: _appLocalizations.minimumPasswordError,
        isError: true,
      );
    } else {
      _onTap();
    }
  }

  void setnewPassword(String uuid, String confirmpassword) {
    loginBloc.add(
      ResetPasswordEvent(uuid, confirmpassword),
    );
  }
}
