import 'package:acml/src/localization/app_localization.dart';
import 'package:acml/src/ui/screens/acml_app.dart';
import 'package:acml/src/ui/screens/base/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../../constants/keys/orderpad_keys.dart';
import '../../../../../models/common/symbols_model.dart';
import '../../../../navigation/screen_routes.dart';
import '../../../../styles/app_widget_size.dart';
import '../../../../widgets/custom_text_widget.dart';
import '../../../../widgets/gradient_button_widget.dart';
import '../../choose_alert.dart';

class AlertSuccessFailureWidget {
  static Future<void> show(
      {required BuildContext context,
      required bool isSuccess,
      required bool fromQuote,
      required String title,
      required String msg,
      required Function onDoneCallBack,
      required String data,
      required Symbols symbol}) async {
    GlobalKey<BaseAuthScreenState> showKey = GlobalKey<BaseAuthScreenState>();
    // if (isSuccess) {
    //   Future.delayed(const Duration(seconds: 5), () {
    //     if (showKey.currentWidget != null) {
    //       onDoneCallBack();
    //     }
    //   });
    // }
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
                  child: Scaffold(
                    bottomNavigationBar: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        gradientButtonWidget(
                          onTap: () async {
                            navigatorKey.currentState?.pop(true);
                            if (!fromQuote) {
                              navigatorKey.currentState?.pushReplacementNamed(
                                ScreenRoutes.alertsScreen,
                              );
                            } else {
                              navigatorKey.currentState?.pushNamed(
                                ScreenRoutes.alertsScreen,
                              );
                            }
                          },
                          width: AppWidgetSize.fullWidth(context) / 2.3,
                          key: const Key(orderpadViewOrderButtonKey),
                          context: context,
                          title: AppLocalizations().myAlerts,
                          isGradient: false,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        gradientButtonWidget(
                          onTap: () async {
                            navigatorKey.currentState?.pop(true);
                            await ChooseAlerts.show(context, symbol,
                                fromStockQuote: true);
                          },
                          width: AppWidgetSize.fullWidth(context) / 2.3,
                          key: const Key(orderpadViewOrderButtonKey),
                          context: context,
                          title: AppLocalizations().createAlert,
                          isGradient: true,
                        ),
                      ],
                    ),
                    body: SingleChildScrollView(
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
                        ],
                      ),
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
