import '../../../config/app_config.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../widgets/webview_widget.dart';
import '../base/base_screen.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/card_widget.dart';
import '../../widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import '../../widgets/list_tile_widget.dart';
import '../route_generator.dart';

class HelpAndSupport extends BaseScreen {
  const HelpAndSupport({
    Key? key,
  }) : super(key: key);

  @override
  HelpAndSupportState createState() => HelpAndSupportState();
}

class HelpAndSupportState extends BaseScreenState<HelpAndSupport> {
  bool isBioMetricEnabled = false;
  bool isPushNotification = false;
  late AppLocalizations _appLocalizations;

  @override
  void initState() {
    super.initState();
    checkBiometricEnabled();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.helpAndSupport);
  }

  checkBiometricEnabled() async {
    dynamic getSmartLoginDetails = await AppUtils().getsmartDetails();
    if (getSmartLoginDetails['biometric'] == true) {
      setState(() {
        isBioMetricEnabled = true;
      });
    }
  }

  List<ListTileWidget> getHelpList(BuildContext context) {
    return [
      ListTileWidget(
        title: _appLocalizations.reportProblem,
        subtitle: '',
        leadingImage: AppImages.reportsProblem(context),
        onTap: () {
          Navigator.push(
            context,
            SlideRoute(
              settings: const RouteSettings(
                name: ScreenRoutes.inAppWebview,
              ),
              builder: (BuildContext context) => WebviewWidget(
                _appLocalizations.reportProblem,
                AppConfig.boUrls![25]["value"],
              ),
            ),
          );
        },
      ),
      ListTileWidget(
        title: _appLocalizations.readBlog,
        subtitle: '',
        leadingImage: AppImages.readBlog(context),
        onTap: () {
          Navigator.push(
            context,
            SlideRoute(
              settings: const RouteSettings(
                name: ScreenRoutes.inAppWebview,
              ),
              builder: (BuildContext context) => WebviewWidget(
                _appLocalizations.readBlog,
                AppConfig.boUrls![24]["value"],
              ),
            ),
          );
        },
      ),
      ListTileWidget(
        title: _appLocalizations.userguide,
        subtitle: '',
        leadingImage: AppImages.userGuide(context),
      ),
    ];
  }

  List<ListTileWidget> selectATopicList(BuildContext context) {
    return [
      ListTileWidget(
        title: _appLocalizations.myAccout,
        subtitle: '',
        leadingImage: AppImages.myAccout(context),
        onTap: () {
          Navigator.push(
            context,
            SlideRoute(
              settings: const RouteSettings(
                name: ScreenRoutes.inAppWebview,
              ),
              builder: (BuildContext context) => WebviewWidget(
                _appLocalizations.needHelp,
                AppConfig.boUrls![16]["value"],
              ),
            ),
          );
        },
      ),
      ListTileWidget(
        title: _appLocalizations.stocks,
        subtitle: '',
        leadingImage: AppImages.stocks(context),
        onTap: () {
          Navigator.push(
            context,
            SlideRoute(
              settings: const RouteSettings(
                name: ScreenRoutes.inAppWebview,
              ),
              builder: (BuildContext context) => WebviewWidget(
                _appLocalizations.needHelp,
                AppConfig.boUrls![17]["value"],
              ),
            ),
          );
        },
      ),
      ListTileWidget(
        title: _appLocalizations.payments,
        subtitle: '',
        leadingImage: AppImages.payments(context),
        onTap: () {
          Navigator.push(
            context,
            SlideRoute(
              settings: const RouteSettings(
                name: ScreenRoutes.inAppWebview,
              ),
              builder: (BuildContext context) => WebviewWidget(
                _appLocalizations.needHelp,
                AppConfig.boUrls![20]["value"],
              ),
            ),
          );
        },
      ),
      ListTileWidget(
        title: _appLocalizations.ipo,
        subtitle: '',
        leadingImage: AppImages.ipo(context),
        onTap: () {
          Navigator.push(
            context,
            SlideRoute(
              settings: const RouteSettings(
                name: ScreenRoutes.inAppWebview,
              ),
              builder: (BuildContext context) => WebviewWidget(
                _appLocalizations.needHelp,
                AppConfig.boUrls![21]["value"],
              ),
            ),
          );
        },
      ),
      ListTileWidget(
        title: _appLocalizations.otherInvestments,
        subtitle: '',
        leadingImage: AppImages.otherInvestments(context),
        onTap: () {
          Navigator.push(
            context,
            SlideRoute(
              settings: const RouteSettings(
                name: ScreenRoutes.inAppWebview,
              ),
              builder: (BuildContext context) => WebviewWidget(
                _appLocalizations.needHelp,
                AppConfig.boUrls![22]["value"],
              ),
            ),
          );
        },
      ),
      ListTileWidget(
        title: _appLocalizations.rewardsAndReferral,
        subtitle: '',
        leadingImage: AppImages.rewards(context),
        onTap: () {
          Navigator.push(
            context,
            SlideRoute(
              settings: const RouteSettings(
                name: ScreenRoutes.inAppWebview,
              ),
              builder: (BuildContext context) => WebviewWidget(
                _appLocalizations.rewardsAndReferral,
                AppConfig.boUrls![23]["value"],
              ),
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: backIconButton(),
            ),
            Padding(
              padding: EdgeInsets.only(left: AppWidgetSize.dimen_25),
              child: CustomTextWidget(
                AppLocalizations().helpAndSupport,
                Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              selectATopic(),
              getHelp(),
            ],
          ),
        ),
      ),
    );
  }

  Widget selectATopic() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppWidgetSize.dimen_30,
              vertical: AppWidgetSize.dimen_20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                  AppLocalizations().selectatopic,
                  Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: AppWidgetSize.fontSize16)),
              const Divider(),
            ],
          ),
        ),
        CardWidget(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_15),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_10),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectATopicList(context).length,
              itemBuilder: (context, index) {
                return selectATopicList(context)[index];
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget getHelp() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppWidgetSize.dimen_30,
              vertical: AppWidgetSize.dimen_20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                  AppLocalizations().getHelp,
                  Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: AppWidgetSize.fontSize16)),
              const Divider(),
            ],
          ),
        ),
        CardWidget(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_15),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_10),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: getHelpList(context).length,
              itemBuilder: (context, index) {
                return getHelpList(context)[index];
              },
            ),
          ),
        ),
      ],
    );
  }
}
