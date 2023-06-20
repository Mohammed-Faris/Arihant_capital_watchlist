import 'package:acml/src/constants/app_constants.dart';
import 'package:acml/src/ui/screens/acml_app.dart';
import 'package:acml/src/ui/widgets/info_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/quote/overview/quote_overview_bloc.dart';
import '../../config/app_config.dart';
import '../../data/store/app_utils.dart';
import '../../localization/app_localization.dart';
import '../../models/common/symbols_model.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import 'custom_text_widget.dart';
import 'performance_bottomsheet.dart';
import 'table_with_bgcolor.dart';

class PerformanceWidget {
  static Widget buildViewMore() {
    return Padding(
      padding: EdgeInsets.only(top: 10.w),
      child: CustomTextWidget(
        AppLocalizations().viewMore,
        Theme.of(navigatorKey.currentContext!).primaryTextTheme.titleLarge,
        textAlign: TextAlign.end,
      ),
    );
  }

  static Widget _buildExpansionRowForBottomSheet(
    BuildContext context,
    String title,
    String description,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          expandedAlignment: Alignment.centerLeft,
          initiallyExpanded: title == 'Open' ? true : false,
          tilePadding: EdgeInsets.only(
            right: 0,
            bottom: 5.w,
          ),
          collapsedIconColor:
              Theme.of(navigatorKey.currentContext!).primaryIconTheme.color,
          title: CustomTextWidget(
            title,
            Theme.of(navigatorKey.currentContext!).textTheme.displaySmall,
          ),
          iconColor:
              Theme.of(navigatorKey.currentContext!).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              description,
              Theme.of(navigatorKey.currentContext!)
                  .primaryTextTheme
                  .labelSmall,
              textAlign: TextAlign.start,
            )
          ],
        ),
      ),
    );
  }

  static Future<void> performanceSheet(BuildContext context) async {
    InfoBottomSheet.showInfoBottomsheet(
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 8.w,
                  ),
                  child: Text(
                    "Performance",
                    style: Theme.of(navigatorKey.currentContext!)
                        .primaryTextTheme
                        .titleSmall!
                        .copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(navigatorKey.currentContext!);
                  },
                  child: AppImages.closeIcon(
                    navigatorKey.currentContext!,
                    width: 20.w,
                    height: 20.w,
                    color: Theme.of(navigatorKey.currentContext!)
                        .primaryIconTheme
                        .color,
                    isColor: true,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 5.w,
            ),
            Divider(
              thickness: AppWidgetSize.dimen_1,
              color: Theme.of(navigatorKey.currentContext!).dividerColor,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "Open",
                      "The price at which the stock starts trading when the exchange opens.",
                    ),
                    Divider(
                      thickness: 1,
                      color:
                          Theme.of(navigatorKey.currentContext!).dividerColor,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "High",
                      "The highest price which the stock touched that day.",
                    ),
                    Divider(
                      thickness: 1,
                      color:
                          Theme.of(navigatorKey.currentContext!).dividerColor,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "Low",
                      "The lowest price which the stock touched that day.",
                    ),
                    Divider(
                      thickness: 1,
                      color:
                          Theme.of(navigatorKey.currentContext!).dividerColor,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "Volume",
                      "The total number of shares traded (both bought and sold) on the exchange for the given trading day and time.",
                    ),
                    Divider(
                      thickness: 1,
                      color:
                          Theme.of(navigatorKey.currentContext!).dividerColor,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "Avg price",
                      "The average price of the stock during the day.",
                    ),
                    Divider(
                      thickness: 1,
                      color:
                          Theme.of(navigatorKey.currentContext!).dividerColor,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "Close",
                      "The stock’s trading price at the end of the trading day. The closing price is calculated as the weighted average price of the last 30 minutes, i.e. from 3:00 PM to 3:30 PM in case of equity.",
                    ),
                    Divider(
                      thickness: 1,
                      color:
                          Theme.of(navigatorKey.currentContext!).dividerColor,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "Lower Circuit",
                      "The minimum permissible lowest price that a stock can hit on a given trading day.",
                    ),
                    Divider(
                      thickness: 1,
                      color:
                          Theme.of(navigatorKey.currentContext!).dividerColor,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "Upper Circuit",
                      "The maximum permissible trading price the stock can touch for the day.",
                    ),
                    Divider(
                      thickness: 1,
                      color:
                          Theme.of(navigatorKey.currentContext!).dividerColor,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "OI",
                      "Open interest is the total number of outstanding derivative contracts (futures and options) which are currently outstanding in the market (not settled).",
                    ),
                    Divider(
                      thickness: 1,
                      color:
                          Theme.of(navigatorKey.currentContext!).dividerColor,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "Face value",
                      "The stock’s nominal value or the par value at the time of issue. This value is not impacted by market fluctuations. However, the face value of a stock can change as a result of corporate actions like stock split. ",
                    ),
                    Divider(
                      thickness: 1,
                      color:
                          Theme.of(navigatorKey.currentContext!).dividerColor,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "VaR Margin",
                      "Value at Risk (VaR) refers to the potential loss that might occur while dealing with securities for a given timeframe. VAR margin is required to cover up for the largest losses that can arise due to uncertain risk conditions on 99% of the days.",
                    ),
                    Divider(
                      thickness: 1,
                      color:
                          Theme.of(navigatorKey.currentContext!).dividerColor,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "Series",
                      "The category of the scrip, eg: EQ for equity, FUTSTK for Stock Futures, O for options.",
                    ),
                    Divider(
                      thickness: 1,
                      color:
                          Theme.of(navigatorKey.currentContext!).dividerColor,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "Lot Size",
                      "The number of stocks you can buy in one transaction. For example, if the lot size of a security is 10, you can only buy that security in multiples of 10.",
                    ),
                    Divider(
                      thickness: 1,
                      color:
                          Theme.of(navigatorKey.currentContext!).dividerColor,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "Tick Size",
                      "The minimum upward/downward movement in the price of a security. ",
                    ),
                    Divider(
                      thickness: 1,
                      color:
                          Theme.of(navigatorKey.currentContext!).dividerColor,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "Delivery %",
                      "The shares which were taken in delivery as a percentage of the total volume of that share in the stock market that day. ",
                    ),
                    Divider(
                      thickness: 1,
                      color:
                          Theme.of(navigatorKey.currentContext!).dividerColor,
                    ),
                    _buildExpansionRowForBottomSheet(
                      navigatorKey.currentContext!,
                      "Max order size",
                      "The maximum quantity which can be placed in a single order for that scrip.",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        context);
  }

  static Widget buildPerformanceTable(Symbols symbols) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildPerformanceTopContent(
          symbols,
        ),
        if (AppConfig.overviewTab[AppUtils().getsymbolType(symbols)]
            .contains(AppLocalizations().fiftytwow))
          Column(
            children: [
              _buildPerformanceIndicatorWidget(
                AppUtils().dataNullCheck(symbols.ylow),
                AppUtils().dataNullCheck(symbols.yhigh),
                AppUtils().dataNullCheck(symbols.ltp),
              ),
              _buildFiftyWeekWidget(
                AppUtils().dataNullCheck(symbols.ylow),
                AppUtils().dataNullCheck(symbols.yhigh),
                AppUtils().dataNullCheck(symbols.ltp),
              ),
            ],
          ),
      ],
    );
  }

  static Widget _buildFiftyWeekWidget(
    String fiftyWL,
    String fiftyWH,
    String ltp,
  ) {
    double fiftyWLPercent =
        ((AppUtils().doubleValue(AppUtils().dataNullCheck(ltp)) -
                    AppUtils().doubleValue(AppUtils().dataNullCheck(fiftyWL))) /
                AppUtils().doubleValue(AppUtils().dataNullCheck(ltp))) *
            100;
    double fiftyWHPercent =
        ((AppUtils().doubleValue(AppUtils().dataNullCheck(fiftyWH)) -
                    AppUtils().doubleValue(AppUtils().dataNullCheck(ltp))) /
                AppUtils().doubleValue(AppUtils().dataNullCheck(ltp))) *
            100;

    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildRichCustomTextWidget(
            '${AppUtils().isValueNAN(fiftyWLPercent).toInt().toString()}.',
            '${AppUtils().isValueNAN(fiftyWLPercent).toStringAsFixed(2).split(".")[1]}%',
            ' down side',
            true,
          ),
          _buildRichCustomTextWidget(
            'up side ',
            '${AppUtils().isValueNAN(fiftyWHPercent).toInt().toString()}.',
            '${AppUtils().isValueNAN(fiftyWHPercent).toStringAsFixed(2).split(".")[1]}%',
            false,
          ),
        ],
      ),
    );
  }

  static Widget _buildRichCustomTextWidget(
    String text1,
    String text2,
    String text3,
    bool isLeft,
  ) {
    return Row(
      children: [
        if (isLeft) AppImages.fiftyWlowIcon(navigatorKey.currentContext!),
        Padding(
          padding: isLeft
              ? EdgeInsets.only(
                  left: 5.w,
                )
              : EdgeInsets.only(
                  right: AppWidgetSize.dimen_5,
                ),
          child: RichText(
            text: TextSpan(
              text: text1,
              style: isLeft
                  ? Theme.of(navigatorKey.currentContext!)
                      .primaryTextTheme
                      .bodySmall
                  : Theme.of(navigatorKey.currentContext!)
                      .primaryTextTheme
                      .bodyLarge!
                      .copyWith(
                        color: Theme.of(navigatorKey.currentContext!)
                            .inputDecorationTheme
                            .labelStyle!
                            .color,
                      ),
              children: [
                TextSpan(
                  text: text2,
                  style: isLeft
                      ? Theme.of(navigatorKey.currentContext!)
                          .primaryTextTheme
                          .bodyMedium!
                          .copyWith(
                            color: Theme.of(navigatorKey.currentContext!)
                                .primaryTextTheme
                                .bodySmall!
                                .color,
                          )
                      : Theme.of(navigatorKey.currentContext!)
                          .primaryTextTheme
                          .bodySmall,
                ),
                TextSpan(
                  text: text3,
                  style: isLeft
                      ? Theme.of(navigatorKey.currentContext!)
                          .primaryTextTheme
                          .bodyLarge!
                          .copyWith(
                            color: Theme.of(navigatorKey.currentContext!)
                                .inputDecorationTheme
                                .labelStyle!
                                .color,
                          )
                      : Theme.of(navigatorKey.currentContext!)
                          .primaryTextTheme
                          .bodyMedium!
                          .copyWith(
                            color: Theme.of(navigatorKey.currentContext!)
                                .primaryTextTheme
                                .bodySmall!
                                .color,
                          ),
                ),
              ],
            ),
          ),
        ),
        if (!isLeft) AppImages.fiftyWhighIcon(navigatorKey.currentContext!),
      ],
    );
  }

  static Widget buildPerformanceTopContent(
    Symbols symbolItem,
  ) {
    return SizedBox(
      child: Column(
        children: [
          buildTableWithBackgroundColor(
              AppLocalizations().open,
              AppUtils().dataNullCheckDashDash(symbolItem.open),
              AppLocalizations().high,
              AppUtils().dataNullCheckDashDash(symbolItem.high),
              AppUtils().getsymbolType(symbolItem) == AppConstants.indices
                  ? ''
                  : AppLocalizations().low,
              AppUtils().getsymbolType(symbolItem) == AppConstants.indices
                  ? ''
                  : AppUtils().dataNullCheckDashDash(symbolItem.low),
              navigatorKey.currentContext!,
              isReduceFontSize: true),
          buildTableWithBackgroundColor(
              AppUtils().getsymbolType(symbolItem) == AppConstants.indices
                  ? AppLocalizations().low
                  : AppLocalizations().volume,
              AppUtils().getsymbolType(symbolItem) == AppConstants.indices
                  ? AppUtils().dataNullCheckDashDash(symbolItem.low)
                  : AppUtils().dataNullCheckDashDash(symbolItem.vol),
              AppUtils().getsymbolType(symbolItem) == AppConstants.indices
                  ? AppLocalizations().prevClose
                  : AppLocalizations().avgPrice,
              AppUtils().getsymbolType(symbolItem) == AppConstants.indices
                  ? AppUtils().dataNullCheckDashDash(symbolItem.close)
                  : AppUtils().dataNullCheckDashDash(symbolItem.atp),
              AppUtils().getsymbolType(symbolItem) == AppConstants.indices
                  ? ""
                  : AppLocalizations().prevClose,
              AppUtils().getsymbolType(symbolItem) == AppConstants.indices
                  ? ""
                  : AppUtils().dataNullCheckDashDash(symbolItem.close),
              navigatorKey.currentContext!,
              isReduceFontSize: true),
          if (AppUtils().getsymbolType(symbolItem) != AppConstants.indices)
            buildTableWithBackgroundColor(
                AppLocalizations().lowerCircuit,
                AppUtils().dataNullCheckDashDash(symbolItem.lcl),
                AppLocalizations().upperCircuit,
                AppUtils().dataNullCheckDashDash(symbolItem.ucl),
                AppLocalizations().oI,
                AppUtils().dataNullCheckDashDash(symbolItem.openInterest),
                navigatorKey.currentContext!,
                isReduceFontSize: true),
        ],
      ),
    );
  }

  static Widget _buildPerformanceIndicatorWidget(
    String fiftyWL,
    String fiftyWH,
    String ltp,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_15),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_80,
              right: AppWidgetSize.dimen_80,
            ),
            child: _buildSeekBarWidget(),
          ),
          Positioned(
            left: 0,
            child: _buildIndicatorLeadingTrailingWidget(
              true,
              AppLocalizations().fifityTwoWL,
              fiftyWL,
            ),
          ),
          Positioned(
            right: 0,
            child: _buildIndicatorLeadingTrailingWidget(
              false,
              AppLocalizations().fifityTwoWH,
              fiftyWH,
            ),
          ),
          if (ltp != "") _buildFloatingLtpWidget(fiftyWL, fiftyWH, ltp),
        ],
      ),
    );
  }

  static Widget _buildFloatingLtpWidget(
    String fiftyWL,
    String fiftyWH,
    String ltp,
  ) {
    final double pecetangeRange =
        (AppUtils().doubleValue(ltp) - AppUtils().doubleValue(fiftyWL)) /
            (AppUtils().doubleValue(fiftyWH) - AppUtils().doubleValue(fiftyWL));
    final double ltpLabelWidth = ltp == ''
        ? 5.w
        : ltp.textSize(
                ltp,
                Theme.of(navigatorKey.currentContext!)
                    .primaryTextTheme
                    .bodyLarge!
                    .copyWith(
                      color: Theme.of(navigatorKey.currentContext!)
                          .colorScheme
                          .secondary,
                    )) +
            7.w;
    return Positioned(
      child: Container(
        height: 50.w,
        margin: EdgeInsets.only(
          top: 10.w,
          left: (AppWidgetSize.fullWidth(navigatorKey.currentContext!) / 2.1 -
                      AppWidgetSize.fullWidth(navigatorKey.currentContext!) /
                          5.5 /
                          AppWidgetSize.dimen_4) *
                  (pecetangeRange > 0 ? pecetangeRange : 0) -
              ltpLabelWidth / 2 +
              AppWidgetSize.dimen_89,
        ),
        child: Stack(
          children: [
            Container(
              width: ltpLabelWidth,
              height: 20.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(AppWidgetSize.dimen_3),
                ),
                color: Theme.of(navigatorKey.currentContext!)
                    .primaryIconTheme
                    .color,
              ),
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_1,
                left: AppWidgetSize.dimen_3,
                right: AppWidgetSize.dimen_3,
              ),
              child: CustomTextWidget(
                ltp,
                Theme.of(navigatorKey.currentContext!)
                    .primaryTextTheme
                    .bodyLarge!
                    .copyWith(
                      color: Theme.of(navigatorKey.currentContext!)
                          .scaffoldBackgroundColor,
                    ),
              ),
            ),
            Positioned(
              top: 10.w,
              left: (ltpLabelWidth / 2) - AppWidgetSize.dimen_12,
              child: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(navigatorKey.currentContext!)
                    .primaryIconTheme
                    .color!,
                size: 20.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildIndicatorLeadingTrailingWidget(
    bool isLeading,
    String headline1,
    String headline2,
  ) {
    return Column(
      crossAxisAlignment:
          isLeading ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10.w),
          child: CustomTextWidget(
            headline1,
            Theme.of(navigatorKey.currentContext!)
                .primaryTextTheme
                .bodyLarge!
                .copyWith(
                  color: Theme.of(navigatorKey.currentContext!)
                      .primaryTextTheme
                      .bodySmall!
                      .color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        _buildFiftyWeekLabel(
          headline2,
          isLeading,
        ),
      ],
    );
  }

  static Widget _buildSeekBarWidget() {
    return Container(
      margin: EdgeInsets.only(top: 36.w),
      width: AppWidgetSize.fullWidth(navigatorKey.currentContext!),
      height: AppWidgetSize.dimen_8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20.w)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          stops: const <double>[
            0.3,
            0.7,
          ],
          colors: <Color>[
            Theme.of(navigatorKey.currentContext!).colorScheme.onSecondary,
            Theme.of(navigatorKey.currentContext!).colorScheme.onPrimary,
          ],
        ),
      ),
    );
  }

  static Widget _buildFiftyWeekLabel(
    String value,
    bool isLeft,
  ) {
    return Container(
      width: 80.w,
      constraints: BoxConstraints(
          // maxWidth: AppWidgetSize.fullWidth(navigatorKey.currentContext!) / 5.5,
          maxHeight: 30.w),
      decoration: BoxDecoration(
        borderRadius: isLeft
            ? BorderRadius.only(
                topLeft: Radius.circular(20.w),
                bottomLeft: Radius.circular(20.w),
              )
            : BorderRadius.only(
                topRight: Radius.circular(20.w),
                bottomRight: Radius.circular(20.w),
              ),
        color: Theme.of(navigatorKey.currentContext!)
            .snackBarTheme
            .backgroundColor!
            .withOpacity(0.5),
      ),
      alignment: Alignment.center,
      child: CustomTextWidget(
        value,
        Theme.of(navigatorKey.currentContext!)
            .primaryTextTheme
            .bodySmall!
            .copyWith(
              fontWeight: FontWeight.w600,
            )
            .copyWith(
              fontSize: AppWidgetSize.fontSize10,
            ),
      ),
    );
  }

  static Future<void> showPerformanceBottomSheet(
      Symbols symbolItem, BuildContext context) async {
    InfoBottomSheet.showInfoBottomsheet(
      BlocProvider<QuoteOverviewBloc>.value(
        value: QuoteOverviewBloc(),
        child: PerformanceBottomSheet(
          arguments: {
            'symbolItem': symbolItem,
          },
        ),
      ),
      context,
      horizontalMargin: false,
    );
  }
}
