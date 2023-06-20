import '../../../../data/store/app_utils.dart';
import '../../../widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';

import '../../../../models/orders/order_book.dart';
import '../../../../models/orders/order_status_log.dart';
import '../../../styles/app_widget_size.dart';

class ListOfTradesWidget extends StatelessWidget {
  final Orders? orders;
  const ListOfTradesWidget(
    this.orders, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpansionTile(
              childrenPadding: EdgeInsets.only(bottom: AppWidgetSize.dimen_10),
              iconColor: Theme.of(context).textTheme.labelSmall?.color,
              collapsedIconColor: Theme.of(context).textTheme.labelSmall?.color,
              // ignore: sort_child_properties_last
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(6),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(6),
                  },
                  children: [
                    TableRow(children: [
                      CustomTextWidget(
                        "Price/Share",
                        Theme.of(context).textTheme.labelSmall,
                      ),
                      CustomTextWidget(
                        "Qty",
                        Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                      CustomTextWidget(
                        "Total Price",
                        Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.right,
                      ),
                    ]),
                    for (ListOfTrades trades in (orders?.listOfTrades ?? []))
                      TableRow(children: [
                        CustomTextWidget(
                          AppUtils().dataNullCheckDashDash(trades.prcPerShare),
                          Theme.of(context).textTheme.titleLarge?.copyWith(),
                          isRupee: true,
                          padding: EdgeInsets.symmetric(
                              vertical: AppWidgetSize.dimen_10),
                        ),
                        CustomTextWidget(
                          AppUtils().dataNullCheckDashDash((AppUtils().intValue(
                                  trades.tradedQty
                                      .toString()
                                      .withMultiplierTrade(orders?.sym)))
                              .toString()),
                          Theme.of(context).textTheme.titleLarge?.copyWith(),
                          padding: EdgeInsets.symmetric(
                              vertical: AppWidgetSize.dimen_10),
                          textAlign: TextAlign.center,
                        ),
                        CustomTextWidget(
                          AppUtils().commaFmt(
                              (AppUtils().doubleValue(trades.prcPerShare) *
                                      AppUtils().doubleValue(trades.tradedQty
                                          .withMultiplierTrade(orders?.sym)))
                                  .toString()),
                          Theme.of(context).textTheme.titleLarge?.copyWith(),
                          isRupee: true,
                          textAlign: TextAlign.right,
                          padding: EdgeInsets.symmetric(
                              vertical: AppWidgetSize.dimen_10),
                        )
                      ]),
                    TableRow(children: [
                      CustomTextWidget(
                        "Total",
                        Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w500),
                        padding: EdgeInsets.symmetric(
                            vertical: AppWidgetSize.dimen_10),
                      ),
                      CustomTextWidget(
                        AppUtils().dataNullCheckDashDash(orders!.listOfTrades!
                            .fold(0, (int previousValue, element) {
                          return (AppUtils().intValue(element.tradedQty
                                  .toString()
                                  .withMultiplierTrade(orders?.sym))) +
                              (previousValue);
                        }).toString()),
                        Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                        padding: EdgeInsets.symmetric(
                            vertical: AppWidgetSize.dimen_10),
                      ),
                      CustomTextWidget(
                        AppUtils().commaFmt(
                          (orders!.listOfTrades!.fold(0.00,
                              (double previousValue, element) {
                            return ((AppUtils().doubleValue(element.tradedQty
                                        .withMultiplierTrade(orders?.sym))) *
                                    AppUtils()
                                        .doubleValue(element.prcPerShare)) +
                                (previousValue);
                          })).toString(),
                        ),
                        Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w500),
                        isRupee: true,
                        textAlign: TextAlign.right,
                        padding: EdgeInsets.symmetric(
                            vertical: AppWidgetSize.dimen_10),
                      )
                    ]),
                  ],
                )
              ],
              tilePadding: EdgeInsets.zero,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: SizedBox(
                width: AppWidgetSize.screenWidth(context),
                child: Text(
                  "List Of Trades",
                  style:
                      Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                  textAlign: TextAlign.left,
                ),
              )),
          Divider(
            color: Theme.of(context).dividerColor,
            thickness: 1,
            height: 0,
          ),
          SizedBox(
            height: AppWidgetSize.dimen_15,
          ),
        ],
      ),
    );
  }
}
