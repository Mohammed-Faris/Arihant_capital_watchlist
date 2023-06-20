import 'dart:io';

import 'package:acml/src/constants/app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:msil_library/utils/config/infoIDConfig.dart';

import '../../../../../blocs/login/login_bloc.dart';
import '../../../../../config/app_config.dart';
import '../../../../../constants/keys/login_keys.dart';
import '../../../../../data/store/app_storage.dart';
import '../../../../../data/store/app_store.dart';
import '../../../../../data/store/app_utils.dart';
import '../../../../../localization/app_localization.dart';
import '../../../../navigation/screen_routes.dart';
import '../../../../styles/app_widget_size.dart';
import '../../../../widgets/biometric_image.dart';
import '../../../../widgets/biometric_widget.dart';
import '../../../../widgets/custom_text_widget.dart';
import '../../../../widgets/gradient_button_widget.dart';
import '../../../../widgets/loader_widget.dart';
import '../../../acml_app.dart';
import '../../../base/base_screen.dart';
import '../../support.dart';

class SetBiometricScreen extends BaseScreen {
  const SetBiometricScreen({Key? key}) : super(key: key);

  @override
  SetBiometricScreenState createState() => SetBiometricScreenState();
}

class SetBiometricScreenState extends BaseAuthScreenState<SetBiometricScreen> {
  BiometricType? biometricType;
  bool biometricOption = false;
  late AppLocalizations _appLocalizations;
  late LoginBloc loginBloc;

  @override
  void initState() {
    super.initState();
    biometricType =
        Platform.isIOS ? BiometricType.face : BiometricType.fingerprint;
    checkBiometrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginBloc = BlocProvider.of<LoginBloc>(context)
        ..stream.listen(_loginBlocListner);
    });
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.setBiometricScreen);
  }

  Future<void> _loginBlocListner(LoginState state) async {
    if (state is RegisterBiometricDoneState) {
      pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen);
    } else if (state is LoginFailedState) {
      showToast(isError: true, message: state.errorMsg);

      if (state.errorCode == InfoIDConfig.invalidSessionCode) {
        handleError(state);
      }
    }
  }

  @override
  void exitToLogin() {
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
              "Are you sure you want to exit the app?",
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
                child: Text(AppLocalizations().cancel,
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              GestureDetector(
                onTap: () {
                  popNavigation();
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else if (Platform.isIOS) {
                    exit(0);
                  }
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

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return WillPopScope(
        onWillPop: () async {
          exitToLogin();
          return false;
        },
        child: Scaffold(
          bottomNavigationBar: const SupportAndCallBottom(),
          appBar: AppBar(
            centerTitle: false,
            elevation: 0.0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            automaticallyImplyLeading: false,
            actions: [appBarActionsWidget(context)],
          ),
          body: _buildBody(),
        ));
  }

  Widget appBarActionsWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        sendEventToFirebaseAnalytics(
          AppEvents.biometricSkip,
          ScreenRoutes.setBiometricScreen,
          'Skip button is selected and will move to smartlogin screen',
        );
        skipBiometric();
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
            ScreenRoutes.smartLoginScreen, (e) => false,
            arguments: {"generateOTP": true});
        AppStorage().setData("skipBiometric", true);
      },
      child: Padding(
        padding: EdgeInsets.only(right: AppWidgetSize.dimen_25),
        child: Center(
          child: CustomTextWidget(
            _appLocalizations.loginViaOtp,
            Theme.of(context)
                .primaryTextTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      height: AppWidgetSize.fullHeight(context),
      padding: EdgeInsets.all(AppWidgetSize.dimen_30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildTopSection(),
          _buildBottomWidget(),
        ],
      ),
    );
  }

  Widget buildTopSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: CustomTextWidget(
              biometricType == BiometricType.fingerprint
                  ? _appLocalizations.setFingerPrintAuthentication
                  : _appLocalizations.setFaceIdAuthentication,
              Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.start),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_54),
          child: CustomTextWidget(
            biometricType == BiometricType.fingerprint
                ? _appLocalizations.setFingerPrintDescription
                : _appLocalizations.setFaceIdDescription,
            Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(fontWeight: FontWeight.w400),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_14),
          child: Center(
            child: CustomTextWidget(
              biometricType == BiometricType.fingerprint
                  ? _appLocalizations.fingerPrintAuthentication
                  : _appLocalizations.faceIdAuthentication,
              Theme.of(context)
                  .primaryTextTheme
                  .labelLarge!
                  .copyWith(fontWeight: FontWeight.w400),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => getBiometricAuthentication(),
          child: BiometricImage(
            context: context,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomWidget() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if (state is LoginProgressState) {
          return const LoaderWidget();
        }
        return Center(
          child: gradientButtonWidget(
            onTap: () => getBiometricAuthentication(),
            width: AppWidgetSize.dimen_280,
            key: const Key(biometricButtonKey),
            context: context,
            title: biometricType == BiometricType.fingerprint
                ? _appLocalizations.setFingerPrint
                : _appLocalizations.setFaceId,
            isGradient: true,
          ),
        );
      },
    );
  }

  Future<void> getBiometricAuthentication() async {
    sendEventToFirebaseAnalytics(
      AppEvents.setbiometicAuthenticate,
      ScreenRoutes.confirmationScreen,
      'Biomteric authentication is triggered',
    );
    bool checkBiometrics = false;
    try {
      checkBiometrics = await BiometricWidget()
          .authenticate(_appLocalizations.authenticateFingerPrint);
      if (biometricOption) {
        if (checkBiometrics) {
          loginBloc.add(RegisterBiometricEvent());
          String userId =
              await AppStore().getSavedDataFromAppStorage(userIdKey);

          setUserIdInFirebaseAnalytics(userId);
        }
      }
    } on PlatformException catch (e) {
      if (e.code == "NotAvailable" || e.code == "NotEnrolled") {
        showToast(
          message: AppLocalizations().biometricNotavailable,
          context: context,
          isError: true,
        );
        pushAndRemoveUntilNavigation(
          ScreenRoutes.smartLoginScreen,
          arguments: {"generateOTP": true},
        );
        AppStorage().setData("skipBiometric", true);
      } else {
        showToast(
          message: AppLocalizations().maxAttempts,
          context: context,
          isError: true,
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (AppConfig.twoFA) {
            navigatorKey.currentState?.pushNamedAndRemoveUntil(
                ScreenRoutes.smartLoginScreen, (e) => false,
                arguments: {"generateOTP": true});
          } else {
            navigatorKey.currentState?.pushNamedAndRemoveUntil(
                ScreenRoutes.homeScreen, (e) => false);
          }
        });
      }
    }
  }

  Future<void> checkBiometrics() async {
    final bool checkBiometrics = await BiometricWidget().checkBiometrics();
    final List getAvailableBiometrics =
        await BiometricWidget().getAvailableBiometrics();

    if (checkBiometrics) {
      if (getAvailableBiometrics.isNotEmpty) {
        setState(() {
          biometricOption = true;
          biometricType = getAvailableBiometrics[0];
        });
      } else {
        setState(() {
          biometricOption = true;
        });
      }
    }
  }

  Future<void> skipBiometric() async {
    await AppUtils().saveLastThreeUserData(biometric: false);
  }
}
