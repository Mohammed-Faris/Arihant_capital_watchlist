import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../blocs/quote/financials/financials_view_more/financials_view_more_bloc.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../constants/keys/search_keys.dart';
import '../../../../../data/store/app_store.dart';
import '../../../../../data/store/app_utils.dart';
import '../../../../../localization/app_localization.dart';
import '../../../../../models/common/symbols_model.dart';
import '../../../../../models/quote/quote_financials/quote_financials_view_more/quote_quarterly_income_statements.dart';
import '../../../../../models/quote/quote_financials/quote_financials_view_more/quote_yearly_income_statement.dart';
import '../../../../../notifiers/notifiers.dart';
import '../../../../styles/app_images.dart';
import '../../../../styles/app_widget_size.dart';
import '../../../../widgets/circular_toggle_button_widget.dart';
import '../../../../widgets/custom_text_widget.dart';
import '../../../../widgets/error_image_widget.dart';
import '../../../../widgets/expansion_tile.dart';
import '../../../../widgets/loader_widget.dart';
import '../../../base/base_screen.dart';

class QuoteFinancialsIncomeStatements extends BaseScreen {
  final dynamic arguments;

  const QuoteFinancialsIncomeStatements({Key? key, this.arguments})
      : super(key: key);

  @override
  State<QuoteFinancialsIncomeStatements> createState() =>
      _QuoteFinancialsIncomeStatementsState();
}

class _QuoteFinancialsIncomeStatementsState
    extends BaseAuthScreenState<QuoteFinancialsIncomeStatements> {
  late AppLocalizations _appLocalizations;
  late Symbols _symbols = Symbols();
  final ScrollController _contentController = ScrollController();
  late final SelectFilterNotifier _filterNotifier = SelectFilterNotifier(0);
  late final ExpandingRevenue _expandingRevenue = ExpandingRevenue(false);
  late final ExpandingExpenses _expandingExpenses = ExpandingExpenses(false);
  YearlyIncomeStatement _yearlyIncomeStatement = YearlyIncomeStatement();
  QuarterlyIncomeStatement _quarterlyIncomeStatement =
      QuarterlyIncomeStatement();
  late List<Financials>? _financials;
  late FinancialsViewMoreBloc _financialsViewMoreBloc;
  int viewPosition = 0;
  int periodPosition = 0;

  @override
  void initState() {
    super.initState();
    _symbols = widget.arguments['symbolItem'];

    _financialsViewMoreBloc = BlocProvider.of<FinancialsViewMoreBloc>(context)
      ..add(ViewMoreIncomeQuarterlyStatementHoldingEvent(_symbols.sym)
        ..consolidated = widget.arguments["consolidated"])
      ..stream.listen(_quoteShareHoldingListener);
  }

  Future<void> _quoteShareHoldingListener(FinancialsViewMoreState state) async {
    if (state is FinancialsViewMoreProgressState) {}
    if (state is FinancialsQuarterlyIncomeStatementDoneState ||
        state is FinancialsYearlyIncomeStatementDoneState) {
    } else if (state is FinancialsViewMoreFailedState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state is FinancialsViewMoreErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _symbols = widget.arguments['symbolItem'];
    _appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocBuilder<FinancialsViewMoreBloc, FinancialsViewMoreState>(
        bloc: _financialsViewMoreBloc,
        builder: (context, state) {
          if (state is FinancialsViewMoreProgressState) {
            return const LoaderWidget();
          }
          if (state is FinancialsQuarterlyIncomeStatementDoneState) {
            _quarterlyIncomeStatement = state.quarterlyIncomeStatement;
            _financials = _quarterlyIncomeStatement.financials;
            currentPostion = 0;
            return bodyQuarterlyData(context);
          } else if (state is FinancialsYearlyIncomeStatementDoneState) {
            _yearlyIncomeStatement = state.yearlyIncomeStatement;
            currentPostion = 0;
            return bodyYearlyData(context);
          }
          if (state is FinancialsServiceExceptionState) {
            return errorWithImageWidget(
              context: context,
              imageWidget: AppUtils().getNoDateImageErrorWidget(context),
              errorMessage: state.errorMsg,
              padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_30,
                right: AppWidgetSize.dimen_30,
                bottom: AppWidgetSize.dimen_30,
              ),
            );
          }
          return Padding(
              padding: EdgeInsets.only(
                  left: AppWidgetSize.dimen_16, right: AppWidgetSize.dimen_16),
              child: Column(
                children: [
                  _buildTimeRow(context, nodata: true),
                  Expanded(
                    child: errorWithImageWidget(
                      context: context,
                      imageWidget:
                          AppUtils().getNoDateImageErrorWidget(context),
                      errorMessage:
                          AppLocalizations().noDataAvailableErrorMessage,
                      padding: EdgeInsets.only(
                        left: AppWidgetSize.dimen_30,
                        right: AppWidgetSize.dimen_30,
                        bottom: AppWidgetSize.dimen_30,
                      ),
                    ),
                  ),
                ],
              ));
        },
      ),
    );
  }

  Padding bodyYearlyData(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_16, right: AppWidgetSize.dimen_16),
      child: Column(
        children: [
          _buildTimeRow(context, isyearly: true),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [],
          ),
          Padding(
            padding: EdgeInsets.all(AppWidgetSize.dimen_1),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: ValueListenableBuilder(
                      valueListenable: _expandingRevenue,
                      builder:
                          (BuildContext context, dynamic value, Widget? child) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopLeftLabel(context, value),
                            buildValues(context, value,
                                isTop: true, isYear: true),
                          ],
                        );
                      }),
                ),
                Padding(
                  padding: EdgeInsets.only(top: AppWidgetSize.dimen_2),
                  child: ValueListenableBuilder(
                      valueListenable: _expandingExpenses,
                      builder:
                          (BuildContext context, dynamic value, Widget? child) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBottomLeftLabel(context, value),
                            buildValues(context, value, isYear: true),
                          ],
                        );
                      }),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Padding bodyQuarterlyData(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_16,
        right: AppWidgetSize.dimen_16,
      ),
      child: Column(
        children: [
          _buildTimeRow(context),
          Padding(
            padding: EdgeInsets.all(AppWidgetSize.dimen_1),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: AppWidgetSize.dimen_2,
                  ),
                  child: ValueListenableBuilder(
                      valueListenable: _expandingRevenue,
                      builder: (
                        BuildContext context,
                        dynamic value,
                        Widget? child,
                      ) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopLeftLabel(
                              context,
                              value,
                            ),
                            buildValues(
                              context,
                              value,
                              isTop: true,
                            ),
                          ],
                        );
                      }),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_2,
                  ),
                  child: ValueListenableBuilder(
                      valueListenable: _expandingExpenses,
                      builder: (
                        BuildContext context,
                        dynamic value,
                        Widget? child,
                      ) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBottomLeftLabel(
                              context,
                              value,
                            ),
                            buildValues(
                              context,
                              value,
                            ),
                          ],
                        );
                      }),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTimeRow(
    BuildContext context, {
    bool isyearly = false,
    bool nodata = false,
  }) {
    return SizedBox(
      height: AppWidgetSize.dimen_120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFinancialTime(context),
          if (!nodata)
            SizedBox(
              height: AppWidgetSize.dimen_30,
              child: VerticalDivider(
                color: Theme.of(context).dividerColor,
                width: 6,
              ),
            ),
          if (!nodata) SizedBox(child: _buildYearsPeriod(isyearly)),
        ],
      ),
    );
  }

  Flexible _buildTopLeftLabel(BuildContext context, bool value) {
    return Flexible(
        flex: 5,
        child: Padding(
          padding: EdgeInsets.only(right: AppWidgetSize.dimen_4),
          child: Theme(
              data: ThemeData().copyWith(
                  dividerColor: Colors.transparent,
                  cardColor: Theme.of(context).scaffoldBackgroundColor,
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                      background: Theme.of(context).colorScheme.background)),
              child: AppExpansionPanelList(
                  animationDuration: const Duration(milliseconds: 200),
                  elevation: 0,
                  expansionCallback: (int index, bool isExpanded) {
                    _expandingRevenue.updateExpandingRevenue(!isExpanded);
                  },
                  expandedHeaderPadding: EdgeInsets.zero,
                  children: [
                    ExpansionPanel(
                      backgroundColor: Theme.of(context).colorScheme.background,
                      canTapOnHeader: true,
                      body: revenueHeaderBody(context),
                      headerBuilder: (context, isExpanded) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            revenueHeader(context),
                            Padding(
                              padding:
                                  EdgeInsets.only(right: AppWidgetSize.dimen_8),
                              child: value
                                  ? AppImages.qtyDecreaseIcon(
                                      context,
                                      isColor: true,
                                      color: AppStore().getThemeData() ==
                                              AppConstants.lightMode
                                          ? const Color(0xFF3F3F3F)
                                          : Colors.white,
                                      width: AppWidgetSize.dimen_22,
                                      height: AppWidgetSize.dimen_22,
                                    )
                                  : AppImages.qtyIncreaseIcon(
                                      context,
                                      isColor: true,
                                      color: AppStore().getThemeData() ==
                                              AppConstants.lightMode
                                          ? const Color(0xFF3F3F3F)
                                          : Colors.white,
                                      width: AppWidgetSize.dimen_22,
                                      height: AppWidgetSize.dimen_22,
                                    ),
                            ),
                          ],
                        );
                      },
                      isExpanded: value,
                    ),
                  ])),
        ));
  }

  Padding revenueHeaderBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: AppWidgetSize.dimen_5),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: AppWidgetSize.dimen_8),
            child: Column(
              children: [
                SizedBox(
                  height: AppWidgetSize.dimen_80,
                  child: VerticalDivider(
                    color: Theme.of(context).dividerColor,
                    width: 3,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: AppWidgetSize.dimen_40,
                child: Center(
                  child: CustomTextWidget(
                    'Revenue From Operations',
                    Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                        fontSize: AppWidgetSize.fontSize14,
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: AppWidgetSize.dimen_40,
                child: Center(
                  child: CustomTextWidget(
                    'Other Revenue',
                    Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                        fontSize: AppWidgetSize.fontSize14,
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Container revenueHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: AppWidgetSize.dimen_5),
      alignment: Alignment.centerLeft,
      height: AppWidgetSize.dimen_40,
      child: Text(
        'Revenue',
        style: TextStyle(
            letterSpacing: 0,
            color: AppStore().getThemeData() == AppConstants.lightMode
                ? const Color(0xFF3F3F3F)
                : Colors.white,
            fontFamily: "futura",
            fontSize: AppWidgetSize.fontSize16,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Flexible buildValues(BuildContext context, bool value,
      {bool isYear = false, bool isTop = false}) {
    return Flexible(
        flex: 5,
        child: Padding(
          padding: EdgeInsets.only(right: AppWidgetSize.dimen_4),
          child: Theme(
              data: ThemeData().copyWith(
                  secondaryHeaderColor:
                      Theme.of(context).colorScheme.background,
                  dividerColor: Colors.transparent,
                  cardColor: Theme.of(context).colorScheme.background,
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        background: Theme.of(context).colorScheme.background,
                      )),
              child: AppExpansionPanelList(
                  animationDuration: const Duration(milliseconds: 200),
                  elevation: 0,
                  children: [
                    ExpansionPanel(
                      backgroundColor: Theme.of(context).colorScheme.background,
                      canTapOnHeader: false,
                      body: Column(
                        children: [
                          Container(
                            height: AppWidgetSize.dimen_40,
                            color: Theme.of(context).colorScheme.background,
                            margin:
                                EdgeInsets.only(right: AppWidgetSize.dimen_5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  isTop
                                      ? isYear
                                          ? _yearlyIncomeStatement.values!
                                              .revnuFrmOprns![viewPosition]
                                          : _financials![viewPosition]
                                              .revnuFrmOprns
                                              .toString()
                                      : isYear
                                          ? _yearlyIncomeStatement
                                              .values!.ebitda![viewPosition]
                                          : _financials![viewPosition]
                                              .eDIDTA
                                              .toString(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall!
                                      .copyWith(
                                          fontSize: AppWidgetSize.fontSize14,
                                          fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  isTop
                                      ? isYear
                                          ? _yearlyIncomeStatement.values!
                                              .revnuFrmOprns![viewPosition + 1]
                                          : _financials![viewPosition + 1]
                                              .revnuFrmOprns
                                              .toString()
                                      : isYear
                                          ? _yearlyIncomeStatement
                                              .values!.ebitda![viewPosition + 1]
                                          : _financials![viewPosition + 1]
                                              .eDIDTA
                                              .toString(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall!
                                      .copyWith(
                                          fontSize: AppWidgetSize.fontSize14,
                                          fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: AppWidgetSize.dimen_40,
                            color: Theme.of(context).colorScheme.background,
                            margin:
                                EdgeInsets.only(right: AppWidgetSize.dimen_5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  isTop
                                      ? isYear
                                          ? _yearlyIncomeStatement
                                              .values!.othrInc![viewPosition]
                                          : _financials![viewPosition]
                                              .othrInc
                                              .toString()
                                      : isYear
                                          ? _yearlyIncomeStatement
                                              .values!.prftBfrTax![viewPosition]
                                          : _financials![viewPosition]
                                              .prftBfrTax
                                              .toString(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall!
                                      .copyWith(
                                          fontSize: AppWidgetSize.fontSize14,
                                          fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  isTop
                                      ? isYear
                                          ? _yearlyIncomeStatement.values!
                                              .othrInc![viewPosition + 1]
                                          : _financials![viewPosition + 1]
                                              .othrInc
                                              .toString()
                                      : isYear
                                          ? _yearlyIncomeStatement.values!
                                              .prftBfrTax![viewPosition + 1]
                                          : _financials![viewPosition + 1]
                                              .prftBfrTax
                                              .toString(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall!
                                      .copyWith(
                                          fontSize: AppWidgetSize.fontSize14,
                                          fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          if (!isTop)
                            Container(
                              height: AppWidgetSize.dimen_40,
                              color: Theme.of(context).colorScheme.background,
                              margin:
                                  EdgeInsets.only(right: AppWidgetSize.dimen_5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    isYear
                                        ? _yearlyIncomeStatement
                                            .values!.netPrft![viewPosition]
                                        : _financials![viewPosition]
                                            .netproftLoss
                                            .toString(),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall!
                                        .copyWith(
                                            fontSize: AppWidgetSize.fontSize14,
                                            fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    isYear
                                        ? _yearlyIncomeStatement
                                            .values!.netPrft![viewPosition + 1]
                                        : _financials![viewPosition + 1]
                                            .netproftLoss
                                            .toString(),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelSmall!
                                        .copyWith(
                                            fontSize: AppWidgetSize.fontSize14,
                                            fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      headerBuilder: (context, isExpanded) {
                        return Container(
                          margin: EdgeInsets.only(right: AppWidgetSize.dimen_4),
                          height: AppWidgetSize.dimen_40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                isTop
                                    ? isYear
                                        ? _yearlyIncomeStatement
                                            .values!.revenue![viewPosition]
                                        : _financials![viewPosition]
                                            .ttlIncome
                                            .toString()
                                    : isYear
                                        ? _yearlyIncomeStatement
                                            .values!.expnses![viewPosition]
                                        : _financials![viewPosition]
                                                .expnditure
                                                ?.toString() ??
                                            "-",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    color: AppStore().getThemeData() ==
                                            AppConstants.lightMode
                                        ? const Color(0xFF3F3F3F)
                                        : Colors.white,
                                    fontFamily: "futura",
                                    fontSize: AppWidgetSize.fontSize14,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                isTop
                                    ? isYear
                                        ? _yearlyIncomeStatement
                                            .values!.revenue![viewPosition + 1]
                                        : _financials![viewPosition + 1]
                                            .ttlIncome
                                            .toString()
                                    : isYear
                                        ? _yearlyIncomeStatement
                                            .values!.expnses![viewPosition + 1]
                                        : _financials![viewPosition + 1]
                                                .expnditure
                                                ?.toString() ??
                                            "-",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    color: AppStore().getThemeData() ==
                                            AppConstants.lightMode
                                        ? const Color(0xFF3F3F3F)
                                        : Colors.white,
                                    fontFamily: "futura",
                                    fontSize: AppWidgetSize.fontSize14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      },
                      isExpanded: value,
                    ),
                  ])),
        ));
  }

  Flexible _buildBottomLeftLabel(BuildContext context, bool value) {
    return Flexible(
        flex: 5,
        child: Padding(
          padding: EdgeInsets.only(right: AppWidgetSize.dimen_4),
          child: Theme(
              data: ThemeData().copyWith(
                  secondaryHeaderColor:
                      Theme.of(context).colorScheme.background,
                  dividerColor: Colors.transparent,
                  cardColor: Theme.of(context).colorScheme.background,
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                      background: Theme.of(context).colorScheme.background)),
              child: AppExpansionPanelList(
                  animationDuration: const Duration(milliseconds: 200),
                  elevation: 0,
                  expansionCallback: (int index, bool isExpanded) {
                    _expandingExpenses.updateExpandingExpenses(!isExpanded);
                  },
                  expandedHeaderPadding: EdgeInsets.zero,
                  children: [
                    ExpansionPanel(
                      backgroundColor: Theme.of(context).colorScheme.background,
                      canTapOnHeader: true,
                      body: bottomLabelBodyContent(context),
                      headerBuilder: (context, isExpanded) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                padding: EdgeInsets.only(
                                    left: AppWidgetSize.dimen_5),
                                alignment: Alignment.centerLeft,
                                height: AppWidgetSize.dimen_40,
                                child: Text('Expenses',
                                    style: TextStyle(
                                        letterSpacing: 0,
                                        color: AppStore().getThemeData() ==
                                                AppConstants.lightMode
                                            ? const Color(0xFF3F3F3F)
                                            : Colors.white,
                                        fontFamily: "futura",
                                        fontSize: AppWidgetSize.fontSize16,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center)),
                            Padding(
                              padding:
                                  EdgeInsets.only(right: AppWidgetSize.dimen_8),
                              child: value
                                  ? AppImages.qtyDecreaseIcon(
                                      context,
                                      isColor: true,
                                      color: AppStore().getThemeData() ==
                                              AppConstants.lightMode
                                          ? const Color(0xFF3F3F3F)
                                          : Colors.white,
                                      width: AppWidgetSize.dimen_22,
                                      height: AppWidgetSize.dimen_22,
                                    )
                                  : AppImages.qtyIncreaseIcon(
                                      context,
                                      isColor: true,
                                      color: AppStore().getThemeData() ==
                                              AppConstants.lightMode
                                          ? const Color(0xFF3F3F3F)
                                          : Colors.white,
                                      width: AppWidgetSize.dimen_22,
                                      height: AppWidgetSize.dimen_22,
                                    ),
                            ),
                          ],
                        );
                      },
                      isExpanded: value,
                    ),
                  ])),
        ));
  }

  Container bottomLabelBodyContent(BuildContext context) {
    return Container(
      height: AppWidgetSize.dimen_120,
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          Container(
            height: AppWidgetSize.dimen_120,
            padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: AppWidgetSize.dimen_8),
                  child: Column(
                    children: [
                      SizedBox(
                        height: AppWidgetSize.dimen_120,
                        child: VerticalDivider(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: AppWidgetSize.dimen_40,
                      child: Center(
                        child: Text(
                          'EBITDA',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .copyWith(
                                  fontSize: AppWidgetSize.fontSize14,
                                  fontWeight: FontWeight.w400),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: AppWidgetSize.dimen_40,
                      child: Center(
                        child: Text(
                          'Profit Before Tax',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .copyWith(
                                  fontSize: AppWidgetSize.fontSize14,
                                  fontWeight: FontWeight.w400),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: AppWidgetSize.dimen_40,
                      child: Center(
                        child: Text(
                          'Net Profit',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .copyWith(
                                  fontSize: AppWidgetSize.fontSize14,
                                  fontWeight: FontWeight.w400),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> financialTimePeriod = [
    AppLocalizations().quarterly,
    AppLocalizations().yearly
  ];

  _buildFinancialTime(
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.only(
          right: 0.0,
          left: 0,
          top: AppWidgetSize.dimen_4,
          bottom: AppWidgetSize.dimen_4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: CircularButtonToggleWidget(
          value: financialTimePeriod[periodPosition],
          toggleButtonlist:
              financialTimePeriod.map((s) => s as dynamic).toList(),
          toggleButtonOnChanged: toggleButtonOnChanged,
          key: const Key(filters_),
          defaultSelected: '',
          enabledButtonlist: const [],
          marginEdgeInsets: buildMarginEdgeInsets(),
          paddingEdgeInsets: buildPaddingEdgeInsets(),
          inactiveButtonColor: Colors.transparent,
          activeButtonColor:
              Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.5),
          inactiveTextColor: Theme.of(context).primaryColor,
          activeTextColor: Theme.of(context).primaryColor,
          isBorder: false,
          context: context,
          borderColor: Colors.transparent,
          fontSize: AppUtils.isTablet ? 20.w : 15.w,
        ),
      ),
    );
  }

  double currentPostion = 0;
  Widget _buildYearsPeriod(bool isYearly) {
    return SizedBox(
      height: AppWidgetSize.dimen_45,
      child: ValueListenableBuilder(
          valueListenable: _filterNotifier,
          builder:
              (BuildContext context, dynamic notifiervalue, Widget? child) {
            return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      width: AppWidgetSize.dimen_20,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: AbsorbPointer(
                          absorbing: notifiervalue <= 0,
                          child: GestureDetector(
                              onTap: () {
                                currentPostion = currentPostion -
                                    (((AppWidgetSize.screenWidth(context) / 2) -
                                            (AppWidgetSize.dimen_80)) /
                                        2);
                                _contentController.jumpTo(currentPostion);
                                _filterNotifier
                                    .changeFilterPosition(notifiervalue - 1);

                                viewPosition = viewPosition - 1;

                                updateRevenueExpenses();
                              },
                              child: notifiervalue <= 0
                                  ? AppImages.leftSwipeDisabledIcon(
                                      context,
                                      isColor: true,
                                      color: Theme.of(context)
                                          .primaryIconTheme
                                          .color,
                                      width: AppWidgetSize.dimen_22,
                                      height: AppWidgetSize.dimen_22,
                                    )
                                  : AppImages.leftSwipeEnabledIcon(
                                      context,
                                      isColor: true,
                                      color: Theme.of(context)
                                          .primaryIconTheme
                                          .color,
                                      width: AppWidgetSize.dimen_22,
                                      height: AppWidgetSize.dimen_22,
                                    )),
                        ),
                      )),
                  _buildTimePeriodFilterList(isYearly),
                  SizedBox(
                    width: AppWidgetSize.dimen_20,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: AbsorbPointer(
                          absorbing: isYearly
                              ? notifiervalue >=
                                  (_yearlyIncomeStatement
                                              .values!.revenue?.length ??
                                          0) -
                                      2
                              : notifiervalue >= (_financials?.length ?? 0) - 2,
                          child: GestureDetector(
                            onTap: () {
                              currentPostion = currentPostion +
                                  (((AppWidgetSize.screenWidth(context) / 2) -
                                          (AppWidgetSize.dimen_80)) /
                                      2);
                              _contentController.jumpTo(
                                currentPostion,
                              );
                              _filterNotifier
                                  .changeFilterPosition(notifiervalue + 1);
                              viewPosition = viewPosition + 1;
                              updateRevenueExpenses();
                            },
                            child: (isYearly
                                    ? notifiervalue >=
                                        (_yearlyIncomeStatement
                                                    .values!.revenue?.length ??
                                                0) -
                                            2
                                    : notifiervalue >= _financials!.length - 2)
                                ? AppImages.rightSwipeDisabledIcon(context,
                                    isColor: true,
                                    width: AppWidgetSize.dimen_22,
                                    height: AppWidgetSize.dimen_22,
                                    color: Theme.of(context)
                                        .primaryIconTheme
                                        .color)
                                : AppImages.rightSwipeEnabledIcon(context,
                                    isColor: true,
                                    width: AppWidgetSize.dimen_22,
                                    height: AppWidgetSize.dimen_22,
                                    color: Theme.of(context)
                                        .primaryIconTheme
                                        .color),
                          )),
                    ),
                  )
                ]);
          }),
    );
  }

  void updateRevenueExpenses() {
    _expandingRevenue.updateExpandingRevenue(_expandingRevenue.value);
    _expandingExpenses.updateExpandingExpenses(_expandingExpenses.value);
  }

  Widget _buildTimePeriodFilterList(bool isYearly) {
    return SizedBox(
      width:
          (AppWidgetSize.screenWidth(context) / 2) - (AppWidgetSize.dimen_80),
      height: AppWidgetSize.dimen_35,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: _contentController,
        scrollDirection: Axis.horizontal,
        itemCount:
            isYearly ? _yearlyIncomeStatement.yrc!.length : _financials!.length,
        itemBuilder: (BuildContext context, dynamic index) {
          return SizedBox(
            width: ((AppWidgetSize.screenWidth(context) / 2) -
                    (AppWidgetSize.dimen_80)) /
                2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  isYearly
                      ? _yearlyIncomeStatement.yrc![index].toString()
                      : dateFormaterFunction(_financials![index].yrc),
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontSize: AppWidgetSize.fontSize12),
                ),
                CustomTextWidget(
                  "(₹ in Cr)",
                  Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontSize: 10),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  String dateFormaterFunction(date) {
    DateTime inputFormat = DateTime.parse('${date}01');
    DateFormat outputFormat = DateFormat("MMM ''yy");
    return outputFormat.format(inputFormat);
  }

  EdgeInsets buildPaddingEdgeInsets() {
    return EdgeInsets.only(
      top: AppWidgetSize.dimen_6,
      bottom: AppWidgetSize.dimen_6,
      right: AppWidgetSize.dimen_10,
      left: AppWidgetSize.dimen_10,
    );
  }

  EdgeInsets buildMarginEdgeInsets() {
    return EdgeInsets.all(AppWidgetSize.dimen_9);
  }

  String? toogleval;
  int toggleButtonOnChanged(String name) {
    toogleval = name;
    if (name.contains(_appLocalizations.quarterly)) {
      periodPosition = 0;
      viewPosition = 0;
      _filterNotifier.changeFilterPosition(0);
      _financialsViewMoreBloc.add(
          ViewMoreIncomeQuarterlyStatementHoldingEvent(_symbols.sym)
            ..consolidated = widget.arguments['consolidated']);
    } else {
      periodPosition = 1;
      viewPosition = 0;
      _filterNotifier.changeFilterPosition(0);
      _financialsViewMoreBloc.add(
          ViewMoreIncomeYearlyStatementHoldingEvent(_symbols.sym)
            ..consolidated = widget.arguments['consolidated']);
    }

    return 0;
  }
}
