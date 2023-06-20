import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../localization/app_localization.dart';
import '../screens/login/support.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import 'gradient_button_widget.dart';

Widget defaultWidget(
  BuildContext context, {
  Function? onCallback,
  String? message,
  String? errorCode,
  dynamic image,
  bool disableImage = true,
  String? buttonText,
  bool disableButton = false,
  bool disableText = false,
}) {
  final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
  return Center(
    child: Scaffold(
      bottomNavigationBar: const SupportAndCallBottom(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_30),
        width: AppWidgetSize.screenWidth(context),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: errorCode == AppConstants.serverDown
            ? SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (!disableText)
                      Padding(
                        padding: EdgeInsets.only(top: 30.h),
                        child: Text(
                          AppLocalizations().wewillback,
                          // message ?? appLocalizations.networkIssueDescription,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    AppImages.maintanence(context,
                        height: AppWidgetSize.screenHeight(context) * 0.54),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(AppWidgetSize.dimen_10),
                      child: Text(
                        AppLocalizations().undermaintanence,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (!disableButton)
                      Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: AppWidgetSize.dimen_20),
                          child: gradientButtonWidget(
                              key: Key(
                                buttonText ?? appLocalizations.retry,
                              ),
                              width: AppWidgetSize.fullWidth(context) / 2,
                              onTap: () {
                                if (onCallback != null) {
                                  onCallback();
                                }
                              },
                              context: context,
                              title: buttonText ?? appLocalizations.retry,
                              isGradient: true,
                              bottom: 20.h)),
                    // if (!disableText)
                    //   Expanded(
                    //     child: Container(
                    //       alignment: Alignment.bottomCenter,
                    //       padding: EdgeInsets.all(AppWidgetSize.dimen_10),
                    //       child: Text(
                    //         message ?? appLocalizations.networkIssueDescription,
                    //         style: Theme.of(context).textTheme.headline6,
                    //         textAlign: TextAlign.center,
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              )
            : SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (!disableText)
                      Padding(
                        padding: EdgeInsets.only(top: 30.h),
                        child: Text(
                          AppLocalizations().networkissue,
                          // message ?? appLocalizations.networkIssueDescription,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    AppImages.networkIssueImage(
                        height: AppWidgetSize.screenHeight(context) * 0.54),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(AppWidgetSize.dimen_10),
                      child: Text(
                        message ?? "",
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (!disableButton)
                      Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: AppWidgetSize.dimen_20),
                          child: gradientButtonWidget(
                              key: Key(
                                buttonText ?? appLocalizations.retry,
                              ),
                              width: AppWidgetSize.fullWidth(context) / 2,
                              onTap: () {
                                if (onCallback != null) {
                                  onCallback();
                                }
                              },
                              context: context,
                              title: buttonText ?? appLocalizations.retry,
                              isGradient: true,
                              bottom: 20.h)),
                  ],
                ),
              ),
      ),
    ),
  );
}
