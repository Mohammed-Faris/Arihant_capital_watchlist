import 'package:flutter/material.dart';

import '../styles/app_widget_size.dart';
import 'custom_text_widget.dart';

Widget errorWithImageWidget(
    {required BuildContext context,
    required Widget imageWidget,
    required String errorMessage,
    required EdgeInsetsGeometry padding,
    double? height,
    double? width,
    String? childErrorMsg,
    bool isBold = false}) {
  return SizedBox(
    height: height,
    width: width,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: padding,
            child: imageWidget,
          ),
          Padding(
            padding: EdgeInsets.only(left: 30.w, right: 30.w),
            child: CustomTextWidget(
              errorMessage,
              isBold
                  ? Theme.of(context).textTheme.titleSmall
                  : Theme.of(context).primaryTextTheme.bodySmall,
            ),
          ),
          if (childErrorMsg != null && childErrorMsg.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                top: 10.w,
                bottom: AppWidgetSize.dimen_70,
              ),
              child: CustomTextWidget(
                childErrorMsg,
                Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Theme.of(context)
                        .inputDecorationTheme
                        .labelStyle!
                        .color),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    ),
  );
}
