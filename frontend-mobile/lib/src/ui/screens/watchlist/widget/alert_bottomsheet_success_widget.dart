import 'package:flutter/material.dart';

import '../../../../constants/keys/widget_keys.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/gradient_button_widget.dart';

void showSuccessAlertBottomSheetWithButton({
  required BuildContext context,
  required String title,
  required String description,
  // required String leftButtonTitle,
  required String rightButtonTitle,
  required Function rightButtonCallback,
}) {
  showModalBottomSheet(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    context: context,
    isDismissible: true,
    enableDrag: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.w),
    ),
    isScrollControlled: true,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      title,
                      Theme.of(context).textTheme.displayMedium,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: AppImages.closeIcon(
                        context,
                        color: Theme.of(context)
                            .primaryTextTheme
                            .titleMedium!
                            .color,
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
                    Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: AppWidgetSize.dimen_10,
                    ),
                    gradientButtonWidget(
                        onTap: () => Navigator.of(context).pop(),
                        width: AppWidgetSize.fullWidth(context) / 2.5,
                        key: const Key(positiveButtonKey),
                        context: context,
                        title: rightButtonTitle,
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
