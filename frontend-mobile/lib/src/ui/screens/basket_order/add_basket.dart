import 'dart:async';

import 'package:acml/src/blocs/basket_order/basket_state.dart';
import 'package:acml/src/blocs/order_pad/order_pad_bloc.dart';
import 'package:acml/src/ui/screens/basket_order/widgets/basket_row_widget.dart';
import 'package:acml/src/ui/styles/app_widget_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../blocs/basket_order/basket_bloc.dart';
import '../../../blocs/market_status/market_status_bloc.dart';
import '../../../blocs/my_funds/add_funds/add_funds_bloc.dart';
import '../../../blocs/orders/order_log/order_log_bloc.dart';
import '../../../blocs/orders/orders_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/basket_order/basket_model.dart';
import '../../../models/basket_order/basket_orderbook.dart';
import '../../../models/orders/order_book.dart' as normal_order;
import '../../../models/orders/order_book.dart';
import '../../../models/sort_filter/sort_filter_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../validator/input_validator.dart';
import '../../widgets/build_empty_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/refresh_widget.dart';
import '../base/base_screen.dart';
import '../orders/orders_detail_screen.dart';
import '../quote/widgets/routeanimation.dart';

class AddBasket extends BaseScreen {
  final Baskets arguments;
  const AddBasket(this.arguments, {super.key});

  @override
  State<AddBasket> createState() => _AddBasketState();
}

class _AddBasketState extends BaseAuthScreenState<AddBasket> {
  late BasketBloc basketBloc;

  late AppLocalizations _appLocalizations;
  late OrdersBloc _ordersBloc;
  late MarketStatusBloc marketStatusBloc;
  late OrderLogBloc _orderLogBloc;
  late OrderPadBloc orderPadBloc;

  final TextEditingController _searchController =
      TextEditingController(text: '');

  String tappedButtonHeader = '';
  bool isSearchSelected = false;

  List<String> orderStatusFilter = [];
  List<String> orderStatusCountFilter = [];
  ValueNotifier<int> ordercount = ValueNotifier<int>(0);

  FocusNode searchFocusNode = FocusNode();

  Orders selectedOrder = Orders();

  SortModel selectedSort = SortModel();
  List<FilterModel> selectedFilters = <FilterModel>[];

  ScrollController statelessControllerA = ScrollController();
  Timer? timer;
  List<Orders> orderList = [];
  String? basketName;
  bool isPop = true;

  @override
  void initState() {
    _ordersBloc = BlocProvider.of<OrdersBloc>(context);
    BlocProvider.of<AddFundsBloc>(context)
        .add(GetFundsViewEvent(fetchApi: true));
    orderPadBloc = BlocProvider.of<OrderPadBloc>(context)
      ..stream.listen((event) {
        if (event is OrderPadPlaceOrderDoneState) {
          basketBloc.add(FetchBasketOrdersEvent(widget.arguments.basketId));
        } else if (event is OrderPadPlaceOrderServiceExceptionState ||
            event is OrderPadPlaceOrderFailedState) {
          showToast(message: event.errorMsg, isError: true);
        }
      });
    marketStatusBloc = BlocProvider.of<MarketStatusBloc>(context);
    _orderLogBloc = BlocProvider.of<OrderLogBloc>(context);
    basketBloc = BlocProvider.of(context);
    basketBloc
      ..add(FetchBasketOrdersEvent(widget.arguments.basketId))
      ..stream.listen((event) {
        if (event is FetchBasketOrdersStreamState) {
          subscribeLevel1(event.streamDetails);
        } else if (event is ExecuteBasketOrdersDone) {
          basketBloc.add(FetchBasketOrdersEvent(widget.arguments.basketId));
        } else if (event is ResetBasketDone) {
          basketBloc.add(FetchBasketOrdersEvent(widget.arguments.basketId));
        }
      });

    //---------------------
    scrollListerner();
    super.initState();
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

  ValueNotifier<bool> isScrolledToTop = ValueNotifier<bool>(false);

  @override
  void dispose() {
    timer?.cancel();

    screenFocusOut();
    super.dispose();
  }

  bool orderFetchDone = false;

  void callStreamEvents() {}

  @override
  void quote1responseCallback(ResponseData data) {
    basketBloc.add(BasketStreamingResponseEvent(data));
  }

  final ScrollController _scrollControllerForTopContent = ScrollController();

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          primary: true,
          title: Container(
            padding: EdgeInsets.zero,
            height: 60.w,
            color: Theme.of(context).snackBarTheme.backgroundColor,
            child: ValueListenableBuilder(
                valueListenable: isScrolledToTop,
                builder: (context, value, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: backIconButton(
                            height: AppWidgetSize.dimen_25,
                            width: AppWidgetSize.dimen_25),
                      ),
                      if (isScrolledToTop.value)
                        BlocBuilder<BasketBloc, BasketState>(
                          builder: (context, state) {
                            if (state is FetchBasketOrdersDone) {
                              basketName = state.basketOrders.basketName ??
                                  widget.arguments.basketName;
                              return namecountWidget(
                                  context,
                                  state.basketOrders.basketName ??
                                      widget.arguments.basketName,
                                  isTop: true);
                            } else {
                              basketName = widget.arguments.basketName;
                              return namecountWidget(context, basketName ?? "",
                                  isTop: true);
                            }
                          },
                        ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 5.w,
                            ),
                            GestureDetector(
                              onTap: () async {
                                await pushNavigation(ScreenRoutes.editBasket,
                                    arguments: {
                                      "basketId": widget.arguments.basketId,
                                      "basketName": basketName ??
                                          widget.arguments.basketName
                                    });

                                basketBloc.add(FetchBasketOrdersEvent(
                                    widget.arguments.basketId));
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  top: AppWidgetSize.dimen_3,
                                  left: AppWidgetSize.dimen_16,
                                  right: AppWidgetSize.dimen_16,
                                  bottom: AppWidgetSize.dimen_3,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.w),
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                child: CustomTextWidget(
                                  _appLocalizations.edit,
                                  Theme.of(context)
                                      .primaryTextTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color:
                                              Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
          ),
          backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
        ),
        body: NestedScrollView(
          controller: _scrollControllerForTopContent,
          headerSliverBuilder: (BuildContext ctext, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(ctext),
                  sliver: SliverAppBar(
                      titleSpacing: 0,
                      automaticallyImplyLeading: false,
                      expandedHeight: 180.w,
                      pinned: false,
                      backgroundColor: Colors.transparent,
                      toolbarHeight: 0,
                      flexibleSpace:
                          FlexibleSpaceBar(background: _buildTopbar()))),
            ];
          },
          body: buildBody(context),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<BasketBloc, BasketState>(
              builder: (context, state) {
                return (basketBloc
                        .ordersDoneState.basketOrders.isexecuteAllorder)
                    ? Padding(
                        padding: EdgeInsets.only(top: 10.w),
                        child: gradientButtonWidget(
                            onTap: () {
                              basketBloc.add(ExecuteBasketOrdersEvent(
                                  BasketOrderBook(orders: orderList)));
                            },
                            width: AppWidgetSize.fullWidth(context) / 1.8,
                            key: const Key("executeBasket"),
                            context: context,
                            title: AppLocalizations().executeAllorder,
                            isGradient: true,
                            fontsize: 20.w,
                            bottom: 25.w),
                      )
                    : (basketBloc
                                .ordersDoneState.basketOrders.orders?.isEmpty ??
                            true)
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.only(top: 10.w),
                            child: gradientButtonWidget(
                                onTap: () {
                                  basketBloc.add(ResetBasketEvent(
                                      widget.arguments.basketId));
                                },
                                width: AppWidgetSize.fullWidth(context) / 1.8,
                                key: const Key("resetBasket"),
                                context: context,
                                title: _appLocalizations.reset,
                                isGradient: true,
                                fontsize: 20.w,
                                bottom: 25.w),
                          );
              },
            ),
          ],
        ));
  }

  Widget _buildTopbar() {
    return BlocBuilder<BasketBloc, BasketState>(
      builder: (context, state) {
        return SizedBox(
          child: Stack(
            children: [
              Container(
                height: (basketBloc
                            .ordersDoneState.basketOrders.orders?.isNotEmpty ??
                        false)
                    ? 120.w
                    : 120.w,
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                  left: AppWidgetSize.dimen_20,
                  right: AppWidgetSize.dimen_20,
                ),
                color: Theme.of(context).snackBarTheme.backgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BlocBuilder<BasketBloc, BasketState>(
                      builder: (context, state) {
                        if (state is FetchBasketOrdersDone) {
                          basketName = state.basketOrders.basketName ??
                              widget.arguments.basketName;
                          return namecountWidget(
                              context,
                              state.basketOrders.basketName ??
                                  widget.arguments.basketName);
                        } else {
                          basketName = widget.arguments.basketName;
                          return namecountWidget(context, basketName ?? "");
                        }
                      },
                    ),
                  ],
                ),
              ),
              if (basketBloc.ordersDoneState.basketOrders.orders?.isNotEmpty ??
                  false)
                Positioned(
                  bottom: 0.h,
                  left: 10.w,
                  child: SizedBox(
                    height: 80.w,
                    width: AppWidgetSize.screenWidth(context) - 25.w,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: 2,
                      itemBuilder: (BuildContext context, int index) {
                        return boxcontent(index);
                      },
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  Padding namecountWidget(BuildContext context, String name,
      {bool isTop = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.w, left: isTop ? 10.w : 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextWidget(
                      name,
                      Theme.of(context).primaryTextTheme.displaySmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: isTop ? 18.w : 24.w,
                          color: Theme.of(context)
                              .primaryTextTheme
                              .labelLarge
                              ?.color),
                      textAlign: TextAlign.left),
                  Padding(
                    padding: EdgeInsets.only(left: 10.w),
                    child: BlocBuilder<BasketBloc, BasketState>(
                      builder: (context, state) {
                        if (state is FetchBasketOrdersDone) {
                          return Padding(
                            padding: EdgeInsets.only(top: 7.h),
                            child: CustomTextWidget(
                              "${state.basketOrders.orders?.length}/20",
                              Theme.of(context).textTheme.titleLarge,
                            ),
                          );
                        } else {
                          return Padding(
                            padding: EdgeInsets.only(top: 7.h),
                            child: CustomTextWidget(
                              "0/20",
                              Theme.of(context).textTheme.titleLarge,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: isTop ? 2.w : 7.h),
                    child: CustomTextWidget(
                      widget.arguments.basktCrtdAt,
                      Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  _buildOrderbookContentWidget(
    BuildContext context,
    List<Orders> orders,
  ) {
    return (orders.isNotEmpty)
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int index = 0; index < orders.length; index++)
                BasketRowWidget(
                  orders: orders[index],
                  onRowClick: (Orders selected) {
                    marketStatusBloc =
                        BlocProvider.of<MarketStatusBloc>(context);
                    _ordersBloc = BlocProvider.of<OrdersBloc>(context);
                    marketStatusBloc.add(GetMarketStatusEvent(selected.sym!));
                    _orderLogBloc = BlocProvider.of<OrderLogBloc>(context);
                    _orderLogBloc.add(OrderStatusLogEvent(
                        normal_order.Orders.fromJson(selected.toJson())));
                    showOrderbookBottomSheet(selected);
                  },
                  isBottomSheet: false,
                  isaddBasket: true,
                  isExecuteallorder:
                      basketBloc.ordersDoneState.basketOrders.isexecuteAllorder,
                  onTap: () {
                    isPop = false;
                    basketBloc.add(ExecuteBasketOrdersEvent(
                        BasketOrderBook(orders: [orders[index]])));
                  },
                ),
            ],
          )

        /*  gradientButtonWidget(
                    onTap: () {},
                    width: AppWidgetSize.fullWidth(context) / 1.5,
                    key: const Key("executeBasket"),
                    context: context,
                    title: AppLocalizations().executeAllorder,
                    isGradient: true,
                    fontsize: 20.w), */

        : _buildEmptyBasketWidget();
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
          child: MultiBlocProvider(
            providers: [
              BlocProvider<OrdersBloc>.value(
                value: _ordersBloc,
              ),
              BlocProvider<OrderPadBloc>.value(
                value: orderPadBloc,
              ),
              BlocProvider<BasketBloc>.value(
                value: basketBloc,
              ),
            ],
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
          _getButtonWidget(
            _appLocalizations.clone,
            () {
              popNavigation();
              orderPadBloc.add(OrderPadPlaceOrderEvent(
                  (orders
                        ..remarks = ""
                        ..ordId = ""
                        ..parOrdId = ""
                        ..pos = (orderList.last.pos ?? 0) + 1)
                      .toJson(),
                  false,
                  basketorder: true));
            },
            context,
            true,
            true,
          ),
          _getButtonWidget(
            _appLocalizations.modify,
            () async {
              popNavigation();
              final Map<String, dynamic> arguments = <String, dynamic>{
                'action': (orders.ordAction?.toLowerCase() == "buy")
                    ? _appLocalizations.buy
                    : _appLocalizations.sell,
                'symbolItem': normal_order.Orders.fromJson(orders.toJson()),
                'orders': normal_order.Orders.fromJson(orders.toJson()),
                AppConstants.orderbookSelectedOrder: _appLocalizations.modify,
                "basketData": {
                  "fromBasket": true,
                  "basketOrderId": orders.basketOrderId,
                  "basketId": orders.basketId,
                  "position": orders.pos
                }
              };
              await pushNavigation(
                ScreenRoutes.orderPadScreen,
                arguments: arguments,
              );

              basketBloc.add(FetchBasketOrdersEvent(widget.arguments.basketId));
            },
            context,
            false,
            true,
          )
        ],
      ),
    );
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
                  color: AppColors().positiveColor,
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
                  : AppColors().positiveColor),
        ),
      ),
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
          if (orders.status != null)
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_10,
                bottom: AppWidgetSize.dimen_10,
              ),
              child: getOrderStatusImage(orders.status!),
            ),
          BasketRowWidget(
            orders: orders,
            onRowClick: () {},
            isBottomSheet: true,
          ),
          BlocBuilder<BasketBloc, BasketState>(
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

  Widget _buildEmptyBasketWidget() {
    return RefreshWidget(
        onRefresh: () {
          basketBloc.add(FetchBasketOrdersEvent(widget.arguments.basketId));
        },
        child: ListView(
          shrinkWrap: false,
          children: [
            buildEmptyWidget(
                topPadding: 0,
                emptyImage: AppImages.noBasketOrders(
                  context,
                ),
                context: context,
                description1: "Place a new order",
                description2:
                    "Dont wait for your time start trading with us for secure investment.",
                buttonInRow: false,
                button1Title: "Add new",
                button2Title: "",
                onButton1Tapped: () async {
                  await pushNavigation(ScreenRoutes.searchScreen, arguments: {
                    "backIconDisable": false,
                    "basketData": {
                      "fromBasket": true,
                      "basketOrderId": "",
                      "basketId": widget.arguments.basketId,
                      "position": orderList.isEmpty
                          ? 1
                          : ((orderList.last.pos ?? 0) + 1)
                    }
                  });
                  basketBloc
                      .add(FetchBasketOrdersEvent(widget.arguments.basketId));
                },
                button1Icon: Padding(
                  padding: EdgeInsets.only(right: 5.w),
                  child: AppImages.addUnfilledIcon(
                    context,
                    color: Theme.of(context).primaryColorLight,
                    isColor: true,
                    height: 25.w,
                    width: 25.w,
                  ),
                )),
          ],
        ));
  }

  //-------
  Widget buildBody(BuildContext context) {
    return BlocBuilder<BasketBloc, BasketState>(
      buildWhen: (BasketState previous, BasketState current) {
        return current is FetchBasketOrdersDone ||
            current is BasketError ||
            current is FetchBasketOrderLoading ||
            current is ResetBasketLoading ||
            current is ExecuteBasketOrdersLoading;
      },
      builder: (context, state) {
        if (state is FetchBasketOrderLoading ||
            state is ResetBasketLoading ||
            state is ExecuteBasketOrdersLoading) {
          return const LoaderWidget();
        }
        if (state is FetchBasketOrdersDone) {
          if (state.basketOrders.orders != null &&
              (state.basketOrders.orders?.isNotEmpty ?? false)) {
            orderList = state.basketOrders.orders!;
            return buildBodyContent(
              context,
              state.basketOrders.orders!, //fixhere
            );
          } else {
            return _buildEmptyBasketWidget();
          }
        } else if (state is OrdersFailedState ||
            state is OrdersServiceExceptionState) {
          return _buildEmptyBasketWidget();
        } else if (state is OrdersServiceExceptionState) {
          return Center(
            child: errorWithImageWidget(
              context: context,
              imageWidget: AppUtils().getNoDateImageErrorWidget(context),
              errorMessage: state.errorMsg,
              padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_30,
                right: AppWidgetSize.dimen_30,
                bottom: AppWidgetSize.dimen_30,
              ),
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
    return RefreshWidget(
        onRefresh: () {
          basketBloc.add(FetchBasketOrdersEvent(widget.arguments.basketId));
        },
        child: SingleChildScrollView(
          child: Container(
            width: AppWidgetSize.screenWidth(context),
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_15,
              left: AppWidgetSize.dimen_25,
              right: AppWidgetSize.dimen_30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (orders.isNotEmpty && (orders.length < 20))
                  _buildSearchTextBox(
                    orders,
                  ),
                _buildOrderbookContentWidget(
                  context,
                  orders,
                ),
              ],
            ),
          ),
        ));
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
        child: TextField(
          readOnly: true,
          cursorColor: Theme.of(context).iconTheme.color,
          enableInteractiveSelection: true,
          autocorrect: false,
          enabled: true,
          controller: _searchController,
          textCapitalization: TextCapitalization.characters,
          onTap: () async {
            await pushNavigation(ScreenRoutes.searchScreen, arguments: {
              "backIconDisable": false,
              "basketData": {
                "fromBasket": true,
                "basketOrderId": "",
                "basketId": widget.arguments.basketId,
                "position": orderList.isEmpty ? 1 : (orderList.length + 1)
              }
            });
            basketBloc.add(FetchBasketOrdersEvent(widget.arguments.basketId));
          },
          /* onChanged: (String text) {
            if (text != "") {
              _ordersBloc.add(OrdersSearchEvent(
                _searchController.text,
                orders,
              ));
            } else {
              _ordersBloc.add(OrdersResetSearchEvent());
            }
          }, */
          textInputAction: TextInputAction.done,
          inputFormatters: InputValidator.searchSymbol,
          style: Theme.of(context)
              .primaryTextTheme
              .labelLarge!
              .copyWith(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            suffixIconConstraints: BoxConstraints(
              maxHeight: AppWidgetSize.dimen_25,
              minHeight: AppWidgetSize.dimen_25,
            ),
            prefixIconConstraints: BoxConstraints(
              maxHeight: AppWidgetSize.dimen_20,
              minHeight: AppWidgetSize.dimen_20,
            ),
            prefixIcon: _buildSearch(context),
            suffixIcon: _searchController.text.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(right: 5.w),
                    child: GestureDetector(
                      onTap: () {
                        isSearchSelected = false;

                        _searchController.text = '';
                        setState(() {});
                        _ordersBloc.add(OrdersResetSearchEvent());
                      },
                      child: AppImages.deleteIcon(
                        context,
                        width: AppWidgetSize.dimen_20,
                        height: AppWidgetSize.dimen_20,
                        color: Theme.of(context).primaryIconTheme.color,
                      ),
                    ),
                  )
                : null,
            border: myinputborder(),
            focusedBorder: myinputborder(),
            enabledBorder: myinputborder(),
            errorBorder: myinputborder(),
            disabledBorder: myinputborder(),
            contentPadding: EdgeInsets.only(
                top: AppWidgetSize.dimen_10,
                bottom: AppWidgetSize.dimen_7,
                right: AppWidgetSize.dimen_10,
                left: 5.3),
            hintText: _appLocalizations.addBaskethint,
            hintStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                fontSize: 14.w,
                color: Theme.of(context).dialogBackgroundColor.withAlpha(-1)),
            counterText: '',
          ),
          maxLength: 25,
        ),
      ),
    );
  }

  OutlineInputBorder myinputborder() {
    return OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        borderSide: BorderSide(
          color: Theme.of(context).primaryIconTheme.color!,
          width: 0.3,
        ));
  }

  // Widget _buildToolBarWidget(
  //   BuildContext context,
  // ) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.end,
  //     children: [
  //       IntrinsicHeight(
  //         child: Row(
  //           children: [_buildSearch(context)],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSearch(BuildContext context) {
    return GestureDetector(
      onTap: () {
        isSearchSelected = true;
        setState(() {});
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_5,
          right: AppWidgetSize.dimen_5,
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

  //----------------------------
  Widget boxcontent(index) {
    return Container(
      margin: EdgeInsets.only(left: AppWidgetSize.dimen_8),
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_8,
        bottom: AppWidgetSize.dimen_8,
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
      child: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_5,
          right: AppWidgetSize.dimen_5,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 5.w, bottom: 5.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextWidget(
                          AppUtils().dataNullCheck(index == 0
                              ? _appLocalizations.availableMargin
                              : _appLocalizations.requiredMargin),
                          Theme.of(context)
                              .primaryTextTheme
                              .bodySmall!
                              .copyWith(
                                fontSize: 14.w,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        AppImages.informationIcon(
                          context,
                          color: Theme.of(context).primaryIconTheme.color,
                          isColor: true,
                          width: AppWidgetSize.dimen_22,
                          height: AppWidgetSize.dimen_22,
                        ),
                      ],
                    ),
                  ),
                  BlocBuilder<BasketBloc, BasketState>(
                    buildWhen: (previous, current) =>
                        current is MarginCalculatorDone ||
                        current is MarginCalculatorLoading ||
                        current is FetchBasketOrderLoading,
                    builder: (context, basketState) {
                      logError("logName", basketState);
                      return BlocBuilder<AddFundsBloc, AddFundsState>(
                          buildWhen: (previous, current) {
                        return current
                            is AddFundBuyPowerandWithdrawcashDoneState;
                      }, builder: (context, state) {
                        return Padding(
                            padding: EdgeInsets.only(left: 5.w, top: 5.w),
                            child: _getLableWithRupeeSymbol(
                                index == 0
                                    ? (state
                                            is AddFundBuyPowerandWithdrawcashDoneState)
                                        ? AppUtils().dataNullCheckDashDash(
                                            state.buy_power)
                                        : "--"
                                    : AppUtils().commaFmt(
                                        basketBloc.fetchBasketDone.marigin ??
                                            "--"),
                                Theme.of(context)
                                    .primaryTextTheme
                                    .labelSmall!
                                    .copyWith(
                                      fontSize: 20.w,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: AppConstants.interFont,
                                    ),
                                Theme.of(context)
                                    .primaryTextTheme
                                    .labelLarge!
                                    .copyWith(
                                        fontSize: 20.w,
                                        fontWeight: FontWeight.w600,
                                        color: index == 0
                                            ? AppUtils().profitLostColor(
                                                AppUtils()
                                                    .dataNullCheckDashDash(
                                                        "38,999"))
                                            : null),
                                forceShimmer: index == 1 &&
                                    (basketState is MarginCalculatorLoading ||
                                        basketState
                                            is FetchBasketOrderLoading ||
                                        basketBloc.fetchBasketDone.marigin ==
                                            null)));
                      });
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getLableWithRupeeSymbol(
      String value, TextStyle rupeeStyle, TextStyle textStyle,
      {bool forceShimmer = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextWidget(
          "${AppConstants.rupeeSymbol} $value",
          textStyle,
          forceShimmer: forceShimmer,
        ),
      ],
    );
  }

  Future<void> moveOrderDetailswithpop(Orders orders) async {
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 200), () {});

    _movetoOrderDetailScreen(orders);
  }

  Future<void> _movetoOrderDetailScreen(
    Orders orders,
  ) async {
    await Navigator.push(
        context,
        SlideUpRoute(
            page: BlocProvider.value(
          value: _orderLogBloc,
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: _ordersBloc,
              ),
              BlocProvider(
                create: (context) => OrderPadBloc(),
              ),
            ],
            child: BlocProvider.value(
              value: marketStatusBloc,
              child: OrdersDetailScreen(
                arguments: {
                  'orders': normal_order.Orders.fromJson(
                      (orders..pos = (orderList.length)).toJson()),
                  'selectedFilters': selectedFilters,
                  'selectedSort': selectedSort,
                  "marketStatusBloc": marketStatusBloc,
                  "ordersBloc": _ordersBloc,
                  "orderslogbloc": _orderLogBloc,
                  "orderpadBloc": orderPadBloc,
                  "basketBloc": basketBloc,
                  "isBasket": true,
                  "length": orderList.length
                },
              ),
            ),
          ),
        )));

    Future.delayed(const Duration(milliseconds: 100), () {
      /*  orderbookApiCallWithFilters(selectedFilters, selectedSort,
          fetchagain: true, loading: false); */
    });
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.addBasket;
  }
}
