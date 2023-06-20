import 'package:flutter/material.dart';

import '../../../constants/app_constants.dart';
import '../../../data/store/app_store.dart';
import '../../../localization/app_localization.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';

class SpalshWidget extends StatelessWidget {
  const SpalshWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppWidgetSize.screenHeight(context),
      width: AppWidgetSize.screenWidth(context),
      child: Stack(
        children: [
          Positioned(
            top: AppWidgetSize.dimen_60,
            left: 30.w,
            child: AppImages.arihantlaunchlogo(
              context,
              height: 40.w,
              width: AppWidgetSize.dimen_280,
            ),
          ),
          Positioned(
            top: AppWidgetSize.dimen_130,
            left: 30.w,
            child: AppImages.arihantpluslogo(
              context,
              height: 40.w,
              width: AppWidgetSize.dimen_280,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: AppWidgetSize.dimen_200),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    AppStore().getThemeData() == AppConstants.darkMode
                        ? const Color(0xFF142D1A)
                        : const Color(0xFFE1F4E5),
                  ],
                  begin: const FractionalOffset(0.0, 0),
                  end: const FractionalOffset(0, 1),
                  stops: const [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: AppWidgetSize.dimen_130,
                  left: AppWidgetSize.dimen_60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations().tradeWith,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                fontSize: 36.w,
                              )
                          //color: Colors.black,

                          ),
                      Text(AppLocalizations().arihant,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                fontSize: 36.w,
                              )),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: AppWidgetSize.dimen_1, bottom: 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomTextWidget(
                            AppLocalizations().poweredby,
                            Theme.of(context).primaryTextTheme.labelSmall,
                          ),
                          CustomTextWidget(
                            AppLocalizations().arihantcapName,
                            Theme.of(context)
                                .primaryTextTheme
                                .labelSmall
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
