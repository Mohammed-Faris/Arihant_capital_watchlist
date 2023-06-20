import 'package:acml/src/ui/widgets/info_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:msil_library/streamer/models/quote2_stream_response_model.dart';

import '../../constants/app_constants.dart';
import '../../data/store/app_store.dart';
import '../../data/store/app_utils.dart';
import '../../localization/app_localization.dart';
import '../styles/app_color.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import 'custom_text_widget.dart';

class MarketDepthWidget extends StatelessWidget {
  final Quote2Data quoteDepthData;
  final String totalBidQtyPercent;
  final String totalAskQtyPercent;
  final List<String> bidQtyPercent;

  final List<String> askQtyPercent;
  final bool infoIcon;
  final Function(String action, String? customPrice)? onCallOrderPad;

  final BuildContext context;
  const MarketDepthWidget({
    Key? key,
    required this.context,
    required this.quoteDepthData,
    this.onCallOrderPad,
    required this.totalBidQtyPercent,
    required this.totalAskQtyPercent,
    required this.bidQtyPercent,
    required this.askQtyPercent,
    this.infoIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildMarketDepthWidget();
  }

  Widget _buildMarketDepthWidget() {
    return Container(
      padding: EdgeInsets.only(
        top: 20.w,
        bottom: 5.w,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderWidget(AppLocalizations().marketDepth),
          _buildDivider(),
          if (onCallOrderPad != null)
            Container(
              alignment: Alignment.center,
              width: double.maxFinite,
              padding: EdgeInsets.all(5.w),
              color: Theme.of(context).snackBarTheme.backgroundColor,
              child: Text(
                "Tap on the price to select",
                style: Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppStore().getThemeData() == AppConstants.darkMode
                          ? const Color(0xFFE1F4E5)
                          : const Color(0xFF00C802),
                      fontSize: 16.w,
                    ),
              ),
            ),
          _buildMarketDepthBody(),
        ],
      ),
    );
  }

  Widget _buildHeaderWidget(String title) {
    return Row(
      children: [
        CustomTextWidget(
          title,
          Theme.of(context).primaryTextTheme.titleSmall,
        ),
        if (infoIcon)
          Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_6,
              left: 5.w,
            ),
            child: GestureDetector(
              onTap: () {
                marketDepthSheet();
              },
              child: AppImages.informationIcon(
                context,
                color: Theme.of(context).primaryIconTheme.color,
                isColor: true,
                width: AppWidgetSize.dimen_22,
                height: AppWidgetSize.dimen_22,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(
        top: 5.w,
      ),
      child: Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
    );
  }

  Widget _buildMarketDepthBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: AppWidgetSize.dimen_16),
        child: _buildMarketDepthTable(
          quoteDepthData,
          AppUtils().dataNullCheck(totalBidQtyPercent),
          AppUtils().dataNullCheck(totalAskQtyPercent),
          bidQtyPercent,
          askQtyPercent,
        ),
      ),
    );
  }

  Widget _buildMarketDepthTable(
    Quote2Data quote2data,
    String totalBidQtyPercent,
    String totalAskQtyPercent,
    List<String> bidQtyPercent,
    List<String> askQtyPercent,
  ) {
    return SizedBox(
      width: AppWidgetSize.fullWidth(context),
      child: Column(
        children: [
          _buildMDTitleWidget(),
          _buildMDContentWidget(
            quote2data,
            bidQtyPercent,
            askQtyPercent,
          ),
          _buildMFFooterWidget(quote2data),
          _buildMarketDepthIndicatorWidget(
            totalBidQtyPercent,
            totalAskQtyPercent,
          ),
          _buildTwoLabelsWithSpaceBetweenWidget(
            '$totalBidQtyPercent%',
            '$totalAskQtyPercent%',
          ),
        ],
      ),
    );
  }

  Widget _buildMDTitleWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMDTable(
          AppLocalizations().bid,
          AppLocalizations().qty,
          true,
          '',
        ),
        _buildMDTable(AppLocalizations().ask, AppLocalizations().qty, true, '',
            reverse: true),
      ],
    );
  }

  Widget _buildMDContentWidget(
    Quote2Data quote2data,
    List<String> bidQtyPercent,
    List<String> askQtyPercent,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildBidWidgetList(
            quote2data,
            bidQtyPercent,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildAskWidgetList(
            quote2data,
            askQtyPercent,
          ),
        ),
      ],
    );
  }

  Widget _buildMFFooterWidget(
    Quote2Data quote2data,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 10.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMDFooterRow(
            AppLocalizations().bidTotal,
            quote2data.totBuyQty,
            true,
          ),
          _buildMDFooterRow(
            AppLocalizations().askTotal,
            quote2data.totSellQty,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildMDFooterRow(
    String title1,
    String title2,
    bool showTitleInLeft,
  ) {
    return SizedBox(
      width: AppWidgetSize.fullWidth(context) / 2.5,
      child: Table(
        children: <TableRow>[
          TableRow(
            children: <TableCell>[
              _buildMDTableCell(
                title1,
                TextAlign.start,
                getMDFooterTextStyle(),
                Theme.of(context).scaffoldBackgroundColor,
                true,
              ),
              _buildMDTableCell(
                title2,
                TextAlign.end,
                getMDFooterTextStyle(),
                Theme.of(context).scaffoldBackgroundColor,
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMDTable(String tableCell1Title, String tableCell3Title,
      bool isTitle, String qtyPercent,
      {bool isBid = false,
      bool isLeft = false,
      Color? color,
      bool reverse = false}) {
    return Container(
      padding: EdgeInsets.only(right: AppWidgetSize.dimen_5),
      // width: AppWidgetSize.fullWidth(context) / 2.5,
      width: AppWidgetSize.fullWidth(context) / 2.5,
      child: Table(
        columnWidths: ({
          0: FlexColumnWidth(reverse
              ? (((quoteDepthData.ask.map((e) => e.qty.length).toList().max) *
                      0.08) +
                  0.5)
              : (((quoteDepthData.bid.map((e) => e.price.length).toList().max) *
                      0.08) +
                  0.5)),
          2: FlexColumnWidth(reverse
              ? (((quoteDepthData.ask.map((e) => e.price.length).toList().max) *
                      0.08) +
                  0.5)
              : (((quoteDepthData.bid.map((e) => e.qty.length).toList().max) *
                      0.08) +
                  0.5)),
        }),
        children: <TableRow>[
          TableRow(
            children: <TableCell>[
              _buildMDTableCellWithBgColor(
                  !reverse ? tableCell1Title : tableCell3Title,
                  qtyPercent,
                  TextAlign.start,
                  getTextStyle(isTitle,
                      color: !reverse ? AppColors.primaryColor : null),
                  reverse
                      ? isTitle
                          ? Theme.of(context).scaffoldBackgroundColor
                          : isLeft
                              ? Theme.of(context).primaryColor.withOpacity(0.3)
                              : AppColors.negativeColor.withOpacity(0.3)
                      : Theme.of(context).scaffoldBackgroundColor,
                  false,
                  isTitle, onTap: () {
                if (onCallOrderPad != null && !isTitle) {
                  onCallOrderPad!(
                      isBid ? AppLocalizations().buy : AppLocalizations().sell,
                      tableCell1Title);
                }
              }),
              _buildMDTableCellWithBgColor(
                  reverse ? tableCell1Title : tableCell3Title,
                  qtyPercent,
                  TextAlign.center,
                  getTextStyle(isTitle,
                      color: reverse ? AppColors.negativeColor : null),
                  !reverse
                      ? isTitle
                          ? Theme.of(context).scaffoldBackgroundColor
                          : isLeft
                              ? Theme.of(context).primaryColor.withOpacity(0.3)
                              : AppColors.negativeColor.withOpacity(0.3)
                      : Theme.of(context).scaffoldBackgroundColor,
                  false,
                  isTitle, onTap: () {
                if (onCallOrderPad != null && !isTitle) {
                  onCallOrderPad!(
                      isBid ? AppLocalizations().buy : AppLocalizations().sell,
                      tableCell1Title);
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  TableCell _buildMDTableCell(
    String title,
    TextAlign textAlign,
    TextStyle style,
    Color bgColor,
    bool isTitle, {
    Function()? onTap,
  }) {
    return TableCell(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
            padding: EdgeInsets.only(
              bottom: 10.w,
              right: 4.w,
              left: AppWidgetSize.dimen_4,
            ),
            child: Container(
              color: bgColor,
              child: CustomTextWidget(
                isNumeric(title)
                    ? AppUtils().doubleValue(title).isNegative
                        ? "0"
                        : title
                    : title,
                style,
                textAlign: textAlign,
                isShowShimmer: !isTitle,
                shimmerPadding: 8.w,
              ),
            )),
      ),
    );
  }

  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return s.contains(RegExp(r'[0-9]'));
  }

  TableCell _buildMDTableCellWithBgColor(
      String title,
      String qtyPercent,
      TextAlign textAlign,
      TextStyle style,
      Color bgColor,
      bool isLeft,
      bool isTitle,
      {Function()? onTap}) {
    if (AppUtils().doubleValue(AppUtils().dataNullCheck(qtyPercent)) > 10) {
      qtyPercent =
          (AppUtils().doubleValue(AppUtils().dataNullCheck(qtyPercent)) / 100)
              .toStringAsFixed(2);
    }
    return TableCell(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: textAlign != TextAlign.start
              ? Alignment.centerRight
              : Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 4.w, horizontal: 5.w),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Stack(
              children: [
                Positioned(
                  right: textAlign != TextAlign.start ? 0 : null,
                  left: textAlign == TextAlign.start ? 0 : null,
                  child: Container(
                    height: AppWidgetSize.dimen_17,
                    width: 55.w *
                        AppUtils()
                            .isValueNAN(AppUtils().doubleValue(qtyPercent)),
                    color: bgColor,
                  ),
                ),
                Align(
                  alignment: textAlign == TextAlign.start
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: CustomTextWidget(
                    title,
                    style,
                    textAlign: textAlign,
                    isShowShimmer: !isTitle,
                    shimmerPadding: 8.w,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBidWidgetList(
    Quote2Data quote2data,
    List<String> bidQtyPercent,
  ) {
    List<Widget> bidWidgetList = List.generate(
      quote2data.bid.length,
      (int index) {
        final SymbolData item = quote2data.bid[index];
        return _buildMDTable(item.price, item.qty, false, bidQtyPercent[index],
            isBid: true, isLeft: true, color: Theme.of(context).primaryColor);
      },
    );
    return bidWidgetList;
  }

  List<Widget> _buildAskWidgetList(
    Quote2Data quote2data,
    List<String> askQtyPercent,
  ) {
    List<Widget> askWidgetList = List.generate(
      quote2data.ask.length,
      (int index) {
        final SymbolData item = quote2data.ask[index];
        return _buildMDTable(item.price, item.qty, false, askQtyPercent[index],
            color: AppColors.negativeColor, reverse: true);
      },
    );
    return askWidgetList;
  }

  TextStyle getTextStyle(bool isTitle, {Color? color}) {
    return isTitle
        ? Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w300,
              fontSize: 15.w,
            )
        : Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: 15.w,
            color: color ?? Theme.of(context).primaryTextTheme.bodySmall!.color,
            fontWeight: FontWeight.w500);
  }

  TextStyle getMDFooterTextStyle() {
    return Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
        fontSize: 14.w,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).primaryTextTheme.bodySmall!.color);
  }

  Widget _buildMarketDepthIndicatorWidget(
    String totalBidQtyPercent,
    String totalAskQtyPercent,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.w),
      child: Container(
        height: AppWidgetSize.dimen_15,
        width: AppWidgetSize.fullWidth(context) - AppWidgetSize.dimen_10,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(
            2,
            (int index) {
              if (index == 0) {
                return Expanded(
                  flex: AppUtils().dataNullCheck(totalBidQtyPercent) != '' &&
                          totalBidQtyPercent != '0'
                      ? AppUtils()
                          .isValueNAN(
                              AppUtils().doubleValue(totalBidQtyPercent))
                          .round()
                          .toInt()
                      : 1,
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: AppUtils().dataNullCheck(totalBidQtyPercent) !=
                                    '' &&
                                totalBidQtyPercent != 'NaN'
                            ? AppUtils().doubleValue(totalBidQtyPercent) ==
                                        100 ||
                                    AppUtils()
                                            .doubleValue(totalBidQtyPercent) ==
                                        0
                                ? 0
                                : AppWidgetSize.dimen_3
                            : 0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: index == 0
                            ? BorderRadius.only(
                                topLeft: Radius.circular(20.w),
                                bottomLeft: Radius.circular(20.w),
                              )
                            : BorderRadius.only(
                                topRight: Radius.circular(20.w),
                                bottomRight: Radius.circular(20.w),
                              ),
                        color: AppColors().positiveColor,
                      ),
                      alignment: Alignment.center,
                    ),
                  ),
                );
              } else {
                return Expanded(
                  flex: AppUtils().dataNullCheck(totalAskQtyPercent) != '' &&
                          totalAskQtyPercent != '0' &&
                          totalBidQtyPercent != 'NaN'
                      ? AppUtils()
                          .doubleValue(totalAskQtyPercent)
                          .round()
                          .toInt()
                      : 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: index == 0
                          ? BorderRadius.only(
                              topLeft: Radius.circular(20.w),
                              bottomLeft: Radius.circular(20.w),
                            )
                          : BorderRadius.only(
                              topRight: Radius.circular(20.w),
                              bottomRight: Radius.circular(20.w),
                            ),
                      color: AppColors.negativeColor,
                    ),
                    alignment: Alignment.center,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTwoLabelsWithSpaceBetweenWidget(
    String lable1,
    String lable2, {
    TextStyle? textStyle,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
            lable1,
            textStyle ?? Theme.of(context).primaryTextTheme.bodySmall,
          ),
          CustomTextWidget(
            lable2,
            textStyle ?? Theme.of(context).primaryTextTheme.bodySmall,
            textAlign: TextAlign.end,
          )
        ],
      ),
    );
  }

  Future<void> marketDepthSheet() async {
    InfoBottomSheet.showInfoBottomsheet(
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Market Depth",
                  style:
                      Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
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
            SizedBox(
              height: AppWidgetSize.dimen_10,
            ),
            Divider(
              thickness: 1,
              color: Theme.of(context).dividerColor,
            ),
            Container(
              height: AppWidgetSize.dimen_8,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Market depth shows the best 5 bids and offers with price, order and quantity of stocks and F&O contracts. With this, investors can better determine the availability or desire for a security at a certain price. “Bids” are functionally equivalent to limit-buy orders that other investors have open on the markets. Similarly, “asks” are functionally equivalent to limit-sell orders from other investors.",
                      style: Theme.of(context).primaryTextTheme.labelSmall,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Each bid and ask is represented by the price, the number of orders at that price and the quantity of the order.",
                      style: Theme.of(context).primaryTextTheme.labelSmall,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Table(
                        border: TableBorder.all(
                            color:
                                Theme.of(context).textTheme.titleLarge?.color ??
                                    Colors.black),
                        // Allows to add a border decoration around your table
                        children: [
                          TableRow(children: [
            
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Bid: ",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall!
                                        .copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    "The price at which a trader is willing to buy.",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall,
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Ask: ",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall!
                                        .copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    "The price at which a trader is willing to sell. ",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall,
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            ),
            
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Order: ",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall!
                                        .copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    "The number of buy orders placed at this bid price. ",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall,
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Order: ",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall!
                                        .copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    "The number of sell orders placed at this price. ",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall,
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            ),
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Qty: ",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall!
                                        .copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    "The number of shares that the traders are willing to buy at this price. ",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall,
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Qty: ",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall!
                                        .copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    "The number of shares that the traders are willing to sell at this price. ",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall,
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ]),
                    const SizedBox(
                      height: 15,
                    ),
                    RichText(
                      text: TextSpan(
                          text: "Note: ",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .copyWith(color: Theme.of(context).primaryColor),
                          children: [
                            TextSpan(
                              text:
                                  "The quantities are highlighted in green and red, this indicates how this order will impact the stock price. The length of the coloured bars is a visual representation of the quantity of the stocks traders are willing to buy and sell.",
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                          ]),
                    ),
                    // Text(
                    //   "the quantities are highlighted in green and red, this indicates how this order will impact the stock price. The length of the coloured bars is a visual representation of the quantity of the stocks traders are willing to buy and sell",
                    //   style: Theme.of(context).primaryTextTheme.overline,
                    //   textAlign: TextAlign.justify,
                    // ),
                    const SizedBox(
                      height: 15,
                    ),
                    RichText(
                      text: TextSpan(
                          text: "💡Tip: ",
                          style: Theme.of(context).primaryTextTheme.labelSmall!,
                          children: [
                            TextSpan(
                              text:
                                  "You can use this segment to speculate the direction in which the price of the stock will go.",
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                          ]),
                    ),
                    // Text(
                    //   "Tip: You can use this segment to speculate the direction in which the price of the stock will go.",
                    //   style: Theme.of(context).primaryTextTheme.overline,
                    //   textAlign: TextAlign.justify,
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
        context);
  }
}
