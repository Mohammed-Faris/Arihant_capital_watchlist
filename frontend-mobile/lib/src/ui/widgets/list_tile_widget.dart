import 'package:acml/src/data/store/app_utils.dart';
import 'package:flutter/material.dart';

import '../styles/app_color.dart';
import '../styles/app_widget_size.dart';
import 'custom_text_widget.dart';
import 'material_switch.dart';

// ignore: must_be_immutable
class ListTileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showArrow;
  final Widget? leadingImage;
  TextStyle? titleTextStyle;
  TextStyle? subtitleTextStyle;
  final String? otherTitle;
  final bool isBackgroundOther;
  final bool isSwitch;
  final void Function()? texbuttonClick;
  final bool switchValue;
  final bool hideDivider;

  final String? textButtonTitle;
  final double? arrowIconSize;
  final void Function(bool)? onChanged;
  final void Function()? onTap;
  final EdgeInsets? margin;
  ListTileWidget({
    required this.title,
    required this.subtitle,
    this.titleTextStyle,
    this.texbuttonClick,
    this.showArrow = true,
    this.onTap,
    this.textButtonTitle,
    this.leadingImage,
    this.isSwitch = false,
    this.onChanged,
    this.otherTitle,
    this.switchValue = false,
    this.isBackgroundOther = false,
    this.arrowIconSize,
    this.hideDivider = false,
    Key? key,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
            overlayColor: MaterialStateProperty.all<Color>(
                Theme.of(context).dialogBackgroundColor.withOpacity(0.1)),
            onTap: () {
              if (onTap != null) onTap!();
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 0.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListTile(
                    horizontalTitleGap: 5.w,
                    contentPadding: EdgeInsets.all(AppWidgetSize.dimen_1),
                    leading: leadingImage != null
                        ? Padding(
                            padding: AppUtils.isTablet
                                ? EdgeInsets.only(
                                    top: 6.w, bottom: subtitle == "" ? 7.w : 0)
                                : EdgeInsets.zero,
                            child: leadingImage,
                          )
                        : null,
                    subtitle: subtitle == ''
                        ? null
                        : Padding(
                            padding: AppUtils.isTablet
                                ? EdgeInsets.only(bottom: 7.w)
                                : EdgeInsets.zero,
                            child: CustomTextWidget(
                                subtitle,
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: AppWidgetSize.fontSize12)),
                          ),
                    title: Padding(
                      padding: AppUtils.isTablet
                          ? EdgeInsets.only(
                              top: 7.w, bottom: subtitle == "" ? 7.w : 0)
                          : EdgeInsets.zero,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width: AppWidgetSize.screenWidth(context) -
                                  (otherTitle != null
                                      ? AppWidgetSize.dimen_250
                                      : AppWidgetSize.dimen_200),
                              child: CustomTextWidget(
                                title,
                                (titleTextStyle != null)
                                    ? titleTextStyle
                                    : Theme.of(context).textTheme.headlineSmall,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                          if (otherTitle != null)
                            Flexible(
                              child: Container(
                                decoration: isBackgroundOther
                                    ? BoxDecoration(
                                        color: Theme.of(context)
                                            .snackBarTheme
                                            .backgroundColor,
                                        borderRadius: BorderRadius.circular(
                                            AppWidgetSize.dimen_20))
                                    : null,
                                padding: EdgeInsets.symmetric(
                                    vertical: AppWidgetSize.dimen_2,
                                    horizontal: AppWidgetSize.dimen_10),
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: CustomTextWidget(
                                    otherTitle ?? "",
                                    Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                            fontSize: AppWidgetSize.fontSize14,
                                            color: AppColors().positiveColor),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    trailing: Padding(
                      padding: AppUtils.isTablet
                          ? EdgeInsets.only(
                              top: 7.w,
                            )
                          : EdgeInsets.zero,
                      child: isSwitch
                          ? MaterialSwitch(
                              onChanged: (value) {
                                if (onChanged != null) onChanged!(value);
                              },
                              value: switchValue,
                              inactiveThumbColor:
                                  Theme.of(context).primaryColor,
                              activeTrackColor: Theme.of(context).primaryColor,
                              inactiveTrackColor: Theme.of(context)
                                  .snackBarTheme
                                  .backgroundColor,
                              activeColor: Colors.white,
                            )
                          : textButtonTitle != null
                              ? TextButton(
                                  onPressed: texbuttonClick,
                                  child: CustomTextWidget(
                                      textButtonTitle ?? "",
                                      Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                              fontSize:
                                                  AppWidgetSize.fontSize14,
                                              color: Theme.of(context)
                                                  .primaryColor)))
                              : showArrow
                                  ? Icon(
                                      Icons.arrow_forward_ios,
                                      color: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .color,
                                      size: arrowIconSize,
                                    )
                                  : null,
                    ),
                  ),
                ],
              ),
            )),
        if (!hideDivider)
          Divider(
            thickness: 1.w,
          ),
      ],
    );
  }
}
