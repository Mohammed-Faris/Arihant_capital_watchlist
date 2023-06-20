import 'package:flutter/material.dart';

import '../../constants/keys/widget_keys.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import 'custom_text_widget.dart';
import 'gradient_button_widget.dart';

Widget buildEmptyWidget(
    {required BuildContext context,
    required String description1,
    required String description2,
    required bool buttonInRow,
    required String button1Title,
    required String button2Title,
    required Function onButton1Tapped,
    Function? onButton2Tapped,
    bool isSearchEmptyError = false,
    bool showbutton = true,
    double topPadding = 0,
    Widget? emptyImage,
    Widget? button1Icon}) {
  return Container(
    // height: AppWidgetSize.fullHeight(context) - 250,
    padding: EdgeInsets.only(
      top: topPadding,
      left: AppWidgetSize.dimen_20,
      right: 20.w,
    ),
    alignment: Alignment.center,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isSearchEmptyError && emptyImage == null)
            AppImages.emptyStocks(context,
                isColor: false,
                width:
                    AppWidgetSize.fullWidth(context) - AppWidgetSize.dimen_120,
                height: 200.w)
          else if (!isSearchEmptyError && emptyImage != null)
            emptyImage
          else
            AppImages.noSearchResults(context,
                isColor: false,
                width:
                    AppWidgetSize.fullWidth(context) - AppWidgetSize.dimen_80,
                height: AppWidgetSize.dimen_150),
          Padding(
            padding: EdgeInsets.only(
              top: 20.w,
            ),
            child: CustomTextWidget(
              description1,
              Theme.of(context).primaryTextTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 10.w,
              bottom: 20.w,
              left: AppWidgetSize.dimen_20,
              right: 20.w,
            ),
            child: CustomTextWidget(
              description2,
              Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          if (showbutton)
            if (buttonInRow)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  gradientButtonWidget(
                    onTap: () {
                      onButton1Tapped();
                    },
                    width: AppWidgetSize.fullWidth(context) / 2.5,
                    key: const Key(emptyWidgetButton1Key),
                    context: context,
                    title: button1Title,
                    isGradient: false,
                    isErrorButton: false,
                  ),
                  SizedBox(
                    width: AppWidgetSize.dimen_10,
                  ),
                  gradientButtonWidget(
                    onTap: () {
                      onButton2Tapped!();
                    },
                    width: AppWidgetSize.fullWidth(context) / 2.5,
                    key: const Key(emptyWidgetButton2Key),
                    context: context,
                    title: button2Title,
                    isGradient: true,
                  )
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  gradientButtonWidget(
                      onTap: () {
                        onButton1Tapped();
                      },
                      width: AppWidgetSize.fullWidth(context) / 2.5,
                      key: const Key(emptyWidgetButton1Key),
                      context: context,
                      title: button1Title,
                      isGradient: true,
                      bottom: button2Title.isNotEmpty ? 20 : 0,
                      icon: button1Icon),
                  if (button2Title.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        onButton2Tapped!();
                      },
                      child: CustomTextWidget(
                        button2Title,
                        Theme.of(context).primaryTextTheme.headlineMedium,
                      ),
                    ),
                ],
              )
        ],
      ),
    ),
  );
}
