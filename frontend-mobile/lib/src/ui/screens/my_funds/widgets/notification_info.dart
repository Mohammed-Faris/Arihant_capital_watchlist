import 'package:flutter/material.dart';

import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';

class NotificationInfo extends StatelessWidget {
  final String info;
  const NotificationInfo({Key? key, required this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
        bottom: AppWidgetSize.dimen_10,
      ),
      child: Container(
        color: Theme.of(context).snackBarTheme.backgroundColor,
        child: Padding(
          padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_17,
            bottom: AppWidgetSize.dimen_17,
            left: AppWidgetSize.dimen_20,
            right: AppWidgetSize.dimen_20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppImages.bankNotificationBadgelogo(context, isColor: true),
              Padding(
                padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
                child: SizedBox(
                  width:
                      AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_80,
                  child:
                      Text(info, style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
