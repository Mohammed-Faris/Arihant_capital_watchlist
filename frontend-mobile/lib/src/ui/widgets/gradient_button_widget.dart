import 'package:flutter/material.dart';

import '../styles/app_color.dart';
import '../styles/app_widget_size.dart';

Widget gradientButtonWidget({
  required Function onTap,
  required double width,
  required Key key,
  required BuildContext context,
  required String title,
  required bool isGradient,
  bool isErrorButton = false,
  Widget? icon,
  double? height,
  Color? backgroundcolor,
  Color? borderColor,
  Color? inactiveTextColor,
  double bottom = 40,
  double? fontsize,
  List<Color>? gradientColors,
}) {
  gradientColors = gradientColors ??
      [
        Theme.of(context).colorScheme.onBackground,
        Theme.of(context).primaryColor
      ];
  return GestureDetector(
    onTap: () {
      onTap();
    },
    child: Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        key: key,
        alignment: Alignment.center,
        width: width,
        height: height ?? AppWidgetSize.dimen_54,
        decoration: isGradient
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(AppWidgetSize.dimen_30),
                gradient: LinearGradient(
                  stops: const [0.0, 1.0],
                  begin: FractionalOffset.topLeft,
                  end: FractionalOffset.topRight,
                  colors: gradientColors,
                ),
              )
            : BoxDecoration(
                border: Border.all(
                  color: isErrorButton
                      ? AppColors.negativeColor
                      : (borderColor ?? AppColors().positiveColor),
                  width: 1.5,
                ),
                color: backgroundcolor,
                borderRadius: BorderRadius.circular(AppWidgetSize.dimen_30),
              ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) icon,
            Text(
              title,
              style: isGradient
                  ? Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: fontsize)
                  : Theme.of(context).primaryTextTheme.displaySmall!.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: fontsize,
                      color: isErrorButton
                          ? AppColors.negativeColor
                          : (inactiveTextColor ?? AppColors().positiveColor)),
            ),
          ],
        ),
      ),
    ),
  );
}
