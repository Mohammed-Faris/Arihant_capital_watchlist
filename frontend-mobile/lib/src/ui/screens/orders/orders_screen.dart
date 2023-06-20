import 'dart:async';

import 'package:acml/src/blocs/common/screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/config/infoIDConfig.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../blocs/market_status/market_status_bloc.dart';
import '../../../blocs/orders/order_log/order_log_bloc.dart';
import '../../../blocs/orders/orders_bloc.dart';
import '../../../blocs/watchlist/watchlist_bloc.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_events.dart';
import '../../../constants/keys/search_keys.dart';
import '../../../data/repository/order/order_repository.dart';
import '../../../data/store/app_calculator.dart';
import '../../../data/store/app_store.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/orders/order_book.dart';
import '../../../models/sort_filter/sort_filter_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../validator/input_validator.dart';
import '../../widgets/build_empty_widget.dart';
import '../../widgets/circular_toggle_button_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/refresh_widget.dart';
import '../../widgets/sort_filter_widget.dart';
import '../../widgets/webview_widget.dart';
import '../base/base_screen.dart';
import '../quote/widgets/routeanimation.dart';
import '../route_generator.dart';
import '../watchlist/widget/alert_bottomsheet_widget.dart';
import 'orders_detail_screen.dart';
import 'widgets/order_row_widget.dart';

class OrderScreen extends BaseScreen {
  final FocusNode searchFocusNode;
  const OrderScreen(
    this.searchFocusNode, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => OrderScreenState();
}

class OrderScreenState extends BaseAuthScreenState<OrderScreen> {
  late OrdersBloc _ordersBloc;
  late OrderLogBloc _orderLogBloc;
  late WatchlistBloc watchlistBloc;
  late MarketStatusBloc marketStatusBloc;
  late AppLocalizations _appLocalizations;

  final TextEditingController _searchController =
      TextEditingController(text: '');

  String tappedButtonHeader = '';
  bool isSearchSelected = false;

  List<String> orderStatusFilter = [];
  List<String> orderStatusCountFilter = [];
  ValueNotifier<int> selectedOrderStatusIndex = ValueNotifier<int>(0);

  Orders selectedOrder = Orders();

  SortModel selectedSort = SortModel();
  List<FilterModel> selectedFilters = <FilterModel>[];

  ScrollController statelessControllerA = ScrollController();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _ordersBloc = BlocProvider.of<OrdersBloc>(context)
      ..stream.listen(_orderBookListener);
    orderbookApiCallWithFilters(null, null, fetchagain: true, loading: true);

    if (Featureflag.fetchOrderfromSocket) {
      timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        try {
          bool fetchData = await OrderRepository().getOrderupdate();
          if (fetchData) {
            orderbookApiCallWithFilters(selectedFilters, selectedSort,
                fetchagain: true, loading: false);
          }
        } on ServiceException catch (e) {
          if (e.code == InfoIDConfig.invalidSessionCode) {
            handleError(ScreenState()
              ..isInvalidException = true
              ..errorCode = e.code
              ..errorMsg = e.msg);
          }
          timer.cancel();
        }
      });
    }

    orderStatusFilter = getOrderStatusFilter();
    selectedFilters = getFilterModel();
    marketStatusBloc = BlocProvider.of<MarketStatusBloc>(context);

    watchlistBloc = BlocProvider.of<WatchlistBloc>(context);
    watchlistBloc.add(WatchlistGetGroupsEvent(false));

    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.orderScreen);
  }

  Future<void> orderbookApiCallWithFilters(
      List<FilterModel>? filterModel, SortModel? sortModel,
      {bool fetchagain = false, loading = true}) async {
    _ordersBloc.add(OrdersBookEvent(
      filterModel,
      selectedSort,
      loading: loading,
      fetchAgain: fetchagain,
    ));
  }

  List<String> getOrderStatusFilter() {
    return [
      AppLocalizations().all,
      AppLocalizations().open,
      AppLocalizations().ordStatusClosed,
      // AppLocalizations().brackets,
    ];
  }

  List<FilterModel> getFilterModel() {
    return [
      FilterModel(
        filterName: AppConstants.action,
        filters: [],
        filtersList: [],
      ),
      FilterModel(
        filterName: AppConstants.segment,
        filters: [],
        filtersList: [],
      ),
      FilterModel(
        filterName: AppConstants.orderStatus,
        filters: [],
        filtersList: [],
      ),
      FilterModel(
        filterName: AppConstants.instrumentSegment,
        filters: [],
        filtersList: [],
      ),
      FilterModel(
        filterName: AppConstants.productType,
        filters: [],
        filtersList: [],
      ),
      FilterModel(
        filterName: AppLocalizations().validity,
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

  @override
  void dispose() {
    timer?.cancel();

    screenFocusOut();
    super.dispose();
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.orderScreen;
  }

  bool orderFetchDone = false;

  Future<void> _orderBookListener(OrdersState state) async {
    if (state is! OrdersProgressState) {
      if (mounted) {}
    }
    if (state is OrdersDoneState) {
      orderFetchDone = true;
    }
    if (state is OrdersProgressState) {
      if (mounted) {}
    } else if (state is OrdersBookStreamState) {
      subscribeLevel1(state.streamDetails);
    } else if (state is OrdersCancelDoneState) {
      showToast(
        message: state.baseModel.infoMsg,
        context: context,
      );
      orderbookApiCallWithFilters(selectedFilters, selectedSort,
          fetchagain: true, loading: false);
    } else if (state is OrdersExitDoneState) {
      showToast(
        message: state.baseModel.infoMsg,
        context: context,
      );
      orderbookApiCallWithFilters(selectedFilters, selectedSort,
          fetchagain: true, loading: false);
    } else if (state is OrdersCancelFailedState ||
        state is OrdersCancelServiceExceptionState ||
        state is OrdersExitFailedState ||
        state is OrdersExitServiceExceptionState) {
      showToast(
        message: state.errorMsg,
        context: context,
        isError: true,
      );
      setState(() {});
      orderbookApiCallWithFilters(selectedFilters, selectedSort,
          loading: false);
    } else if (state is OrdersFailedState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state is OrdersErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  void callStreamEvents() {
    _ordersBloc.add(StartSymStreamEvent());
  }

  @override
  void quote1responseCallback(ResponseData data) {
    _ordersBloc.add(StreamingResponseEvent(data));
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: RefreshWidget(
          onRefresh: () async {
            orderbookApiCallWithFilters(selectedFilters, selectedSort,
                fetchagain: true, loading: false);
            /*  bool fetchData = await OrderRepository().getOrderupdate();
            if (fetchData) {
              
            } */
          },
          child: buildBody(context),
        ),
        bottomNavigationBar: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if ((state is OrdersFailedState ||
                    (_ordersBloc.ordersDoneState.orderBook?.orders?.isEmpty ??
                        true) ||
                    state is OrdersErrorState) &&
                state is! OrdersProgressState &&
                !isFilterSelected()) {
              return Padding(
                  padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (Featureflag.basketOrder) _buildMyBasket(context),
                      _buildTradeHistory(context),
                    ],
                  ));
            } else {
              return Container(
                height: 0,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMyBasket(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 5.w),
      child: AppUtils().labelBorderWidgetBottom(
        AppLocalizations().myBasket,
        AppImages.createBasketIcon(context,
            color: Theme.of(context).primaryColor, isColor: true, width: 15.w),
        () async {
          await pushNavigation(ScreenRoutes.myBasket);
          orderbookApiCallWithFilters(selectedFilters, selectedSort,
              fetchagain: true, loading: false);
        },
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      buildWhen: (OrdersState previous, OrdersState current) {
        return current is OrdersDoneState ||
            current is OrdersFailedState ||
            current is OrdersProgressState ||
            current is OrdersServiceExceptionState;
      },
      builder: (context, state) {
        if (state is OrdersProgressState) {
          return const LoaderWidget();
        }
        if (state is OrdersDoneState) {
          orderStatusCountFilter = [
            state.orderBook?.orders?.length.toString() ?? '0',
            getCountForOrderStatus(1, state.orderBook?.orders ?? []),
            getCountForOrderStatus(2, state.orderBook?.orders ?? []),
            getCountForOrderStatus(3, state.orderBook?.orders ?? []),
          ];

          if (state.orderBook?.orders != null &&
              (state.orderBook?.orders?.isNotEmpty ?? false)) {
            if (AppStore().getSelectedOrder() != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                try {
                  Orders orders = state.orderBook!.orders!
                      .where((element) =>
                          element.ordId == AppStore().getSelectedOrder()?.ordId)
                      .first;
                  AppStore().setOrder(null);
                  selectedOrder = orders;
                  marketStatusBloc = BlocProvider.of<MarketStatusBloc>(context);
                  _ordersBloc = BlocProvider.of<OrdersBloc>(context);
                  marketStatusBloc.add(GetMarketStatusEvent(orders.sym!));
                  _orderLogBloc = BlocProvider.of<OrderLogBloc>(context);
                  _orderLogBloc.add(OrderStatusLogEvent(orders));

                  await showOrderbookBottomSheet(orders);
                  moveOrderDetailswithpop(orders);
                } catch (e) {
                  AppStore().setOrder(null);
                }
              });
            }
            if (isSearchSelected) {
              if (state.searchOrdersSymbols != null &&
                  state.searchOrdersSymbols!.isNotEmpty) {
                return buildBodyContent(
                  context,
                  getOrdersListForSelectedOrderStatus(
                    state.searchOrdersSymbols!,
                  ),
                );
              } else if (_searchController.text.isEmpty) {
                return buildBodyContent(
                  context,
                  getOrdersListForSelectedOrderStatus(
                    state.orderBook!.orders!,
                  ),
                );
              } else {
                return buildBodyContent(
                  context,
                  getOrdersListForSelectedOrderStatus(
                    state.orderBook!.orders!,
                  ),
                  isSearchEmpty: true,
                );
              }
            } else {
              return buildBodyContent(
                context,
                getOrdersListForSelectedOrderStatus(
                  state.orderBook!.orders!,
                ),
              );
            }
          } else if (selectedFilters
                  .where((FilterModel element) =>
                      element.filters?.isNotEmpty ?? false)
                  .toList()
                  .isNotEmpty ||
              selectedSort.sortName != null) {
            return buildBodyContent(
                context,
                getOrdersListForSelectedOrderStatus(
                  state.orderBook!.orders!,
                ),
                isSearchEmpty: _searchController.text.isNotEmpty);
          } else {
            return _buildEmptyOrderWidget();
          }
        } else if (state is OrdersFailedState ||
            state is OrdersServiceExceptionState) {
          AppStore().setOrder(null);
          return _buildEmptyOrderWidget();
        } else if (state is OrdersServiceExceptionState) {
          AppStore().setOrder(null);
          return errorWithImageWidget(
            context: context,
            imageWidget: AppUtils().getNoDateImageErrorWidget(context),
            errorMessage: state.errorMsg,
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
              bottom: AppWidgetSize.dimen_30,
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget buildBodyContent(
    BuildContext context,
    List<Orders> orders, {
    bool isSearchEmpty = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_15,
        left: AppWidgetSize.dimen_25,
        right: AppWidgetSize.dimen_30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSearchSelected)
            _buildSearchTextBox(
              orders,
            )
          else
            _buildToolBarWidget(context),
          if (!isSearchSelected)
            _buildOrderStatusWidget(
              context,
              orders,
            ),
          if (isSearchEmpty)
            buildEmptySearch(
              context: context,
              description1: _appLocalizations.emptySearchDescriptions1,
              button1Title: _appLocalizations.emptySearchDescriptions2,
              onButton1Tapped: moveToMyOrdersScreen,
            )
          else
            _buildOrderbookContentWidget(
              context,
              orders,
            ),
        ],
      ),
    );
  }

  Widget buildEmptySearch({
    required BuildContext context,
    required String description1,
    required String button1Title,
    required Function onButton1Tapped,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            //   alignment: WrapAlignment.center,
            children: [
              AppImages.noSearchResults(context,
                  isColor: false,
                  width:
                      AppWidgetSize.fullWidth(context) - AppWidgetSize.dimen_80,
                  height: AppWidgetSize.dimen_150),
              Padding(
                padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_20,
                  bottom: AppWidgetSize.dimen_40,
                ),
                child: CustomTextWidget(
                  description1,
                  Theme.of(context).primaryTextTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              GestureDetector(
                onTap: () {
                  onButton1Tapped();
                },
                child: CustomTextWidget(
                  button1Title,
                  Theme.of(context).primaryTextTheme.headlineMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyOrderWidget() {
    return ListView(children: [
      SizedBox(
          height: AppWidgetSize.screenHeight(context) - AppWidgetSize.dimen_200,
          child: buildEmptyWidget(
            context: context,
            description1: _appLocalizations.emptyOrdersDescriptions1,
            description2: _appLocalizations.emptyOrdersDescriptions2,
            buttonInRow: false,
            button1Title: _appLocalizations.placeOrder,
            button2Title: _appLocalizations.viewWatchlist,
            onButton1Tapped: onPlaceOrderTapped,
            onButton2Tapped: onViewWatchlistTapped,
          ))
    ]);
  }

  void moveToMyOrdersScreen() {
    pushAndRemoveUntilNavigation(
      ScreenRoutes.homeScreen,
      arguments: {
        'pageName': ScreenRoutes.tradesScreen,
        'selectedIndex': 0,
      },
    );
  }

  void onViewWatchlistTapped() {
    pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen);
  }

  Future<void> onPlaceOrderTapped() async {
    unsubscribeLevel1();
    await pushNavigation(
      ScreenRoutes.searchScreen,
      arguments: {
        'watchlistBloc': watchlistBloc,
      },
    );
  }

  Widget _buildToolBarWidget(
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (Featureflag.basketOrder) _buildMyBasket(context),
            _buildTradeHistory(context),
          ],
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              _buildFilter(context),
              VerticalDivider(
                color: Theme.of(context).textTheme.labelLarge!.color,
                width: 1.5,
              ),
              _buildSearch(context)
            ],
          ),
        ),
      ],
    );
  }

  void _movetoGtdorderScreen(Orders orders) {
    AppStore().setOrder(orders);
    pushAndRemoveUntilNavigation(
      ScreenRoutes.homeScreen,
      arguments: {
        'pageName': ScreenRoutes.tradesScreen,
        'selectedIndex': 0,
        'toGtd': true
      },
    );
  }

  Widget _buildTradeHistory(BuildContext context) {
    return AppUtils().labelBorderWidgetBottom(
      AppLocalizations().tradeHistory,
      AppImages.tradeHistory(
        context,
        width: AppWidgetSize.dimen_15,
        height: AppWidgetSize.dimen_15,
      ),
      () async {
        pushNavigation(ScreenRoutes.tradeHistory);
      },
    );
  }

  Widget _buildFilter(BuildContext context) {
    return InkWell(
      onTap: () {
        sortSheet();
      },
      child: Padding(
          padding: EdgeInsets.only(
            right: AppWidgetSize.dimen_4,
          ),
          child: AppUtils().buildFilterIcon(
            context,
            isSelected: isFilterSelected() ||
                (selectedSort.sortName != null &&
                    selectedSort.sortName!.isNotEmpty),
          )),
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

  // Widget _buildSortSelectedDot() {
  //   return Positioned(
  //     right: 0,
  //     child: Container(
  //       width: AppWidgetSize.dimen_5,
  //       height: AppWidgetSize.dimen_5,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(4),
  //         color: Theme.of(context).primaryColor,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSearch(BuildContext context) {
    return GestureDetector(
      onTap: () {
        isSearchSelected = true;
        setState(() {});
        widget.searchFocusNode.requestFocus();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_15,
        ),
        child: AppImages.search(
          context,
          color: Theme.of(context).primaryIconTheme.color,
          isColor: true,
          width: AppWidgetSize.dimen_25,
          height: AppWidgetSize.dimen_25,
        ),
      ),
    );
  }

  Widget _buildSearchTextBox(
    List<Orders> orders,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_20,
      ),
      child: Container(
        height: AppWidgetSize.dimen_45,
        alignment: Alignment.centerLeft,
        child: Stack(
          children: [
            TextField(
              cursorColor: Theme.of(context).iconTheme.color,
              enableInteractiveSelection: true,
              autocorrect: false,
              enabled: true,
              controller: _searchController,
              textCapitalization: TextCapitalization.characters,
              onChanged: (String text) {
                if (text != "") {
                  _ordersBloc.add(OrdersSearchEvent(
                    _searchController.text,
                    orders,
                  ));
                } else {
                  _ordersBloc.add(OrdersResetSearchEvent());
                }
              },
              focusNode: widget.searchFocusNode,
              textInputAction: TextInputAction.done,
              inputFormatters: InputValidator.searchSymbol,
              style: Theme.of(context)
                  .primaryTextTheme
                  .labelLarge!
                  .copyWith(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10,
                  bottom: AppWidgetSize.dimen_7,
                  right: AppWidgetSize.dimen_10,
                ),
                hintText: _appLocalizations.holdingsSearchHint,
                hintStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color:
                        Theme.of(context).dialogBackgroundColor.withAlpha(-1)),
                counterText: '',
              ),
              maxLength: 25,
            ),
            Positioned(
              right: 0,
              top: AppWidgetSize.dimen_12,
              child: GestureDetector(
                onTap: () {
                  isSearchSelected = false;

                  _searchController.text = '';
                  setState(() {});
                  _ordersBloc.add(OrdersResetSearchEvent());
                },
                child: Center(
                  child: AppImages.deleteIcon(
                    context,
                    width: AppWidgetSize.dimen_25,
                    height: AppWidgetSize.dimen_25,
                    color: Theme.of(context).primaryIconTheme.color,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildOrderbookContentWidget(
    BuildContext context,
    List<Orders> orders,
  ) {
    return (orders.isNotEmpty)
        ? Expanded(
            child: ListView.builder(
              primary: false,
              controller: statelessControllerA,
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: orders.length,
              padding: EdgeInsets.only(
                bottom: AppWidgetSize.dimen_10,
              ),
              itemBuilder: (context, int index) {
                return OrdersRowWidget(
                  orders: orders[index],
                  onRowClick: (Orders selected) {
                    selectedOrder = selected;
                    marketStatusBloc =
                        BlocProvider.of<MarketStatusBloc>(context);
                    _ordersBloc = BlocProvider.of<OrdersBloc>(context);
                    marketStatusBloc.add(GetMarketStatusEvent(selected.sym!));
                    _orderLogBloc = BlocProvider.of<OrderLogBloc>(context);
                    _orderLogBloc.add(OrderStatusLogEvent(selected));

                    showOrderbookBottomSheet(selected);
                  },
                  isBottomSheet: false,
                );
              },
            ),
          )
        : Expanded(
            child: ListView(children: [
              errorWithImageWidget(
                  context: context,
                  height: AppWidgetSize.screenHeight(context) -
                      AppWidgetSize.dimen_400,
                  imageWidget: AppUtils().getNoDateImageErrorWidget(context),
                  errorMessage: AppLocalizations().noDataAvailableErrorMessage,
                  padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_30,
                    right: AppWidgetSize.dimen_30,
                    bottom: AppWidgetSize.dimen_30,
                  )),
            ]),
          );
  }

  Widget _buildOrderStatusWidget(
    BuildContext context,
    List<Orders> orders,
  ) {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_10),
      child: SizedBox(
        height: AppWidgetSize.dimen_40,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: selectedOrderStatusIndex,
                builder: (context, value, child) => CircularButtonToggleWidget(
                  spacing: AppWidgetSize.dimen_10,
                  buttonNoList:
                      orderStatusCountFilter.map((e) => e as dynamic).toList(),
                  value: orderStatusFilter[selectedOrderStatusIndex.value],
                  toggleButtonlist:
                      orderStatusFilter.map((s) => s as dynamic).toList(),
                  toggleButtonOnChanged: toggleButtonOnChanged,
                  toggleChanged: (value) {
                    selectedOrderStatusIndex.value = value;

                    orderbookApiCallWithFilters(selectedFilters, selectedSort,
                        loading: false);
                    statelessControllerA.animateTo(0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeIn);
                  },
                  key: const Key(filters_),
                  defaultSelected: '',
                  enabledButtonlist: const [],
                  inactiveButtonColor: Colors.transparent,
                  activeButtonColor: Theme.of(context)
                      .snackBarTheme
                      .backgroundColor!
                      .withOpacity(0.5),
                  inactiveTextColor: Theme.of(context).primaryColor,
                  activeTextColor: Theme.of(context).primaryColor,
                  isBorder: false,
                  context: context,
                  borderColor: Colors.transparent,
                  paddingEdgeInsets: EdgeInsets.fromLTRB(
                    AppWidgetSize.dimen_5,
                    AppWidgetSize.dimen_3,
                    AppWidgetSize.dimen_5,
                    AppWidgetSize.dimen_3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> getSelectedOrderStatus(int index) {
    if (index == 1) {
      return [
        AppConstants.pending,
      ];
    } else if (index == 1) {
      return [
        AppConstants.executed,
        AppConstants.rejected,
        AppConstants.cancelled,
      ];
    } else {
      return [
        AppConstants.executed,
        AppConstants.rejected,
        AppConstants.cancelled,
        AppConstants.pending,
      ];
    }
  }

  Future<void> showOrderbookBottomSheet(
    Orders orders,
  ) async {
    showInfoBottomsheet(
        GestureDetector(
          onVerticalDragEnd: (details) {
            int sensitivity = 0;
            if ((details.primaryVelocity ?? 0) < sensitivity) {
              moveOrderDetailswithpop(orders);
            } else {
              Navigator.of(context).pop();
            }
          },
          child: BlocProvider<OrdersBloc>.value(
            value: _ordersBloc,
            child: BlocProvider<MarketStatusBloc>.value(
              value: marketStatusBloc,
              child: StatefulBuilder(
                builder: (
                  BuildContext context,
                  StateSetter updateState,
                ) {
                  return _bottomContent(orders);
                },
              ),
            ),
          ),
        ),
        topMargin: false,
        horizontalMargin: false);
  }

  Future<void> moveOrderDetailswithpop(Orders orders) async {
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 200), () {});

    _movetoOrderDetailScreen(orders);
  }

  Widget _bottomContent(
    Orders orders,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _bottomSheetBody(orders),
        _buildPersistentFooterWidget(orders),
      ],
    );
  }

  Widget _bottomSheetBody(
    Orders orders,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
        bottom: AppWidgetSize.dimen_10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onTap: () async {
                moveOrderDetailswithpop(orders);
              },
              child: AppImages.upArrowIcon(context,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true,
                  width: 30.w,
                  height: 30.w),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_10,
              bottom: AppWidgetSize.dimen_10,
            ),
            child: getOrderStatusImage(orders.status!),
          ),
          OrdersRowWidget(
            orders: orders,
            onRowClick: () {},
            isBottomSheet: true,
          ),
          BlocBuilder<OrdersBloc, OrdersState>(
            buildWhen: (previous, current) {
              return current is OrdersDoneState;
            },
            builder: (context, state) {
              return _buildLtp(
                orders,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget getOrderStatusImage(
    String orderStatus,
  ) {
    if (orderStatus.toLowerCase() == AppConstants.executed.toLowerCase()) {
      return AppImages.executedStatus(context, width: 30.w, height: 30.w);
    } else if (orderStatus.toLowerCase() ==
        AppConstants.pending.toLowerCase()) {
      return AppImages.pendingStatus(context, width: 30.w, height: 30.w);
    } else {
      return AppImages.rejectedStatus(context, width: 30.w, height: 30.w);
    }
  }

  List<Orders> getOrdersListForSelectedOrderStatus(
    List<Orders> orders,
  ) {
    List<Orders> selectedOrdersList = [];

    if (selectedOrderStatusIndex.value == 1) {
      for (var element in orders) {
        if (element.status!.toLowerCase() ==
                AppConstants.pending.toLowerCase() ||
            element.status!.toLowerCase() ==
                AppConstants.triggeredPending.toLowerCase()) {
          selectedOrdersList.add(element);
        }
      }
    } else if (selectedOrderStatusIndex.value == 2) {
      for (var element in orders) {
        if (element.status!.toLowerCase() ==
                AppConstants.cancelled.toLowerCase() ||
            element.status!.toLowerCase() ==
                AppConstants.rejected.toLowerCase() ||
            element.status!.toLowerCase() ==
                AppConstants.executed.toLowerCase()) {
          selectedOrdersList.add(element);
        }
      }
    } else if (selectedOrderStatusIndex.value == 3) {
      for (var element in orders) {
        if (element.prdType!.toLowerCase() ==
            AppConstants.bracketOrder.toLowerCase()) {
          selectedOrdersList.add(element);
        }
      }
    } else {
      return orders;
    }
    return selectedOrdersList;
  }

  String getCountForOrderStatus(
    int index,
    List<Orders> orders,
  ) {
    int count = 0;
    if (index == 1) {
      for (var element in orders) {
        if (element.status!.toLowerCase() ==
                AppConstants.pending.toLowerCase() ||
            element.status!.toLowerCase() ==
                AppConstants.triggeredPending.toLowerCase()) {
          count++;
        }
      }
    } else if (index == 2) {
      for (var element in orders) {
        if (element.status!.toLowerCase() ==
                AppConstants.cancelled.toLowerCase() ||
            element.status!.toLowerCase() ==
                AppConstants.rejected.toLowerCase() ||
            element.status!.toLowerCase() ==
                AppConstants.executed.toLowerCase()) {
          count++;
        }
      }
    } else if (index == 3) {
      for (var element in orders) {
        if (element.prdType?.toLowerCase() ==
            AppConstants.bracketOrder.toLowerCase()) {
          count++;
        }
      }
    }

    return count.toString();
  }

  String toggleButtonOnChanged(String name) {
    return name;
  }

  Container _buildLtp(
    Orders orders,
  ) {
    return Container(
      margin: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_8,
        top: AppWidgetSize.dimen_8,
      ),
      padding: EdgeInsets.all(
        AppWidgetSize.dimen_8,
      ),
      color: Theme.of(context).colorScheme.background,
      child: Row(
        children: [
          Flexible(
            flex: 3,
            child: Row(
              children: [
                CustomTextWidget(
                  _appLocalizations.ltp,
                  Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                _buildMarketStatusBloc(),
              ],
            ),
          ),
          Flexible(
            flex: 7,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomTextWidget(
                  AppUtils().dataNullCheck(orders.ltp),
                  Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.w500),
                  isShowShimmer: true,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_1,
                    left: AppWidgetSize.dimen_5,
                  ),
                  child: CustomTextWidget(
                    AppUtils().getChangePercentage(orders),
                    Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(left: 8.0),
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
                    ? Theme.of(context).primaryColor
                    : AppColors.negativeColor,
              ),
            ),
          ),
          CustomTextWidget(
            isOpen ? _appLocalizations.live : _appLocalizations.closed,
            Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersistentFooterWidget(
    Orders orders,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: AppWidgetSize.dimen_60,
      color: Theme.of(context).bottomSheetTheme.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          if (orders.status!.toLowerCase() !=
              AppConstants.rejected.toLowerCase())
            _getButtonWidget(
                _getLeftFooterButtonTitle(
                  orders.cancellable!,
                  orders.status!,
                  orders.exitable ?? "false",
                ), () {
              buttonPressed(orders);
            },
                context,
                true,
                orders.status!.toLowerCase() !=
                    AppConstants.rejected.toLowerCase()),
          _getButtonWidget(
              _getRightFooterButtonTitle(orders.modifiable!, orders.status!,
                  orders.actCode, orders.actDisp), () {
            buttonPressed(orders);
          },
              context,
              false,
              orders.status!.toLowerCase() !=
                  AppConstants.rejected.toLowerCase()),
        ],
      ),
    );
  }

  String _getLeftFooterButtonTitle(
      String cancellable, String status, String exitable) {
    if (status.toLowerCase() == AppConstants.pending.toLowerCase() ||
        status.toLowerCase() == AppConstants.triggeredPending.toLowerCase()) {
      if (cancellable == AppConstants.trueConstant) {
        return _appLocalizations.cancel;
      } else if (exitable == AppConstants.trueConstant) {
        return _appLocalizations.exit;
      } else {
        return _appLocalizations.viewPositions;
      }
    } else if (status.toLowerCase() == AppConstants.cancelled.toLowerCase()) {
      return _appLocalizations.viewWatchlist;
    } else {
      return _appLocalizations.viewPositions;
    }
  }

  String _getRightFooterButtonTitle(
      String modifiable, String status, String? accCode, String? accDisplay) {
    if (status.toLowerCase() == AppConstants.pending.toLowerCase() &&
        modifiable == AppConstants.trueConstant) {
      return _appLocalizations.modify;
    } else if (status.toLowerCase() == AppConstants.executed.toLowerCase() &&
        modifiable == AppConstants.trueConstant) {
      return _appLocalizations.modify;
    } else if (status.toLowerCase() ==
            AppConstants.triggeredPending.toLowerCase() &&
        modifiable == AppConstants.trueConstant) {
      return _appLocalizations.modify;
    } else {
      if (accCode == AppConstants.activateAccountCode) {
        return accDisplay ?? "";
      }
      return _appLocalizations.repeatOrder;
    }
  }

  void buttonPressed(
    Orders orders,
  ) {
    if (Featureflag.isGtdNavValidation) {
      if ((tappedButtonHeader == _appLocalizations.cancel ||
              tappedButtonHeader == _appLocalizations.modify) &&
          (orders.comments?.toUpperCase() == AppConstants.gtd.toUpperCase() ||
              orders.ordDuration == AppConstants.gtd)) {
        if ((!((ACMCalci.isMarketStartedOrders(orders) ||
            (orders.isAmo ?? false))))) {
          _movetoGtdorderScreen(orders);
          return;
        }
      }
    }

    if (tappedButtonHeader == _appLocalizations.cancel) {
      showAlertBottomSheetWithTwoButtons(
        context: context,
        title: _appLocalizations.cancel,
        description: _appLocalizations.cancelordermessage,
        leftButtonTitle: AppConstants.no,
        rightButtonTitle: AppConstants.yes,
        rightButtonCallback: _sendCancelOrderRequest,
      );
    } else if (tappedButtonHeader == _appLocalizations.exit) {
      showAlertBottomSheetWithTwoButtons(
        context: context,
        title: _appLocalizations.exit,
        description: _appLocalizations.exitordermessage,
        leftButtonTitle: AppConstants.no,
        rightButtonTitle: AppConstants.yes,
        rightButtonCallback: _sendExitOrderRequest,
      );
    } else if (tappedButtonHeader == _appLocalizations.modify) {
      _movetoPlaceOrderScreen(
        AppConstants.orderbookModifyOrder,
        orders,
      );
    } else if (tappedButtonHeader == _appLocalizations.viewPositions) {
      _movetoPositionsScreen(orders);
    } else if (tappedButtonHeader == _appLocalizations.viewWatchlist) {
      pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen);
    } else if (tappedButtonHeader == _appLocalizations.repeatOrder) {
      sendEventToFirebaseAnalytics(
          AppEvents.repeatorder,
          ScreenRoutes.orderScreen,
          'Clicked repeat order in orderbook bottomsheet',
          key: "symbol",
          value: orders.dispSym);

      _movetoPlaceOrderScreen(
        AppConstants.orderbookRepeatOrder,
        orders,
      );
    } else if (orders.actCode == AppConstants.activateAccountCode) {
      String? url = AppConfig.boUrls
          ?.firstWhereOrNull((element) => element["key"] == "reKYC")?["value"];
      if (url != null) {
        {
          Navigator.push(
            context,
            SlideRoute(
                settings: const RouteSettings(
                  name: ScreenRoutes.inAppWebview,
                ),
                builder: (BuildContext context) =>
                    WebviewWidget("Activate Your Account", url)),
          );
        }
      }
    }
  }

  Future<void> _movetoPlaceOrderScreen(
    String buttonname,
    Orders orders,
  ) async {
    Navigator.of(context).pop();
    String action = AppConstants.buy;
    if (orders.ordAction != null) {
      if (orders.ordAction!.isNotEmpty) {
        action =
            orders.ordAction!.toUpperCase() == AppConstants.buy.toUpperCase()
                ? AppConstants.buy
                : AppConstants.sell;
      }
    }

    unsubscribeLevel1();

    final Map<String, dynamic> arguments = <String, dynamic>{
      'action': action,
      'symbolItem': orders,
      'orders': orders,
      AppConstants.orderbookSelectedOrder: buttonname,
    };
    await pushNavigation(
      ScreenRoutes.orderPadScreen,
      arguments: arguments,
    );
    orderbookApiCallWithFilters(selectedFilters, selectedSort,
        fetchagain: true, loading: false);
  }

  void _movetoPositionsScreen(Orders orders) {
    AppStore().setPosition(orders);
    pushAndRemoveUntilNavigation(
      ScreenRoutes.homeScreen,
      arguments: {
        'pageName': ScreenRoutes.tradesScreen,
        'selectedIndex': 1,
      },
    );
  }

  void _sendCancelOrderRequest() {
    Navigator.of(context).pop();
    _ordersBloc.add(OrderBookCancelEvent(selectedOrder, false));
  }

  void _sendExitOrderRequest() {
    Navigator.of(context).pop();
    _ordersBloc.add(OrderBookExitEvent(selectedOrder));
  }

  Widget _getButtonWidget(String header, Function onTapCallback,
      BuildContext context, bool isleft, bool isLeftAvailable) {
    return GestureDetector(
      onTap: () {
        tappedButtonHeader = header;
        onTapCallback();
      },
      child: Container(
        width: isLeftAvailable
            ? ((AppWidgetSize.fullWidth(context) / 2) - 40.w)
            : null,
        height: AppWidgetSize.dimen_50,
        padding: EdgeInsets.all(AppWidgetSize.dimen_10),
        decoration: !isleft
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
                  color: header == _appLocalizations.viewPositions ||
                          header == _appLocalizations.viewWatchlist
                      ? AppColors().positiveColor
                      : AppColors.negativeColor,
                  width: 1.5,
                ),
                //color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(
                  AppWidgetSize.dimen_30,
                ),
              ),
        child: Text(
          header,
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.displaySmall!.copyWith(
              color: !isleft
                  ? Theme.of(context).colorScheme.secondary
                  : header == _appLocalizations.viewPositions ||
                          header == _appLocalizations.viewWatchlist
                      ? AppColors().positiveColor
                      : AppColors.negativeColor),
        ),
      ),
    );
  }

  Future<void> sortSheet() async {
    showInfoBottomsheet(StatefulBuilder(
        builder: (BuildContext context, StateSetter updateState) {
      return SortFilterWidget(
        screenName: ScreenRoutes.orderScreen,
        onDoneCallBack: (s, f) {
          onDoneCallBack(s, f);
          updateState(() {});
        },
        onClearCallBack: () {
          onClearCallBack();
          updateState(() {});
          if (_ordersBloc.ordersDoneState.orderBook?.orders?.isNotEmpty ??
              false) {
            Future.delayed(
                const Duration(milliseconds: 500),
                (() => statelessControllerA.animateTo(0,
                    duration: const Duration(seconds: 100),
                    curve: Curves.easeIn)));
          }
        },
        selectedSort: selectedSort,
        selectedFilters: selectedFilters,
      );
    }), horizontalMargin: false);
  }

  //Functions

  void onDoneCallBack(
    SortModel selectedSortModel,
    List<FilterModel> filterList,
  ) {
    selectedSort = selectedSortModel;
    selectedFilters = filterList;
    orderbookApiCallWithFilters(selectedFilters, selectedSort,
        fetchagain: true);
  }

  void onClearCallBack() {
    bool fetchagain = selectedFilters
        .where((element) => (element.filters?.isNotEmpty ?? false))
        .toList()
        .isNotEmpty;
    selectedFilters = getFilterModel();
    selectedSort = SortModel();
    orderbookApiCallWithFilters(null, null, fetchagain: fetchagain);
  }

  Future<void> _movetoOrderDetailScreen(
    Orders orders,
  ) async {
    await Navigator.push(
        context,
        SlideUpRoute(
            page: BlocProvider.value(
          value: _orderLogBloc,
          child: BlocProvider.value(
            value: _ordersBloc,
            child: BlocProvider.value(
              value: marketStatusBloc,
              child: OrdersDetailScreen(
                arguments: {
                  'orders': orders,
                  'selectedFilters': selectedFilters,
                  'selectedSort': selectedSort,
                  "marketStatusBloc": marketStatusBloc,
                  "ordersBloc": _ordersBloc,
                  "orderslogbloc": _orderLogBloc
                },
              ),
            ),
          ),
        )));

    Future.delayed(const Duration(milliseconds: 100), () {
      orderbookApiCallWithFilters(selectedFilters, selectedSort,
          fetchagain: true, loading: false);
    });
  }
}
