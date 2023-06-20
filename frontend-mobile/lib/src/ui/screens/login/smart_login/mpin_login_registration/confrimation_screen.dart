import 'package:acml/src/constants/app_events.dart';
import 'package:flutter/material.dart';

import '../../../../../config/app_config.dart';
import '../../../../../data/store/app_store.dart';
import '../../../../../localization/app_localization.dart';
import '../../../../navigation/screen_routes.dart';
import '../../../../styles/app_images.dart';
import '../../../../styles/app_widget_size.dart';
import '../../../../widgets/biometric_widget.dart';
import '../../../../widgets/custom_text_widget.dart';
import '../../../base/base_screen.dart';

class ConfirmationScreen extends BaseScreen {
  const ConfirmationScreen({Key? key}) : super(key: key);

  @override
  ConfirmationScreenState createState() => ConfirmationScreenState();
}

class ConfirmationScreenState extends BaseScreenState<ConfirmationScreen> {
  late AppLocalizations _appLocalizations;
  bool biometricOption = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkBiometricsAndNavigate();
    });
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.confirmationScreen);
  }

  Future<void> checkBiometricsAndNavigate() async {
    final bool checkBiometrics = await BiometricWidget().checkBiometrics();

    if (checkBiometrics) {
      final List getAvailableBiometrics =
          await BiometricWidget().getAvailableBiometrics();
      if (getAvailableBiometrics.isNotEmpty) {
        setState(() {
          biometricOption = true;
        });
      } else {
        setState(() {
          biometricOption = false;
        });
      }
    }
    if (biometricOption) {
      Future.delayed(const Duration(seconds: 2), () {
        if (AppConfig.twoFA) {
          pushNavigation(ScreenRoutes.setBiometricScreen);
        } else {
          pushNavigation(ScreenRoutes.homeScreen);
        }
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (AppConfig.twoFA) {
          sendEventToFirebaseAnalytics(
            AppEvents.confirmationSmarlogin,
            ScreenRoutes.confirmationScreen,
            '2FA is enabled so will move to Generate OTP',
          );
          pushAndRemoveUntilNavigation(ScreenRoutes.smartLoginScreen,
              arguments: {"generateOTP": true});
        } else {
          sendEventToFirebaseAnalytics(
            AppEvents.confirmationHome,
            ScreenRoutes.confirmationScreen,
            'Will move to homescreen',
          );
          pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      height: AppWidgetSize.fullHeight(context),
      padding: EdgeInsets.all(AppWidgetSize.dimen_30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTitleSection(),
          _buildImageWidget(),
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
          child: CustomTextWidget(_appLocalizations.welcome,
              Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.left),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: CustomTextWidget(AppStore().getAccountName(),
              Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.left),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_54),
          child: CustomTextWidget(
            _appLocalizations.welcomeDescription,
            Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget() {
    return Container(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_150,
        bottom: AppWidgetSize.dimen_140,
      ),
      //height: AppWidgetSize.halfHeight(context),
      width: AppWidgetSize.halfWidth(context),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AppImages.success(),
        ),
      ),
    );
  }
}
