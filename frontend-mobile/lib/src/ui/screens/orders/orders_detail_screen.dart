import 'package:acml/src/blocs/basket_order/basket_bloc.dart';
import 'package:acml/src/ui/screens/acml_app.dart';
import 'package:acml/src/ui/screens/basket_order/widgets/basket_row_widget.dart';
import 'package:acml/src/ui/screens/orders/widgets/order_row_widget.dart';
import 'package:acml/src/ui/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import '../../../models/orders/order_book.dart' as normal_order;

import '../../../blocs/market_status/market_status_bloc.dart';
import '../../../blocs/order_pad/order_pad_bloc.dart';
import '../../../blocs/orders/order_log/order_log_bloc.dart';
import '../../../blocs/orders/orders_bloc.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_constants.dart';
import '../../../data/store/app_calculator.dart';
import '../../../data/store/app_helper.dart';
import '../../../data/store/app_store.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/orders/order_book.dart';
import '../../../models/orders/order_status_log.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/build_error_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/expansion_tile.dart';
import '../../widgets/webview_widget.dart';
import '../base/base_screen.dart';
import '../route_generator.dart';
import '../watchlist/widget/alert_bottomsheet_widget.dart';
import 'widgets/list_of_trades.dart';

class OrdersDetailScreen extends BaseScreen {
  final dynamic arguments;

  const OrdersDetailScreen({
    Key? key,
    this.arguments,
  }) : super(key: key);

  @override
  State<OrdersDetailScreen> createState() => _OrdersDetailScreenState();
}

class _OrdersDetailScreenState extends BaseAuthScreenState<OrdersDetailScreen> {
  late AppLocalizations _appLocalizations;
  late OrdersBloc _ordersBloc;
  late OrderLogBloc _orderLogBloc;
  late MarketStatusBloc marketStatusBloc;
  late Orders orders;
  String tappedButtonHeader = '';
  ValueNotifier<bool> showAll = ValueNotifier<bool>(false);
  bool isBasket = false;
  late OrderPadBloc orderPadBloc;
  late BasketBloc basketBloc;

  @override
  void initState() {
    orders = widget.arguments['orders'];
    isBasket = widget.arguments["isBasket"] ?? false;

    if (isBasket) {
      basketBloc = widget.arguments["basketBloc"];
      orderPadBloc = widget.arguments["orderpadBloc"];
      orderPadBloc = BlocProvider.of<OrderPadBloc>(context)
        ..stream.listen((event) {
          if (event is OrderPadPlaceOrderDoneState) {
            basketBloc.add(FetchBasketOrdersEvent(orders.basketId ?? ""));
          } else if (event is OrderPadPlaceOrderServiceExceptionState ||
              event is OrderPadPlaceOrderFailedState) {
            showToast(message: event.errorMsg, isError: true);
          }
        });
    }

    _orderLogBloc = widget.arguments["orderslogbloc"]
      ..stream.listen(_orderLogListener);
    if (_orderLogBloc.state is OrderLogStreamState) {
      if (_orderLogBloc.ordersStatusLogStreamState.streamDetails != null) {
        /*  subscribeLevel1(
            _orderLogBloc.ordersStatusLogStreamState.streamDetails!); */
      }
    }
    marketStatusBloc = widget.arguments["marketStatusBloc"];
    _ordersBloc = widget.arguments["ordersBloc"]
      ..stream.listen(_orderBookListener);
    Future.delayed(const Duration(milliseconds: 200), () {
      subscribeLevel1(AppHelper().streamDetails(
        [Symbols.fromJson(orders.toJson())],
        [
          AppConstants.streamingLtp,
          AppConstants.streamingChng,
          AppConstants.streamingChgnPer,
        ],
      ));
    });
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.orderDetailScreen);
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.orderDetailScreen;
  }

  Future<void> _orderBookListener(OrdersState state) async {
    if (state is! OrdersProgressState) {
      if (mounted) {}
    }
    if (state is OrdersProgressState) {
      if (mounted) {}
    } else if (state is OrdersCancelDoneState) {
      showToast(
        message: state.baseModel.infoMsg,
      );
      postSetState();
    } else if (state is OrdersCancelFailedState ||
        state is OrdersCancelServiceExceptionState) {
      showToast(
        message: state.errorMsg,
        isError: true,
      );
      postSetState();
    } else if (state is OrdersStatusLogDoneState) {
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

  void postSetState({Function()? function}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          if (function != null) {
            function();
          }
        });
      }
    });
  }

  Future<void> _orderLogListener(OrderLogState state) async {
    if (state is! OrderLogProgressState) {
      if (mounted) {
        //stopLoader();
      }
    }
    if (state is OrderLogProgressState) {
      if (mounted) {
        // startLoader();
      }
    } else if (state is OrderLogStreamState) {
      if (state.streamDetails != null) {
        subscribeLevel1(state.streamDetails!);
      }
    } else if (state is OrderLogErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  @override
  void quote1responseCallback(ResponseData data) {
    _orderLogBloc.add(OrderLogStreamingResponseEvent(data));
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        persistentFooterButtons: [
          _buildPersistentFooterBlocBuilder(),
        ],
      ),
    );
  }

  Widget _buildPersistentFooterBlocBuilder() {
    return _buildPersistentFooterWidget(orders);
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      toolbarHeight: AppWidgetSize.dimen_60,
      elevation: 0,
      shadowColor: Theme.of(context).dividerColor.withOpacity(0.5),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_25,
          right: AppWidgetSize.dimen_25,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildOrderStatusImage(),
            GestureDetector(
              onTap: () {
                popNavigation();
              },
              child: AppImages.close(context,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true,
                  width: 30.w,
                  height: 30.w),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusImage() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
        bottom: AppWidgetSize.dimen_10,
      ),
      child: BlocBuilder<OrderLogBloc, OrderLogState>(
        buildWhen: (previous, current) {
          return current is OrdersStatusLogDoneState ||
              current is OrdersStatusLogFailedState ||
              current is OrdersStatusLogServiceExceptionState;
        },
        builder: (context, state) {
          return getOrderStatusImage((orders.status ?? ""));
        },
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<OrderLogBloc, OrderLogState>(
      buildWhen: (previous, current) {
        return current is OrdersStatusLogDoneState ||
            current is OrdersStatusLogFailedState ||
            current is OrdersStatusLogServiceExceptionState ||
            current is OrderLogStreamState;
      },
      builder: (context, state) {
        orders.tradedQty = (AppUtils().intValue(_orderLogBloc
                    .ordersStatusLogDoneState
                    .orderStatusLog
                    ?.ordDtls
                    ?.tradedQty ??
                orders.tradedQty))
            .toString();
        orders.listOfTrades =
            _orderLogBloc.ordersStatusLogDoneState.orderStatusLog?.listOfTrades;

        orders.ordAction = _orderLogBloc
                .ordersStatusLogDoneState.orderStatusLog?.ordDtls?.ordAction ??
            orders.ordAction;
        /* orders.ordDuration =
              _orderLogBloc
                      .ordersStatusLogDoneState.orderStatusLog?.ordDtls?.ordDuration ?? orders.ordDuration; */
        _orderLogBloc
                .ordersStatusLogDoneState.orderStatusLog?.ordDtls?.ordAction ??
            orders.ordAction;
        orders.triggerPrice = _orderLogBloc.ordersStatusLogDoneState
                .orderStatusLog?.ordDtls?.triggerPrice ??
            orders.triggerPrice;
        orders.prdType = _orderLogBloc
                .ordersStatusLogDoneState.orderStatusLog?.ordDtls?.prdType ??
            orders.prdType;
        orders.qty = (AppUtils().intValue(_orderLogBloc
                    .ordersStatusLogDoneState.orderStatusLog?.ordDtls?.qty ??
                orders.qty))
            .toString();
        orders.exchOrdId = _orderLogBloc
                .ordersStatusLogDoneState.orderStatusLog?.ordDtls?.exchOrdId ??
            orders.exchOrdId;
        orders.disQty = (AppUtils().intValue(_orderLogBloc
                    .ordersStatusLogDoneState.orderStatusLog?.ordDtls?.disQty ??
                orders.disQty))
            .toString();
        orders.ordId = _orderLogBloc
                .ordersStatusLogDoneState.orderStatusLog?.ordDtls?.ordId ??
            orders.ordId;

        orders.ordType = _orderLogBloc
                .ordersStatusLogDoneState.orderStatusLog?.ordDtls?.ordType ??
            orders.ordType;
        orders.status = _orderLogBloc.ordersStatusLogDoneState.orderStatusLog
                ?.ordDtls?.currentOrdStatus ??
            orders.status;
        if (state is OrdersStatusLogFailedState ||
            state is OrdersStatusLogServiceExceptionState) {
          return _buildBodyContentWidget(orders, errorMsg: state.errorMsg);
        } else if (state is OrderLogProgressState ||
            state is OrderLogStreamState) {
          return _buildBodyContentWidget(
            orders,
          );
        }
        return Container();
      },
    );
  }

  Widget _buildBodyContentWidget(Orders orders, {String errorMsg = ""}) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isBasket
                ? BasketRowWidget(
                    orders: orders,
                    onRowClick: () {},
                    isBottomSheet: true,
                  )
                : OrdersRowWidget(
                    orders: orders,
                    isFromGtd: widget.arguments["fromGtd"] ?? false,
                    onRowClick: () {},
                    isBottomSheet: true,
                  ),
            _buildLtp(
              orders,
            ),
            SizedBox(
              height: AppWidgetSize.dimen_10,
            ),
            _buildTwoLabelsWidget(
              _appLocalizations.orderType,
              AppUtils().dataNullCheck(orders.ordType?.toLowerCase()) ==
                          AppConstants.market.toLowerCase() ||
                      AppUtils().dataNullCheck(orders.ordType?.toLowerCase()) ==
                          AppConstants.limit.toLowerCase()
                  ? AppUtils()
                      .dataNullCheck(orders.ordType?.capitalizeFirstofEach)
                  : AppUtils().dataNullCheck(orders.ordType?.toUpperCase()),
            ),
            _buildTwoLabelsWidget(
              _appLocalizations.validity,
              AppUtils().dataNullCheck(orders.ordDuration),
            ),
            if (/* orders.ordDuration != AppConstants.gtd && */
            !(widget.arguments?["fromGtd"] ?? false))
              _buildTwoLabelsWidget(
                _appLocalizations.orderValue,
                AppUtils().dataNullCheck(_orderValue(orders.tradedQty,
                    orders.avgPrice ?? "0.00", orders.sym!.exc!)),
              ),
            if (orders.ordType?.toLowerCase() ==
                    AppConstants.sl.toLowerCase() ||
                orders.ordType?.toLowerCase() == AppConstants.slM.toLowerCase())
              _buildTwoLabelsWidget(
                _appLocalizations.triggerPrice,
                AppUtils().dataNullCheck(orders.triggerPrice),
              ),
            if (orders.disQty != null)
              _buildTwoLabelsWidget(
                _appLocalizations.disclosedQty,
                AppUtils().dataNullCheck(orders.disQty),
              ),
            if (orders.ordValidDte?.isNotEmpty ?? false)
              _buildTwoLabelsWidget(
                _appLocalizations.validityDate,
                AppUtils().dataNullCheck(orders.ordValidDte),
              ),
            _buildTwoLabelsWidget(
              _appLocalizations.orderId,
              AppUtils().dataNullCheck(orders.ordId),
              isCopy: true,
            ),
            if (widget.arguments?["fromGtd"] == true)
              _buildTwoLabelsWidget(
                "Trigger Id",
                AppUtils().dataNullCheck(orders.triggerid),
                isCopy: true,
              ),
            if ((orders.status ?? "").toLowerCase() !=
                AppConstants.rejected.toLowerCase())
              _buildTwoLabelsWidget(
                _appLocalizations.exchangeOrdId,
                AppUtils().dataNullCheckDashDash(orders.exchOrdId),
                isCopy: true,
              ),
            SizedBox(
              height: AppWidgetSize.dimen_10,
            ),
            Divider(
              thickness: AppWidgetSize.dimen_1,
              color: Theme.of(context).dividerColor,
            ),
            if (orders.listOfTrades?.isNotEmpty ?? false)
              ListOfTradesWidget(orders),
            Column(
              children: [
                _buildOrderStatusTitleAndNeedHelp(),
                errorMsg.isNotEmpty
                    ? errorWithImageWidget(
                        context: context,
                        imageWidget:
                            AppUtils().getNoDateImageErrorWidget(context),
                        errorMessage: errorMsg,
                        padding: EdgeInsets.only(
                          left: AppWidgetSize.dimen_30,
                          right: AppWidgetSize.dimen_30,
                          bottom: AppWidgetSize.dimen_30,
                        ),
                      )
                    : _buildOrderlogContent(
                        context,
                      ),
              ],
            ),
            if ((orders.status ?? "").toLowerCase() ==
                    AppConstants.rejected.toLowerCase() ||
                (orders.status ?? "").toLowerCase() ==
                    AppConstants.cancelled.toLowerCase())
              Padding(
                padding: EdgeInsets.only(
                  top: 20.w,
                  bottom: AppWidgetSize.dimen_20,
                ),
                child: (orders.rejReason != '--' &&
                        orders.rejReason != "" &&
                        orders.rejReason != null)
                    ? buildErrorWidget(
                        true,
                        orders.rejReason ?? "--",
                        false,
                        context,
                      )
                    : Container(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderlogContent(
    BuildContext context,
  ) {
    return BlocBuilder<OrderLogBloc, OrderLogState>(
      builder: (BuildContext context, OrderLogState state) {
        final OrderStatusLog orderData =
            _orderLogBloc.ordersStatusLogDoneState.orderStatusLog ??
                OrderStatusLog();
        orders = _orderLogBloc.ordersStatusLogDoneState.orders!;
        if (state is OrderLogProgressState) {
          return SizedBox(height: 200.w, child: const LoaderWidget());
        } else if (state is OrdersStatusLogDoneState ||
            (_orderLogBloc.ordersStatusLogDoneState.orderStatusLog != null &&
                _orderLogBloc.ordersStatusLogDoneState.orders != null)) {
          if (externalChargesExpanded?.isEmpty ?? true) {
            externalChargesExpanded = List.generate(
              orderData.history?.length ?? 0,
              (index) => ValueNotifier(false),
            );
          }

          return Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_20,
              bottom: AppWidgetSize.dimen_20,
            ),
            child: (orderData.history?.length ?? 0) > 0
                ? (widget.arguments["fromGtd"] ?? false)
                    ? ValueListenableBuilder<bool>(
                        valueListenable: showAll,
                        builder: (context, value, _) {
                          return Column(
                            children: [
                              ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(0),
                                  shrinkWrap: true,
                                  itemCount:
                                      (orderData.history?.length ?? 0) > 5 &&
                                              !showAll.value
                                          ? 5
                                          : (orderData.history?.length ?? 0),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      children: [
                                        buildExpandableList(
                                            context,
                                            "header",
                                            "headerValue",
                                            orderData.history![index],
                                            index),
                                        Divider(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ],
                                    );
                                  }),
                              if ((orderData.history?.length ?? 0) > 5)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if ((orderData.history?.length ?? 0) > 5)
                                      GestureDetector(
                                        onTap: () {
                                          showAll.value = !showAll.value;
                                        },
                                        child: CustomTextWidget(
                                            !showAll.value
                                                ? "View more"
                                                : "View less",
                                            Theme.of(context)
                                                .primaryTextTheme
                                                .bodySmall!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary)),
                                      ),
                                  ],
                                )
                            ],
                          );
                        })
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(0),
                        shrinkWrap: true,
                        itemCount: orderData.history?.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          return _buildOrderStatusWidget(
                            index,
                            orderData,
                          );
                        })
                : errorWithImageWidget(
                    context: context,
                    imageWidget: AppUtils().getNoDateImageErrorWidget(context),
                    errorMessage:
                        AppLocalizations().noDataAvailableErrorMessage,
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_30,
                      right: AppWidgetSize.dimen_30,
                      bottom: AppWidgetSize.dimen_30,
                    ),
                  ),
          );
        } else if (state is OrdersStatusLogFailedState ||
            state is OrdersStatusLogServiceExceptionState) {}
        return Container();
      },
    );
  }

  Padding buildExpandableList(BuildContext context, String header,
      String headerValue, History history, int index) {
    return Padding(
      padding: EdgeInsets.only(top: 8.w),
      child: Theme(
        data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            cardColor: Theme.of(context).scaffoldBackgroundColor,
            colorScheme: Theme.of(context).colorScheme.copyWith(
                background: Theme.of(context).colorScheme.background)),
        child: ValueListenableBuilder<bool>(
            valueListenable: externalChargesExpanded![index],
            builder: (context, value, _) {
              return AppExpansionPanelList(
                key: const Key("key"),
                animationDuration: const Duration(milliseconds: 200),
                elevation: 0,
                expansionCallback: (int indexx, bool isExpanded) {
                  for (int i = 0; i < externalChargesExpanded!.length; i++) {
                    if (i == index) {
                      externalChargesExpanded![i].value =
                          !(externalChargesExpanded![i].value);
                    } else {
                      externalChargesExpanded![i].value = false;
                    }
                  }
                },
                children: [
                  ExpansionPanel(
                    canTapOnHeader: true,
                    body: Padding(
                      padding: EdgeInsets.only(top: 10.w),
                      child: Column(
                        children: [
                          _buildTwoLabelsWidget(
                              "Nest order no", history.ordId ?? "--",
                              isCopy: true),
                          _buildTwoLabelsWidget(
                              "Traded Qty.", history.tradedQty ?? "--"),
                          _buildTwoLabelsWidget(
                              "Rejected Qty.", history.rejectQty ?? "--"),
                          _buildTwoLabelsWidget(
                              "Cancelled Qty.", history.cancelQty ?? "--"),
                          /* _buildTwoLabelsWidget(
                              "Date & Time", history.lupdateDateTime ?? "--"), */
                          _buildTwoLabelsWidget(
                              "Order Source", history.ordSource ?? "--"),
                          _buildTwoLabelsWidget(
                              "Number of Days", history.noOfDays ?? "--"),
                        ],
                      ),
                    ),
                    headerBuilder: (context, isExpanded) {
                      return SizedBox(
                        width: AppWidgetSize.fullWidth(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextWidget(
                                  "Qty",
                                  Theme.of(context)
                                      .primaryTextTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5.w),
                                  child: CustomTextWidget(
                                    "${history.tradedQty.toString()}/${history.qty.toString()}",
                                    Theme.of(context)
                                        .primaryTextTheme
                                        .bodySmall,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                CustomTextWidget(
                                  "Price",
                                  Theme.of(context)
                                      .primaryTextTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5.w),
                                  child: CustomTextWidget(
                                    history.limitPrice.toString(),
                                    Theme.of(context)
                                        .primaryTextTheme
                                        .bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextWidget(
                                      "Traded Time",
                                      Theme.of(context)
                                          .primaryTextTheme
                                          .bodySmall!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 5.w),
                                      child: CustomTextWidget(
                                        history.lupdateDateTime.toString(),
                                        Theme.of(context)
                                            .primaryTextTheme
                                            .bodySmall,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 15.w),
                                  child: (externalChargesExpanded?[index]
                                              .value ??
                                          false)
                                      ? AppImages.upArrowIcon(context,
                                          color: Theme.of(
                                                  navigatorKey.currentContext!)
                                              .primaryIconTheme
                                              .color,
                                          isColor: true,
                                          width: 20.w)
                                      : AppImages.downArrow(context,
                                          color: Theme.of(
                                                  navigatorKey.currentContext!)
                                              .primaryIconTheme
                                              .color,
                                          isColor: true,
                                          width: 20.w),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    isExpanded: externalChargesExpanded?[index].value ?? false,
                  ),
                ],
              );
            }),
      ),
    );
  }

  Row historyRow(String heading, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(heading), Text(value)],
    );
  }

  List<ValueNotifier<bool>>? externalChargesExpanded;
  Row expandableChildRow(String label, String value,
      {String? lableBottom, bool isHeader = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              label,
              style: isHeader
                  ? Theme.of(navigatorKey.currentContext!)
                      .primaryTextTheme
                      .labelSmall
                  : Theme.of(navigatorKey.currentContext!)
                      .primaryTextTheme
                      .labelSmall
                      ?.copyWith(
                          fontSize: 14.w,
                          color: Theme.of(navigatorKey.currentContext!)
                              .primaryTextTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.8)),
            ),
            if (lableBottom != null)
              Container(
                constraints: BoxConstraints(
                    maxWidth: AppWidgetSize.screenWidth(context) * 0.55),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 4.0,
                    ),
                    child: CustomTextWidget(
                      lableBottom,
                      Theme.of(context)
                          .primaryTextTheme
                          .bodySmall
                          ?.copyWith(fontSize: 12.w),
                    ),
                  ),
                ),
              ),
          ],
        ),
        Container(
          constraints: BoxConstraints(
              maxWidth: AppWidgetSize.screenWidth(context) * 0.35),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: CustomTextWidget(
              '${AppConstants.rupeeSymbol} $value',
              isHeader
                  ? Theme.of(navigatorKey.currentContext!)
                      .primaryTextTheme
                      .labelSmall
                  : Theme.of(navigatorKey.currentContext!)
                      .primaryTextTheme
                      .labelSmall
                      ?.copyWith(
                          fontSize: 14.w,
                          color: Theme.of(navigatorKey.currentContext!)
                              .primaryTextTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatusWidget(
    int index,
    OrderStatusLog orderData,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDynamicOrderImage(
          index,
          orderData,
        ),
        _buildDynamicOrderStatus(
          index,
          orderData,
        ),
      ],
    );
  }

  Widget _buildDynamicOrderStatus(
    int index,
    OrderStatusLog orderData,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_15,
      ),
      child: Wrap(
        direction: Axis.vertical,
        alignment: WrapAlignment.start,
        children: [
          SizedBox(
            width: (AppWidgetSize.fullWidth(context) - 120.w),
            child: CustomTextWidget(
                "${orderData.history![index].ordStatus}",
                Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.left),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.h,
            ),
            child: CustomTextWidget(
              AppUtils()
                  .dataNullCheck(orderData.history![index].lupdateDateTime)
                  .toString(),
              Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicOrderImage(
    int index,
    OrderStatusLog orderData,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (index != 0)
          AppImages.orderPlaced(
            context,
          )
        else
          getOrderStatusImageForOrderLog((orders.status ?? "")),
        if (index != orderData.history!.length - 1)
          SizedBox(
            height: 50,
            child: VerticalDivider(
              width: 1.5,
              thickness: 1.5,
              color: Theme.of(context).dividerColor,
            ),
          ),
      ],
    );
  }

  Widget _buildTwoLabelsWidget(
    String title,
    String value, {
    bool isCopy = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_4,
        bottom: AppWidgetSize.dimen_4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
            title,
            Theme.of(context)
                .primaryTextTheme
                .bodySmall!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTextWidget(
                value,
                Theme.of(context).primaryTextTheme.bodySmall,
              ),
              if (isCopy)
                Padding(
                  padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_3,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      showToast(
                        message: "Copied",
                        context: context,
                      );
                    },
                    child: AppImages.copyIcon(context,
                        color: Theme.of(context).textTheme.labelSmall!.color,
                        isColor: true),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusTitleAndNeedHelp() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_4,
        bottom: AppWidgetSize.dimen_4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
            (widget.arguments?["fromGtd"] == true)
                ? _appLocalizations.orderHistory
                : _appLocalizations.orderStatus,
            Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (orders.status != "cancelled" &&
              (orders.status?.isNotEmpty ?? false))
            GestureDetector(
              onTap: () {
                pushNavigation(ScreenRoutes.orderHelpScreen,
                    arguments: (orders.status ?? "").toLowerCase());
              },
              child: CustomTextWidget(
                _appLocalizations.needHelp,
                Theme.of(context).primaryTextTheme.titleLarge,
              ),
            ),
        ],
      ),
    );
  }

  Widget getOrderStatusImage(
    String orderStatus,
  ) {
    if (orderStatus == "") return Container();
    if (orderStatus.toLowerCase() == AppConstants.executed.toLowerCase()) {
      return AppImages.executedStatus(context, width: 30.w, height: 30.w);
    } else if (orderStatus.toLowerCase() ==
        AppConstants.pending.toLowerCase()) {
      return AppImages.pendingStatus(context, width: 30.w, height: 30.w);
    } else {
      return AppImages.rejectedStatus(context, width: 30.w, height: 30.w);
    }
  }

  Widget getOrderStatusImageForOrderLog(
    String orderStatus,
  ) {
    if (orderStatus.toLowerCase() == AppConstants.executed.toLowerCase()) {
      return AppImages.orderPlaced(context);
    } else if (orderStatus.toLowerCase() ==
        AppConstants.pending.toLowerCase()) {
      return AppImages.orderPending(context);
    } else {
      return AppImages.orderRejected(context);
    }
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
          BlocBuilder<OrderLogBloc, OrderLogState>(
            builder: (context, state) {
              return Flexible(
                flex: 7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomTextWidget(
                      AppUtils().dataNullCheckDashDash(
                          _orderLogBloc.orderStream.orders?.ltp),
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
                        AppUtils().getChangePercentage(
                            _orderLogBloc.orderStream.orders ?? orders),
                        Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        isShowShimmer: true,
                      ),
                    ),
                  ],
                ),
              );
            },
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
                      : AppColors
                          .negativeColor //Theme.of(context).colorScheme.errorContainer,
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
          if (isBasket)
            _getButtonWidget(
              _appLocalizations.clone,
              () {
                popNavigation();
                orderPadBloc.add(OrderPadPlaceOrderEvent(
                    (orders..pos = ((widget.arguments["length"] ?? 0) + 1))
                        .toJson(),
                    false,
                    basketorder: isBasket));
              },
              context,
              true,
              true,
            ),
          if (isBasket)
            _getButtonWidget(
              _appLocalizations.modify,
              () async {
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

                basketBloc.add(FetchBasketOrdersEvent(orders.basketId ?? ""));
              },
              context,
              false,
              true,
            ),
          if (!isBasket)
            if ((orders.status ?? "").toLowerCase() !=
                AppConstants.rejected.toLowerCase())
              _getButtonWidget(
                  _getLeftFooterButtonTitle(
                    orders.cancellable,
                    orders.status,
                    orders.exitable,
                  ), () {
                buttonPressed(orders);
              },
                  context,
                  true,
                  (orders.status ?? "").toLowerCase() !=
                      AppConstants.rejected.toLowerCase()),
          if (!isBasket)
            _getButtonWidget(
                _getRightFooterButtonTitle(orders.modifiable, orders.status,
                    orders.actCode, orders.actDisp), () {
              buttonPressed(orders);
            },
                context,
                false,
                (orders.status ?? "").toLowerCase() !=
                    AppConstants.rejected.toLowerCase()),
        ],
      ),
    );
  }

  String _getLeftFooterButtonTitle(
      String? cancellable, String? status, String? exitable) {
    if (status?.toLowerCase() == AppConstants.pending.toLowerCase() ||
        status?.toLowerCase() == AppConstants.triggeredPending.toLowerCase()) {
      if (cancellable == AppConstants.trueConstant) {
        return _appLocalizations.cancel;
      } else if (exitable == AppConstants.trueConstant) {
        return _appLocalizations.exit;
      } else if (status?.toLowerCase() ==
          AppConstants.cancelled.toLowerCase()) {
        return _appLocalizations.viewWatchlist;
      } else {
        return _appLocalizations.viewPositions;
      }
    } else if (status?.toLowerCase() == AppConstants.cancelled.toLowerCase()) {
      return _appLocalizations.viewWatchlist;
    } else {
      return _appLocalizations.viewPositions;
    }
  }

  String _getRightFooterButtonTitle(
      String? modifiable, String? status, String? accCode, String? accDisplay) {
    if (status?.toLowerCase() == AppConstants.pending.toLowerCase() &&
        modifiable == AppConstants.trueConstant) {
      return _appLocalizations.modify;
    } else if (status?.toLowerCase() == AppConstants.executed.toLowerCase() &&
        modifiable == AppConstants.trueConstant) {
      return _appLocalizations.modify;
    } else if (status?.toLowerCase() ==
            AppConstants.triggeredPending.toLowerCase() &&
        modifiable == AppConstants.trueConstant) {
      return _appLocalizations.modify;
    } else {
      // if (accCode == AppConstants.activateAccountCode) {
      //   return accDisplay ?? "";
      // }
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
        if ((widget.arguments["fromGtd"] ?? false) &&
            (ACMCalci.isMarketStartedOrders(orders) ||
                (orders.isAmo ?? false))) {
          _movetoNormalorderScreen(orders);
          return;
        } else if ((!((ACMCalci.isMarketStartedOrders(orders) ||
                (orders.isAmo ?? false)))) &&
            !(widget.arguments["fromGtd"] ?? false)) {
          _movetoGtdorderScreen(orders);
          return;
        }
      }
    }

    if (tappedButtonHeader == _appLocalizations.cancel) {
      if (orders.comments?.toUpperCase() == AppConstants.gtd.toUpperCase()) {
        showAlertBottomSheetWithTwoButtons(
          context: context,
          title: _appLocalizations.cancel,
          description: _appLocalizations.cancelordermessage,
          leftButtonTitle: AppConstants.no,
          rightButtonTitle: AppConstants.yes,
          rightButtonCallback: _sendCancelOrderRequest,
        );
      } else {
        showAlertBottomSheetWithTwoButtons(
          context: context,
          title: _appLocalizations.cancel,
          description: _appLocalizations.cancelordermessage,
          leftButtonTitle: AppConstants.no,
          rightButtonTitle: AppConstants.yes,
          rightButtonCallback: _sendCancelOrderRequest,
        );
      }
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
      _movetoPositionsScreen();
    } else if (tappedButtonHeader == _appLocalizations.viewWatchlist) {
      pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen);
    } else if (tappedButtonHeader == _appLocalizations.repeatOrder) {
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
                builder: (BuildContext context) => WebviewWidget(
                    orders.actDisp ?? "Activate your Account", url)),
          );
        }
      }
    }
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

  void _movetoNormalorderScreen(Orders orders) {
    AppStore().setOrder(orders);
    pushAndRemoveUntilNavigation(
      ScreenRoutes.homeScreen,
      arguments: {
        'pageName': ScreenRoutes.tradesScreen,
        'selectedIndex': 0,
      },
    );
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
  }

  void _movetoPositionsScreen() {
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
    _ordersBloc.add(OrderBookCancelEvent(
        widget.arguments['orders'], widget.arguments['fromGtd'] ?? false));
  }

  void _sendExitOrderRequest() {
    Navigator.of(context).pop();
    _ordersBloc.add(OrderBookExitEvent(
      widget.arguments['orders'],
    ));
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
                color: Theme.of(context).scaffoldBackgroundColor,
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

  _orderValue(String? quantity, String averagePrice, String exc) {
    double qty = AppUtils().doubleValue(AppUtils().decimalValue(quantity));
    double avgPrice =
        AppUtils().doubleValue(AppUtils().decimalValue(averagePrice));

    return AppUtils().decimalValue(
        (qty * avgPrice).toString().withMultiplierTrade(orders.sym).exdouble(),
        decimalPoint: AppUtils().getDecimalpoint(exc));
  }
}
