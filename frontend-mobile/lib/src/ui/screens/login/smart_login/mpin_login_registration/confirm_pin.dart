import 'package:acml/src/constants/app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/login/login_bloc.dart';
import '../../../../../config/app_config.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../constants/keys/login_keys.dart';
import '../../../../../data/repository/order/order_repository.dart';
import '../../../../../data/store/app_storage.dart';
import '../../../../../data/store/app_utils.dart';
import '../../../../../localization/app_localization.dart';
import '../../../../navigation/screen_routes.dart';
import '../../../../styles/app_widget_size.dart';
import '../../../../widgets/custom_text_widget.dart';
import '../../../../widgets/secure_input_widget.dart';
import '../../../base/base_screen.dart';
import '../../support.dart';

class ConfirmPinScreen extends BaseScreen {
  final dynamic arguments;
  const ConfirmPinScreen({Key? key, this.arguments}) : super(key: key);

  @override
  ConfrimPinScreenState createState() => ConfrimPinScreenState();
}

class ConfrimPinScreenState extends BaseScreenState<ConfirmPinScreen> {
  late AppLocalizations _appLocalizations;
  late LoginBloc loginBloc;
  ValueNotifier<bool> isError = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    if (Featureflag.fetchOrderfromSocket) {
      OrderRepository().connectOrdersocket();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginBloc = BlocProvider.of<LoginBloc>(context)
        ..stream.listen(_loginBlocListner);
      Future.delayed(const Duration(milliseconds: 500), () {
        pinfocus.requestFocus();
      });
    });
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.confirmPinScreen);
  }

  Future<void> setPIN() async {
    var logindetails = await AppStorage().getData(userLoginDetailsKey);
    logindetails["pinStatus"] = "";
    AppStorage().setData(userLoginDetailsKey, logindetails);

    await AppUtils().saveLastThreeUserData(
        biometric: false, token: "", userName: logindetails["accName"]);
  }

  Future<void> _loginBlocListner(LoginState state) async {
    if (state is LoginProgressState) {
      startLoader();
    }
    if (state is! LoginProgressState) {
      stopLoader();
    }

    if (state is RegisterPinDoneState) {
      setPIN();
      pushAndRemoveUntilNavigation(ScreenRoutes.confirmationScreen);
    } else if (state is LoginFailedState) {
      pincode.clear();
      if (state.errorCode == AppConstants.invalidSessionErrorCode) {
        showToast(
          isCenter: true,
          context: context,
          message: state.errorMsg,
          isError: true,
        );
        await AppUtils().removeCurrentUser();
        pushAndRemoveUntilNavigation(ScreenRoutes.loginScreen);
      } else {
        showToast(
          isCenter: true,
          context: context,
          message: state.errorMsg,
          isError: true,
        );
        isError.value = true;
        popNavigation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      bottomNavigationBar: const SupportAndCallBottom(),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: backIconButton(onTap: () => Navigator.of(context).pop()),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      height: AppWidgetSize.fullHeight(context),
      padding: EdgeInsets.all(AppWidgetSize.dimen_30),
      child: Wrap(
        children: [
          buildTitleSection(),
          inputFieldSection(),
          SizedBox(
            height: 40.w,
          ),
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
          child: CustomTextWidget(
            _appLocalizations.setPin,
            Theme.of(context).textTheme.displayLarge,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_54),
          child: CustomTextWidget(
            _appLocalizations.reSetPinDescription,
            Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Container inputFieldSection() {
    return Container(
      margin: EdgeInsets.only(top: AppWidgetSize.dimen_50),
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 30.w),
            child: CustomTextWidget(
              _appLocalizations.reEnterPin,
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
                error: isError.value,
                pincode: pincode,
                focusNode: pinfocus,
                autoFocus: false,
              );
            },
          ),
        ],
      ),
    );
  }

  FocusNode pinfocus = FocusNode();

  TextEditingController pincode = TextEditingController();
  int failureCount = 0;
  Future<void> changeInput(String data, {String? type}) async {
    if (data.length == 4) {
      if (widget.arguments['pin'] == data) {
        sendEventToFirebaseAnalytics(
          AppEvents.confirmPinSuccess,
          ScreenRoutes.setPinScreen,
          'Confirm pin is done and will move to confrimation screen',
        );
        Future.delayed(const Duration(milliseconds: 500), (() {
          loginBloc.add(RegisterPinEvent(data));
        }));
      } else {
        pincode.clear();
        sendEventToFirebaseAnalytics(
          AppEvents.confirmPinFailure,
          ScreenRoutes.confirmPinScreen,
          _appLocalizations.pinNotMatchingErrorDescription,
        );
        showToast(
          isCenter: true,
          context: context,
          message: _appLocalizations.pinNotMatchingErrorDescription,
          isError: true,
        );
        failureCount++;
        isError.value = true;

        if (failureCount == 3) {
          sendEventToFirebaseAnalytics(
            AppEvents.confirmPinFailure,
            ScreenRoutes.confirmPinScreen,
            _appLocalizations.maxTryError,
          );
          showToast(
              isCenter: true,
              message: _appLocalizations.maxTryError,
              isError: true);
          popNavigation();
        }
      }
    }
  }
}
