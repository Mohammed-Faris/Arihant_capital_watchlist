import 'package:acml/src/ui/screens/markets/bulk_blockdeals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/markets/markets_bloc.dart';
import '../../../../config/app_config.dart';
import '../../../../constants/app_constants.dart';
import '../../../../constants/keys/watchlist_keys.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/config/config_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/loader_widget.dart';
import '../../../widgets/scrollable_toggle_widget.dart';
import '../../../widgets/toggle_circular_widget.dart';
import '../../base/base_screen.dart';
import '../markets_cash/market_indices_screen.dart';
import '../markets_cash/market_movers_detail.dart';
import '../markets_cash/markets_pcr_screen.dart';
import '../markets_cash/markets_rollover_screen.dart';
import '../markets_fii_dii_screen.dart';

class MarketsFNOScreen extends BaseScreen {
  final TabController tabControllerFno;
  const MarketsFNOScreen(
    this.tabControllerFno, {
    Key? key,
  }) : super(key: key);

  @override
  State<MarketsFNOScreen> createState() => _MarketsFNOScreenState();
}

class _MarketsFNOScreenState extends BaseAuthScreenState<MarketsFNOScreen>
    with TickerProviderStateMixin {
  final AppLocalizations _appLocalizations = AppLocalizations();
  late List marketMoverTabKeys;

  List<String>? expiryList;

  ValueNotifier<String> selectedExpiryDate = ValueNotifier<String>("");

  ValueNotifier<bool> isselected = ValueNotifier<bool>(true);

  ValueNotifier<int> selectedToggleIndex = ValueNotifier<int>(0);

  late MarketsBloc marketsBloc;
  String? selectedSegment;

  int selectedExchangeindex = 0;
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderWidget(_appLocalizations.marketIndices),
          const MarketIndicesScreen(arguments: {
            'screenName': AppConstants.fno,
          }),
          _buildViewMoreWidget(
              _appLocalizations.viewMore, ScreenRoutes.marketsFNOScreen),
          _buildMarketMoversHeaderWidget(_appLocalizations.marketMovers),
          SizedBox(
            height: AppWidgetSize.dimen_5,
          ),
          _buildTabListWidget(),
          SizedBox(
            height: AppWidgetSize.dimen_8,
          ),
          _buildHeaderWidget(_appLocalizations.fiiDiiActivity),
          MarketsFIIDII(MarketFiiDiiArguments(true)),
          Padding(
            padding: EdgeInsets.only(top: 10.w, bottom: 10.w),
            child: _buildViewMoreWidget(
                _appLocalizations.viewMore, ScreenRoutes.fiidiiScreen),
          ),
          _buildHeaderWidget(_appLocalizations.putCallRatio),
          BlocBuilder<MarketsBloc, MarketsState>(
              buildWhen: (previous, current) =>
                  current is MarketMoversFOExpiryListResponseDoneState,
              builder: (context, state) {
                return PutCallRationScreen(expiryListFno);
              }),
          _buildHeaderWidget(_appLocalizations.rollOver),
          MarketsRollOver(MarketsRollOverArgs(false, 0)),
        ],
      ),
    ));
  }

  List<String> expiryListFno = [];

  Future<void> marketMoversFNOBlocListener(MarketsState state) async {
    if (state is MarketsMoversFOProgressState) {
      // startLoader();
    } else if (state is MarketMoversFOExpiryListResponseDoneState) {
      if (state.results!.isNotEmpty) {
        expiryList = state.results!;
        if (selectedToggleIndex.value == 0) {
          expiryListFno = expiryList ?? [];
        }
        selectedExpiryDate.value = state.results![0];
        widget.tabControllerFno.animateTo(widget.tabControllerFno.index);
        marketsBloc.add(MarketFoScreenUpdate(
            selectedExpiryDate.value, selectedToggleIndex.value));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      }
    } else if (state is MarketMoversFOExpiryListResponseDoneDummyState) {
    } else if (state is MarketsFailedState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state.isInvalidException) {
      handleError(state);
    }
  }

  late List marketMoversFOSegmentKeys;
  late List<NSE> nseItemsList;
  late List<BSE> bseItemsList;

  @override
  void initState() {
    loadData();

    super.initState();
  }

  void loadData() {
    nseItemsList = AppConfig.indices?.nSE as List<NSE>;
    bseItemsList = AppConfig.indices?.bSE as List<BSE>;
    marketMoversFOSegmentKeys = ["stockFut", "stockOpt"];
    marketMoverTabKeys = AppUtils.marketMoverTabKeysDerivatives;

    marketsBloc = BlocProvider.of<MarketsBloc>(context)
      ..stream.listen(marketMoversFNOBlocListener);
    widget.tabControllerFno.animateTo(widget.tabControllerFno.index);
    sendExpiryListRequest(marketMoversFOSegmentKeys[0]);
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

  int getCurrentTabIndex() {
    return widget.tabControllerFno.index;
  }

  Widget _buildTabListWidget() {
    return Column(
      children: [
        selectedToggleIndex.value == 0
            ? Container()
            : _buildExpiryFilterWidget(),
        SizedBox(
          height: AppWidgetSize.dimen_500,
          child: DefaultTabController(
            // key: const Key("marketTab1"),

            length: widget.tabControllerFno.length,
            child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                appBar: AppBar(
                  toolbarHeight: AppWidgetSize.dimen_48,
                  automaticallyImplyLeading: false,
                  elevation: 2,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  centerTitle: false,
                  leading: const SizedBox.shrink(),
                  leadingWidth: 0,
                  shadowColor: Theme.of(context).inputDecorationTheme.fillColor,
                  title: TabBar(
                    padding: EdgeInsets.zero,
                    controller: widget.tabControllerFno,
                    key: const Key(marketsCashTabViewControllerKey),
                    isScrollable: true,
                    labelPadding: EdgeInsets.only(right: 12.w, left: 12.w),
                    indicatorPadding: EdgeInsets.only(right: 0.w, left: 0.w),
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorWeight: AppWidgetSize.dimen_2,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle:
                        Theme.of(context).primaryTextTheme.headlineMedium,
                    labelColor: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .color,
                    unselectedLabelStyle:
                        Theme.of(context).textTheme.labelLarge,
                    unselectedLabelColor:
                        Theme.of(context).textTheme.labelLarge!.color,
                    tabs: AppUtils.marketMoverTabKeysDerivativesDisplayKeys
                        .map((String item) => _buildTabBarTitleView(item))
                        .toList(),
                  ),
                ),
                body: BlocBuilder<MarketsBloc, MarketsState>(
                  buildWhen: (previous, current) =>
                      current is MarketMoverFOState ||
                      current is MarketMoverFOLoaderState,
                  builder: (context, state) {
                    if (state is! MarketMoverFOState) {
                      return const LoaderWidget();
                    }
                    return TabBarView(
                      controller: widget.tabControllerFno,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      children: List.generate(
                          marketMoverTabKeys.length,
                          (index) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 10.w),
                                      child: ValueListenableBuilder<int>(
                                          valueListenable: selectedToggleIndex,
                                          builder: (context, foToggle, _) {
                                            return ValueListenableBuilder<
                                                    String>(
                                                valueListenable:
                                                    selectedExpiryDate,
                                                builder:
                                                    (context, snapshot, _) {
                                                  return MarketMoversDetailScreen(
                                                    arguments: {
                                                      'currentTabIndex': index,
                                                      'expiryDate':
                                                          selectedExpiryDate
                                                              .value,
                                                      'segment':
                                                          marketMoversFOSegmentKeys[
                                                              selectedToggleIndex
                                                                  .value],
                                                      'showMarketIndicesDetails':
                                                          false,
                                                      'showMarketMoversCashDetails':
                                                          false,
                                                      'showMarketMoversFODetails':
                                                          true,
                                                      'screenName': ScreenRoutes
                                                          .marketsFNOScreen,
                                                    },
                                                    showAppbar: false,
                                                    onExchangechange: (value) {
                                                      selectedExchangeindex =
                                                          int.parse(
                                                              value ?? '0');
                                                    },
                                                    onindexChange: (value) {
                                                      selectedIndex =
                                                          value ?? 0;
                                                    },
                                                  );
                                                });
                                          }),
                                    ),
                                  ),
                                  _buildViewMoreWidget(
                                      _appLocalizations.viewMore,
                                      ScreenRoutes.marketMoversDetailsScreen)
                                ],
                              )).toList(),
                    );
                  },
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryFilterWidget() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter updateState) {
      return Padding(
        padding: EdgeInsets.only(
            right: AppWidgetSize.dimen_5,
            left: AppWidgetSize.dimen_15,
            bottom: AppWidgetSize.dimen_5),
        child: ScrollCircularButtonToggleWidget(
          value: selectedExpiryDate.value,
          toggleButtonlist: expiryList ?? [],
          toggleButtonOnChanged: (val) {
            selectedExpiryDate.value = val;

            isselected.value = true;

            updateState(() {});
            marketsBloc.add(MarketFoScreenUpdate(
                selectedExpiryDate.value, selectedToggleIndex.value));
          },

          //toggleButtonOnChanged,
          activeButtonColor:
              Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.5),
          activeTextColor: Theme.of(context).primaryColor,
          inactiveButtonColor: Colors.transparent,
          inactiveTextColor: Theme.of(context).primaryColor,
          key: const Key(""),
          defaultSelected: '',
          enabledButtonlist: const [],
          isBorder: false,
          context: context,
          borderColor: Colors.transparent,
        ),
      );
    });
  }

  Widget _buildHeaderWidget(String title) {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20,
          top: AppWidgetSize.dimen_8,
          right: AppWidgetSize.dimen_20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
            title,
            Theme.of(context).primaryTextTheme.titleSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildViewMoreWidget(
    String title,
    String navigationKey,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 5.w),
      child: GestureDetector(
        onTap: () {
          if (navigationKey == ScreenRoutes.marketMoversDetailsScreen) {
            moveToDetailsScreen();
          } else if (navigationKey == ScreenRoutes.fiidiiScreen) {
            pushNavigation(ScreenRoutes.fiidiiScreen,
                arguments: MarketFiiDiiArguments(true, isFullScreen: true));
          } else if (navigationKey == ScreenRoutes.marketsBulkandBlockDeal) {
            pushNavigation(ScreenRoutes.marketsBulkandBlockDeal,
                arguments: MarketsBulkAndBlockDealsArgs(isFullScreen: true));
          } else {
            moveToMarketIndicesDetailsScreen();
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_20, right: AppWidgetSize.dimen_20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomTextWidget(
                title,
                Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium
                    ?.copyWith(fontSize: AppWidgetSize.fontSize16),
              )
            ],
          ),
        ),
      ),
    );
  }

  void moveToMarketIndicesDetailsScreen() {
    pushNavigation(
      ScreenRoutes.marketMoversDetailsScreen,
      arguments: {
        'currentTabIndex': getCurrentTabIndex(),
        'showMarketIndicesDetails': true,
        'showMarketMoversFODetails': false,
        "indexName": "",
        'segment': marketMoversFOSegmentKeys[selectedToggleIndex.value],
      },
    );
  }

  void moveToDetailsScreen() {
    pushNavigation(
      ScreenRoutes.marketMoversDetailsScreen,
      arguments: {
        'currentTabIndex': getCurrentTabIndex(),
        'expiryDate': selectedExpiryDate.value,
        'segment': marketMoversFOSegmentKeys[selectedToggleIndex.value],
        'showMarketIndicesDetails': false,
        'showMarketMoversFODetails': true
      },
    );
  }

  Future<void> showMarketfandoInforBottomSheet() async {
    return showInfoBottomsheet(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  "Market Movers",
                  Theme.of(context).primaryTextTheme.titleMedium,
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
            Divider(
              thickness: 1,
              color: Theme.of(context).dividerColor,
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /* CustomTextWidget(
                "Market Movers section allows you to easily discover the stocks that are trending in the market.In the Market Movers snippet section, check out Top Gainers, Top Losers, 52W High & Low, Most Active stocks of the day of Nifty 50 index (by default). However, when you click on View More, you can choose the index whose market movers you want to see.\n\nYou can discover what is trending in these major categories by navigating the panel below.",
                Theme.of(context).primaryTextTheme.overline,
                textAlign: TextAlign.justify), */
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: AppWidgetSize.dimen_5,
                          top: AppWidgetSize.dimen_15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomTextWidget(
                            _appLocalizations.marketMoverfando,
                            Theme.of(context)
                                .primaryTextTheme
                                .labelSmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: AppWidgetSize.dimen_10,
                          bottom: AppWidgetSize.dimen_5),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text: _appLocalizations.marketsTopGainers,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            )
                          ])),
                    ),
                    CustomTextWidget(_appLocalizations.topgainerfandoInfo,
                        Theme.of(context).primaryTextTheme.labelSmall,
                        textAlign: TextAlign.justify),
                    Padding(
                      padding: EdgeInsets.only(
                          top: AppWidgetSize.dimen_10,
                          bottom: AppWidgetSize.dimen_5),
                      child: RichText(
                          text: TextSpan(children: [
                        TextSpan(
                          text: _appLocalizations.marketsTopLosers,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .copyWith(fontWeight: FontWeight.bold),
                        )
                      ])),
                    ),
                    CustomTextWidget(_appLocalizations.toploserfandoInfo,
                        Theme.of(context).primaryTextTheme.labelSmall,
                        textAlign: TextAlign.justify),
                    Padding(
                      padding: EdgeInsets.only(
                          top: AppWidgetSize.dimen_10,
                          bottom: AppWidgetSize.dimen_5),
                      child: RichText(
                          text: TextSpan(children: [
                        TextSpan(
                          text: _appLocalizations.mostActivefando,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .copyWith(fontWeight: FontWeight.bold),
                        )
                      ])),
                    ),
                    CustomTextWidget(_appLocalizations.mostActivefandoInfo,
                        Theme.of(context).primaryTextTheme.labelSmall,
                        textAlign: TextAlign.justify),
                    Padding(
                      padding: EdgeInsets.only(
                          top: AppWidgetSize.dimen_10,
                          bottom: AppWidgetSize.dimen_5),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text: _appLocalizations.protipCash,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: _appLocalizations.protipFandoinfo,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                          ])),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: AppWidgetSize.dimen_10,
                          bottom: AppWidgetSize.dimen_5),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            WidgetSpan(
                                child: Padding(
                              padding:
                                  EdgeInsets.only(right: AppWidgetSize.dimen_5),
                              child: AppImages.market_note(context,
                                  height: AppWidgetSize.dimen_20),
                            )),
                            TextSpan(
                              text: _appLocalizations.note,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: _appLocalizations.noteFandoinfo,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!,
                            )
                          ])),
                    ),
                  ]),
            ))
          ],
        ),
        height: 550.w);
  }

  Widget _buildMarketMoversHeaderWidget(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_20,
              right: AppWidgetSize.dimen_20,
              top: 4.w),
          child: Row(
            children: [
              CustomTextWidget(
                title,
                Theme.of(context).primaryTextTheme.titleSmall,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_4,
                  left: AppWidgetSize.dimen_5,
                ),
                child: GestureDetector(
                  onTap: () {
                    showMarketfandoInforBottomSheet();
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
          ),
        ),
        _buildFutureOptionsSegmentContent()
      ],
    );
  }

  Widget _buildFutureOptionsSegmentContent() {
    return Container(
      // height: AppWidgetSize.fullWidth(context),
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_30,
          right: AppWidgetSize.dimen_15,
          top: AppWidgetSize.dimen_8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              height: AppWidgetSize.dimen_24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppWidgetSize.dimen_2),
                child: ToggleCircularWidget(
                  key: const Key(marketsToggleWidgetKey),
                  height: AppWidgetSize.dimen_20,
                  minWidth: AppWidgetSize.dimen_40,
                  cornerRadius: AppWidgetSize.dimen_10,
                  activeBgColor:
                      Theme.of(context).primaryTextTheme.displayLarge!.color,
                  activeTextColor: Theme.of(context).colorScheme.secondary,
                  inactiveBgColor: Theme.of(context).scaffoldBackgroundColor,
                  inactiveTextColor:
                      Theme.of(context).primaryTextTheme.displayLarge!.color,
                  labels: <String>[
                    _appLocalizations.futures,
                    _appLocalizations.options
                  ],
                  initialLabel: selectedToggleIndex.value,
                  isBadgeWidget: false,
                  activeTextStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontSize: AppWidgetSize.fontSize12),
                  inactiveTextStyle:
                      Theme.of(context).inputDecorationTheme.labelStyle!,
                  onToggle: (int selectedTabValue) {
                    selectedToggleIndex.value = selectedTabValue;
                    selectedSegment =
                        marketMoversFOSegmentKeys[selectedToggleIndex.value];

                    sendExpiryListRequest(
                        marketMoversFOSegmentKeys[selectedToggleIndex.value]);
                    marketsBloc.add(MarketFoScreenUpdate(
                        selectedExpiryDate.value, selectedToggleIndex.value));
                    setState(() {});

                    // print('selectedTab $selectedTabValue');
                  },
                ),
              )),
        ],
      ),
    );
  }

  void sendExpiryListRequest(String segment) {
    BlocProvider.of<MarketsBloc>(context).add(
        MarketMoversFOSendExpiryRequestEvent(
            exc: AppConstants.nfo, segment: segment));
  }

  List<String> setDropDownListItemsBaseSym(int selectedToggleIndex) {
    List<String> displayNameList = [];
    if (selectedToggleIndex == 0) {
      for (var i = 0; i < nseItemsList.length; i++) {
        displayNameList.add(nseItemsList[i].baseSym!);
      }
    } else {
      for (var i = 0; i < bseItemsList.length; i++) {
        displayNameList.add(bseItemsList[i].baseSym!);
      }
    }

    return displayNameList;
  }
}
