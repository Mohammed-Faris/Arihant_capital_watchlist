import 'package:acml/src/models/common/symbols_model.dart';
import 'package:acml/src/ui/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/streamer/stream/streaming_manager.dart';

import '../../../blocs/markets/markets_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../data/store/app_helper.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/sort_filter/sort_filter_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/refresh_widget.dart';
import '../../widgets/toggle_circular_widget.dart';
import '../base/base_screen.dart';
import '../watchlist/widget/watchlist_list_widget.dart';

enum SelectedDropDown { marketMoversItems, marketMoversIndexFilter }

class QuoteContributor extends BaseScreen {
  final Symbols? symbols;

  const QuoteContributor({
    Key? key,
    this.symbols,
  }) : super(key: key);

  @override
  State<QuoteContributor> createState() => _QuoteContributorState();
}

@override
String getScreenRoute() {
  return ScreenRoutes.marketMoversDetailsScreen;
}

class _QuoteContributorState extends BaseAuthScreenState<QuoteContributor> {
  SortModel selectedSort = SortModel();
  late Symbols symbols;
  late AppLocalizations _appLocalizations;
  MarketsBloc? marketsBloc;
  int selectedToggleIndex = 0;

  List<String> toggleKeys = [
    "topGainers",
    "topLosers",
  ];

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;

    return RefreshWidget(
      onRefresh: () async {},
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin:
                      EdgeInsets.symmetric(vertical: 10.w, horizontal: 20.w),
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
                      key: const Key(""),
                      height: AppWidgetSize.dimen_40,
                      minWidth: AppWidgetSize.dimen_80,
                      cornerRadius: AppWidgetSize.dimen_20,
                      activeBgColor: Theme.of(context)
                          .primaryTextTheme
                          .displayLarge!
                          .color,
                      activeTextColor: Theme.of(context).colorScheme.secondary,
                      inactiveBgColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      inactiveTextColor: Theme.of(context)
                          .primaryTextTheme
                          .displayLarge!
                          .color,
                      labels: const ["Top Gainers", "Top Losers"],
                      initialLabel: selectedToggleIndex,
                      isBadgeWidget: false,
                      activeTextStyle: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(fontSize: AppWidgetSize.fontSize14),
                      inactiveTextStyle:
                          Theme.of(context).inputDecorationTheme.labelStyle!,
                      onToggle: (int selectedTabValue) {
                        selectedToggleIndex = selectedTabValue;

                        sendAllMarketMoversRequest(
                            toggleKeys[selectedToggleIndex],
                            widget.symbols?.baseSym ?? "");
                        // print('selectedTab $selectedTabValue');
                      },
                    ),
                  )),
              Expanded(child: _buildMarketsMoversBlocBuilder()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      BlocProvider.of<MarketsBloc>(context)
          .stream
          .listen(marketsMoversDetailsBlocListener);

      sendAllMarketMoversRequest(
          toggleKeys[selectedToggleIndex], widget.symbols?.baseSym ?? "");
    });

    super.initState();
  }

  Future<void> marketsMoversDetailsBlocListener(MarketsState state) async {
    if (state is MarketIndicesStartStreamState) {
      subscribeLevel1(state.streamDetails);
    } else if (state is MarketMoversStartStreamState) {
      subscribeLevel1(state.streamDetails);
    } else if (state is MarketMoversSortItemsDoneState) {
      final List<String> streamingKeys = <String>[
        AppConstants.streamingLtp,
        AppConstants.streamingChng,
        AppConstants.streamingChgnPer
      ];
      subscribeLevel1(
        AppHelper().streamDetails(state.symbols, streamingKeys),
      );
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
    BlocProvider.of<MarketsBloc>(context)
        .add(MarketMoversStreamingResponseEvent(data));
  }

  void sendAllMarketMoversRequest(String sortBy, String indexName) {
    selectedSort = SortModel();
    StreamingManager()
        .unsubscribeLevel1(ScreenRoutes.marketMoversDetailsScreen);

    BlocProvider.of<MarketsBloc>(context).add(
        MarketMoversFetchTopGainersLosersFetchEvent(
            exchange: widget.symbols?.sym?.exc,
            indexName: indexName,
            limit: 5,
            sortBy: sortBy,
            fetchAllDetails: true));
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.marketMoversDetailsScreen;
  }

  bool initialLoad = true;
  BlocBuilder _buildMarketsMoversBlocBuilder() {
    return BlocBuilder<MarketsBloc, MarketsState>(
        buildWhen: (previous, current) {
      return current is MarketMoversFetchItemsDoneState ||
          current is MarketsMoversFetchItemsProgressState && initialLoad ||
          current is MarketsFetchItemsDoneState ||
          current is MarketsFetchItemsProgressState ||
          current is MarketMoversFOFetchItemsDoneState ||
          current is MarketsMoversFOProgressState ||
          current is MarketMoversSortItemsDoneState ||
          current is MarketsServiceExpectionState ||
          current is MarketMoversIndicesFetchItemsDoneState ||
          current is MarketsFailedState;
    }, builder: (context, state) {
      if (state is MarketsFetchItemsProgressState ||
          state is MarketsMoversFOProgressState) {
        initialLoad = false;
        return const LoaderWidget();
      } else if (state is MarketsMoversFetchItemsProgressState) {
        initialLoad = false;
        return const LoaderWidget();
      } else if (state is MarketMoversFetchItemsDoneState) {
        return _marketMoversContent(
            state.marketMoversModel?.marketMovers as List<Symbols>);
      } else if (state is MarketMoversSortItemsDoneState) {
        return _marketMoversContent(state.symbols as List<Symbols>);
      } else if (state is MarketMoversIndicesFetchItemsDoneState) {
        return _marketMoversContent(state.symbols as List<Symbols>);
      } else if (state is MarketsFetchItemsDoneState) {
        return _marketMoversContent(state.nSE as List<Symbols>);
      } else if (state is MarketMoversFOFetchItemsDoneState) {
        return _marketMoversContent(
            state.marketMoversModel?.marketMovers as List<Symbols>);
      } else if (state is MarketsFailedState ||
          state is MarketsServiceExpectionState) {
        return _errorContent(state.errorMsg);
      }

      // return loaderWidget(context);
      return Container();
    });
  }

  final ScrollController scrollController = ScrollController();

  final ScrollController indicesscrollController =
      ScrollController(initialScrollOffset: 0);

  Widget _marketMoversContent(List<Symbols> suggestedStocks) {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
      child: WatchlistListWidget(
        scrollController: scrollController,
        showNSETag: true,
        disableSwipe: false,
        symbolList: suggestedStocks,
        onRowClicked: _onRowClickedCallBack,
        refreshWatchlist: () {},
      ),
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
      arguments: {'symbolItem': symbolItem, 'shouldHideFooter': false},
    );
  }

  void fetchMarketIndicesDetails(bool getNSE, bool getBSE) {
    BlocProvider.of<MarketsBloc>(context).add(
        FetchMarketIndicesItemsEvent(getNseItems: getNSE, getBseItems: false));
  }

  void sendMarketMoversRequestFO(String expiry, String segment, sortBy) {
    selectedSort = SortModel();

    BlocProvider.of<MarketsBloc>(context).add(
        MarketMoversFetchFOTopGainersLosersFetchEvent(
            segment: segment,
            fetchAllDetails: true,
            sortBy: sortBy,
            asset: "equity",
            expiry: expiry,
            limit: 5));
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

  final GlobalKey selectedIndex = GlobalKey();
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
