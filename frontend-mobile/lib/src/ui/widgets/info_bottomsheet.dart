import 'package:flutter/material.dart';

import '../styles/app_widget_size.dart';

class InfoBottomSheet {
  static showInfoBottomsheet(Widget child, BuildContext context,
      {double? height,
      isdimissible = true,
      double? bottomMargin,
      bool isDirectChild = false,
      bool horizontalMargin = true,
      bool topMargin = true}) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      enableDrag: false,
      isDismissible: isdimissible,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.w),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter updateState) {
          return isDirectChild
              ? SafeArea(child: child)
              : Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_5),
                  padding: EdgeInsets.only(
                      top: topMargin ? 20.w : 0,
                      bottom: bottomMargin ?? 20.w,
                      left: horizontalMargin ? 30.w : 0,
                      right: horizontalMargin ? 30.w : 0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.w),
                      ),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(
                          color: Theme.of(context).primaryColor, width: 1.5.w)),
                  constraints: BoxConstraints(
                    maxHeight: height ??
                        MediaQuery.of(context).copyWith().size.height * 0.8,
                  ),
                  child: child,
                );
        });
      },
    );
  }
}
