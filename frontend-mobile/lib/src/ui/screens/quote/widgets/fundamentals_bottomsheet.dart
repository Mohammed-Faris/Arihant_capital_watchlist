import 'package:flutter/material.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/quote/quote_fundamentals/quote_financials_ratios.dart';
import '../../../../models/quote/quote_fundamentals/quote_key_stats.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/table_with_bgcolor.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../base/base_screen.dart';

class FundamentalsBottomSheet extends BaseScreen {
  final dynamic arguments;
  const FundamentalsBottomSheet({Key? key, this.arguments}) : super(key: key);

  @override
  FundamentalsBottomSheetState createState() => FundamentalsBottomSheetState();
}

class FundamentalsBottomSheetState
    extends BaseAuthScreenState<FundamentalsBottomSheet> {
  late AppLocalizations _appLocalizations;
  QuoteKeyStats? quoteKeyStats;
  QuoteFinancialsRatios? quoteFinancialsRatios;

  @override
  void initState() {
    quoteKeyStats = widget.arguments['quoteKeyStats'];
    quoteFinancialsRatios = widget.arguments['quoteFinancialsRatios'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.w),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: 1, color: Theme.of(context).dividerColor))),
          padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_10,
            bottom: AppWidgetSize.dimen_15,
          ),
          child: _getFundamentalsBottomSheetHeader(),
        ),
        _buildBody(context),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_20,
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
      ),
      child: SingleChildScrollView(child: _getFundamentalsBottomSheetContent()),
    );
  }

  Widget _getFundamentalsBottomSheetContent() {
    return Wrap(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_20,
          ),
          child: _buildFundamentalsTableWidget(),
        ),
      ],
    );
  }

  Widget _getFundamentalsBottomSheetHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        CustomTextWidget(
          _appLocalizations.fundamentals,
          Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: AppImages.closeIcon(
            context,
            color: Theme.of(context).primaryIconTheme.color,
            isColor: true,
            width: AppWidgetSize.dimen_22,
            height: AppWidgetSize.dimen_22,
          ),
        ),
      ],
    );
  }

  Widget _buildFundamentalsTableWidget() {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTableWithBackgroundColor(
              _appLocalizations.mktCapcr,
              quoteKeyStats != null ? quoteKeyStats!.stats!.mcap! : '--',
              _appLocalizations.pE,
              quoteKeyStats != null ? quoteKeyStats!.stats!.pe! : '--',
              _appLocalizations.priceToBook,
              quoteKeyStats != null ? quoteKeyStats!.stats!.prcBookVal! : '--',
              context,
              isReduceFontSize: true),
          buildTableWithBackgroundColor(
              _appLocalizations.bookValue,
              quoteKeyStats != null ? quoteKeyStats!.stats!.bookValue! : '--',
              _appLocalizations.epsTtm,
              quoteKeyStats != null ? quoteKeyStats!.stats!.eps! : '--',
              _appLocalizations.dividendYield,
              quoteKeyStats != null ? quoteKeyStats!.stats!.divYield! : '--',
              context,
              isReduceFontSize: true),
          buildTableWithBackgroundColor(
              _appLocalizations.roe,
              quoteFinancialsRatios != null
                  ? quoteFinancialsRatios!.roe!
                  : '--',
              _appLocalizations.debtToEquity,
              quoteFinancialsRatios != null
                  ? quoteFinancialsRatios!.debtEqty!
                  : '--',
              _appLocalizations.operatingMargin,
              quoteFinancialsRatios != null
                  ? quoteFinancialsRatios!.operatingMargin!
                  : '--',
              context,
              isReduceFontSize: true),
          buildTableWithBackgroundColor(
              _appLocalizations.netSalesGrowth,
              quoteFinancialsRatios != null
                  ? quoteFinancialsRatios!.netSalesGrowth!
                  : '--',
              _appLocalizations.roa,
              quoteFinancialsRatios != null
                  ? quoteFinancialsRatios!.roa!
                  : '--',
              _appLocalizations.interestCover,
              quoteFinancialsRatios != null
                  ? quoteFinancialsRatios!.interestCover!
                  : '--',
              context,
              isReduceFontSize: true),
          buildTableWithBackgroundColor(
              _appLocalizations.evToEbit,
              quoteFinancialsRatios != null
                  ? quoteFinancialsRatios!.evToEbit!
                  : '--',
              _appLocalizations.evToEbida,
              quoteFinancialsRatios != null
                  ? quoteFinancialsRatios!.evToEbitda!
                  : '--',
              _appLocalizations.evToSales,
              quoteFinancialsRatios != null
                  ? quoteFinancialsRatios!.evToSales!
                  : '--',
              context,
              isReduceFontSize: true),
          buildTableWithBackgroundColor(
              _appLocalizations.pegRatio,
              quoteFinancialsRatios != null
                  ? quoteFinancialsRatios!.pegRatio!
                  : '--',
              _appLocalizations.fixedTurnOver,
              quoteFinancialsRatios != null
                  ? quoteFinancialsRatios!.fixedTurnover!
                  : '--',
              _appLocalizations.netProfitMargin,
              quoteFinancialsRatios != null
                  ? quoteFinancialsRatios!.netProfitMargin!
                  : '--',
              context,
              isReduceFontSize: true),
        ],
      ),
    );
  }
}
