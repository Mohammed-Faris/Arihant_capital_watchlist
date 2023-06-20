import 'package:acml/src/ui/styles/app_color.dart';
import 'package:flutter/material.dart';

import '../../../../constants/keys/widget_keys.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/gradient_button_widget.dart';

void showAlertBottomSheetWithTwoButtons(
    {required BuildContext context,
    required String title,
    required String description,
    required String leftButtonTitle,
    required String rightButtonTitle,
    required Function rightButtonCallback,
    bool? button1Error,
    bool? button2Error}) {
  showModalBottomSheet(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    context: context,
    isDismissible: true,
    enableDrag: false,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.w),
    ),
    builder: (_) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(20.r),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(
              top: 30.w,
              left: 30.w,
              right: 30.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      title,
                      // Theme.of(context).textTheme.headline2,
                      Theme.of(context)
                          .primaryTextTheme
                          .bodySmall!
                          .copyWith(fontWeight: FontWeight.w500, fontSize: 24),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: AppImages.closeIcon(
                        context,
                        color: Theme.of(context).primaryIconTheme.color,
                        isColor: true,
                        width: AppWidgetSize.dimen_22,
                        height: AppWidgetSize.dimen_22,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 30.w,
                    bottom: 30.w,
                  ),
                  child: CustomTextWidget(
                    description,
                    Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontSize: 17.w),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    gradientButtonWidget(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      width: AppWidgetSize.fullWidth(context) / 2.5,
                      key: const Key(negativeButtonKey),
                      context: context,
                      title: leftButtonTitle,
                      isGradient: false,
                      isErrorButton: button1Error ?? true,
                    ),
                    SizedBox(
                      width: AppWidgetSize.dimen_10,
                    ),
                    gradientButtonWidget(
                        onTap: () {
                          Navigator.of(context).pop();
                          // watchlistBloc.add(WatchlistDeleteGroupEvent(group));
                          rightButtonCallback();
                        },
                        width: AppWidgetSize.fullWidth(context) / 2.5,
                        key: const Key(positiveButtonKey),
                        context: context,
                        title: rightButtonTitle,
                        gradientColors: (button2Error ?? false)
                            ? [AppColors.negativeColor, AppColors.negativeColor]
                            : null,
                        isGradient: true)
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
