// ignore_for_file: depend_on_referenced_packages

import 'package:acml/src/blocs/holdings/holdings/holdings_bloc.dart';
import 'package:acml/src/blocs/watchlist/watchlist_bloc.dart';
import 'package:acml/src/config/app_config.dart';
import 'package:acml/src/constants/keys/quote_keys.dart';
import 'package:acml/src/ui/screens/positions/positions_convert_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/quote2_stream_response_model.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../blocs/positions/position_conversion/position_convertion_bloc.dart';
import '../../../blocs/positions/positions_detail/positions_detail_bloc.dart';
import '../../../blocs/quote/main_quote/quote_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_events.dart';
import '../../../constants/keys/positions_keys.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/sym_model.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/positions/positions_model.dart';
import '../../../models/watchlist/watchlist_group_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/choose_watchlist_widget.dart';
import '../../widgets/create_new_watchlist_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/horizontal_list_view.dart';
import '../../widgets/label_border_text_widget.dart';
import '../../widgets/table_with_bgcolor.dart';
import '../base/base_screen.dart';

class PositionsDetailsScreen extends BaseScreen {
  final dynamic arguments;
  const PositionsDetailsScreen({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<PositionsDetailsScreen> createState() => _PositionsDetailsScreenState();
}

class _PositionsDetailsScreenState
    extends BaseAuthScreenState<PositionsDetailsScreen> {
  late AppLocalizations _appLocalizations;
  late PositionsDetailBloc positionsDetailBloc;
  late QuoteBloc quoteBloc;
  late Positions _positions;
  late WatchlistBloc watchlistBloc;

  List<Groups>? groupList = <Groups>[];
  int selectedIndex = 0;
  bool isOpen = true;
  @override
  void initState() {
    BlocProvider.of<HoldingsBloc>(context).add(
        HoldingsFetchEvent(false, isStreaming: false, isFetchAgain: false));
    _positions = widget.arguments['symbolItem'];
    isOpen = widget.arguments['isOpen'];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      positionsDetailBloc = BlocProvider.of<PositionsDetailBloc>(context)
        ..stream.listen(_positionsListener);
      quoteBloc = BlocProvider.of<QuoteBloc>(context)
        ..stream.listen(quoteListener);
      watchlistBloc = BlocProvider.of<WatchlistBloc>(context)
        ..stream.listen(watchlistListener);
      watchlistBloc.add(WatchlistGetGroupsEvent(false));
      callStreamEvents();
    });
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.positionsDetailsScreen);
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
      watchlistBloc.add(WatchlistGetGroupsEvent(false));
    } else if (state is QuoteErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  Future<void> _positionsListener(PositionsDetailState state) async {
    if (state is PositionsDetailSymStreamState) {
      subscribeLevel1(state.streamDetails);
    } else if (state is PositionsDetailQuoteTwoStreamState) {
      subscribeLevel2(state.streamDetails);
    } else if (state is PositionsDetailErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  void callStreamEvents() {
    positionsDetailBloc.add(PositionsDetailStartSymStreamEvent(_positions));
    positionsDetailBloc
        .add(PositionsDetailQuoteTwoStartStreamEvent(_positions));
  }

  @override
  void quote1responseCallback(ResponseData data) {
    positionsDetailBloc.add(PositionsDetailStreamingResponseEvent(data));
  }

  @override
  Future<void> quote2responseCallback(Quote2Data streamData) async {
    positionsDetailBloc.add(PositionsDetailQuoteTwoResponseEvent(streamData));
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.positionsDetailsScreen;
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
      toolbarHeight: AppWidgetSize.dimen_100,
      elevation: 0,
      shadowColor: Theme.of(context).dividerColor.withOpacity(0.5),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Column(
        children: [
          _buildAppBarContent(),
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
          right: AppWidgetSize.dimen_30,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: FittedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    _positions.dispSym!,
                    Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: AppWidgetSize.dimen_80,
                        child: LabelBorderWidget(
                          keyText: const Key(positionsBottomSheetStockQuoteKey),
                          text: _appLocalizations.stockQuote,
                          textColor: Theme.of(context).primaryColor,
                          fontSize: AppWidgetSize.fontSize12,
                          margin: EdgeInsets.only(top: AppWidgetSize.dimen_2),
                          borderRadius: AppWidgetSize.dimen_20,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          borderWidth: AppWidgetSize.dimen_1,
                          borderColor: Theme.of(context).dividerColor,
                          isSelectable: true,
                          labelTapAction: () {
                            pushNavigation(
                              ScreenRoutes.quoteScreen,
                              arguments: {
                                'symbolItem': _positions,
                              },
                            );
                          },
                        ),
                      ),
                      if (AppUtils().getsymbolType(_positions) !=
                          AppConstants.indices)
                        Container(
                          margin: EdgeInsets.only(left: AppWidgetSize.dimen_5),
                          width: AppWidgetSize.dimen_100,
                          child: LabelBorderWidget(
                            keyText: const Key(quoteLabelKey),
                            text: _appLocalizations.optionChain,
                            textColor: Theme.of(context).primaryColor,
                            fontSize: AppWidgetSize.fontSize12,
                            margin: EdgeInsets.only(top: AppWidgetSize.dimen_2),
                            borderRadius: 20.w,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            borderWidth: 1,
                            borderColor: Theme.of(context).dividerColor,
                            isSelectable: true,
                            labelTapAction: () {
                              optionChainTapAction(_positions);
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> optionChainTapAction(Symbols positions) async {
    sendEventToFirebaseAnalytics(
        AppEvents.optionchainClick,
        ScreenRoutes.positionScreen,
        'clicked option chain from position bottom sheet',
        key: "symbol",
        value: positions.dispSym);
    unsubscribeLevel1();

    await pushNavigation(
      ScreenRoutes.quoteOptionChain,
      arguments: {'symbolItem': positions, 'expiry': positions.sym?.expiry},
    );
    positionsDetailBloc.add(PositionsDetailStartSymStreamEvent(_positions));
  }

  Widget _getAppBarRightContent() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_10,
          ),
          child: GestureDetector(
            onTap: () {
              if (groupList!.isEmpty) {
                _showCreateNewBottomSheet(_positions);
              } else {
                _showWatchlistGroupBottomSheet(_positions);
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSegmentWidget(_positions),
        Padding(
          padding: EdgeInsets.only(
            bottom: AppWidgetSize.dimen_8,
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  right: AppWidgetSize.dimen_8,
                ),
                child: getLableBorderWidget(
                  positionsSymbolRowProductTypeKey,
                  _positions.prdType.toString(),
                ),
              ),
              getLableBorderWidget(
                positionsSymbolRowProductTypeKey,
                AppUtils().doubleValue(_positions.netQty) != 0
                    ? _appLocalizations.open
                    : _appLocalizations.ordStatusClosed,
              ),
            ],
          ),
        ),
        _buildButtonWidget(),
        buildTableWithBackgroundColor(
            _positions.isOneDay
                ? _appLocalizations.netdayQty
                : _appLocalizations.netQty,
            _positions.netQty.withMultiplierTrade(_positions.sym),
            _appLocalizations.carryForwardQty,
            (AppUtils().intValue(_positions.cfBuyQty) -
                    AppUtils().intValue(_positions.cfSellQty!))
                .toString()
                .withMultiplierTrade(_positions.sym),
            '',
            '',
            context,
            showtable: !_positions.isOneDay),
        buildTableWithBackgroundColor(
          _appLocalizations.ltp,
          _positions.ltp!,
          _appLocalizations.avgPrice,
          _positions.avgPrice!,
          '',
          '',
          context,
          isShowShimmer: true,
          isRupeeSymbol1: true,
          isRupeeSymbol: true,
        ),
        buildTableWithBackgroundColor(
          _appLocalizations.closed_,
          _positions.close ?? "0",
          _appLocalizations.open,
          _positions.open ?? "0",
          '',
          '',
          context,
          isRupeeSymbol1: true,
          isRupeeSymbol: true,
        ),
        buildTableWithBackgroundColor(
          AppUtils().getsymbolType(_positions) == AppConstants.fno
              ? _appLocalizations.currentExposure
              : _appLocalizations.currentValue,
          _positions.currentValue!,
          AppUtils().getsymbolType(_positions) == AppConstants.fno
              ? _appLocalizations.exposureTaken
              : _appLocalizations.investedValue,
          _positions.invested ?? "",
          '',
          '',
          context,
          isShowShimmer: true,
          isRupeeSymbol1: true,
          isRupeeSymbol: true,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: BlocBuilder<PositionsDetailBloc, PositionsDetailState>(
        buildWhen: (previous, current) {
          return current is PositionsDetailDataState;
        },
        builder: (context, state) {
          if (state is PositionsDetailDataState) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFixedTopBarContent(),
                  _buildBodyContentWidget(
                    state.positions!,
                  ),
                ],
              ),
            );
          }
          return _buildBodyContentWidget(_positions);
        },
      ),
    );
  }

  Widget _buildBodyContentWidget(
    Positions positions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: AppWidgetSize.dimen_20,
        ),
        Container(
          width: AppWidgetSize.fullWidth(context),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 2.5,
                color: Theme.of(context).dividerColor.withOpacity(0.4),
              ),
            ),
          ),
          child: horizontalListView(
            values: [
              _appLocalizations.netHoldings,
            ],
            selectedIndex: selectedIndex,
            isEnabled: true,
            isRectShape: false,
            callback: (value, index) {
              selectedIndex = index;
              setState(() {});
            },
            highlighterColor:
                Theme.of(context).primaryTextTheme.displayLarge!.color!,
            context: context,
            vertical: 0,
            fontSize: AppWidgetSize.dimen_15,
            height: AppWidgetSize.dimen_35,
          ),
        ),
        _buildNetHoldings(positions),
        SizedBox(
          height: AppWidgetSize.dimen_20,
        ),
      ],
    );
  }

  // Widget _getWidgetWithBackgroundColor(
  //   String title,
  //   String value,
  // ) {
  //   return Padding(
  //     padding: EdgeInsets.only(
  //       bottom: AppWidgetSize.dimen_10,
  //       left: AppWidgetSize.dimen_25,
  //       right: AppWidgetSize.dimen_35,
  //     ),
  //     child: Container(
  //       height: AppWidgetSize.dimen_45,
  //       color:
  //           Theme.of(context).inputDecorationTheme.fillColor!.withOpacity(0.5),
  //       padding: EdgeInsets.only(
  //         left: AppWidgetSize.dimen_15,
  //         right: AppWidgetSize.dimen_15,
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           CustomTextWidget(
  //             title,
  //             Theme.of(context).primaryTextTheme.caption!.copyWith(
  //                   color: Theme.of(context).colorScheme.primary,
  //                 ),
  //           ),
  //           _getLableWithRupeeSymbol(
  //             value,
  //             Theme.of(context).primaryTextTheme.caption!.copyWith(
  //                   fontFamily: AppConstants.interFont,
  //                 ),
  //             Theme.of(context).primaryTextTheme.overline!,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildMarketDepthWidget() {
  //   return BlocBuilder<PositionsDetailBloc, PositionsDetailState>(
  //     buildWhen:
  //         (PositionsDetailState prevState, PositionsDetailState currentState) {
  //       return currentState is PositionsDetailMktDepthDataState;
  //     },
  //     builder: (BuildContext context, PositionsDetailState state) {
  //       final Quote2Data? quoteDepthData =
  //           state is PositionsDetailMktDepthDataState
  //               ? state.quoteMarketDepthData
  //               : AppConfig().marketDepthData;
  //       if (state is PositionsDetailMktDepthDataState) {
  //         return Padding(
  //           padding: EdgeInsets.only(
  //             left: AppWidgetSize.dimen_30,
  //             right: AppWidgetSize.dimen_32,
  //           ),
  //           child: MarketDepthWidget(
  //               quoteDepthData: quoteDepthData!,
  //               infoIcon: false,
  //               totalBidQtyPercent: state.totalBidQtyPercent!,
  //               totalAskQtyPercent: state.totalAskQtyPercent!,
  //               bidQtyPercent: state.bidQtyPercent,
  //               askQtyPercent: state.askQtyPercent),
  //         );
  //       }
  //       List<String> totalBidAskQtyPercent = AppConfig().totalBuyAskQty;
  //       return Padding(
  //         padding: EdgeInsets.only(
  //           left: AppWidgetSize.dimen_30,
  //           right: AppWidgetSize.dimen_32,
  //         ),
  //         child: MarketDepthWidget(
  //             quoteDepthData: quoteDepthData!,
  //             totalBidQtyPercent: '0.0',
  //             infoIcon: false,
  //             totalAskQtyPercent: '0.0',
  //             bidQtyPercent: totalBidAskQtyPercent,
  //             askQtyPercent: totalBidAskQtyPercent),
  //       );
  //     },
  //   );
  // }

  // Widget _buildPerformaceWidget() {
  //   return Padding(
  //     padding: EdgeInsets.only(
  //       left: AppWidgetSize.dimen_30,
  //       right: AppWidgetSize.dimen_32,
  //     ),
  //     child: PerformanceWidget(
  //       symbols: _positions,
  //       infoIcon: false,
  //     ),
  //   );
  // }

  Widget _buildSegmentWidget(
    Positions positions,
  ) {
    return BlocBuilder<PositionsDetailBloc, PositionsDetailState>(
      buildWhen: (previous, current) {
        return current is PositionsDetailDataState;
      },
      builder: (context, state) {
        if (state is PositionsDetailDataState) {
          return buildSegmentContainer(
            state.positions!,
          );
        }
        return buildSegmentContainer(
          positions,
        );
      },
    );
  }

  Widget getLableBorderWidget(
    String key,
    String title,
  ) {
    return SizedBox(
      width: title.textSize(
            title,
            Theme.of(context).inputDecorationTheme.labelStyle!,
          ) +
          AppWidgetSize.dimen_10,
      child: LabelBorderWidget(
        keyText: Key(key),
        text: title,
        textColor: Theme.of(context).inputDecorationTheme.labelStyle!.color,
        fontSize: AppWidgetSize.fontSize12,
        borderRadius: AppWidgetSize.dimen_20,
        margin: EdgeInsets.only(right: AppWidgetSize.dimen_1),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        borderWidth: 1,
        borderColor: Theme.of(context).dividerColor,
      ),
    );
  }

  Widget buildSegmentContainer(
    Positions positions,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_20,
      ),
      height: AppWidgetSize.dimen_130,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _buildListBoxContent(
              _appLocalizations.todaysPnL,
              AppUtils().dataNullCheck(positions.oneDayPnL),
              '(${AppUtils().dataNullCheck(positions.oneDayPnLPercent)}%)',
              AppUtils().profitLostColor(positions.oneDayPnL),
            );
          } else if (index == 1 && !positions.isOneDay) {
            return Featureflag.showOverallPnl
                ? _buildListBoxContent(
                    _appLocalizations.overallPnL,
                    positions.overallPnL!,
                    AppUtils()
                        .getPercentage(positions.overallPnLPercent ?? "0"),
                    AppUtils().profitLostColor(positions.overallPnL!),
                  )
                : Container();
          } else {
            return Container();
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
        right: AppWidgetSize.dimen_10,
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
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_5,
        right: AppWidgetSize.dimen_5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                title,
                Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              GestureDetector(
                onTap: () {
                  informationIconBottomSheet(title);
                },
                child: AppImages.informationIcon(
                  context,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true,
                  width: AppWidgetSize.dimen_20,
                  height: AppWidgetSize.dimen_20,
                ),
              ),
            ],
          ),
          _getLableWithRupeeSymbol(
            value,
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
              Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
              isShowShimmer: true,
            ),
          )
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _getBottomButtonWidget(
                positionAddButtonKey,
                !isOpen ? _appLocalizations.buy : _appLocalizations.add,
                AppColors().positiveColor,
                true,
              ),
              if (isSquareOff() ||
                  AppUtils().doubleValue(_positions.netQty) == 0)
                SizedBox(width: AppWidgetSize.dimen_10),
              if (isTransferable() && isOpen)
                _getBottomButtonWidget(
                  positionConvertButtonKey,
                  _appLocalizations.convert,
                  AppColors().positiveColor,
                  false,
                ),
              if (isTransferable()) SizedBox(width: AppWidgetSize.dimen_10),
              if (isSquareOff() ||
                  AppUtils().doubleValue(_positions.netQty) == 0)
                _getBottomButtonWidget(
                  positionExitButtonKey,
                  isOpen ? _appLocalizations.exit : _appLocalizations.sell,
                  AppColors.negativeColor,
                  false,
                ),
            ],
          )),
    );
  }

  double gradientButtonSizes(bool isOpen) {
    double width = AppWidgetSize.fullWidth(context) / 1.2;
    if (isTransferable() && isOpen) {
      width = AppWidgetSize.fullWidth(context) / 2.7;
    }
    if (isSquareOff() || !isOpen) {
      width = AppWidgetSize.fullWidth(context) / 2.6;
    }
    if (isSquareOff() && isTransferable() && isOpen) {
      width = AppWidgetSize.fullWidth(context) / 3.8;
    }
    return width;
  }

  bool isSquareOff() => _positions.isSquareoff == 'true';

  bool isTransferable() => _positions.transferable == 'true';

  Widget _getBottomButtonWidget(
    String key,
    String header,
    Color color,
    bool isGradient,
  ) {
    return gradientButtonWidget(
      onTap: () async {
        String action;
        bool buy;
        if (header ==
            (!isOpen ? AppLocalizations().buy : _appLocalizations.add)) {
          if (AppUtils().intValue(_positions.netQty) > 0) {
            buy = true;
          } else {
            buy = false;
          }
          if (buy) {
            if (AppUtils().intValue(_positions.netQty) < 0) {
              action = isOpen ? AppConstants.sell : AppConstants.buy;
            } else {
              action = isOpen ? AppConstants.buy : AppConstants.sell;
            }
          } else {
            if (AppUtils().intValue(_positions.netQty) > 0) {
              action = isOpen ? AppConstants.buy : AppConstants.sell;
            } else {
              action = isOpen ? AppConstants.sell : AppConstants.buy;
            }
          }
          _onCallOrderPad(
            action,
            isOpen,
            header,
          );
        } else if (header ==
            (!isOpen ? AppLocalizations().sell : _appLocalizations.exit)) {
          if (AppUtils().intValue(_positions.netQty) > 0) {
            _onCallOrderPad(
              isOpen ? AppConstants.sell : AppConstants.buy,
              isOpen,
              header,
            );
          } else {
            _onCallOrderPad(
              isOpen ? AppConstants.buy : AppConstants.sell,
              isOpen,
              header,
            );
          }
        } else {
          await _showPositionsConvertBottomSheet(_positions);
        }
      },
      width: gradientButtonSizes(isOpen),
      key: Key(header),
      context: context,
      title: header,
      isGradient: header == _appLocalizations.convert ? false : true,
      gradientColors: header == _appLocalizations.exit ||
              header == _appLocalizations.sell
          ? AppUtils().intValue(_positions.netQty) < 0
              ? [
                  Theme.of(context).colorScheme.onBackground,
                  AppColors().positiveColor
                ]
              : [AppColors.negativeColor, AppColors.negativeColor]
          : header == _appLocalizations.add || header == _appLocalizations.buy
              ? AppUtils().intValue(_positions.netQty) >= 0
                  ? [
                      Theme.of(context).colorScheme.onBackground,
                      AppColors().positiveColor
                    ]
                  : [AppColors.negativeColor, AppColors.negativeColor]
              : null,
    );
  }

  _isFutures(Sym? sym) {
    if (sym!.asset == 'future') {
      return true;
    }
    return false;
  }

  Future _showPositionsConvertBottomSheet(Positions positions) async {
    positions.isFUT = _isFutures(positions.sym);
    return showInfoBottomsheet(
        BlocProvider<PositionConvertionBloc>(
          create: (context) => PositionConvertionBloc(),
          child: PositionsConvertSheet(
            arguments: {
              'positions': positions,
            },
          ),
        ),
        topMargin: false,
        bottomMargin: 0,
        horizontalMargin: false);
  }

  Widget _getNewHoldingsHeader(
    String header,
  ) {
    return CustomTextWidget(
      header,
      Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _getTableHeaderWidget() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_10,
        top: AppWidgetSize.dimen_10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              width: AppWidgetSize.dimen_10,
            ),
          ),
          Expanded(
            flex: 1,
            child: CustomTextWidget(
              _appLocalizations.qty,
              Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          Expanded(
            flex: 2,
            child: CustomTextWidget(
              _appLocalizations.amount,
              Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getNetHoldingsLeftTableCell(
    String title,
    Color color,
  ) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_10,
        ),
        child: CustomTextWidget(
          title,
          Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: color,
              ),
        ),
      ),
    );
  }

  Widget _getNetHoldingsMiddleTableCell(
    String title,
  ) {
    return Expanded(
      flex: 1,
      child: CustomTextWidget(
        title,
        Theme.of(context).primaryTextTheme.labelSmall!,
      ),
    );
  }

  Widget _getNetHoldingsRightTableCell(
    String value1,
    String value2,
  ) {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
            value1,
            Theme.of(context).primaryTextTheme.labelSmall,
          ),
          Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_6,
            ),
            child: CustomTextWidget(
              '$value2 ${_appLocalizations.avg}',
              Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getNetHoldingsTable(
    String leftLabel1,
    String leftLabel2,
    String middleLabel1,
    String middleLabel2,
    String rightLabel1,
    String rightLabel2,
    String rightLabel3,
    String rightLabel4,
  ) {
    return Column(
      children: [
        _getTableHeaderWidget(),
        Container(
          padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getNetHoldingsLeftTableCell(
                    leftLabel1,
                    AppColors().positiveColor,
                  ),
                  _getNetHoldingsMiddleTableCell(
                    middleLabel1.withMultiplierTrade(_positions.sym),
                  ),
                  _getNetHoldingsRightTableCell(
                    rightLabel1,
                    rightLabel2,
                  ),
                ],
              ),
              Divider(
                thickness: AppWidgetSize.dimen_1,
                endIndent: AppWidgetSize.dimen_10,
                indent: AppWidgetSize.dimen_10,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_5,
                  bottom: AppWidgetSize.dimen_5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _getNetHoldingsLeftTableCell(
                      leftLabel2,
                      leftLabel2 == _appLocalizations.sold
                          ? AppColors.negativeColor
                          : AppColors().positiveColor,
                    ),
                    _getNetHoldingsMiddleTableCell(
                      middleLabel2.withMultiplierTrade(_positions.sym),
                    ),
                    _getNetHoldingsRightTableCell(
                      rightLabel3,
                      rightLabel4,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNetHoldings(
    Positions positions,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_30,
        bottom: AppWidgetSize.dimen_30,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _getNewHoldingsHeader(
                  _appLocalizations.todaysTradeSummary,
                ),
                _getNetHoldingsTable(
                  _appLocalizations.bought,
                  _appLocalizations.sold,
                  AppUtils().dataNullCheck(positions.dayBuyQty),
                  AppUtils().dataNullCheck(positions.daySellQty),
                  AppUtils().dataNullCheck(AppUtils().commaFmt(
                    AppUtils().decimalValue(
                      positions.dayBuyQty
                              .withMultiplierTrade(_positions.sym)
                              .exdouble() *
                          positions.dayBuyAvgPrice.exdouble(),
                      decimalPoint:
                          AppUtils().getDecimalpoint(_positions.sym?.exc),
                    ),
                  )),
                  AppUtils().dataNullCheck(_positions.dayBuyAvgPrice),
                  AppUtils().dataNullCheck(AppUtils().commaFmt(
                    AppUtils().decimalValue(
                        positions.daySellQty
                                .withMultiplierTrade(_positions.sym)
                                .exdouble() *
                            positions.daySellAvgPrice.exdouble(),
                        decimalPoint:
                            AppUtils().getDecimalpoint(_positions.sym?.exc)),
                  )),
                  AppUtils().dataNullCheck(_positions.daySellAvgPrice),
                ),
              ],
            ),
            if (AppUtils().doubleValue(positions.cfBuyQty) != 0 ||
                AppUtils().doubleValue(positions.cfSellQty) != 0)
              Padding(
                padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _getNewHoldingsHeader(
                      _appLocalizations.broughtForward,
                    ),
                    netHoldingsBody(positions),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  BlocBuilder<HoldingsBloc, HoldingsState> netHoldingsBody(
      Positions positions) {
    return BlocBuilder<HoldingsBloc, HoldingsState>(
      builder: (context, state) {
        return _getNetHoldingsTable(
          (isNFOCDSMCX(positions))
              ? _appLocalizations.bought
              : _appLocalizations.boughtDemat,
          isNFOCDSMCX(positions)
              ? _appLocalizations.sold
              : _appLocalizations.boughtT1,
          isNFOCDSMCX(positions)
              ? AppUtils().dataNullCheck(positions.cfBuyQty)
              : boughtDematQty(context, positions),
          isNFOCDSMCX(positions)
              ? AppUtils().dataNullCheck(positions.cfSellQty)
              : boughtT1Qty(context, positions),
          isNFOCDSMCX(positions)
              ? AppUtils().dataNullCheck(AppUtils().commaFmt(
                  AppUtils().decimalValue(
                    positions.cfBuyQty
                            .withMultiplierTrade(_positions.sym)
                            .exdouble() *
                        positions.cfBuyAvgPrice.exdouble(),
                  ),
                ))
              : boughtDematAmount(context, positions),
          isNFOCDSMCX(positions)
              ? AppUtils().dataNullCheck(positions.cfBuyAvgPrice)
              : boughtHoldingAvg(context, positions),
          isNFOCDSMCX(positions)
              ? AppUtils().dataNullCheck(AppUtils().commaFmt(
                  AppUtils().decimalValue(
                    positions.cfSellQty
                            .withMultiplierTrade(_positions.sym)
                            .exdouble() *
                        positions.cfSellAvgPrice.exdouble(),
                  ),
                ))
              : boughtT1Amt(context, positions),
          isNFOCDSMCX(positions)
              ? AppUtils().dataNullCheck(positions.cfSellAvgPrice)
              : boughtHoldingAvg(context, positions),
        );
      },
    );
  }

  String boughtT1Amt(BuildContext context, Positions positions) {
    return AppUtils().commaFmt(((AppUtils().intValue(
                BlocProvider.of<HoldingsBloc>(context)
                        .holdingsFetchDoneState
                        .mainHoldingsSymbols
                        ?.firstWhereOrNull(
                            (element) => element.dispSym == positions.dispSym)
                        ?.btst ??
                    "0")) *
            AppUtils().intValue(BlocProvider.of<HoldingsBloc>(context)
                    .holdingsFetchDoneState
                    .mainHoldingsSymbols
                    ?.firstWhereOrNull(
                        (element) => element.dispSym == positions.dispSym)
                    ?.avgPrice ??
                "0"))
        .toString());
  }

  String boughtHoldingAvg(BuildContext context, Positions positions) {
    return AppUtils().commaFmt(BlocProvider.of<HoldingsBloc>(context)
            .holdingsFetchDoneState
            .mainHoldingsSymbols
            ?.firstWhereOrNull(
                (element) => element.dispSym == positions.dispSym)
            ?.avgPrice ??
        "0.00");
  }

  String boughtDematAmount(BuildContext context, Positions positions) {
    return AppUtils().commaFmt(((AppUtils().intValue(
                    BlocProvider.of<HoldingsBloc>(context)
                            .holdingsFetchDoneState
                            .mainHoldingsSymbols
                            ?.firstWhereOrNull((element) =>
                                element.dispSym == positions.dispSym)
                            ?.qty ??
                        "0") -
                AppUtils().intValue(BlocProvider.of<HoldingsBloc>(context)
                        .holdingsFetchDoneState
                        .mainHoldingsSymbols
                        ?.firstWhereOrNull(
                            (element) => element.dispSym == positions.dispSym)
                        ?.btst ??
                    "0")) *
            AppUtils().intValue(BlocProvider.of<HoldingsBloc>(context)
                    .holdingsFetchDoneState
                    .mainHoldingsSymbols
                    ?.firstWhereOrNull(
                        (element) => element.dispSym == positions.dispSym)
                    ?.avgPrice ??
                "0"))
        .toString());
  }

  String boughtT1Qty(BuildContext context, Positions positions) {
    return BlocProvider.of<HoldingsBloc>(context)
            .holdingsFetchDoneState
            .mainHoldingsSymbols
            ?.firstWhereOrNull(
                (element) => element.dispSym == positions.dispSym)
            ?.btst ??
        "0";
  }

  String boughtDematQty(BuildContext context, Positions positions) {
    return (AppUtils().intValue(BlocProvider.of<HoldingsBloc>(context)
                    .holdingsFetchDoneState
                    .mainHoldingsSymbols
                    ?.firstWhereOrNull(
                        (element) => element.dispSym == positions.dispSym)
                    ?.qty ??
                "0") -
            AppUtils().intValue(BlocProvider.of<HoldingsBloc>(context)
                    .holdingsFetchDoneState
                    .mainHoldingsSymbols
                    ?.firstWhereOrNull(
                        (element) => element.dispSym == positions.dispSym)
                    ?.btst ??
                "0"))
        .toString();
  }

  bool isNFOCDSMCX(Positions positions) {
    return positions.sym!.exc == AppConstants.nfo ||
        positions.sym!.exc == AppConstants.cds ||
        positions.sym!.exc == AppConstants.mcx;
  }

  void _showWatchlistGroupBottomSheet(
    Symbols symbolItem,
  ) {
    showInfoBottomsheet(
        BlocProvider<QuoteBloc>.value(
            value: quoteBloc,
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(AppWidgetSize.dimen_20),
              ),
              child: ChooseWatchlistWidget(
                arguments: {
                  'symbolItem': symbolItem,
                  'groupList': groupList,
                },
              ),
            )),
        topMargin: false,
        bottomMargin: 0,
        height: (AppUtils().chooseWatchlistHeight(groupList ?? []) <
                (AppWidgetSize.screenHeight(context) * 0.8))
            ? AppUtils().chooseWatchlistHeight(groupList ?? [])
            : (AppWidgetSize.screenHeight(context) * 0.8),
        horizontalMargin: false);
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
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(AppWidgetSize.dimen_20),
            ),
          ),
          child: SafeArea(
            child: Container(
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
          ),
        );
      },
    ).then((value) {
      Navigator.of(context).pop();
    });
  }

  Future<void> _onCallOrderPad(
    String action,
    bool isOpen,
    String header,
  ) async {
    await pushNavigation(
      ScreenRoutes.orderPadScreen,
      arguments: {
        'action': action,
        'symbolItem': _positions,
        AppConstants.positionExitOrAdd:
            _positions.netQty.withMultiplierTrade(_positions.sym),
        AppConstants.positionsPrdType: (_positions.prdType?.toLowerCase() ==
                    AppConstants.coverOrder.toLowerCase() ||
                _positions.prdType?.toLowerCase() ==
                    AppConstants.bracketOrder.toLowerCase())
            ? AppLocalizations().intraDay.toUpperCase()
            : _positions.prdType,
        AppConstants.isOpenPosition: isOpen,
        AppConstants.positionButtonHeader: header,
      },
    );
    popNavigation();
  }

  // Future _showPositionsConvertBottomSheet(Positions positions) async {
  //   positions.isFUT = _isFutures(positions.sym);
  //   return showInfoBottomsheet(
  //       BlocProvider<PositionConvertionBloc>(
  //         create: (context) => PositionConvertionBloc(),
  //         child: PositionsConvertSheet(
  //           arguments: {
  //             'positions': positions,
  //           },
  //         ),
  //       ),
  //       horizontalMargin: false);
  // }

  Future<void> informationIconBottomSheet(String title) async {
    String titleText = '';
    String descpText = '';
    if (title == _appLocalizations.overText) {
      titleText = _appLocalizations.overText;
      descpText = _appLocalizations.ovrRetDesp;
    } else if (title == _appLocalizations.todaysReturn) {
      titleText = _appLocalizations.todaysReturn;
      descpText = "";
    } else if (title == _appLocalizations.ltp) {
      titleText = _appLocalizations.ltp;
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
        child: description == ""
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headingSubjectWidget('', [
                    TextSpan(
                        text:
                            "A ${_appLocalizations.todaysPnL} ${_appLocalizations.todayPnlInfodescription1}")
                  ]),
                  Padding(
                    padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_10),
                    child: CustomTextWidget(
                      "For stocks purchased today,",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                  CustomTextWidget(
                      "${_appLocalizations.todaysPnL} = (Current LTP – Today’s average trade price) * Quantity",
                      Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(fontWeight: FontWeight.w600)),
                  headingSubjectWidget("", [
                    const TextSpan(
                        text:
                            "For F&O positions, your 1-day return would be net of current market price and your buying/selling average (or yesterday’s close if it is a carry-forward position).")
                  ]),
                ],
              )
            : CustomTextWidget(
                description,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
      ),
    );
  }

  Widget headingSubjectWidget(String heading, List<TextSpan> subject,
      {double? padding}) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: padding ?? AppWidgetSize.dimen_10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heading != "")
            CustomTextWidget(
                heading,
                Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.justify),
          Padding(
              padding: EdgeInsets.symmetric(
                  vertical: padding ?? AppWidgetSize.dimen_10),
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: Theme.of(context).primaryTextTheme.labelSmall,
                  children: subject,
                ),
              )),
        ],
      ),
    );
  }
}
