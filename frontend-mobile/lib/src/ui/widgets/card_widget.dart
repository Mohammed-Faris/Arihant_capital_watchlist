import 'package:flutter/material.dart';

import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import 'custom_text_widget.dart';

class CardWidget extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final double? width;
  final Color? color;
  final Color? subtitleColor;
  final Function()? subtitleOntap;
  final Function()? infoOntap;
  const CardWidget(
      {required this.child,
      this.title,
      this.color,
      Key? key,
      this.width,
      this.subtitle,
      this.subtitleOntap,
      this.subtitleColor,
      this.infoOntap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (title != null && subtitle != null)
          Padding(
            padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_5,
                right: AppWidgetSize.dimen_5,
                bottom: AppWidgetSize.dimen_15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                    title!,
                    Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: AppWidgetSize.fontSize16)),
                Row(
                  children: [
                    GestureDetector(
                      onTap: subtitleOntap,
                      child: CustomTextWidget(
                          subtitle!,
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: AppWidgetSize.fontSize16,
                              color: subtitleColor)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_5),
                      child: GestureDetector(
                          onTap: infoOntap,
                          child: AppImages.informationIcon(context,
                              color: Theme.of(context).primaryIconTheme.color,
                              isColor: true,
                              height: AppWidgetSize.dimen_25,
                              width: AppWidgetSize.dimen_25)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (title != null && subtitle == null)
          Padding(
            padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_5, bottom: AppWidgetSize.dimen_15),
            child: CustomTextWidget(
                title!,
                Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: AppWidgetSize.fontSize16)),
          ),
        SizedBox(
          width: width ??
              MediaQuery.of(context).size.width - AppWidgetSize.dimen_60,
          child: Card(
              elevation: 5,
              color: color,
              shadowColor: color ?? Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(AppWidgetSize.dimen_10)),
                  side: BorderSide(
                      width: 0.5, color: Theme.of(context).dividerColor)),
              child: child),
        ),
      ],
    );
  }
}
