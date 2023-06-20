import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../blocs/search/search_bloc.dart';
import '../../../blocs/watchlist/watchlist_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_events.dart';
import '../../../constants/keys/search_keys.dart';
import '../../../data/store/app_store.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/watchlist/watchlist_group_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../validator/input_validator.dart';
import '../../widgets/circular_toggle_button_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/loader_widget.dart';
import '../base/base_screen.dart';
import 'widgets/search_list_widget.dart';

class SearchScreen extends BaseScreen {
  final dynamic arguments;

  const SearchScreen({Key? key, required this.arguments}) : super(key: key);

  @override
  SymbolSearchScreenState createState() => SymbolSearchScreenState();
}

class SymbolSearchScreenState extends BaseAuthScreenState<SearchScreen> {
  late SearchBloc searchBloc;
  late WatchlistBloc watchlistBloc;
  late AppLocalizations _appLocalizations;

  final List<String> _filterList = <String>[
    AppConstants.all,
    AppConstants.stocks,
    AppConstants.etfs,
    AppConstants.future,
    AppConstants.options,
    AppConstants.commodity,
    AppConstants.currency,
  ];

  bool isNewWatchlist = false;
  bool isNewWatchlistCreated = false;

  final TextEditingController _searchController =
      TextEditingController(text: '');
  FocusNode searchFocusNode = FocusNode();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (mounted) {
          if (ModalRoute.of(context)?.settings.name.toString() ==
              ScreenRoutes.loginScreen) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (searchFocusNode.hasFocus) {
                searchFocusNode.unfocus();
                Future.delayed(const Duration(milliseconds: 200), () {
                  searchFocusNode.requestFocus();
                });
              }
            });
          }
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null) {
      if (widget.arguments["isNewWatchlist"] != null &&
          widget.arguments["isNewWatchlist"]) {
        isNewWatchlist = true;
      }
    }
    searchBloc = BlocProvider.of<SearchBloc>(context)
      ..stream.listen(searchBlocListner);
    searchBloc.add(SymbolSearchEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      watchlistBloc = BlocProvider.of<WatchlistBloc>(context);
    });
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.searchScreen);
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.searchScreen;
  }

  Future<void> searchBlocListner(SearchState state) async {
    if (state is SymbolSearchDoneState) {
    } else if (state is SearchAddDoneState) {
      clearFocus();
      if (isNewWatchlist) {
        isNewWatchlistCreated = true;
        if (widget.arguments["backIconDisable"] == null) {
          final Map<String, dynamic> returnGroupMapObj = <String, dynamic>{
            'isNewWatchlist': true,
            'wName': searchBloc.wName,
            'isNewWatchlistCreated': isNewWatchlistCreated
          };
          popNavigation(arguments: returnGroupMapObj);
        }
      }
      showToast(
        message: state.messageModel,
        context: context,
      );
    } else if (state is SearchdeleteDoneState) {
      clearFocus();
      showToast(
        message: state.messageModel,
        context: context,
      );
    } else if (state is SearchAddSymbolFailedState ||
        state is SearchdeleteSymbolFailedState) {
      showToast(message: state.errorMsg, context: context, isError: true);
      clearFocus();
    } else if (state is SearchSymStreamState) {
      subscribeLevel1(state.streamDetails);
    } else if (state is SearchFailedState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  @override
  void quote1responseCallback(ResponseData data) {
    searchBloc.add(SearchStreamingResponseEvent(data));
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      toolbarHeight: AppWidgetSize.dimen_60,
      elevation: 0.0,
      bottom: PreferredSize(
          preferredSize: Size(double.maxFinite,
              AppWidgetSize.dimen_130), // here the desired height
          child: _buildSymbolFilterWidget(context)),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.only(top: 20.w, left: AppWidgetSize.dimen_5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildBackButtonWidget(),
            Expanded(
              child: searchTextBox(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBackButtonWidget() {
    return backIconButton(
      onTap: (widget.arguments["backIconDisable"] != true)
          ? null
          : () {
              pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen);
            },
      customColor: Theme.of(context).textTheme.displayLarge!.color,
    );
  }

  String? searchtext;
  Widget searchTextBox() {
    return BlocBuilder<SearchBloc, SearchState>(
      buildWhen: ((previous, current) => current is SymbolSearchDoneState),
      builder: (context, state) {
        return Container(
          height: AppWidgetSize.dimen_45,
          alignment: Alignment.centerLeft,
          child: Stack(
            children: [
              TextField(
                cursorColor: Theme.of(context).iconTheme.color,
                enableInteractiveSelection: true,
                autocorrect: false,
                autofocus: !isNewWatchlist ? false : true,
                enabled: true,
                controller: _searchController,
                textCapitalization: TextCapitalization.characters,
                onChanged: (String text) {
                  if (text.length > 2 && text != searchtext) {
                    searchtext = text;
                    unsubscribeLevel1();
                    sendEventToFirebaseAnalytics(AppEvents.searchSymbol,
                        ScreenRoutes.searchScreen, 'Search symbol',
                        key: "symbol", value: text);
                    searchBloc.add(SymbolSearchEvent()
                      ..searchString = _searchController.text
                      ..selectedFilter = state.selectedSymbolFilter);
                  } else if (text.isEmpty) {
                    searchtext = text;
                    searchBloc.add(SymbolSearchEvent()
                      ..searchString = _searchController.text
                      ..selectedFilter = state.selectedSymbolFilter);
                    if (scrollController.positions.isNotEmpty) {
                      scrollController.animateTo(0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease);
                    }
                  } else {
                    searchtext = text;
                  }
                },
                focusNode: searchFocusNode,
                textInputAction: TextInputAction.done,
                inputFormatters: InputValidator.searchSymbol,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      left: 5.w,
                      top: 10.w,
                      bottom: AppWidgetSize.dimen_7,
                      right: 10.w,
                    ),
                    hintText: _appLocalizations.searchHint,
                    hintStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context)
                            .dialogBackgroundColor
                            .withAlpha(-1)),
                    counterText: '',
                    suffixIcon: Visibility(
                      visible: _searchController.text.isNotEmpty,
                      child: GestureDetector(
                        onTap: () {
                          clearFocus();
                          searchtext = "";
                          _searchController.text = '';
                          if (scrollController.positions.isNotEmpty) {
                            scrollController.animateTo(0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          }
                          searchBloc.add(SymbolSearchEvent());
                        },
                        child: Container(
                          padding: EdgeInsets.all(AppWidgetSize.dimen_10),
                          child: AppImages.deleteIcon(
                            context,
                            color: Theme.of(context).primaryIconTheme.color,
                          ),
                        ),
                      ),
                    )),
                maxLength: 25,
              ),
            ],
          ),
        );
      },
    );
  }

  final ScrollController scrollController = ScrollController();

  Widget _buildBody() {
    return _buildSymbolSearchWidget();
  }

  Widget _buildHeaderContentWidget(
      {SearchState? state, bool isExploreTitle = false}) {
    return Container(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(
          top: 10.w,
          left: 30.w,
          right: 30.w,
          bottom:
              isExploreTitle ? AppWidgetSize.dimen_10 : AppWidgetSize.dimen_10,
        ),
        child: Row(
          children: [
            CustomTextWidget(
              isExploreTitle
                  ? _appLocalizations.explore
                  : state!.isShowRecentSearch
                      ? _appLocalizations.recentSearch
                      : _appLocalizations.search,
              Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                  color:
                      Theme.of(context).inputDecorationTheme.labelStyle!.color),
            ),
            GestureDetector(
              onTap: () {
                isExploreTitle
                    ? _showExploreBottomSheet()
                    : pushNavigation(ScreenRoutes.infoScreen);
              },
              child: AppImages.informationIcon(
                context,
                color: Theme.of(context).primaryIconTheme.color,
                isColor: true,
                width: 20.w,
                height: 20.w,
              ),
            )
          ],
        ),
      ),
    );
  }

  _showExploreBottomSheet() {
    return showInfoBottomsheet(SizedBox(
      height: 160.w,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  _appLocalizations.explore,
                  Theme.of(context).textTheme.displayMedium,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: AppImages.closeIcon(
                    context,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          Padding(
            padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
            child: CustomTextWidget(
              _appLocalizations.exploreInfo,
              Theme.of(context).textTheme.headlineSmall!,
            ),
          )
        ],
      ),
    ));
  }

  Widget _buildSymbolSearchWidget() {
    return BlocBuilder<SearchBloc, SearchState>(
      buildWhen: (SearchState prevState, SearchState currentState) {
        return currentState is SymbolSearchDoneState ||
            currentState is SearchFailedState ||
            currentState is SearchServiceExpectionState ||
            currentState is SearchLoaderState;
      },
      builder: (BuildContext context, SearchState state) {
        if (state is SearchLoaderState) {
          return const LoaderWidget();
        }
        if (state is SearchFailedState ||
            state is SearchServiceExpectionState) {
          if (state is SearchServiceExpectionState) {
            unsubscribeLevel1();

            return errorWithImageWidget(
              context: context,
              imageWidget: AppUtils().getNoDateImageErrorWidget(context),
              errorMessage: state.errorMsg,
              padding: EdgeInsets.only(
                left: 30.w,
                right: 30.w,
                bottom: 30.w,
              ),
            );
          } else {
            return _buildErrorWidget(state.errorMsg);
          }
        } else if (state is SymbolSearchDoneState) {
          if (!state.isShowRecentSearch &&
              (state.searchSymbolsModel?.symbols.isNotEmpty ?? false)) {
            return _buildSearchWidget(
              state.searchSymbolsModel?.symbols ?? [],
            );
          } else if (state.isShowRecentSearch) {
            return _buildRecentSearchWidget(
                state.recentSelecteddatamodel.symbols);
          } else {
            return _buildErrorWidget(_appLocalizations.symbolnotfound);
          }
        } else {
          return const Center(
            child: LoaderWidget(),
          );
        }
      },
    );
  }

  Widget _buildSearchWidget(List<Symbols> symbolList) {
    return symbolList.isEmpty
        ? _buildErrorWidget(_appLocalizations.symbolnotfound)
        : Container(
            constraints: BoxConstraints(
                minHeight: AppWidgetSize.screenHeight(context) -
                    AppWidgetSize.dimen_60),
            child: SearchlistListWidget(
              symbolList: symbolList,
              isScrollable: true,
              scrollController: scrollController,
              groupList: getWatchListGroups(),
              searchBloc: searchBloc,
              isNewWatchlist: isNewWatchlist,
              newWatchlistName:
                  isNewWatchlist ? widget.arguments['newWatchlistName'] : '',
              isShowRecentHist: false,
              watchlistIcons: !isNewWatchlist
                  ? AppUtils().getWatchlistIcons(
                      context,
                      getWatchListGroups().length,
                    )
                  : [],
              fromBasket: widget.arguments["basketData"] != null,
              fromAlerts: widget.arguments["fromAlerts"] ?? false,
              basketData: widget.arguments["basketData"],
            ),
          );
  }

  Widget _buildRecentSearchWidget(
    List<Symbols> symbolList,
  ) {
    return ListView(
      children: [
        if (symbolList.isNotEmpty)
          SearchlistListWidget(
            symbolList: symbolList,
            groupList: getWatchListGroups(),
            searchBloc: searchBloc,
            isScrollable: false,
            isNewWatchlist: isNewWatchlist,
            newWatchlistName:
                isNewWatchlist ? widget.arguments['newWatchlistName'] : '',
            isShowRecentHist: true,
            watchlistIcons: !isNewWatchlist
                ? AppUtils().getWatchlistIcons(
                    context,
                    getWatchListGroups().length,
                  )
                : [],
            fromBasket: widget.arguments["basketData"] != null,
            fromAlerts: widget.arguments["fromAlerts"] ?? false,
            basketData: widget.arguments["basketData"],
          )
        else
          _buildErrorWidget(
              _appLocalizations.recentSearchNotAvailbleErrorMessage),
        if (!isNewWatchlist &&
            !(widget.arguments["fromAlerts"] ?? false) &&
            !(widget.arguments["basketData"] != null))
          _buildHeaderContentWidget(isExploreTitle: true),
        if (!isNewWatchlist &&
            !(widget.arguments["fromAlerts"] ?? false) &&
            !(widget.arguments["basketData"] != null))
          _buildExploreWidget()
      ],
    );
  }

  Widget _buildSymbolFilterWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.w, left: 20.w),
          child: BlocBuilder<SearchBloc, SearchState>(
            buildWhen: (previous, current) {
              return current is SymbolSearchDoneState;
            },
            builder: (context, state) {
              if (state is SymbolSearchDoneState) {
                return CircularButtonToggleWidget(
                  value: state.selectedSymbolFilter,
                  toggleButtonlist: _filterList,
                  runSpacing: 5.w,
                  toggleButtonOnChanged: toggleButtonOnChanged,
                  activeButtonColor:
                      AppStore().getThemeData() == AppConstants.lightMode
                          ? Theme.of(context)
                              .snackBarTheme
                              .backgroundColor!
                              .withOpacity(0.5)
                          : Theme.of(context).primaryColor,
                  activeTextColor:
                      AppStore().getThemeData() == AppConstants.lightMode
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.displayLarge!.color!,
                  inactiveButtonColor: Colors.transparent,
                  inactiveTextColor: Theme.of(context).primaryColor,
                  key: const Key(filters_),
                  defaultSelected: '',
                  enabledButtonlist: const [],
                  isBorder: false,
                  context: context,
                  paddingEdgeInsets: EdgeInsets.fromLTRB(
                    AppWidgetSize.dimen_14,
                    AppWidgetSize.dimen_3,
                    AppWidgetSize.dimen_14,
                    AppWidgetSize.dimen_3,
                  ),
                  borderColor: Colors.transparent,
                  fontSize: 16.w,
                );
              }
              return CircularButtonToggleWidget(
                value: AppConstants.all,
                toggleButtonlist: _filterList,
                toggleButtonOnChanged: toggleButtonOnChanged,
                activeButtonColor: Theme.of(context)
                    .snackBarTheme
                    .backgroundColor!
                    .withOpacity(0.5),
                activeTextColor: Theme.of(context).primaryColor,
                inactiveButtonColor: Colors.transparent,
                inactiveTextColor: Theme.of(context).primaryColor,
                key: const Key(filters_),
                defaultSelected: '',
                enabledButtonlist: const [],
                isBorder: false,
                context: context,
                paddingEdgeInsets: EdgeInsets.fromLTRB(
                  AppWidgetSize.dimen_14,
                  AppWidgetSize.dimen_3,
                  AppWidgetSize.dimen_14,
                  AppWidgetSize.dimen_3,
                ),
                borderColor: Colors.transparent,
                fontSize: 18.w,
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
          child: BlocBuilder<SearchBloc, SearchState>(
            buildWhen: (SearchState prevState, SearchState currentState) {
              return currentState is SymbolSearchDoneState ||
                  currentState is SearchFailedState ||
                  currentState is SearchServiceExpectionState ||
                  currentState is SearchLoaderState;
            },
            builder: (context, state) {
              return _buildHeaderContentWidget(state: state);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExploreWidget() {
    return Padding(
        padding: EdgeInsets.only(left: 20.w, top: 10.w, bottom: 10.w),
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 1.1,
                ),
                child: Wrap(
                    runSpacing: 12.w,
                    spacing: 8.w,
                    alignment: WrapAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          moveToDetailsScreenMarketIndices("NIFTY");
                        },
                        child: _buildExploreContentWidget(
                          AppImages.niftyFiftyIcon(context),
                          AppConstants.nifty,
                          AppImages.closeIcon(
                            context,
                            width: AppWidgetSize.dimen_22,
                            height: AppWidgetSize.dimen_22,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          moveToDetailsScreenMarketIndices("BANKNIFTY");
                        },
                        child: _buildExploreContentWidget(
                          AppImages.bankNiftyIcon(context),
                          AppConstants.bankNifty,
                          AppImages.downArrow(
                            context,
                            width: AppWidgetSize.dimen_22,
                            height: AppWidgetSize.dimen_22,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          moveToDetailsScreen(0);
                        },
                        child: _buildExploreContentWidget(
                          AppImages.niftyMidcapIcon(context),
                          AppConstants.topGainers,
                          AppImages.closeIcon(
                            context,
                            width: AppWidgetSize.dimen_22,
                            height: AppWidgetSize.dimen_22,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          moveToDetailsScreen(1);
                        },
                        child: _buildExploreContentWidget(
                          Image(image: AppImages.topLosers()),
                          AppConstants.topLosers,
                          AppImages.closeIcon(
                            context,
                            width: AppWidgetSize.dimen_22,
                            height: AppWidgetSize.dimen_22,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          moveToDetailsScreen(2);
                        },
                        child: _buildExploreContentWidget(
                          AppImages.bullIcon(context),
                          AppConstants.whNifty,
                          AppImages.downArrow(
                            context,
                            width: AppWidgetSize.dimen_22,
                            height: AppWidgetSize.dimen_22,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          moveToDetailsScreen(3);
                        },
                        child: _buildExploreContentWidget(
                          AppImages.bearIcon(context),
                          AppConstants.wlNifty,
                          AppImages.downArrow(
                            context,
                            width: AppWidgetSize.dimen_22,
                            height: AppWidgetSize.dimen_22,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          moveToDetailsScreenFO(0, true);
                        },
                        child: _buildExploreContentWidget(
                          AppImages.futureGainers(context),
                          AppConstants.futureGainers,
                          AppImages.downArrow(
                            context,
                            width: AppWidgetSize.dimen_22,
                            height: AppWidgetSize.dimen_22,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          moveToDetailsScreenFO(1, true);
                        },
                        child: _buildExploreContentWidget(
                          AppImages.futureLosers(context),
                          AppConstants.futureLosers,
                          AppImages.downArrow(
                            context,
                            width: AppWidgetSize.dimen_22,
                            height: AppWidgetSize.dimen_22,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          moveToDetailsScreenFO(0, false);
                        },
                        child: _buildExploreContentWidget(
                          AppImages.priceUpArrow(context),
                          AppConstants.optionGainers,
                          AppImages.downArrow(
                            context,
                            width: AppWidgetSize.dimen_22,
                            height: AppWidgetSize.dimen_22,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          moveToDetailsScreenFO(1, false);
                        },
                        child: _buildExploreContentWidget(
                          AppImages.priceDownArrow(context),
                          AppConstants.optionLosers,
                          AppImages.downArrow(
                            context,
                            width: AppWidgetSize.dimen_22,
                            height: AppWidgetSize.dimen_22,
                          ),
                        ),
                      ),
                    ]))));
  }

  void moveToDetailsScreen(int currentTabIndex) {
    pushNavigation(
      ScreenRoutes.marketMoversDetailsScreen,
      arguments: {
        'currentTabIndex': currentTabIndex,
        'showMarketMoversCashDetails': true
      },
    );
  }

  void moveToDetailsScreenFO(int currentTabIndex, bool isFuture) {
    pushNavigation(
      ScreenRoutes.marketMoversDetailsScreen,
      arguments: {
        'currentTabIndex': currentTabIndex,
        'showMarketIndicesDetails': false,
        'showMarketMoversFODetails': true,
        'segment': isFuture ? "stockFut" : "stockOpt",
        "page": ScreenRoutes.searchScreen
      },
    );
  }

  void moveToDetailsScreenMarketIndices(String indexName) {
    pushNavigation(
      ScreenRoutes.marketMoversDetailsScreen,
      arguments: {
        'indexName': indexName,
        'showMarketMoversCashDetails': false,
      },
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Container(
      height: 60.w,
      alignment: Alignment.center,
      width: AppWidgetSize.fullWidth(context),
      child: CustomTextWidget(
        errorMessage,
        Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildExploreContentWidget(
      Widget chipImageIcon, String label, Widget image) {
    final double sizedBoxWidth = label == ''
        ? 5.w
        : label.textSize(
                label, Theme.of(context).primaryTextTheme.labelLarge!) +
            10.w;
    return Chip(
      avatar: chipImageIcon,
      label: SizedBox(
        width: sizedBoxWidth,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: AppWidgetSize.dimen_5),
              child: CustomTextWidget(
                  label, Theme.of(context).primaryTextTheme.labelSmall),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 1.0,
      shape: StadiumBorder(
        side: BorderSide(
          width: 0.5,
          color: Theme.of(context).dividerColor,
        ),
      ),
      padding: EdgeInsets.all(10.w),
    );
  }

  void toggleButtonOnChanged(String data) {
    if (scrollController.positions.isNotEmpty) {
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    }
    searchBloc.add(SymbolSearchEvent()
      ..searchString = _searchController.text
      ..selectedFilter = data);
  }

  List<Groups> getWatchListGroups() {
    List<Groups> watchlistGroups =
        watchlistBloc.watchlistDoneState.watchlistGroupModel?.groups ?? [];

    return watchlistGroups;
  }

  void clearFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
