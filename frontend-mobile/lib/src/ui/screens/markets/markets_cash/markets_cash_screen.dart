import 'package:acml/src/ui/screens/markets/bulk_blockdeals.dart';
import 'package:flutter/material.dart';

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
import '../../base/base_screen.dart';
import '../markets_fii_dii_screen.dart';
import 'market_indices_screen.dart';
import 'market_movers_detail.dart';

class MarketsCashScreen extends BaseScreen {
  const MarketsCashScreen(
    this.tabControllerCash, {
    Key? key,
  }) : super(key: key);
  final TabController tabControllerCash;
  @override
  State<MarketsCashScreen> createState() => _MarketsCashScreenState();
}

class _MarketsCashScreenState extends BaseAuthScreenState<MarketsCashScreen>
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
  int selectedbuilBlockindex = 0;
  int selectedbuilBlockSegmentindex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderWidget(_appLocalizations.marketIndices),
          const MarketIndicesScreen(arguments: {
            'screenName': AppConstants.cash,
          }),
          _buildViewMoreWidget(_appLocalizations.viewMore, ""),
          _buildMarketMoversHeaderWidget(_appLocalizations.marketMovers),
          SizedBox(
            height: AppWidgetSize.dimen_5,
          ),
          _buildTabListWidget(),
          SizedBox(
            height: AppWidgetSize.dimen_8,
          ),
          _buildHeaderWidget(_appLocalizations.fiiDiiActivity),
          MarketsFIIDII(MarketFiiDiiArguments(false)),
          Padding(
            padding: EdgeInsets.only(top: 10.w, bottom: 10.w),
            child: _buildViewMoreWidget(
                _appLocalizations.viewMore, ScreenRoutes.fiidiiScreen),
          ),
          Column(
            children: [
              _buildHeaderWidget(_appLocalizations.deals), //fix here
              MarketsBulkandBlock(
                MarketsBulkAndBlockDealsArgs(onToggle: (value) {
                  selectedbuilBlockindex = value;
                }, onSegmentToggle: (value) {
                  selectedbuilBlockSegmentindex = value;
                }),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.w, bottom: 10.w),
                child: _buildViewMoreWidget(_appLocalizations.viewMore,
                    ScreenRoutes.marketsBulkandBlockDeal),
              ),
            ],
          ),
         
        ],
      ),
    ));
  }

  late List marketMoversFOSegmentKeys;
  late List<NSE> nseItemsList;
  late List<BSE> bseItemsList;

  @override
  void initState() {
    widget.tabControllerCash.animateTo(widget.tabControllerCash.index);
    loadData();

    super.initState();
  }

  void loadData() {
    nseItemsList = AppConfig.indices?.nSE as List<NSE>;
    bseItemsList = AppConfig.indices?.bSE as List<BSE>;
    marketMoversFOSegmentKeys = ["stockFut", "stockOpt"];
    marketMoverTabKeys = AppUtils.marketMoverTabKeysCash;
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
    return widget.tabControllerCash.index;
  }

  Widget _buildTabListWidget() {
    return Column(
      children: [
        SizedBox(
          height: AppWidgetSize.dimen_550,
          child: DefaultTabController(
            // key: const Key("marketTab1"),
            initialIndex: widget.tabControllerCash.index,
            length: widget.tabControllerCash.length,
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
                    controller: widget.tabControllerCash,
                    key: const Key(marketsCashTabViewControllerKey),
                    isScrollable: true,
                    labelPadding: EdgeInsets.only(right: 15.w, left: 8.w),
                    indicatorPadding: EdgeInsets.only(right: 3.w, left: 0.w),
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
                    tabs: AppUtils.marketMoverTabKeysCashDisplayKeys
                        .map((String item) => _buildTabBarTitleView(item))
                        .toList(),
                  ),
                ),
                body: TabBarView(
                  controller: widget.tabControllerCash,
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
                                        return ValueListenableBuilder<String>(
                                            valueListenable: selectedExpiryDate,
                                            builder: (context, snapshot, _) {
                                              return MarketMoversDetailScreen(
                                                arguments: {
                                                  'currentTabIndex': index,
                                                  'segment':
                                                      marketMoverTabKeys[index],
                                                  'showMarketIndicesDetails':
                                                      false,
                                                  'showMarketMoversCashDetails':
                                                      true,
                                                  'showMarketMoversFODetails':
                                                      false,
                                                  'screenName': ScreenRoutes
                                                      .marketsCashScreen,
                                                  "indexName": selectedExchangeindex ==
                                                          0
                                                      ? (selectedIndex != null
                                                          ? setDropDownListItemsBaseSym(
                                                                  selectedExchangeindex)[
                                                              selectedIndex ??
                                                                  0]
                                                          : "NIFTY")
                                                      : "",
                                                  "selectedExchangeindex":
                                                      selectedExchangeindex,
                                                },
                                                showAppbar: false,
                                                onExchangechange: (value) {
                                                  selectedExchangeindex =
                                                      int.parse(value ?? '0');
                                                },
                                                onindexChange: (value) {
                                                  selectedIndex = value ?? 0;
                                                },
                                              );
                                            });
                                      }),
                                ),
                              ),
                              _buildViewMoreWidget(_appLocalizations.viewMore,
                                  ScreenRoutes.marketMoversDetailsScreen)
                            ],
                          )).toList(),
                )),
          ),
        ),
      ],
    );
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
                arguments: MarketFiiDiiArguments(false, isFullScreen: true));
          } else if (navigationKey == ScreenRoutes.marketsBulkandBlockDeal) {
            pushNavigation(ScreenRoutes.marketsBulkandBlockDeal,
                arguments: MarketsBulkAndBlockDealsArgs(
                    isFullScreen: true,
                    isBlock: selectedbuilBlockindex == 0 ? true : false,
                    isNse: selectedbuilBlockSegmentindex == 0));
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
        'showMarketMoversFODetails': false,
        'showMarketIndicesDetails': true,
        "indexName": selectedIndex != null
            ? setDropDownListItemsBaseSym(
                selectedExchangeindex)[selectedIndex ?? 0]
            : selectedExchangeindex == 0
                ? "NIFTY"
                : "SENSEX",
        "segment": marketMoverTabKeys[getCurrentTabIndex()],
        "selectedExchangeindex": selectedExchangeindex,
        "onIndexchange": selectedIndex
      },
    );
  }

  void moveToDetailsScreen() {
    pushNavigation(
      ScreenRoutes.marketMoversDetailsScreen,
      arguments: {
        'currentTabIndex': getCurrentTabIndex(),
        'showMarketIndicesDetails': false,
        'showMarketMoversFODetails': false,
        'showMarketMoversCashDetails': true,
        "indexName": selectedIndex != null
            ? setDropDownListItemsBaseSym(
                selectedExchangeindex)[selectedIndex ?? 0]
            : selectedExchangeindex == 0
                ? "NIFTY"
                : "SENSEX",
        "segment": marketMoverTabKeys[getCurrentTabIndex()],
        "selectedExchangeindex": selectedExchangeindex,
        "onIndexchange": selectedIndex
      },
    );
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
                    showMarketCashInforBottomSheet();
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
      ],
    );
  }

  Future<void> showMarketCashInforBottomSheet() async {
    return showInfoBottomsheet(Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextWidget(
              _appLocalizations.marketMovers,
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CustomTextWidget(_appLocalizations.marketMoversDesc,
                Theme.of(context).primaryTextTheme.labelSmall,
                textAlign: TextAlign.justify),
            Padding(
              padding: EdgeInsets.only(
                  bottom: AppWidgetSize.dimen_5, top: AppWidgetSize.dimen_15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    _appLocalizations.cashMarket,
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
                  top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_5),
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
            CustomTextWidget(
              _appLocalizations.topgainersCashinfo,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_5),
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
            CustomTextWidget(_appLocalizations.toplosersCashinfo,
                Theme.of(context).primaryTextTheme.labelSmall,
                textAlign: TextAlign.justify),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_5),
              child: RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: _appLocalizations.fiftytwoweekhigh,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(_appLocalizations.fiftytwoweekhighCashinfo,
                Theme.of(context).primaryTextTheme.labelSmall,
                textAlign: TextAlign.justify),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_5),
              child: RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: _appLocalizations.fiftytwoweeklow,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(_appLocalizations.fiftytwoweeklowCashinfo,
                Theme.of(context).primaryTextTheme.labelSmall,
                textAlign: TextAlign.justify),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_5),
              child: RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: _appLocalizations.mostactiveVolume,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(_appLocalizations.mostactiveVolumecashifo,
                Theme.of(context).primaryTextTheme.labelSmall,
                textAlign: TextAlign.justify),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_5),
              child: RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: _appLocalizations.mostactiveValue,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(_appLocalizations.mostactiveValuecashinfo,
                Theme.of(context).primaryTextTheme.labelSmall,
                textAlign: TextAlign.justify),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_5),
              child: RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: _appLocalizations.upperCircuit,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(_appLocalizations.upperCircuitCashinfo,
                Theme.of(context).primaryTextTheme.labelSmall,
                textAlign: TextAlign.justify),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_5),
              child: RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: _appLocalizations.lowerCircuit,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(_appLocalizations.lowerCircuitCashinfo,
                Theme.of(context).primaryTextTheme.labelSmall,
                textAlign: TextAlign.justify),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_5),
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
                      text: _appLocalizations.protipCashinfo,
                      style: Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ])),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_5),
              child: RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(children: [
                    WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          height: 20.w,
                          margin: EdgeInsets.only(bottom: 1.w),
                          child: AppImages.market_note(context),
                        )),
                    TextSpan(
                      text: _appLocalizations.note,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: _appLocalizations.noteCashinfo,
                      style: Theme.of(context).primaryTextTheme.labelSmall!,
                    )
                  ])),
            ),
          ]),
        ))
      ],
    ));
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
