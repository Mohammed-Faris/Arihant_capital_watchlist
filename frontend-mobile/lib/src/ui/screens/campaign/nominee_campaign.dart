import 'package:acml/src/blocs/common/screen_state.dart';
import 'package:acml/src/ui/screens/acml_app.dart';
import 'package:acml/src/ui/screens/base/base_screen.dart';
import 'package:acml/src/ui/styles/app_images.dart';
import 'package:acml/src/ui/styles/app_widget_size.dart';
import 'package:flutter/material.dart';
import 'package:msil_library/utils/exception/service_exception.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../constants/keys/quote_keys.dart';
import '../../../data/repository/my_account/my_account_repository.dart';
import '../../navigation/screen_routes.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/webview_widget.dart';
import '../route_generator.dart';

class NomineeCampaign extends BaseScreen {
  const NomineeCampaign({super.key});

  @override
  State<NomineeCampaign> createState() => _NomineeCampaignState();
}

class _NomineeCampaignState extends BaseAuthScreenState<NomineeCampaign> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildPresistentFooterWidget(),
      appBar: AppBar(
        toolbarHeight: 0.w,
        backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          alignment: Alignment.centerRight,
          width: AppWidgetSize.screenWidth(context),
          padding: EdgeInsets.only(right: 20.w, top: 20.w),
          color: Theme.of(context).snackBarTheme.backgroundColor,
          child: InkWell(
            onTap: () {
              navigatorKey.currentState?.pop();
            },
            child: AppImages.closeIcon(
              context,
              width: 40.w,
              height: 20.w,
              color: Theme.of(context).primaryIconTheme.color,
              isColor: true,
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 30.w, top: 30.w),
          color: Theme.of(context).snackBarTheme.backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [AppImages.nomineeBanner(context)],
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 20.w, left: 20.w, right: 20.w),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: AppImages.arihantpluslogo(
                    context,
                    height: 40.w,
                    width: AppWidgetSize.dimen_280,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.w, bottom: 10.h),
                  child: CustomTextWidget(
                      "Nominee details Required",
                      Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: AppWidgetSize.fontSize18),
                      textAlign: TextAlign.justify),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.w, bottom: 10.h),
                  child: CustomTextWidget(
                      "It looks like you haven’t designated a nominee yet. It’s time to either add a nominee or opt-out of the feature.\n\nLet's complete your nomination. Click one of the following buttons and follow through the process to ensure your account is active.",
                      Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: AppWidgetSize.fontSize16),
                      textAlign: TextAlign.justify),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.w, bottom: 0.h),
                  child: CustomTextWidget(
                      "As per SEBI circular No.\nSEBI/HO/MIRSD/MIRSD-PoD-1/P/CIR/2023/42\n\n",
                      Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: AppWidgetSize.fontSize14),
                      textAlign: TextAlign.justify),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildPresistentFooterWidget() {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          gradientButtonWidget(
            key: const Key(addNominee),
            title: "Add Nominee",
            width: AppWidgetSize.fullWidth(context) / 2.2,
            isGradient: false,
            context: context,
            fontsize: 16.w,
            bottom: 20.w,
            onTap: () async {
              startLoader();

              try {
                String? ssoUrl = await MyAccountRepository()
                    .getNomineeUrl("nominee-details");
                stopLoader();
                await Permission.microphone.request();
                await Permission.camera.request();
                await Permission.location.request();
                await Permission.locationWhenInUse.request();
                await Permission.accessMediaLocation.request();
                if (mounted) {
                  Navigator.push(
                      context,
                      SlideRoute(
                          settings: const RouteSettings(
                            name: ScreenRoutes.inAppWebview,
                          ),
                          builder: (BuildContext context) =>
                              WebviewWidget("Add Nominee", ssoUrl)));
                }
              } on ServiceException catch (ex) {
                stopLoader();
                handleError(ScreenState()
                  ..errorCode = ex.code
                  ..errorMsg = ex.msg);
              } catch (e) {
                stopLoader();
              }
            },
          ),
          gradientButtonWidget(
            key: const Key(optoutNominee),
            title: "Opt-out of Nominee",
            width: AppWidgetSize.fullWidth(context) / 2.2,
            isGradient: true,
            fontsize: 16.w,
            bottom: 20.w,
            context: context,
            onTap: () async {
              startLoader();

              try {
                String? ssoUrl =
                    await MyAccountRepository().getNomineeUrl("optin-out");
                stopLoader();
                await Permission.microphone.request();
                await Permission.camera.request();
                await Permission.location.request();
                await Permission.locationWhenInUse.request();
                await Permission.accessMediaLocation.request();
                if (mounted) {
                  Navigator.push(
                      context,
                      SlideRoute(
                          settings: const RouteSettings(
                            name: ScreenRoutes.inAppWebview,
                          ),
                          builder: (BuildContext context) =>
                              WebviewWidget("Opt-out of Nominee", ssoUrl)));
                }
              } on ServiceException catch (ex) {
                stopLoader();
                handleError(ScreenState()
                  ..errorCode = ex.code
                  ..errorMsg = ex.msg);
              } catch (e) {
                stopLoader();
              }
            },
          ),
        ],
      ),
    );
  }
}
