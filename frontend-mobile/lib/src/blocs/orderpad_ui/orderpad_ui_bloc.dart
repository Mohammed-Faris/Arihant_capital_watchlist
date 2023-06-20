import 'dart:async';

import 'package:acml/src/ui/screens/acml_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../constants/app_constants.dart';
import '../../data/store/app_utils.dart';
import '../../localization/app_localization.dart';
import '../../models/common/symbols_model.dart';
import '../../models/order_pad/order_pad_ui_model.dart';
import '../../models/orders/order_book.dart';
import '../../ui/screens/base/base_screen.dart';

part 'orderpad_ui_event.dart';
part 'orderpad_ui_state.dart';

class OrderpadUiBloc extends Bloc<OrderpadUiEvent, OrderpadUiState> {
  final OrderpadUiUpdate orderpadupdate = OrderpadUiUpdate();

  OrderpadUiBloc() : super(OrderpadInitial()) {
    on<OrderpadUiinit>(initEvent);
    on<OrdertypeChange>(orderTypeToggleChanged);
    on<ValidityChange>(validityToggleChanged);
    on<UpdateUi>(updateUiValues);
    on<CheckMariginEvent>(checkMariginEvent);
    on<GetCoTriggerPrice>(getCoTriggerPrice);
    on<ExchangeChange>(exchangeCheckboxChecked);
    on<OtherExchange>(otherExchangeEvent);
    on<PrdChange>(onPrdChange);
  }

  Future<FutureOr<void>> initEvent(OrderpadUiinit event, emit) async {
    orderpadupdate.arguments = event.arguments;
    orderpadupdate.symbols = event.arguments['symbolItem'];
    orderpadupdate.currentSymbol = orderpadupdate.symbols;
    if (isModifyOrder() || isRepeatOrder()) {
      orderpadupdate.orders = orderpadupdate.arguments['orders'];
    }
    orderpadupdate.basketId =
        orderpadupdate.arguments["basketData"]?["basketId"];
    orderpadupdate.basketorderId =
        orderpadupdate.arguments["basketData"]?["basketOrderId"];

    orderpadupdate.exchangeList!.add(orderpadupdate.symbols.sym!.exc!);
    orderpadupdate.selectedAction = orderpadupdate.arguments['action'];
    orderpadupdate.lcl = AppUtils().dataNullCheck(orderpadupdate.symbols.lcl);
    orderpadupdate.ucl = AppUtils().dataNullCheck(orderpadupdate.symbols.ucl);
    orderpadupdate.ltp = AppUtils().dataNullCheck(orderpadupdate.symbols.ltp);
    if (orderpadupdate.symbols.sym!.otherExch != null) {
      //set exchange list - only two exchanges are possible
      //(if more than 2 exchange is there then code needs to be changed.)
      orderpadupdate.exchangeList!
          .addAll(List.from(orderpadupdate.symbols.sym!.otherExch!));
    }
    emit(CallOtherExchange());
    orderpadupdate.isAmoEnabled.value =
        AppUtils().getAmoStatus(orderpadupdate.symbols.sym!.exc!);

    orderpadupdate.productList = getProductTypeList();

    orderpadupdate.quantityController.text = setInitialQtyField();

    if (isModifyOrder() || isRepeatOrder()) {
      orderpadupdate.selectedValidity = isGTD()
          ? AppConstants.gtd
          : orderpadupdate.orders.ordDuration?.toUpperCase() ??
              AppConstants.day;
      if (isGTD()) {
        orderpadupdate.validityDateController.text =
            (orderpadupdate.basketorderId?.isNotEmpty ?? false)
                ? orderpadupdate.orders.gtdOrdDate ?? ""
                : (isModifyOrder() || isRepeatOrder())
                    ? (orderpadupdate.orders.ordValidDte ?? "")
                    : AppLocalizations().chooseDate;
      }
    }
    orderpadupdate.selectedOrderType = (isModifyOrder() || isRepeatOrder())
        ? getOrderTypeFromOrder(orderpadupdate.orders.ordType ?? "")
        : isPositonExitOrAdd() &&
                getProductTypeFromOrders(
                        orderpadupdate.arguments[AppConstants.positionsPrdType],
                        orderpadupdate.selectedValidity,
                        orderpadupdate.orders.isGtd) ==
                    AppLocalizations()
                        .bracketOrder
                        .toString()
                        .replaceAll(' ', '')
            ? AppConstants.limit
            : orderpadupdate.selectedOrderType;
    await updateUiValues(
      UpdateUi(
          (isModifyOrder() ||
                  isRepeatOrder() ||
                  (orderpadupdate.basketorderId?.isNotEmpty ?? false))
              ? (orderpadupdate.orders.comments == AppConstants.gtd &&
                      orderpadupdate.orders.ordValidDte != null)
                  ? getProductTypeFromOrders(AppConstants.gtd, AppConstants.gtd,
                      orderpadupdate.orders.isGtd)
                  : getProductTypeFromOrders(
                      orderpadupdate.orders.prdType ??
                          AppLocalizations().regular,
                      orderpadupdate.selectedValidity,
                      orderpadupdate.orders.isGtd)
              : isPositonExitOrAdd()
                  ? getProductTypeFromOrders(
                      orderpadupdate.arguments[AppConstants.positionsPrdType],
                      orderpadupdate.selectedValidity,
                      orderpadupdate.orders.isGtd)
                  : getProductTypeString(),
          (isModifyOrder() || isRepeatOrder())
              ? getOrderTypeFromOrder(orderpadupdate.orders.ordType ?? "")
              : orderpadupdate.selectedOrderType,
          initCallOrder: isModifyOrder() || isRepeatOrder()),
      emit,
    );
    if (isModifyOrder() || isRepeatOrder()) {
      prefillSymbolDetails();
      checkMariginEvent(CheckMariginEvent(), emit);
    }
    if ((event.arguments['customPrice']?.isNotEmpty ?? false)) {
      await customPriceOnChange(customPrice: event.arguments['customPrice']);
    }

    emit(orderpadupdate);
  }

  String setInitialQtyField() {
    return (isModifyOrder() || isRepeatOrder())
        ? setOrderQty()
        : isPositonExitOrAdd() &&
                orderpadupdate.arguments[AppConstants.isOpenPosition] &&
                orderpadupdate.arguments["positionButtonHeader"] == "Exit"
            ? orderpadupdate.arguments[AppConstants.positionExitOrAdd]
                .toString()
                .removeMultiplierPositionModify(
                  orderpadupdate.currentSymbol.sym,
                )
                .exdoubleTrialZero()
                .abs()
                .toString()
            : orderpadupdate.arguments[AppConstants.holdingsNavigation] != null
                ? orderpadupdate.arguments[AppConstants.holdingsNavigation]
                    .toString()
                    .exdoubleTrialZero()
                    .abs()
                    .toString()
                : setInitialQty();
  }

  String setInitialQty() {
    return (orderpadupdate.currentSymbol.sym!.lotSize!.exdoubleTrialZero() *
                orderpadupdate.currentSymbol.sym!.multiplier!
                    .exdoubleTrialZero()) >
            1
        ? "1"
            .withMultiplierOrderPad(orderpadupdate.currentSymbol.sym)
            .exInt()
            .toString()
        : !isExcNseOrBse()
            ? "1"
            : '';
  }

  String setOrderQty() {
    return (orderpadupdate.orders.qty.dataNullCheck().exdoubleTrialZero() > 0 &&
                orderpadupdate.orders.qty.dataNullCheck().exdoubleTrialZero() !=
                    orderpadupdate.orders.tradedQty
                        .dataNullCheck()
                        .exdoubleTrialZero()
            ? (orderpadupdate.orders.qty.dataNullCheck().exdoubleTrialZero() -
                    orderpadupdate.orders.tradedQty
                        .dataNullCheck()
                        .exdoubleTrialZero())
                .toString()
            : orderpadupdate.orders.qty!)
        .withMultiplierOrderV2(orderpadupdate.orders.sym);
  }

  customPriceOnChange({String? customPrice, BuildContext? context}) async {
    clearAllFocus();
    orderpadupdate.isCustomPriceEnabled =
        customPrice != null ? true : !orderpadupdate.isCustomPriceEnabled;

    orderpadupdate.priceController.text =
        AppUtils().removeCommaFmt(customPrice ?? orderpadupdate.ltp);
    if (orderpadupdate.isCustomPriceEnabled) {
      BlocProvider.of<OrderpadUiBloc>(context ?? navigatorKey.currentContext!)
          .add(OrdertypeChange(
              orderpadupdate.selectedOrderType == AppConstants.slM ||
                      orderpadupdate.selectedOrderType == AppConstants.sl
                  ? AppConstants.sl
                  : AppConstants.limit));

      BlocProvider.of<OrderpadUiBloc>(context ?? navigatorKey.currentContext!)
          .add(UpdateUi(
              getProductTypeString(),
              orderpadupdate.selectedOrderType == AppConstants.slM ||
                      orderpadupdate.selectedOrderType == AppConstants.sl
                  ? AppConstants.sl
                  : AppConstants.limit));
    } else {
      BlocProvider.of<OrderpadUiBloc>(context ?? navigatorKey.currentContext!)
          .add(UpdateUi(
              getProductTypeString(),
              orderpadupdate.selectedOrderType == AppConstants.sl
                  ? AppConstants.slM
                  : AppConstants.market));
    }
  }

  FutureOr<void> validityToggleChanged(event, emit) async {
    orderpadupdate.selectedValidity = event.selectedValidity;
    if (event.selectedValidity == AppConstants.gtd) {
      orderpadupdate.isCustomPriceEnabled = true;
      orderpadupdate.disableCustomPriceCheckbox = true;
      orderpadupdate.isShowAmoWidget = true;
      orderpadupdate.isAmoEnabled.value = false;
      orderpadupdate.selectedOrderType =
          orderpadupdate.selectedOrderType == AppConstants.slM
              ? AppConstants.sl
              : orderpadupdate.selectedOrderType == AppConstants.market
                  ? AppConstants.limit
                  : orderpadupdate.selectedOrderType;
    }
    await updateUiValues(
        UpdateUi(
            getProductTypeString(),
            orderpadupdate.isCustomPriceEnabled
                ? orderpadupdate.selectedOrderType
                : orderpadupdate.selectedOrderType == AppConstants.sl
                    ? AppConstants.slM
                    : AppConstants.market),
        emit);
    emit(OrderpadChange());

    emit(orderpadupdate);
  }

  String getProductTypeFromOrders(
      String prdType, String orderValidity, bool isGtd) {
    if (orderValidity.toLowerCase() == AppConstants.gtd.toLowerCase() ||
        isGtd) {
      orderpadupdate.selectedProductTypeIndex =
          orderpadupdate.productList.indexOf(AppConstants.gtd);
      return AppConstants.gtd;
    } else if (prdType.toLowerCase() == AppConstants.delivery.toLowerCase() ||
        prdType.toLowerCase() == AppConstants.carryForward.toLowerCase()) {
      orderpadupdate.selectedProductTypeIndex =
          orderpadupdate.productList.indexOf(AppLocalizations().regular);
      orderpadupdate.selectedRegularProductTypeIndex = 0;
      return AppLocalizations().invest;
    } else if (prdType.toLowerCase() == AppConstants.intraday.toLowerCase()) {
      orderpadupdate.selectedProductTypeIndex =
          orderpadupdate.productList.indexOf(AppLocalizations().regular);
      orderpadupdate.selectedRegularProductTypeIndex = 1;
      return AppLocalizations().trade;
    } else if (prdType.toLowerCase() == AppConstants.coverOrder.toLowerCase()) {
      orderpadupdate.selectedProductTypeIndex =
          orderpadupdate.productList.indexOf(AppLocalizations().cover);
      return AppLocalizations().cover.toString().replaceAll(' ', '');
    } else {
      orderpadupdate.selectedProductTypeIndex =
          orderpadupdate.productList.indexOf(AppLocalizations().bracket);
      return AppLocalizations().bracket.toString().replaceAll(' ', '');
    }
  }

  String getOrderTypeFromOrder(
    String ordType,
  ) {
    if (isRepeatOrder() && isCoverOrder() && ordType == AppConstants.slM) {
      return AppConstants.market;
    } else if (ordType.toLowerCase() == AppConstants.market.toLowerCase()) {
      return AppConstants.market;
    } else if (ordType.toLowerCase() == AppConstants.limit.toLowerCase()) {
      return AppConstants.limit;
    } else if (ordType.toLowerCase() == AppConstants.sl.toLowerCase()) {
      return AppConstants.sl;
    } else {
      return AppConstants.slM;
    }
  }

  void prefillSymbolDetails() {
    orderpadupdate.selectedOrderType = getOrderTypeFromOrder(
      orderpadupdate.selectedOrderType,
    );
    if (orderpadupdate.basketorderId?.isNotEmpty ?? false) {
      orderpadupdate.stopLossController.text =
          orderpadupdate.orders.boStpLoss ?? "";
      orderpadupdate.targetPriceController.text =
          orderpadupdate.orders.boTgtPrice ?? "";
      orderpadupdate.trailingStopLossController.text =
          orderpadupdate.orders.trailingSL ?? "";
    }
    orderpadupdate.isCustomPriceEnabled =
        (orderpadupdate.selectedOrderType == AppConstants.limit ||
            orderpadupdate.selectedOrderType == AppConstants.sl);
    orderpadupdate.priceController.text = isCoverModifyOrder() ||
            isBracketModifyChildOrder()
        ? isMainOrderType()
            ? AppUtils().removeCommaFmt(orderpadupdate.orders.limitPrice!)
            : AppUtils().removeCommaFmt(orderpadupdate.orders.mainLegPrice!)
        : orderpadupdate.selectedOrderType == AppConstants.market ||
                orderpadupdate.selectedOrderType == AppConstants.slM
            ? AppLocalizations().atMarket
            : orderpadupdate.priceController.text =
                AppUtils().removeCommaFmt(orderpadupdate.orders.limitPrice!);
    orderpadupdate.isTriggerPriceEnabled = isCoverOrder()
        ? false
        : ((isRegularOrder() &&
                orderpadupdate.selectedOrderType == AppConstants.sl) ||
            (isRegularOrder() &&
                orderpadupdate.selectedOrderType == AppConstants.slM) ||
            (isGTD() && orderpadupdate.selectedOrderType == AppConstants.sl) ||
            (isBracketOrder() &&
                ((isMainOrderType() &&
                        orderpadupdate.selectedOrderType == AppConstants.sl) ||
                    (orderpadupdate.selectedOrderType == AppConstants.sl &&
                        (orderpadupdate.basketorderId?.isNotEmpty ?? false)))));
    if (isBracketOrder() && isChildOrderSecondType()) {
      orderpadupdate.targetPriceController.text =
          AppUtils().removeCommaFmt(orderpadupdate.orders.limitPrice!);
    } else if (isBracketOrder() && isChildOrderThirdType()) {
      orderpadupdate.trailingStopLossController.text =
          AppUtils().removeCommaFmt(orderpadupdate.orders.limitPrice!);
      orderpadupdate.stopLossController.text =
          AppUtils().removeCommaFmt(orderpadupdate.orders.triggerPrice!);
    } else if (isCoverOrder()) {
      orderpadupdate.stopLossTriggerController.text =
          AppUtils().removeCommaFmt(orderpadupdate.orders.triggerPrice!);
    }
    if (orderpadupdate.isTriggerPriceEnabled) {
      orderpadupdate.triggerPriceController.text =
          AppUtils().removeCommaFmt(orderpadupdate.orders.triggerPrice!);
    }

    orderpadupdate.disableCustomPriceCheckbox =
        (((isModifyOrderCoverOrder()) && !isMainOrderType()) &&
                !isRepeatOrder()) ||
            isBracketOrder() ||
            isGTD();

    if (orderpadupdate.orders.disQty != '0') {
      orderpadupdate.disclosedQtyController.text = orderpadupdate.orders.disQty
          .withMultiplierOrderV2(orderpadupdate.orders.sym);
    }

    orderpadupdate.selectedValidity =
        isGTD() ? AppConstants.gtd : orderpadupdate.orders.ordDuration!;

    orderpadupdate.isAmoEnabled.value =
        isModifyOrder() || orderpadupdate.basketorderId != null
            ? (orderpadupdate.orders.isAmo ?? false)
            : AppUtils().getAmoStatus(orderpadupdate.currentSymbol.sym!.exc!);
  }

  void clearAllFocus() {
    orderpadupdate.qtyFocusNode.unfocus();
    orderpadupdate.priceFocusNode.unfocus();
    orderpadupdate.triggerPriceFocusNode.unfocus();
    orderpadupdate.stopLossFocusNode.unfocus();
    orderpadupdate.stopLossTriggerFocusNode.unfocus();
    orderpadupdate.disclosedQtyFocusNode.unfocus();
    orderpadupdate.targetPriceFocusNode.unfocus();
    orderpadupdate.trailingStopLossFocusNode.unfocus();
    orderpadupdate.validityFocusNode.unfocus();
  }

  bool isQtyGreaterThanZero() {
    return orderpadupdate.quantityController.text.exdoubleTrialZero() > 0;
  }

  bool isQtyGreaterThanOrderedQty() {
    return (isModifyOrder() &&
            (orderpadupdate.orders.qty.toString().exdoubleTrialZero() >=
                (AppUtils()
                    .intValue(orderpadupdate.quantityController.text)))) ||
        (isPositonExitOrAdd() &&
            isShortSellPosition() &&
            isBuyActionSelected() &&
            (AppUtils()
                    .intValue(orderpadupdate
                        .arguments[AppConstants.positionExitOrAdd])
                    .abs() >=
                (AppUtils()
                    .intValue(orderpadupdate.quantityController.text)))) ||
        (isPositonExitOrAdd() &&
            !isShortSellPosition() &&
            !isBuyActionSelected() &&
            (orderpadupdate.arguments[AppConstants.positionExitOrAdd]
                    .toString()
                    .exdoubleTrialZero() >=
                (orderpadupdate.quantityController.text.exdoubleTrialZero())));
  }

  bool isBuyActionSelected() {
    return orderpadupdate.selectedAction == AppLocalizations().buy;
  }

  Future<FutureOr<void>> updateUiValues(UpdateUi event, emit) async {
    orderpadupdate.decimalPoint = AppUtils().getDecimalpoint(orderpadupdate
        .exchangeList!
        .elementAt(orderpadupdate.selectedExchangeIndex));
    orderpadupdate.orderTypeList = getOrderTypeList(event.selectedProductType);
    orderpadupdate.validityList = getValidityList(
      event.selectedProductType,
      event.orderType,
    );

    if (!event.initCallOrder) {
      orderpadupdate.selectedOrderType = event.orderType;
      orderpadupdate.disableCustomPriceCheckbox = (isBracketOrder() || isGTD());
      orderpadupdate.isCustomPriceEnabled = getCustomPriceEnabled(
          event.selectedProductType, orderpadupdate.selectedOrderType);
      orderpadupdate.isTriggerPriceEnabled = getTriggerPrice(
          event.selectedProductType, orderpadupdate.selectedOrderType);

      orderpadupdate.priceController.text = !orderpadupdate.isCustomPriceEnabled
          ? AppLocalizations().atMarket
          : orderpadupdate.priceController.text != AppLocalizations().atMarket
              ? orderpadupdate.priceController.text
              : AppUtils().removeCommaFmt(orderpadupdate.ltp);
    }
    orderpadupdate.isShowAmoWidget = showOrHideAmo(
        event.selectedProductType, orderpadupdate.selectedOrderType);
    orderpadupdate.isShowDiscloseQty = showOrHideDisclosedQty(
        event.selectedProductType, orderpadupdate.selectedOrderType);
    if (event.isReset) {
      orderpadupdate.isCustomPriceEnabled = false;
      orderpadupdate.isTriggerPriceEnabled = false;
      orderpadupdate.selectedOrderType = '';
      orderpadupdate.selectedValidity = AppConstants.day;
    }
    if (!event.initCallOrder) checkMariginEvent(CheckMariginEvent(), emit);
    if (getProductTypeStringForPlaceOrder() == AppConstants.coverOrder) {
      getCoTriggerPrice(GetCoTriggerPrice(), emit);
    }
    if (!isExcNseOrBseandDelivery()) {
      orderpadupdate.isQuantity.value = true;
    }

    emit(OrderpadChange());
    emit(orderpadupdate);
  }

  Future<FutureOr<void>> onPrdChange(PrdChange event, emit) async {
    orderpadupdate.selectedProductTypeIndex = event.index;
    orderpadupdate.selectedValidity =
        getProductTypeStringForPlaceOrder() == AppConstants.gtd
            ? AppConstants.gtd
            : orderpadupdate.selectedValidity;

    orderpadupdate.isQuantityTextFieldInFocus = false;

    clearAllFocus();
    await updateUiValues(
        UpdateUi(
          getProductTypeString(),
          getProductTypeStringForPlaceOrder() == AppConstants.bracketOrder
              ? AppConstants.limit
              : getProductTypeStringForPlaceOrder() == AppConstants.gtd
                  ? AppConstants.limit
                  : AppConstants.market,
        ),
        emit);

    emit(OrderpadChange());

    emit(orderpadupdate);
  }

  bool isNseBseExcSellDeliveryOrder(String action) {
    return action == AppLocalizations().sell &&
            isExcNseOrBse() &&
            getProductTypeStringForPlaceOrder().toLowerCase() ==
                AppConstants.delivery.toLowerCase() ||
        getProductTypeStringForPlaceOrder().toLowerCase() ==
            AppConstants.gtd.toLowerCase();
  }

  bool isMcxcdsExcSellDeliveryOrder(String action) {
    return action == AppLocalizations().sell &&
        isExcCdsOrMcx() &&
        getProductTypeStringForPlaceOrder().toLowerCase() ==
            AppConstants.normal.toLowerCase();
  }

  String getProductTypeStringForPlaceOrder() {
    String prdType = orderpadupdate.productList
                .elementAt(orderpadupdate.selectedProductTypeIndex) ==
            AppLocalizations().cover
        ? AppConstants.coverOrder
        : orderpadupdate.productList
                    .elementAt(orderpadupdate.selectedProductTypeIndex) ==
                AppConstants.gtd
            ? AppConstants.gtd
            : orderpadupdate.productList
                        .elementAt(orderpadupdate.selectedProductTypeIndex) ==
                    AppLocalizations().bracket
                ? AppConstants.bracketOrder
                : orderpadupdate.selectedRegularProductTypeIndex == 0
                    ? isExcNseOrBse()
                        ? AppConstants.delivery.toUpperCase()
                        : AppConstants.normal.toUpperCase()
                    : AppConstants.intraday.toUpperCase();

    return prdType;
  }

  bool isRegularOrder() {
    return getProductTypeFromIndex(orderpadupdate.selectedProductTypeIndex) ==
        AppLocalizations().regular;
  }

  bool isCoverOrder() {
    return getProductTypeFromIndex(orderpadupdate.selectedProductTypeIndex) ==
        AppLocalizations().cover;
  }

  bool isCoverModifyOrder() {
    return isCoverOrder() && isModifyOrder();
  }

  bool isBrackeModifySecondOrder() {
    return isBracketOrder() && isChildOrderSecondType();
  }

  bool isBracketModifyChildOrder() {
    return isBracketOrder() &&
        (isChildOrderSecondType() || isChildOrderThirdType());
  }

  bool isBrackeModifyThirdOrder() {
    return isBracketOrder() && isChildOrderThirdType();
  }

  String getProductTypeFromIndex(int selectedIndex) {
    return orderpadupdate.productList.elementAt(selectedIndex);
  }

  bool isGTD() {
    return orderpadupdate
                .productList[orderpadupdate.selectedProductTypeIndex] ==
            AppConstants.gtd ||
        (orderpadupdate.orders.ordDuration?.toLowerCase() ==
            AppConstants.gtd.toLowerCase());
  }

  String getCheckMarginQty() {
    String qty = '0';
    if (isModifyOrder() &&
        orderpadupdate.orders.qty.dataNullCheck().exdoubleTrialZero() <
            (orderpadupdate.quantityController.text.exdoubleTrialZero())) {
      qty = (orderpadupdate.quantityController.text.exdoubleTrialZero() -
              orderpadupdate.orders.qty.dataNullCheck().exdoubleTrialZero())
          .toString()
          .removeMultiplierOrderPad(orderpadupdate.currentSymbol.sym);
    } else if (isPositonExitOrAdd() &&
        orderpadupdate.arguments[AppConstants.positionButtonHeader] !=
            AppLocalizations().add &&
        AppUtils()
                .intValue(
                    orderpadupdate.arguments[AppConstants.positionExitOrAdd])
                .abs() <
            (orderpadupdate.quantityController.text.exdoubleTrialZero())) {
      qty = (orderpadupdate.quantityController.text.exdoubleTrialZero() -
              orderpadupdate.arguments[AppConstants.positionExitOrAdd]
                  .toString()
                  .exdoubleTrialZero()
                  .abs())
          .toString()
          .removeMultiplierOrderPad(orderpadupdate.currentSymbol.sym);
    } else {
      qty = orderpadupdate.quantityController.text == ''
          ? '0'
          : orderpadupdate.quantityController.text
              .removeMultiplierOrderPad(orderpadupdate.currentSymbol.sym);
    }

    return qty;
  }

  void dispose() {
    orderpadupdate.qtyFocusNode.dispose();
    orderpadupdate.priceFocusNode.dispose();
    orderpadupdate.triggerPriceFocusNode.dispose();
    orderpadupdate.stopLossTriggerFocusNode.dispose();
    orderpadupdate.stopLossFocusNode.dispose();
    orderpadupdate.targetPriceFocusNode.dispose();
    orderpadupdate.trailingStopLossFocusNode.dispose();
    orderpadupdate.disclosedQtyFocusNode.dispose();
    orderpadupdate.validityFocusNode.dispose();
  }

  bool isBracketOrder() {
    return getProductTypeFromIndex(orderpadupdate.selectedProductTypeIndex) ==
        AppLocalizations().bracket;
  }

  bool isBracketOrderorModifyMainLeg() {
    return (isBracketOrder() && !isModifyOrder()) ||
        (isBracketOrder() && isModifyOrder() && isMainOrderType());
  }

  bool isShortSellPosition() {
    return AppUtils()
        .intValue(orderpadupdate.arguments[AppConstants.positionExitOrAdd])
        .isNegative;
  }

  isMainOrderType() {
    return orderpadupdate.orders.childType == AppConstants.main;
  }

  isChildOrderSecondType() {
    return isModifyOrder() &&
        !isMainOrderType() &&
        ((Featureflag.boSecondLegType != null &&
                orderpadupdate.orders.prdType == AppConstants.bracketOrder)
            ? orderpadupdate.orders.ordType?.toLowerCase() ==
                Featureflag.boSecondLegType?.toLowerCase()
            : orderpadupdate.orders.childType == AppConstants.second);
  }

  isChildOrderThirdType() {
    return (isModifyOrder() &&
            !isMainOrderType() &&
            (Featureflag.boSecondLegType != null &&
                orderpadupdate.orders.prdType == AppConstants.bracketOrder)
        ? (orderpadupdate.orders.ordType?.toLowerCase() !=
            Featureflag.boSecondLegType?.toLowerCase())
        : orderpadupdate.orders.childType == AppConstants.third);
  }

  bool isExcNseOrBse() {
    return orderpadupdate.exchangeList!
                .elementAt(orderpadupdate.selectedExchangeIndex) ==
            AppConstants.nse ||
        orderpadupdate.exchangeList!
                .elementAt(orderpadupdate.selectedExchangeIndex) ==
            AppConstants.bse;
  }

  bool isExcNseOrBseandDelivery() {
    return (orderpadupdate.exchangeList!
                    .elementAt(orderpadupdate.selectedExchangeIndex) ==
                AppConstants.nse ||
            orderpadupdate.exchangeList!
                    .elementAt(orderpadupdate.selectedExchangeIndex) ==
                AppConstants.bse) &&
        getProductTypeStringForPlaceOrder() ==
            AppConstants.delivery.toUpperCase();
  }
  //Functions to get data from OrderPadUIModel

  List<String> getProductTypeList() {
    //set product types from json
    List<String> productList = (orderpadupdate.orderPadUIModel
            .getKeyValue(orderpadupdate.exchangeList!
                .elementAt(orderpadupdate.selectedExchangeIndex))!
            .productTypes
            ?.where((element) => isModifyOrder()
                ? (element.toUpperCase() == AppConstants.gtd
                    ? orderpadupdate.orders.ordDuration?.toUpperCase() ==
                        AppConstants.gtd.toUpperCase()
                    : element.toUpperCase() ==
                            AppLocalizations().bracket.toUpperCase()
                        ? orderpadupdate.orders.prdType!.toUpperCase() ==
                            AppConstants.bracketOrder.toUpperCase()
                        : element.toUpperCase() ==
                                AppLocalizations().cover.toUpperCase()
                            ? orderpadupdate.orders.prdType!.toUpperCase() ==
                                AppConstants.coverOrder.toUpperCase()
                            : element.toUpperCase() ==
                                    AppLocalizations().regular.toUpperCase()
                                ? ((orderpadupdate.orders.prdType!
                                                .toUpperCase() ==
                                            AppConstants.delivery
                                                .toUpperCase() ||
                                        orderpadupdate.orders.prdType!
                                                .toUpperCase() ==
                                            AppConstants.carryForward
                                                .toUpperCase() ||
                                        orderpadupdate.orders.prdType!
                                                .toUpperCase() ==
                                            AppConstants.normal
                                                .toUpperCase()) &&
                                    orderpadupdate.orders.comments
                                            ?.toUpperCase() !=
                                        AppConstants.gtd.toUpperCase())
                                : element.toUpperCase() ==
                                    orderpadupdate.orders.prdType!
                                        .toUpperCase())
                : true)
            .toList()) ??
        [];
    return productList.isEmpty ? [AppLocalizations().regular] : productList;
  }

  String getdatevalue(DateTime date, String formateString) {
    final dynamic now = date;
    final dynamic formatter = DateFormat(formateString);
    return formatter.format(now);
  }

  List<String> getOrderTypeList(
    String selectedProductType,
  ) {
    List<String> orderTypeList = orderpadupdate.orderPadUIModel
            .getKeyValue(orderpadupdate.exchangeList!
                .elementAt(orderpadupdate.selectedExchangeIndex))!
            .getKeyValue(selectedProductType)!
            .orderTypes
            ?.toList() ??
        [];
    if (selectedProductType == AppLocalizations().invest ||
        selectedProductType == AppLocalizations().trade) {
      orderTypeList.removeWhere((element) =>
          element == AppConstants.market || element == AppConstants.limit);
      return orderTypeList;
    }

    return orderTypeList;
  }

  List<String> getValidityList(
    String selectedProductType,
    String orderType,
  ) {
    List<String> validity =
        getProductJson(selectedProductType, orderType)?.validity ?? [];

    return validity;
  }

  OrderType? getProductJson(String? selectedProductType, String? orderType) {
    return orderpadupdate.orderPadUIModel
        .getKeyValue(orderpadupdate.exchangeList
                ?.elementAt(orderpadupdate.selectedExchangeIndex) ??
            "")
        ?.getKeyValue(selectedProductType ?? "")
        ?.getKeyValue(orderType ?? "");
  }

  bool showOrHideDisclosedQty(
    String selectedProductType,
    String orderType,
  ) {
    return getProductJson(selectedProductType, orderType)?.disQty ?? false;
  }

  bool showOrHideAmo(
    String selectedProductType,
    String orderType,
  ) {
    return (isBracketOrder() || isCoverOrder())
        ? false
        : getProductJson(selectedProductType, orderType)?.amo ?? false;
  }

  bool getTriggerPrice(
    String selectedProductType,
    String orderType,
  ) {
    return getProductJson(selectedProductType, orderType)?.triggerPrice ??
        false;
  }

  bool getCustomPriceEnabled(
    String selectedProductType,
    String orderType,
  ) {
    return getProductJson(selectedProductType, orderType)?.customPrice ?? false;
  }

  bool isSelectedValidityAvailableInValidityList(
    String selectedProductType,
    String orderType,
  ) {
    return getValidityList(selectedProductType, orderType).contains(
      orderpadupdate.selectedValidity,
    );
  }

  bool isPositonExitOrAdd() {
    return (orderpadupdate.arguments[AppConstants.positionExitOrAdd] != null);
  }

  bool isPositionAdd() {
    return (isPositonExitOrAdd() &&
            (isBuyActionSelected() &&
                !isShortSellPosition()) /*long position */ ||
        (!isBuyActionSelected() && isShortSellPosition()));
  }

  bool isModifyOrder() {
    return (orderpadupdate.arguments[AppConstants.orderbookSelectedOrder] ==
            AppConstants.orderbookModifyOrder) &&
        orderpadupdate.basketorderId == null;
  }

  bool isRepeatOrder() {
    return (orderpadupdate.arguments[AppConstants.orderbookSelectedOrder] ==
            AppConstants.orderbookRepeatOrder) ||
        (orderpadupdate.basketorderId?.isNotEmpty ?? false);
  }

  isModifyOrderCoverOrder() {
    return !isRepeatOrder() &&
        orderpadupdate.basketorderId == null &&
        orderpadupdate.orders.prdType != null &&
        orderpadupdate.orders.prdType!.toLowerCase() ==
            AppConstants.coverOrder.toLowerCase();
  }

  isModifyOrderBracketOrder() {
    return orderpadupdate.orders.prdType != null &&
        orderpadupdate.orders.prdType!.toLowerCase() ==
            AppConstants.bracketOrder.toLowerCase();
  }

  bool isExcCdsOrMcx() {
    return orderpadupdate.exchangeList!
                .elementAt(orderpadupdate.selectedExchangeIndex) ==
            AppConstants.cds ||
        orderpadupdate.exchangeList!
                .elementAt(orderpadupdate.selectedExchangeIndex) ==
            AppConstants.mcx;
  }

  bool isExcCds() {
    return orderpadupdate.exchangeList!
            .elementAt(orderpadupdate.selectedExchangeIndex) ==
        AppConstants.cds;
  }

  bool isMcx() {
    return orderpadupdate.exchangeList!
            .elementAt(orderpadupdate.selectedExchangeIndex) ==
        AppConstants.mcx;
  }

  Future<FutureOr<void>> orderTypeToggleChanged(
      OrdertypeChange event, emit) async {
    orderpadupdate.selectedOrderType = event.currentSelectedOrderType;

    orderpadupdate.isCustomPriceEnabled = getCustomPriceEnabled(
        getProductTypeString(), orderpadupdate.selectedOrderType);
    orderpadupdate.isTriggerPriceEnabled = getTriggerPrice(
        getProductTypeString(), orderpadupdate.selectedOrderType);
    await updateUiValues(
        UpdateUi(getProductTypeString(), orderpadupdate.selectedOrderType),
        emit);
    emit(OrderpadChange());

    emit(orderpadupdate);
  }

  String getProductTypeString() {
    return orderpadupdate.productList[orderpadupdate.selectedProductTypeIndex]
                .toUpperCase() ==
            AppLocalizations().regular.toUpperCase()
        ? orderpadupdate.selectedRegularProductTypeIndex == 0
            ? AppLocalizations().invest
            : AppLocalizations().trade
        : orderpadupdate.productList
            .elementAt(orderpadupdate.selectedProductTypeIndex)
            .toString()
            .replaceAll(' ', '');
  }

  Future<FutureOr<void>> exchangeCheckboxChecked(event, emit) async {
    orderpadupdate.selectedExchangeIndex =
        orderpadupdate.selectedExchangeIndex == 0 ? 1 : 0;
    orderpadupdate.ltp = orderpadupdate.symbols.sym!.exc ==
            orderpadupdate.exchangeList!
                .elementAt(orderpadupdate.selectedExchangeIndex)
        ? orderpadupdate.symbols.ltp!
        : orderpadupdate.otherExcSymbol.ltp!;
    orderpadupdate.lcl = orderpadupdate.symbols.sym!.exc ==
            orderpadupdate.exchangeList!
                .elementAt(orderpadupdate.selectedExchangeIndex)
        ? orderpadupdate.symbols.lcl!
        : orderpadupdate.otherExcSymbol.lcl!;
    orderpadupdate.ucl = orderpadupdate.symbols.sym!.exc ==
            orderpadupdate.exchangeList!
                .elementAt(orderpadupdate.selectedExchangeIndex)
        ? orderpadupdate.symbols.ucl!
        : orderpadupdate.otherExcSymbol.ucl!;
    orderpadupdate.currentSymbol = orderpadupdate.symbols.sym!.exc ==
            orderpadupdate.exchangeList!
                .elementAt(orderpadupdate.selectedExchangeIndex)
        ? orderpadupdate.symbols
        : orderpadupdate.otherExcSymbol;
    //   priceController.text = AppUtils().removeCommaFmt(  ltp);
    clearAllFocus();
    await updateUiValues(
        UpdateUi(getProductTypeString(), orderpadupdate.selectedOrderType),
        emit);
    emit(OrderPadGetMarketStatus());
    emit(OrderpadChange());

    emit(orderpadupdate);
  }

  Map<String, dynamic> getCheckMarginPayloadData() {
    final Map<String, dynamic> checkMarginPayloadData = {
      'sym': orderpadupdate.currentSymbol.sym!,
      'prdType': getPrdTypePayloadValue(),
      'ordType': orderpadupdate.selectedOrderType.toUpperCase(),
      'isAmo': !isBracketOrder() && !isCoverOrder()
          ? orderpadupdate.isAmoEnabled.value
          : false,
      //In modify order, if modified qty is greater than actual qty
      //then call checkmargin only for the difference between modified qty and actual qty.
      'qty': getCheckMarginQty(),
      'ordAction': orderpadupdate.selectedAction.toUpperCase(),
      'ordDuration': orderpadupdate.selectedValidity.toUpperCase(),
    };

    checkMarginPayloadData['limitPrice'] =
        orderpadupdate.priceController.text == AppLocalizations().atMarket
            ? orderpadupdate.currentSymbol.ltp
            : getLimitPriceValue();

    checkMarginPayloadData['triggerPrice'] = getTriggerPriceValue();

    if (isBracketOrderorModifyMainLeg()) {
      checkMarginPayloadData['boTgtPrice'] =
          orderpadupdate.targetPriceController.text;
      checkMarginPayloadData['boStpLoss'] =
          orderpadupdate.stopLossController.text;
      checkMarginPayloadData['trailingSL'] =
          orderpadupdate.trailingStopLossController.text;
    }

    return checkMarginPayloadData;
  }

  String? getPrdTypePayloadValue() {
    return (isModifyOrder() &&
            (orderpadupdate.orders.prdType == AppConstants.bracketOrder ||
                orderpadupdate.orders.prdType == AppConstants.coverOrder))
        ? isMainOrderType()
            ? orderpadupdate.orders.prdType
            : AppConstants.intraday.toUpperCase()
        : isGTD()
            ? isExcNseOrBse()
                ? AppConstants.delivery.toUpperCase()
                : AppConstants.normal.toUpperCase()
            : getProductTypeStringForPlaceOrder();
  }

  String getTriggerPriceValue() {
    return (isModifyOrder() && isBracketOrder() && isChildOrderSecondType())
        ? AppUtils().removeCommaFmt(orderpadupdate.targetPriceController.text)
        : (isModifyOrder() && isBracketOrder() && isChildOrderThirdType())
            ? AppUtils().removeCommaFmt(orderpadupdate.stopLossController.text)
            : isCoverOrder()
                ? AppUtils().removeCommaFmt(
                    orderpadupdate.stopLossTriggerController.text)
                : orderpadupdate.selectedOrderType == AppConstants.sl ||
                        orderpadupdate.selectedOrderType == AppConstants.slM
                    ? orderpadupdate.triggerPriceIndex == 1
                        ? AppUtils().decimalValue(((((orderpadupdate
                                        .triggerPriceController.text
                                        .exdoubleTrialZero() +
                                    100) /
                                100) *
                            orderpadupdate.ltp.exdoubleTrialZero())))
                        : AppUtils().removeCommaFmt(
                            orderpadupdate.triggerPriceController.text)
                    : '';
  }

  String getFundsRequired(String availableFunds) {
    //if marketprice is enabled then calculate funds required using ltp
    //or using limit price text
    String fundRequired = isBracketOrder()
        ? AppUtils().decimalValue(
            (orderpadupdate.quantityController.text.exdoubleTrialZero() *
                orderpadupdate.ltp.exdoubleTrialZero()),
            decimalPoint: orderpadupdate.decimalPoint)
        : !orderpadupdate.isCustomPriceEnabled
            ? AppUtils().decimalValue(
                (orderpadupdate.quantityController.text.exdoubleTrialZero() *
                    orderpadupdate.ltp.exdoubleTrialZero()),
                decimalPoint: orderpadupdate.decimalPoint)
            : AppUtils().decimalValue(
                (orderpadupdate.quantityController.text.exdoubleTrialZero() *
                    orderpadupdate.priceController.text.exdoubleTrialZero()),
                decimalPoint: orderpadupdate.decimalPoint);

    return fundRequired;
  }

  bool checkTickSize(String data) {
    final bool checkTickSize = AppUtils().checkTickSize(
      data,
      tickSize: orderpadupdate.currentSymbol.sym!.tickSize!,
      decimalPoint: orderpadupdate.decimalPoint,
    );
    return !checkTickSize;
  }

  bool showValidationAlert(
    String message,
  ) {
    showToast(
      message: message,
      isError: true,
      secondsToShowToast: 8,
    );
    return false;
  }

  bool isvalidForPlaceOrder() {
    AppLocalizations appLocalizations = AppLocalizations();

    //lot issue, Disclosed qty errors
    if (!isExcNseOrBse() &&
        orderpadupdate.quantityController.text.exdoubleTrialZero() %
                "1"
                    .withMultiplierOrderPad(orderpadupdate.currentSymbol.sym)
                    .exdouble() !=
            0) {
      return showValidationAlert(
          '${appLocalizations.lotIssueError} ${"1".withMultiplierOrderPad(orderpadupdate.currentSymbol.sym)}');
    } else if (isExcNseOrBse() &&
        orderpadupdate.currentSymbol.sym!.lotSize
                .dataNullCheck()
                .exdoubleTrialZero() >
            1 &&
        orderpadupdate.quantityController.text.exdoubleTrialZero() %
                "1"
                    .withMultiplierOrderPad(orderpadupdate.currentSymbol.sym)
                    .exdouble() !=
            0) {
      return showValidationAlert(appLocalizations.qtyMultipleError);
    } else if (!orderpadupdate.isAmoEnabled.value &&
        orderpadupdate.disclosedQtyController.text != '' &&
        orderpadupdate.disclosedQtyController.text.exdoubleTrialZero() >
            orderpadupdate.quantityController.text.exdoubleTrialZero()) {
      return showValidationAlert(appLocalizations.disQtyLessThanQtyError);
    } else if (!orderpadupdate.isAmoEnabled.value &&
        orderpadupdate.disclosedQtyController.text != '' &&
        orderpadupdate.disclosedQtyController.text.exInt() != 0 &&
        (orderpadupdate.disclosedQtyController.text.exdoubleTrialZero()) <
            (orderpadupdate.quantityController.text.exdoubleTrialZero() *
                ((AppUtils()
                                .getsymbolType(orderpadupdate.currentSymbol)
                                .toLowerCase() ==
                            AppConstants.commodity.toLowerCase()
                        ? 25
                        : 10) /
                    100))) {
      return showValidationAlert(AppUtils()
                  .getsymbolType(orderpadupdate.currentSymbol)
                  .toLowerCase() ==
              AppConstants.commodity.toLowerCase()
          ? appLocalizations.disQtyMin25Error
          : appLocalizations.disQtyMin10Error);
    } else if (!orderpadupdate.isAmoEnabled.value &&
        orderpadupdate.disclosedQtyController.text != '' &&
        orderpadupdate.disclosedQtyController.text.exdoubleTrialZero() %
                "1"
                    .withMultiplierOrderPad(orderpadupdate.currentSymbol.sym)
                    .exdouble() !=
            0) {
      return showValidationAlert(
          '${appLocalizations.lotIssueErrorDisclose} ${"1".withMultiplierOrderPad(orderpadupdate.currentSymbol.sym)}');
    }
    //Price filed related errors
    if (orderpadupdate.isCustomPriceEnabled &&
            orderpadupdate.selectedOrderType == AppConstants.limit ||
        orderpadupdate.selectedOrderType == AppConstants.sl) {
      if (orderpadupdate.priceController.text == '' ||
          orderpadupdate.priceController.text == '.' ||
          orderpadupdate.priceController.text.exdoubleTrialZero() <= 0) {
        return showValidationAlert(appLocalizations.priceEmptyError);
      } else if (((orderpadupdate.lcl.exdoubleTrialZero() >
              orderpadupdate.priceController.text.exdoubleTrialZero() ||
          (orderpadupdate.priceController.text.exdoubleTrialZero()) >
              orderpadupdate.ucl.exdoubleTrialZero()))) {
        // return showValidationAlert(
        //     '${appLocalizations.priceRangeError} ${orderpadupdate.lcl}- ${orderpadupdate.ucl}');
      } else if (checkTickSize(orderpadupdate.priceController.text)) {
        return showValidationAlert(
            '${appLocalizations.priceTickSizeError} ${orderpadupdate.currentSymbol.sym!.tickSize}');
      }
    }
    //trigger price filed related errors
    String? triggerPriceerror = triggerPriceError();
    if (triggerPriceerror != null) {
      return showValidationAlert(triggerPriceerror);
    } //gtd - validity errors
    if (orderpadupdate.selectedValidity.toUpperCase() ==
        AppConstants.gtd.toUpperCase()) {
      if (orderpadupdate.validityDateController.text == '' ||
          orderpadupdate.validityDateController.text ==
              AppLocalizations().chooseDate) {
        return showValidationAlert(appLocalizations.gtdDateError);
      }
    }
    //CO - stop loss trigger related errors
    if (getProductTypeStringForPlaceOrder() == AppConstants.coverOrder &&
        !isModifyOrder()) {
      if (orderpadupdate.stopLossTriggerController.text == ' ' ||
          orderpadupdate.stopLossTriggerController.text == '.' ||
          AppUtils()
                  .doubleValue(orderpadupdate.stopLossTriggerController.text) <=
              0) {
        return showValidationAlert(isBuyActionSelected()
            ? appLocalizations.sellStopLossEmptyError
            : appLocalizations.buyStopLossEmptyError);
      } else if (checkTickSize(orderpadupdate.stopLossTriggerController.text)) {
        return showValidationAlert(
            '${isBuyActionSelected() ? appLocalizations.sellStopLossTickSizeError : appLocalizations.buyStopLossTickSizeError} ${orderpadupdate.currentSymbol.sym!.tickSize}');
      } else {
        final List<String> splitValue =
            orderpadupdate.coTriggerPrice.value.split('-');
        final num low = splitValue.isNotEmpty &&
                AppUtils().dataNullCheck(splitValue[0]) != ''
            ? splitValue[0].trim().exdoubleTrialZero()
            : 0.00;
        final num high = splitValue.isNotEmpty &&
                AppUtils().dataNullCheck(splitValue[1]) != ''
            ? splitValue[1].trim().exdoubleTrialZero()
            : 0.00;
        if ((low >
                orderpadupdate.stopLossTriggerController.text
                    .exdoubleTrialZero()) ||
            ((orderpadupdate.stopLossTriggerController.text
                    .exdoubleTrialZero()) >
                high)) {
          return showValidationAlert(
              '${isBuyActionSelected() ? appLocalizations.sellStopLossRangeError : appLocalizations.buyStopLossRangeError} ${orderpadupdate.coTriggerPrice.value}');
        }
      }
//check for limit
      if (orderpadupdate.selectedOrderType == AppConstants.limit) {
        if (isBuyActionSelected() &&
            orderpadupdate.stopLossTriggerController.text.exdoubleTrialZero() >
                orderpadupdate.priceController.text.exdoubleTrialZero()) {
          return showValidationAlert(
              appLocalizations.tiggerPriceLesserThanLimitPriceError);
        } else if (!isBuyActionSelected() &&
            orderpadupdate.stopLossTriggerController.text.exdoubleTrialZero() <
                orderpadupdate.priceController.text.exdoubleTrialZero()) {
          return showValidationAlert(
              appLocalizations.triggerPriceGreaterThanLimitPriceError);
        }
      }
    }
    //CO modify order
    if (isModifyOrder() &&
        isModifyOrderCoverOrder() &&
        (isChildOrderSecondType() || isChildOrderThirdType())) {
      final List<String> splitValue =
          orderpadupdate.coTriggerPrice.value.split('-');
      final num low =
          splitValue.isNotEmpty && AppUtils().dataNullCheck(splitValue[0]) != ''
              ? splitValue[0].trim().exdoubleTrialZero()
              : 0.00;
      final num high =
          splitValue.isNotEmpty && AppUtils().dataNullCheck(splitValue[1]) != ''
              ? splitValue[1].trim().exdoubleTrialZero()
              : 0.00;
      if (orderpadupdate.stopLossTriggerController.text == ' ' ||
          orderpadupdate.stopLossTriggerController.text == '.' ||
          orderpadupdate.stopLossTriggerController.text.exdoubleTrialZero() <=
              0) {
        return showValidationAlert(appLocalizations.triggerPriceEmptyError);
      } else if (((low >
              AppUtils()
                  .doubleValue(orderpadupdate.stopLossTriggerController.text) ||
          (orderpadupdate.stopLossTriggerController.text.exdoubleTrialZero()) >
              high))) {
        return showValidationAlert(
            '${appLocalizations.triggerPriceRangeError} $low- $high');
      } else if (checkTickSize(orderpadupdate.stopLossTriggerController.text)) {
        return showValidationAlert(
            '${appLocalizations.triggetPriceTickSizeError} ${orderpadupdate.currentSymbol.sym!.tickSize}');
      } else {
        //is modify cover order then check for stop loss validation with mainLegPrice from   orders response
        if (isBuyActionSelected() &&
            orderpadupdate.stopLossTriggerController.text.exdoubleTrialZero() <
                orderpadupdate.orders.mainLegPrice
                    .dataNullCheck()
                    .exdoubleTrialZero()) {
          return showValidationAlert(
              appLocalizations.triggerPriceGreaterThanLimitPriceError);
        } else if (!isBuyActionSelected() &&
            orderpadupdate.stopLossTriggerController.text.exdoubleTrialZero() >
                orderpadupdate.orders.mainLegPrice
                    .dataNullCheck()
                    .exdoubleTrialZero() &&
            (orderpadupdate.selectedOrderType != AppConstants.slM &&
                orderpadupdate.selectedOrderType != AppConstants.market)) {
          return showValidationAlert(
              appLocalizations.tiggerPriceLesserThanLimitPriceError);
        }
      }
    }
    //BO - stop loss sell/buy and target price related errors
    if (getProductTypeStringForPlaceOrder() == AppConstants.bracketOrder &&
        !isModifyOrder()) {
      if (orderpadupdate.stopLossController.text == ' ' ||
          orderpadupdate.stopLossController.text == '.' ||
          orderpadupdate.stopLossController.text.exdoubleTrialZero() <= 0) {
        return showValidationAlert(isBuyActionSelected()
            ? appLocalizations.sellStopLossEmptyError
            : appLocalizations.buyStopLossEmptyError);
      } else if (checkTickSize(orderpadupdate.stopLossController.text)) {
        return showValidationAlert(
            '${isBuyActionSelected() ? appLocalizations.sellStopLossTickSizeError : appLocalizations.buyStopLossTickSizeError} ${orderpadupdate.currentSymbol.sym!.tickSize}');
      } else if (((orderpadupdate.lcl.exdoubleTrialZero() >
              orderpadupdate.stopLossController.text.exdoubleTrialZero() ||
          (orderpadupdate.stopLossController.text.exdoubleTrialZero()) >
              orderpadupdate.ucl.exdoubleTrialZero()))) {
        // return showValidationAlert(
        //     '${isBuyActionSelected() ? appLocalizations.sellStopLossRangeError : appLocalizations.buyStopLossRangeError} ${orderpadupdate.lcl} - ${orderpadupdate.ucl}');
      } else if (orderpadupdate.targetPriceController.text == ' ' ||
          orderpadupdate.targetPriceController.text == '.' ||
          orderpadupdate.targetPriceController.text.exdoubleTrialZero() <= 0) {
        return showValidationAlert(appLocalizations.targetPriceEmptyError);
      } else if (checkTickSize(orderpadupdate.targetPriceController.text)) {
        return showValidationAlert(
            '${appLocalizations.targetPriceTickSizeError} ${orderpadupdate.currentSymbol.sym!.tickSize}');
      } else if (((orderpadupdate.lcl.exdoubleTrialZero() >
              AppUtils()
                  .doubleValue(orderpadupdate.targetPriceController.text) ||
          (orderpadupdate.targetPriceController.text.exdoubleTrialZero()) >
              orderpadupdate.ucl.exdoubleTrialZero()))) {
        // return showValidationAlert(
        //     '${appLocalizations.targetPriceRangeError} ${orderpadupdate.lcl} - ${orderpadupdate.ucl}');
      }
      if (isBuyActionSelected() &&
          orderpadupdate.stopLossController.text.exdoubleTrialZero() >
              orderpadupdate.priceController.text.exdoubleTrialZero()) {
        return showValidationAlert(
            appLocalizations.sellStopLossPriceLessThanLimitPriceError);
      } else if (!isBuyActionSelected() &&
          orderpadupdate.stopLossController.text.exdoubleTrialZero() <
              orderpadupdate.priceController.text.exdoubleTrialZero()) {
        return showValidationAlert(
            appLocalizations.buyStopLossGreaterThanLimitPriceError);
      }
      if (isBuyActionSelected() &&
          orderpadupdate.targetPriceController.text.exdoubleTrialZero() <
              orderpadupdate.priceController.text.exdoubleTrialZero()) {
        return showValidationAlert(
            appLocalizations.targetPriceLesserThanLimitPriceError);
      } else if (!isBuyActionSelected() &&
          orderpadupdate.targetPriceController.text.exdoubleTrialZero() >
              orderpadupdate.priceController.text.exdoubleTrialZero()) {
        return showValidationAlert(
            appLocalizations.targetPriceGreaterThanLimitPriceError);
      }
    }
    return true;
  }

  Map<String, dynamic> getOrderPayloadData({int? pos}) {
    final Map<String, dynamic> orderPayloadData = {
      //basket order-----
      if ((orderpadupdate.basketorderId?.isNotEmpty ?? false) &&
          orderpadupdate.basketorderId != "")
        "basketOrderId": orderpadupdate.basketorderId,
      if (orderpadupdate.basketId != null) "basketId": orderpadupdate.basketId,
      if (orderpadupdate.basketId != null)
        "trSym": orderpadupdate.currentSymbol.dispSym,

      if (orderpadupdate.basketId != null) "pos": pos,

      "dispSym": orderpadupdate.currentSymbol.dispSym,
      "baseSym": orderpadupdate.currentSymbol.baseSym,

      //-----------------
      'sym': orderpadupdate.currentSymbol.sym
        ?..dispSym = orderpadupdate.currentSymbol.dispSym
        ..baseSym = orderpadupdate.currentSymbol.baseSym,
      'prdType': getPrdTypePayloadValue(),
      'ordType': orderpadupdate.selectedOrderType.toUpperCase(),
      if (orderpadupdate.priceController.text != AppLocalizations().atMarket)
        'limitPrice': getLimitPriceValue(),
      if (isBracketOrderorModifyMainLeg())
        'targetPrice': orderpadupdate.targetPriceController.text,
      'triggerPrice': getTriggerPriceValue(),
      'requiredMarigin':
          AppUtils().removeCommaFmt(orderpadupdate.requiredMargin),
      if (!isModifyOrder())
        'isAmo': !isBracketOrder() && !isCoverOrder()
            ? orderpadupdate.isAmoEnabled.value
            : false,
      'qty': (isModifyOrder() && orderpadupdate.basketId == null)
          ? (orderpadupdate.quantityController.text
                      .removeMultiplierOrderPad(
                          orderpadupdate.currentSymbol.sym)
                      .exInt() +
                  orderpadupdate.orders.tradedQty!.exdoubleTrialZero())
              .floor()
              .toString()
          : orderpadupdate.quantityController.text
              .removeMultiplierOrderPad(orderpadupdate.currentSymbol.sym),
      'disQty': orderpadupdate.isAmoEnabled.value
          ? ''
          : (orderpadupdate.disclosedQtyController.text
                  .removeMultiplierOrderPad(orderpadupdate.currentSymbol.sym))
              .toString(),
      'ordDuration': orderpadupdate.selectedValidity.toUpperCase(),
      'ordAction': orderpadupdate.selectedAction.toUpperCase(),
      'ltp': AppUtils().removeCommaFmt((orderpadupdate.currentSymbol).ltp),
      if (isBracketOrderorModifyMainLeg())
        'boTgtPrice': orderpadupdate.targetPriceController.text,
      if (isBracketOrderorModifyMainLeg())
        'boStpLoss': orderpadupdate.stopLossController.text,
      if (isBracketOrderorModifyMainLeg())
        'trailingSL': orderpadupdate.trailingStopLossController.text,
      'currentDateTime': "",
      if (isGTD())
        "gtdOrdDate": isGTD()
            ? (orderpadupdate.validityDateController.text.contains("/")
                ? AppUtils().getDateStringInDateFormat(
                    orderpadupdate.validityDateController.text,
                    AppConstants.dateFormatConstantDDMMYYYY,
                    AppConstants.dateFormatWithDash,
                  )
                : orderpadupdate.validityDateController.text)
            : ""
    };
    if (isModifyOrder()) {
      orderPayloadData['ordId'] = orderpadupdate.orders.ordId;
      orderPayloadData['triggerid'] =
          orderpadupdate.orders.triggerid.toString();
    }

    return orderPayloadData;
  }

  String getLimitPriceValue() {
    return (isModifyOrder() && isBracketOrder() && isChildOrderSecondType())
        ? AppUtils().removeCommaFmt(orderpadupdate.targetPriceController.text)
        : (isModifyOrder() && isBracketOrder() && isChildOrderThirdType())
            ? AppUtils().removeCommaFmt(orderpadupdate.stopLossController.text)
            : AppUtils().removeCommaFmt(orderpadupdate.priceController.text);
  }

  String getSelectedOrderTypeType() {
    return orderpadupdate.productList[orderpadupdate.selectedProductTypeIndex]
                .toUpperCase() ==
            AppLocalizations().regular.toUpperCase()
        ? orderpadupdate.selectedOrderType == AppConstants.market ||
                orderpadupdate.selectedOrderType == AppConstants.limit ||
                orderpadupdate.selectedOrderType == ''
            ? ''
            : orderpadupdate.selectedOrderType
        : orderpadupdate.selectedOrderType;
  }

  FutureOr<void> otherExchangeEvent(
      OtherExchange event, Emitter<OrderpadUiState> emit) {
    orderpadupdate.otherExcSymbol = event.symbols;
    orderpadupdate.currentSymbol = orderpadupdate.symbols.sym!.exc ==
            orderpadupdate.exchangeList!
                .elementAt(orderpadupdate.selectedExchangeIndex)
        ? orderpadupdate.symbols
        : orderpadupdate.otherExcSymbol;
    emit(OrderpadChange());

    emit(orderpadupdate);
  }

  updateQtyandAmount() {
    if (!orderpadupdate.isQuantity.value) {
      orderpadupdate.quantityController.text =
          (orderpadupdate.investAmount.text.exdouble() /
                  (orderpadupdate.priceController.text ==
                          AppLocalizations().atMarket
                      ? orderpadupdate.ltp.exdouble()
                      : orderpadupdate.priceController.text.exdouble()))
              .toString()
              .exInt()
              .toString();
    } else {
      orderpadupdate.investAmount.text =
          (orderpadupdate.quantityController.text.exdouble() *
                  (orderpadupdate.priceController.text ==
                          AppLocalizations().atMarket
                      ? orderpadupdate.currentSymbol.ltp.exdouble()
                      : orderpadupdate.priceController.text.exdouble()))
              .toStringAsFixed(AppUtils()
                  .getDecimalpoint(orderpadupdate.currentSymbol.sym!.exc!));
    }
  }

  FutureOr<void> checkMariginEvent(
      CheckMariginEvent event, Emitter<OrderpadUiState> emit) {
    updateQtyandAmount();
    final String price =
        (orderpadupdate.selectedOrderType == AppConstants.limit ||
                    orderpadupdate.selectedOrderType == AppConstants.sl) ||
                (orderpadupdate.priceController.text ==
                        AppLocalizations().atMarket &&
                    isRepeatOrder())
            ? orderpadupdate.priceController.text
            : (orderpadupdate.currentSymbol.ltp ?? "");
    if (price != '' &&
        price != '-' &&
        orderpadupdate.quantityController.text.isNotEmpty &&
        orderpadupdate.quantityController.text != '0') {
      //on sell NSE and BSE symbol , delivery product type
      //- no need to call check margin API.
      emit(OrderPadGetCheckMarigin(getCheckMarginPayloadData()));
    }
  }

  FutureOr<void> getCoTriggerPrice(
      GetCoTriggerPrice event, Emitter<OrderpadUiState> emit) {
    final Map<String, dynamic> payload = {
      'sym': orderpadupdate.currentSymbol.sym!,
      'prdType': getProductTypeStringForPlaceOrder(),
      'ordAction': (!isMainOrderType() && isModifyOrder())
          ? orderpadupdate.selectedAction.toUpperCase() ==
                  AppConstants.buy.toUpperCase()
              ? AppConstants.sell.toUpperCase()
              : AppConstants.buy.toUpperCase()
          : orderpadupdate.selectedAction.toUpperCase(),
    };
    emit(OrderpadCheckTrigger(payload));
  }

  String? triggerPriceError() {
    AppLocalizations appLocalizations = AppLocalizations();
    if ((orderpadupdate.selectedOrderType == AppConstants.sl ||
            orderpadupdate.selectedOrderType == AppConstants.slM) &&
        !isCoverOrder() &&
        !isBracketOrder()) {
      if (orderpadupdate.triggerPriceIndex == 0) {
        if (orderpadupdate.triggerPriceController.text == '' ||
            orderpadupdate.triggerPriceController.text == '.' ||
            AppUtils()
                    .doubleValue(orderpadupdate.triggerPriceController.text) <=
                0) {
          return AppLocalizations().triggerPriceEmptyError;
        } else if (((orderpadupdate.lcl.exdoubleTrialZero() >
                AppUtils()
                    .doubleValue(orderpadupdate.triggerPriceController.text) ||
            (AppUtils()
                    .doubleValue(orderpadupdate.triggerPriceController.text)) >
                orderpadupdate.ucl.exdoubleTrialZero()))) {
          // return (
          //     '${appLocalizations.triggerPriceRangeError} ${orderpadupdate.lcl}- ${orderpadupdate.ucl}');
        } else if (checkTickSize(orderpadupdate.triggerPriceController.text)) {
          return '${appLocalizations.triggetPriceTickSizeError} ${orderpadupdate.currentSymbol.sym!.tickSize}';
        }
      } else {
        String triggerPrice = AppUtils().decimalValue(((((AppUtils()
                        .doubleValue(
                            orderpadupdate.triggerPriceController.text) +
                    100) /
                100) *
            orderpadupdate.ltp.exdoubleTrialZero())));
        if (triggerPrice == '' ||
            triggerPrice == '.' ||
            triggerPrice.exdoubleTrialZero() <= 0) {
          return appLocalizations.triggerPriceEmptyError;
        } else if (((orderpadupdate.lcl.exdoubleTrialZero() >
                triggerPrice.exdoubleTrialZero() ||
            (triggerPrice.exdoubleTrialZero()) >
                orderpadupdate.ucl.exdoubleTrialZero()))) {
          // return (
          //     '${appLocalizations.triggerPriceRangeError} ${orderpadupdate.lcl}- ${orderpadupdate.ucl}');
        } else if (checkTickSize(triggerPrice)) {
          return '${appLocalizations.triggetPriceTickSizeError} ${orderpadupdate.currentSymbol.sym!.tickSize}';
        }
      }
    }
    //price and trigger price filed comparison related errors
    if (orderpadupdate.selectedOrderType == AppConstants.sl &&
        !isBracketOrder()) {
      if (isBuyActionSelected() &&
          orderpadupdate.triggerPriceController.text.exdoubleTrialZero() >
              orderpadupdate.priceController.text.exdoubleTrialZero()) {
        return appLocalizations.tiggerPriceLesserThanLimitPriceError;
      } else if (((orderpadupdate.lcl.exdoubleTrialZero() >
              orderpadupdate.priceController.text.exdoubleTrialZero() ||
          (orderpadupdate.priceController.text.exdoubleTrialZero()) >
              orderpadupdate.ucl.exdoubleTrialZero()))) {
        // return
        //     '${appLocalizations.priceRangeError} ${orderpadupdate.lcl}- ${orderpadupdate.ucl}';
      } else if (!isBuyActionSelected() &&
          orderpadupdate.triggerPriceController.text.exdoubleTrialZero() <
              orderpadupdate.priceController.text.exdoubleTrialZero()) {
        return appLocalizations.triggerPriceGreaterThanLimitPriceError;
      }
    }
    return null;
  }
}
