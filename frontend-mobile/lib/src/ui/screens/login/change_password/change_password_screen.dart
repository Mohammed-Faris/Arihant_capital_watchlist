// ignore_for_file: deprecated_member_use

import 'package:acml/src/constants/app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/login/login_bloc.dart';
import '../../../../config/app_config.dart';
import '../../../../constants/keys/login_keys.dart';
import '../../../../data/store/app_storage.dart';
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

class ChangePasswordScreenArgs {
  final String? uid;

  ChangePasswordScreenArgs(this.uid);
}

class ChangePasswordScreen extends BaseScreen {
  const ChangePasswordScreen({
    Key? key,
    this.args,
  }) : super(key: key);
  final ChangePasswordScreenArgs? args;
  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends BaseScreenState<ChangePasswordScreen> {
  late LoginBloc loginBloc;
  late AppLocalizations _appLocalizations;

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confrimPasswordController =
      TextEditingController();

  bool obscureCurrentPwd = true;
  bool obscureNewPwd = true;
  bool obscureConfirmPwd = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginBloc = BlocProvider.of<LoginBloc>(context)
        ..stream.listen(loginBlocListner);
    });
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.changePasswordScreen);
  }

  Future<void> loginBlocListner(LoginState state) async {
    if (state is! LoginProgressState) {
      stopLoader();
    }
    if (state is LoginProgressState) {
      startLoader();
    }
    if (state is ChangePasswordDoneState) {
      resetPIN();
      List lastThreeUser =
          await AppStorage().getData(lastThreeUserLoginDetailsKey);

      // showToast(
      //     context: context, message: AppLocalizations().passwordChangedToast);
      if (!mounted) {
        return;
      }
      showToast(
        isCenter: true,
        context: context,
        message: state.changePasswordModel.infoMsg,
      );
      await AppUtils().removeCurrentUser();
      pushAndRemoveUntilNavigation(ScreenRoutes.loginScreen,
          arguments: LoginScreenArgs(
              clientId: widget.args?.uid ?? lastThreeUser[0]["uid"]));
    } else if (state is LoginFailedState) {
      showToast(
        isCenter: true,
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: backIconButton(onTap: () => Navigator.of(context).pop()),
        actions: [appBarActionsWidget(context)],
      ),
      resizeToAvoidBottomInset: true,
      body: _buildBody(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20.w),
            child: _buildBottomWidget(),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 0.w),
            child: const SupportAndCallBottom(),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
              ScreenRoutes.changePasswordScreen,
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
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        buildTitleSection(),
        Padding(
          padding: EdgeInsets.only(top: AppWidgetSize.dimen_20),
          child: buildInputSection(),
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
            Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        CustomTextWidget(
          _appLocalizations.setPasswordDescription,
          Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          enableSuggestions: false,
          key: const Key(changePasswordOldPasswordKey),
          autocorrect: false,
          showCursor: true,
          enableInteractiveSelection: true,
          toolbarOptions: const ToolbarOptions(
            copy: false,
            cut: false,
            paste: false,
            selectAll: false,
          ),
          enabled: true,
          onChanged: (String text) {
            setState(() {});
          },
          textInputAction: TextInputAction.next,
          inputFormatters: InputValidator.loginPassword,
          keyboardType: TextInputType.text,
          controller: _oldPasswordController,
          style: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
              fontWeight: FontWeight.w400, decoration: TextDecoration.none),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(
              left: AppWidgetSize.fontSize15.w,
              top: 7.w,
              bottom: 7.w,
              right: 10.w,
            ),
            labelText: _appLocalizations.oldPassword,
            labelStyle: Theme.of(context).primaryTextTheme.labelSmall,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.w),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).dividerColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).dividerColor, width: 1),
            ),
            suffixIcon: GestureDetector(
              key: const Key(changePasswordEyeIconFieldKey1),
              onTap: () {
                sendEventToFirebaseAnalytics(
                  AppEvents.passwordEyeicon,
                  ScreenRoutes.changePasswordScreen,
                  obscureConfirmPwd
                      ? 'password is hidden'
                      : 'password is not hidden',
                );
                setState(() {
                  obscureCurrentPwd = !obscureCurrentPwd;
                });
              },
              child: Padding(
                padding: EdgeInsets.all(AppWidgetSize.dimen_8),
                child: _oldPasswordController.text.isNotEmpty
                    ? obscureCurrentPwd
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
          obscureText: obscureCurrentPwd,
          maxLength: 16,
        ),
        SizedBox(
          height: AppWidgetSize.dimen_35,
        ),
        TextFormField(
          key: const Key(changePasswordNewPasswordKey),
          showCursor: true,
          enableInteractiveSelection: true,
          toolbarOptions: const ToolbarOptions(
            copy: false,
            cut: false,
            paste: false,
            selectAll: false,
          ),
          autocorrect: false,
          enabled: true,
          onChanged: (String text) {
            setState(() {});
          },
          textInputAction: TextInputAction.next,
          inputFormatters: InputValidator.loginPassword,
          keyboardType: TextInputType.text,
          controller: _newPasswordController,
          style: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
              fontWeight: FontWeight.w400, decoration: TextDecoration.none),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(
              left: AppWidgetSize.fontSize15.w,
              top: 7.w,
              bottom: 7.w,
              right: 10.w,
            ),
            labelText: _appLocalizations.newPassword,
            labelStyle: Theme.of(context).primaryTextTheme.labelSmall,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.w),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).dividerColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).dividerColor, width: 1),
            ),
            suffixIcon: GestureDetector(
              key: const Key(changePasswordEyeIconFieldKey2),
              onTap: () {
                setState(() {
                  obscureNewPwd = !obscureNewPwd;
                });
              },
              child: Padding(
                padding: EdgeInsets.all(AppWidgetSize.dimen_8),
                child: _newPasswordController.text.isNotEmpty
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
          key: const Key(changePasswordConfirmPasswordKey),
          autocorrect: false,
          showCursor: true,
          enableInteractiveSelection: true,
          toolbarOptions: const ToolbarOptions(
            copy: false,
            cut: false,
            paste: false,
            selectAll: false,
          ),
          enabled: true,
          onChanged: (String text) {
            setState(() {});
          },
          inputFormatters: InputValidator.loginPassword,
          controller: _confrimPasswordController,
          style: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
              fontWeight: FontWeight.w400, decoration: TextDecoration.none),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(
              left: AppWidgetSize.fontSize15.w,
              top: 7.w,
              bottom: 7.w,
              right: 10.w,
            ),
            labelText: _appLocalizations.confirmPassword,
            labelStyle: Theme.of(context).primaryTextTheme.labelSmall,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.w),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).dividerColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).dividerColor, width: 1),
            ),
            suffixIcon: GestureDetector(
              key: const Key(changePasswordEyeIconFieldKey3),
              onTap: () {
                setState(() {
                  obscureConfirmPwd = !obscureConfirmPwd;
                });
              },
              child: Padding(
                padding: EdgeInsets.all(AppWidgetSize.dimen_8),
                child: _confrimPasswordController.text.isNotEmpty
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
        SizedBox(
          height: AppWidgetSize.dimen_35,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_5),
          child: CustomTextWidget(
            "Note : ",
            Theme.of(context).textTheme.labelLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: AppWidgetSize.fontSize15,
                ),
            textAlign: TextAlign.start,
          ),
        ),
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
                    fontWeight: FontWeight.w400,
                    fontSize: AppWidgetSize.fontSize15),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildBottomWidget() {
    return Container(
      //  height: 50.w,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Opacity(
        opacity: _oldPasswordController.text.isEmpty ||
                _newPasswordController.text.isEmpty ||
                _confrimPasswordController.text.isEmpty
            ? 0.3
            : 1,
        child: Container(
          //color: Colors.red,
          /*  margin: EdgeInsets.symmetric(
              horizontal: AppWidgetSize.dimen_50,
              vertical: AppWidgetSize.dimen_15), */
          child: gradientButtonWidget(
              onTap: () {
                if (_oldPasswordController.text.isNotEmpty &&
                    _newPasswordController.text.isNotEmpty &&
                    _confrimPasswordController.text.isNotEmpty) {
                  sendEventToFirebaseAnalytics(
                    AppEvents.changepasswordProceed,
                    ScreenRoutes.changePasswordScreen,
                    'Proceed button is selected and will move to Login Screen',
                  );
                  _sendResetPassword();
                }
              },
              width: AppWidgetSize.dimen_280,
              key: const Key(loginSubmitButtonKey),
              context: context,
              title: _appLocalizations.proceed,
              isGradient: true,
              bottom: 0),
        ),
      ),
    );
  }

  Future<void> _sendResetPassword() async {
    final String oldPassword = _oldPasswordController.text.trim();
    final String newPassword = _newPasswordController.text.trim();
    final String confrimPassword = _confrimPasswordController.text.trim();
    bool hasDigits = newPassword.contains(RegExp(r'[0-9]'));
    bool hasLowercase = newPassword.contains(RegExp(r'[a-z]')) ||
        newPassword.contains(RegExp(r'[A-Z]'));
    if (newPassword.isEmpty || newPassword.length < 8) {
      showToast(
        isCenter: true,
        context: context,
        message: _appLocalizations.minimumPasswordError,
        isError: true,
      );
    } else if (newPassword != confrimPassword) {
      showToast(
        isCenter: true,
        context: context,
        message:
            _appLocalizations.newPasswordAndConfrimPasswordNotMatchingError,
        isError: true,
      );
    } else if (newPassword == oldPassword) {
      showToast(
        isCenter: true,
        context: context,
        message:
            _appLocalizations.currentPasswordAndNewPasswordShouldNotBeSameError,
        isError: true,
      );
    } else if (!(hasDigits && hasLowercase)) {
      showToast(
        isCenter: true,
        context: context,
        message: _appLocalizations.passwordAlphaNumValidation,
        isError: true,
      );
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
      loginBloc.add(ChangePasswordEvent(
        newPassword,
        oldPassword,
      ));
    }
  }
}
