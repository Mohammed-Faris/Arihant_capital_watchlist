import 'package:acml/src/localization/app_localization.dart';
import 'package:acml/src/ui/screens/acml_app.dart';
import 'package:acml/src/ui/screens/base/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../constants/keys/orderpad_keys.dart';
import '../../ui/navigation/screen_routes.dart';
import '../../ui/styles/app_widget_size.dart';
import '../../ui/widgets/custom_text_widget.dart';
import '../../ui/widgets/gradient_button_widget.dart';

class OrderSuccessFailureWidget {
  static Future<void> show({
    required BuildContext context,
    required bool isSuccess,
    required String title,
    required String msg,
    required Function onDoneCallBack,
    required String data,
  }) async {
    GlobalKey<BaseAuthScreenState> showKey = GlobalKey<BaseAuthScreenState>();
    if (isSuccess) {
      Future.delayed(const Duration(seconds: 5), () {
        if (showKey.currentWidget != null) {
          onDoneCallBack();
        }
      });
    }
    await showModalBottomSheet(
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      context: context,
      enableDrag: false,
      isDismissible: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (_, StateSetter updateState) {
            return DraggableScrollableSheet(
              expand: false,
              maxChildSize: 1,
              key: showKey,
              initialChildSize: 1,
              builder: (_, ScrollController scrollController) {
                return WillPopScope(
                  onWillPop: () {
                    return Future.value(true);
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            left: 30.w,
                            right: 30.w,
                            top: AppWidgetSize.dimen_80,
                            bottom: AppWidgetSize.dimen_40,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                if (isSuccess)
                                  Container(
                                    width: AppWidgetSize.dimen_150,
                                    height: AppWidgetSize.dimen_150,
                                    color: Colors.transparent,
                                    child: Lottie.asset(
                                      "lib/assets/images/success.json",
                                      fit: BoxFit.fill,
                                      repeat: false,
                                    ),
                                  )
                                else
                                  Container(
                                    width: AppWidgetSize.dimen_150,
                                    height: AppWidgetSize.dimen_150,
                                    color: Colors.transparent,
                                    child: Lottie.asset(
                                      "lib/assets/images/failed.json",
                                      fit: BoxFit.fill,
                                      repeat: false,
                                    ),
                                  ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 30.w,
                                    bottom: 30.w,
                                  ),
                                  child: CustomTextWidget(
                                    title,
                                    Theme.of(context)
                                        .primaryTextTheme
                                        .titleSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                if (isSuccess)
                                  CustomTextWidget(
                                    AppLocalizations().orderSuccessMessage1,
                                    Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall,
                                    textAlign: TextAlign.center,
                                  )
                                else
                                  CustomTextWidget(
                                    data,
                                    Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 20.w,
                                    bottom: 30.w,
                                  ),
                                  child: CustomTextWidget(
                                    msg,
                                    Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isSuccess)
                          Column(
                            children: [
                              gradientButtonWidget(
                                onTap: () {
                                  navigatorKey.currentState
                                      ?.pushNamedAndRemoveUntil(
                                    ScreenRoutes.homeScreen,
                                    (route) => false,
                                    arguments: {
                                      'pageName': ScreenRoutes.tradesScreen,
                                      'selectedIndex': 0,
                                    },
                                  );
                                },
                                width: AppWidgetSize.fullWidth(context) / 2.3,
                                key: const Key(orderpadViewOrderButtonKey),
                                context: context,
                                title: AppLocalizations().viewOrder,
                                isGradient: true,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: AppWidgetSize.dimen_40,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    onDoneCallBack();
                                  },
                                  child: CustomTextWidget(
                                      AppLocalizations().done,
                                      Theme.of(context)
                                          .primaryTextTheme
                                          .headlineMedium),
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              gradientButtonWidget(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                width: AppWidgetSize.fullWidth(context) / 2.3,
                                key: const Key(orderpadRetryButtonKey),
                                context: context,
                                title: AppLocalizations().retry,
                                isGradient: true,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: AppWidgetSize.dimen_40,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    onDoneCallBack();
                                  },
                                  child: CustomTextWidget(
                                      AppLocalizations().done,
                                      Theme.of(context)
                                          .primaryTextTheme
                                          .headlineMedium),
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
