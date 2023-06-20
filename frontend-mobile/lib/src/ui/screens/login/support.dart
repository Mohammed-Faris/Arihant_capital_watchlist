import 'package:acml/src/config/app_config.dart';
import 'package:acml/src/data/store/app_utils.dart';
import 'package:acml/src/ui/styles/app_widget_size.dart';
import 'package:acml/src/ui/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/keys/login_keys.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../base/base_screen.dart';

class SupportPage extends BaseScreen {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends BaseAuthScreenState<SupportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: topBar(context),
        toolbarHeight: AppWidgetSize.dimen_60,
      ),
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: (AppWidgetSize.screenHeight(context) *
                    (AppUtils.isTablet ? 0.25 : 0.35)),
                // padding: EdgeInsets.only(top: AppWidgetSize.dimen_20),
                child: Lottie.asset(
                  "lib/assets/images/support.json",
                  fit: BoxFit.fill,
                  repeat: true,
                ),
              ),
              const MailandPhone()
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeArea(
            child: Container(
              padding: EdgeInsets.only(bottom: 30.w),
              child: gradientButtonWidget(
                onTap: () {
                  showToast(message: "COMING SOON");
                },
                bottom: 0,
                width: AppWidgetSize.dimen_280,
                key: const Key(writeTOUs),
                context: context,
                title: AppLocalizations().writeToUs,
                isGradient: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: backIconButton(),
        ),
        Padding(
          padding: EdgeInsets.only(left: AppWidgetSize.dimen_25),
          child: CustomTextWidget(
            AppLocalizations().support,
            Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }
}

class MailandPhone extends StatelessWidget {
  const MailandPhone({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(top: AppWidgetSize.dimen_20),
          child: CardWidget(
              width:
                  AppWidgetSize.screenWidth(context) - AppWidgetSize.dimen_20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                alignment: Alignment.center,
                height: AppWidgetSize.dimen_60,
                child: CardWidget2(
                    text: AppConfig.boUrls?.firstWhereOrNull((element) =>
                            element["key"] == "marginPledge")?["value"] ??
                        AppConfig.contactEmail,
                    child: Icon(
                      Icons.mail,
                      color: Theme.of(context).primaryColor,
                      size: 18.w,
                    ),
                    ontextTap: () async {
                      final Uri url = Uri(
                        scheme: 'mailto',
                        path: AppConfig.boUrls?.firstWhereOrNull((element) =>
                                element["key"] == "marginPledge")?["value"] ??
                            AppConfig.contactEmail,
                        query:
                            'subject=App Support&body=App Version ${AppConfig.appVersion}',
                      );
                      await launchUrl(url);
                    }),
              )),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppWidgetSize.dimen_20),
          child: CardWidget(
              width:
                  AppWidgetSize.screenWidth(context) - AppWidgetSize.dimen_20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                alignment: Alignment.center,
                height: AppWidgetSize.dimen_60,
                child: CardWidget2(
                    text: AppConfig.arhtBnkDtls?.contact ??
                        AppConfig.contactMobile,
                    child: Icon(
                      Icons.call,
                      color: Theme.of(context).primaryColor,
                      size: 18.w,
                    ),
                    ontextTap: () async {
                      final Uri url = Uri(
                        scheme: 'tel',
                        path: AppConfig.arhtBnkDtls?.contact ??
                            AppConfig.contactMobile,
                      );
                      await launchUrl(url);
                    }),
              )),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_20),
          child: CardWidget(
              width:
                  AppWidgetSize.screenWidth(context) - AppWidgetSize.dimen_20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                alignment: Alignment.center,
                height: AppWidgetSize.dimen_60,
                child: CardWidget2(
                    text: AppConfig.arhtBnkDtls?.secContact ??
                        AppConfig.contactSecMobile,
                    child: Icon(
                      Icons.call,
                      color: Theme.of(context).primaryColor,
                      size: 18.w,
                    ),
                    ontextTap: () async {
                      final Uri url = Uri(
                        scheme: 'tel',
                        path: AppConfig.arhtBnkDtls?.secContact ??
                            AppConfig.contactSecMobile,
                      );
                      await launchUrl(url);
                    }),
              )),
        ),
      ],
    );
  }
}

class CardWidget2 extends StatelessWidget {
  final Widget? child;
  final String text;
  final Function() ontextTap;
  const CardWidget2({
    Key? key,
    required this.text,
    this.child,
    required this.ontextTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            if (child != null)
              Padding(
                padding: EdgeInsets.only(right: AppWidgetSize.dimen_10),
                child: child!,
              ),
            Container(
              padding: EdgeInsets.only(right: AppWidgetSize.dimen_10),
              child: GestureDetector(
                onTap: ontextTap,
                child: Text(
                  text,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: 17.w),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: text));
              showToast(
                message: "Copied",
                context: context,
              );
            },
            child: Container(
              //color: Theme.of(context).scaffoldBackgroundColor,
              padding: EdgeInsets.all(10.w),
              child: AppImages.copyIcon(context,
                  isColor: true,
                  color: Theme.of(context).primaryColor,
                  height: 19.w),
            )),
      ],
    );
  }
}

class SupportAndCallBottom extends BaseScreen {
  const SupportAndCallBottom({
    Key? key,
    this.isForInternetPop = false,
  }) : super(key: key);
  final bool isForInternetPop;

  @override
  State<SupportAndCallBottom> createState() => _SupportAndCallBottomState();
}

class _SupportAndCallBottomState
    extends BaseAuthScreenState<SupportAndCallBottom> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: !widget.isForInternetPop
                    ? Radius.zero
                    : Radius.circular(20.w),
                bottomRight: !widget.isForInternetPop
                    ? Radius.zero
                    : Radius.circular(20.w),
                topLeft: widget.isForInternetPop
                    ? Radius.zero
                    : Radius.circular(5.w),
                topRight: widget.isForInternetPop
                    ? Radius.zero
                    : Radius.circular(5.w))),
        width: AppWidgetSize.screenWidth(context),
        //  padding: EdgeInsets.only(top: 20.w, bottom: 20.w),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 20.w,
              ),
              Padding(
                padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_20),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, ScreenRoutes.support);
                  },
                  child: CustomTextWidget(
                    'Support',
                    Theme.of(context).primaryTextTheme.headlineSmall,
                  ),
                ),
              ),

              /* SizedBox(
                height: 40.w,
                child: VerticalDivider(
                  thickness: 1.5.w,
                  color: Theme.of(context).dividerColor,
                ),
              ), */
              Padding(
                padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_20),
                child: GestureDetector(
                  onTap: () async => {
                    showAlert(
                        "Having trouble placing an order? We've got your back 😊! Simply call your RM, branch, or dealer to place an order on your behalf.",
                        header: "📞 Call & Trade ")

                    //await launchUrl(Uri.parse("tel:${AppConfig.callFortrade}")
                  },
                  child: CustomTextWidget(
                    'Call for trade',
                    Theme.of(context).primaryTextTheme.headlineSmall,
                  ),
                ),
              ),
              SizedBox(
                height: 20.w,
              ),
            ]),
      ),
    );
  }
}
