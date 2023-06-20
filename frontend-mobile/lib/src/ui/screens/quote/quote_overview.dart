// ignore_for_file: non_constant_identifier_names

import 'package:acml/src/blocs/holdings/holdings/holdings_bloc.dart';
import 'package:acml/src/blocs/market_status/market_status_bloc.dart';
import 'package:acml/src/blocs/quote/main_quote/quote_bloc.dart';
import 'package:acml/src/blocs/quote/overview/quote_overview_bloc.dart';
import 'package:acml/src/config/app_config.dart';
import 'package:acml/src/constants/app_constants.dart';
import 'package:acml/src/data/store/app_utils.dart';
import 'package:acml/src/localization/app_localization.dart';
import 'package:acml/src/models/common/symbols_model.dart';
import 'package:acml/src/models/quote/quote_fundamentals/quote_financials_ratios.dart';
import 'package:acml/src/models/quote/quote_fundamentals/quote_key_stats.dart';
import 'package:acml/src/ui/navigation/screen_routes.dart';
import 'package:acml/src/ui/screens/base/base_screen.dart';
import 'package:acml/src/ui/screens/quote/quote_peers.dart';
import 'package:acml/src/ui/screens/quote/widgets/fundamentals_bottomsheet.dart';
import 'package:acml/src/ui/screens/quote/widgets/market_depth_com_widget.dart';
import 'package:acml/src/ui/styles/app_images.dart';
import 'package:acml/src/ui/styles/app_widget_size.dart';
import 'package:acml/src/ui/widgets/custom_text_widget.dart';
import 'package:acml/src/ui/widgets/error_image_widget.dart';
import 'package:acml/src/ui/widgets/expansionrow.dart';
import 'package:acml/src/ui/widgets/loader_widget.dart';
import 'package:acml/src/ui/widgets/performance_widget.dart';
import 'package:acml/src/ui/widgets/table_with_bgcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../blocs/marketdepth/marketdepth_bloc.dart';
import '../../../constants/keys/quote_keys.dart';
import '../../../data/store/app_calculator.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/Swapbutton_widget.dart';

class QuoteOverview extends BaseScreen {
  final dynamic arguments;
  final Function() onViewMore;
  final Function(String action, String? customPrice) onCallOrderPad;

  const QuoteOverview({
    Key? key,
    required this.arguments,
    required this.onCallOrderPad,
    required this.onViewMore,
  }) : super(key: key);

  @override
  QuoteOverviewwState createState() => QuoteOverviewwState();
}

class QuoteOverviewwState extends BaseAuthScreenState<QuoteOverview> {
  QuoteOverviewBloc? _quoteOverviewBloc;
  late HoldingsBloc _holdingsBloc;
  MarketStatusBloc? marketStatusBloc;
  late AppLocalizations _appLocalizations;
  late Symbols symbols;
  int holdingsIndex = 0;
  bool isHoldingsAvailable = false;

  @override
  void initState() {
    AppUtils.start = DateTime.now();
    symbols = widget.arguments['symbolItem'];
    symbols.sym!.baseSym = symbols.baseSym;
    _quoteOverviewBloc = BlocProvider.of<QuoteOverviewBloc>(context)
      ..stream.listen(_quoteOverviewListener);

    callStreamEvents();

    _appLocalizations = AppLocalizations();

    marketStatusBloc = MarketStatusBloc()
      ..add(GetMarketStatusEvent(symbols.sym!));

    _holdingsBloc = HoldingsBloc()..stream.listen(_holdingsListener);
    if (AppUtils().getsymbolType(symbols) != AppConstants.indices) {
      sendFetchHoldingsRequest();
    }

    if (AppConfig.overviewTab[AppUtils().getsymbolType(symbols)]
        .contains(_appLocalizations.company)) sendCompanyDetailsRequest();
    if (AppConfig.overviewTab[AppUtils().getsymbolType(symbols)]
        .contains(_appLocalizations.fundamentals)) sendFundamentalsRequest();
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.quoteOverview);
  }

  @override
  void didChangeDependencies() {
    _appLocalizations = AppLocalizations.of(context)!;

    super.didChangeDependencies();
  }

  void callStreamEvents() {
    _quoteOverviewBloc!.add(QuoteOverviewStartSymStreamEvent(
      symbols,
      isHoldingsAvailable,
    ));
  }

  void sendCompanyDetailsRequest() {
    _quoteOverviewBloc!.add(QuoteOverviewGetCompanyDetailsEvent(symbols.sym!));
  }

  void sendFetchHoldingsRequest() {
    _holdingsBloc.add(HoldingsFetchEvent(false, isFetchAgain: false));
  }

  void sendFundamentalsRequest() {
    _quoteOverviewBloc!.add(QuoteGetFundamentalsKeyStatsEvent(symbols.sym!)
      ..consolidated = consolidated.value);
    _quoteOverviewBloc!.add(
        QuoteGetFundamentalsFinancialRatiosEvent(symbols.sym!)
          ..consolidated = consolidated.value);
  }

  Future<void> _quoteOverviewListener(QuoteOverviewState state) async {
    if (state is QuoteOverviewSymStreamState) {
      subscribeLevel1(
        state.streamDetails,
      );
    } else if (state is QuoteSimilarStockDoneState) {
      if (state.quotePeerModel != null) {
        showViewMore.value = true;
      }
    } else if (state is QuoteOverviewErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  Future<void> _holdingsListener(HoldingsState state) async {
    if (state is! HoldingsProgressState) {
      if (mounted) {}
    }
    if (state is HoldingsFailedState) {}
    if (state is HoldingsProgressState) {
      if (mounted) {}
    } else if (state is HoldingsFetchDoneState) {
      if (isHoldingsAvailableInSymbol(symbols, state.holdingsModel?.holdings)) {
        symbols.qty = state.holdingsModel?.holdings?[holdingsIndex].qty;
        symbols.invested =
            state.holdingsModel?.holdings?[holdingsIndex].invested;
        symbols.isPrevClose =
            state.holdingsModel?.holdings?[holdingsIndex].isPrevClose;
        symbols.close = state.holdingsModel?.holdings?[holdingsIndex].close;
        symbols.avgPrice =
            state.holdingsModel?.holdings?[holdingsIndex].avgPrice;
        symbols.totalInvested = state.holdingsModel?.totalInvested;
        symbols.dayspnl = ACMCalci.holdingOnedayPnl(symbols);
        symbols.porfolioPercent =
            _calculateProfolioPercent(symbols, symbols.totalInvested ?? "0");
        symbols.overallReturn = ACMCalci.holdingOverallPnl(symbols);

        isHoldingsAvailable = true;
      } else {
        isHoldingsAvailable = false;
      }
    } else if (state is HoldingsErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  String _calculateProfolioPercent(Symbols holdings, String totalInvested) {
    final double calculatedvalue = AppUtils().doubleValue(holdings.invested) /
        AppUtils().doubleValue(totalInvested) *
        100;

    return AppUtils().commaFmt(
      AppUtils().decimalValue(AppUtils().isValueNAN(calculatedvalue),
          decimalPoint: AppUtils().getDecimalpoint(holdings.sym!.exc!)),
    );
  }

  @override
  void quote1responseCallback(ResponseData data) {
    _quoteOverviewBloc?.isHoldingsAvailable = isHoldingsAvailable;
    _quoteOverviewBloc?.add(QuoteOverviewStreamingResponseEvent(data));
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.quoteOverview;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Scaffold(
          body: ListView(
            children: [
              if (AppConfig.overviewTab[AppUtils().getsymbolType(symbols)]
                  .contains(_appLocalizations.marketDepth))
                Container(
                  padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_30,
                    right: AppWidgetSize.dimen_30,
                  ),
                  child: BlocProvider(
                    create: (context) => MarketdepthBloc(),
                    child: MarketDepth(
                      symbols,
                      screenName: ScreenRoutes.quoteOverview,
                      onCallOrderPad: widget.onCallOrderPad,
                    ),
                  ),
                ),
              _buildMarketStatusBloc(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketStatusBloc(
    BuildContext context,
  ) {
    return BlocBuilder<MarketStatusBloc, MarketStatusState>(
      buildWhen: (MarketStatusState previous, MarketStatusState current) {
        return current is MarketStatusDoneState ||
            current is MarketStatusFailedState ||
            current is MarketStatusServiceExpectionState;
      },
      builder: (context, state) {
        if (state is MarketStatusDoneState) {
          return _buildBody(context, state.isOpen);
        } else {
          return _buildBody(context, false);
        }
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    bool isOpen,
  ) {
    List<Widget> overviewWidgetList = getOverviewWidgetList(
      context,
      isOpen,
    );
    return Container(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
      ),
      color: Theme.of(context).scaffoldBackgroundColor,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                primary: false,
                shrinkWrap: true,
                itemCount: overviewWidgetList.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return overviewWidgetList[index];
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> getOverviewWidgetList(
    BuildContext context,
    bool isOpen,
  ) {
    String symbolType = AppUtils().getsymbolType(symbols);
    List<Widget> overviewWidgetList = [
      if (AppConfig.overviewTab[symbolType]
          .contains(_appLocalizations.performance))
        _buildPerformanceWidget(isOpen || symbolType == AppConstants.indices),
      if (AppConfig.overviewTab[symbolType]
          .contains(_appLocalizations.fundamentals))
        _buildFundamentalsWidget(isOpen),
      if (AppConfig.overviewTab[symbolType].contains(_appLocalizations.about))
        _buildAbout(isOpen, context),
      _buildHoldingsWidget(isOpen),
      if (AppConfig.overviewTab[symbolType].contains(_appLocalizations.company))
        _buildCompanyContentWidget(context, isOpen),
      if (AppConfig.overviewTab[symbolType]
          .contains(_appLocalizations.similarStocks))
        _buildSimilarStockWidget(context, isOpen),
    ];
    return overviewWidgetList;
  }

  ExpansionRow _buildAbout(bool isOpen, BuildContext context) {
    return ExpansionRow(
        initiallExpanded: isOpen,
        footer: const SizedBox.shrink(),
        title: _appLocalizations.about,
        child: buildTableWithBackgroundColor(
            _appLocalizations.expiryDate,
            symbols.sym?.expiry ?? "--",
            AppUtils().getsymbolType(symbols) == AppConstants.fno.toLowerCase()
                ? ""
                : _appLocalizations.ltd,
            symbols.lstTradeDte ?? "--",
            "",
            '',
            context,
            isReduceFontSize: true));
  }

  final ValueNotifier<bool> showViewMore = ValueNotifier<bool>(false);

  //Market depth ends

  //Performance content starts

  Widget _buildPerformanceWidget(bool isOpen) {
    return VisibilityDetector(
        key: const Key(performanceVisibilitykey),
        onVisibilityChanged: (VisibilityInfo info) {
          if (info.visibleFraction > 0.3 &&
              !AppStore.subscribedPages.contains(getScreenRoute())) {
            callStreamEvents();
          }
        },
        child: BlocBuilder<QuoteOverviewBloc, QuoteOverviewState>(
          buildWhen:
              (QuoteOverviewState prevState, QuoteOverviewState currentState) {
            return currentState is QuoteOverviewInitial ||
                currentState is QuoteOverviewDataState ||
                currentState is QuoteOverviewErrorState ||
                currentState is QuoteOverviewServiceExceptionState;
          },
          builder: (BuildContext context, QuoteOverviewState state) {
            if (state is QuoteProgressState) {
              return const LoaderWidget();
            }
            if (state is QuoteOverviewInitial) {
              return ExpansionRow(
                onInfoTap: () {
                  PerformanceWidget.performanceSheet(context);
                },
                title: _appLocalizations.performance,
                footer:
                    (AppUtils().getsymbolType(symbols) == AppConstants.indices)
                        ? Container()
                        : GestureDetector(
                            onTap: () {
                              PerformanceWidget.showPerformanceBottomSheet(
                                  symbols, context);
                            },
                            child: PerformanceWidget.buildViewMore(),
                          ),
                initiallExpanded: isOpen,
                child: PerformanceWidget.buildPerformanceTable(symbols),
              );
            }
            if (state is QuoteOverviewDataState) {
              if (state.symbols != null) {
                return ExpansionRow(
                  onInfoTap: () {
                    PerformanceWidget.performanceSheet(context);
                  },
                  title: _appLocalizations.performance,
                  footer: (AppUtils().getsymbolType(symbols) ==
                          AppConstants.indices)
                      ? Container()
                      : GestureDetector(
                          onTap: () {
                            PerformanceWidget.showPerformanceBottomSheet(
                                symbols, context);
                          },
                          child: PerformanceWidget.buildViewMore(),
                        ),
                  initiallExpanded: isOpen,
                  child: PerformanceWidget.buildPerformanceTable(symbols),
                );
              } else {
                return Container();
              }
            } else if (state is QuoteOverviewServiceExceptionState) {
              return ExpansionRow(
                title: _appLocalizations.performance,
                footer: Container(),
                onInfoTap: () {
                  PerformanceWidget.performanceSheet(context);
                },
                initiallExpanded: isOpen,
                child: errorWithImageWidget(
                  context: context,
                  imageWidget: AppUtils().getNoDateImageErrorWidget(context),
                  errorMessage: state.errorMsg,
                  padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_30,
                    left: AppWidgetSize.dimen_30,
                    right: AppWidgetSize.dimen_30,
                    bottom: AppWidgetSize.dimen_30,
                  ),
                ),
              );
            }
            if (_quoteOverviewBloc != null &&
                _quoteOverviewBloc!.quoteOverviewDataState.symbols != null) {
              if (_quoteOverviewBloc!.quoteOverviewDataState.symbols != null) {
                return ExpansionRow(
                  onInfoTap: () {
                    PerformanceWidget.performanceSheet(context);
                  },
                  title: _appLocalizations.performance,
                  footer: (AppUtils().getsymbolType(symbols) ==
                          AppConstants.indices)
                      ? Container()
                      : GestureDetector(
                          onTap: () {
                            PerformanceWidget.showPerformanceBottomSheet(
                                symbols, context);
                          },
                          child: PerformanceWidget.buildViewMore(),
                        ),
                  initiallExpanded: isOpen,
                  child: PerformanceWidget.buildPerformanceTable(symbols),
                );
              } else {
                return Container();
              }
            }
            return Container();
          },
        ));
  }

  onInfoTap(String title) {
    // myHoldingsShowBottomSheet();
    if (title == _appLocalizations.fundamentals) {
      fundamentalsShowBottomSheet();
    }
    if (title == _appLocalizations.similarStocks) {
      SimilarStockShowBottomSheet();
    }
    if (title == _appLocalizations.myHoldings) {
      myHoldingsShowBottomSheet();
    }
  }

  //Performace content ends

  //Fundamentals content start

  Widget _buildFundamentalsWidget(
    bool isOpen,
  ) {
    return BlocBuilder<QuoteOverviewBloc, QuoteOverviewState>(
      buildWhen: (previous, current) {
        return current is QuoteFundamentalsDoneState ||
            current is QuoteOverviewFailedState;
      },
      builder: (BuildContext context, QuoteOverviewState state) {
        return ExpansionRow(
          onInfoTap: () {
            onInfoTap(_appLocalizations.fundamentals);
          },
          title: _appLocalizations.fundamentals,
          footer: Row(
            mainAxisAlignment: Featureflag.csToggle
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.w),
                child: ValueListenableBuilder<bool>(
                    valueListenable: consolidated,
                    builder: (ctx, snapshot, _) {
                      return SwappingWidget.drop(
                        value: consolidated,
                        onTap: () {
                          consolidated.value = !consolidated.value;
                          sendFundamentalsRequest();
                        },
                      );
                    }),
              ),
              GestureDetector(
                onTap: () {
                  showFundamentalsBottomSheet(
                    state.quoteKeyStats,
                    state.quoteFinancialsRatios,
                  );
                },
                child: _buildViewMore(),
              ),
            ],
          ),
          initiallExpanded: isOpen,
          child: _buildFundamentalsContentWidget(
            state.quoteKeyStats,
            state.quoteFinancialsRatios,
          ),
        );
      },
    );
  }

  ValueNotifier<bool> consolidated = ValueNotifier<bool>(false);

  Widget _buildFundamentalsContentWidget(
    QuoteKeyStats? quoteKeyStats,
    QuoteFinancialsRatios? quoteFinancialsRatios,
  ) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTableWithBackgroundColor(
              _appLocalizations.mktCapcr,
              quoteKeyStats?.stats?.mcap ?? '--',
              _appLocalizations.pE,
              quoteKeyStats?.stats?.pe ?? '--',
              _appLocalizations.priceToBook,
              quoteKeyStats?.stats?.prcBookVal ?? '--',
              context,
              isReduceFontSize: true),
          buildTableWithBackgroundColor(
              _appLocalizations.bookValue,
              quoteKeyStats?.stats?.bookValue ?? '--',
              _appLocalizations.epsTtm,
              quoteKeyStats?.stats?.eps ?? '--',
              _appLocalizations.dividendYield,
              quoteKeyStats?.stats?.divYield ?? '--',
              context,
              isReduceFontSize: true),
          buildTableWithBackgroundColor(
              _appLocalizations.roe,
              quoteFinancialsRatios?.roe ?? '--',
              _appLocalizations.debtToEquity,
              quoteFinancialsRatios?.debtEqty ?? '--',
              _appLocalizations.operatingMargin,
              quoteFinancialsRatios?.operatingMargin ?? '--',
              context,
              isReduceFontSize: true),
        ],
      ),
    );
  }

  Future<void> showFundamentalsBottomSheet(
    QuoteKeyStats? quoteKeyStats,
    QuoteFinancialsRatios? quoteFinancialsRatios,
  ) async {
    showInfoBottomsheet(
        BlocProvider<QuoteOverviewBloc>.value(
          value: _quoteOverviewBloc!,
          child: FundamentalsBottomSheet(
            arguments: {
              'quoteKeyStats': quoteKeyStats,
              'quoteFinancialsRatios': quoteFinancialsRatios,
            },
          ),
        ),
        topMargin: false,
        bottomMargin: AppWidgetSize.dimen_10,
        horizontalMargin: false);
  }

  Widget _buildHoldingsWidget(bool isOpen) {
    return BlocBuilder<HoldingsBloc, HoldingsState>(
        builder: (BuildContext ctx, HoldingsState state) {
      if (_holdingsBloc.holdingsFetchDoneState.holdingsModel?.holdings !=
              null &&
          (_holdingsBloc
                  .holdingsFetchDoneState.holdingsModel!.holdings?.isNotEmpty ??
              false) &&
          isHoldingsAvailableInSymbol(symbols,
              _holdingsBloc.holdingsFetchDoneState.holdingsModel!.holdings)) {
        return ExpansionRow(
          onInfoTap: () {
            onInfoTap(_appLocalizations.myHoldings);
          },
          title: _appLocalizations.myHoldings,
          footer: GestureDetector(
            onTap: () {
              /* sendEventToFirebaseAnalytics(
                    AppEvents.viewMore,
                    ScreenRoutes.quoteOverview,
                    'Clicked view more under holding section in quote screen',
                    key: "symbol",
                    value: symbols.dispSym); */
              AppStore().setHolding(symbols);
              AppConstants.loadHoldingsFromQuote = true;
              pushAndRemoveUntilNavigation(
                ScreenRoutes.homeScreen,
                arguments: {
                  'pageName': ScreenRoutes.tradesScreen,
                  'selectedIndex': 2,
                },
              );
            },
            child: _buildViewMore(),
          ),
          initiallExpanded: isOpen,
          child: _buildMyHoldingsTable(_holdingsBloc.holdingsFetchDoneState),
        );
      } else {
        return Container();
      }
    });
  }

  Widget _buildMyHoldingsTable(HoldingsFetchDoneState state) {
    return _buildHoldingsRow(state);
  }

  Widget _buildHoldingsFirstRow(HoldingsFetchDoneState state) {
    return FittedBox(
      child: buildTableWithBackgroundColor(
        _appLocalizations.mktValue,
        AppUtils().dataNullCheckDashDash(AppUtils().commaFmt(
          AppUtils().decimalValue(
              AppUtils().isValueNAN((AppUtils().doubleValue(symbols.ltp) *
                  AppUtils().doubleValue(
                      state.holdingsModel!.holdings![holdingsIndex].qty))),
              decimalPoint: AppUtils().getDecimalpoint(
                  state.holdingsModel!.holdings![holdingsIndex].sym!.exc!)),
        )),
        _appLocalizations.qty,
        AppUtils().dataNullCheckDashDash(
          state.holdingsModel!.holdings![holdingsIndex].qty,
        ),
        _appLocalizations.avgCost,
        AppUtils().dataNullCheckDashDash(
          state.holdingsModel!.holdings![holdingsIndex].avgPrice,
        ),
        context,
      ),
    );
  }

  Symbols? quoteoverVieSym;
  Widget _buildHoldingsRow(HoldingsFetchDoneState holdingstate) {
    return BlocBuilder<QuoteOverviewBloc, QuoteOverviewState>(
      buildWhen:
          (QuoteOverviewState prevState, QuoteOverviewState currentState) {
        return currentState is QuoteOverviewDataState;
      },
      builder: (BuildContext ctx, QuoteOverviewState state) {
        if (state is QuoteOverviewDataState) {
          quoteoverVieSym = state.symbols;
        }
        if (state is QuoteOverviewDataState || quoteoverVieSym != null) {
          return FittedBox(
            child: Column(
              children: [
                _buildHoldingsFirstRow(holdingstate),
                buildTableWithBackgroundColor(
                  _appLocalizations.overallReturn,
                  AppUtils().dataNullCheckDashDash(
                    quoteoverVieSym!.overallReturn,
                  ),
                  _appLocalizations.todaysReturn,
                  AppUtils().dataNullCheckDashDash(
                    quoteoverVieSym!.dayspnl,
                  ),
                  _appLocalizations.porfolioPercent,
                  AppUtils().dataNullCheckDashDash(
                    quoteoverVieSym!.porfolioPercent,
                  ),
                  context,
                ),
              ],
            ),
          );
        }
        if (_quoteOverviewBloc != null &&
            _quoteOverviewBloc!.quoteOverviewDataState.symbols != null) {
          quoteoverVieSym = _quoteOverviewBloc!.quoteOverviewDataState.symbols;

          return FittedBox(
            child: Column(
              children: [
                _buildHoldingsFirstRow(holdingstate),
                buildTableWithBackgroundColor(
                  _appLocalizations.overallReturn,
                  AppUtils().dataNullCheckDashDash(
                    quoteoverVieSym!.overallReturn,
                  ),
                  _appLocalizations.todaysReturn,
                  AppUtils().dataNullCheckDashDash(
                    quoteoverVieSym!.dayspnl,
                  ),
                  _appLocalizations.porfolioPercent,
                  AppUtils().dataNullCheckDashDash(
                    quoteoverVieSym!.porfolioPercent,
                  ),
                  context,
                ),
              ],
            ),
          );
        }
        return const LoaderWidget();
      },
    );
  }

  //My holdings content ends

  //company content starts

  Widget _buildCompanyContentWidget(
    BuildContext context,
    bool isOpen,
  ) {
    return BlocBuilder<QuoteOverviewBloc, QuoteOverviewState>(
      buildWhen:
          (QuoteOverviewState prevState, QuoteOverviewState currentState) {
        return currentState is QuoteOverviewGetCompanyDataState ||
            currentState is QuoteOverviewGetCompanyFailedState ||
            currentState is QuoteOverviewGetCompanyServiceExceptionState;
      },
      builder: (BuildContext ctx, QuoteOverviewState state) {
        if (state is QuoteOverviewGetCompanyDataState) {
          if (state.quoteCompanyModel != null) {
            return ExpansionRow(
              title: _appLocalizations.company,
              footer: GestureDetector(
                onTap: () {
                  /*   sendEventToFirebaseAnalytics(
                      AppEvents.viewMore,
                      ScreenRoutes.quoteOverview,
                      'Clicked view more under company section in quote screen',
                      key: "symbol",
                      value: symbols.dispSym); */
                  showCompanyBottomSheet(
                    state.quoteCompanyModel!.compName!,
                    state.quoteCompanyModel!.desc!,
                  );
                },
                child: _buildViewMore(),
              ),
              initiallExpanded: isOpen,
              child: _buildDescriptionWidget(state.quoteCompanyModel!.desc!),
            );
          }
        } else if (state is QuoteOverviewGetCompanyFailedState ||
            state is QuoteOverviewGetCompanyServiceExceptionState) {
          return ExpansionRow(
            title: _appLocalizations.company,
            footer: Container(),
            initiallExpanded: isOpen,
            child: errorWithImageWidget(
              context: context,
              imageWidget: AppUtils().getNoDateImageErrorWidget(context),
              errorMessage: AppLocalizations().noDataAvailableErrorMessage,
              padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_30,
                right: AppWidgetSize.dimen_30,
                bottom: AppWidgetSize.dimen_30,
              ),
            ),
          );
        }
        if (_quoteOverviewBloc != null &&
            _quoteOverviewBloc!
                    .quoteOverviewGetCompanyDataState.quoteCompanyModel !=
                null) {
          return ExpansionRow(
            title: _appLocalizations.company,
            footer: GestureDetector(
              onTap: () {
                showCompanyBottomSheet(
                  _quoteOverviewBloc!.quoteOverviewGetCompanyDataState
                      .quoteCompanyModel!.compName!,
                  _quoteOverviewBloc!.quoteOverviewGetCompanyDataState
                      .quoteCompanyModel!.desc!,
                );
              },
              child: _buildViewMore(),
            ),
            initiallExpanded: isOpen,
            child: _buildDescriptionWidget(_quoteOverviewBloc!
                .quoteOverviewGetCompanyDataState.quoteCompanyModel!.desc!),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildDescriptionWidget(
    String description,
  ) {
    return Text(
      description,
      style: Theme.of(context).primaryTextTheme.labelSmall,
      overflow: TextOverflow.ellipsis,
      maxLines: 4,
      textAlign: TextAlign.justify,
    );
  }

  Future<void> showCompanyBottomSheet(
    String compName,
    String description,
  ) async {
    showInfoBottomsheet(
        SafeArea(
            child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(AppWidgetSize.dimen_20),
          ),
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: AppWidgetSize.dimen_70,
              backgroundColor:
                  Theme.of(context).bottomSheetTheme.backgroundColor,
              title: Padding(
                padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_20,
                  bottom: AppWidgetSize.dimen_20,
                  left: AppWidgetSize.dimen_20,
                  right: AppWidgetSize.dimen_20,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(
                        width: AppWidgetSize.fullWidth(context) * 0.6,
                        child: Text(
                          compName,
                          softWrap: false,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).primaryTextTheme.headlineSmall,
                        ),
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
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Wrap(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_30,
                      right: AppWidgetSize.dimen_30,
                      bottom: AppWidgetSize.dimen_30,
                    ),
                    child: Text(
                      description,
                      style: Theme.of(context).primaryTextTheme.labelSmall,
                      textAlign: TextAlign.justify,
                    ),
                  )
                ],
              ),
            ),
          ),
        )),
        topMargin: false,
        horizontalMargin: false);
  }

  //company content ends

  //similar stocks starts

  Widget _buildSimilarStockWidget(
    BuildContext context,
    bool isOpen,
  ) {
    return ExpansionRow(
      onInfoTap: () {
        onInfoTap(_appLocalizations.similarStocks);
      },
      title: _appLocalizations.similarStocks,
      footer: GestureDetector(
        onTap: () {
          /*  sendEventToFirebaseAnalytics(
              AppEvents.viewMore,
              ScreenRoutes.quoteOverview,
              'Clicked view more under similar stocks section in quote screen',
              key: "symbol",
              value: symbols.dispSym); */
          unsubscribeLevel1();
          widget.onViewMore();
        },
        child: ValueListenableBuilder<bool>(
          valueListenable: showSimilarStockNoDataAvailable,
          builder: (context, value, _) {
            return !showSimilarStockNoDataAvailable.value
                ? _buildViewMore()
                : Container();
          },
        ),
      ),
      initiallExpanded: isOpen,
      child: _buildSSContentWidget(context),
    );
  }

  ValueNotifier<bool> showSimilarStockNoDataAvailable =
      ValueNotifier<bool>(false);

  Widget _buildSSContentWidget(BuildContext context) {
    return QuotePeers(
      arguments: {
        'symbolItem': symbols,
        'context': context,
        'isFromOverview': true,
      },
      nodataavailable: (data) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSimilarStockNoDataAvailable.value = data ?? false;
        });
      },
    );
  }

  Widget _buildExpansionRowForBottomSheet(
    BuildContext context,
    String title,
    String description,
  ) {
    final GlobalKey expansionTileKey = GlobalKey();

    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_5,
      ),
      child: Theme(
        data: ThemeData().copyWith(
            dividerColor: Colors.transparent,
            primaryColor: Theme.of(context).primaryColor),
        child: ExpansionTile(
          initiallyExpanded:
              title == _appLocalizations.fundamentals ? true : false,
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: AppWidgetSize.dimen_5,
          ),
          key: expansionTileKey,
          onExpansionChanged: (a) {
            if (a) {
              scrollToSelectedContent(expansionTileKey: expansionTileKey);
            }
          },
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
            title,
            Theme.of(context).textTheme.displaySmall,
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              description,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionRowForBottomSheetRich(
    BuildContext context,
    String title,
    String description,
  ) {
    final GlobalKey expansionTileKey = GlobalKey();

    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_5,
      ),
      child: Theme(
        data: ThemeData().copyWith(
            dividerColor: Colors.transparent,
            primaryColor: Theme.of(context).primaryColor),
        child: ExpansionTile(
          initiallyExpanded:
              title == _appLocalizations.fundamentals ? true : false,
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: AppWidgetSize.dimen_5,
          ),
          key: expansionTileKey,
          onExpansionChanged: (a) {
            if (a) {
              scrollToSelectedContent(expansionTileKey: expansionTileKey);
            }
          },
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
            title,
            Theme.of(context).textTheme.displaySmall,
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            // CustomTextWidget(
            //   description,
            //   Theme.of(context).primaryTextTheme.overline,
            // ),
            RichText(
              text: TextSpan(
                text: _appLocalizations.overviewInfo1,
                style: Theme.of(context).primaryTextTheme.labelSmall,
                children: <TextSpan>[
                  TextSpan(
                    text: AppConstants.rupeeSymbol,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .labelSmall!
                        .copyWith(fontFamily: AppConstants.interFont),
                  ),
                  TextSpan(
                      text: _appLocalizations.overviewInfo2,
                      style: Theme.of(context).primaryTextTheme.labelSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  fundamentalsShowBottomSheet() {
    if (!mounted) {
      return;
    }
    showInfoBottomsheet(
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _appLocalizations.fundamentals,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: AppImages.closeIcon(
                  context,
                  width: AppWidgetSize.dimen_20,
                  height: AppWidgetSize.dimen_20,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true,
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_8,
            ),
            child: Text(_appLocalizations.overviewInfo3,
                textAlign: TextAlign.justify,
                style: Theme.of(context).primaryTextTheme.labelSmall),
          ),
          Divider(
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildExpansionRowForBottomSheet(context, "Fundamentals",
                  //     "The financial ratios and statistics which are relevant in understanding the company’s financial health. This information is updated quarterly or annually"),

                  _buildExpansionRowForBottomSheet(
                    context,
                    "Mkt Cap",
                    "Total market value of a company’s outstanding shares.",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  _buildExpansionRowForBottomSheet(
                    context,
                    "PE",
                    "The price-earnings ratio is the ratio of a company’s current share price to its earnings per share (EPS). It is used to measure the value of a company – whether it is overpriced or underpriced.",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  _buildExpansionRowForBottomSheet(
                    context,
                    "Price to Book",
                    "The ratio of the company’s share price to its book value.",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  _buildExpansionRowForBottomSheet(
                    context,
                    "Book Value",
                    "The net worth of a company if it were to be liquidated today. It's the total of its assets minus its liabilities.",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  _buildExpansionRowForBottomSheet(
                    context,
                    "EPS (TTM)",
                    "Earnings Per Share of the company for the last 12 months.",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  _buildExpansionRowForBottomSheet(
                    context,
                    "Dividend Yield",
                    "Dividend yield is a stock's annual dividend payments to shareholders expressed as a percentage of the stock's current price.",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  _buildExpansionRowForBottomSheet(
                    context,
                    "ROE",
                    "Return on equity is a financial ratio that tells how much profit a company earns in comparison to the net assets it holds. It is calculated by dividing the net income of the company by the shareholder’s equity.",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  _buildExpansionRowForBottomSheet(
                    context,
                    "Debt to Equity",
                    "A ratio of the total liabilities of the company to the shareholder’s equity and is used to evaluate a company's financial leverage.",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  _buildExpansionRowForBottomSheetRich(
                      context,
                      "Operating Margin",
                      'Operating income as a ratio of the sales revenue. This shows the amount of revenue created per  ${AppConstants.rupeeSymbol} of sales.'),

                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  _buildExpansionRowForBottomSheet(
                    context,
                    "Net Sales Growth",
                    "The percent increase in net sales from the previous period. ",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),

                  _buildExpansionRowForBottomSheet(
                    context,
                    "ROA",
                    "Return on assets is a ratio of the company’s net income to the assets. It is a measure of how efficiently a company uses its assets to generate a profit. ",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),

                  _buildExpansionRowForBottomSheet(
                    context,
                    "Interest Cover",
                    "It is the ratio of the company’s earnings before interest and taxes (EBIT) to the interest expense. It is a measure of how easily a company can pay off its debt. ",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),

                  _buildExpansionRowForBottomSheet(
                    context,
                    "EV to EBIT",
                    "The ratio between enterprise value (EV) and earnings before interest and taxes (EBIT).",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  _buildExpansionRowForBottomSheet(
                    context,
                    "EV to EBITDA",
                    "It is the ratio of the enterprise value of a company to its earnings before interest, taxes, depreciation, and amortization (EBITDA).",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  _buildExpansionRowForBottomSheet(
                    context,
                    "EV to Sales",
                    "It is the ratio of the enterprise value of a company to its net sales.",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  _buildExpansionRowForBottomSheet(
                    context,
                    "PEG Ratio",
                    "Price/Earnings-to-Growth ratio is a company's stock price to earnings ratio divided by the future growth rate of its earnings..",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  _buildExpansionRowForBottomSheet(
                    context,
                    "Fixed Turnover",
                    "The ratio of net sales divided by average fixed assets. ",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  _buildExpansionRowForBottomSheet(
                    context,
                    "Net Profit Margin",
                    "The ratio of the net profit of a company to the total amount of revenue it generates. It helps investors evaluate the relative amount of profit the company produces from its revenue. ",
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),

                  Padding(
                    padding: EdgeInsets.only(
                        top: AppWidgetSize.dimen_10,
                        bottom: AppWidgetSize.dimen_5),
                    child: CustomTextWidget(
                      AppLocalizations().disclaimer,
                      Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: AppWidgetSize.fontSize12),
                    ),
                  ),
                  CustomTextWidget(
                      AppLocalizations().disclaimerContent,
                      Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: AppWidgetSize.fontSize11)),

                  Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_7),
                    child: CustomTextWidget(
                        AppLocalizations().cmotsData,
                        Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: AppWidgetSize.fontSize11)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SimilarStockShowBottomSheet() {
    if (!mounted) {
      return;
    }
    showInfoBottomsheet(
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Similar stocks",
                style: Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: AppImages.closeIcon(
                  context,
                  width: AppWidgetSize.dimen_20,
                  height: AppWidgetSize.dimen_20,
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
            thickness: AppWidgetSize.dimen_1,
          ),
          SizedBox(
            height: AppWidgetSize.dimen_10,
          ),
          Text(
            "To help you make smart investment decisions, we’ve curated a list of stocks similar to the one you are viewing on this stock quote page. You will be able to identify companies from similar sectors or industries under this section.",
            style: Theme.of(context).primaryTextTheme.labelSmall,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            "For easy analysis, you can compare the LTP, market cap and the PE ratio of these companies by tapping on the “<” and “>” arrows provided.  You can also sort the list alphabetically, by market cap and change in stock price.",
            style: Theme.of(context).primaryTextTheme.labelSmall,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            "Please note, these stocks are not recommendations by Arihant but just a tool for analysis. You must do your own research before investing.",
            style: Theme.of(context).primaryTextTheme.labelSmall,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  myHoldingsShowBottomSheet() {
    if (!mounted) {
      return;
    }
    showInfoBottomsheet(
      SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Holdings ",
                  style:
                      Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: AppImages.closeIcon(
                    context,
                    width: AppWidgetSize.dimen_20,
                    height: AppWidgetSize.dimen_20,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              "This section represents the stocks/ derivative contracts that are part of your investment and/or trading portfolio with Arihant. Under the section you will find the following details about your each holding in your portfolio:",
              style: Theme.of(context).primaryTextTheme.labelSmall,
              textAlign: TextAlign.justify,
            ),
            Divider(
              thickness: AppWidgetSize.dimen_1,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      myholdingInfoContent(
                          context, "Qty :", "The number of units you hold."),
                      Divider(
                        thickness: AppWidgetSize.dimen_1,
                        color: Theme.of(context).dividerColor,
                      ),
                      myholdingInfoContent(context, "Market Value :",
                          "The current market value of your holdings."),
                      Divider(
                        thickness: AppWidgetSize.dimen_1,
                        color: Theme.of(context).dividerColor,
                      ),
                      myholdingInfoContent(context, 'Average Cost   :',
                          "The total cost of acquisition of the shares divided by the total number of shares.\n💡The average price is necessary to understand your overall loss/ gain as you may have bought the stock in tranches at different prices."),
                      Divider(
                        thickness: AppWidgetSize.dimen_1,
                        color: Theme.of(context).dividerColor,
                      ),
                      myholdingInfoContent(context, "Today’s Return :",
                          "Today’s profit or loss you are making in this security"),
                      Divider(
                        thickness: AppWidgetSize.dimen_1,
                        color: Theme.of(context).dividerColor,
                      ),
                      myholdingInfoContent(context, "Overall Return :",
                          "Overall profit or loss you are making in this security."),
                      Divider(
                        thickness: AppWidgetSize.dimen_1,
                        color: Theme.of(context).dividerColor,
                      ),
                      myholdingInfoContent(context, "Portfolio % :",
                          "This represents the portfolio weightage, i.e. how much percent of your total investment is made into this stock/security.")
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Table myholdingInfoContent(BuildContext context, String title, String desc) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(10)},
      children: [
        TableRow(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, //'Average Cost   :',
                  style:
                      Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                  child: Column(
                    children: [
                      /*  CustomTextWidget(
                        'The total cost of acquisition of the shares divided by the total number of shares.',
                        Theme.of(context).primaryTextTheme.overline,
                      ),
                      CustomTextWidget(
                        'The average price is necessary to understand your overall loss/ gain as you may have bought the stock in tranches at different prices.',
                        Theme.of(context).primaryTextTheme.overline,
                      ), */

                      CustomTextWidget(
                        desc,
                        Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewMore() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
      ),
      child: CustomTextWidget(
        _appLocalizations.viewMore,
        Theme.of(context).primaryTextTheme.titleLarge,
        textAlign: TextAlign.end,
      ),
    );
  }

  bool isHoldingsAvailableInSymbol(
      Symbols symbolItem, List<Symbols>? holdingsList) {
    bool isHoldingsAvailableInSymbol = false;
    int index = 0;
    if (holdingsList != null) {
      for (Symbols element in holdingsList) {
        if (element.dispSym == symbolItem.dispSym &&
            element.sym?.exc == symbolItem.sym!.exc) {
          holdingsIndex = index;
          isHoldingsAvailableInSymbol = true;
        }
        index++;
      }
    }
    return isHoldingsAvailableInSymbol;
  }
}
