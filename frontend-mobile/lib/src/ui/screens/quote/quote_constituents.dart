import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../blocs/indices/indices_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_events.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/sort_filter/sort_filter_model.dart';
import '../../../models/watchlist/watchlist_group_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/sort_filter_widget.dart';
import '../base/base_screen.dart';
import '../watchlist/widget/watchlist_list_widget.dart';

class QuoteConstituents extends BaseScreen {
  final dynamic arguments;
  const QuoteConstituents({
    Key? key,
    this.arguments,
  }) : super(key: key);

  @override
  QuoteConstituentsState createState() => QuoteConstituentsState();
}

class QuoteConstituentsState extends BaseAuthScreenState<QuoteConstituents> {
  late IndicesBloc indicesBloc;
  late Symbols symbols;

  List<FilterModel> selectedFilters = <FilterModel>[];
  SortModel selectedSort = SortModel();
  int sortIndexSelected = -1;
  @override
  void initState() {
    super.initState();
    symbols = widget.arguments['symbolItem'];
    symbols.sym!.baseSym = symbols.baseSym;
    selectedFilters = getFilterModel();
    selectedSort = SortModel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      indicesBloc = BlocProvider.of<IndicesBloc>(context)
        ..stream.listen(indicesListener);

      indicesBloc.add(IndexConstituentsSymbolsEvent(
          symbols.baseSym!, symbols.dispSym!,
          baseSym: symbols.dispSym,
          sortModel: selectedSort,
          filtermodel: selectedFilters,
          fromConstituents: true));
      indicesBloc.add(IndexConstituentsStartSymStreamEvent());
    });
  }

  Map<dynamic, dynamic>? streamDetails;
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
  void quote1responseCallback(ResponseData data) {
    indicesBloc.add(IndexConstituentsStreamingResponseEvent(data));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _buildBody(context),
    );
  }

  late AppLocalizations _appLocalizations;
  Widget _buildBody(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      floatingActionButton: _buildFloatingButtonActionWidget(context),
      body: BlocBuilder<IndicesBloc, IndicesState>(
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
            return _buildErrorWidget(state.errorMsg, symbols.baseSym!);
          } else if (state is IndicesServiceExpectionState ||
              state is IndicesErrorState) {
            return _buildErrorWidget(
              state.errorMsg,
              symbols.baseSym!,
              isShowErrorImage: true,
            );
          }
          return _buildErrorWidget(state.errorMsg, symbols.baseSym!);
        },
      ),
    );
  }

  Future<void> sortSheet() async {
    showInfoBottomsheet(
        BlocProvider<IndicesBloc>.value(
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
                mystock: false,
                selectedSort: selectedSort,
                selectedFilters: selectedFilters,
              );
            },
          ),
        ),
        horizontalMargin: false,
        bottomMargin: 0);
  }

  Widget _buildFloatingButtonActionWidget(BuildContext context) {
    return BlocBuilder<IndicesBloc, IndicesState>(
      builder: (context, state) {
        return FloatingActionButton(
            onPressed: () {
              sortSheet();
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Theme.of(context).iconTheme.color!)),
              child: AppUtils().buildFilterIcon(
                context,
                isSelected: (isFilterSelected() ||
                    selectedSort.sortName != null &&
                        selectedSort.sortName!.isNotEmpty),
              ),
            ));
      },
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
          // _buildBottomAppBarWidget(appbarTitle, 0),
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
  Widget _buildContentWidgetWith({
    required String appBarTitle,
    required int appBarLength,
    required List<Symbols> symbolsList,
    bool isShowEditWatchlist = false,
    Groups? group,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: WatchlistListWidget(
            scrollController: scrollcontroller,
            symbolList: symbolsList,
            isShowEditWatchlist: isShowEditWatchlist,
            group: group,
            onEditWatchlistCallback: () {},
            holdingsList: const [],
            isFromWatchlistScreen: true,
            onRowClicked: _onRowClickedCallBack,
            refreshWatchlist: () {},
          ),
        )
      ],
    );
  }

  Future<void> _onRowClickedCallBack(Symbols symbolItem) async {
    await pushNavigation(
      ScreenRoutes.quoteScreen,
      arguments: {
        'symbolItem': symbolItem,
      },
    );
    indicesBloc.add(IndexConstituentsStartSymStreamEvent());
  }

  void onDoneCallBack(
    SortModel selectedSortModel,
    List<FilterModel> filterList,
  ) {
    selectedSort = selectedSortModel;

    selectedFilters = filterList;
    watchListApiCallWithFilters(selectedFilters, selectedSort);
  }

  void onClearCallBack() {
    selectedFilters = getFilterModel();
    selectedSort = SortModel();
    watchListApiCallWithFilters(selectedFilters, selectedSort);

    indicesBloc.add(IndexConstituentsStartSymStreamEvent());
  }

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

  void watchListApiCallWithFilters(
    List<FilterModel>? filterModel,
    SortModel? sortModel,
  ) {
    indicesBloc.add(IndexConstituentsSortSymbolsEvent(
        symbols.dispSym!, filterModel, selectedSort,
        fromConstituents: true));
  }
}
