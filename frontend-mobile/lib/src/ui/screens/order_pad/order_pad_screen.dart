// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:acml/src/blocs/orderpad_ui/orderpad_ui_bloc.dart';
import 'package:acml/src/ui/screens/acml_app.dart';
import 'package:acml/src/ui/screens/order_pad/chargesheet.dart';
import 'package:acml/src/ui/widgets/info_bottomsheet.dart';
import 'package:acml/src/ui/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../blocs/charges/charges_bloc.dart';
import '../../../blocs/edis/edis_bloc.dart';
import '../../../blocs/holdings/holdings/holdings_bloc.dart';
import '../../../blocs/init/init_bloc.dart';
import '../../../blocs/market_status/market_status_bloc.dart';
import '../../../blocs/marketdepth/marketdepth_bloc.dart';
import '../../../blocs/my_funds/add_funds/add_funds_bloc.dart';
import '../../../blocs/order_pad/order_pad_bloc.dart';
import '../../../blocs/order_pad/orderpad_success_failure_widget.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_events.dart';
import '../../../constants/keys/login_keys.dart';
import '../../../constants/keys/orderpad_keys.dart';
import '../../../constants/keys/watchlist_keys.dart';
import '../../../constants/storage_constants.dart';
import '../../../data/store/app_storage.dart';
import '../../../data/store/app_store.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/edis/order_details_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../validator/input_validator.dart';
import '../../widgets/account_suspended.dart';
import '../../widgets/checkbox_widget.dart';
import '../../widgets/circular_toggle_button_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/fandotag.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/horizontal_list_view.dart';
import '../../widgets/table_with_bgcolor.dart';
import '../../widgets/toggle_circular_widget.dart';
import '../base/base_screen.dart';
import '../quote/widgets/market_depth_com_widget.dart';
import 'orderpad_info.dart';

class OrderPadScreen extends BaseScreen {
  final dynamic arguments;
  const OrderPadScreen({
    Key? key,
    this.arguments,
  }) : super(key: key);

  @override
  State<OrderPadScreen> createState() => _OrderPadScreenState();
}

class _OrderPadScreenState extends BaseAuthScreenState<OrderPadScreen> {
  late OrderpadUiBloc orderpadUiBloc;
  bool initEvent = true;
  OrderPadBloc? orderPadBloc;
  late HoldingsBloc holdingsBloc;
  late MarketStatusBloc marketStatusBloc;
  late AddFundsBloc addFundsBloc;
  late EdisBloc edisBloc;
  Timer? timer;

  @override
  void initState() {
    getrevieworderStatus();
    orderpadUiBloc = BlocProvider.of<OrderpadUiBloc>(context)
      ..stream.listen(orderPadUiListener);

    orderpadinitEvent();
    orderpadUiBloc.add(OrderpadUiinit(widget.arguments));

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (((AppStore().getinitFetchedTime()?.toUtc().hour ?? 0) < 3 &&
              DateTime.now().toUtc().hour > 3) ||
          (AppStore().getinitFetchedTime()?.toUtc().day !=
              DateTime.now().toUtc().day)) {
        BlocProvider.of<InitBloc>(context).add(InitFetchAppIDEvent());
      }
      if (!orderpadUiBloc.orderpadupdate.isAmoCheckBoxInteracted) {
        bool isAMO = AppUtils()
            .getAmoStatus(orderpadUiBloc.orderpadupdate.symbols.sym!.exc!);
        if (orderpadUiBloc.orderpadupdate.isAmoEnabled.value != isAMO) {
          orderpadUiBloc.orderpadupdate.isAmoEnabled.value =
              orderpadUiBloc.isModifyOrder() ||
                      orderpadUiBloc.orderpadupdate.basketorderId != null
                  ? (orderpadUiBloc.orderpadupdate.orders.isAmo ?? false)
                  : isAMO;
          orderpadUiBloc.orderpadupdate.isAmoCheckBoxInteracted = false;
        }
      }
    });

    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.orderPadScreen);
  }

  bool reviewOrder = false;

  getrevieworderStatus() async {
    var data = await AppUtils().getsmartDetails();

    reviewOrder = data["reviewOrder"] == "true" ? true : false;
  }

  orderPadUiListener(event) {
    if (event is OrderPadGetMarketStatus) {
      marketStatusBloc.add(GetMarketStatusEvent(
          orderpadUiBloc.orderpadupdate.currentSymbol.sym!));
    } else if (event is OrderPadGetCheckMarigin) {
      orderPadBloc!.add(OrderPadCheckMarginEvent(
        event.mariginPayloadData,
      ));
    } else if (event is OrderpadCheckTrigger) {
      orderPadBloc!.add(OrderPadCoSlTriggerRangeEvent(event.payload));
    } else if (event is CallOtherExchange) {
      if (orderpadUiBloc.orderpadupdate.exchangeList!.length > 1) {
        //if two exchange is available then get details of other exchange for streaming
        orderPadBloc!.add(
          OrderPadGetOtherExcSymbolInfoEvent(
              orderpadUiBloc.orderpadupdate.symbols,
              orderpadUiBloc.orderpadupdate.exchangeList![1]),
        );
      } else {
        //else call event to store symbol detail for streaming
        orderPadBloc!.add(
            OrderPadSetSymbolItemEvent(orderpadUiBloc.orderpadupdate.symbols));
      }
    }
  }

  void orderpadinitEvent() {
    orderPadBloc = BlocProvider.of<OrderPadBloc>(context)
      ..stream.listen(orderPadListener);

    isShowAuthorize();

    //first - screen have to render regular - market order.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addFundsBloc = BlocProvider.of<AddFundsBloc>(context)
        ..add(GetFundsViewEvent(fetchApi: true));

      holdingsBloc = BlocProvider.of<HoldingsBloc>(context)
        ..stream.listen(_holdingsListener);
      marketStatusBloc = BlocProvider.of<MarketStatusBloc>(context)
        ..add(GetMarketStatusEvent(widget.arguments['symbolItem'].sym));
      // ..stream.listen((state) {
      //   if (state is MarketStatusDoneState) {
      //     isAMoEnableFromApi = state.isAmo;
      //     isAmoEnabled.value = state.isAmo;
      //   }
      // });

      holdingsApiCall();
      edisBloc = BlocProvider.of<EdisBloc>(context)
        ..stream.listen(edisListener);
      // Future.delayed(Duration(milliseconds: 100), () {});
    });
  }

  void holdingsApiCall() {
    holdingsBloc.add(HoldingsFetchEvent(false, isFetchAgain: false));
  }

  Future<void> _holdingsListener(HoldingsState state) async {
    if (state is HoldingsFetchDoneState) {
      setOrdDetailsForEdisVerify(state.holdingsModel!.holdings);
      if (isHoldingsAvailableInSymbol(orderpadUiBloc.orderpadupdate.symbols,
          state.holdingsModel!.holdings)) {
        orderpadUiBloc.orderpadupdate.isHoldingsAvailable = true;
      } else {
        orderpadUiBloc.orderpadupdate.isHoldingsAvailable = false;
      }
    } else if (state is HoldingsFailedState) {
      orderpadUiBloc.orderpadupdate.isHoldingsAvailable = false;
    }
  }

  Future<void> edisListener(EdisState state) async {
    if (state is! EdisProgressState) {
      if (mounted) {
        stopLoader();
      }
    }
    if (state is EdisProgressState) {
      if (mounted) {
        startLoader();
      }
    } else if (state is VerifyEdisDoneState) {
      final Map<String, dynamic> data = await pushNavigation(
        ScreenRoutes.edisScreen,
        arguments: {
          'edis': state.verifyEdisModel!.edis![0],
          'segment': orderpadUiBloc.orderpadupdate.segment,
        },
      );

      if (data['isNsdlAckNeeded'] == 'true') {
        edisBloc.add(GetNsdlAcknowledgementEvent(
            state.verifyEdisModel!.edis![0].reqId!));
      }
    } else if (state is NsdlAcknowledgementDoneState) {
      if (state.nsdlAckModel!.status == AppConstants.authorizationSuccessful) {
        showToast(
          message: state.nsdlAckModel!.msg,
          context: context,
          secondsToShowToast: 5,
          isCenter: true,
        );
        showAuthorizationMessage.value = true;
        isAuthorized = true;
        Future.delayed(const Duration(seconds: 2), () {
          showAuthorizationMessage.value = false;
        });
        Future.delayed(const Duration(seconds: 2), () {
          _placeOrder();
        });
      } else {
        showToast(
          message: state.nsdlAckModel!.msg,
          context: context,
          isError: true,
          secondsToShowToast: 5,
          isCenter: true,
        );
      }
    } else if (state is NsdlAcknowledgementFailedState) {
      showToast(
        message: state.errorMsg,
        context: context,
        isError: true,
        secondsToShowToast: 5,
        isCenter: true,
      );
    } else if (state is NsdlAcknowledgementServiceExceptionState) {
      showToast(
        message: state.errorMsg,
        context: context,
        isError: true,
        secondsToShowToast: 5,
        isCenter: true,
      );
    } else if (state is VerifyEdisFailedState) {
      _placeOrder();
    } else if (state is VerifyEdisServiceExceptionState) {
      showAuthorizationMessage.value = true;
      isAuthorized = false;
      Future.delayed(const Duration(seconds: 2), () {
        showAuthorizationMessage.value = false;
      });
      showToast(
        message: state.errorMsg,
        context: context,
        isError: true,
        secondsToShowToast: 5,
        isCenter: true,
      );
    } else if (state is EdisErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  Future<void> orderPadListener(OrderPadState state) async {
    if (state is OrderPadPlaceOrderDoneState ||
        state is OrderPadPlaceOrderServiceExceptionState ||
        state is OrderPadPlaceOrderFailedState) {
      if (mounted) {
        stopLoader();
      }
    }
    if (state is OrderPadPlaceProgressState) {
      if (mounted) {
        startLoader();
      }
    } else if (state is OrderPadOtherExcSymbolInfoDoneState) {
      //2nd symbol detail
      orderpadUiBloc.add(OtherExchange(state.symbolItem));

      callStreaming();
    } else if (state is OrderPadOtherExcSymbolInfoFailedState) {
      callStreaming();
    } else if (state is OrderPadSymStreamState) {
      subscribeLevel1(state.streamDetails);
    } else if (state is OrderPadSetSymbolItemDoneState) {
      callStreaming();
    } else if (state is OrderPadCoSlTriggerRangeState) {
      orderpadUiBloc.orderpadupdate.coTriggerPrice.value =
          state.coTriggerPriceRangeModel!.trigPriceRange!;
    } else if (state is OrderPadPlaceOrderDoneState) {
      orderpadUiBloc.orderpadupdate.isPlaceOrderSelected.value = false;
      if (state.isBasket) {
        popAndRemoveUntilNavigation(ScreenRoutes.addBasket);
      } else {
        if (state.responseData['ordStatus'] == AppConstants.orderCancelled ||
            state.responseData['ordStatus'] == AppConstants.orderRejected ||
            state.responseData['ordStatus'] == AppConstants.orderFreeze) {
          OrderSuccessFailureWidget.show(
              context: context,
              isSuccess: false,
              title: state.responseData['ordStatus'],
              msg: state.responseData['rejReason'],
              onDoneCallBack: onDoneCallback,
              data:
                  '${orderpadUiBloc.orderpadupdate.symbols.dispSym} (${orderpadUiBloc.orderpadupdate.quantityController.text} ${AppLocalizations().qty})');
        } else {
          OrderSuccessFailureWidget.show(
              context: context,
              isSuccess: true,
              title: state.responseData['ordStatus'],
              msg:
                  '${_appLocalizations.orderId}: ${state.responseData['ordId']}',
              onDoneCallBack: onDoneCallback,
              data:
                  '${orderpadUiBloc.orderpadupdate.symbols.dispSym} (${orderpadUiBloc.orderpadupdate.quantityController.text} ${AppLocalizations().qty})');
        }
        if (orderpadUiBloc.orderpadupdate.isAmoEnabled.value &&
            !orderpadUiBloc.isCoverOrder() &&
            !orderpadUiBloc.isBracketOrder()) {
          showNotification(
              message: _appLocalizations.amoOrderMessage, seconds: 4);
        }
      }
    } else if (state is OrderPadPlaceOrderFailedState) {
      orderpadUiBloc.orderpadupdate.isPlaceOrderSelected.value = false;
      if (state.responseData.isNotEmpty) {
        OrderSuccessFailureWidget.show(
            context: context,
            isSuccess: false,
            title: state.responseData['ordStatus'],
            msg: state.responseData['rejReason'],
            onDoneCallBack: onDoneCallback,
            data:
                '${orderpadUiBloc.orderpadupdate.symbols.dispSym} (${orderpadUiBloc.orderpadupdate.quantityController.text} ${AppLocalizations().qty})');
      } else {
        OrderSuccessFailureWidget.show(
            context: context,
            isSuccess: false,
            title: 'Order rejected',
            msg: state.errorMsg,
            onDoneCallBack: onDoneCallback,
            data:
                '${orderpadUiBloc.orderpadupdate.symbols.dispSym} (${orderpadUiBloc.orderpadupdate.quantityController.text} ${AppLocalizations().qty})');
      }
    } else if (state is OrderPadPlaceOrderServiceExceptionState ||
        state is CheckMarginServiceExceptionState) {
      orderpadUiBloc.orderpadupdate.isPlaceOrderSelected.value = false;
      showToast(
        message: state.errorMsg,
        isError: true,
      );
    } else if (state is OrderPadErrorState ||
        state is OrderPadPlaceOrderServiceExceptionState) {
      orderpadUiBloc.orderpadupdate.isPlaceOrderSelected.value = false;
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  void onDoneCallback() {
    popNavigation();
    popNavigation();
  }

// streaming call for 2 exc if available or single exc
  void callStreaming() {
    orderPadBloc!.add(OrderPadStartSymStreamEvent());
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.orderPadScreen;
  }

  @override
  void quote1responseCallback(ResponseData data) {
    orderPadBloc?.add(OrderPadStreamingResponseEvent(data));
  }

  @override
  void dispose() {
    screenFocusOut();
    timer?.cancel();
    orderpadUiBloc.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> isShowAuthorize() async {
    final dynamic userLoginDetails =
        await AppStorage().getData(userLoginDetailsKey);
    if (userLoginDetails != null || userLoginDetails['isNonPoaUser'] != null) {
      orderpadUiBloc.orderpadupdate.isNonPoaUser =
          userLoginDetails['isNonPoaUser'];
      orderpadUiBloc.orderpadupdate.segment = userLoginDetails['segment'];
    }
  }

  Future<void> _onCallOrderPad(String action, String? customPrice) async {
    popNavigation();
    await orderpadUiBloc.customPriceOnChange(
        context: context, customPrice: customPrice);
    if (!orderpadUiBloc.isModifyOrder()) {
      orderpadUiBloc.orderpadupdate.selectedAction = action;
      orderpadUiBloc.add(UpdateUi(orderpadUiBloc.getProductTypeString(),
          orderpadUiBloc.orderpadupdate.selectedOrderType));
    }
    if (orderpadUiBloc.getProductTypeStringForPlaceOrder() ==
        AppConstants.coverOrder) {
      orderpadUiBloc.add(GetCoTriggerPrice());
    }
    orderpadUiBloc.add(CheckMariginEvent());
    callStreaming();
  }

  late AppLocalizations _appLocalizations;
  double bottomInset = 0;
  showMarketDepth() async {
    await InfoBottomSheet.showInfoBottomsheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocProvider(
            create: (context) => MarketdepthBloc(),
            child: MarketDepth(orderpadUiBloc.orderpadupdate.currentSymbol,
                screenName: ScreenRoutes.orderPadScreenMktDepth,
                onCallOrderPad: _onCallOrderPad),
          ),
          buildTableWithBackgroundColor(
            AppLocalizations().open,
            AppUtils().dataNullCheckDashDash(
                (orderpadUiBloc.orderpadupdate.currentSymbol).open),
            AppLocalizations().high,
            AppUtils().dataNullCheckDashDash(
                (orderpadUiBloc.orderpadupdate.currentSymbol).high),
            AppLocalizations().low,
            AppUtils().dataNullCheckDashDash(
                (orderpadUiBloc.orderpadupdate.currentSymbol).low),
            context,
            isReduceFontSize: true,
          ),
          buildTableWithBackgroundColor(
            AppLocalizations().volume,
            AppUtils().dataNullCheckDashDash(
                (orderpadUiBloc.orderpadupdate.currentSymbol).vol),
            AppLocalizations().avgPrice,
            AppUtils().dataNullCheckDashDash(
                (orderpadUiBloc.orderpadupdate.currentSymbol).atp),
            AppLocalizations().prevClose,
            AppUtils().dataNullCheckDashDash(
                (orderpadUiBloc.orderpadupdate.currentSymbol).close),
            context,
            isReduceFontSize: true,
          ),
        ],
      ),
      context,
      topMargin: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    bottomInset = AppWidgetSize.bottomInset(context);
    _appLocalizations = AppLocalizations.of(context)!;
    return BlocBuilder<OrderpadUiBloc, OrderpadUiState>(
      buildWhen: (previous, current) =>
          current is OrderpadUiUpdate || current is OrderpadChange,
      builder: (context, state) {
        if (state is OrderpadUiUpdate) {
          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: _buildAppBar(),
                body: _buildBody(context),
                bottomNavigationBar: Visibility(
                    visible: bottomInset == 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFooterFundsWidget(),
                        _buildPresistentFooterWidget(),
                      ],
                    )),
              ),
            ),
          );
        } else {
          return const LoaderWidget();
        }
      },
    );
  }

//funds details
  Widget _buildFooterFundsWidget() {
    return BlocBuilder<OrderPadBloc, OrderPadState>(
      buildWhen: (OrderPadState previous, OrderPadState current) {
        return current is CheckMarginDoneState ||
            current is CheckMarginFailedState ||
            current is CheckMarginServiceExceptionState;
      },
      builder: (context, state) {
        return _buildFundsView();
      },
    );
  }

  Widget _buildFundsView() {
    return _buildFooterFundsOrErrorWidget();
  }

  Widget _buildFooterFundsOrErrorWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppWidgetSize.dimen_15),
        topRight: Radius.circular(AppWidgetSize.dimen_15),
      ),
      child: Container(
          width: AppWidgetSize.fullWidth(context),
          color: Theme.of(context).snackBarTheme.backgroundColor,
          padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_5,
              left: AppWidgetSize.dimen_20,
              right: 30.w,
              bottom: 5.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      CustomTextWidget(
                        _appLocalizations.availableMargin,
                        Theme.of(context)
                            .primaryTextTheme
                            .titleMedium!
                            .copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppStore().getThemeData() ==
                                      AppConstants.darkMode
                                  ? const Color(0xFFE1F4E5)
                                  : const Color(0xFF00C802),
                              fontSize: 12.w,
                            ),
                      ),
                    ],
                  ),
                  _buildAvailableMargin(),
                ],
              ),
              requiredmarginWidget(),
            ],
          )),
    );
  }

  Widget requiredmarginWidget() {
    return GestureDetector(
      onTap: () {
        orderpadUiBloc.add(CheckMariginEvent());
      },
      child: Column(
        children: [
          Row(
            children: [
              _buildRefreshIconWidget(),
              CustomTextWidget(
                _appLocalizations.requiredMargin,
                Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.w,
                      color: AppStore().getThemeData() == AppConstants.darkMode
                          ? const Color(0xFFE1F4E5)
                          : const Color(0xFF00C802),
                    ),
              ),
            ],
          ),
          buildRequireMargin(),
        ],
      ),
    );
  }

  Widget _buildRefreshIconWidget() {
    return BlocBuilder<OrderPadBloc, OrderPadState>(
      buildWhen: (previous, current) {
        return current is CheckMarginProgressState ||
            current is CheckMarginDoneState ||
            current is CheckMarginFailedState ||
            current is CheckMarginServiceExceptionState;
      },
      builder: (context, state) {
        if (state is CheckMarginProgressState) {
          return Padding(
            padding: EdgeInsets.only(
              right: AppWidgetSize.dimen_5,
            ),
            child: SizedBox(
              width: AppWidgetSize.dimen_7,
              height: AppWidgetSize.dimen_7,
              child: CircularProgressIndicator(
                strokeWidth: 1,
                color: AppStore().getThemeData() == AppConstants.darkMode
                    ? const Color(0xFFE1F4E5)
                    : const Color(0xFF00C802),
              ),
            ),
          );
        } else {
          return GestureDetector(
            onTap: () {
              orderpadUiBloc.add(CheckMariginEvent());
            },
            child: Container(
              padding: EdgeInsets.only(
                right: AppWidgetSize.dimen_5,
              ),
              child: AppImages.refreshIcon(
                context,
                isColor: true,
                color: AppStore().getThemeData() == AppConstants.darkMode
                    ? const Color(0xFFE1F4E5)
                    : const Color(0xFF00C802),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildAvailableMargin() {
    return BlocBuilder<AddFundsBloc, AddFundsState>(
      buildWhen: (previous, current) {
        return current is AddFundBuyPowerandWithdrawcashDoneState;
      },
      builder: (context, state) {
        if (state is AddFundBuyPowerandWithdrawcashDoneState) {
          orderpadUiBloc.orderpadupdate.availableMargin = state.buy_power;
          return CustomTextWidget(
            state.buy_power,
            Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                  fontSize: 12.w,
                  fontWeight: FontWeight.w500,
                  color: AppStore().getThemeData() == AppConstants.darkMode
                      ? const Color(0xFFE1F4E5)
                      : const Color(0xFF00C802),
                ),
          );
        }
        orderpadUiBloc.orderpadupdate.availableMargin == '--';
        return CustomTextWidget(
          '--',
          Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12.w,
                color: AppStore().getThemeData() == AppConstants.darkMode
                    ? const Color(0xFFE1F4E5)
                    : const Color(0xFF00C802),
              ),
        );
      },
    );
  }

  Widget buildRequireMargin() {
    return BlocBuilder<OrderPadBloc, OrderPadState>(
        buildWhen: (OrderPadState previous, OrderPadState current) {
      return current is CheckMarginDoneState ||
          current is CheckMarginFailedState ||
          current is CheckMarginServiceExceptionState;
    }, builder: (context, state) {
      if (state is CheckMarginDoneState) {
        if (orderpadUiBloc.orderpadupdate.quantityController.text.isEmpty ||
            orderpadUiBloc.orderpadupdate.quantityController.text == '0') {
          orderpadUiBloc.orderpadupdate.requiredMargin = '--';
        } else {
          orderpadUiBloc.orderpadupdate.requiredMargin =
              state.checkMarginModel!.orderMargin!;
        }
      }
      if (orderpadUiBloc.orderpadupdate.quantityController.text.isEmpty ||
          orderpadUiBloc.orderpadupdate.quantityController.text == '0') {
        orderpadUiBloc.orderpadupdate.requiredMargin = '--';
      }

      return Row(
        children: [
          CustomTextWidget(
            ((orderpadUiBloc.isNseBseExcSellDeliveryOrder(
                        orderpadUiBloc.orderpadupdate.selectedAction)) ||
                    (orderpadUiBloc.isQtyGreaterThanOrderedQty()) ||
                    orderpadUiBloc.isMcxcdsExcSellDeliveryOrder(
                        orderpadUiBloc.orderpadupdate.selectedAction))
                ? "0.00"
                : orderpadUiBloc.orderpadupdate.requiredMargin.isEmpty
                    ? "--"
                    : orderpadUiBloc.orderpadupdate.requiredMargin,
            Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12.w,
                  color: AppUtils()
                          .doubleValue(orderPadBloc?.checkMarginDoneState
                              .checkMarginModel?.availMargin)
                          .isNegative
                      ? AppColors.negativeColor
                      : AppStore().getThemeData() == AppConstants.darkMode
                          ? const Color(0xFFE1F4E5)
                          : const Color(0xFF00C802),
                ),
          ),
          if (orderpadUiBloc.orderpadupdate.requiredMargin.isNotEmpty &&
              orderpadUiBloc.orderpadupdate.requiredMargin != "--" &&
              Featureflag.showCharges)
            GestureDetector(
              onTap: () {
                showInfoBottomsheet(
                    BlocProvider(
                      create: (context) => ChargesBloc(ChargesProgressState()),
                      child: ChargeSheet(
                          data: orderpadUiBloc.getOrderPayloadData(),
                          isMcx: orderpadUiBloc.isMcx(),
                          isCurrency: orderpadUiBloc.isExcCds()),
                    ),
                    horizontalMargin: false,
                    height: AppWidgetSize.fullHeight(context) * 0.8);
              },
              child: CustomTextWidget(
                _appLocalizations.charges,
                Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.w,
                      color: const Color(0xffF69200),
                    ),
              ),
            ),
        ],
      );
    });
  }

//buy/ sell or error buttons at the bottom
  Widget _buildPresistentFooterWidget() {
    return _buildBuyOrSellButton();
  }

  Widget _buildBuyOrSellButton() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: 10.w,
          bottom: 10.w,
        ),
        child: SizedBox(
          width: AppWidgetSize.fullWidth(context) - AppWidgetSize.dimen_80,
          height: 50.w,
          child: ValueListenableBuilder<bool>(
            valueListenable: orderpadUiBloc.orderpadupdate.isPlaceOrderSelected,
            builder: (context, value, _) {
              return Opacity(
                opacity:
                    orderpadUiBloc.orderpadupdate.isPlaceOrderSelected.value
                        ? 0.3
                        : orderpadUiBloc.orderpadupdate.quantityController.text
                                    .isEmpty ||
                                AppUtils().doubleValue(orderpadUiBloc
                                        .orderpadupdate
                                        .quantityController
                                        .text) <=
                                    0
                            ? 0.3
                            : 1,
                child: _getBottomButtonWidget(
                  orderpadPersistentButtonKey,
                  (orderpadUiBloc.orderpadupdate.basketId != null)
                      ? (orderpadUiBloc
                                  .orderpadupdate.basketorderId?.isNotEmpty ??
                              false)
                          ? _appLocalizations.modifyBasket
                          : _appLocalizations.addtoBasket
                      : orderpadUiBloc.isBuyActionSelected()
                          ? _appLocalizations.buy
                          : _appLocalizations.sell,
                  true,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<OrderDetails> ordDetails = [];

  void setOrdDetailsForEdisVerify(
    List<Symbols>? holdings,
  ) {
    ordDetails = [];
    List<OrderDetails> tempOrdDetails = [];
    for (Symbols element in holdings!) {
      tempOrdDetails.add(OrderDetails(isin: element.isin, qty: element.qty));
    }
    ordDetails = tempOrdDetails;
  }

  showReviewbottomsheet(BuildContext context) {
    return showInfoBottomsheet(
      StatefulBuilder(builder: (context, setstate) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 15.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: AppWidgetSize.fullWidth(context) * 0.47),
                        child: FittedBox(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CustomTextWidget(
                                  orderpadUiBloc.orderpadupdate.currentSymbol
                                          .baseSym ??
                                      "",
                                  Theme.of(context)
                                      .primaryTextTheme
                                      .displaySmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .primaryTextTheme
                                              .labelSmall
                                              ?.color)),
                              Padding(
                                  padding: EdgeInsets.only(left: 5.w),
                                  child: FandOTag(orderpadUiBloc
                                      .orderpadupdate.currentSymbol)),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _buildSingleExchangeWidget(),
                          Container(
                              margin: EdgeInsets.only(left: 10.w),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: AppImages.closeIcon(
                                  context,
                                  width: AppWidgetSize.dimen_20,
                                  height: AppWidgetSize.dimen_20,
                                  color:
                                      Theme.of(context).primaryIconTheme.color,
                                  isColor: true,
                                ),
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
                CustomTextWidget(
                    orderpadUiBloc.orderpadupdate.currentSymbol.companyName ??
                        "",
                    Theme.of(context)
                        .primaryTextTheme
                        .labelSmall
                        ?.copyWith(color: Theme.of(context).disabledColor)),
                Padding(
                  padding: EdgeInsets.only(top: 20.w),
                  child: buildTableWithBackgroundColor(
                      _appLocalizations.quantity,
                      orderpadUiBloc.orderpadupdate.quantityController.text,
                      _appLocalizations.price,
                      AppUtils().commaFmt(
                          orderpadUiBloc.orderpadupdate.priceController.text,
                          decimalPoint: AppUtils().getDecimalpoint(
                              orderpadUiBloc
                                  .orderpadupdate.currentSymbol.sym?.exc)),
                      "",
                      "",
                      context,
                      isReduceFontSize: true,
                      fontSize: 15.w,
                      keyFontSize: 14.w),
                ),

                buildTableWithBackgroundColor(
                    _appLocalizations.orderType,
                    orderpadUiBloc.orderpadupdate.selectedOrderType,
                    AppConstants.productType,
                    orderpadUiBloc
                                .getProductTypeStringForPlaceOrder()
                                .toLowerCase() ==
                            AppConstants.gtd.toLowerCase()
                        ? AppConstants.delivery.toUpperCase()
                        : orderpadUiBloc
                                    .getProductTypeStringForPlaceOrder()
                                    .toLowerCase() ==
                                AppConstants.normal.toLowerCase()
                            ? AppLocalizations().carryForward
                            : orderpadUiBloc
                                .getProductTypeStringForPlaceOrder(),
                    "",
                    "",
                    context,
                    isReduceFontSize: true,
                    fontSize: 15.w,
                    keyFontSize: 14.w),
                if (orderpadUiBloc.getProductTypeStringForPlaceOrder() == "BO")
                  buildTableWithBackgroundColor(
                      orderpadUiBloc.orderpadupdate.selectedAction.toLowerCase() ==
                              AppLocalizations().buy.toLowerCase()
                          ? _appLocalizations.stopLossSell
                          : _appLocalizations.stopLossBuy,
                      AppUtils().commaFmt(
                          orderpadUiBloc.orderpadupdate.stopLossController.text,
                          decimalPoint: AppUtils().getDecimalpoint(orderpadUiBloc
                              .orderpadupdate.currentSymbol.sym?.exc)),
                      _appLocalizations.targetPrice,
                      AppUtils()
                          .commaFmt(orderpadUiBloc.orderpadupdate.targetPriceController.text,
                              decimalPoint: AppUtils().getDecimalpoint(orderpadUiBloc
                                  .orderpadupdate.currentSymbol.sym?.exc)),
                      "",
                      "",
                      context,
                      isReduceFontSize: true,
                      fontSize: 15.w,
                      keyFontSize: 14.w),
                buildTableWithBackgroundColor(
                    _appLocalizations.validity,
                    orderpadUiBloc.orderpadupdate.selectedValidity,
                    orderpadUiBloc.getProductTypeStringForPlaceOrder() == "CO"
                        ? _appLocalizations.stopLossTrigger
                        : (orderpadUiBloc.orderpadupdate.selectedOrderType ==
                                    AppConstants.sl ||
                                orderpadUiBloc.orderpadupdate.selectedOrderType ==
                                    AppConstants.slM)
                            ? _appLocalizations.triggerPrice
                            : "",
                    orderpadUiBloc.getProductTypeStringForPlaceOrder() == "CO"
                        ? AppUtils().commaFmt(orderpadUiBloc.orderpadupdate.stopLossTriggerController.text,
                            decimalPoint: AppUtils().getDecimalpoint(orderpadUiBloc
                                .orderpadupdate.currentSymbol.sym?.exc))
                        : AppUtils()
                            .commaFmt(orderpadUiBloc.orderpadupdate.triggerPriceController.text,
                                decimalPoint: AppUtils().getDecimalpoint(orderpadUiBloc
                                    .orderpadupdate.currentSymbol.sym?.exc)),
                    orderpadUiBloc.getProductTypeStringForPlaceOrder() == "GTD"
                        ? "Validity date"
                        : "",
                    orderpadUiBloc.orderpadupdate.validityDateController.text,
                    context,
                    isReduceFontSize: true,
                    fontSize: 15.w,
                    keyFontSize: 14.w),

                Divider(
                  color: Theme.of(context).dividerColor,
                  thickness: 0.5,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: ((orderpadUiBloc
                                .isNseBseExcSellDeliveryOrder(orderpadUiBloc
                                    .orderpadupdate.selectedAction)) ||
                            (orderpadUiBloc.isQtyGreaterThanOrderedQty()))
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      if (!((orderpadUiBloc.isNseBseExcSellDeliveryOrder(
                              orderpadUiBloc.orderpadupdate.selectedAction)) ||
                          (orderpadUiBloc.isQtyGreaterThanOrderedQty())))
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 6.w, horizontal: 10.w),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .snackBarTheme
                                  .backgroundColor,
                              borderRadius: BorderRadius.circular(
                                  AppWidgetSize.dimen_10)),
                          child: BlocProvider.value(
                            value: orderPadBloc!,
                            child: requiredmarginWidget(),
                          ),
                        ),
                      GestureDetector(
                          onTap: () {
                            if (orderpadUiBloc.isModifyOrder()) {
                              orderPadBloc!.add(ModifyOrderPadPlaceOrderEvent(
                                  orderpadUiBloc.getOrderPayloadData(),
                                  orderpadUiBloc.isGTD()));
                            } else {
                              orderPadBloc!.add(OrderPadPlaceOrderEvent(
                                  orderpadUiBloc.getOrderPayloadData(),
                                  orderpadUiBloc.isGTD()));
                            }
                            popNavigation();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: ((orderpadUiBloc
                                        .isNseBseExcSellDeliveryOrder(
                                            orderpadUiBloc.orderpadupdate
                                                .selectedAction)) ||
                                    (orderpadUiBloc
                                        .isQtyGreaterThanOrderedQty()))
                                ? AppWidgetSize.dimen_180
                                : AppWidgetSize.dimen_120,
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.w),
                              gradient: LinearGradient(
                                stops: const [0.0, 1.0],
                                begin: FractionalOffset.topLeft,
                                end: FractionalOffset.topRight,
                                colors: orderpadUiBloc.isBuyActionSelected()
                                    ? [
                                        Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                        Theme.of(context).primaryColor,
                                      ]
                                    : [
                                        AppColors.negativeColor,
                                        AppColors.negativeColor,
                                      ],
                              ),
                            ),
                            child: Text(
                              "Confirm",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .displaySmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                            ),
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }),
      horizontalMargin: false,
      isdimissible: true,
      bottomMargin: 10.w,
    );
  }

  Widget _buildSingleExchangeWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
      child: Container(
        height: AppWidgetSize.dimen_24,
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_2,
          right: AppWidgetSize.dimen_2,
        ),
        constraints: BoxConstraints(minWidth: AppWidgetSize.dimen_40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppWidgetSize.dimen_20),
            bottomLeft: Radius.circular(AppWidgetSize.dimen_20),
          ),
          color: orderpadUiBloc.isBuyActionSelected()
              ? Theme.of(context).primaryTextTheme.displayLarge!.color
              : AppColors.negativeColor,
        ),
        alignment: Alignment.center,
        child: Row(
          children: <Widget>[
            Text(
              orderpadUiBloc.isBuyActionSelected()
                  ? _appLocalizations.buy
                  : _appLocalizations.sell,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .primaryTextTheme
                  .bodyLarge!
                  .copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }

  confirmOrder(String header) {
    sendEventToFirebaseAnalytics(
        header == _appLocalizations.buy
            ? AppEvents.orderpadBuy
            : AppEvents.orderpadSell,
        ScreenRoutes.orderPadScreen,
        '${header == _appLocalizations.buy ? "Buy" : "Sell"} symbol in orderpad screen',
        key: "symbol",
        value: orderpadUiBloc.orderpadupdate.currentSymbol.dispSym);

    if (orderpadUiBloc.orderpadupdate.quantityController.text.isNotEmpty &&
        AppUtils().doubleValue(
                orderpadUiBloc.orderpadupdate.quantityController.text) >
            0 &&
        !orderpadUiBloc.orderpadupdate.isPlaceOrderSelected.value) {
      if ((header == _appLocalizations.buy ||
              header == _appLocalizations.sell ||
              header == _appLocalizations.addtoBasket ||
              header == _appLocalizations.modifyBasket) &&
          header != _appLocalizations.addFunds) {
        orderpadUiBloc.clearAllFocus();
        if (orderpadUiBloc.orderpadupdate.isNonPoaUser &&
            orderpadUiBloc.orderpadupdate.isHoldingsAvailable &&
            orderpadUiBloc.isNseBseExcSellDeliveryOrder(header)) {
          edisBloc.add(VerifyEdisEvent(ordDetails));
        } else {
          _placeOrder();
        }
      } else if (header == _appLocalizations.addFunds) {
        if (AppStore().isAccountActivated) {
          pushNavigation(ScreenRoutes.addfundsScreen);
        } else {
          showInfoBottomsheet(suspendedAccount(context));
        }
      }
    }
  }

  Widget _getBottomButtonWidget(
    String key,
    String header,
    bool isGradient,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: orderpadUiBloc.orderpadupdate.isPlaceOrderSelected,
      builder: (context, value, _) {
        return GestureDetector(
          key: Key(key),
          onTap: () {
            confirmOrder(header);
          },
          child: Container(
            alignment: Alignment.center,
            width: AppWidgetSize.dimen_120,
            height: 50.w,
            //padding: EdgeInsets.all(AppWidgetSize.dimen_10),
            decoration: isGradient
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(25.w),
                    gradient: LinearGradient(
                      stops: const [0.0, 1.0],
                      begin: FractionalOffset.topLeft,
                      end: FractionalOffset.topRight,
                      colors: orderpadUiBloc.isBuyActionSelected()
                          ? [
                              Theme.of(context).colorScheme.onBackground,
                              Theme.of(context).primaryColor,
                            ]
                          : [
                              AppColors.negativeColor,
                              AppColors.negativeColor,
                            ],
                    ),
                  )
                : BoxDecoration(
                    border: Border.all(
                      color: AppColors.negativeColor,
                      width: 1.5,
                    ),
                    color: AppColors.negativeColor,
                    borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
                  ),
            child: Text(
              orderpadUiBloc.isModifyOrder()
                  ? _appLocalizations.modify
                  : header,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .primaryTextTheme
                  .displaySmall!
                  .copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      toolbarHeight: AppWidgetSize.dimen_110,
      elevation: 3,
      shadowColor: Theme.of(context).dividerColor.withOpacity(0.5),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: _buildTopAppBarContent(),
    );
  }

  Widget _buildTopAppBarContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAppBarTopContent(),
        _buildProductTypeWidget(),
      ],
    );
  }

//back + streaming + buy/sell toggle
  Widget _buildAppBarTopContent() {
    return Padding(
      padding: EdgeInsets.only(
        top: 30.w,
        bottom: 5.w,
        left: 5.w,
        right: AppWidgetSize.dimen_3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              backIconButton(),
              _buildAppBarStreamingContent(),
            ],
          ),
          _buildBuySellToggleWidget(),
        ],
      ),
    );
  }

  Widget _buildAppBarStreamingContent() {
    return Container(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_2,
      ),
      height: AppWidgetSize.dimen_45,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDispSymAndMartetStatusWidget(),
            _buildExchangeStreamingWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildDispSymAndMartetStatusWidget() {
    return Row(
      children: [
        CustomTextWidget(
          orderpadUiBloc.orderpadupdate.currentSymbol.baseSym ?? "",
          Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_5),
          child:
              FandOTag(orderpadUiBloc.orderpadupdate.symbols, showTag: false),
        ),
        _buildMarketStatusBloc(),
      ],
    );
  }

  Widget _buildExchangeStreamingWidget() {
    return BlocBuilder<OrderPadBloc, OrderPadState>(
      buildWhen: (OrderPadState previous, OrderPadState current) {
        return current is OrderPadSymbolItemState;
      },
      builder: (context, state) {
        if (state is OrderPadSymbolItemState) {
          if (orderpadUiBloc.orderpadupdate.symbols.sym!.exc ==
              orderpadUiBloc.orderpadupdate.exchangeList!.elementAt(
                  orderpadUiBloc.orderpadupdate.selectedExchangeIndex)) {
            orderpadUiBloc.orderpadupdate.lcl = AppUtils()
                .dataNullCheck(orderpadUiBloc.orderpadupdate.symbols.lcl);
            orderpadUiBloc.orderpadupdate.ucl = AppUtils()
                .dataNullCheck(orderpadUiBloc.orderpadupdate.symbols.ucl);
          } else {
            orderpadUiBloc.orderpadupdate.lcl = AppUtils().dataNullCheck(
                orderpadUiBloc.orderpadupdate.otherExcSymbol.lcl);
            orderpadUiBloc.orderpadupdate.ucl = AppUtils().dataNullCheck(
                orderpadUiBloc.orderpadupdate.otherExcSymbol.ucl);
          }

          return _buildExchangeListWidget(state.symbols);
        }
        return _buildExchangeListWidget(
            [orderpadUiBloc.orderpadupdate.symbols]);
      },
    );
  }

  Widget _buildExchangeListWidget(List<Symbols> symbols) {
    return Opacity(
      opacity: (!orderpadUiBloc.isModifyOrder()) ? 1 : 0.6,
      child: Container(
        padding: EdgeInsets.only(
          bottom: 2.w,
          right: AppWidgetSize.dimen_2,
        ),
        height: AppWidgetSize.dimen_25,
        width: AppWidgetSize.fullWidth(context) - AppWidgetSize.dimen_160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: symbols.length,
          itemBuilder: (BuildContext ctx, int index) {
            return _buildExchangeCheckBoxWidget(
              symbols[index],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExchangeCheckBoxWidget(Symbols symbolItem) {
    return Padding(
      padding: EdgeInsets.only(
        right: AppWidgetSize.dimen_5,
      ),
      child: GestureDetector(
        onTap: () {
          if (!orderpadUiBloc.isModifyOrder()) {
            sendEventToFirebaseAnalytics(
                "other_exc_onTap",
                ScreenRoutes.orderPadScreen,
                'other exchange  on tap in orderpad screen',
                key: "symbol",
                value: orderpadUiBloc.orderpadupdate.currentSymbol.dispSym);
            orderpadUiBloc.add(ExchangeChange());
          }
        },
        child: Row(
          children: [
            CheckboxWidget(
              checkBoxValue: orderpadUiBloc.orderpadupdate.exchangeList!
                      .elementAt(orderpadUiBloc
                          .orderpadupdate.selectedExchangeIndex) ==
                  symbolItem.sym!.exc,
              isDisabled: orderpadUiBloc.isModifyOrder() ||
                      orderpadUiBloc.isPositonExitOrAdd() ||
                      orderpadUiBloc.orderpadupdate.exchangeList!.isNotEmpty &&
                          orderpadUiBloc.orderpadupdate.exchangeList!.length ==
                              1
                  ? true
                  : false,
              valueChanged: (bool checkboxdata) {
                if (!orderpadUiBloc.isModifyOrder()) {
                  sendEventToFirebaseAnalytics(
                      "other_exc_onTap",
                      ScreenRoutes.orderPadScreen,
                      'other exchange  on tap in orderpad screen',
                      key: "symbol",
                      value:
                          orderpadUiBloc.orderpadupdate.currentSymbol.dispSym);
                  orderpadUiBloc.add(ExchangeChange());
                }
              },
              isPositive: orderpadUiBloc.isBuyActionSelected() ? true : false,
              addSymbolKey: orderpadExchangeToggleKey,
              height: Theme.of(context).primaryTextTheme.labelSmall?.fontSize,
              width: Theme.of(context).primaryTextTheme.labelSmall?.fontSize,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 5.w,
              ),
              child: CustomTextWidget(
                '${symbolItem.sym!.exc == AppConstants.nfo ? AppConstants.fo : symbolItem.sym!.exc} : ',
                Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(context).primaryTextTheme.labelSmall!.color,
                    ),
              ),
            ),
            CustomTextWidget(
              AppUtils().dataNullCheck(symbolItem.ltp),
              Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                  ),
              isShowShimmer: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildToggle() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_25,
          bottom: 5.w,
          top: AppWidgetSize.dimen_8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
              alignment: Alignment.centerRight,
              height: AppWidgetSize.dimen_20,
              decoration: BoxDecoration(
                border: Border.all(
                  color: !orderpadUiBloc.isBuyActionSelected()
                      ? AppColors.negativeColor
                      : Theme.of(context).primaryColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: ToggleCircularWidget(
                  key: const Key(amountQtyToggle),
                  height: AppWidgetSize.dimen_20,
                  minWidth: AppWidgetSize.dimen_35,
                  cornerRadius: AppWidgetSize.dimen_10,
                  activeBgColor: !orderpadUiBloc.isBuyActionSelected()
                      ? AppColors.negativeColor
                      : Theme.of(context).primaryTextTheme.displayLarge!.color,
                  activeTextColor: Theme.of(context).colorScheme.secondary,
                  inactiveBgColor: Theme.of(context).scaffoldBackgroundColor,
                  inactiveTextColor: !orderpadUiBloc.isBuyActionSelected()
                      ? AppColors.negativeColor
                      : Theme.of(context).primaryTextTheme.displayLarge!.color,
                  labels: const <String>["Qty", "Amt"],
                  initialLabel:
                      orderpadUiBloc.orderpadupdate.isQuantity.value ? 0 : 1,
                  isBadgeWidget: false,
                  activeTextStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontSize: AppWidgetSize.fontSize12),
                  inactiveTextStyle:
                      Theme.of(context).inputDecorationTheme.labelStyle!,
                  onToggle: (int selectedTabValue) {
                    orderpadUiBloc.orderpadupdate.isQuantity.value =
                        selectedTabValue == 0;
                    orderpadUiBloc.add(UpdateUi(
                        orderpadUiBloc.getProductTypeString(),
                        orderpadUiBloc.orderpadupdate.selectedOrderType));
                    orderpadUiBloc.orderpadupdate.qtyFocusNode.unfocus();
                  },
                ),
              )),
        ],
      ),
    );
  }

//same as stock quote
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
      padding: EdgeInsets.only(
        left: 5.w,
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: AppWidgetSize.dimen_3,
            ),
            child: Container(
              width: 5.w,
              height: 5.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.w),
                color: isOpen
                    ? AppColors().positiveColor
                    : AppColors.negativeColor,
              ),
            ),
          ),
          CustomTextWidget(
            isOpen ? _appLocalizations.live : _appLocalizations.closed,
            Theme.of(context)
                .primaryTextTheme
                .bodyLarge!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildBuySellToggleWidget() {
    return Opacity(
      opacity: orderpadUiBloc.isModifyOrder() ||
              (orderpadUiBloc.isPositonExitOrAdd() &&
                  widget.arguments[AppConstants.isOpenPosition])
          ? 0.4
          : 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 0.9,
          ),
          borderRadius: BorderRadius.circular(
            AppWidgetSize.dimen_20,
          ),
        ),
        child: ToggleCircularWidget(
          key: const Key(orderpadBugSellToggleWidgetKey),
          height: AppWidgetSize.dimen_25,
          minWidth: 40.w,
          cornerRadius: AppWidgetSize.dimen_20,
          activeBgColor: orderpadUiBloc.isBuyActionSelected()
              ? Theme.of(context).primaryTextTheme.displayLarge!.color
              : AppColors.negativeColor,
          activeTextColor: Theme.of(context).colorScheme.secondary,
          inactiveBgColor: Theme.of(context).scaffoldBackgroundColor,
          inactiveTextColor:
              Theme.of(context).primaryTextTheme.titleMedium!.color,
          labels: orderpadUiBloc.orderpadupdate.actions,
          initialLabel: orderpadUiBloc.orderpadupdate.actions
              .indexOf(orderpadUiBloc.orderpadupdate.selectedAction),
          isBadgeWidget: false,
          activeTextStyle: Theme.of(context).primaryTextTheme.bodyLarge!,
          inactiveTextStyle: Theme.of(context).inputDecorationTheme.labelStyle!,
          isDisabled: orderpadUiBloc.isModifyOrder() ||
              (orderpadUiBloc.isPositonExitOrAdd() &&
                  widget.arguments[AppConstants.isOpenPosition]),
          onToggle: (int selectedToggleIndex) {
            if (!orderpadUiBloc.isModifyOrder()) {
              orderpadUiBloc.orderpadupdate.selectedAction =
                  orderpadUiBloc.orderpadupdate.actions[selectedToggleIndex];

              orderpadUiBloc.add(UpdateUi(orderpadUiBloc.getProductTypeString(),
                  orderpadUiBloc.orderpadupdate.selectedOrderType));
            }
            if (orderpadUiBloc.getProductTypeStringForPlaceOrder() ==
                AppConstants.coverOrder) {
              orderpadUiBloc.add(GetCoTriggerPrice());
            }
            orderpadUiBloc.add(CheckMariginEvent());
          },
        ),
      ),
    );
  }

//regular cover and brack order tabs
  Widget _buildProductTypeWidget() {
    return SizedBox(
      height: 40.w,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          horizontalListView(
            values: orderpadUiBloc.orderpadupdate.productList,
            selectedIndex:
                orderpadUiBloc.orderpadupdate.selectedProductTypeIndex,
            isEnabled: orderpadUiBloc.isModifyOrder() ? false : true,
            isRectShape: false,
            callback: (value, index) {
              sendEventToFirebaseAnalytics(
                  value + "_order_tab",
                  ScreenRoutes.orderPadScreen,
                  'prd type  changed in orderpad screen',
                  key: "symbol",
                  value: orderpadUiBloc.orderpadupdate.currentSymbol.dispSym);
              orderpadUiBloc.add(PrdChange(value, index));
            },
            highlighterColor: orderpadUiBloc.isBuyActionSelected()
                ? Theme.of(context).primaryTextTheme.displayLarge!.color!
                : AppColors.negativeColor,
            context: context,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                height: 20.w,
                child: VerticalDivider(
                  width: 12.5.w,
                  thickness: 1.w,
                  color: Theme.of(context).dividerColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  OrderPadInfo.showInformationIconBottomSheet(context);
                },
                child: AppImages.informationIcon(
                  context,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true,
                  width: 24.w,
                  height: 24.w,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
  ) {
    return BlocBuilder<OrderPadBloc, OrderPadState>(
      buildWhen: (OrderPadState previous, OrderPadState current) {
        return current is OrderPadSymbolItemState;
      },
      builder: (context, state) {
        if (state is OrderPadSymbolItemState) {
          if (orderpadUiBloc.orderpadupdate.symbols.sym!.exc ==
              orderpadUiBloc.orderpadupdate.exchangeList!.elementAt(
                  orderpadUiBloc.orderpadupdate.selectedExchangeIndex)) {
            orderpadUiBloc.orderpadupdate.lcl = AppUtils()
                .dataNullCheck(orderpadUiBloc.orderpadupdate.symbols.lcl);
            orderpadUiBloc.orderpadupdate.ucl = AppUtils()
                .dataNullCheck(orderpadUiBloc.orderpadupdate.symbols.ucl);
          } else {
            orderpadUiBloc.orderpadupdate.lcl = AppUtils().dataNullCheck(
                orderpadUiBloc.orderpadupdate.otherExcSymbol.lcl);
            orderpadUiBloc.orderpadupdate.ucl = AppUtils().dataNullCheck(
                orderpadUiBloc.orderpadupdate.otherExcSymbol.ucl);
          }
          orderpadUiBloc.updateQtyandAmount();
          return _buildBodyWidget(context);
        }
        return _buildBodyWidget(context);
      },
    );
  }

  Widget _buildBodyWidget(
    BuildContext context,
  ) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: (bottomInset != 0) ? AppWidgetSize.dimen_110 : 0,
          ),
          child: LayoutBuilder(
            builder: (
              BuildContext ctx,
              BoxConstraints viewportConstraints,
            ) {
              return SingleChildScrollView(
                key: const Key(orderpadScreenBodyKey),
                controller:
                    orderpadUiBloc.orderpadupdate.orderpadBodyScrollController,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (orderpadUiBloc.isRegularOrder())
                        _buildRegularProductTypeButtonWidget(),
                      _buildQtyAndPriceWidget(),
                      if (orderpadUiBloc.isCoverOrder())
                        _buildStopLossTriggerWidget(),
                      if ((orderpadUiBloc.isBracketOrder() &&
                              !orderpadUiBloc.isModifyOrder()) ||
                          (!orderpadUiBloc.isMainOrderType() &&
                              orderpadUiBloc.isBracketOrder() &&
                              orderpadUiBloc.isModifyOrder()))
                        _buildBracketOrderSecondLegWidget(),
                      if (orderpadUiBloc.isModifyOrder() &&
                          (orderpadUiBloc.isModifyOrderCoverOrder() &&
                                  orderpadUiBloc.isChildOrderSecondType() ||
                              orderpadUiBloc.isModifyOrderBracketOrder() &&
                                  orderpadUiBloc.isChildOrderSecondType() ||
                              orderpadUiBloc.isChildOrderThirdType()))
                        Container()
                      else
                        _buildAdvanceOptionsWidget(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Visibility(
          visible: bottomInset != 0,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Wrap(
              children: [
                _buildFooterFundsWidget(),
                _buildPresistentFooterWidget(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegularProductTypeButtonWidget() {
    return Opacity(
      opacity: (!(orderpadUiBloc.isModifyOrder() ||
              (orderpadUiBloc.isPositonExitOrAdd() &&
                  widget.arguments[AppConstants.isOpenPosition])))
          ? 1
          : 0.4,
      child: Padding(
        padding: EdgeInsets.only(
          top: 30.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                gradientButtonWidget(
                  onTap: () {
                    orderpadUiBloc.clearAllFocus();
                    if (!(orderpadUiBloc.isModifyOrder() ||
                        (orderpadUiBloc.isPositonExitOrAdd() &&
                            widget.arguments[AppConstants.isOpenPosition]))) {
                      sendEventToFirebaseAnalytics(
                          AppEvents.orderpadInvestclick,
                          ScreenRoutes.orderPadScreen,
                          'Clicked invest button in orderpad screen',
                          key: "symbol",
                          value: orderpadUiBloc
                              .orderpadupdate.currentSymbol.dispSym);
                      orderpadUiBloc
                          .orderpadupdate.selectedRegularProductTypeIndex = 0;
                      if (!orderpadUiBloc.isBuyActionSelected() &&
                          !orderpadUiBloc.orderpadupdate.isHoldingsAvailable) {
                        // fundsAndHoldingsError.value = 2;
                      }

                      orderpadUiBloc.add(UpdateUi(
                        _appLocalizations.invest,
                        orderpadUiBloc.orderpadupdate.selectedOrderType,
                      ));

                      // checkMargin();
                    }
                  },
                  height: 40.w,
                  width: AppWidgetSize.fullWidth(context) / 2.5,
                  key: const Key(orderpadInvestButtonKey),
                  context: context,
                  title: _appLocalizations.invest,
                  isGradient: orderpadUiBloc
                              .orderpadupdate.selectedRegularProductTypeIndex ==
                          0
                      ? true
                      : false,
                  gradientColors: orderpadUiBloc.isBuyActionSelected()
                      ? [
                          Theme.of(context).colorScheme.onBackground,
                          Theme.of(context).primaryColor,
                        ]
                      : [
                          AppColors.negativeColor,
                          AppColors.negativeColor,
                        ],
                  isErrorButton: false,
                  borderColor: Theme.of(context).dividerColor,
                  inactiveTextColor:
                      Theme.of(context).primaryTextTheme.titleMedium!.color!,
                  bottom: 5.w,
                ),
                SizedBox(
                  width: AppWidgetSize.dimen_25,
                ),
                gradientButtonWidget(
                  onTap: () {
                    orderpadUiBloc.clearAllFocus();
                    if (!(orderpadUiBloc.isModifyOrder() ||
                        (orderpadUiBloc.isPositonExitOrAdd() &&
                            widget.arguments[AppConstants.isOpenPosition]))) {
                      sendEventToFirebaseAnalytics(
                          AppEvents.orderpadTradeclick,
                          ScreenRoutes.orderPadScreen,
                          'Clicked trade button in orderpad screen',
                          key: "symbol",
                          value: orderpadUiBloc
                              .orderpadupdate.currentSymbol.dispSym);
                      orderpadUiBloc
                          .orderpadupdate.selectedRegularProductTypeIndex = 1;

                      orderpadUiBloc.add(UpdateUi(_appLocalizations.trade,
                          orderpadUiBloc.orderpadupdate.selectedOrderType));

                      // checkMargin();
                    }
                  },
                  height: 40.w,
                  width: AppWidgetSize.fullWidth(context) / 2.5,
                  key: const Key(orderpadTradeButtonKey),
                  context: context,
                  title: _appLocalizations.trade,
                  isGradient: orderpadUiBloc
                              .orderpadupdate.selectedRegularProductTypeIndex ==
                          1
                      ? true
                      : false,
                  gradientColors: orderpadUiBloc.isBuyActionSelected()
                      ? [
                          Theme.of(context).colorScheme.onBackground,
                          Theme.of(context).primaryColor,
                        ]
                      : [
                          AppColors.negativeColor,
                          AppColors.negativeColor,
                        ],
                  isErrorButton: false,
                  borderColor: Theme.of(context).dividerColor,
                  inactiveTextColor:
                      Theme.of(context).primaryTextTheme.titleMedium!.color!,
                  bottom: 5.w,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                left: orderpadUiBloc.isExcNseOrBse()
                    ? AppWidgetSize.dimen_20
                    : AppWidgetSize.dimen_5,
                right: 30.w,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    orderpadUiBloc.isExcNseOrBse()
                        ? _appLocalizations.forDelivery
                        : _appLocalizations.forCarryForward,
                    Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  CustomTextWidget(
                    _appLocalizations.forIntraday,
                    Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQtyAndPriceWidget() {
    return Container(
      padding: EdgeInsets.only(
        top: 20.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ValueListenableBuilder<bool>(
              valueListenable: showAuthorizationMessage,
              builder: (context, snapshot, _) {
                return showAuthorizationMessage.value == false
                    ? const SizedBox.shrink()
                    : AnimatedSize(
                        curve: Curves.linear,
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                            padding: EdgeInsets.only(
                                left: 40.w, top: 20.w, bottom: 20.w),
                            color: isAuthorized
                                ? Theme.of(context)
                                    .snackBarTheme
                                    .backgroundColor!
                                    .withOpacity(0.5)
                                : Theme.of(context)
                                    .colorScheme
                                    .onSecondary
                                    .withOpacity(0.1),
                            child: Row(
                              children: [
                                isAuthorized
                                    ? AppImages.authorizationSuccess(context)
                                    : AppImages.authorizationFail(context),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isAuthorized
                                            ? "Authorization Successful"
                                            : "Authorization Failed",
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .labelSmall!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.w),
                                        child: Text(
                                          isAuthorized
                                              ? "You can execute your sell transactions"
                                              : "Oops , Try after sometime for authentication",
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .labelSmall!
                                              .copyWith(fontSize: 12.w),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )));
              }),
          buildQtyWidget(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildPriceWidget(),
              _buildCustomPriceCheckboxWidget(),
              if (orderpadUiBloc.orderpadupdate.validityList
                      .contains(AppConstants.gtd) &&
                  orderpadUiBloc.orderpadupdate.selectedValidity ==
                      AppConstants.gtd)
                _buildValidityDateWidget(context),
            ],
          ),
        ],
      ),
    );
  }

  Padding buildPriceWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: 20.w,
        bottom: 30.w,
        left: 30.w,
        right: 30.w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: orderpadUiBloc.orderpadupdate.isTriggerPriceEnabled
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          if (orderpadUiBloc.orderpadupdate.isTriggerPriceEnabled)
            _buildTextFieldWithFooterWidget(
                key: const Key(orderPadTriggerPriceTextFieldKey),
                lblText: _appLocalizations.triggerPrice,
                validator: (v) {
                  return null;

                  //  return orderpadUiBloc.triggerPriceError();
                },
                txtCtrl: orderpadUiBloc.orderpadupdate.triggerPriceController,
                focusnode: orderpadUiBloc.orderpadupdate.triggerPriceFocusNode,
                formatter: InputValidator.doubleValidator(
                    orderpadUiBloc.orderpadupdate.decimalPoint),
                keyboardType: orderpadUiBloc.orderpadupdate.priceKeyboardType,
                isTxtEnabled:
                    orderpadUiBloc.orderpadupdate.isTriggerPriceEnabled,
                isTitleTrailingAvailable: true,
                trailingWidget:
                    Container(), //_buildPriceToPercentToggleWidget(),
                isFooterAvailable: true,
                isRupeeSymbolRequired:
                    orderpadUiBloc.orderpadupdate.triggerPriceIndex == 0
                        ? true
                        : false,
                isPercentSymbolRequired:
                    orderpadUiBloc.orderpadupdate.triggerPriceIndex == 1
                        ? true
                        : false,
                footerWidget: Text(
                  '${_appLocalizations.range}${orderpadUiBloc.orderpadupdate.lcl}- ${orderpadUiBloc.orderpadupdate.ucl}',
                  style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                width: AppWidgetSize.fullWidth(context) / 2 -
                    AppWidgetSize.dimen_40,
                isInformationVisible: true),
          _buildTextFieldWithFooterWidget(
            key: const Key(orderPadPriceTextFieldKey),
            lblText: _appLocalizations.price,
            txtCtrl: orderpadUiBloc.orderpadupdate.priceController,
            focusnode: orderpadUiBloc.orderpadupdate.priceFocusNode,
            formatter: InputValidator.doubleValidator(
                orderpadUiBloc.orderpadupdate.decimalPoint),
            keyboardType: orderpadUiBloc.orderpadupdate.priceKeyboardType,
            isTxtEnabled: ((orderpadUiBloc.isModifyOrder()
                        ? ((orderpadUiBloc.isCoverOrder() &&
                                orderpadUiBloc.isMainOrderType()) ||
                            (orderpadUiBloc.isBracketOrder() &&
                                orderpadUiBloc.isMainOrderType()) ||
                            orderpadUiBloc.isGTD())
                        : true) ||
                    orderpadUiBloc.isRegularOrder()) &&
                orderpadUiBloc.orderpadupdate.isCustomPriceEnabled,
            isTitleTrailingAvailable: true,
            isRupeeSymbolRequired:
                orderpadUiBloc.orderpadupdate.isCustomPriceEnabled,
            trailingWidget: Text(
              '${_appLocalizations.tick}${orderpadUiBloc.orderpadupdate.currentSymbol.sym?.tickSize!}',
              style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            isFooterAvailable:
                orderpadUiBloc.orderpadupdate.isCustomPriceEnabled,
            textAlign: TextAlign.center,
            footerWidget: Text(
              '${_appLocalizations.range}${orderpadUiBloc.orderpadupdate.lcl}- ${orderpadUiBloc.orderpadupdate.ucl}',
              style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            width: orderpadUiBloc.orderpadupdate.isTriggerPriceEnabled
                ? AppWidgetSize.fullWidth(context) / 2 - AppWidgetSize.dimen_40
                : AppWidgetSize.dimen_200,
          ),
        ],
      ),
    );
  }

  final ValueNotifier<bool> showAuthorizationMessage =
      ValueNotifier<bool>(false);
  bool isAuthorized = false;
  buildQtyWidget() {
    return Padding(
        padding: EdgeInsets.only(
          top: 20.w,
          bottom: 30.w,
          left: 30.w,
          right: 30.w,
        ),
        child: ValueListenableBuilder(
            valueListenable: orderpadUiBloc.orderpadupdate.quantityController,
            builder: (context, value, v) {
              return ValueListenableBuilder(
                  valueListenable: orderpadUiBloc.orderpadupdate.investAmount,
                  builder: (context, snapshot, _) {
                    return _buildTextFieldWithFooterWidget(
                      key: const Key(orderPadQuantityTextFieldKey),
                      lblText: orderpadUiBloc.isMcx()
                          ? _appLocalizations.lotWithoutcolon
                          : orderpadUiBloc.orderpadupdate.isQuantity.value
                              ? _appLocalizations.quantity
                              : "Invest Amount",
                      txtCtrl: orderpadUiBloc.orderpadupdate.isQuantity.value
                          ? orderpadUiBloc.orderpadupdate.quantityController
                          : orderpadUiBloc.orderpadupdate.investAmount,
                      focusnode: orderpadUiBloc.orderpadupdate.qtyFocusNode,
                      formatter: InputValidator.qtyValidator,
                      keyboardType: TextInputType.number,
                      isQty: true,
                      isRupeeSymbolRequired:
                          !orderpadUiBloc.orderpadupdate.isQuantity.value,
                      isTxtEnabled: (orderpadUiBloc.isModifyOrder() &&
                              (orderpadUiBloc.isModifyOrderCoverOrder() &&
                                      orderpadUiBloc.isMainOrderType() ||
                                  orderpadUiBloc.isChildOrderSecondType() ||
                                  orderpadUiBloc.isModifyOrderBracketOrder() &&
                                      (orderpadUiBloc.isMainOrderType()
                                          ? AppUtils().doubleValue(
                                                  orderpadUiBloc.orderpadupdate
                                                      .orders.tradedQty) !=
                                              0
                                          : false) ||
                                  orderpadUiBloc.isChildOrderSecondType() ||
                                  orderpadUiBloc.isChildOrderThirdType()))
                          ? !(orderpadUiBloc.isCoverOrder() ||
                              orderpadUiBloc.isBracketOrder())
                          : true,
                      isTitleTrailingAvailable:
                          orderpadUiBloc.isExcNseOrBseandDelivery()
                              ? true
                              : !orderpadUiBloc.isExcNseOrBse(),
                      trailingWidget: orderpadUiBloc.isExcNseOrBseandDelivery()
                          ? buildToggle()
                          : Text(
                              orderpadUiBloc.isMcx()
                                  ? '${_appLocalizations.qty} : ${(AppUtils().doubleValue(orderpadUiBloc.orderpadupdate.quantityController.text.toString().withMultiplierOrderPad(orderpadUiBloc.orderpadupdate.symbols.sym, forall: true))).floor()}'
                                  : '${_appLocalizations.lot}${(AppUtils().doubleValue(orderpadUiBloc.orderpadupdate.quantityController.text.toString().removeMultiplierOrderPad(orderpadUiBloc.orderpadupdate.symbols.sym, forall: true))).floor()}',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                      isFooterAvailable:
                          orderpadUiBloc.isExcNseOrBseandDelivery() &&
                                  AppUtils().intValue(orderpadUiBloc
                                          .orderpadupdate
                                          .symbols
                                          .sym!
                                          .lotSize) <=
                                      1
                              ? true
                              : AppUtils().intValue(orderpadUiBloc
                                          .orderpadupdate
                                          .symbols
                                          .sym!
                                          .lotSize) <=
                                      1
                                  ? false
                                  : true,
                      footerWidget: orderpadUiBloc.isExcNseOrBseandDelivery() &&
                              AppUtils().intValue(orderpadUiBloc
                                      .orderpadupdate.symbols.sym!.lotSize) <=
                                  1
                          ? Text(
                              '${orderpadUiBloc.orderpadupdate.isQuantity.value ? "Invest Amt" : "Qty"} : ${orderpadUiBloc.orderpadupdate.isQuantity.value ? orderpadUiBloc.orderpadupdate.investAmount.text.isEmpty ? "--" : orderpadUiBloc.orderpadupdate.investAmount.text.commaFmt(decimalPoint: AppUtils().getDecimalpoint(orderpadUiBloc.orderpadupdate.currentSymbol.sym?.exc)) : orderpadUiBloc.orderpadupdate.quantityController.text.isEmpty ? "--" : orderpadUiBloc.orderpadupdate.quantityController.text.commaFmt(decimalPoint:0)} ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            )
                          : Text(
                              '${orderpadUiBloc.isExcCdsOrMcx() ? _appLocalizations.lotSize : _appLocalizations.minQty} : ${"1".withMultiplierOrderPad(orderpadUiBloc.orderpadupdate.symbols.sym, forall: true)} ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                      width: AppWidgetSize.dimen_200,
                      textAlign: TextAlign.center,
                    );
                  });
            }));
  }

  void lotInputChange(int type) {
    if (orderpadUiBloc.orderpadupdate.qtyFocusNode.hasFocus) {
      keyboardFocusOut();
    }
    int qty = AppUtils().intValue(
        orderpadUiBloc.orderpadupdate.quantityController.text != ''
            ? orderpadUiBloc.orderpadupdate.quantityController.text
            : '0');
    int lotSize = "1"
        .withMultiplierOrderPad(orderpadUiBloc.orderpadupdate.symbols.sym)
        .exInt();

    if (type == 1) {
      qty = qty - lotSize;

      if (qty >= lotSize) {
        final String value = (((qty / lotSize).floor()) * lotSize).toString();
        orderpadUiBloc.orderpadupdate.quantityController.text = value;
      } else {
        orderpadUiBloc.orderpadupdate.quantityController.text =
            lotSize.toString();
      }
    } else {
      qty = qty + 1;
      final String value = (((qty / lotSize).ceil()) * lotSize).toString();
      orderpadUiBloc.orderpadupdate.quantityController
        ..text = value
        ..selection = TextSelection.collapsed(offset: value.length);
    }
    orderpadUiBloc.add(CheckMariginEvent());
  }

  Widget _buildStopLossTriggerWidget() {
    return ValueListenableBuilder<String>(
      valueListenable: orderpadUiBloc.orderpadupdate.coTriggerPrice,
      builder: (context, value, _) {
        return Padding(
          padding: EdgeInsets.only(top: AppWidgetSize.dimen_20),
          child: _buildTextFieldWithFooterWidget(
            key: const Key(orderPadStopLossTriggerTextFieldKey),
            lblText: _appLocalizations.stopLossTrigger,
            txtCtrl: orderpadUiBloc.orderpadupdate.stopLossTriggerController,
            focusnode: orderpadUiBloc.orderpadupdate.stopLossTriggerFocusNode,
            formatter: InputValidator.doubleValidator(
                orderpadUiBloc.orderpadupdate.decimalPoint),
            keyboardType: orderpadUiBloc.orderpadupdate.priceKeyboardType,
            isTxtEnabled: (!orderpadUiBloc.isMainOrderType() ||
                orderpadUiBloc.isRepeatOrder()),
            isTitleTrailingAvailable: false,
            isRupeeSymbolRequired: true,
            trailingWidget: Text(
              '${_appLocalizations.tick}${orderpadUiBloc.orderpadupdate.symbols.sym!.tickSize}',
              style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            isFooterAvailable: true,
            footerWidget: Text(
              '${_appLocalizations.range} ${orderpadUiBloc.orderpadupdate.coTriggerPrice.value}',
              style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            width: 200.w,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        );
      },
    );
  }

  Widget _buildBracketOrderSecondLegWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: 30.w,
        left: 30.w,
        right: 30.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: orderpadUiBloc.isModifyOrder() &&
                    (orderpadUiBloc.isChildOrderSecondType() ||
                        orderpadUiBloc.isChildOrderThirdType())
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              if (orderpadUiBloc.isModifyOrder()
                  ? (orderpadUiBloc.isMainOrderType() ||
                      orderpadUiBloc.isChildOrderThirdType())
                  : true)
                _buildTextFieldWithFooterWidget(
                  key: const Key(orderPadStopLossTextFieldKey),
                  lblText: (orderpadUiBloc.isModifyOrder() &&
                          !orderpadUiBloc.isMainOrderType())
                      ? orderpadUiBloc.isBuyActionSelected()
                          ? _appLocalizations.stopLossBuy
                          : _appLocalizations.stopLossSell
                      : orderpadUiBloc.isBuyActionSelected()
                          ? _appLocalizations.stopLossSell
                          : _appLocalizations.stopLossBuy,
                  txtCtrl: orderpadUiBloc.orderpadupdate.stopLossController,
                  focusnode: orderpadUiBloc.orderpadupdate.stopLossFocusNode,
                  formatter: InputValidator.doubleValidator(
                      orderpadUiBloc.orderpadupdate.decimalPoint),
                  keyboardType: orderpadUiBloc.orderpadupdate.priceKeyboardType,
                  isTxtEnabled: true,
                  isTitleTrailingAvailable: false,
                  trailingWidget: Container(),
                  isRupeeSymbolRequired: true,
                  isFooterAvailable: true,
                  textAlign: TextAlign.center,
                  footerWidget: Text(
                    '${_appLocalizations.range}${orderpadUiBloc.orderpadupdate.lcl}- ${orderpadUiBloc.orderpadupdate.ucl}',
                    style:
                        Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                  ),
                  width: (orderpadUiBloc.isModifyOrder() &&
                          !orderpadUiBloc.isMainOrderType())
                      ? AppWidgetSize.dimen_200
                      : (AppWidgetSize.fullWidth(context) / 2 -
                          AppWidgetSize.dimen_40),
                ),
              if (orderpadUiBloc.isModifyOrder()
                  ? (orderpadUiBloc.isChildOrderSecondType() ||
                      orderpadUiBloc.isMainOrderType())
                  : true)
                _buildTextFieldWithFooterWidget(
                  key: const Key(orderPadTargetPriceTextFieldKey),
                  lblText: _appLocalizations.targetPrice,
                  txtCtrl: orderpadUiBloc.orderpadupdate.targetPriceController,
                  focusnode: orderpadUiBloc.orderpadupdate.targetPriceFocusNode,
                  formatter: InputValidator.doubleValidator(
                      orderpadUiBloc.orderpadupdate.decimalPoint),
                  keyboardType: orderpadUiBloc.orderpadupdate.priceKeyboardType,
                  isTxtEnabled: true,
                  isTitleTrailingAvailable: false,
                  trailingWidget: Container(),
                  isRupeeSymbolRequired: true,
                  isFooterAvailable: true,
                  textAlign: TextAlign.center,
                  footerWidget: Text(
                    '${_appLocalizations.range}${orderpadUiBloc.orderpadupdate.lcl}- ${orderpadUiBloc.orderpadupdate.ucl}',
                    style:
                        Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                  ),
                  width: (orderpadUiBloc.isModifyOrder() &&
                          !orderpadUiBloc.isMainOrderType())
                      ? AppWidgetSize.dimen_200
                      : (AppWidgetSize.fullWidth(context) / 2 -
                          AppWidgetSize.dimen_40),
                ),
            ],
          ),
          // if (!orderpadUiBloc.isModifyOrder() ||
          //     orderpadUiBloc.isMainOrderType())
          //   Padding(
          //     padding: EdgeInsets.only(
          //       top: 30.w,
          //     ),
          //     child: _buildTextFieldWithFooterWidget(
          //       key: const Key(orderPadTrailingStopLossTextFieldKey),
          //       lblText: _appLocalizations.trailingStopLoss,
          //       txtCtrl:
          //           orderpadUiBloc.orderpadupdate.trailingStopLossController,
          //       focusnode:
          //           orderpadUiBloc.orderpadupdate.trailingStopLossFocusNode,
          //       formatter: InputValidator.doubleValidator(
          //           orderpadUiBloc.orderpadupdate.decimalPoint),
          //       keyboardType: orderpadUiBloc.orderpadupdate.priceKeyboardType,
          //       isRupeeSymbolRequired: true,
          //       isTxtEnabled: true,
          //       isTitleTrailingAvailable: false,
          //       trailingWidget: Container(),
          //       isFooterAvailable: false,
          //       footerWidget: Container(),
          //       width: AppWidgetSize.fullWidth(context) / 2 - 40.w,
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildCustomPriceCheckboxWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Opacity(
          opacity: orderpadUiBloc.orderpadupdate.disableCustomPriceCheckbox
              ? 0.3
              : 1,
          child: GestureDetector(
            onTap: () {
              if (!orderpadUiBloc.orderpadupdate.disableCustomPriceCheckbox) {
                orderpadUiBloc.customPriceOnChange(
                  context: context,
                );
              }
              if (!orderpadUiBloc.orderpadupdate.isQuantity.value) {
                orderpadUiBloc.orderpadupdate.quantityController
                    .text = (orderpadUiBloc.orderpadupdate.investAmount.text
                            .exdouble() /
                        (orderpadUiBloc.orderpadupdate.priceController.text ==
                                _appLocalizations.atMarket
                            ? orderpadUiBloc.orderpadupdate.ltp.exdouble()
                            : orderpadUiBloc.orderpadupdate.priceController.text
                                .exdouble()))
                    .toString()
                    .exInt()
                    .toString();
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CheckboxWidget(
                  checkBoxValue:
                      orderpadUiBloc.orderpadupdate.isCustomPriceEnabled,
                  isDisabled:
                      orderpadUiBloc.orderpadupdate.disableCustomPriceCheckbox,
                  valueChanged: (bool checkboxdata) {
                    if (!orderpadUiBloc
                        .orderpadupdate.disableCustomPriceCheckbox) {
                      orderpadUiBloc.customPriceOnChange(
                        context: context,
                      );
                    }
                  },
                  addSymbolKey: orderpadCustomPriceCheckboxKey,
                  enableIcon: orderpadUiBloc.isBuyActionSelected()
                      ? AppImages.filterSelectedIcon(
                          context,
                          width: 16.w,
                          height: 16.w,
                        )
                      : AppImages.redCheckboxEnableIcon(
                          context,
                          width: 16.w,
                          height: 16.w,
                        ),
                  disableIcon: AppImages.filterUnSelectedIcon(
                    context,
                    width: 16.w,
                    height: 16.w,
                    isColor: true,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 8.w,
                    top: AppWidgetSize.dimen_1,
                  ),
                  child: CustomTextWidget(
                    _appLocalizations.customPrice,
                    Theme.of(context).primaryTextTheme.bodySmall,
                  ),
                )
              ],
            ),
          ),
        ),
        Opacity(
          opacity: (orderpadUiBloc.orderpadupdate.isTriggerPriceEnabled
                  ? (orderpadUiBloc.orderpadupdate.isTriggerPriceEnabled)
                  : (((orderpadUiBloc.isModifyOrder()
                                  ? ((orderpadUiBloc.isCoverOrder() &&
                                          orderpadUiBloc.isMainOrderType()) ||
                                      (orderpadUiBloc.isBracketOrder() &&
                                          orderpadUiBloc.isMainOrderType()))
                                  : true) ||
                              orderpadUiBloc.isRegularOrder() ||
                              (orderpadUiBloc.isGTD())) &&
                          orderpadUiBloc.orderpadupdate.isCustomPriceEnabled) ||
                      (orderpadUiBloc.orderpadupdate.priceController.text ==
                              _appLocalizations.atMarket &&
                          !orderpadUiBloc
                              .orderpadupdate.disableCustomPriceCheckbox))
              ? 1
              : 0.4,
          child: GestureDetector(
            onTap: () {
              if (orderpadUiBloc.orderpadupdate.isTriggerPriceEnabled
                  ? (orderpadUiBloc.orderpadupdate.isTriggerPriceEnabled)
                  : (((orderpadUiBloc.isModifyOrder()
                                  ? ((orderpadUiBloc.isCoverOrder() &&
                                          orderpadUiBloc.isMainOrderType()) ||
                                      (orderpadUiBloc.isBracketOrder() &&
                                          orderpadUiBloc.isMainOrderType()) ||
                                      (orderpadUiBloc.isGTD()))
                                  : true) ||
                              orderpadUiBloc.isRegularOrder()) &&
                          orderpadUiBloc.orderpadupdate.isCustomPriceEnabled) ||
                      orderpadUiBloc.orderpadupdate.priceController.text ==
                              _appLocalizations.atMarket &&
                          !orderpadUiBloc
                              .orderpadupdate.disableCustomPriceCheckbox) {
                showMarketDepth();
              }
            },
            child: Padding(
              padding: EdgeInsets.only(left: 60.w),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: AppImages.marketDepth(context,
                        isColor: true,
                        height: 30.w,
                        width: 30.w,
                        color: !orderpadUiBloc.isBuyActionSelected()
                            ? AppColors.negativeColor
                            : Theme.of(context).primaryColor),
                  ),
                  Text(
                    AppLocalizations().depth,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .bodySmall
                        ?.copyWith(
                            fontSize: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge
                                ?.fontSize),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildAdvanceOptionsWidget(
    BuildContext context,
  ) {
    return _buildExpansionRow(
      context,
      _appLocalizations.advancedOptions,
      _buildAdvanceOptionExpandedWidget(context),
    );
  }

  Widget _buildAdvanceOptionExpandedWidget(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!orderpadUiBloc.isCoverOrder()) _buildOrderTypeWidget(context),
        _buildValidityWidget(context),
        if (orderpadUiBloc.orderpadupdate.exchangeList!.elementAt(
                orderpadUiBloc.orderpadupdate.selectedExchangeIndex) !=
            AppConstants.nfo)
          ValueListenableBuilder<bool>(
              valueListenable: orderpadUiBloc.orderpadupdate.isAmoEnabled,
              builder: (_, value, child) {
                return _buildDisclosedQtyAndValidityDateWidget(context);
              }),
      ],
    );
  }

  Widget _buildOrderTypeWidget(
    BuildContext context,
  ) {
    return (orderpadUiBloc.isModifyOrder() &&
            orderpadUiBloc.isModifyOrderBracketOrder())
        ? Container()
        : Container(
            padding: EdgeInsets.only(
              bottom: 30.w,
            ),
            width: AppWidgetSize.fullWidth(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10.w,
                        bottom: 8.w,
                      ),
                      child: CustomTextWidget(
                        _appLocalizations.orderType,
                        Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                    _buildCircularToggleWidgetForOrderType(
                      context,
                      orderpadUiBloc.getSelectedOrderTypeType(),
                      orderpadUiBloc.orderpadupdate.orderTypeList,
                      orderPadOrderTypeKey,
                    ),
                  ],
                ),
              ],
            ),
          );
  }

  Widget _buildValidityWidget(
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: SizedBox(
        width: AppWidgetSize.fullWidth(context),
        child: _buildValidityCirularButtonAndAmoWidget(),
      ),
    );
  }

  Widget _buildValidityCirularButtonAndAmoWidget() {
    if (!orderpadUiBloc.isSelectedValidityAvailableInValidityList(
        orderpadUiBloc.getProductTypeString(),
        orderpadUiBloc.orderpadupdate.selectedOrderType)) {
      orderpadUiBloc.orderpadupdate.selectedValidity = AppConstants.day;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: 8.w,
              ),
              child: CustomTextWidget(
                _appLocalizations.validity,
                Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            _buildCircularToggleWidgetForValidity(
              context,
              orderpadUiBloc.orderpadupdate.selectedValidity,
              orderpadUiBloc.orderpadupdate.validityList,
              orderPadValidityKey,
            ),
          ],
        ),
        if (orderpadUiBloc.orderpadupdate.isShowAmoWidget)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(
                    bottom: 8.w,
                  ),
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 5.w,
                    ),
                    width: 130.w,
                    child: CustomTextWidget(
                      _appLocalizations.afterMarketOrder,
                      Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  )),
              _buildAmoWidget(),
            ],
          ),
      ],
    );
  }

  Widget _buildAmoWidget() {
    return GestureDetector(
      onTap: () {
        if (!orderpadUiBloc.isModifyOrder()) onAmoChanged();
      },
      child: Opacity(
        opacity: orderpadUiBloc.isModifyOrder() ? 0.4 : 1,
        child: SizedBox(
          width: 130.w,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ValueListenableBuilder<bool>(
                  valueListenable: orderpadUiBloc.orderpadupdate.isAmoEnabled,
                  builder: (_, value, child) {
                    return CheckboxWidget(
                      checkBoxValue:
                          orderpadUiBloc.orderpadupdate.isAmoEnabled.value,
                      valueChanged: (bool checkboxdata) {
                        onAmoChanged();
                      },
                      isDisabled: orderpadUiBloc.isModifyOrder(),
                      addSymbolKey: orderpadAmoCheckboxKey,
                      enableIcon: orderpadUiBloc.isBuyActionSelected()
                          ? AppImages.filterSelectedIcon(
                              context,
                              width: 16.w,
                              height: 16.w,
                            )
                          : AppImages.redCheckboxEnableIcon(
                              context,
                              width: 16.w,
                              height: 16.w,
                            ),
                      disableIcon: AppImages.filterUnSelectedIcon(
                        context,
                        isColor: true,
                        color: Theme.of(context).disabledColor,
                        width: 16.w,
                        height: 16.w,
                      ),
                    );
                  }),
              Padding(
                padding: EdgeInsets.only(
                  left: 8.w,
                  top: AppWidgetSize.dimen_1,
                ),
                child: CustomTextWidget(
                  _appLocalizations.amo,
                  Theme.of(context).primaryTextTheme.bodySmall,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void onAmoChanged() {
    if (!(orderpadUiBloc.isModifyOrder() &&
        marketStatusBloc.marketStatusDoneState.isOpen)) {
      orderpadUiBloc.orderpadupdate.isAmoCheckBoxInteracted = true;
      orderpadUiBloc.orderpadupdate.isAmoEnabled.value =
          !orderpadUiBloc.orderpadupdate.isAmoEnabled.value;

      scrollToEnd();
    }
  }

  void scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 200), () {
      orderpadUiBloc.orderpadupdate.orderpadBodyScrollController.animateTo(
          orderpadUiBloc.orderpadupdate.orderpadBodyScrollController.position
              .maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.ease);
    });
  }

//have disclosed qty and gtd calender
  Widget _buildDisclosedQtyAndValidityDateWidget(
    BuildContext context,
  ) {
    return orderpadUiBloc.isModifyOrder() &&
            orderpadUiBloc.isModifyOrderBracketOrder()
        ? Container()
        : Container(
            padding: EdgeInsets.only(
              top: 10.w,
              bottom: 30.w,
            ),
            width: AppWidgetSize.fullWidth(context),
            child: Row(
              mainAxisAlignment:
                  !orderpadUiBloc.orderpadupdate.isAmoEnabled.value &&
                          orderpadUiBloc.orderpadupdate.selectedValidity !=
                              AppConstants.ioc
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
              children: [
                if (!orderpadUiBloc.orderpadupdate.isAmoEnabled.value &&
                    orderpadUiBloc.orderpadupdate.selectedValidity !=
                        AppConstants.ioc &&
                    orderpadUiBloc.orderpadupdate.selectedValidity !=
                        AppConstants.gtd &&
                    orderpadUiBloc.orderpadupdate.isShowDiscloseQty)
                  _buildDisclosedQtyWidget(context),
              ],
            ),
          );
  }

  Widget _buildDisclosedQtyWidget(
    BuildContext context,
  ) {
    return _buildTextFieldWithFooterWidget(
      key: const Key(orderPadDisclosedQtyTextFieldKey),
      lblText: _appLocalizations.disclosedQtyOpt,
      txtCtrl: orderpadUiBloc.orderpadupdate.disclosedQtyController,
      focusnode: orderpadUiBloc.orderpadupdate.disclosedQtyFocusNode,
      formatter: InputValidator.qtyValidator,
      keyboardType: TextInputType.number,
      isTxtEnabled: true,
      isTitleTrailingAvailable: false,
      trailingWidget: Container(),
      isFooterAvailable: false,
      footerWidget: Container(),
      style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
      width: 150.w,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildValidityDateWidget(
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 20.w),
      child: _buildTextFieldWithFooterWidget(
        key: const Key(orderpadValidityDateKey),
        lblText: _appLocalizations.validityDate,
        txtCtrl: orderpadUiBloc.orderpadupdate.validityDateController,
        focusnode: orderpadUiBloc.orderpadupdate.validityFocusNode,
        formatter: InputValidator.qtyValidator,
        keyboardType: TextInputType.number,
        isTxtEnabled: false,
        isDate: true,
        isTitleTrailingAvailable: false,
        trailingWidget: Container(),
        isFooterAvailable: false,
        footerWidget: Container(),
        style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
        width: AppWidgetSize.dimen_200,
        textAlign: TextAlign.left,
        showCloseButton: false,
      ),
    );
  }

  //common widgets

  Widget _buildTextFieldWithFooterWidget(
      {required Key key,
      required String lblText,
      required TextEditingController txtCtrl,
      required FocusNode focusnode,
      required List<TextInputFormatter> formatter,
      required TextInputType keyboardType,
      required bool isTxtEnabled,
      required bool isTitleTrailingAvailable,
      required bool isFooterAvailable,
      bool isQty = false,
      bool isDate = false,
      required Widget trailingWidget,
      required Widget footerWidget,
      bool isRupeeSymbolRequired = false,
      bool isPercentSymbolRequired = false,
      TextStyle? style,
      bool isInformationVisible = false,
      double width = 200,
      TextAlign textAlign = TextAlign.center,
      CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
      bool showCloseButton = true,
      String? Function(String?)? validator}) {
    style ??= Theme.of(context).primaryTextTheme.labelSmall;
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        SizedBox(
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: () {
                    if (isInformationVisible) {
                      OrderPadInfo.tgPriceInformationIconBottomSheet(context);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (lblText.startsWith("Trailing"))
                        SizedBox(
                          width: width,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              lblText,
                              style: style,
                            ),
                          ),
                        )
                      else
                        Text(
                          lblText,
                          style: style,
                        ),
                      if (isInformationVisible)
                        AppImages.informationIcon(
                          context,
                          color: Theme.of(context).primaryIconTheme.color,
                          isColor: true,
                          width: 22.w,
                          height: 22.w,
                        ),
                    ],
                  )),
              if (isTitleTrailingAvailable) trailingWidget
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 5.w,
          ),
          child: SizedBox(
            width: width,
            child: FocusScope(
              child: Focus(
                onFocusChange: (value) {
                  if (key == const Key(orderPadQuantityTextFieldKey)) {
                    orderpadUiBloc.orderpadupdate.isQuantityTextFieldInFocus =
                        value;
                    setState(() {});
                  }
                },
                child: Opacity(
                  opacity: isTxtEnabled ||
                          txtCtrl.text == _appLocalizations.atMarket ||
                          isDate
                      ? 1
                      : 0.65,
                  child: TextFormField(
                      key: key,
                      enabled: isTxtEnabled ||
                          (txtCtrl.text == _appLocalizations.atMarket &&
                              !orderpadUiBloc
                                  .orderpadupdate.disableCustomPriceCheckbox) ||
                          isDate,
                      readOnly: !isTxtEnabled,
                      enableInteractiveSelection: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: validator,
                      toolbarOptions: const ToolbarOptions(
                        copy: false,
                        cut: false,
                        paste: false,
                        selectAll: false,
                      ),
                      scrollPadding: EdgeInsets.only(
                        bottom: 50.w,
                      ),
                      onTap: () async {
                        if (key == const Key(orderPadPriceTextFieldKey) &&
                            orderpadUiBloc
                                    .orderpadupdate.priceController.text ==
                                _appLocalizations.atMarket) {
                          if (!orderpadUiBloc
                              .orderpadupdate.disableCustomPriceCheckbox) {
                            orderpadUiBloc.customPriceOnChange(
                              context: context,
                            );
                            focusnode.requestFocus();
                            await Future.delayed(
                                const Duration(milliseconds: 10));

                            orderpadUiBloc
                                    .orderpadupdate.priceController.value =
                                TextEditingValue(
                                    text: orderpadUiBloc
                                        .orderpadupdate.priceController.text,
                                    selection: TextSelection.collapsed(
                                        offset: orderpadUiBloc.orderpadupdate
                                            .priceController.text.length));
                          }
                        }
                      },
                      controller: txtCtrl,
                      focusNode: focusnode,
                      cursorColor: Theme.of(context).primaryIconTheme.color,
                      textAlign: isDate ? textAlign : TextAlign.center,
                      onChanged: (String data) {
                        orderpadUiBloc.add(CheckMariginEvent());
                        if (key == const Key(orderPadQuantityTextFieldKey)) {
                          setState(() {});
                        }
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        filled: isTxtEnabled,
                        isDense: true,
                        enabledBorder: textBorder(),
                        prefixIconConstraints: BoxConstraints(
                          maxHeight: 50.w,
                        ),
                        prefixIcon: SizedBox(
                            width: isDate ? 20.w : 30.w,
                            child: (!orderpadUiBloc.isExcNseOrBse() && isQty)
                                ? qtyDecWidget()
                                : isRupeeSymbolRequired &&
                                        (focusnode.hasFocus ||
                                            txtCtrl.text.isNotEmpty)
                                    ? Container(
                                        height: 22.w,
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.only(
                                            left: 10.w, right: 15.w),
                                        child: CustomTextWidget(
                                          AppConstants.rupeeSymbol,
                                          Theme.of(context)
                                              .primaryTextTheme
                                              .labelSmall!
                                              .copyWith(
                                                  fontFamily:
                                                      AppConstants.interFont,
                                                  fontSize: 16.w),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : null),
                        suffixIconConstraints: BoxConstraints(
                          maxHeight: 50.w,
                        ),
                        suffixIcon: SizedBox(
                            width: 40.w,
                            child:
                                ((orderpadUiBloc.isExcNseOrBse() || !isQty) &&
                                        isTxtEnabled)
                                    ? closeButton(showCloseButton, txtCtrl, key)
                                    : (!orderpadUiBloc.isExcNseOrBse() && isQty)
                                        ? qtyIncWidget()
                                        : isDate
                                            ? dateWidget()
                                            : SizedBox(width: 20.w)),
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        border: textBorder(),
                        focusedBorder: textBorder(),
                        errorMaxLines: 5,
                        errorStyle: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.negativeColor),
                        errorBorder: textBorder(color: AppColors.negativeColor),
                        contentPadding: EdgeInsets.only(
                          top: 16.w,
                          bottom: 15.w,
                        ),
                        disabledBorder: isDate
                            ? textBorder()
                            : textBorder(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.5)),
                        prefixStyle: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontFamily: AppConstants.interFont),
                        suffixStyle: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontFamily: AppConstants.interFont),
                        hintText: key == const Key(orderPadQuantityTextFieldKey)
                            ? orderpadUiBloc
                                    .orderpadupdate.isQuantityTextFieldInFocus
                                ? ''
                                : '0'
                            : '',
                        hintStyle:
                            Theme.of(context).primaryTextTheme.labelSmall,
                        labelStyle:
                            Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                      inputFormatters: formatter,
                      keyboardType: keyboardType,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .labelSmall
                          ?.copyWith(fontSize: 15.w)),
                ),
              ),
            ),
          ),
        ),
        if (isFooterAvailable)
          Container(
            height: 25.w,
            alignment: Alignment.centerLeft,
            width: width,
            child: FittedBox(fit: BoxFit.scaleDown, child: footerWidget),
          )
      ],
    );
  }

  dateWidget() {
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: GestureDetector(
        key: const Key(orderpadCalendarIconKey),
        onTap: () {
          _displayDatePickerWidget(context);
        },
        child: Padding(
          padding: EdgeInsets.all(AppWidgetSize.dimen_8),
          child: AppImages.calendarIcon(
            context,
            color: Theme.of(context).primaryIconTheme.color,
          ),
        ),
      ),
    );
  }

  qtyDecWidget() {
    return Container(
      padding: EdgeInsets.only(left: 10.w),
      width: 40.w,
      child: GestureDetector(
        onTap: () {
          if (orderpadUiBloc.isModifyOrder() &&
              (orderpadUiBloc.isModifyOrderCoverOrder() &&
                      orderpadUiBloc.isMainOrderType() ||
                  orderpadUiBloc.isChildOrderSecondType() ||
                  orderpadUiBloc.isModifyOrderBracketOrder() &&
                      orderpadUiBloc.isMainOrderType() ||
                  orderpadUiBloc.isChildOrderSecondType() ||
                  orderpadUiBloc.isChildOrderThirdType())) {
          } else {
            lotInputChange(1);
          }
        },
        child: AppImages.qtyDecreaseIcon(
          context,
          color: Theme.of(context).primaryIconTheme.color,
          isColor: true,
          width: AppWidgetSize.dimen_22,
          height: AppWidgetSize.dimen_22,
        ),
      ),
    );
  }

  qtyIncWidget() {
    return SizedBox(
      width: 40.w,
      child: GestureDetector(
        onTap: () {
          if (orderpadUiBloc.isModifyOrder() &&
              (orderpadUiBloc.isModifyOrderCoverOrder() &&
                      orderpadUiBloc.isMainOrderType() ||
                  orderpadUiBloc.isChildOrderSecondType() ||
                  orderpadUiBloc.isModifyOrderBracketOrder() &&
                      orderpadUiBloc.isMainOrderType() ||
                  orderpadUiBloc.isChildOrderSecondType() ||
                  orderpadUiBloc.isChildOrderThirdType())) {
          } else {
            lotInputChange(2);
          }
        },
        child: AppImages.qtyIncreaseIcon(
          context,
          color: Theme.of(context).primaryIconTheme.color,
          isColor: true,
          width: AppWidgetSize.dimen_22,
          height: AppWidgetSize.dimen_22,
        ),
      ),
    );
  }

  OutlineInputBorder textBorder({Color? color}) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color ?? Theme.of(context).dividerColor,
        width: 1.w,
      ),
      borderRadius: BorderRadius.circular(
        3.w,
      ),
    );
  }

  closeButton(bool showCloseButton, TextEditingController txtCtrl, Key key) {
    return Container(
      alignment: Alignment.centerRight,
      height: AppWidgetSize.dimen_20,
      width: 40.w,
      child: showCloseButton &&
              (txtCtrl.text != '' &&
                  txtCtrl.text != _appLocalizations.atMarket) &&
              (/* key != const Key(orderPadQuantityTextFieldKey) && */
                  txtCtrl.text != '0')
          ? Container(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  txtCtrl.clear();
                  setState(() {});
                  orderpadUiBloc.add(CheckMariginEvent());
                },
                child: AppImages.deleteIcon(
                  context,
                  color: Theme.of(context).primaryIconTheme.color,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildExpansionRow(
    BuildContext context,
    String title,
    Widget childWidget,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20.w,
        left: 30.w,
        right: 30.w,
        bottom: 5.w,
      ),
      child: Column(
        children: [
          Divider(
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          Theme(
            data: ThemeData().copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.only(
                left: 0,
                bottom: 0,
              ),
              title: _buildHeaderWidget(title),
              iconColor: Theme.of(context).primaryIconTheme.color,
              initiallyExpanded: orderpadUiBloc.isGTD(),
              collapsedIconColor: Theme.of(context).primaryIconTheme.color,
              expandedCrossAxisAlignment: CrossAxisAlignment.end,
              onExpansionChanged: (value) {
                orderpadUiBloc.orderpadupdate.isAdvancedOptionsExpanded.value =
                    !orderpadUiBloc
                        .orderpadupdate.isAdvancedOptionsExpanded.value;

                if (value) {
                  scrollToEnd();
                } else {
                  orderpadUiBloc.orderpadupdate.orderpadBodyScrollController
                      .animateTo(0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease);
                }
              },
              trailing: GestureDetector(
                onTap: () {
                  OrderPadInfo.advancedInformationIconBottomSheet(context);
                  // showAlert("test");
                },
                child: AppImages.informationIcon(
                  context,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true,
                  width: AppWidgetSize.dimen_25,
                  height: AppWidgetSize.dimen_25,
                ),
              ),
              children: <Widget>[
                childWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWidget(String title) {
    return Row(
      children: [
        CustomTextWidget(
          title,
          Theme.of(context).primaryTextTheme.labelSmall,
        ),
        ValueListenableBuilder<bool>(
            valueListenable:
                orderpadUiBloc.orderpadupdate.isAdvancedOptionsExpanded,
            builder: (context, value, _) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 5.w,
                ),
                child: value
                    ? AppImages.upArrowCircleIcon(navigatorKey.currentContext!,
                        color: Theme.of(navigatorKey.currentContext!)
                            .primaryIconTheme
                            .color,
                        isColor: true,
                        height: 18.w)
                    : AppImages.downArrowCircleIcon(
                        navigatorKey.currentContext!,
                        color: Theme.of(navigatorKey.currentContext!)
                            .primaryIconTheme
                            .color,
                        isColor: true,
                        height: 18.w),
              );
            }),
      ],
    );
  }

  Widget _buildCircularToggleWidgetForOrderType(
    BuildContext context,
    String selectedValue,
    List<String> toggleButtonList,
    String key,
  ) {
    return CircularButtonToggleWidget(
      value: selectedValue,
      toggleButtonlist: toggleButtonList,
      toggleButtonOnChanged: (currentSelectedOrderType) async {
        final bool? isorderTypeBottomSheetShown =
            await AppStorage().getData(orderTypeBottomSheetShown);
        if (isorderTypeBottomSheetShown == false ||
            isorderTypeBottomSheetShown == null &&
                currentSelectedOrderType != AppConstants.limit) {
          // ignore: use_build_context_synchronously
          OrderPadInfo.showSlSlmInformationBottomSheet(context);
        } else {
          orderpadUiBloc.add(OrdertypeChange(currentSelectedOrderType ==
                  orderpadUiBloc.orderpadupdate.selectedOrderType
              ? currentSelectedOrderType == AppConstants.slM
                  ? AppConstants.market
                  : currentSelectedOrderType == AppConstants.sl
                      ? AppConstants.limit
                      : currentSelectedOrderType
              : currentSelectedOrderType));
        }
      },
      activeButtonColor: orderpadUiBloc.isBuyActionSelected()
          ? Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.5)
          : Theme.of(context).colorScheme.onSecondary.withOpacity(0.2),
      activeTextColor: orderpadUiBloc.isBuyActionSelected()
          ? Theme.of(context).primaryColor
          : AppColors.negativeColor,
      inactiveButtonColor: Colors.transparent,
      inactiveTextColor: Theme.of(context).primaryTextTheme.titleMedium!.color!,
      key: Key(key),
      defaultSelected: '',
      enabledButtonlist: const [],
      isBorder: true,
      context: context,
      paddingEdgeInsets: EdgeInsets.only(
        left: AppWidgetSize.dimen_14,
        right: AppWidgetSize.dimen_14,
        top: AppWidgetSize.dimen_4,
        bottom: AppWidgetSize.dimen_4,
      ),
      marginEdgeInsets: EdgeInsets.only(
        right: 10.w,
      ),
      fontSize: 18.w,
      islightBorderColor: true,
      borderColor: orderpadUiBloc.isBuyActionSelected()
          ? Theme.of(context).primaryColor
          : Theme.of(context).colorScheme.onError,
      isResetSelectionAllowed: true,
    );
  }

  Widget _buildCircularToggleWidgetForValidity(
    BuildContext context,
    String selectedValue,
    List<String> toggleButtonList,
    String key,
  ) {
    return SizedBox(
      width: (AppWidgetSize.fullWidth(context) / 2) - 40.w,
      child: CircularButtonToggleWidget(
        value: selectedValue,
        toggleButtonlist: toggleButtonList,
        toggleButtonOnChanged: (data) {
          orderpadUiBloc.add(ValidityChange(data));
        },
        activeButtonColor: orderpadUiBloc.isBuyActionSelected()
            ? Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.5)
            : Theme.of(context).colorScheme.onSecondary.withOpacity(0.2),
        activeTextColor: orderpadUiBloc.isBuyActionSelected()
            ? Theme.of(context).primaryColor
            : AppColors.negativeColor,
        inactiveButtonColor: Colors.transparent,
        inactiveTextColor:
            Theme.of(context).primaryTextTheme.titleMedium!.color!,
        key: Key(key),
        defaultSelected: '',
        enabledButtonlist: const [],
        isBorder: true,
        runSpacing: 15.w,
        context: context,
        paddingEdgeInsets: EdgeInsets.only(
          left: AppWidgetSize.dimen_14,
          right: AppWidgetSize.dimen_14,
          top: AppWidgetSize.dimen_4,
          bottom: AppWidgetSize.dimen_4,
        ),
        marginEdgeInsets: EdgeInsets.only(
          right: 10.w,
        ),
        fontSize: 18.w,
        islightBorderColor: true,
        borderColor: orderpadUiBloc.isBuyActionSelected()
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.onError,
      ),
    );
  }

  //Functions

  void _placeOrder() {
    //send qty if isExcCdsOrMcx, then send lot or send it as qty. for displaying vice versa

    if (orderpadUiBloc.isvalidForPlaceOrder()) {
      if (reviewOrder) {
        showReviewbottomsheet(context);

        return;
      }

      if (orderpadUiBloc.isModifyOrder() ||
          (orderpadUiBloc.orderpadupdate.basketorderId?.isNotEmpty ?? false)) {
        if ((orderpadUiBloc.orderpadupdate.basketorderId?.isNotEmpty ??
            false)) {
          orderpadUiBloc.orderpadupdate.isPlaceOrderSelected.value = true;
          orderPadBloc!.add(ModifyOrderPadPlaceOrderEvent(
              orderpadUiBloc.getOrderPayloadData(
                pos: (widget.arguments["basketData"]["position"]),
              ),
              orderpadUiBloc.isGTD(),
              basketorder:
                  (widget.arguments["basketData"]["fromBasket"] ?? false)));
        } else {
          orderpadUiBloc.orderpadupdate.isPlaceOrderSelected.value = true;
          orderPadBloc!.add(ModifyOrderPadPlaceOrderEvent(
            orderpadUiBloc.getOrderPayloadData(),
            orderpadUiBloc.isGTD(),
          ));
        }
        //basket
      } else {
        orderpadUiBloc.orderpadupdate.isPlaceOrderSelected.value = true;
        if (widget.arguments["basketData"] != null) {
          orderPadBloc!.add(OrderPadPlaceOrderEvent(
              orderpadUiBloc.getOrderPayloadData(
                  pos: (widget.arguments["basketData"]["position"])),
              orderpadUiBloc.isGTD(),
              basketorder:
                  (widget.arguments["basketData"]["fromBasket"] ?? false)));
        } else {
          orderPadBloc!.add(OrderPadPlaceOrderEvent(
            orderpadUiBloc.getOrderPayloadData(),
            orderpadUiBloc.isGTD(),
          ));
        }
      }
    } else {
      orderpadUiBloc.orderpadupdate.isPlaceOrderSelected.value = false;
    }
  }

  bool isHoldingsAvailableInSymbol(
    Symbols symbolItem,
    List<Symbols>? holdingsList,
  ) {
    bool isHoldingsAvailableInSymbol = false;
    int index = 0;
    if (holdingsList != null) {
      for (Symbols element in holdingsList) {
        if (element.dispSym == symbolItem.dispSym &&
            element.sym!.exc == symbolItem.sym!.exc) {
          isHoldingsAvailableInSymbol = true;
          orderpadUiBloc.orderpadupdate.holdingsIndex = index;
        }
        index++;
      }
    }
    return isHoldingsAvailableInSymbol;
  }

  //Order status

  //calender functions

  Future<void> _displayDatePickerWidget(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    try {
      initialDate = DateFormat(AppConstants.dateFormatConstantDDMMYYYY).parse(
        orderpadUiBloc.orderpadupdate.validityDateController.text,
      );
    } catch (e) {
      initialDate = DateTime.now();
    }
    DateTime.now(); //.add(const Duration(days: 20));
    DateTime lastDate = DateTime.now().add(const Duration(days: 45));
    final DateTime? selectedDateOfBirth = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: lastDate,
      helpText: "",
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: MaterialColor(AppColors().positiveColor.value,
                  AppColors.calendarPrimaryColorSwatch),
            ),
            textTheme: TextTheme(
              labelSmall: TextStyle(fontSize: AppWidgetSize.fontSize16),
            ),
          ),
          child: child!,
        );
      },
    );
    if (orderpadUiBloc.orderpadupdate.currentSymbol.sym?.expiry?.isNotEmpty ??
        false) {
      logError(
          "Dat",
          DateFormat("dd-MM-yyyy")
              .parse(
                  orderpadUiBloc.orderpadupdate.currentSymbol.sym?.expiry ?? "")
              .compareTo(selectedDateOfBirth!));
      if (DateFormat("dd-MM-yyyy")
              .parse(
                  orderpadUiBloc.orderpadupdate.currentSymbol.sym?.expiry ?? "")
              .compareTo(selectedDateOfBirth) <
          0) {
        showNotification(
          message:
              "Validity Date should be less than or Equal to ${orderpadUiBloc.orderpadupdate.currentSymbol.sym?.expiry}",
        );
        return;
      }
    }
    if (selectedDateOfBirth != null) {
      orderpadUiBloc.orderpadupdate.validityDateController.text =
          orderpadUiBloc.getdatevalue(
        selectedDateOfBirth,
        AppConstants.dateFormatConstantDDMMYYYY,
      );
      if (orderpadUiBloc
          .orderpadupdate.validityDateController.text.isNotEmpty) {
        showNotification(
          message:
              "This order will expire on ${orderpadUiBloc.orderpadupdate.validityDateController.text}",
        );
      }
      setState(() {});
    }
  }
}
