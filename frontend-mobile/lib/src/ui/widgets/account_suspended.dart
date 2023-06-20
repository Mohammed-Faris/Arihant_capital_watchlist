import 'package:flutter/material.dart';

import '../../data/store/app_store.dart';
import '../../localization/app_localization.dart';
import '../styles/app_widget_size.dart';

Widget suspendedAccount(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      Text(
        AppLocalizations().arihant,
        style: Theme.of(context).textTheme.displaySmall,
      ),
      Padding(
        padding: EdgeInsets.only(top: AppWidgetSize.dimen_20, bottom: 20.h),
        child: Text(
          "Your account is ${AppStore().getAccStatus()}",
          style: Theme.of(context).textTheme.headlineMedium!,
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                AppLocalizations().ok,
                style: Theme.of(context).primaryTextTheme.headlineMedium,
              ),
            ),
          ),
        ],
      )
    ],
  );
}
