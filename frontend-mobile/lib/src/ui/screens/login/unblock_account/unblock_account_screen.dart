// ignore_for_file: deprecated_member_use

import 'package:acml/src/constants/app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../blocs/login/login_bloc.dart';
import '../../../../config/app_config.dart';
import '../../../../constants/app_constants.dart';
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
import '../login_screen.dart';

class UnBlockAccountScreen extends BaseScreen {
  final dynamic arguments;
  const UnBlockAccountScreen({Key? key, this.arguments}) : super(key: key);

  @override
  UnBlockAccountScreenState createState() => UnBlockAccountScreenState();
}

class UnBlockAccountScreenState extends BaseScreenState<UnBlockAccountScreen> {
  late LoginBloc loginBloc;
  late AppLocalizations _appLocalizations;

  final TextEditingController _userIdController =
      TextEditingController(text: '');
  final TextEditingController _dobController = TextEditingController(text: '');

  final FocusNode dobFocusNode = FocusNode();

  final FocusNode _userIdFocusNode = FocusNode();
  bool isUserNameError = false;
  bool isDobError = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginBloc = BlocProvider.of<LoginBloc>(context)
        ..stream.listen(loginBlocListner);
      if (widget.arguments != null) {
        _userIdController.text = widget.arguments["uuid"];
        dobFocusNode.requestFocus();
      }
    });
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.unBlockAccountScreen);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (mounted) {
          if (ModalRoute.of(context)?.settings.name.toString() ==
              ScreenRoutes.unBlockAccountScreen) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_userIdFocusNode.hasFocus) {
                _userIdFocusNode.unfocus();
                Future.delayed(const Duration(milliseconds: 200), () {
                  _userIdFocusNode.requestFocus();
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

  Future<void> loginBlocListner(LoginState state) async {
    if (state is! LoginProgressState) {
      stopLoader();
    }
    if (state is LoginProgressState) {
      startLoader();
    }
    if (state is UnBlockAccountDoneState) {
      showToast(
          isCenter: true,
          context: context,
          message: state.unblockAccountModel.infoMsg);
      pushAndRemoveUntilNavigation(ScreenRoutes.loginScreen,
          arguments: LoginScreenArgs(clientId: _userIdController.value.text));
    } else if (state is LoginFailedState) {
      showToast(
        isCenter: true,
        context: context,
        message: state.errorMsg,
        isError: true,
      );
      dobFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: backIconButton(onTap: () => Navigator.of(context).pop()),
        actions: [appBarActionsWidget(context)],
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 25.h),
        child: _buildBody(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildBottomWidget(),
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
              ScreenRoutes.unBlockAccountScreen,
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

  Widget _buildBody() {
    return SingleChildScrollView(
      reverse: true,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: AppWidgetSize.screenHeight(context) * 0.08),
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
        ),
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
            _appLocalizations.unblockAccount,
            Theme.of(context).textTheme.displayLarge,
          ),
        ),
        customTextWidget(
          _appLocalizations.unBlockAccountDescription,
          Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget buildInputSection() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_30),
      child: Column(
        children: [
          TextFormField(
            key: const Key(unblockAccountUserIdKey),
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
            focusNode: _userIdFocusNode,
            onChanged: (String text) {
              setState(() {});
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: InputValidator.username,
            controller: _userIdController,
            style: Theme.of(context)
                .primaryTextTheme
                .labelLarge!
                .copyWith(fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                left: AppWidgetSize.dimen_15,
                top: AppWidgetSize.dimen_12,
                bottom: AppWidgetSize.dimen_12,
                right: AppWidgetSize.dimen_10,
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
                        : Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isUserNameError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).dividerColor),
              ),
            ),
            maxLength: 50,
          ),
          SizedBox(
            height: AppWidgetSize.dimen_35,
          ),
          TextFormField(
            showCursor: true,
            toolbarOptions: const ToolbarOptions(
              copy: false,
              cut: false,
              paste: false,
              selectAll: false,
            ),
            key: const Key(unblockAccountDobKey),
            enableInteractiveSelection: true,
            autocorrect: false,
            enabled: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (String text) {
              setState(() {});
            },
            inputFormatters: InputValidator.dob,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            controller: _dobController,
            focusNode: dobFocusNode,
            autofocus: true,
            style: Theme.of(context)
                .primaryTextTheme
                .labelLarge!
                .copyWith(fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                left: AppWidgetSize.dimen_15,
                top: AppWidgetSize.dimen_12,
                bottom: AppWidgetSize.dimen_12,
                right: AppWidgetSize.dimen_10,
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
                key: const Key(unblockAccountCalendarIconKey),
                onTap: () {
                  sendEventToFirebaseAnalytics(
                    AppEvents.unblockaccountCalender,
                    ScreenRoutes.unBlockAccountScreen,
                    'calender button selected and will show calender widget for DOB input',
                  );
                  _userIdFocusNode.unfocus();
                  _displayDatePickerWidget(context);
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
            maxLength: 10,
          ),
        ],
      ),
    );
  }

  Future<void> _displayDatePickerWidget(BuildContext context) async {
    final DateTime? selectedDateOfBirth = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1920, 1),
      lastDate: DateTime.now(),
      helpText: "",
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: MaterialColor(AppColors().positiveColor.value,
                  AppColors.calendarPrimaryColorSwatch),
            ),
            textTheme: TextTheme(
              labelSmall: TextStyle(fontSize: AppWidgetSize.fontSize16),
            ),
            // dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: child!,
        );
      },
    );

    if (selectedDateOfBirth != null) {
      _dobController.text = _getdatevalue(
        selectedDateOfBirth,
        AppConstants.dateFormatConstantDDMMYYYY,
      );
      setState(() {});
    }
  }

  Widget _buildBottomWidget() {
    return Opacity(
      opacity: _userIdController.text.isEmpty || _dobController.text.isEmpty
          ? 0.3
          : 1,
      child: gradientButtonWidget(
        onTap: () {
          sendEventToFirebaseAnalytics(
            AppEvents.unblockaccountSubmit,
            ScreenRoutes.unBlockAccountScreen,
            'Submit button selected and will move to Login Screen for relogin',
          );
          isDobError = false;
          dobFocusNode.unfocus();
          if (_userIdController.text.isNotEmpty &&
              _dobController.text.isNotEmpty) _onTap();
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
      dobFocusNode.requestFocus();
    } else if (selectedDob.length < 8 ||
        !DateFormatter.isValidDOB(_dobController.text.trim(), "dd/MM/yyyy")) {
      showToast(
        isCenter: true,
        context: context,
        message: _appLocalizations.invalidDOBError,
        isError: true,
      );
      dobFocusNode.requestFocus();
    } else if (_userIdController.text.contains(RegExp(r"^\d{10}$"))) {
      loginBloc.add(UnBlockAccountEvent(
        mobileNumKey,
        _userIdController.text.trim(),
        selectedDob,
      ));
    } else if (_userIdController.text.contains(RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))) {
      loginBloc.add(UnBlockAccountEvent(
        emailIdKey,
        _userIdController.text.trim(),
        selectedDob,
      ));
    } else if (_userIdController.text.contains(RegExp(r"^[a-zA-Z0-9]+$"))) {
      loginBloc.add(UnBlockAccountEvent(
        uidKey,
        _userIdController.text.trim(),
        selectedDob,
      ));
    } else {
      showToast(
        isCenter: true,
        context: context,
        message: _appLocalizations.invalidUid,
        isError: true,
      );
      _userIdFocusNode.requestFocus();
    }
  }

  Text customTextWidget(String title, TextStyle? style) {
    return Text(
      title,
      style: style,
    );
  }

  static String _getdatevalue(DateTime date, String formateString) {
    final dynamic now = date;
    final dynamic formatter = DateFormat(formateString);
    return formatter.format(now);
  }
}
