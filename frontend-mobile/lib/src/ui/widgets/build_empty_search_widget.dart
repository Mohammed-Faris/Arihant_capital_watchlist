import 'package:flutter/material.dart';

import '../../constants/keys/widget_keys.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import 'custom_text_widget.dart';
import 'gradient_button_widget.dart';

Widget buildEmptySearchWidget({
  required BuildContext context,
  required String description1,
  required bool buttonInRow,
  required String button2Title,
  required Function onButton1Tapped,
  Function? onButton2Tapped,
}) {
  return Container(
    height: AppWidgetSize.fullHeight(context) - 250,
    padding: EdgeInsets.only(
      left: AppWidgetSize.dimen_20,
      right: 20.w,
    ),
    child: Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          AppImages.noSearchResults(context,
              isColor: false,
              width: AppWidgetSize.fullWidth(context) - AppWidgetSize.dimen_120,
              height: 200.h),
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
          if (buttonInRow)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                Padding(
                  padding: EdgeInsets.only(
                    top: 20.w,
                  ),
                  child: SizedBox(
                    width: AppWidgetSize.dimen_10,
                  ),
                ),
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
