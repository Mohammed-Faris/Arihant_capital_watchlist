import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../../blocs/markets/markets_bloc.dart';
import '../../../../config/app_config.dart';
import '../../../../constants/app_constants.dart';
import '../../../../constants/keys/watchlist_keys.dart';
import '../../../../data/store/app_helper.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../../models/config/config_model.dart';
import '../../../../models/sort_filter/sort_filter_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/error_image_widget.dart';
import '../../../widgets/loader_widget.dart';
import '../../../widgets/refresh_widget.dart';
import '../../../widgets/sort_filter_widget.dart';
import '../../../widgets/toggle_circular_widget.dart';
import '../../base/base_screen.dart';
import '../../watchlist/widget/watchlist_list_widget.dart';
import '../markets_screen.dart';

enum SelectedDropDown { marketMoversItems, marketMoversIndexFilter }

class MarketMoversDetailScreen extends BaseScreen {
  final dynamic arguments;
  final Function(String?)? onExchangechange;
  final Function(int?)? onindexChange;
  final bool showAppbar;

  const MarketMoversDetailScreen({
    Key? key,
    this.arguments,
    this.onExchangechange,
    this.onindexChange,
    this.showAppbar = true,
  }) : super(key: key);

  @override
  State<MarketMoversDetailScreen> createState() =>
      _MarketMoversDetailScreenState();
}

class _MarketMoversDetailScreenState
    extends BaseAuthScreenState<MarketMoversDetailScreen> {
  SortModel selectedSort = SortModel();
  late AppLocalizations _appLocalizations;
  MarketsBloc? marketsBloc;
  late List marketMoverTabKeys;
  late List marketMoverTabKeysFO;
  late List marketMoverIndexKeys;
  List? marketMoverIndexDisplayKeys;
  late List marketMoverTabDisplayKeys;
  ValueNotifier<int> selectionDropDownIndex = ValueNotifier<int>(0);

  late int selectedFilterIndex;
  late bool showMarketIndicesDetail;
  late bool showMarketMoversFODetails;
  late bool showMarketMoversCashDetails;
  late String selectedSegment;
  late String selectedExpiry;
  late String indexName;
  late List<NSE> nseItemsList;
  late List<BSE> bseItemsList;
  late List<String> exchangeArray;
  late List<Symbols> displayedSymbols;
  int selectedToggleIndex = 0;
  int selectedIndicestoggle = 0;
  late StateSetter sortStateSetter;
  late bool sortClearClicked = false;
  bool showAppbar = true;

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;

    if (showMarketMoversFODetails) {
      marketMoverTabDisplayKeys =
          AppUtils.marketMoverTabKeysDerivativesDisplayKeys;
    } else {
      marketMoverTabDisplayKeys = AppUtils.marketMoverTabKeysCashDisplayKeys;
    }

    return RefreshWidget(
      onRefresh: () async {
        // sortClearClicked = true;
        // selectedSort = SortModel();
        onDoneCallBack(
          selectedSort,
        );
        // sendMarketMoversDetailRequest();
      },
      child: Scaffold(
        appBar: widget.showAppbar ? _buildAppBar() : null,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              showMarketMoversCashDetails
                  ? _buildSegmentDropdownView()
                  : Container(),
              if (widget.arguments?['showMarketIndicesDetails'] ?? false)
                _buildSegmentToggleContent(),
              Expanded(child: _buildMarketsMoversBlocBuilder()),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      toolbarHeight: AppWidgetSize.dimen_70,
      elevation: 0,
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
      child: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_30,
        ),
        child: _getAppBarLeftContent(),
      ),
    );
  }

  @override
  void initState() {
    loaddata();
    isLoading.addListener(() {
      if (isScreenActive() && isLoading.value) {
        if (showMarketMoversFODetails) {
          sendMarketMoversRequestFO(selectedExpiry, selectedSegment,
              marketMoverTabKeys[selectionDropDownIndex.value]);
        } else {
          sendAllMarketMoversRequest(
              marketMoverTabKeys[selectionDropDownIndex.value],
              setDropDownListItemsBaseSym(
                  selectedToggleIndex)[selectedFilterIndex]);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    isLoading.removeListener(() {});
    super.dispose();
  }

  @override
  void didUpdateWidget(MarketMoversDetailScreen oldWidget) {
    // loaddata();

    super.didUpdateWidget(oldWidget);
  }

  void loaddata() {
    showMarketMoversCashDetails =
        widget.arguments['showMarketMoversCashDetails'] ?? false;
    showMarketMoversFODetails =
        widget.arguments['showMarketMoversFODetails'] ?? false;
    selectionDropDownIndex.value = widget.arguments['currentTabIndex'] ?? 0;
    showMarketIndicesDetail =
        widget.arguments['showMarketIndicesDetails'] ?? false;
    selectedSegment = widget.arguments['segment'] ?? "";
    selectedExpiry = widget.arguments['expiryDate'] ?? "";
    indexName = widget.arguments['indexName'] ?? "";
    showAppbar = widget.showAppbar;
    selectedToggleIndex = widget.arguments["selectedExchangeindex"] ?? 0;
    nseItemsList = AppConfig.indices?.nSE as List<NSE>;
    bseItemsList = AppConfig.indices?.bSE as List<BSE>;

    selectedFilterIndex = indexName == ""
        ? 0
        : setDropDownListItemsBaseSym(selectedToggleIndex).indexOf(indexName);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (AppConfig.indices?.bSE?.isNotEmpty ?? false) {
        BSE? sensex;
        try {
          sensex = AppConfig.indices?.bSE?.firstWhere(
              (element) => element.dispSym?.toLowerCase() == "sensex");
          if (sensex != null) {
            AppConfig.indices?.bSE?.removeWhere((element) => element == sensex);
            AppConfig.indices?.bSE?.insert(0, sensex);
            // ignore: empty_catches
          }
        } catch (e) {
          logError("Internal Error", "Sensex Not Found");
        }
      }
      setDropDownListItems(selectedToggleIndex);
      exchangeArray = [AppConstants.nse, AppConstants.bse];

      BlocProvider.of<MarketsBloc>(context)
          .stream
          .listen(marketsMoversDetailsBlocListener);
      if (widget.arguments['page'] != null &&
          widget.arguments['page'] == ScreenRoutes.searchScreen) {
        if (selectedSegment.isNotEmpty) {
          sendExpiryListRequest(selectedSegment);
          return;
        }
      }
      sendMarketMoversDetailRequest();
    });
  }

  void sendExpiryListRequest(String segment) {
    BlocProvider.of<MarketsBloc>(context).add(
        MarketMoversFOSendExpiryRequestEvent(
            exc: AppConstants.nfo, segment: segment));
  }

  void sendMarketMoversDetailRequest() {
    marketMoverIndexKeys = [
      "NIFTY",
      "Nifty Next 50",
      "NIFTY MIDCAP 100",
      "Nifty 100",
      "NIFTY SMLCAP 100"
    ];

    marketMoverIndexDisplayKeys = [];
    for (var displayName in marketMoverIndexKeys) {
      marketMoverIndexDisplayKeys!.add(
        AppUtils().getDisplayNameForItem(displayName, AppConstants.nse),
      );
    }

    if (showMarketIndicesDetail == true) {
      fetchMarketIndicesDetails(true, false);
    } else if ((indexName == AppConstants.indexNifty ||
            indexName == AppConstants.indexBankNifty) &&
        selectedSegment == "") {
      sendMarketMoversIndicesRequest(indexName);
    } else {
      if (showMarketMoversFODetails) {
        marketMoverTabKeys = AppUtils.marketMoverTabKeysDerivatives;
        selectionDropDownIndex.value = widget.arguments['currentTabIndex'] ?? 0;

        sendMarketMoversRequestFO(selectedExpiry, selectedSegment,
            marketMoverTabKeys[selectionDropDownIndex.value]);
      } else {
        marketMoverTabKeys = AppUtils.marketMoverTabKeysCash;
        if (selectedSegment != "") {
          selectionDropDownIndex.value =
              marketMoverTabKeys.indexOf(selectedSegment);
        }
        if (indexName != "") {
          selectedFilterIndex = setDropDownListItemsBaseSym(selectedToggleIndex)
              .indexOf(indexName);
        }

        sendAllMarketMoversRequest(
            marketMoverTabKeys[selectionDropDownIndex.value],
            setDropDownListItemsBaseSym(
                selectedToggleIndex)[selectedFilterIndex]);
      }
    }
  }

  @override
  String getScreenRoute() {
    return widget.arguments?['screenName'] != null
        ? ('${widget.arguments?['screenName']} ${selectionDropDownIndex.value.toString()}')
        : ScreenRoutes.marketMoversDetailsScreen;
  }

  List<String> setDropDownListItemsBaseSym(int selectedToggleIndex) {
    List<String> displayNameList = [];
    if (selectedToggleIndex == 0) {
      for (var i = 0; i < nseItemsList.length; i++) {
        displayNameList.add(nseItemsList[i].baseSym ?? "");
      }
    } else {
      for (var i = 0; i < bseItemsList.length; i++) {
        displayNameList.add(bseItemsList[i].baseSym!);
      }
    }

    return displayNameList;
  }

  List<String> setDropDownListItems(int selectedToggleIndex) {
    List<String> displayNameList = [];
    if (selectedToggleIndex == 0) {
      for (var i = 0; i < nseItemsList.length; i++) {
        displayNameList.add(nseItemsList[i].dispSym!);
      }
    } else {
      for (var i = 0; i < bseItemsList.length; i++) {
        displayNameList.add(bseItemsList[i].dispSym!);
      }
    }

    return displayNameList;
  }

  bool initialLoad = true;
  BlocBuilder _buildMarketsMoversBlocBuilder() {
    return BlocBuilder<MarketsBloc, MarketsState>(
        buildWhen: (previous, current) {
      return current is MarketMoversFetchItemsDoneState ||
          current is MarketsMoversFetchItemsProgressState && initialLoad ||
          (widget.arguments['screenName'] != ScreenRoutes.marketsFNOScreen &&
                  widget.arguments['screenName'] !=
                      ScreenRoutes.marketsCashScreen
              ? current is MarketsFetchItemsDoneState
              : false) ||
          current is MarketsFetchItemsProgressState ||
          current is MarketMoversFOFetchItemsDoneState ||
          current is MarketsMoversFOProgressState ||
          current is MarketMoversFOExpiryListResponseDoneState ||
          current is MarketMoversSortItemsDoneState ||
          current is MarketsServiceExpectionState ||
          current is MarketMoversIndicesFetchItemsDoneState ||
          current is MarketsFailedState;
    }, builder: (context, state) {
      if (state is MarketsFetchItemsProgressState ||
          state is MarketsMoversFOProgressState ||
          state is MarketMoversFOExpiryListResponseDoneState) {
        displayedSymbols = [];

        initialLoad = false;
        return const LoaderWidget();
      } else if (state is MarketsMoversFetchItemsProgressState) {
        displayedSymbols = [];

        initialLoad = false;
        return const LoaderWidget();
      } else if (state is MarketMoversFetchItemsDoneState &&
          (widget.arguments['screenName'] == ScreenRoutes.marketsFNOScreen ||
                  widget.arguments['screenName'] ==
                      ScreenRoutes.marketsCashScreen
              ? (state.marketMoversModel?.isMarketMoversG ?? false)
              : true)) {
        return _marketMoversContent(
            state.marketMoversModel?.marketMovers as List<Symbols>);
      } else if (state is MarketMoversSortItemsDoneState) {
        return _marketMoversContent(state.symbols as List<Symbols>);
      } else if (state is MarketMoversIndicesFetchItemsDoneState) {
        return _marketMoversContent(state.symbols as List<Symbols>);
      } else if (state is MarketsFetchItemsDoneState) {
        return _marketMoversContent(selectedIndicestoggle == 0
            ? state.nSE as List<Symbols>
            : state.bSE as List<Symbols>);
      } else if (state is MarketMoversFOFetchItemsDoneState) {
        return _marketMoversContent(
            state.marketMoversModel?.marketMovers as List<Symbols>);
      } else if (state is MarketsFailedState ||
          state is MarketsServiceExpectionState) {
        displayedSymbols = [];
        if (AppUtils.isMarketStartedAndNodataavailable()) {
          Future.delayed(const Duration(seconds: 30), () {
            if (mounted) {
              sendMarketMoversDetailRequest();
            }
          });
        }
        return _errorContent(state.errorMsg);
      }

      // return loaderWidget(context);
      return Container();
    });
  }

  Widget _buildFutureOptionsSegmentContent() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter updateState) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              height: AppWidgetSize.dimen_40,
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
                  height: AppWidgetSize.dimen_40,
                  minWidth: AppWidgetSize.dimen_80,
                  cornerRadius: AppWidgetSize.dimen_20,
                  activeBgColor:
                      Theme.of(context).primaryTextTheme.displayLarge!.color,
                  activeTextColor: Theme.of(context).colorScheme.secondary,
                  inactiveBgColor: Theme.of(context).scaffoldBackgroundColor,
                  inactiveTextColor:
                      Theme.of(context).primaryTextTheme.displayLarge!.color,
                  labels: <String>[
                    _appLocalizations.nse,
                    _appLocalizations.bse
                  ],
                  initialLabel: selectedToggleIndex,
                  isBadgeWidget: false,
                  activeTextStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontSize: AppWidgetSize.fontSize12),
                  inactiveTextStyle:
                      Theme.of(context).inputDecorationTheme.labelStyle!,
                  onToggle: (int selectedTabValue) {
                    selectedFilterIndex = 0;

                    selectedToggleIndex = selectedTabValue;

                    if (widget.onindexChange != null) {
                      widget.onindexChange!(selectedFilterIndex);
                    }

                    setState(() {});
                    sendAllMarketMoversRequest(
                        marketMoverTabKeys[selectionDropDownIndex.value],
                        setDropDownListItemsBaseSym(
                            selectedToggleIndex)[selectedFilterIndex]);
                    if (widget.onExchangechange != null) {
                      widget.onExchangechange!(selectedToggleIndex.toString());
                    }
                  },
                ),
              )),
        ],
      );
    });
  }

  Widget _buildSegmentToggleContent() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter updateState) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.only(right: 20.w),
              height: AppWidgetSize.dimen_40,
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
                  height: AppWidgetSize.dimen_40,
                  minWidth: AppWidgetSize.dimen_80,
                  cornerRadius: AppWidgetSize.dimen_20,
                  activeBgColor:
                      Theme.of(context).primaryTextTheme.displayLarge!.color,
                  activeTextColor: Theme.of(context).colorScheme.secondary,
                  inactiveBgColor: Theme.of(context).scaffoldBackgroundColor,
                  inactiveTextColor:
                      Theme.of(context).primaryTextTheme.displayLarge!.color,
                  labels: <String>[
                    _appLocalizations.nse,
                    _appLocalizations.bse
                  ],
                  initialLabel: selectedIndicestoggle,
                  isBadgeWidget: false,
                  activeTextStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontSize: AppWidgetSize.fontSize12),
                  inactiveTextStyle:
                      Theme.of(context).inputDecorationTheme.labelStyle!,
                  onToggle: (int selectedTabValue) {
                    selectedIndicestoggle = selectedTabValue;
                    fetchMarketIndicesDetails(
                        selectedTabValue == 0, selectedTabValue != 0);
                  },
                ),
              )),
        ],
      );
    });
  }

  Widget _buildSegmentDropdownView() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter updateState) {
      return Container(
        padding: EdgeInsets.only(left: 22.w, right: AppWidgetSize.dimen_16),
        width: AppWidgetSize.screenWidth(context),
        height: 50,

        // color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFutureOptionsSegmentContent(),
            ValueListenableBuilder<int>(
                valueListenable: selectionDropDownIndex,
                builder: (context, value, _) {
                  return (selectionDropDownIndex.value != 6 &&
                          selectionDropDownIndex.value != 2 &&
                          selectionDropDownIndex.value != 3 &&
                          selectionDropDownIndex.value != 7)
                      ? _buildMarketMoversIndicesWidget(setDropDownListItems(
                          selectedToggleIndex)[selectedFilterIndex])
                      : Container();
                })
          ],
        ),
      );
    });
  }

  final ScrollController scrollController = ScrollController();

  final ScrollController indicesscrollController =
      ScrollController(initialScrollOffset: 0);

  Widget _marketMoversContent(List<Symbols> suggestedStocks) {
    displayedSymbols = suggestedStocks;
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
      child: WatchlistListWidget(
          scrollController: scrollController,
          showNSETag: showMarketIndicesDetail ? false : true,
          disableSwipe: showMarketIndicesDetail ? true : false,
          symbolList: suggestedStocks,
          onRowClicked: _onRowClickedCallBack,
          refreshWatchlist: () {},
          isFromWatchlistScreen: false,
          isScroll: widget.showAppbar ? true : false),
    );
  }

  Widget _errorContent(String errorMessage) {
    return errorWithImageWidget(
      context: context,
      imageWidget: AppUtils().getNoDateImageErrorWidget(context),
      errorMessage: errorMessage,
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
        bottom: AppWidgetSize.dimen_30,
      ),
    );
  }

  Future<void> _onRowClickedCallBack(Symbols symbolItem) async {
    await pushNavigation(
      ScreenRoutes.quoteScreen,
      arguments: {
        'symbolItem': symbolItem,
        'shouldHideFooter': showMarketIndicesDetail ? true : false
      },
    );
    onDoneCallBack(
      selectedSort,
    );
  }

  void fetchMarketIndicesDetails(bool getNSE, bool getBSE) {
    BlocProvider.of<MarketsBloc>(context).add(
        FetchMarketIndicesItemsEvent(getNseItems: getNSE, getBseItems: getBSE));
  }

  void sendMarketMoversRequestFO(String expiry, String segment, sortBy) {
    selectedSort = SortModel();
    unsubscribeLevel1();
    BlocProvider.of<MarketsBloc>(context).add(
        MarketMoversFetchFOTopGainersLosersFetchEvent(
            segment: segment,
            fetchAllDetails: showAppbar ? true : false,
            sortBy: sortBy,
            asset: "equity",
            expiry: expiry,
            limit: 5));
  }

  void sendMarketMoversIndicesRequest(String indexName) {
    unsubscribeLevel1();
    BlocProvider.of<MarketsBloc>(context)
        .add(MarketsIndexConstituentsSymbolsEvent(indexName));
  }

  void sendAllMarketMoversRequest(String sortBy, String indexName) {
    selectedSort = SortModel();
    unsubscribeLevel1();
    BlocProvider.of<MarketsBloc>(context).add(
        MarketMoversFetchTopGainersLosersFetchEvent(
            exchange: exchangeArray[selectedToggleIndex],
            indexName: indexName,
            limit: 5,
            sortBy: sortBy,
            fetchAllDetails: showAppbar ? true : false));
  }

  Future<void> marketsMoversDetailsBlocListener(MarketsState state) async {
    if (state is MarketIndicesStartStreamState) {
      subscribeLevel1(state.streamDetails);
    } else if (state is MarketMoversStartStreamState) {
      subscribeLevel1(state.streamDetails);
    } else if (state is MarketMoversSortItemsDoneState) {
      selectedToggleIndex = selectedToggleIndex;
      unsubscribeLevel1();
      final List<String> streamingKeys = <String>[
        AppConstants.streamingLtp,
        AppConstants.streamingChng,
        AppConstants.streamingChgnPer
      ];
      subscribeLevel1(
        AppHelper().streamDetails(state.symbols, streamingKeys),
      );
    } else if (state is MarketMoversFOExpiryListResponseDoneState) {
      if (state.results!.isNotEmpty) {
        selectedExpiry = state.results![0];
        sendMarketMoversDetailRequest();
      }
    } else if (state is MarketsFailedState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state.isInvalidException) {
      handleError(state);
    }
  }

  @override
  void quote1responseCallback(ResponseData data) {
    if (showMarketIndicesDetail) {
      BlocProvider.of<MarketsBloc>(context)
          .add(MarketIndicesStreamingResponseEvent(data));
    } else {
      if (showMarketMoversFODetails) {
        BlocProvider.of<MarketsBloc>(context)
            .add(MarketMoversFOStreamingResponseEvent(data));
      } else {
        BlocProvider.of<MarketsBloc>(context)
            .add(MarketMoversStreamingResponseEvent(data));
      }
    }
  }

  void _buildMarketMoversDropDownItemsSheet(SelectedDropDown selectedDropDown) {
    showInfoBottomsheet(
      _buildBottomSheetContentWidget(selectedDropDown),
    );
  }

  _showBottomSheet(BuildContext ctx) {
    List items = setDropDownListItems(selectedToggleIndex);

    showInfoBottomsheet(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextWidget(
                    _appLocalizations.chooseIndex,
                    Theme.of(context).textTheme.displayMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: AppImages.closeIcon(context,
                        width: AppWidgetSize.dimen_25,
                        height: AppWidgetSize.dimen_25,
                        color: Theme.of(context).primaryIconTheme.color,
                        isColor: true),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                //itemExtent: items.length.toDouble(),

                cacheExtent: items.length.toDouble() * 100,
                controller: indicesscrollController,
                padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_1,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: false,
                itemCount: items.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  // return Container();

                  return Column(
                    children: [
                      _buildPredefinedWatchSymRowWidget(
                          setDropDownListItems(selectedToggleIndex),
                          index,
                          SelectedDropDown.marketMoversIndexFilter),
                      Padding(
                        padding: const EdgeInsets.symmetric(),
                        child: Divider(
                          thickness: AppWidgetSize.dimen_1,
                          color: Theme.of(context).dividerColor,
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        height: AppWidgetSize.screenHeight(context) * 0.5);
  }

  Widget _buildBottomSheetContentWidget(SelectedDropDown selectedDropDown) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                selectedDropDown == SelectedDropDown.marketMoversItems
                    ? _appLocalizations.marketMovers
                    : _appLocalizations.chooseIndex,
                Theme.of(context).textTheme.displayMedium,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: AppImages.closeIcon(context,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true),
              ),
            ],
          ),
        ),
        _buildMarketMoversSelectionWidget(selectedDropDown)
      ],
    );
  }

  getHeaderTextForDropDown(SelectedDropDown selectedDropDown) {
    if (selectedDropDown == SelectedDropDown.marketMoversItems) {
      return _appLocalizations.marketMovers;
    } else if (selectedDropDown == SelectedDropDown.marketMoversIndexFilter) {
      return _appLocalizations.chooseIndex;
    } else {
      return _appLocalizations.chooseIndex;
    }
  }

  getItemCountForDropDown(SelectedDropDown selectedDropDown) {
    if (selectedDropDown == SelectedDropDown.marketMoversItems) {
      return marketMoverTabKeys.length;
    } else if (selectedDropDown == SelectedDropDown.marketMoversIndexFilter) {
      return setDropDownListItems(selectedToggleIndex).length;
    } else {
      setDropDownListItems(selectedToggleIndex).length;
    }
  }

  final GlobalKey selectedIndex = GlobalKey();
  Widget _buildMarketMoversSelectionWidget(SelectedDropDown selectedDropDown) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: AppWidgetSize.screenHeight(context) * 0.6),
      child: ListView.separated(
        padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_1,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(),
            child: Divider(
              thickness: AppWidgetSize.dimen_1,
              color: Theme.of(context).dividerColor,
            ),
          );
        },
        itemCount: selectedDropDown == SelectedDropDown.marketMoversItems
            ? marketMoverTabKeys.length
            : setDropDownListItems(selectedToggleIndex).length,
        itemBuilder: (BuildContext ctxt, int index) {
          // return Container();

          return _buildPredefinedWatchSymRowWidget(
              selectedDropDown == SelectedDropDown.marketMoversItems
                  ? marketMoverTabDisplayKeys
                  : setDropDownListItems(selectedToggleIndex),
              index,
              selectedDropDown);
        },
      ),
    );
  }

  Widget _buildPredefinedWatchSymRowWidget(
      List marketMoverSelection, int index, SelectedDropDown selectedDropDown) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter updateState) {
      return GestureDetector(
        key: ((selectionDropDownIndex.value == index &&
                    selectedDropDown == SelectedDropDown.marketMoversItems) ||
                (selectedFilterIndex == index &&
                    selectedDropDown ==
                        SelectedDropDown.marketMoversIndexFilter))
            ? selectedIndex
            : null,
        onTap: () async {
          if (displayedSymbols.isNotEmpty) {
            scrollController.animateTo(5,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn);
          }
          // selectedWatchlist = predefinedWatch.baseSym;

          if (selectedDropDown == SelectedDropDown.marketMoversItems) {
            selectionDropDownIndex.value = index;
          } else {
            selectedFilterIndex = index;
          }
          if (showMarketMoversFODetails) {
            sendMarketMoversRequestFO(selectedExpiry, selectedSegment,
                marketMoverTabKeys[selectionDropDownIndex.value]);
          } else {
            sendAllMarketMoversRequest(
                marketMoverTabKeys[selectionDropDownIndex.value],
                setDropDownListItemsBaseSym(
                    selectedToggleIndex)[selectedFilterIndex]);
          }
          if (widget.onindexChange != null) {
            widget.onindexChange!(selectedFilterIndex);
          }

          setState(() {});

          Navigator.of(context).pop();

          // _onPredefinedWatchlistRowClick();
        },
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_10,
              bottom: AppWidgetSize.dimen_10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppWidgetSize.dimen_10,
                      ),
                      child: CustomTextWidget(
                        marketMoverSelection[index],
                        Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ),
                  ],
                ),
                if (selectionDropDownIndex.value == index &&
                    selectedDropDown == SelectedDropDown.marketMoversItems)
                  SizedBox(
                    child: AppImages.greenTickIcon(
                      context,
                      width: AppWidgetSize.dimen_22,
                      height: AppWidgetSize.dimen_22,
                    ),
                  )
                else if (selectedFilterIndex == index &&
                    selectedDropDown ==
                        SelectedDropDown.marketMoversIndexFilter)
                  SizedBox(
                    child: AppImages.greenTickIcon(
                      context,
                      width: AppWidgetSize.dimen_22,
                      height: AppWidgetSize.dimen_22,
                    ),
                  )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMarketMoversDropdownWidget(String title) {
    return Container(
      decoration: BoxDecoration(
        // border: Border(
        //   top: BorderSide(
        //       width: AppWidgetSize.dimen_1,
        //       color: Theme.of(context).dividerColor),
        // ),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: ClipRRect(
        child: Container(
          height: AppWidgetSize.dimen_70,
          margin: EdgeInsets.only(
            bottom: AppWidgetSize.dimen_3,
          ),
          padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_5,
            // right: AppWidgetSize.dimen_20,
            top: AppWidgetSize.dimen_10,
            bottom: AppWidgetSize.dimen_10,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            // boxShadow: [
            //   BoxShadow(
            //     color: Theme.of(context).dividerColor,
            //     offset: const Offset(0.0, 1.0),
            //     blurRadius: AppWidgetSize.dimen_2,
            //   ),
            // ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  _buildMarketMoversDropDownItemsSheet(
                      SelectedDropDown.marketMoversItems);
                },
                child: Container(
                  width: AppWidgetSize.fullWidth(context) / 1.6,
                  height: AppWidgetSize.dimen_70,
                  decoration: BoxDecoration(
                    color: Theme.of(context).snackBarTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppWidgetSize.dimen_12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: AppWidgetSize.dimen_14,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: AppWidgetSize.dimen_5,
                                top: AppWidgetSize.dimen_2,
                              ),
                              child: CustomTextWidget(
                                  title,
                                  Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                      )),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _buildMarketMoversDropDownItemsSheet(
                              SelectedDropDown.marketMoversItems);
                        },
                        child: Padding(
                          padding:
                              EdgeInsets.only(right: AppWidgetSize.dimen_8),
                          child: AppImages.viewWatchlistIcon(
                            context,
                            isColor: false,
                            width: AppWidgetSize.dimen_25,
                            height: AppWidgetSize.dimen_25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_10,
                      // right: AppWidgetSize.dimen_2,
                    ),
                    child: Container(
                      padding: EdgeInsets.only(
                        top: AppWidgetSize.dimen_5,
                      ),
                      margin: EdgeInsets.only(
                        top: AppWidgetSize.dimen_2,
                      ),
                      width: 1.5,
                      height: AppWidgetSize.dimen_22,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  _buildFilterIcon(title),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketMoversIndicesWidget(String title) {
    return GestureDetector(
      onTap: () async {
        await _showBottomSheet(context);
        Future.delayed(const Duration(milliseconds: 50), () {
          scrollToSelectedContent(expansionTileKey: selectedIndex);
        });
      },
      child: Container(
        width: AppWidgetSize.fullWidth(context) / 2.5,
        height: AppWidgetSize.dimen_40,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_5,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_5,
                    ),
                    child: CustomTextWidget(
                        title,
                        Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: AppWidgetSize.fontSize14)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: AppWidgetSize.dimen_5),
              child: GestureDetector(
                onTap: () {
                  // _buildMarketMoversDropDownItemsSheet(
                  //     SelectedDropDown.marketMoversIndexFilter);
                  _showBottomSheet(context);
                },
                child: AppImages.downArrow(
                  context,
                  isColor: true,
                  color: Theme.of(context).primaryIconTheme.color,
                  width: AppWidgetSize.dimen_25,
                  height: AppWidgetSize.dimen_25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sortSheet() async {
    sortClearClicked = false;
    showInfoBottomsheet(StatefulBuilder(
      builder: (BuildContext context, StateSetter updateState) {
        sortStateSetter = updateState;
        return SortFilterWidget(
          onCloseClickAction: false,
          screenName: ScreenRoutes.marketIndicesScreen,
          onDoneCallBack: (s, f) {
            onDoneCallBack(
              s,
            );
            updateState(() {});
          },
          onClearCallBack: () {
            onClearCallBack();
            updateState(() {});
          },
          selectedSort: selectedSort,
          selectedFilters: const [],
          isShowFilter: false,
        );
      },
    ), horizontalMargin: false);
  }

  void onDoneCallBack(
    SortModel selectedSortModel,
  ) {
    setState(() {});
    selectedSort = selectedSortModel;
    if (sortClearClicked == true &&
        !(selectedSort.sortName != null && selectedSort.sortName!.isNotEmpty) &&
        showMarketMoversCashDetails) {
      sendAllMarketMoversRequest(
          marketMoverTabKeys[selectionDropDownIndex.value],
          setDropDownListItemsBaseSym(
              selectedToggleIndex)[selectedFilterIndex]);
    } else if (sortClearClicked == true &&
        !(selectedSort.sortName != null && selectedSort.sortName!.isNotEmpty) &&
        showMarketMoversFODetails) {
      sendMarketMoversRequestFO(selectedExpiry, selectedSegment,
          marketMoverTabKeys[selectionDropDownIndex.value]);
    } else if (showMarketMoversCashDetails) {
      BlocProvider.of<MarketsBloc>(context).add(MarketsFilterSortSymbolEvent(
          selectedSort, displayedSymbols, false, false));
    } else if ((indexName == AppConstants.indexNifty ||
            indexName == AppConstants.indexBankNifty) &&
        selectedSegment == "") {
      BlocProvider.of<MarketsBloc>(context).add(MarketsFilterSortSymbolEvent(
          selectedSort, displayedSymbols, false, true));
    } else {
      BlocProvider.of<MarketsBloc>(context).add(MarketsFilterSortSymbolEvent(
          selectedSort, displayedSymbols, true, false));
    }
  }

  void onClearCallBack() {
    sortClearClicked = true;
    // selectedFilters = getFilterModel();
    setState(() {});
    sortClearClicked = true;
    selectedSort = SortModel();

    if (showMarketMoversCashDetails) {
      sendAllMarketMoversRequest(
          marketMoverTabKeys[selectionDropDownIndex.value],
          setDropDownListItemsBaseSym(
              selectedToggleIndex)[selectedFilterIndex]);
    } else if ((indexName == AppConstants.indexNifty ||
            indexName == AppConstants.indexBankNifty) &&
        selectedSegment == "") {
      sendMarketMoversIndicesRequest(indexName);
    } else {
      sendMarketMoversRequestFO(selectedExpiry, selectedSegment,
          marketMoverTabKeys[selectionDropDownIndex.value]);
    }
    unsubscribeLevel1();
    // Navigator.pop(context);
  }

  Widget _buildFilterIcon(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 10.w),
      child: Opacity(
        opacity: 1,
        child: InkWell(
            onTap: () {
              sortSheet();
            },
            child: AppUtils().buildFilterIcon(context,
                isSelected: selectedSort.sortName != null &&
                    selectedSort.sortName!.isNotEmpty)),
      ),
    );
  }

  Widget _getAppBarLeftContent() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              backIconButton(
                  onTap: () {
                    popNavigation();
                  },
                  customColor:
                      Theme.of(context).textTheme.displayMedium!.color),
              showMarketIndicesDetail ||
                      ((indexName == AppConstants.indexNifty ||
                              indexName == AppConstants.indexBankNifty) &&
                          selectedSegment == "")
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: AppWidgetSize.dimen_5,
                          ),
                          child: (indexName == AppConstants.indexNifty ||
                                      indexName ==
                                          AppConstants.indexBankNifty) &&
                                  !showMarketIndicesDetail
                              ? CustomTextWidget(
                                  AppUtils().getDisplayNameForItem(
                                      indexName, AppConstants.nse),
                                  Theme.of(context).textTheme.headlineMedium)
                              : CustomTextWidget(
                                  _appLocalizations.marketIndices,
                                  Theme.of(context).textTheme.headlineMedium),
                        ),
                      ],
                    )
                  : _buildMarketMoversDropdownWidget(
                      marketMoverTabDisplayKeys[selectionDropDownIndex.value]),
            ],
          ),
          ((indexName == AppConstants.indexNifty ||
                      indexName == AppConstants.indexBankNifty) &&
                  selectedSegment == "")
              ? _buildFilterIcon("")
              : const SizedBox(
                  height: 0,
                ),
        ],
      ),
    );
  }
}
