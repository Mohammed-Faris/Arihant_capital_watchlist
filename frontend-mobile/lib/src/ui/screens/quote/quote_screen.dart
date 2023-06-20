import 'package:acml/src/ui/screens/quote/quote_constituents.dart';
import 'package:acml/src/ui/screens/quote/quote_contributor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../blocs/market_status/market_status_bloc.dart';
import '../../../blocs/quote/main_quote/quote_bloc.dart';
import '../../../blocs/search/search_bloc.dart';
import '../../../blocs/watchlist/watchlist_bloc.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_events.dart';
import '../../../constants/keys/quote_keys.dart';
import '../../../data/store/app_store.dart';
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
import '../../widgets/fandotag.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/label_border_text_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/toggle_circular_widget.dart';
import '../alerts/choose_alert.dart';
import '../base/base_screen.dart';
import 'quote_analysis.dart';
import 'quote_chart.dart';
import 'quote_corporate_action.dart';
import 'quote_deals.dart';
import 'quote_financials/quote_financials.dart';
import 'quote_futures_options.dart';
import 'quote_news.dart';
import 'quote_overview.dart';
import 'quote_peers.dart';

class QuoteScreen extends BaseScreen {
  final dynamic arguments;
  const QuoteScreen({Key? key, required this.arguments}) : super(key: key);

  @override
  QuoteScreenState createState() => QuoteScreenState();
}

class QuoteScreenState extends BaseAuthScreenState<QuoteScreen>
    with TickerProviderStateMixin {
  late QuoteBloc quoteBloc;
  late WatchlistBloc watchlistBloc;
  late MarketStatusBloc marketStatusBloc;
  final ScrollController _scrollControllerForTopContent = ScrollController();
  final AppLocalizations _appLocalizations = AppLocalizations();
  ValueNotifier<bool> isScrolledToTop = ValueNotifier<bool>(false);
  late Symbols symbols;
  List<String> tabsHeaders = [];

  TabController? tabController;
  List<String>? exchangeList = [];
  List<Groups>? groupList = <Groups>[];
  String symbolType = "";
  late SearchBloc searchBloc;
  bool shouldHideFooter = false;
  @override
  void initState() {
    symbols = widget.arguments['symbolItem'];
    quoteBloc = BlocProvider.of<QuoteBloc>(context)
      ..stream.listen(quoteListener);
    quoteBloc.add(QuoteGetSectorEvent(symbols.sym!));
    callStreaming();

    shouldHideFooter = widget.arguments['shouldHideFooter'] ?? false;
    searchBloc = BlocProvider.of<SearchBloc>(context)
      ..stream.listen(searchBlocListner);
    exchangeList!.add(symbols.sym?.exc == AppConstants.nfo
        ? AppConstants.fo
        : AppUtils().dataNullCheck(symbols.sym?.exc!));
    if (symbols.sym?.otherExch != null) {
      exchangeList!.addAll(List.from(symbols.sym?.otherExch ?? []));
    }
    symbolType = AppUtils().getsymbolType(symbols);

    marketStatusBloc = BlocProvider.of<MarketStatusBloc>(context)
      ..add(GetMarketStatusEvent(symbols.sym!));

    watchlistBloc = BlocProvider.of<WatchlistBloc>(context)
      ..stream.listen(watchlistListener);
    watchlistBloc.add(WatchlistGetGroupsEvent(false));
    tabsHeaders = getTabHeaders()
        .where((element) =>
            (element == _appLocalizations.quoteFandO
                ? (Featureflag.isFnoSymbolsKeyCheck
                    ? AppUtils().getsymbolType(symbols) == AppConstants.equity
                        ? symbols.isFno
                        : true
                    : true)
                : true) &&
            AppConfig.quoteTabs[symbolType].contains(element))
        .toList();

    if (symbolType == 'indices') {
      tabsHeaders.addAll([
        _appLocalizations.contributor,
        _appLocalizations.constituents,
      ]);
    }

    tabController = TabController(vsync: this, length: tabsHeaders.length);

    tabController?.addListener(() {
      sendEventToFirebaseAnalytics(
          AppEvents.quoteTabclick,
          ScreenRoutes.quoteScreen,
          'clicked ${tabsHeaders[tabController?.index ?? 0]} tab in quotescreen',
          key: "symbol",
          value: symbols.dispSym);
    });
    scrollListerner();

    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.quoteScreen);
    arguments = widget.arguments;
  }

  void callStreaming() {
    quoteBloc.add(QuoteStartSymStreamEvent(symbols));
  }

  Future<void> quoteListener(QuoteState state) async {
    if (state is! QuoteProgressState) {
      if (mounted) {}
    }
    if (state is QuoteProgressState) {
      if (mounted) {}
    } else if (state is QuoteExcChangeState) {
      unsubscribeLevel1();
      symbols = state.symbolItem;
      symbolType = AppUtils().getsymbolType(symbols);
      int currentTab = tabController?.index ?? 0;
      tabsHeaders = getTabHeaders()
          .where((element) =>
              (element == _appLocalizations.quoteFandO
                  ? (Featureflag.isFnoSymbolsKeyCheck
                      ? AppUtils().getsymbolType(symbols) == AppConstants.equity
                          ? symbols.isFno
                          : true
                      : true)
                  : true) &&
              AppConfig.quoteTabs[symbolType].contains(element))
          .toList();
      tabController = TabController(vsync: this, length: tabsHeaders.length);
      tabController?.index = currentTab;
      if (symbols.sym != null) {
        marketStatusBloc.add(GetMarketStatusEvent(symbols.sym!));
      }
      callStreaming();
    } else if (state is QuoteSymStreamState) {
      subscribeLevel1(state.streamDetails);
      setState(() {});
    } else if (state is QuotedeleteDoneState) {
      showToast(
        message: state.messageModel,
        context: context,
      );
    } else if (state is QuoteAddSymbolFailedState ||
        state is QuotedeleteSymbolFailedState) {
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

  void scrollListerner() {
    _scrollControllerForTopContent.addListener(
      () {
        if (_scrollControllerForTopContent.offset != 0.0) {
          if (_scrollControllerForTopContent.offset >=
              AppWidgetSize.dimen_130) {
            isScrolledToTop.value = true;
          } else {
            isScrolledToTop.value = false;
          }
        }
      },
    );
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.quoteScreen;
  }

  @override
  void quote1responseCallback(ResponseData data) {
    quoteBloc.add(QuoteStreamingResponseEvent(data));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            popNavigation();
            return false;
            //return Future.delayed(const Duration(seconds: 0));
          },
          child: Scaffold(
            appBar: _buildAppBar(),
            body: _buildBody(),
            persistentFooterButtons: <Widget>[
              !shouldHideFooter ? _buildPresistentFooterWidget() : Container(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      toolbarHeight: AppWidgetSize.dimen_60,
      elevation: 0.0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: Container(
        height: AppWidgetSize.fullWidth(context),
        width: AppWidgetSize.fullWidth(context),
        padding: EdgeInsets.only(
          // left: AppWidgetSize.dimen_10,
          right: AppWidgetSize.dimen_10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAppBarLeftWidget(),
            _buildAppBarRightWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarLeftWidget() {
    return Row(
      children: [
        backIconButton(
            onTap: () {
              // if (symbolType != AppConstants.indices) {
              //   if ((exchangeList?.contains(AppConstants.nse)) ?? false) {
              //     quoteBloc.add(QuoteExcChangeEvent(exchangeList![0]));
              //   }
              // }

              popNavigation();
            },
            customColor: Theme.of(context).textTheme.displayMedium!.color),
        _buildQuoteStreamingContent(true)
      ],
    );
  }

  Widget _buildQuoteStreamingContent(bool isAppBar) {
    return BlocBuilder<QuoteBloc, QuoteState>(
        buildWhen: (QuoteState previous, QuoteState current) {
      return current is QuoteSymbolItemState;
    }, builder: (context, state) {
      if (state is QuoteProgressState) {
        return const LoaderWidget();
      }
      if (state is QuoteSymbolItemState) {
        return ValueListenableBuilder<bool>(
            valueListenable: isScrolledToTop,
            builder: (context, value, _) {
              return isAppBar
                  ? value
                      ? _buildAppBarStreamingContent()
                      : Container()
                  : _buildSliverAppBarContent();
            });
      }
      return Container();
    });
  }

  Widget _buildAppBarStreamingContent() {
    return SizedBox(
      height: AppWidgetSize.dimen_40,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                width: AppWidgetSize.screenWidth(context) * 0.5,
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      CustomTextWidget(
                          (symbols.sym?.optionType != null)
                              ? '${symbols.baseSym} '
                              : AppUtils().dataNullCheck(symbols.dispSym),
                          Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.left),
                      FandOTag(
                        symbols,
                      ),
                    ],
                  ),
                )),
            SizedBox(
              width: AppWidgetSize.screenWidth(context) * 0.42,
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomTextWidget(
                      AppUtils().dataNullCheck(symbols.ltp),
                      Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: AppWidgetSize.fontSize16,
                            color: AppUtils().setcolorForChange(
                                AppUtils().dataNullCheck(symbols.chng)),
                          ),
                      isShowShimmer: true,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppWidgetSize.dimen_5,
                      ),
                      child: CustomTextWidget(
                        AppUtils().getChangePercentage(symbols),
                        Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                              fontSize: AppWidgetSize.fontSize14,
                              color: Theme.of(context)
                                  .inputDecorationTheme
                                  .labelStyle!
                                  .color,
                            ),
                        isShowShimmer: true,
                      ),
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

  Widget _buildAppBarRightWidget() {
    return Row(
      children: [
        if (symbolType != AppConstants.indices) _buildExchangeToggleWidget(),
        if (Featureflag.alerts)
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: GestureDetector(
                onTap: () async {
                  await ChooseAlerts.show(context, symbols,
                      fromStockQuote: true);
                },
                child: FutureBuilder(
                  future: AppUtils().isAlertAvailableFortheSymbol(symbols),
                  builder: (context, snapshot) =>  AppImages.addAlert(context),
                )),
          ),
        if (symbolType != AppConstants.indices)
          GestureDetector(
            onTap: () async {
              sendEventToFirebaseAnalytics(
                  AppEvents.quoteAddsymbol,
                  ScreenRoutes.quoteScreen,
                  'clicked Add symbol button in quotescreen',
                  key: "symbol",
                  value: symbols.dispSym);
              if (groupList!.isEmpty) {
                _showCreateNewBottomSheet(symbols);
              } else {
                _showWatchlistGroupBottomSheet(symbols);
              }
            },
            child: (AppUtils().getsymbolType(symbols) == AppConstants.fno &&
                        !AppStore().getFnoAvailability()) ||
                    ((AppUtils().getsymbolType(symbols) ==
                                AppConstants.currency ||
                            AppUtils().getsymbolType(symbols) ==
                                AppConstants.commodity) &&
                        !AppStore().getCurrencyAvailability())
                ? Container()
                : AppImages.addUnfilledIcon(
                    context,
                    color: AppColors().positiveColor,
                    isColor: true,
                    width: AppWidgetSize.dimen_25,
                    height: AppWidgetSize.dimen_25,
                  ),
          )
      ],
    );
  }

  Future<dynamic> alertDialog() {
    return showDialog(
        useSafeArea: true,
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            titlePadding: EdgeInsets.only(top: 20.w, left: 10.w, right: 10.w),
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: CustomTextWidget(
                        "Message notification is closed and new messages will not be received.",
                        Theme.of(context)
                            .primaryTextTheme
                            .titleSmall
                            ?.copyWith(fontSize: 19.w),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.w, bottom: 40.w),
                  child: CustomTextWidget(
                    "Receive news and activity in time",
                    Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: AppWidgetSize.fontSize17),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
            actionsPadding: EdgeInsets.zero,
            actionsOverflowDirection: VerticalDirection.up,
            actions: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  gradientButtonWidget(
                    height: 45.w,
                    onTap: () {
                      popNavigation();
                    },
                    bottom: 20.w,
                    width: AppWidgetSize.fullWidth(context) / 3,
                    key: const Key(""),
                    context: context,
                    title: AppLocalizations().cancel,
                    isGradient: false,
                  ),
                  gradientButtonWidget(
                    height: 45.w,
                    onTap: () async {
                      popNavigation();
                      await pushNavigation(
                        ScreenRoutes.createAlert,
                        arguments: {
                          'symbolItem': symbols,
                        },
                      );
                    },
                    width: AppWidgetSize.fullWidth(context) / 3,
                    key: const Key(""),
                    context: context,
                    bottom: 20.w,
                    title: "Enable Now",
                    isGradient: true,
                  )
                ],
              ),
            ],
          );
        });
  }

  Widget _buildExchangeToggleWidget() {
    return Padding(
        padding: EdgeInsets.only(right: AppWidgetSize.dimen_10),
        child: exchangeList!.length == 1
            ? _buildSingleExchangeWidget()
            : _buildListOfExchangeWidget());
  }

  Widget _buildSingleExchangeWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
      child: Container(
        height: AppWidgetSize.dimen_24,
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_2,
          right: AppWidgetSize.dimen_2,
        ),
        constraints: BoxConstraints(minWidth: AppWidgetSize.dimen_40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppWidgetSize.dimen_20),
            bottomLeft: Radius.circular(AppWidgetSize.dimen_20),
          ),
          color: Theme.of(context).primaryTextTheme.displayLarge!.color,
        ),
        alignment: Alignment.center,
        child: Row(
          children: <Widget>[
            Text(
              exchangeList![0],
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .primaryTextTheme
                  .bodyLarge!
                  .copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListOfExchangeWidget() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: AppWidgetSize.dimen_1,
        ),
        borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
      ),
      child: ToggleCircularWidget(
        key: const Key(quoteToggleWidgetKey),
        height: AppWidgetSize.dimen_20,
        minWidth: AppWidgetSize.dimen_35,
        cornerRadius: AppWidgetSize.dimen_20,
        activeBgColor: Theme.of(context).primaryTextTheme.displayLarge!.color,
        activeTextColor: Theme.of(context).colorScheme.secondary,
        inactiveBgColor: Theme.of(context).scaffoldBackgroundColor,
        inactiveTextColor:
            Theme.of(context).primaryTextTheme.displayLarge!.color,
        labels: exchangeList,
        initialLabel: selectedIndex,
        isBadgeWidget: false,
        activeTextStyle: Theme.of(context).primaryTextTheme.bodyLarge!,
        inactiveTextStyle: Theme.of(context).inputDecorationTheme.labelStyle!,
        onToggle: (int selectedToggleIndex) {
          sendEventToFirebaseAnalytics(
              AppEvents.quoteExchangeToggleclick,
              ScreenRoutes.quoteScreen,
              'clicked ${exchangeList?[selectedToggleIndex]} toggle in quotescreen',
              key: "symbol",
              value: symbols.dispSym);

          if (selectedIndex != selectedToggleIndex) {
            toggleExchangeTapAction(selectedToggleIndex);
          }
          selectedIndex = selectedToggleIndex;
        },
      ),
    );
  }

  Widget _buildPresistentFooterWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: AppWidgetSize.dimen_50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _getBottomButtonWidget(
            quoteBuyButtonKey,
            _appLocalizations.buy,
            AppColors().positiveColor,
            true,
          ),
          SizedBox(width: AppWidgetSize.dimen_32),
          _getBottomButtonWidget(
            quoteSellButtonKey,
            _appLocalizations.sell,
            AppColors.negativeColor,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return NestedScrollView(
      controller: _scrollControllerForTopContent,
      headerSliverBuilder: (BuildContext ctext, bool innerBoxIsScrolled) {
        return <Widget>[
          _buildSliverAppBar(
            ctext,
            AppWidgetSize.dimen_140,
          ),
        ];
      },
      body: _buildBodyBottomContent(),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    double height,
  ) {
    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverAppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        expandedHeight: height,
        pinned: false,
        backgroundColor: Colors.transparent,
        toolbarHeight: 0,
        flexibleSpace: SizedBox(
          child: FlexibleSpaceBar(
            background: _buildQuoteStreamingContent(false),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBarContent() {
    return Container(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_24,
        right: AppWidgetSize.dimen_30,
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomTextWidget(
                    (symbols.sym?.optionType != null)
                        ? '${symbols.baseSym} '
                        : AppUtils().dataNullCheck(symbols.dispSym),
                    Theme.of(context)
                        .primaryTextTheme
                        .labelSmall!
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 22.w),
                    textAlign: TextAlign.left),
                FandOTag(
                  symbols,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_5,
                bottom: AppWidgetSize.dimen_5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomTextWidget(
                        AppUtils().dataNullCheck(symbols.ltp),
                        Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppUtils().setcolorForChange(
                                  AppUtils().dataNullCheck(symbols.chng)),
                            ),
                        isShowShimmer: true,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: AppWidgetSize.dimen_5,
                          left: AppWidgetSize.dimen_5,
                        ),
                        child: CustomTextWidget(
                          AppUtils().getChangePercentage(symbols),
                          Theme.of(context)
                              .primaryTextTheme
                              .bodySmall!
                              .copyWith(
                                color: Theme.of(context)
                                    .inputDecorationTheme
                                    .labelStyle!
                                    .color,
                              ),
                          isShowShimmer: true,
                        ),
                      ),
                    ],
                  ),
                  _buildMarketStatusBloc(),
                ],
              ),
            ),
            CustomTextWidget(
              '${_appLocalizations.asOf} ${AppUtils().dataNullCheck(symbols.lTradedTime)}',
              Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                    color: Theme.of(context)
                        .inputDecorationTheme
                        .labelStyle!
                        .color,
                  ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_5,
                bottom: AppWidgetSize.dimen_5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildSectorNameWidget(),
                      Padding(
                        padding: EdgeInsets.only(
                          top: AppWidgetSize.dimen_3,
                        ),
                        child: CustomTextWidget(
                          '${AppUtils().dataNullCheck(symbols.vol)} ${_appLocalizations.vol}',
                          Theme.of(context)
                              .primaryTextTheme
                              .bodyLarge!
                              .copyWith(
                                color: Theme.of(context)
                                    .inputDecorationTheme
                                    .labelStyle!
                                    .color,
                              ),
                        ),
                      ),
                    ],
                  ),
                  if (Featureflag.isFnoSymbolsKeyCheck &&
                          AppUtils().getsymbolType(symbols) ==
                              AppConstants.equity
                      ? (symbols.isFno)
                      : AppUtils().getsymbolType(symbols) ==
                              AppConstants.indices
                          ? symbols.sym?.exc != AppConstants.bse
                          : true)
                    SizedBox(
                      width: AppWidgetSize.dimen_100,
                      child: LabelBorderWidget(
                        padding: EdgeInsets.all(AppWidgetSize.dimen_4),
                        keyText: const Key(quoteLabelKey),
                        text: _appLocalizations.optionChain,
                        textColor: Theme.of(context).primaryColor,
                        fontSize: AppWidgetSize.fontSize14,
                        margin: EdgeInsets.all(AppWidgetSize.dimen_1),
                        borderRadius: 20.w,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        borderWidth: 1,
                        borderColor: Theme.of(context).dividerColor,
                        isSelectable: true,
                        labelTapAction: optionChainTapAction,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketStatusBloc() {
    return BlocBuilder<MarketStatusBloc, MarketStatusState>(
      buildWhen: (MarketStatusState previous, MarketStatusState current) {
        return current is MarketStatusDoneState ||
            current is MarketStatusFailedState ||
            current is MarketStatusServiceExpectionState;
      },
      builder: (context, state) {
        if (state is MarketStatusDoneState) {
          return _buildMarketStatusWidget(state.isOpen);
        } else if (state is MarketStatusFailedState ||
            state is MarketStatusServiceExpectionState) {
          return Container();
        }
        return Container();
      },
    );
  }

  Widget _buildMarketStatusWidget(
    bool isOpen,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: AppWidgetSize.dimen_3,
            ),
            child: Container(
              width: AppWidgetSize.dimen_5,
              height: AppWidgetSize.dimen_5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.w),
                color: isOpen
                    ? AppColors().positiveColor
                    : AppColors.negativeColor,
              ),
            ),
          ),
          CustomTextWidget(
            isOpen ? _appLocalizations.live : _appLocalizations.closed,
            Theme.of(context)
                .primaryTextTheme
                .bodyLarge!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorNameWidget() {
    return BlocBuilder<QuoteBloc, QuoteState>(
        buildWhen: (QuoteState previous, QuoteState current) {
      return current is QuoteSectorDataState ||
          current is QuoteSectorFailedState;
    }, builder: (context, state) {
      if (state is QuoteSectorDataState) {
        if (state.sectorName.isNotEmpty) {
          double sectorLblWidth = state.sectorName == ''
              ? 5
              : state.sectorName.textSize(
                      state.sectorName,
                      Theme.of(context)
                          .inputDecorationTheme
                          .labelStyle!
                          .copyWith(
                            fontSize: AppWidgetSize.fontSize12,
                          )) +
                  15;
          if (sectorLblWidth >= 150) {
            sectorLblWidth = 140;
          }
          return Padding(
            padding: EdgeInsets.only(right: AppWidgetSize.dimen_5),
            child: Container(
              width: sectorLblWidth,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: LabelBorderWidget(
                keyText: const Key(quoteLabelKey),
                text: state.sectorName,
                textColor:
                    Theme.of(context).inputDecorationTheme.labelStyle!.color,
                fontSize: AppWidgetSize.fontSize12,
                margin: EdgeInsets.only(top: AppWidgetSize.dimen_1),
                borderRadius: AppWidgetSize.dimen_20,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                borderWidth: AppWidgetSize.dimen_1,
                borderColor: Theme.of(context).dividerColor,
              ),
            ),
          );
        } else {
          return Container();
        }
      } else if (state is QuoteSectorFailedState) {
        return Container();
      }
      return Container();
    });
  }

  Widget _buildBodyBottomContent() {
    return Column(
      children: [
        _buildTabListWidget(),
      ],
    );
  }

  Widget _buildTabListWidget() {
    return Expanded(
      child: DefaultTabController(
        key: Key(symbols.sym!.exc!),
        initialIndex: tabController?.index ?? 0,
        length: tabsHeaders.length,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            toolbarHeight: AppWidgetSize.dimen_40,
            automaticallyImplyLeading: false,
            elevation: 2,
            shadowColor: Theme.of(context).inputDecorationTheme.fillColor,
            flexibleSpace: Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.only(left: 20.w),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: TabBar(
                controller: tabController,
                key: const Key(quoteTabViewControllerKey),
                isScrollable: true,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorWeight: AppWidgetSize.dimen_2,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: Theme.of(context).primaryTextTheme.headlineMedium,
                labelColor:
                    Theme.of(context).primaryTextTheme.headlineMedium!.color,
                unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
                unselectedLabelColor:
                    Theme.of(context).textTheme.labelLarge!.color,
                tabs: tabsHeaders
                    .map((String item) => _buildTabBarTitleView(item))
                    .toList(),
              ),
            ),
          ),
          body: TabBarView(
            controller: tabController,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            children: tabsHeaders
                .map(
                  (String item) => _buildTabBarBodyView(item),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarTitleView(String item) {
    return Tab(
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              item,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarBodyView(String item) {
    return _getTabList()[item];
  }

  getTabHeaders() {
    return [
      _appLocalizations.quoteOverview,
      _appLocalizations.quoteChart,
      _appLocalizations.quoteFandO,
      _appLocalizations.quoteAnalysis,
      _appLocalizations.quoteFinancials,
      _appLocalizations.quoteDeals,
      _appLocalizations.quoteNews,
      _appLocalizations.quoteCorporateAction,
      _appLocalizations.quotePeers,
      _appLocalizations.contributor,
      _appLocalizations.constituents
    ];
  }

  Map<String, dynamic> _getTabList() {
    return {
      _appLocalizations.quoteOverview: getQuoteOverviewMultiBlocProvider(),
      _appLocalizations.quoteChart: QuoteChart(QuoteChartArgs(symbols)),
      _appLocalizations.quoteFandO: quoteFuturesOptionMultiBlocProvider(),
      _appLocalizations.quoteAnalysis: quoteAnalysisMultiBlocProvider(),
      _appLocalizations.quoteFinancials: quoteFinancialsMultiBlocProvider(),
      _appLocalizations.quoteDeals: quoteDealsMultiBlocProvider(),
      _appLocalizations.quoteNews: getQuoteNewsBlocProvider(),
      _appLocalizations.quoteCorporateAction:
          getQuoteCorporateActionBlocProvider(),
      _appLocalizations.quotePeers: getQuotePeersBlocProvider(),
      _appLocalizations.contributor: getQuoteContributorBlocProvider(),
      _appLocalizations.constituents: getQuoteConstituentsBlocProvider(),
    };
  }

  quoteFuturesOptionMultiBlocProvider() {
    return QuoteFutureOptions(
      arguments: {
        'symbolItem': symbols,
      },
    );
  }

  quoteAnalysisMultiBlocProvider() {
    return QuoteAnalysis(
      arguments: {
        'symbolItem': symbols,
      },
    );
  }

  quoteFinancialsMultiBlocProvider() {
    return QuoteFinancials(
      arguments: {
        'symbolItem': symbols,
      },
    );
  }

  quoteDealsMultiBlocProvider() {
    return QuoteDeals(
      arguments: {
        'symbolItem': symbols,
      },
    );
  }

  getQuoteOverviewMultiBlocProvider() {
    return QuoteOverview(
      arguments: {
        'symbolItem': symbols,
        'marketStatus': marketStatusBloc.marketStatusDoneState.isOpen,
      },
      onCallOrderPad: _onCallOrderPad,
      onViewMore: onViewMore,
    );
  }

  getQuoteContributorBlocProvider() {
    return QuoteContributor(
      symbols: symbols,
    );
  }

  getQuoteConstituentsBlocProvider() {
    return QuoteConstituents(
      arguments: {
        'symbolItem': symbols,
      },
    );
  }

  getQuoteNewsBlocProvider() {
    return QuoteNews(
      arguments: {
        'symbolItem': symbols,
      },
    );
  }

  getQuoteCorporateActionBlocProvider() {
    return QuoteCorporateAction(
      arguments: {
        'symbolItem': symbols,
      },
    );
  }

  getQuotePeersBlocProvider() {
    return QuotePeers(
      arguments: {
        'symbolItem': symbols,
        'context': context,
        'isFromOverview': false,
      },
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
        unsubscribeLevel1();
        if (header == _appLocalizations.buy) {
          sendEventToFirebaseAnalytics(AppEvents.quoteBuyclick,
              ScreenRoutes.quoteScreen, 'clicked Buy button in quotescreen',
              key: "symbol", value: symbols.dispSym);
          _onCallOrderPad(_appLocalizations.buy, "");
        } else {
          sendEventToFirebaseAnalytics(AppEvents.quoteSellclick,
              ScreenRoutes.quoteScreen, 'clicked Sell button in quotescreen',
              key: "symbol", value: symbols.dispSym);
          _onCallOrderPad(_appLocalizations.sell, "");
        }
      },
      child: Container(
        width: AppWidgetSize.dimen_130,
        height: AppWidgetSize.dimen_50,
        alignment: Alignment.center,
        // padding: EdgeInsets.all(AppWidgetSize.dimen_10),
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
              .copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> searchBlocListner(SearchState state) async {
    if (state is! SearchProgressState) {}
    if (state is SearchProgressState) {
    } else if (state is SymbolSearchDoneState) {
    } else if (state is SearchAddDoneState) {
      showToast(
        message: state.messageModel,
        context: context,
      );
      watchlistBloc.add(WatchlistGetGroupsEvent(false));

      setState(() {});
    } else if (state is SearchdeleteDoneState) {
      showToast(
        message: state.messageModel,
        context: context,
      );
      setState(() {});
    } else if (state is SearchAddSymbolFailedState ||
        state is SearchdeleteSymbolFailedState) {
      setState(() {});
      showToast(
        message: state.errorMsg,
        context: context,
        isError: true,
      );
    } else if (state is SearchSymStreamState) {
      subscribeLevel1(state.streamDetails);
    } else if (state is SearchFailedState) {
      showToast(
        message: state.errorMsg,
        context: context,
        isError: true,
      );
      setState(() {});
    }
  }

  void _showWatchlistGroupBottomSheet(Symbols symbolItem) {
    showInfoBottomsheet(
        ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(AppWidgetSize.dimen_20),
            ),
            child: BlocProvider<QuoteBloc>.value(
              value: quoteBloc,
              child: ChooseWatchlistWidget(
                arguments: {
                  "searchBloc": searchBloc,
                  'symbolItem': symbolItem,
                  'groupList': groupList,
                },
              ),
            )),
        bottomMargin: 0,
        topMargin: false,
        height: (AppUtils().chooseWatchlistHeight(groupList ?? []) <
                (AppWidgetSize.screenHeight(context) * 0.8))
            ? AppUtils().chooseWatchlistHeight(groupList ?? [])
            : (AppWidgetSize.screenHeight(context) * 0.8),
        horizontalMargin: false);
  }

  Future<void> _showCreateNewBottomSheet(Symbols symbolItem) async {
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
    );
  }

  int selectedIndex = 0;
  void toggleExchangeTapAction(int selectedToggleIndex) {
    quoteBloc.add(QuoteExcChangeEvent(
      exchangeList![selectedToggleIndex],
    ));
  }

  Future<void> optionChainTapAction() async {
    sendEventToFirebaseAnalytics(AppEvents.optionchainClick,
        ScreenRoutes.quoteScreen, 'clicked option chain in quote screen',
        key: "symbol", value: symbols.dispSym);
    unsubscribeLevel1();

    await pushNavigation(
      ScreenRoutes.quoteOptionChain,
      arguments: {'symbolItem': symbols, 'expiry': symbols.sym?.expiry},
    );
    setState(() {});
    callStreaming();
  }

  void onViewMore() {
    tabController?.animateTo(tabsHeaders.length - 1);
  }

  Future<void> _onCallOrderPad(String action, String? customPrice) async {
    await pushNavigation(
      ScreenRoutes.orderPadScreen,
      arguments: {
        'action': action,
        'symbolItem': symbols,
        'customPrice': customPrice ?? ""
      },
    );
    callStreaming();
  }
}
