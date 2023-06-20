import 'package:acml/src/constants/app_events.dart';
import 'package:flutter/material.dart';

import '../../../config/app_config.dart';
import '../../../constants/keys/onboarding_keys.dart';
import '../../../constants/storage_constants.dart';
import '../../../data/store/app_storage.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/webview_widget.dart';
import '../base/base_screen.dart';
import '../route_generator.dart';

class BordingScreen extends BaseScreen {
  const BordingScreen({Key? key}) : super(key: key);

  @override
  BordingScreenState createState() => BordingScreenState();
}

class BordingScreenState extends BaseScreenState<BordingScreen> {
  bool isLoader = true;
  late AppLocalizations _appLocalizations;
  int slideIndex = 0;
  int currentIndex = 0;
  final PageController _pageController = PageController(
    initialPage: 0,
  );

  bool end = false;

  @override
  void initState() {
    super.initState();
    AppStorage().setData(isOnboardingScreenShown, true);
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.onBoardingScreen);
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_100,
          bottom: 20.w,
        ),
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: PageView(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    currentIndex = value;
                  });
                },
                children: <Widget>[
                  Slider(
                    image: AppImages.bordingImage1(
                      context,
                      height: 200.w,
                      width: 120.w,
                    ),
                    text1: _appLocalizations.bording1,
                    text2: _appLocalizations.bording11,
                  ),
                  Slider(
                    image: AppImages.bordingImage2(
                      context,
                      height: 200.w,
                      width: 120.w,
                    ),
                    text1: _appLocalizations.bording2,
                    text2: _appLocalizations.bording22,
                  ),
                  Slider(
                    image: AppImages.bordingImage3(
                      context,
                      height: 200.w,
                      width: 120.w,
                    ),
                    text1: _appLocalizations.bording3,
                    text2: _appLocalizations.bording33,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 50.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => buildDot(index, context),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                gradientButtonWidget(
                  onTap: () {
                    sendEventToFirebaseAnalytics(
                      AppEvents.boardingArihant,
                      ScreenRoutes.onBoardingScreen,
                      'Join Arihant button selected and will move to Airhant signup webview',
                    );
                    Navigator.push(
                      context,
                      SlideRoute(
                        settings: const RouteSettings(
                          name: ScreenRoutes.inAppWebview,
                        ),
                        builder: (BuildContext context) => WebviewWidget(
                          _appLocalizations.joinArihant,
                          AppConfig.signUpUrl,
                          key: Key(_appLocalizations.joinArihant),
                        ),
                      ),
                    );
                  },
                  width: 300.w / 2,
                  key: const Key(onBoardingScreenJoinButtonKey),
                  context: context,
                  title: _appLocalizations.joinArihant,
                  isGradient: false,
                ),
                gradientButtonWidget(
                  onTap: () {
                    sendEventToFirebaseAnalytics(
                      AppEvents.boardingLogin,
                      ScreenRoutes.onBoardingScreen,
                      'Login button is selected and will move to Login screen',
                    );
                    pushAndRemoveUntilNavigation(ScreenRoutes.loginScreen);
                  },
                  width: 300.w / 2,
                  key: const Key(onBoardingScreenLoginButtonKey),
                  context: context,
                  title: _appLocalizations.login,
                  isGradient: true,
                ),
              ],
            )
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: AppWidgetSize.dimen_10,
      width: currentIndex == index
          ? AppWidgetSize.dimen_25
          : AppWidgetSize.dimen_10,
      margin: EdgeInsets.only(right: AppWidgetSize.dimen_5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(20.w),
        color: currentIndex == index ? Colors.green : Colors.white,
      ),
    );
  }
}

// slider declared
// ignore: must_be_immutable
class Slider extends StatelessWidget {
  Widget image;
  String text1;
  String text2;

  Slider(
      {Key? key, required this.image, required this.text1, required this.text2})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        image,
        Padding(
          padding: EdgeInsets.only(top: AppWidgetSize.dimen_60),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              Center(
                child: Text(
                  text1,
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge!
                      .copyWith(fontSize: AppWidgetSize.fontSize28),
                ),
              ),
              Center(
                child: Text(
                  text2,
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge!
                      .copyWith(fontSize: AppWidgetSize.fontSize28),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
