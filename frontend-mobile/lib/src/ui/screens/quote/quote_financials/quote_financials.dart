import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../blocs/quote/financials/financials_bloc.dart';
import '../../../../constants/keys/search_keys.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../../models/quote/quote_financials/financials_data.dart';
import '../../../../models/quote/quote_financials/financials_model.dart';
import '../../../../models/quote/quote_financials/financials_yearly_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_color.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/Swapbutton_widget.dart';
import '../../../widgets/circular_toggle_button_widget.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/error_image_widget.dart';
import '../../../widgets/loader_widget.dart';
import '../../../widgets/technicalspivotstrategychart/toggle_circular_tabborder_widget.dart';
import '../../base/base_screen.dart';

class QuoteFinancials extends BaseScreen {
  final dynamic arguments;
  const QuoteFinancials({Key? key, this.arguments}) : super(key: key);

  @override
  State<QuoteFinancials> createState() => _QuoteFinancialsState();
}

class _QuoteFinancialsState extends BaseAuthScreenState<QuoteFinancials>
    with TickerProviderStateMixin {
  late AppLocalizations _appLocalizations;
  late QuoteFinancialsBloc _financialsBloc;
  late Symbols _symbols = Symbols();
  late FinancialsModel _financialsModel;
  late FinancialsYearly _financialsYearly;
  late List<String>? _financialTimePeriod;

  bool toggleFinancialRevenue = true;
  bool toggleFinancialProfit = false;
  late int periodPosition = 0;
  late double positiviePeak;
  late double negativePeak;
  int selectedToggleIndex = 0;
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  bool onfirstScroll = true;

  @override
  void initState() {
    super.initState();
    _symbols = widget.arguments['symbolItem'];
    _symbols.sym!.baseSym = _symbols.baseSym;
    _financialsBloc = BlocProvider.of<QuoteFinancialsBloc>(context)
      ..add((QuoteToggleRevenueEvent()))
      ..stream.listen(_quoteFinancialsListener);
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.quoteFinancials);
    tabController = TabController(
        length: 2, initialIndex: selectedIndex.value, vsync: this);
    tabController?.addListener(() {
      selectedIndex.value = tabController?.index ?? 0;
      onfirstScroll = true;
    });
  }

  Future<void> _quoteFinancialsListener(QuoteFinancialsState state) async {
    if (state is FinancialsProgressState) {}
    if (state is FinancialsRevenueDoneState) {
    } else if (state is FinancialsProfitDoneState) {
    } else if (state is FinancialsYearlyRevenueDoneState) {
    } else if (state is FinancialsYearlyProfitDoneState) {
    } else if (state is FinancialsFailedState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state is FinancialsErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuoteFinancialsToggleWidget(),
            ],
          ),
          typeChangeWidget(),
          _buildFinancialsBlocBuilder(),
        ],
      ),
    );
  }

  Widget _buildQuoteFinancialsToggleWidget() {
    return Padding(
        padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_15,
        ),
        child: toggleCircularWidget());
  }

  int intialIndex = 0;
  TabController? tabController;
  toggleCircularWidget() {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: AppWidgetSize.dimen_1,
          ),
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
        ),
        child: Padding(
            padding: EdgeInsets.all(AppWidgetSize.dimen_2),
            child: ToggleCircularTabMWidget(
              tabController: tabController!,
              key: const Key(''),
              height: AppWidgetSize.dimen_36,
              minWidth: AppWidgetSize.dimen_150,
              cornerRadius: AppWidgetSize.dimen_20,
              labels: <String>[
                _appLocalizations.revenue,
                _appLocalizations.profit,
              ],
              initialLabel: intialIndex,
              onToggle: (int selectedTabValue) {
                intialIndex = selectedTabValue;
                togglePosition = selectedTabValue;
                if (selectedTabValue == 0) {
                  toggleFinancialRevenue = true;
                  toggleFinancialProfit = false;
                  periodPosition = 0;
                  _financialsBloc.add((QuoteToggleRevenueEvent()
                    ..consolidated = selectedToggleIndex == 0));
                } else if (selectedTabValue == 1) {
                  toggleFinancialRevenue = false;
                  toggleFinancialProfit = true;
                  periodPosition = 0;
                  _financialsBloc.add((QuoteToggleProfitEvent()
                    ..consolidated = selectedToggleIndex == 0));
                }

                tabController?.animateTo(selectedTabValue);
              },
            )));
  }

  BlocBuilder<QuoteFinancialsBloc, QuoteFinancialsState>
      _buildFinancialsBlocBuilder() {
    return BlocBuilder<QuoteFinancialsBloc, QuoteFinancialsState>(
      builder: (context, state) {
        if (state is FinancialsProgressState) {
          return const LoaderWidget();
        }
        if (state is FinancialsRevenueToggleState) {
          _financialsBloc.add(QuoteFinancialsRevenueEvent(
            FinancialsData(sym: _symbols.sym),
            true,
          )..consolidated = selectedToggleIndex == 0);
        } else if (state is FinancialsProfitToggleState) {
          _financialsBloc.add(QuoteFinancialsProfitEvent(
              FinancialsData(sym: _symbols.sym), true)
            ..consolidated = selectedToggleIndex == 0);
        } else if (state is FinancialsRevenueDoneState) {
          positiviePeak = state.positivePeak;
          negativePeak = state.negativePeak;
          _financialsModel = state.financialsModel;
          return _createChartView(_financialsModel, 'revenueQuarterly');
        } else if (state is FinancialsProfitDoneState) {
          positiviePeak = state.positivePeak;
          negativePeak = state.negativePeak;
          _financialsModel = state.financialsModel;
          return _createChartView(_financialsModel, 'profitQuarterly');
        } else if (state is FinancialsYearlyRevenueDoneState) {
          positiviePeak = state.positivePeak;
          negativePeak = state.negativePeak;
          _financialsYearly = state.financialsYearly;
          // if(periodPosition == 1 && toggleFinancialRevenue)
          {
            return _createChartView(_financialsYearly, 'revenueYearly');
          }
        } else if (state is FinancialsYearlyProfitDoneState) {
          positiviePeak = state.positivePeak;
          negativePeak = state.negativePeak;
          _financialsYearly = state.financialsYearly;
          // if(periodPosition == 1 && toggleFinancialProfit)
          {
            return _createChartView(_financialsYearly, 'profitYearly');
          }
        } else if (state is FinancialsFailedState) {
          return _createChartView(null, '');
        } else if (state is FinancialsErrorState) {
          return _createChartView(null, '');
        } else if (state is FinancialsServiceExceptionState) {
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
        return Container();
      },
    );
  }

  Widget _createChartView(dynamic data, String chartType) {
    return Column(
      children: [
        if (data != null)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 10),
                child: Opacity(
                  opacity: 0.5,
                  child: CustomTextWidget(
                    _appLocalizations.valuesInCr,
                    Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: AppWidgetSize.fontSize14,
                        ),
                  ),
                ),
              ),
              _createRevenueVolumeChartWidget(data, chartType),
            ],
          )
        else if (data == null)
          errorWithImageWidget(
            context: context,
            height: AppWidgetSize.dimen_250,
            imageWidget: AppUtils().getNoDateImageErrorWidget(context),
            errorMessage: AppLocalizations().noDataAvailableErrorMessage,
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
              bottom: AppWidgetSize.dimen_30,
            ),
          ),
        SizedBox(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFinancialTime(context, periodPosition),
                  GestureDetector(
                      onTap: () => pushNavigation(
                              ScreenRoutes.quoteFinancialsViewMore,
                              arguments: {
                                'symbolItem': _symbols,
                              }),
                      child: _buildRoundedTextButton(
                          context,
                          _appLocalizations.viewMore,
                          buildMarginEdgeInsets(),
                          buildPaddingEdgeInsets()))
                ],
              ),
            ],
          ),
        ),
        Container(
            padding: EdgeInsets.only(bottom: 10.w),
            child: financialsDisclaimer())
      ],
    );
  }

  ValueNotifier<bool> consolidated = ValueNotifier<bool>(true);

  Padding typeChangeWidget() {
    return Padding(
      padding:
          EdgeInsets.only(left: 20.w, bottom: 10.w, top: 20.w, right: 20.w),
      child: ValueListenableBuilder<bool>(
          valueListenable: consolidated,
          builder: (context, value, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SwappingWidget.drop(
                  value: consolidated,
                  onTap: () {
                    swapChange();
                  },
                ),
              ],
            );
          }),
    );
  }

  void swapChange() {
    consolidated.value = !consolidated.value;
    selectedToggleIndex = consolidated.value ? 0 : 1;
    toggleButtonOnChanged(_financialTimePeriod![periodPosition]);
  }

  Column financialsDisclaimer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_20),
          child: CustomTextWidget(
            AppLocalizations().disclaimer,
            Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: AppWidgetSize.fontSize12),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_5,
              left: AppWidgetSize.dimen_20,
              right: AppWidgetSize.dimen_20),
          child: CustomTextWidget(
              AppLocalizations().disclaimerContent,
              Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: AppWidgetSize.fontSize11)),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_7,
              left: AppWidgetSize.dimen_20,
              right: AppWidgetSize.dimen_20),
          child: CustomTextWidget(
              AppLocalizations().cmotsData,
              Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: AppWidgetSize.fontSize11)),
        )
      ],
    );
  }

  Widget _createRevenueVolumeChartWidget(dynamic data, String chartType) {
    int revenueYearly = 0;
    int profitYearly = 0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (chartType == 'revenueQuarterly')
            ...data.financials!.map((data1) {
              bool isNegative = data.financials!
                  .where((e) => AppUtils()
                      .doubleValue((e.ttlIncome?.toString() ?? "0"))
                      .isNegative)
                  .toList()
                  .isNotEmpty;

              return Flexible(
                fit: FlexFit.loose,
                child: _volumeChartBarWidget(
                    data1.ttlIncome, data1.yrc, isNegative),
              ); //Text(data['day']);
            }).toList(),
          if (chartType == 'profitQuarterly')
            ...data.financials!.map((data1) {
              bool isNegative = data.financials!
                  .where((e) => AppUtils()
                      .doubleValue((e.netproftLoss?.toString() ?? "0"))
                      .isNegative)
                  .toList()
                  .isNotEmpty;

              return Flexible(
                fit: FlexFit.loose,
                child: _volumeChartBarWidget(
                    data1.netproftLoss, data1.yrc.toString(), isNegative),
              ); //Text(data['day']);
            }).toList(),
          if (chartType == 'revenueYearly')
            ...data.values!.revenue!.map((data1) {
              bool isNegative = data.values!.revenue!
                  .where((e) =>
                      AppUtils().doubleValue((e?.toString() ?? "0")).isNegative)
                  .toList()
                  .isNotEmpty;
              revenueYearly = revenueYearly + 1;
              return Flexible(
                fit: FlexFit.loose,
                child: _volumeChartBarWidget(data1,
                    _financialsYearly.yrc![revenueYearly - 1], isNegative),
              );
            }).toList(),
          if (chartType == 'profitYearly')
            ...data.values!.netPrft!.map((data1) {
              profitYearly = profitYearly + 1;
              bool isNegative = data.values!.netPrft!
                  .where((e) =>
                      AppUtils().doubleValue((e?.toString() ?? "0")).isNegative)
                  .toList()
                  .isNotEmpty;

              return Flexible(
                fit: FlexFit.loose,
                child: _volumeChartBarWidget(data1,
                    _financialsYearly.yrc![profitYearly - 1], isNegative),
              );
            }).toList()
        ],
      ),
    );
  }

  Widget _volumeChartBarWidget(
      String? data, String? year, bool isContainNegative) {
    return SizedBox(
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _volumeFractionalBoxWidget(data, isContainNegative),
              _yAxisVolumeIntervalCustomTextWidget(dateFormaterFunction(year))
            ],
          ),
        ],
      ),
    );
  }

  Widget _volumeFractionalBoxWidget(String? data, bool isContainNegative) {
    return SizedBox(
      child: Column(
        mainAxisAlignment:
            AppUtils().doubleValue((data?.toString() ?? "0")).isNegative
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
        children: [
          if (!AppUtils().doubleValue((data?.toString() ?? "0")).isNegative)
            Column(
              children: [
                SizedBox(
                  height: (_chartHeightCal(
                              positiviePeak.toString(), positiviePeak) ??
                          0) +
                      30.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 8.0.w, bottom: 8.0.w),
                          child: CustomTextWidget(
                            data.toString(),
                            Theme.of(context)
                                .primaryTextTheme
                                .titleSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10.w,
                                ),
                          )),
                      SizedBox(
                        height: _chartHeightCal(data, positiviePeak),
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                              color: 50 > 0
                                  ? AppColors().positiveColor
                                  : AppColors.negativeColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0.w),
                                  topRight: Radius.circular(10.0.w),
                                  bottomLeft: Radius.circular(10.0.w),
                                  bottomRight: Radius.circular(10.0.w))),
                          width: 10.w,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isContainNegative)
                  Divider(
                    thickness: 2.w,
                  ),
                if (isContainNegative)
                  SizedBox(
                    height: (_chartHeightCal(
                                negativePeak.toString(), negativePeak) ??
                            0) +
                        30.w,
                  ),
              ],
            ),
          if (AppUtils().doubleValue((data?.toString() ?? "0")).isNegative)
            Column(
              children: [
                SizedBox(
                  height: (_chartHeightCal(
                              positiviePeak.toString(), positiviePeak) ??
                          0) +
                      30.w,
                ),
                Divider(
                  thickness: 2.w,
                ),
                SizedBox(
                  height:
                      (_chartHeightCal(negativePeak.toString(), negativePeak) ??
                              0) +
                          30.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: _chartHeightCal(
                            AppUtils().doubleValue(data).abs().toString(),
                            negativePeak),
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          decoration: const BoxDecoration(
                              color: 50 > 0
                                  ? AppColors.negativeColor
                                  : AppColors.negativeColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0))),
                          width: 10,
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: CustomTextWidget(
                            data.toString(),
                            Theme.of(context)
                                .primaryTextTheme
                                .titleSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10.w,
                                ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  double? _chartHeightCal(String? data, double? totalRevenue) {
    double s = totalRevenue! / (AppUtils().doubleValue(data));
    totalRevenue = 127 / s;
    return (totalRevenue > 180 ? 180.w : totalRevenue).abs().toDouble().w;
  }

  Widget _yAxisVolumeIntervalCustomTextWidget(String? data) {
    return Container(
        width: AppWidgetSize.dimen_60,
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: CustomTextWidget(
          data.toString(),
          Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 10.w,
              ),
        ));
  }

  Padding _buildFinancialTime(BuildContext context, int selectIndex) {
    _financialTimePeriod = [
      _appLocalizations.quarterly,
      _appLocalizations.yearly
    ];
    return Padding(
      padding:
          const EdgeInsets.only(right: 10.0, left: 10.0, top: 4, bottom: 4),
      child: CircularButtonToggleWidget(
        value: _financialTimePeriod![selectIndex],
        toggleButtonlist:
            _financialTimePeriod!.map((s) => s as dynamic).toList(),
        toggleButtonOnChanged: toggleButtonOnChanged,
        key: const Key(filters_),
        defaultSelected: _appLocalizations.quarterly,
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
        fontSize: 18.w,
      ),
    );
  }

  Container _buildRoundedTextButton(BuildContext context, String itemName,
      EdgeInsets? marginEdgeInsets, EdgeInsets? paddingEdgeInsets) {
    return Container(
      margin: marginEdgeInsets ?? buildMarginEdgeInsets(),
      padding: paddingEdgeInsets ?? buildPaddingEdgeInsets(),
      decoration: BoxDecoration(
          color:
              Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(
            AppWidgetSize.dimen_20,
          ),
          border: Border.all(
            width: AppWidgetSize.dimen_1,
            color: Theme.of(context).primaryColor,
          )),
      child: Text(
        itemName.toString(),
        style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w500, color: Theme.of(context).primaryColor),
        key: Key(
          itemName.toString(),
        ),
      ),
    );
  }

  String? toogleval;
  int toggleButtonOnChanged(
    String name,
  ) {
    toogleval = name;
    if (togglePosition == 0) {
      if (name.contains(_appLocalizations.quarterly)) {
        periodPosition = 0;
        _financialsBloc.add(QuoteFinancialsRevenueEvent(
          FinancialsData(sym: _symbols.sym),
          true,
        )..consolidated = selectedToggleIndex == 0);
      } else {
        periodPosition = 1;

        _financialsBloc.add(QuoteRevenueYearlyEvent(_symbols.sym)
          ..consolidated = selectedToggleIndex == 0);
      }
    } else {
      if (name.contains(_appLocalizations.quarterly)) {
        periodPosition = 0;
        _financialsBloc.add(
            QuoteFinancialsProfitEvent(FinancialsData(sym: _symbols.sym), true)
              ..consolidated = selectedToggleIndex == 0);
      } else {
        periodPosition = 1;
        _financialsBloc.add(QuoteProfitYearlyEvent(_symbols.sym)
          ..consolidated = selectedToggleIndex == 0);
      }
    }

    return 0;
  }

  String dateFormaterFunction(date) {
    if (periodPosition == 0) {
      DateTime inputFormat = DateTime.parse('${date}01');
      DateFormat outputFormat = DateFormat("MMM ''yy");
      return outputFormat.format(inputFormat);
    } else {
      return date;
    }
  }

  int togglePosition = 0;

  EdgeInsets buildPaddingEdgeInsets() {
    return EdgeInsets.all(
      AppWidgetSize.dimen_6,
    );
  }

  EdgeInsets buildMarginEdgeInsets() {
    return EdgeInsets.all(AppWidgetSize.dimen_9);
  }
}
