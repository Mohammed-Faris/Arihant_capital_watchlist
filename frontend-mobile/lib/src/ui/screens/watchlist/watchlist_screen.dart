import 'package:acml/src/blocs/common/screen_state.dart';
import 'package:acml/src/constants/app_events.dart';
import 'package:acml/src/ui/widgets/market_indices_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/service_exception.dart';
import 'package:msil_library/utils/lib_store.dart';
import 'package:permission_handler/permission_handler.dart';

// import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../blocs/holdings/holdings/holdings_bloc.dart';
import '../../../blocs/indices/indices_bloc.dart';
import '../../../blocs/my_accounts/client_details/clientdetails_bloc.dart';
import '../../../blocs/pcr/put_call_ratio_bloc.dart';
import '../../../blocs/quote/deals/deals_bloc.dart';
import '../../../blocs/watchlist/watchlist_bloc.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/keys/watchlist_keys.dart';
import '../../../data/repository/my_account/my_account_repository.dart';
import '../../../data/repository/order/order_repository.dart';
import '../../../data/store/app_storage.dart';
import '../../../data/store/app_store.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/config/config_model.dart';
import '../../../models/sort_filter/sort_filter_model.dart';
import '../../../models/watchlist/watchlist_group_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/build_empty_widget.dart';
import '../../widgets/create_new_watchlist.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/refresh_widget.dart';
import '../../widgets/sort_filter_widget.dart';
import '../../widgets/toggle_circular_tabs_widget.dart';
import '../../widgets/webview_widget.dart';
import '../base/base_screen.dart';
import '../markets/markets_screen.dart';
import '../route_generator.dart';
import 'widget/watchlist_list_widget.dart';

class WatchlistScreen extends BaseScreen {
  const WatchlistScreen({Key? key}) : super(key: key);

  @override
  WatchlistScreenState createState() => WatchlistScreenState();
}

class WatchlistScreenState extends BaseAuthScreenState<WatchlistScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollControllerForTopContent = ScrollController();
  late AppLocalizations _appLocalizations;
  late HoldingsBloc holdingsBloc;
  late WatchlistBloc watchlistBloc;

  late IndicesBloc indicesBloc;
  List<String> toggleList = <String>[
    AppLocalizations().watchlist,
    AppLocalizations().markets,
  ];
  int selectedToggleIndex = 0;
  String activeTab = AppConstants.tab1;
  late String activeTitle;
  List<String> myWatchlistList = <String>[];
  final ValueNotifier<String> selectedWatchlist =
      ValueNotifier<String>(AppLocalizations().myStocks);

  Groups? selectedWatchlistGroup;
  bool isSortTab = true;
  int sortIndexSelected = -1;
  int symbolsCount = 0;
  List<FilterModel> selectedFilters = <FilterModel>[];
  bool isNewWatchlist = false;
  List<Widget> watchlistIcons = <Widget>[];
  List<Widget> predefinedWatchlistIcons = <Widget>[];
  double? topSheetHeight;

  SortModel selectedSort = SortModel();
  // late TutorialCoachMark tutorialCoachMark;
  // List<TargetFocus> targets = <TargetFocus>[];
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    logError("SessionID ", LibStore().getSessionCookie());
    super.initState();
    fetchData();
  }

  void fetchData() {
    if (Featureflag.fetchOrderfromSocket) {
      OrderRepository().connectOrdersocket();
    }

    tabController = TabController(
        length: 2, initialIndex: selectedToggleIndex, vsync: this);
    tabController?.addListener(() {
      selectedIndex.value = tabController?.index ?? 0;

      if (selectedIndex.value == 0) {
        refreshWatchlist();
      } else if (selectedIndex.value == 1) {
        unsubScribeLevel1quotes();
      }
    });
    fetchAccountInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedFilters = getFilterModel();
      watchlistBloc = BlocProvider.of<WatchlistBloc>(context)
        ..add(GetCorpSymListEvent())
        ..stream.listen(watchlistListener);
      holdingsBloc = BlocProvider.of<HoldingsBloc>(context)
        ..stream.listen(holdingsListener);
      indicesBloc = BlocProvider.of<IndicesBloc>(context)
        ..stream.listen(indicesListener);
      watchlistBloc.add(WatchlistGetGroupsEvent(true));
      watchlistBloc = BlocProvider.of<WatchlistBloc>(context)
        ..stream.listen((event) {
          if (event is WatchlistGetGroupsDone && isScreenCurrent()) {
            getselectedWatchList();
          }
        });
      BlocProvider.of<ClientdetailsBloc>(context).add(
        ClientdetailsFetchEvent(load: false),
      );

      setupPredefinedWatchlistIcons();
    });

    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.watchlistScreen);
    if (AppStore().isPushClicked()) {
      Future.delayed(const Duration(milliseconds: 100), () async {
        await pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen, arguments: {
          'pageName': ScreenRoutes.myAccount,
        });
      });
    }
  }

  Widget buildSubCampaign() {
    return ValueListenableBuilder(
        valueListenable: AppStore.isNomineeAvailable,
        builder: (context, value, _) {
          return ((!AppStore.isNomineeAvailable.value &&
                  Featureflag.nomineeCampaign))
              ? GestureDetector(
                  onTap: () {
                    pushNavigation(ScreenRoutes.nomineeCampagin);
                  },
                  child: Container(
                    height: 75.w,
                    color: Theme.of(context).snackBarTheme.backgroundColor,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: AppWidgetSize.dimen_10,
                        right: AppWidgetSize.dimen_10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppImages.bankNotificationBadgelogo(context,
                                    isColor: true),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 15.w,
                                left: 15.w,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add nominee details before ${Featureflag.campaignEndDate}, 2023",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                    textAlign: TextAlign.justify,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "to keep demat account active",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        textAlign: TextAlign.justify,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5.w),
                                        child: gradientButtonWidget(
                                            onTap: () async {
                                              startLoader();

                                              try {
                                                String? ssoUrl =
                                                    await MyAccountRepository()
                                                        .getNomineeUrl(
                                                            "nominee-details");
                                                stopLoader();
                                                await Permission.microphone
                                                    .request();
                                                await Permission.camera
                                                    .request();
                                                await Permission.location
                                                    .request();
                                                await Permission
                                                    .locationWhenInUse
                                                    .request();
                                                await Permission
                                                    .accessMediaLocation
                                                    .request();
                                                if (mounted) {
                                                  Navigator.push(
                                                    context,
                                                    SlideRoute(
                                                        settings:
                                                            const RouteSettings(
                                                          name: ScreenRoutes
                                                              .inAppWebview,
                                                        ),
                                                        builder: (BuildContext
                                                                context) =>
                                                            WebviewWidget(
                                                                "Add Nominee",
                                                                ssoUrl)),
                                                  );
                                                }
                                              } on ServiceException catch (ex) {
                                                stopLoader();
                                                handleError(ScreenState()
                                                  ..errorCode = ex.code
                                                  ..errorMsg = ex.msg);
                                              } catch (e) {
                                                stopLoader();
                                              }
                                            },
                                            width: 80.w,
                                            height: 25.w,
                                            fontsize: 14.w,
                                            bottom: 0,
                                            key: const Key("gradientButton"),
                                            context: context,
                                            title: "Add Now",
                                            isGradient: true),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container();
        });
  }

  GlobalKey keyButton = GlobalKey();
  GlobalKey keyButton1 = GlobalKey();

  List<FilterModel> getFilterModel() {
    return [
      FilterModel(
        filterName: AppConstants.segment,
        filters: [],
        filtersList: [],
      ),
      FilterModel(
        filterName: AppConstants.moreFilters,
        filters: [],
        filtersList: [],
      ),
    ];
  }

  Future<void> getselectedWatchList() async {
    var accDetails = await AppStorage().getData("userLoginDetailsKey");
    var data = await AppStorage().getData("selcetedWatchlist");

    if (data != null &&
        (watchlistBloc.watchlistDoneState.watchlistGroupModel?.groups
                ?.where((element) => element.wName == data["selcetedWatchlist"])
                .isNotEmpty ??
            false) &&
        data["accName"] == accDetails["accName"]) {
      selectedWatchlist.value = data["selcetedWatchlist"];
      selectedWatchlistGroup = watchlistBloc
          .watchlistDoneState.watchlistGroupModel?.groups!
          .firstWhere((element) => element.wName == selectedWatchlist.value);
      watchlistBloc.add(SelectedWatchlistAndTabEvent(
          selectedWatchlist.value, AppConstants.tab1));
      if (selectedWatchlistGroup != null) {
        watchlistBloc
            .add(WatchlistGetSymbolsEvent(selectedWatchlistGroup!, true, true));
      }
    } else {
      selectedWatchlist.value = _appLocalizations.myStocks;
      holdingsBloc.add(HoldingsFetchEvent(true, isFetchAgain: false));
    }
  }

  void callHoldingsApi() {
    holdingsBloc.add(HoldingsFetchEvent(
        selectedWatchlist.value == _appLocalizations.myStocks,
        isStreaming: selectedWatchlist.value == _appLocalizations.myStocks));
  }

  void setupWatchlistIcons() {
    watchlistIcons = AppUtils().getWatchlistIcons(
      context,
      myWatchlistList.length,
    );
  }

  void setupPredefinedWatchlistIcons() {
    predefinedWatchlistIcons = [
      AppImages.sensexIcon(context, height: AppWidgetSize.fontSize22),
      AppImages.niftyFiftyIcon(context, height: AppWidgetSize.fontSize22),
      AppImages.bankNiftyIcon(context, height: AppWidgetSize.fontSize22),
      AppImages.niftyMidcapIcon(context, height: AppWidgetSize.fontSize22),
      //AppImages.sensexIcon(context),
      AppImages.itServicesIcon(context, height: AppWidgetSize.fontSize22),
      AppImages.financeIcon(context, height: AppWidgetSize.fontSize22),
      AppImages.pharmaIcon(context, height: AppWidgetSize.fontSize22),
      AppImages.metalIcon(context, height: AppWidgetSize.fontSize22),
      AppImages.fmcgIcon(context, height: AppWidgetSize.fontSize22),
      AppImages.automobileIcon(context, height: AppWidgetSize.fontSize22),
      AppImages.psuIcon(context, height: AppWidgetSize.fontSize22),
      AppImages.niftyIcon(context, height: AppWidgetSize.fontSize22),
    ];
  }

  Map<dynamic, dynamic>? streamDetails;

  Future<void> holdingsListener(HoldingsState state) async {
    if (state is HoldingsFetchDoneState) {
    } else if (state is SuggestedStocksState) {
      selectedWatchlist.value = _appLocalizations.myStocks;
    } else if (state is SuggestedStocksStartStreamState) {
      streamDetails = state.streamDetails;

      subscribeLevel1(state.streamDetails);
    } else if (state is HoldingsStartStreamState) {
      watchlistBloc.add(WatchlistSetMyHoldingsSymbolsEvent(
          holdingsBloc.holdingsFetchDoneState.holdingsModel!.holdings!));
      streamDetails = state.streamDetails;

      subscribeLevel1(state.streamDetails);
    } else if (state is HoldingsErrorState) {
      handleError(state);
    }
  }

  bool loadHoldingsfirst = true;
  int watchListCount = 0;
  Future<void> watchlistListener(WatchlistState state) async {
    if (state is WatchlistGetGroupsState) {
      watchlistBloc.add(WatchlistGetSymbolsForAllWatchlistEvent());
    } else if (state is WatchlistAllSymsDoneState) {
    } else if (state is WatchlistDoneState) {
      if (state.selectedTab == AppConstants.tab1) {
        selectedWatchlist.value = state.selectedWatchlist;
      } else if (state.selectedTab == AppConstants.tab2) {
        selectedWatchlist.value = state.selectedWatchlist;
      }
      if (state.watchlistGroupModel != null) {
        state.watchlistGroupModel!.groups!;
        myWatchlistList = [];
        watchListCount = state.watchlistGroupModel!.groups!
            .where((element) => element.editable ?? false)
            .toList()
            .length;
        myWatchlistList.add(_appLocalizations.myStocks);
        for (Groups element in state.watchlistGroupModel!.groups!) {
          if (!(myWatchlistList.contains(element.wName))) {
            myWatchlistList.add(element.wName!);
          }
        }
      }
      setupWatchlistIcons();
    } else if (state is WatchlistSymStreamState) {
      streamDetails = state.streamDetails;

      subscribeLevel1(state.streamDetails);
      if (loadHoldingsfirst) {
        loadHoldingsfirst = false;
        callHoldingsApi();
      }
    } else if (state is WatchlistErrorState) {
      handleError(state);
    }
  }

  Future<void> indicesListener(IndicesState state) async {
    if (state is IndexConstituentsSymStreamState) {
      streamDetails = state.streamDetails;

      subscribeLevel1(state.streamDetails);
    } else if (state is IndexConstituentsDoneState) {
    } else if (state is IndicesErrorState) {
      handleError(state);
    }
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.watchlistScreen;
  }

  @override
  void quote1responseCallback(ResponseData data) {
    if (selectedWatchlist.value == _appLocalizations.myStocks &&
        watchlistBloc.watchlistDoneState.selectedTab == AppConstants.tab1) {
      symbolsCount == 0
          ? holdingsBloc.add(SuggestedStocksStreamingResponseEvent(data))
          : holdingsBloc.add(HoldingsStreamingResponseEvent(data));
    } else if (watchlistBloc.watchlistDoneState.selectedTab ==
        AppConstants.tab1) {
      watchlistBloc.add(WatchlistStreamingResponseEvent(data));
    } else {
      indicesBloc.add(IndexConstituentsStreamingResponseEvent(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;

    return SafeArea(
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    return NestedScrollView(
      controller: _scrollControllerForTopContent,
      headerSliverBuilder: (BuildContext ctext, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctext),
              sliver: SliverAppBar(
                titleSpacing: 0,
                automaticallyImplyLeading: false,
                expandedHeight: AppWidgetSize.getSize(66.w),
                pinned: false,
                centerTitle: false,
                forceElevated: innerBoxIsScrolled,
                backgroundColor: Colors.transparent,
                toolbarHeight: 0,
                flexibleSpace: SizedBox(
                  height: 80.w,
                  child: _buildTopAppBarContent(),
                ),
              ))
        ];
      },
      body: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  width: AppWidgetSize.dimen_1,
                  color: Theme.of(context).dividerColor),
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: returnToggleContent()),
    );
  }

  Widget returnToggleContent() {
    return TabBarView(
      controller: tabController,
      children: [
        RefreshWidget(
          onRefresh: () async {
            refreshWatchlist(fetchApi: true);
          },
          child: _buildBottomContent(),
        ),
        MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => QuotesDealsBloc(),
            ),
            BlocProvider(
              create: (context) => PutCallRatioBloc(),
            )
          ],
          child: const MarketsScreen(),
        )
      ],
    );
  }

  void unSubscribeMarketsStreaming() {
    unsubscribeLevel1();
  }

  TabController? tabController;

  Widget _buildTopAppBarContent() {
    return Container(
      height: AppWidgetSize.fullWidth(context),
      padding: EdgeInsets.only(
        left: 30.w,
        right: AppWidgetSize.dimen_25,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              SizedBox(
                width: AppWidgetSize.screenWidth(context) * 0.45,
                child: ToggleCircularTabsWidget(
                  tabController: tabController!,
                  key: const Key(watchlistToggleWidgetKey),
                  height: AppWidgetSize.dimen_80,
                  minWidth: AppWidgetSize.dimen_1,
                  cornerRadius: AppWidgetSize.dimen_20,
                  labels: toggleList,
                  initialLabel: selectedToggleIndex,
                  onToggle: (int selectedTabValue) {
                    selectedToggleIndex = selectedTabValue;
                    tabController!.animateTo(selectedToggleIndex);
                  },
                ),
              ),
              ValueListenableBuilder<int>(
                  valueListenable: selectedIndex,
                  builder: (context, value, _) {
                    return value == 0
                        ? Padding(
                            padding: EdgeInsets.only(left: 10.w),
                            child: GestureDetector(
                                onTap: () {
                                  sendEventToFirebaseAnalytics(
                                    AppEvents.watchlistInfo,
                                    ScreenRoutes.watchlistScreen,
                                    'Watchlist info icon is selected and will show information bottomsheet',
                                  );
                                  showWatchlistInforBottomSheet();
                                },
                                child: Padding(
                                    padding: EdgeInsets.only(left: 10.w),
                                    child: AppImages.infoIcon(
                                      context,
                                      width: AppWidgetSize.fontSize22,
                                      height: AppWidgetSize.fontSize22,
                                      color: Theme.of(context)
                                          .primaryIconTheme
                                          .color,
                                      isColor: true,
                                    ))),
                          )
                        : Container();
                  })
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const MarketIndicesTopWidget(),
                SizedBox(
                  width: 16.w,
                ),
                GestureDetector(
                  onTap: () async {
                    sendEventToFirebaseAnalytics(
                      AppEvents.watchlistSearch,
                      ScreenRoutes.watchlistScreen,
                      'Search icon is selected and will move to Search screen',
                    );
                    _onClickSearch();
                  },
                  child: AppImages.addUnfilledIcon(
                    context,
                    color: AppColors().positiveColor,
                    isColor: true,
                    width: AppWidgetSize.dimen_25,
                    height: AppWidgetSize.dimen_25,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomContent() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      width: MediaQuery.of(context).size.width,
      child: ValueListenableBuilder<String>(
        valueListenable: selectedWatchlist,
        builder: (context, value, _) {
          return isSelectedWatchlistIsMyStocks() &&
                  activeTab == AppConstants.tab1
              ? _buildHoldingsBlocBuilder()
              : activeTab == AppConstants.tab2 &&
                      !myWatchlistList.contains(selectedWatchlist.value)
                  ? _buildIndexConstituentsBlocBuilder()
                  : _buildWatchlistBlocBuilder();
        },
      ),
    );
  }

  BlocBuilder _buildHoldingsBlocBuilder() {
    return BlocBuilder<HoldingsBloc, HoldingsState>(
      buildWhen: (previous, current) {
        return current is HoldingsFetchDoneState ||
            current is SuggestedStocksState ||
            current is HoldingsFailedState ||
            current is HoldingsServiceExpectionState;
      },
      builder: (context, state) {
        if (state is HoldingsProgressState) {
          return const LoaderWidget();
        }
        if (state is HoldingsFetchDoneState) {
          selectedFilters = state.selectedFilter ?? getFilterModel();
          selectedSort = state.selectedSortBy ?? SortModel();
        }
        if (state is HoldingsFetchDoneState) {
          if (holdingsBloc.holdingsFetchDoneState.holdingsModel?.holdings !=
                  null &&
              (holdingsBloc.holdingsFetchDoneState.holdingsModel?.holdings!
                      .isNotEmpty ??
                  false)) {
            return _buildContentWidgetWith(
              appBarTitle: _appLocalizations.myStocks,
              appBarLength: holdingsBloc
                  .holdingsFetchDoneState.holdingsModel!.holdings!.length,
              symbolsList:
                  holdingsBloc.holdingsFetchDoneState.holdingsModel!.holdings!,
            );
          } else if ((selectedFilters.first.filters?.isNotEmpty ?? false) ||
              selectedSort.sortName != null) {
            return _buildErrorWidget(
                _appLocalizations.nodatainWatchlist, selectedWatchlist.value,
                isShowErrorImage: true);
          }
        } else if (state is SuggestedStocksState ||
            state is SuggestedStocksStartStreamState) {
          return _buildContentWidgetWith(
            appBarTitle: _appLocalizations.myStocks,
            appBarLength: 0,
            isScroll: false,
            symbolsList: AppConfig.suggestedStocks,
            isEmptyContent: true,
          );
        } else if (state is HoldingsFailedState) {
          if (state.errorCode == AppConstants.noDataAvailableErrorCode) {
            return _buildContentWidgetWith(
              appBarTitle: _appLocalizations.myStocks,
              appBarLength: 0,
              symbolsList: AppConfig.suggestedStocks,
              isEmptyContent: true,
            );
          } else {
            return _buildErrorWidget(
                _appLocalizations.noDataAvailableErrorMessage,
                selectedWatchlist.value);
          }
        } else if (state is HoldingsServiceExpectionState) {
          return _buildErrorWidget(
            state.errorMsg,
            selectedWatchlist.value,
            isShowErrorImage: true,
          );
        }
        return const LoaderWidget();
      },
    );
  }

  bool showTutorialbool = true;

  BlocBuilder _buildWatchlistBlocBuilder() {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      buildWhen: (previous, current) {
        return current is WatchlistProgressState ||
            current is WatchlistDoneState ||
            current is WatchlistServiceExpectionState ||
            current is WatchlistInitState ||
            current is WatchlistSymStreamState ||
            current is WatchlistFailedState;
      },
      builder: (context, state) {
        if (state is WatchlistProgressState || state is WatchlistInitState) {
          return const LoaderWidget();
        }
        if (state is WatchlistFailedState) {
          return _buildErrorWidget(state.errorMsg, selectedWatchlist.value);
        } else if (state is WatchlistServiceExpectionState) {
          return _buildErrorWidget(
            state.errorMsg,
            selectedWatchlist.value,
            isShowErrorImage: true,
          );
        }

        if (state is WatchlistDoneState || state is WatchlistSymStreamState) {
          if (watchlistBloc.watchlistDoneState.watchlistSymbolsModel != null ||
              watchlistBloc.watchlistDoneState.watchlistGroupModel != null &&
                  selectedWatchlistGroup != null) {
            Groups? group = watchlistBloc
                .watchlistDoneState.watchlistGroupModel!.groups!
                .firstWhere(
                    (element) => element.wName == selectedWatchlist.value,
                    orElse: () => selectedWatchlistGroup!);
            selectedFilters = group.selectedFilter ?? getFilterModel();
            selectedSort = group.selectedSortBy ?? SortModel();

            if (watchlistBloc.watchlistDoneState.watchlistSymbolsModel?.symbols
                    .isEmpty ??
                true && ((group.selectedFilter?.isNotEmpty ?? false))) {
              return _buildErrorWidget(
                  _appLocalizations.nodatainWatchlist, selectedWatchlist.value,
                  isShowErrorImage: true);
            } else if (watchlistBloc.watchlistDoneState.watchlistSymbolsModel
                    ?.symbols.isNotEmpty ??
                false) {
              return _buildContentWidgetWith(
                appBarTitle: watchlistBloc.watchlistDoneState.selectedWatchlist,
                appBarLength: watchlistBloc.watchlistDoneState
                        .watchlistSymbolsModel?.symbols.length ??
                    0,
                symbolsList: watchlistBloc
                        .watchlistDoneState.watchlistSymbolsModel?.symbols ??
                    [],
                isShowEditWatchlist: true,
                group: group,
              );
            } else {
              return _buildErrorWidget(
                  _appLocalizations.noSymbolFound, selectedWatchlist.value);
            }
          }
        }
        return const LoaderWidget();
      },
    );
  }

  BlocBuilder _buildIndexConstituentsBlocBuilder() {
    return BlocBuilder<IndicesBloc, IndicesState>(
      buildWhen: (previous, current) =>
          current is IndicesProgressState ||
          current is IndexConstituentsDoneState ||
          current is IndicesServiceExpectionState ||
          current is IndicesFailedState,
      builder: (context, state) {
        if (state is IndicesProgressState) {
          return const LoaderWidget();
        }
        if (state is IndexConstituentsDoneState) {
          selectedFilters = state.selectedFilter ?? getFilterModel();
          selectedSort = state.selectedSort ?? SortModel();

          if (state.indicesConstituentsModel?.result.isEmpty ?? true) {
            return _buildErrorWidget(_appLocalizations.nodatainWatchlist,
                state.selectedPredefinedWatchlist!,
                isShowErrorImage: true);
          } else {
            return _buildContentWidgetWith(
                appBarTitle: state.selectedPredefinedWatchlist!,
                appBarLength: state.indicesConstituentsModel!.result.length,
                symbolsList: state.indicesConstituentsModel!.result);
          }
        } else if (state is IndicesFailedState) {
          return _buildErrorWidget(state.errorMsg, selectedWatchlist.value);
        } else if (state is IndicesServiceExpectionState) {
          return _buildErrorWidget(
            state.errorMsg,
            selectedWatchlist.value,
            isShowErrorImage: true,
          );
        }
        return _buildErrorWidget(state.errorMsg, selectedWatchlist.value);
      },
    );
  }

  Widget _buildErrorWidget(
    String errorMessage,
    String appbarTitle, {
    bool isShowErrorImage = false,
  }) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildBottomAppBarWidget(appbarTitle, 0),
          isShowErrorImage
              ? errorWithImageWidget(
                  context: context,
                  imageWidget:
                      errorMessage == AppLocalizations().nodatainWatchlist
                          ? Image.asset(
                              'lib/assets/images/watchlistnodata.png',
                              height: 230.w,
                            )
                          : AppUtils().getNoDateImageErrorWidget(context),
                  errorMessage: errorMessage,
                  padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_100,
                    left: 30.w,
                    right: 30.w,
                    bottom: 30.w,
                  ),
                )
              : SizedBox(
                  height: AppWidgetSize.fullWidth(context),
                  child: Center(
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  final ScrollController scrollcontroller = ScrollController();

  Widget _buildContentWidgetWith(
      {required String appBarTitle,
      required int appBarLength,
      required List<Symbols> symbolsList,
      bool isShowEditWatchlist = false,
      Groups? group,
      bool isEmptyContent = false,
      bool isScroll = true}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildBottomAppBarWidget(
          appBarTitle,
          appBarLength,
        ),
        buildSubCampaign(),
        !isEmptyContent
            ? Expanded(
                child: WatchlistListWidget(
                  scrollController: scrollcontroller,
                  symbolList: symbolsList,
                  isShowEditWatchlist: isShowEditWatchlist,
                  group: group,
                  onEditWatchlistCallback: _onEditWatchlistCallback,
                  holdingsList:
                      holdingsBloc.holdingsFetchDoneState.holdingsModel != null
                          ? holdingsBloc
                              .holdingsFetchDoneState.holdingsModel!.holdings
                          : [],
                  isFromWatchlistScreen: true,
                  isScroll: isScroll,
                  onRowClicked: _onRowClickedCallBack,
                  refreshWatchlist: onRefreshWatchlist,
                ),
              )
            : Expanded(
                child: _buildBottomContentForEmptyWidget(
                    AppConfig.suggestedStocks),
              ),
      ],
    );
  }

  Widget _buildBottomAppBarWidget(
    String title,
    int watchlistSymCount,
  ) {
    symbolsCount = watchlistSymCount;
    return ClipRRect(
      child: Container(
        height: AppWidgetSize.dimen_70,
        margin: EdgeInsets.only(
          bottom: 3.w,
        ),
        padding: EdgeInsets.only(
          left: 30.w,
          right: 20.w,
          top: 10.w,
          bottom: 10.w,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).dividerColor,
              offset: const Offset(0.0, 1.0),
              blurRadius: AppWidgetSize.dimen_2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              key: keyButton,
              onTap: () {
                sendEventToFirebaseAnalytics(
                  AppEvents.watchlistGroupsheet,
                  ScreenRoutes.watchlistScreen,
                  'select watchlist bottomsheet',
                );
                _buildWatchlistGroupBottomSheet();
              },
              child: Container(
                width: AppWidgetSize.fullWidth(context) / 1.35,
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
                        left: 10.w,
                      ),
                      child: Row(
                        children: [
                          if (myWatchlistList.contains(title))
                            if (myWatchlistList.indexOf(title) <
                                watchlistIcons.length)
                              watchlistIcons
                                  .elementAt(myWatchlistList.indexOf(title))
                            else
                              Container()
                          else if (!myWatchlistList.contains(title))
                            AppConfig.predefinedWatch.indexWhere((element) =>
                                        element.dispSym == title) !=
                                    -1
                                ? predefinedWatchlistIcons.elementAt(
                                    AppConfig.predefinedWatch.indexWhere(
                                        (element) => element.dispSym == title))
                                : predefinedWatchlistIcons.elementAt(1),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 5.w,
                              top: AppWidgetSize.dimen_2,
                            ),
                            child: CustomTextWidget(
                              title,
                              Theme.of(context)
                                  .primaryTextTheme
                                  .bodySmall!
                                  .copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: AppWidgetSize.fontSize18),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: AppWidgetSize.dimen_3,
                              top: AppWidgetSize.dimen_2,
                            ),
                            child: CustomTextWidget('($watchlistSymCount)',
                                Theme.of(context).primaryTextTheme.bodySmall),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: GestureDetector(
                        onTap: () {
                          sendEventToFirebaseAnalytics(
                            AppEvents.watchlistGroupsheet,
                            ScreenRoutes.watchlistScreen,
                            'watchlist group icon is selected and it will show watchlist group and predefined watchlist in bottomsheet',
                          );
                          _buildWatchlistGroupBottomSheet();
                        },
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
                // GestureDetector(
                //   onTap: () {
                //     _buildWatchlistGroupBottomSheet();
                //   },
                //   child: AppImages.viewWatchlistIcon(
                //     context,
                //     isColor: false,
                //     width: AppWidgetSize.dimen_25,
                //     height: AppWidgetSize.dimen_25,
                //   ),
                // ),
                // Padding(
                //   padding: EdgeInsets.only(
                //     left: AppWidgetSize.dimen_20,
                //     right: 20.w,
                //   ),
                //   child: Container(
                //     padding: EdgeInsets.only(
                //       top:5.w,
                //     ),
                //     margin: EdgeInsets.only(
                //       top: AppWidgetSize.dimen_2,
                //     ),
                //     width: 1.5,
                //     height: AppWidgetSize.dimen_22,
                //     color: Theme.of(context).dividerColor,
                //   ),
                // ),
                _buildFilterIcon(title, watchlistSymCount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterIcon(String title, int watchlistSymCount) {
    return Opacity(
      opacity: watchlistSymCount == 0 &&
              watchlistBloc.watchlistDoneState.selectedWatchlist ==
                  _appLocalizations.myStocks &&
              !(isFilterSelected() ||
                  selectedSort.sortName != null &&
                      selectedSort.sortName!.isNotEmpty)
          ? 0.3
          : 1,
      child: InkWell(
        onTap: watchlistSymCount == 0 &&
                watchlistBloc.watchlistDoneState.selectedWatchlist ==
                    _appLocalizations.myStocks &&
                !(isFilterSelected() ||
                    selectedSort.sortName != null &&
                        selectedSort.sortName!.isNotEmpty)
            ? null
            : () {
                sendEventToFirebaseAnalytics(
                  AppEvents.sortFilter,
                  ScreenRoutes.watchlistScreen,
                  'Watchlist filter icon is selected and it will show sort and filter bottomsheet',
                );
                if (activeTab == AppConstants.tab1) {
                  sortSheet();
                } else if (activeTab == AppConstants.tab2) {
                  sortSheet();
                }
              },
        key: keyButton1,
        child: AppUtils().buildFilterIcon(context,
            isSelected: (isFilterSelected() ||
                selectedSort.sortName != null &&
                    selectedSort.sortName!.isNotEmpty)),
      ),
    );
  }

  bool isFilterSelected() {
    for (FilterModel filterModel in selectedFilters) {
      if (filterModel.filters != null) {
        for (String filters in filterModel.filters!) {
          if (filters.isNotEmpty) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Widget _buildBottomContentForEmptyWidget(List<Symbols> suggestedStocks) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topSuggestedStocksContent(),
          _bottomSuggestedStocksContent(suggestedStocks),
        ],
      ),
    );
  }

  GlobalKey<WatchListCreateState> createWatchList =
      GlobalKey<WatchListCreateState>();

  Widget _topSuggestedStocksContent() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        children: [
          WatchListCreate(
            height: 0,
            watchlistGroups:
                watchlistBloc.watchlistDoneState.watchlistGroupModel?.groups ??
                    [],
            key: createWatchList,
          ),
          buildEmptyWidget(
            context: context,
            description1: _appLocalizations.emptyStockDescription1,
            description2: _appLocalizations.emptyStockDescription2,
            buttonInRow: false,
            button1Title: _appLocalizations.startTrading,
            button2Title: watchListCount <
                    AppUtils().intValue(AppConfig.watchlistGroupLimit)
                ? _appLocalizations.createWatchlist
                : "",
            onButton1Tapped: _onClickSearch,
            onButton2Tapped: () async {
              if (watchListCount <
                  AppUtils().intValue(AppConfig.watchlistGroupLimit)) {
                await createWatchList.currentState?.showCreateNewBottomSheet();
                if (createWatchList.currentState?.watchlistCreated ?? false) {
                  _onCreateNewButtonClick(createWatchList
                          .currentState?.newWatchlistController.text ??
                      "");
                }
              }
            },
            topPadding: AppWidgetSize.dimen_20,
          ),
        ],
      ),
    );
  }

  Widget _bottomSuggestedStocksContent(List<Symbols> suggestedStocks) {
    return Wrap(
      alignment: WrapAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: 20.w,
            left: 30.w,
          ),
          child: Row(
            children: [
              CustomTextWidget(
                _appLocalizations.suggestedStocks,
                Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Theme.of(context)
                        .inputDecorationTheme
                        .labelStyle!
                        .color),
              ),
              InkWell(
                onTap: () {
                  sendEventToFirebaseAnalytics(
                    AppEvents.suggestedstockInfo,
                    ScreenRoutes.watchlistScreen,
                    'Suggested stock info icon is selected and it will show infromation in bottomsheet',
                  );
                  showInfoBottomsheet(
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextWidget(
                              _appLocalizations.suggestedStocks,
                              Theme.of(context).primaryTextTheme.titleMedium,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: AppImages.closeIcon(context,
                                  width: 20.w,
                                  height: 20.w,
                                  color:
                                      Theme.of(context).primaryIconTheme.color,
                                  isColor: true),
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: AppWidgetSize.dimen_20),
                          child: CustomTextWidget(
                            _appLocalizations.watchlistInfo,
                            Theme.of(context).primaryTextTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_2,
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
        ),
        WatchlistListWidget(
            symbolList: suggestedStocks,
            onRowClicked: _onRowClickedCallBack,
            holdingsList: holdingsBloc.holdingsFetchDoneState.holdingsModel !=
                    null
                ? holdingsBloc.holdingsFetchDoneState.holdingsModel!.holdings
                : [],
            refreshWatchlist: () {},
            isScroll: false),
      ],
    );
  }

  void _buildWatchlistGroupBottomSheet() {
    showInfoBottomsheet(
      StatefulBuilder(builder: (_, StateSetter updateState) {
        return Scaffold(
          body: _buildBottomSheetContentWidget(
            updateState,
          ),
          bottomNavigationBar: activeTab == AppConstants.tab1
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    bottomManageCreateButton(),
                  ],
                )
              : null,
        );
      }),
      horizontalMargin: false,
    );
  }

  unsubScribeLevel1quotes() {
    unsubscribeLevel1();
  }

  Row bottomManageCreateButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 20.w,
            right: 20.w,
          ),
          child: Center(
            child: gradientButtonWidget(
              onTap: () {
                sendEventToFirebaseAnalytics(
                  AppEvents.watchlistManage,
                  ScreenRoutes.watchlistScreen,
                  'Manage button selected from watchlist group bottomsheet and will it move to Manage watchlist screen',
                );
                unsubScribeLevel1quotes();
                Navigator.of(context).pop();
                _onManageWatchlist();
              },
              width: watchListCount <
                      AppUtils().intValue(AppConfig.watchlistGroupLimit)
                  ? AppWidgetSize.dimen_150
                  : AppWidgetSize.dimen_200,
              key: const Key(watchlistManageWatchlistKey),
              context: context,
              title: _appLocalizations.manage,
              isGradient: true,
            ),
          ),
        ),
        if (watchListCount < AppUtils().intValue(AppConfig.watchlistGroupLimit))
          WatchListCreate(
            onChanged: (value) {
              sendEventToFirebaseAnalytics(
                AppEvents.watchlistCreate,
                ScreenRoutes.watchlistScreen,
                'Create watchlist is selected and it will show create watchlist bottomsheet',
              );
              if (watchListCount <
                  AppUtils().intValue(AppConfig.watchlistGroupLimit)) {
                Navigator.of(context).pop();
                _onCreateNewButtonClick(value);
              } else {
                Navigator.of(context).pop();
                showToast(
                    message: _appLocalizations.maxlimitReached,
                    context: context,
                    isError: true);
              }
            },
            title: _appLocalizations.create,
            width: AppWidgetSize.dimen_150,
            watchlistGroups:
                watchlistBloc.watchlistDoneState.watchlistGroupModel?.groups! ??
                    [],
          ),
      ],
    );
  }

  Widget _buildBottomSheetContentWidget(
    StateSetter updateState,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_32,
              right: 30.w,
              bottom: 20.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomTextWidget(
                      "${_appLocalizations.watchlist}s",
                      // Theme.of(context).textTheme.headline2,
                      Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w500, fontSize: 22.w),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 5.w,
                        top: 5.w,
                      ),
                      child: InkWell(
                          onTap: () {
                            sendEventToFirebaseAnalytics(
                              AppEvents.watchlistInfo,
                              ScreenRoutes.watchlistScreen,
                              'Watchlist info icon is selected and will show information bottomsheet',
                            );
                            pushNavigation(ScreenRoutes.watchlistinfoScreen);
                          },
                          child: AppImages.infoIcon(
                            context,
                            color: Theme.of(context).primaryIconTheme.color,
                            isColor: true,
                          )),
                    ),
                  ],
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
          Material(
            elevation: 10,
            shadowColor: Theme.of(context).dialogBackgroundColor,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: AppWidgetSize.dimen_45,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 10.w,
                  left: 15.w,
                  right: AppWidgetSize.dimen_15,
                  bottom: 2.w,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildWidgetForTabView(
                      _appLocalizations.myWatchlists,
                      AppConstants.tab1,
                      WrapAlignment.start,
                      updateState,
                    ),
                    _buildWidgetForTabView(
                      _appLocalizations.predefinedWatchlists,
                      AppConstants.tab2,
                      WrapAlignment.center,
                      updateState,
                    )
                  ],
                ),
              ),
            ),
          ),
          activeTab == AppConstants.tab1
              ? Expanded(
                  child: _buildMyWatchlistWidget(
                    updateState,
                  ),
                )
              : Expanded(
                  child: _buildPredefinedWatchlistsWidget(
                    updateState,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildWidgetForTabView(
    String title,
    String constantTabTitle,
    WrapAlignment alignment,
    StateSetter updateState,
  ) {
    return Wrap(
      alignment: alignment,
      direction: Axis.vertical,
      children: <Widget>[
        GestureDetector(
          onTap: () => _onSetSelectedTap(
            constantTabTitle,
            title,
            updateState,
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  if (title == _appLocalizations.predefinedWatchlists)
                    AppImages.predefinedIcon(
                      context,
                      color: activeTab == constantTabTitle
                          ? Theme.of(context).primaryColor
                          : Theme.of(context)
                              .inputDecorationTheme
                              .labelStyle!
                              .color,
                      width: 22.w,
                      height: 22.w,
                    ),
                  Text(
                    title,
                    style: activeTab == constantTabTitle
                        ? Theme.of(context).primaryTextTheme.headlineMedium
                        : Theme.of(context)
                            .primaryTextTheme
                            .labelLarge!
                            .copyWith(
                                color: Theme.of(context)
                                    .inputDecorationTheme
                                    .labelStyle!
                                    .color,
                                fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              if (activeTab == constantTabTitle) _buildBottomHighlighter(title),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomHighlighter(String title) {
    return Container(
      width: title.length * AppWidgetSize.dimen_8,
      height: AppWidgetSize.dimen_2,
      margin: EdgeInsets.only(top: AppWidgetSize.dimen_4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(AppWidgetSize.dimen_2),
      ),
    );
  }

  Widget _buildMyWatchlistWidget(
    StateSetter updateState,
  ) {
    return myWatchlistList.isNotEmpty
        ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.separated(
                        padding: EdgeInsets.only(
                          top: AppWidgetSize.dimen_1,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        separatorBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: EdgeInsets.only(left: 30.w, right: 30.w),
                            child: Divider(
                              thickness: AppWidgetSize.dimen_1,
                              color: Theme.of(context).dividerColor,
                            ),
                          );
                        },
                        itemCount: myWatchlistList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return _buildMyWatchlistSymRowWidget(
                              myWatchlistList[index], index, updateState);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Center(
            child: SizedBox(
              child: CustomTextWidget(
                _appLocalizations.noDataAvailableErrorMessage,
                Theme.of(context).textTheme.displaySmall,
              ),
            ),
          );
  }

  Future<void> _onCreateNewButtonClick(String watchListName) async {
    unsubScribeLevel1quotes();

    final Map<String, dynamic>? data = await pushNavigation(
      ScreenRoutes.searchScreen,
      arguments: {
        'watchlistBloc': watchlistBloc,
        'isNewWatchlist': true,
        'newWatchlistName': watchListName.trim(),
      },
    );

    if (data?['isNewWatchlist']) {
      if (data?['isNewWatchlistCreated']) {
        var accDetails = await AppStorage().getData("userLoginDetailsKey");

        await AppStorage().setData("selcetedWatchlist", {
          "accName": accDetails["accName"],
          "selcetedWatchlist": data?["wName"]
        });
        await getselectedWatchList();
        //await pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen);
      }
    }
  }

  Widget _buildMyWatchlistSymRowWidget(
    String group,
    int index,
    StateSetter updateState,
  ) {
    return GestureDetector(
      onTap: () async {
        sendEventToFirebaseAnalytics(
          AppEvents.watchlistgroupSelect,
          ScreenRoutes.watchlistScreen,
          'Watchlist is selected in watchlist group bottomsheet',
        );
        _scrollControllerForTopContent.animateTo(0,
            duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
        Future.delayed(Duration.zero).then((_) {
          Navigator.of(context).pop();
        });
        var accDetails = await AppStorage().getData("userLoginDetailsKey");

        await AppStorage().setData("selcetedWatchlist",
            {"accName": accDetails["accName"], "selcetedWatchlist": group});
        selectedWatchlist.value = group;
        selectedFilters = getFilterModel();
        selectedSort = SortModel();

        refreshWatchlist();
      },
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: EdgeInsets.only(
            left: 30.w,
            right: 30.w,
            top: 12.w,
            bottom: 10.w,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (myWatchlistList.indexOf(group) < watchlistIcons.length)
                    watchlistIcons.elementAt(myWatchlistList.indexOf(group))
                  else
                    Container(),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10.w,
                    ),
                    child: CustomTextWidget(
                      group,
                      // Theme.of(context).primaryTextTheme.button!.copyWith(
                      //       fontWeight: FontWeight.w400,
                      //     ),
                      Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w500, fontSize: 18.w),
                    ),
                  ),
                ],
              ),
              if (group == selectedWatchlist.value)
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
  }

  Widget _buildPredefinedWatchlistsWidget(
    StateSetter updateState,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_1,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.only(left: 30.w, right: 30.w),
                child: Divider(
                  thickness: AppWidgetSize.dimen_1,
                  color: Theme.of(context).dividerColor,
                ),
              );
            },
            itemCount: AppConfig.predefinedWatch.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return _buildPredefinedWatchSymRowWidget(
                AppConfig.predefinedWatch[index],
                updateState,
                index,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPredefinedWatchSymRowWidget(
    PredefinedWatch predefinedWatch,
    StateSetter updateState,
    int index,
  ) {
    return GestureDetector(
      onTap: () async {
        sendEventToFirebaseAnalytics(
          AppEvents.predefwatchlistSelect,
          ScreenRoutes.watchlistScreen,
          'Predefined watchlist is selected in watchlist group bottomsheet',
        );
        selectedWatchlist.value = predefinedWatch.baseSym;

        Navigator.of(context).pop();
        refreshWatchlist();
      },
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: EdgeInsets.only(
            left: 30.w,
            right: 30.w,
            top: 12.w,
            bottom: 10.w,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  predefinedWatchlistIcons.elementAt(index),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10.w,
                    ),
                    child: CustomTextWidget(
                      predefinedWatch.dispSym,
                      // Theme.of(context).primaryTextTheme.button!.copyWith(
                      //       fontWeight: FontWeight.w400,
                      //     ),
                      Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w500, fontSize: 18.w),
                    ),
                  ),
                ],
              ),
              if (predefinedWatch.baseSym == selectedWatchlist.value)
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
  }

  Future<void> sortSheet() async {
    showInfoBottomsheet(
        BlocProvider<WatchlistBloc>.value(
          value: watchlistBloc,
          child: BlocProvider<IndicesBloc>.value(
            value: indicesBloc,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter updateState) {
                return SortFilterWidget(
                  screenName: ScreenRoutes.watchlistScreen,
                  onDoneCallBack: (s, f) {
                    sendEventToFirebaseAnalytics(
                      AppEvents.sortfilterDone,
                      ScreenRoutes.watchlistScreen,
                      'Done is selected in sort and filter bottomsheet',
                    );
                    onDoneCallBack(s, f);
                    updateState(() {});
                  },
                  onClearCallBack: () {
                    sendEventToFirebaseAnalytics(
                      AppEvents.sortfilterClear,
                      ScreenRoutes.watchlistScreen,
                      'Clear is selected in sort and filter bottomsheet',
                    );
                    onClearCallBack();
                    updateState(() {});
                  },
                  mystock:
                      selectedWatchlist.value == _appLocalizations.myStocks,
                  selectedSort: selectedSort,
                  selectedFilters: selectedFilters,
                );
              },
            ),
          ),
        ),
        horizontalMargin: false);
  }

  void onDoneCallBack(
    SortModel selectedSortModel,
    List<FilterModel> filterList,
  ) {
    selectedSort = selectedSortModel;
    if (filterList.isNotEmpty) {
      selectedFilters = filterList;
      watchListApiCallWithFilters(selectedFilters, selectedSort);
    }
  }

  void onClearCallBack() {
    selectedFilters = getFilterModel();
    selectedSort = SortModel();
    watchListApiCallWithFilters(selectedFilters, selectedSort);
    if (isSelectedWatchlistIsMyStocks() &&
        watchlistBloc.watchlistDoneState.selectedTab == AppConstants.tab1) {
      symbolsCount == 0 &&
              holdingsBloc.holdingsFetchDoneState.holdingsModel == null
          ? holdingsBloc.add(SuggestedStocksStartSymStreamEvent())
          : holdingsBloc.add(HoldingsStartSymStreamEvent());
    } else if (watchlistBloc.watchlistDoneState.selectedTab ==
        AppConstants.tab1) {
      watchlistBloc.add(WatchlistStartSymStreamEvent());
    } else {
      indicesBloc.add(IndexConstituentsStartSymStreamEvent());
    }
  }

  void watchListApiCallWithFilters(
    List<FilterModel>? filterModel,
    SortModel? sortModel,
  ) {
    if (isSelectedWatchlistIsMyStocks()) {
      holdingsBloc.add(FetchHoldingsWithFiltersEvent(
        filterModel,
        selectedSort,
      ));
    } else if (!myWatchlistList.contains(selectedWatchlist.value)) {
      indicesBloc.add(IndexConstituentsSortSymbolsEvent(
          selectedWatchlist.value, filterModel, selectedSort));
    } else {
      if (selectedWatchlistGroup != null) {
        int index = watchlistBloc
            .watchlistDoneState.watchlistGroupModel!.groups!
            .indexOf(selectedWatchlistGroup!);
        if (index >= 0) {
          watchlistBloc.watchlistDoneState.watchlistGroupModel!.groups![index]
              .selectedSortBy = selectedSort;
          watchlistBloc.watchlistDoneState.watchlistGroupModel!.groups![index]
              .selectedFilter = selectedFilters;
          watchlistBloc.add(WatchlistGetSymbolsEvent(
            selectedWatchlistGroup ?? Groups(),
            true,
            true,
          ));
        }
      }
    }
  }

  _onWatchlistSymbolRowClick({bool fetchApi = false}) {
    if (isSelectedWatchlistIsMyStocks()) {
      watchlistBloc.add(SelectedWatchlistAndTabEvent(
          _appLocalizations.myStocks, AppConstants.tab1));
      holdingsBloc.add(HoldingsFetchEvent(true, isFetchAgain: true));
    } else if (myWatchlistList.contains(selectedWatchlist.value)) {
      selectedWatchlistGroup = watchlistBloc
          .watchlistDoneState.watchlistGroupModel?.groups!
          .firstWhere((element) => element.wName == selectedWatchlist.value);
      watchlistBloc.add(SelectedWatchlistAndTabEvent(
          selectedWatchlist.value, AppConstants.tab1));
      if (selectedWatchlistGroup != null) {
        watchlistBloc.add(WatchlistGetSymbolsEvent(
            selectedWatchlistGroup!, true, true,
            fetchApi: fetchApi));
      }
    }
  }

  void _onPredefinedWatchlistRowClick() {
    selectedFilters = getFilterModel();
    selectedSort = SortModel();
    if (activeTab == AppConstants.tab2) {
      watchlistBloc.add(SelectedWatchlistAndTabEvent(
          selectedWatchlist.value, AppConstants.tab2));
      PredefinedWatch predefinedWatch = AppConfig.predefinedWatch
          .firstWhere((element) => element.baseSym == selectedWatchlist.value);

      indicesBloc.add(IndexConstituentsSymbolsEvent(
          selectedWatchlist.value, predefinedWatch.dispSym));
    }
  }

  void _onSetSelectedTap(
    String selectedTab,
    String selectedTitle,
    StateSetter updateState,
  ) {
    sendEventToFirebaseAnalytics(
      AppEvents.watchlistgroupTab,
      ScreenRoutes.watchlistScreen,
      'New tab is selected in watchlist group bottomsheet',
    );
    updateState(() {
      activeTab = selectedTab;
      activeTitle = selectedTitle;
    });
  }

  bool isSelectedWatchlistIsMyStocks() {
    return selectedWatchlist.value == _appLocalizations.myStocks;
  }

  bool isSortSelectedInPredefinedWatchlist() {
    bool isSortSeletedInOneGroup = false;
    for (PredefinedWatch element in AppConfig.predefinedWatch) {
      if (element.baseSym == selectedWatchlist.value) {
        isSortSeletedInOneGroup = true;
      }
    }
    return isSortSeletedInOneGroup;
  }

  bool isSortSelectedInHoldings() {
    return holdingsBloc.holdingsFetchDoneState.isSortSelected;
  }

  bool isFilterSelectedInHoldings() {
    return holdingsBloc.holdingsFetchDoneState.isFilterSelected;
  }

  Future<void> _onManageWatchlist() async {
    await pushNavigation(ScreenRoutes.watchlistManageScreen, arguments: {
      'watchlistBloc': watchlistBloc,
      'indicesBloc': indicesBloc,
    });
    refreshWatchlist();
  }

  Future<void> _onClickSearch() async {
    unsubScribeLevel1quotes();
    await pushNavigation(
      ScreenRoutes.searchScreen,
      arguments: {'watchlistBloc': watchlistBloc, 'fromWatchlist': true},
    );
    refreshWatchlist();
  }

  void _onEditWatchlistCallback() async {
    sendEventToFirebaseAnalytics(
      AppEvents.watchlistEdit,
      ScreenRoutes.watchlistScreen,
      'Edit watchlist is selected and it will move to Edit watchlist screen',
    );
    unsubScribeLevel1quotes();
    await pushNavigation(
      ScreenRoutes.editWatchlistScreen,
      arguments: {
        'watchlistGroup': watchlistBloc
            .watchlistDoneState.watchlistGroupModel!.groups!
            .firstWhere((element) => element.wName == selectedWatchlist.value),
        'watchlistBloc': watchlistBloc,
        'indicesBloc': indicesBloc,
      },
    );

    refreshWatchlist();
  }

  Future<void> _onRowClickedCallBack(Symbols symbolItem) async {
    unsubScribeLevel1quotes();
    sendEventToFirebaseAnalytics(
      AppEvents.watchlistRowclick,
      ScreenRoutes.watchlistScreen,
      'Watchlist row is clicked and will move to quote screen',
    );
    await pushNavigation(
      ScreenRoutes.quoteScreen,
      arguments: {
        'symbolItem': symbolItem,
      },
    );
    setState(() {});
    if (activeTab == AppConstants.tab2 &&
        !myWatchlistList.contains(selectedWatchlist.value)) {
      unsubScribeLevel1quotes();
      indicesBloc.add(IndexConstituentsStartSymStreamEvent());
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        refreshWatchlist();
      });
    }
  }

  void onRefreshWatchlist() {
    callHoldingsApi();
    if (!isSelectedWatchlistIsMyStocks() &&
        watchlistBloc.watchlistDoneState.selectedTab != AppConstants.tab1) {
      refreshWatchlist();
    }
  }

  Future<void> refreshWatchlist({Groups? newGroup, fetchApi = false}) async {
    unsubScribeLevel1quotes();
    if (isNewWatchlist) {
      watchlistBloc.add(WatchlistGetGroupsEvent(true));
      isNewWatchlist = false;
      selectedWatchlistGroup = newGroup;
    }
    if (activeTab == AppConstants.tab1) {
      _onWatchlistSymbolRowClick(fetchApi: fetchApi);
    } else {
      _onPredefinedWatchlistRowClick();
    }
  }

  Future<void> showWatchlistInforBottomSheet() async {
    return showInfoBottomsheet(Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextWidget(
              _appLocalizations.watchlistGuide1,
              Theme.of(context).primaryTextTheme.titleMedium,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: AppImages.closeIcon(
                context,
                width: 20.w,
                height: 20.w,
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
            CustomTextWidget(_appLocalizations.watchlistGuide2,
                Theme.of(context).primaryTextTheme.labelSmall,
                textAlign: TextAlign.justify),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
              child: RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(children: [
                    WidgetSpan(
                        alignment: PlaceholderAlignment.top,
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: 8.w,
                            right: 10.w,
                          ),
                          child: AppImages.watchlist_52high(context,
                              height: AppWidgetSize.dimen_17),
                        )),
                    TextSpan(
                      text: _appLocalizations.fiftytwoweekhigh,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    )
                  ])),
            ),
            CustomTextWidget(
              _appLocalizations.watchlistGuide3,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
              child: RichText(
                  text: TextSpan(children: [
                WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.w, right: 10.w),
                      child: AppImages.watchlist_52low(context,
                          height: AppWidgetSize.dimen_17),
                    )),
                TextSpan(
                  text: _appLocalizations.fiftytwoweeklow,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(
              _appLocalizations.watchlistGuide3,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
              child: RichText(
                  text: TextSpan(children: [
                WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.w, right: 10.w),
                      child: AppImages.watchlist_bonus(context,
                          height: AppWidgetSize.dimen_17),
                    )),
                TextSpan(
                  text: _appLocalizations.watchlistGuide4,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(
              _appLocalizations.watchlistGuide5,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
              child: RichText(
                  text: TextSpan(children: [
                WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.w, right: 10.w),
                      child: AppImages.watchlist_split(context,
                          height: AppWidgetSize.dimen_17),
                    )),
                TextSpan(
                  text: _appLocalizations.watchlistGuide6,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(
              _appLocalizations.watchlistGuide7,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
              child: RichText(
                  text: TextSpan(children: [
                WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.w, right: 10.w),
                      child: AppImages.watchlist_exdividend(context,
                          height: AppWidgetSize.dimen_17),
                    )),
                TextSpan(
                  text: _appLocalizations.watchlistGuide8,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(
              _appLocalizations.watchlistGuide9,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
              child: RichText(
                  text: TextSpan(children: [
                WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.w, right: 10.w),
                      child: AppImages.watchlist_cumdividend(context,
                          height: AppWidgetSize.dimen_17),
                    )),
                TextSpan(
                  text: _appLocalizations.watchlistGuide10,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(
              _appLocalizations.watchlistGuide11,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
              child: RichText(
                  text: TextSpan(children: [
                WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10.w, right: 10.w),
                      child: AppImages.watchlist_holding(context,
                          height: AppWidgetSize.dimen_17,
                          color: Theme.of(context).primaryIconTheme.color,
                          isColor: true),
                    )),
                TextSpan(
                  text: _appLocalizations.watchlistGuide12,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(
              _appLocalizations.watchlistGuide13,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
              child: RichText(
                  text: TextSpan(children: [
                WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10.w, right: 10.w),
                      child: AppImages.watchlist_nse(context,
                          height: AppWidgetSize.dimen_17),
                    )),
                TextSpan(
                  text: _appLocalizations.watchlistGuide14,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(
              _appLocalizations.watchlistGuide15,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
              child: RichText(
                  text: TextSpan(children: [
                WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10.w, right: 10.w),
                      child: AppImages.watchlist_bse(context,
                          height: AppWidgetSize.dimen_17),
                    )),
                TextSpan(
                  text: _appLocalizations.watchlistGuide16,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(
              _appLocalizations.watchlistGuide17,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
              child: RichText(
                  text: TextSpan(children: [
                WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10.w, right: 10.w),
                      child: AppImages.watchlist_nfo(context,
                          height: AppWidgetSize.dimen_17),
                    )),
                TextSpan(
                  text: _appLocalizations.watchlistGuide18,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(
              _appLocalizations.watchlistGuide19,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
              child: RichText(
                  text: TextSpan(children: [
                WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10.w, right: 10.w),
                      child: AppImages.watchlist_fando(context,
                          height: AppWidgetSize.dimen_17),
                    )),
                TextSpan(
                  text: _appLocalizations.watchlistGuide18,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(
              _appLocalizations.watchlistGuide20,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
              child: RichText(
                  text: TextSpan(children: [
                WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.w, right: 10.w),
                      child: AppImages.watchlist_cds(context,
                          height: AppWidgetSize.dimen_17),
                    )),
                TextSpan(
                  text: _appLocalizations.cdfullform,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ])),
            ),
            CustomTextWidget(
              _appLocalizations.watchlistGuide22,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
          ]),
        ))
      ],
    ));
  }

  Future<void> fetchAccountInfo() async {
    await MyAccountRepository().getAccountInfo(fetchAgain: false);
  }

  // Future<void> writejson() async {
  //   final Directory directory = await getApplicationDocumentsDirectory();
  //   final File file = File('${directory.path}/res.json');
  //   var text = await file.readAsString();
  //   file.writeAsStringSync(json.encode({"akash": "skk"}));
  //   logInfo("file", text);
  // }
}
