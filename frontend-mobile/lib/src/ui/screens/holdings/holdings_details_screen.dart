import 'package:acml/src/ui/widgets/expansionrow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/quote2_stream_response_model.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../blocs/holdings/holdings/holdings_bloc.dart';
import '../../../blocs/holdings/holdings_detail/holdings_detail_bloc.dart';
import '../../../blocs/market_status/market_status_bloc.dart';
import '../../../blocs/marketdepth/marketdepth_bloc.dart';
import '../../../blocs/quote/main_quote/quote_bloc.dart';
import '../../../blocs/watchlist/watchlist_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/keys/holdings_keys.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/watchlist/watchlist_group_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/choose_watchlist_widget.dart';
import '../../widgets/create_new_watchlist_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/label_border_text_widget.dart';
import '../../widgets/performance_widget.dart';
import '../../widgets/table_with_bgcolor.dart';
import '../base/base_screen.dart';
import '../quote/widgets/market_depth_com_widget.dart';

class HoldingsDetailsScreen extends BaseScreen {
  final dynamic arguments;
  const HoldingsDetailsScreen({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<HoldingsDetailsScreen> createState() => _HoldingsDetailsScreenState();
}

class _HoldingsDetailsScreenState
    extends BaseAuthScreenState<HoldingsDetailsScreen> {
  late AppLocalizations _appLocalizations;
  late HoldingsDetailBloc holdingsDetailBloc;
  late MarketStatusBloc marketStatusBloc;
  late QuoteBloc quoteBloc;
  late WatchlistBloc watchlistBloc;
  late Symbols symbols;
  late String porfolioWeightge;
  late String totalInvested;

  List<Groups>? groupList = <Groups>[];

  @override
  void initState() {
    symbols = widget.arguments['symbolItem'];
    porfolioWeightge = widget.arguments['portfolioWeightage'];
    totalInvested = widget.arguments?['totalInvested'] ?? "";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      holdingsDetailBloc = BlocProvider.of<HoldingsDetailBloc>(context)
        ..stream.listen(_holdingsListener);
      marketStatusBloc = BlocProvider.of<MarketStatusBloc>(context)
        ..add(GetMarketStatusEvent(symbols.sym!));
      quoteBloc = BlocProvider.of<QuoteBloc>(context)
        ..stream.listen(quoteListener);
      watchlistBloc = BlocProvider.of<WatchlistBloc>(context)
        ..stream.listen(watchlistListener);
      getWatchlistGroup();
      callStreamEvents();
    });
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.holdingsDetailsScreen);
  }

  void getWatchlistGroup() {
    watchlistBloc.add(WatchlistGetGroupsEvent(false));
  }

  Future<void> quoteListener(QuoteState state) async {
    if (state is! QuoteProgressState) {
      if (mounted) {
        stopLoader();
      }
    }
    if (state is QuoteProgressState) {
      if (mounted) {
        startLoader();
      }
    } else if (state is QuotedeleteDoneState) {
      showToast(
        message: state.messageModel,
        context: context,
      );
      setState(() {});
    } else if (state is QuoteAddSymbolFailedState ||
        state is QuotedeleteSymbolFailedState) {
      setState(() {});
      showToast(
        message: state.errorMsg,
        context: context,
        isError: true,
      );
    } else if (state is QuoteAddDoneState) {
      showToast(
        message: state.messageModel,
        context: context,
      );
      getWatchlistGroup();
      setState(() {});
    } else if (state is QuoteErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  Future<void> watchlistListener(WatchlistState state) async {
    if (state is WatchlistDoneState) {
      groupList = [];
      if (state.watchlistGroupModel != null) {
        for (Groups element in state.watchlistGroupModel!.groups!) {
          groupList!.add(element);
        }
      }
    }
  }

  Future<void> _holdingsListener(HoldingsDetailState state) async {
    if (state is HoldingsDetailSymStreamState) {
      subscribeLevel1(state.streamDetails);
    } else if (state is HoldingsDetailQuoteTwoStreamState) {
      subscribeLevel2(state.streamDetails);
    } else if (state is HoldingsErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  void callStreamEvents() {
    holdingsDetailBloc.add(HoldingsDetailStartSymStreamEvent(symbols));
    holdingsDetailBloc.add(HoldingsDetailQuoteTwoStartStreamEvent(symbols));
  }

  @override
  void quote1responseCallback(ResponseData data) {
    holdingsDetailBloc.add(HoldingsDetailStreamingResponseEvent(data));
  }

  @override
  Future<void> quote2responseCallback(Quote2Data streamData) async {
    holdingsDetailBloc.add(HoldingsDetailQuoteTwoResponseEvent(streamData));
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.holdingsDetailsScreen;
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      toolbarHeight: AppWidgetSize.dimen_450,
      elevation: 0,
      shadowColor: Theme.of(context).dividerColor.withOpacity(0.5),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Column(
        children: [
          _buildAppBarContent(),
          _buildFixedTopBarContent(),
        ],
      ),
    );
  }

  Widget _buildAppBarContent() {
    return Container(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_10,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: AppWidgetSize.dimen_2,
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      width: AppWidgetSize.fullWidth(context),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _getAppBarLeftContent(),
            _getAppBarRightContent(),
          ],
        ),
      ),
    );
  }

  Widget _getAppBarLeftContent() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
      ),
      child: Row(
        children: [
          backIconButton(
              onTap: () {
                popNavigation();
              },
              customColor: Theme.of(context).textTheme.displayMedium!.color),
          Padding(
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_5,
            ),
            child: CustomTextWidget(
              symbols.dispSym!,
              Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAppBarRightContent() {
    return Row(
      children: [
        SizedBox(
          width: AppWidgetSize.dimen_80,
          child: LabelBorderWidget(
            keyText: const Key(holdingsDetailsStockQuoteKey),
            text: _appLocalizations.stockQuote,
            textColor: Theme.of(context).primaryColor,
            fontSize: AppWidgetSize.fontSize12,
            margin: EdgeInsets.only(top: AppWidgetSize.dimen_2),
            borderRadius: AppWidgetSize.dimen_20,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            borderWidth: AppWidgetSize.dimen_1,
            borderColor: Theme.of(context).dividerColor,
            isSelectable: true,
            labelTapAction: () {
              pushNavigation(
                ScreenRoutes.quoteScreen,
                arguments: {
                  'symbolItem': symbols,
                },
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_10,
          ),
          child: GestureDetector(
            onTap: () {
              if (groupList!.isEmpty) {
                _showCreateNewBottomSheet(symbols);
              } else {
                _showWatchlistGroupBottomSheet(symbols);
              }
            },
            child: AppImages.addUnfilledIcon(context,
                color: AppColors().positiveColor,
                isColor: true,
                width: 30.w,
                height: 30.w),
          ),
        ),
      ],
    );
  }

  Widget _buildFixedTopBarContent() {
    return Column(
      children: [
        _buildSegmentWidget(symbols),
        Padding(
          padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_25,
            right: AppWidgetSize.dimen_25,
          ),
          child: buildTableWithBackgroundColor(
            _appLocalizations.netQty,
            symbols.qty!,
            _appLocalizations.avgPrice,
            symbols.avgPrice!,
            '',
            '',
            context,
            isRupeeSymbol: true,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_25,
            right: AppWidgetSize.dimen_25,
          ),
          child: buildTableWithBackgroundColor(
            _appLocalizations.pledgedQty,
            symbols.pledgedQty ?? "--",
            _appLocalizations.freeQty,
            symbols.freeQty ?? "--",
            '',
            '',
            context,
            isRupeeSymbol: true,
          ),
        ),
        _buildButtonWidget(),
      ],
    );
  }

  Widget _buildBody() {
    return BlocBuilder<HoldingsDetailBloc, HoldingsDetailState>(
      buildWhen: (previous, current) {
        return current is HoldingsDetailDataState;
      },
      builder: (context, state) {
        if (state is HoldingsDetailDataState) {
          return _buildBodyContentWidget(
            state.symbols!,
          );
        }
        return _buildBodyContentWidget(symbols);
      },
    );
  }

  Widget _buildBodyContentWidget(
    Symbols symbols,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_20,
        right: AppWidgetSize.dimen_20,
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _getWidgetWithBackgroundColor(
              _appLocalizations.currentValue,
              AppUtils().dataNullCheck(symbols.mktValue),
            ),
            _getWidgetWithBackgroundColor(
              _appLocalizations.investedValue,
              AppUtils().dataNullCheck(symbols.invested),
            ),
            _getWidgetWithBackgroundColor(
              _appLocalizations.overallPnL,
              AppUtils().dataNullCheck(symbols.overallPnL) +
                  ("(${AppUtils().dataNullCheck(symbols.overallPnLPercent)}%)"),
            ),
            _getWidgetWithBackgroundColor(
              _appLocalizations.portfolioWeightage,
              AppUtils().dataNullCheck(porfolioWeightge),
            ),
            BlocProvider(
              create: (context) => MarketdepthBloc(),
              child: MarketDepth(symbols,
                  screenName: ScreenRoutes.orderPadScreen,
                  onCallOrderPad: _onCallOrderPad),
            ),
            _buildPerformaceWidget(),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onCallOrderPad(String action, String? customPrice) async {
    await pushNavigation(
      ScreenRoutes.orderPadScreen,
      arguments: {
        'action': action,
        'symbolItem': symbols,
        AppConstants.holdingsNavigation:
            action == _appLocalizations.sell ? symbols.qty : null,
        'customPrice': customPrice ?? ""
      },
    );
  }

  Widget _getWidgetWithBackgroundColor(
    String title,
    String value,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_10,
      ),
      child: Container(
        height: AppWidgetSize.dimen_45,
        color:
            Theme.of(context).inputDecorationTheme.fillColor!.withOpacity(0.5),
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_15,
          right: AppWidgetSize.dimen_15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextWidget(
              title,
              Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            title == _appLocalizations.portfolioWeightage
                ? CustomTextWidget(
                    '$value%',
                    Theme.of(context).primaryTextTheme.labelSmall!,
                    isShowShimmer: true,
                  )
                : _getLableWithRupeeSymbol(
                    value,
                    Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                          fontFamily: AppConstants.interFont,
                        ),
                    Theme.of(context).primaryTextTheme.labelSmall!,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformaceWidget() {
    return BlocBuilder<MarketStatusBloc, MarketStatusState>(
      buildWhen: (MarketStatusState previous, MarketStatusState current) {
        return current is MarketStatusDoneState ||
            current is MarketStatusFailedState ||
            current is MarketStatusServiceExpectionState;
      },
      builder: (context, state) {
        if (state is MarketStatusDoneState) {
          return ExpansionRow(
            onInfoTap: () {
              PerformanceWidget.performanceSheet(context);
            },
            title: _appLocalizations.performance,
            footer: GestureDetector(
              onTap: () {
                PerformanceWidget.showPerformanceBottomSheet(symbols, context);
              },
              child: PerformanceWidget.buildViewMore(),
            ),
            initiallExpanded: state.isOpen,
            child: PerformanceWidget.buildPerformanceTable(symbols),
          );
        } else if (state is MarketStatusFailedState ||
            state is MarketStatusServiceExpectionState) {
          return Container();
        }
        return Container();
      },
    );
  }

  Widget _buildSegmentWidget(
    Symbols holdingItem,
  ) {
    return BlocBuilder<HoldingsDetailBloc, HoldingsDetailState>(
      buildWhen: (previous, current) {
        return current is HoldingsDetailDataState;
      },
      builder: (context, state) {
        if (state is HoldingsDetailDataState) {
          return buildSegmentContainer(
            state.symbols!,
          );
        }
        return buildSegmentContainer(
          holdingItem,
        );
      },
    );
  }

  Widget getLableBorderWidget(
    String key,
    String title,
  ) {
    return SizedBox(
      width: AppWidgetSize.dimen_64,
      child: LabelBorderWidget(
        keyText: Key(key),
        text: title,
        textColor: Theme.of(context).inputDecorationTheme.labelStyle!.color,
        fontSize: AppWidgetSize.fontSize14,
        borderRadius: AppWidgetSize.dimen_20,
        margin: EdgeInsets.only(right: AppWidgetSize.dimen_1),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        borderWidth: 1,
        borderColor: Theme.of(context).dividerColor,
      ),
    );
  }

  Widget buildSegmentContainer(
    Symbols holdingsItem,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_20,
        top: AppWidgetSize.dimen_20,
      ),
      height: AppWidgetSize.dimen_150,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 2,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Center(
              child: _buildListBoxContent(
                _appLocalizations.todaysPnL,
                AppUtils().dataNullCheck(holdingsItem.oneDayPnL),
                '(${AppUtils().dataNullCheck(holdingsItem.oneDayPnLPercent)}%)',
                AppUtils().doubleValue(holdingsItem.oneDayPnL) != 0
                    ? AppUtils()
                            .doubleValue(AppUtils().decimalValue((AppUtils()
                                    .doubleValue(holdingsItem.oneDayPnL) /
                                AppUtils().doubleValue(totalInvested) *
                                100)))
                            .isNegative
                        ? AppColors.negativeColor
                        : AppColors().positiveColor
                    : AppColors.labelColor,
              ),
            );
          } else {
            return _buildListBoxContent(
              _appLocalizations.ltp,
              holdingsItem.ltp!,
              AppUtils().getChangePercentage(holdingsItem),
              AppUtils().setcolorForChange(holdingsItem.chng ?? "0.00"),
            );
          }
        },
      ),
    );
  }

  Widget _buildListBoxContent(
    String title,
    String value,
    String subValue,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
        left: AppWidgetSize.dimen_20,
        right: AppWidgetSize.dimen_20,
      ),
      child: Container(
        height: AppWidgetSize.dimen_100,
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_8,
          right: AppWidgetSize.dimen_8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            AppWidgetSize.dimen_6,
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(context).dividerColor,
              blurRadius: 2.5,
            ),
          ],
        ),
        child: _getListBoxWidget(
          title,
          value,
          subValue,
          color,
        ),
      ),
    );
  }

  Widget _getListBoxWidget(
    String title,
    String value,
    String subValue,
    Color color, {
    bool isBottomSheet = false,
  }) {
    return Container(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_5,
        right: AppWidgetSize.dimen_5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextWidget(
                      AppUtils().dataNullCheckDashDash(title),
                      Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                _getLableWithRupeeSymbol(
                  AppUtils().dataNullCheckDashDash(value),
                  Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: AppConstants.interFont,
                        color: color,
                      ),
                  Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_5,
                  ),
                  child: CustomTextWidget(
                    subValue,
                    Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              informationIconBottomSheet(title);
            },
            child: Padding(
              padding: EdgeInsets.only(
                top: isBottomSheet
                    ? AppWidgetSize.dimen_12
                    : AppWidgetSize.dimen_18,
              ),
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
      ),
    );
  }

  Widget _getLableWithRupeeSymbol(
    String value,
    TextStyle rupeeStyle,
    TextStyle textStyle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextWidget(
          AppConstants.rupeeSymbol + value,
          textStyle,
          isShowShimmer: true,
        ),
      ],
    );
  }

  Widget _buildButtonWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: AppWidgetSize.dimen_50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _getBottomButtonWidget(
              holdingsAddButtonKey,
              _appLocalizations.buy,
              AppColors().positiveColor,
              true,
            ),
            SizedBox(width: AppWidgetSize.dimen_10),
            _getBottomButtonWidget(
              holdingsExitButtonKey,
              _appLocalizations.sell,
              AppColors.negativeColor,
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBottomButtonWidget(
    String key,
    String header,
    Color color,
    bool isGradient,
  ) {
    return GestureDetector(
      key: Key(key),
      onTap: () async {
        if (header == _appLocalizations.buy) {
          _onCallOrderPad(_appLocalizations.buy, null);
        } else {
          _onCallOrderPad(_appLocalizations.sell, null);
        }
      },
      child: Container(
        width: AppWidgetSize.dimen_150,
        height: AppWidgetSize.dimen_50,
        padding: EdgeInsets.all(AppWidgetSize.dimen_10),
        decoration: isGradient
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(25.w),
                gradient: LinearGradient(
                  stops: const [0.0, 1.0],
                  begin: FractionalOffset.topLeft,
                  end: FractionalOffset.topRight,
                  colors: <Color>[
                    Theme.of(context).colorScheme.onBackground,
                    AppColors().positiveColor,
                  ],
                ),
              )
            : BoxDecoration(
                border: Border.all(
                  color: AppColors.negativeColor,
                  width: 1.5,
                ),
                color: AppColors.negativeColor,
                borderRadius: BorderRadius.circular(AppWidgetSize.dimen_30),
              ),
        child: Text(
          header,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .primaryTextTheme
              .displaySmall!
              .copyWith(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }

  void _showWatchlistGroupBottomSheet(
    Symbols symbolItem,
  ) {
    showInfoBottomsheet(
      ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(AppWidgetSize.dimen_20),
        ),
        child: BlocProvider<QuoteBloc>.value(
          value: quoteBloc,
          child: ChooseWatchlistWidget(
            arguments: {
              'symbolItem': symbolItem,
              'groupList': groupList,
            },
          ),
        ),
      ),
      bottomMargin: 0,
      topMargin: false,
      height: (AppUtils().chooseWatchlistHeight(groupList ?? []) <
              (AppWidgetSize.screenHeight(context) * 0.8))
          ? AppUtils().chooseWatchlistHeight(groupList ?? [])
          : (AppWidgetSize.screenHeight(context) * 0.8),
      horizontalMargin: false,
    );
  }

  Future<void> _showCreateNewBottomSheet(
    Symbols symbolItem,
  ) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
      ),
      builder: (BuildContext bct) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(AppWidgetSize.dimen_20),
              ),
            ),
            padding: EdgeInsets.fromLTRB(AppWidgetSize.dimen_20,
                AppWidgetSize.dimen_20, AppWidgetSize.dimen_20, 0),
            child: BlocProvider<QuoteBloc>.value(
              value: quoteBloc,
              child: CreateNewWatchlistWidget(
                arguments: {
                  'symbolItem': symbolItem,
                  'groupList': groupList,
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> informationIconBottomSheet(String title) async {
    String titleText = '';
    String descpText = '';
    if (title == _appLocalizations.overText) {
      titleText = _appLocalizations.overText;
      descpText = _appLocalizations.ovrRetDesp;
    } else if (title == _appLocalizations.todaysReturn) {
      titleText = _appLocalizations.todaysReturn;
      descpText = _appLocalizations.todayRetDesc;
    } else if (title == _appLocalizations.ltp) {
      titleText = _appLocalizations.lastTradePrice;
      descpText = _appLocalizations.ltpDesc;
    } else if (title == _appLocalizations.currValText) {
      titleText = _appLocalizations.currValText;
      descpText = _appLocalizations.curValDesp;
    } else if (title == _appLocalizations.invsText) {
      titleText = _appLocalizations.invsText;
      descpText = _appLocalizations.ovrRetDesp;
    }
    List<Widget> informationWidgetList = [
      _buildExpansionRowForBottomSheet(context, descpText),
      // Divider(
      //   thickness: 1,
      //   color: Theme.of(context).dividerColor,
      // ),
      // _buildExpansionRowForBottomSheet(
      //   context,
      //   _appLocalizations.slm,
      //   _appLocalizations.slMOrderDespText,
      // ),
    ];
    showInfoBottomsheet(
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  titleText,
                  Theme.of(context).primaryTextTheme.titleMedium,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: AppImages.closeIcon(context,
                      width: AppWidgetSize.dimen_20,
                      height: AppWidgetSize.dimen_20,
                      color: Theme.of(context).primaryIconTheme.color,
                      isColor: true),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      shrinkWrap: true,
                      itemCount: informationWidgetList.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return informationWidgetList[index];
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionRowForBottomSheet(
    BuildContext context,
    String description,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_5,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: CustomTextWidget(
          description,
          Theme.of(context).primaryTextTheme.labelSmall,
        ),
      ),
    );
  }
}
