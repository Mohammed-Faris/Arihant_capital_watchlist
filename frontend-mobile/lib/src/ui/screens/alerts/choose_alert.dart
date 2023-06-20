import 'package:acml/src/ui/screens/acml_app.dart';
import 'package:acml/src/ui/screens/alerts/add_alert/add_alert_popup.dart';
import 'package:acml/src/ui/styles/app_widget_size.dart';
import 'package:flutter/material.dart';

import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../styles/app_images.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/info_bottomsheet.dart';

class ChooseAlerts {
  static show(BuildContext context, Symbols symbol,{bool fromStockQuote=false}) {
    return InfoBottomSheet.showInfoBottomsheet(StatefulBuilder(
        builder: (BuildContext context, StateSetter updateState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  AppLocalizations().choosetheAlertType,
                  Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: 22.w),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: AppImages.closeIcon(
                    context,
                    width: 20.w,
                    height: 20.w,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: AppUtils().convertToListOfAlerts().length,
                  itemBuilder: (context, index) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 5.w, top: 5.w),
                        width: AppWidgetSize.screenWidth(context),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1.5.w),
                        )),
                        child: ListTile(
                            horizontalTitleGap: 5.w,
                            contentPadding:
                                EdgeInsets.all(AppWidgetSize.dimen_1),
                            title: CustomTextWidget(
                              AppUtils()
                                      .convertToListOfAlerts()[index]
                                      .isNotEmpty
                                  ? AppUtils()
                                      .convertToListOfAlerts()[index]
                                      .first
                                      .alertType
                                  : "--",
                              Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.left,
                            )),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            AppUtils().convertToListOfAlerts()[index].length,
                        itemBuilder: (context, i) => GestureDetector(
                          onTap: () async {
                            navigatorKey.currentState?.pop();
                            await AddAlert.show(context, symbol,
                                AppUtils().convertToListOfAlerts()[index][i],fromStockQuote:fromStockQuote);
                          },
                          child: Container(
                              padding: EdgeInsets.only(bottom: 5.w, top: 5.w),
                              width: AppWidgetSize.screenWidth(context),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                  border: Border(
                                bottom: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 1.5.w),
                              )),
                              child: ListTile(
                                horizontalTitleGap: 5.w,
                                trailing: AppImages.rightArrowIos(context),
                                contentPadding:
                                    EdgeInsets.all(AppWidgetSize.dimen_1),
                                title: CustomTextWidget(
                                  AppUtils()
                                      .convertToListOfAlerts()[index][i]
                                      .alertName,
                                  Theme.of(context).textTheme.headlineSmall,
                                  textAlign: TextAlign.left,
                                ),
                              )),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      );
    }), context);
  }
}
