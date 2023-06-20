part of 'orderpad_ui_bloc.dart';

abstract class OrderpadUiState {}

class OrderpadInitial extends OrderpadUiState {}

class OrderpadChange extends OrderpadUiState {}

class CallOtherExchange extends OrderpadUiState {}

class OrderpadCheckTrigger extends OrderpadUiState {
  final Map<String, dynamic> payload;

  OrderpadCheckTrigger(this.payload);
}

class OrderPadGetMarketStatus extends OrderpadUiState {}

class OrderPadGetCheckMarigin extends OrderpadUiState {
  final Map<String, dynamic> mariginPayloadData;

  OrderPadGetCheckMarigin(this.mariginPayloadData);
}

class OrderpadUiUpdate extends OrderpadUiState {
  late Symbols symbols = Symbols();
  late final dynamic arguments;
  late Symbols otherExcSymbol;
  late Symbols currentSymbol;
  ValueNotifier<bool> isQuantity = ValueNotifier<bool>(true);
  String? basketId, basketorderId;
  Orders orders = Orders();
  int selectedExchangeIndex = 0;
  List<String>? exchangeList = [];
  List<String> actions = [
    AppLocalizations().buy,
    AppLocalizations().sell,
  ];
  List<String> productList = [];
  List<String> orderTypeList = [];
  List<String> validityList = [];
  final OrderPadUIModel orderPadUIModel = OrderPadUIModel.fromJson();
  bool isShowAmoWidget = false;
  int decimalPoint = 2;
  int selectedProductTypeIndex = 0;
  int selectedRegularProductTypeIndex = 0;
  int holdingsIndex = 0;
  final int triggerPriceIndex = 0;
  String selectedAction = AppLocalizations().buy;
  String selectedOrderType = AppConstants.market;
  String selectedValidity = AppConstants.day;
  String lcl = '';
  String ucl = '';
  String ltp = '';
  String availableMargin = '';
  String requiredMargin = '';
  ValueNotifier<String> coTriggerPrice = ValueNotifier<String>('');
//bool values
  bool isKeyboardhidden = true;
  bool isCustomPriceEnabled = false;
  bool isTriggerPriceEnabled = false;
  bool isShowAmo = false;
  ValueNotifier<bool> isAmoEnabled = ValueNotifier<bool>(false);
  ValueNotifier<bool> isAdvancedOptionsExpanded = ValueNotifier<bool>(false);
  bool isAmoCheckBoxInteracted = false;

  bool disableCustomPriceCheckbox = false;
  bool isHoldingsAvailable = false;
  bool isQuantityTextFieldInFocus = false;
  bool isShowDiscloseQty = false;
  bool orderDetailsExp = false;
  int selectedExpansion = 0;
  // 0 - No error
  // 1 - Funds required is greater than available funds
  // 2 - No holdings
  // 3 - insufficient holdings

  //isPlaceOrderSelected - to avoid duplicate order/one click on BUY/SELL button.
  ValueNotifier<bool> isPlaceOrderSelected = ValueNotifier<bool>(false);
  final TextEditingController investAmount = TextEditingController();

//text controller and focus node
  final TextEditingController quantityController = TextEditingController();
  final FocusNode qtyFocusNode = FocusNode();
  TextEditingController priceController = TextEditingController();
  final FocusNode priceFocusNode = FocusNode();
  final TextEditingController triggerPriceController = TextEditingController();
  final FocusNode triggerPriceFocusNode = FocusNode();
  final TextEditingController disclosedQtyController = TextEditingController();
  final FocusNode disclosedQtyFocusNode = FocusNode();
  final TextEditingController validityDateController = TextEditingController();
  final FocusNode validityFocusNode = FocusNode();
  final TextEditingController stopLossTriggerController =
      TextEditingController();
  final FocusNode stopLossTriggerFocusNode = FocusNode();
  final TextEditingController stopLossController = TextEditingController();
  final FocusNode stopLossFocusNode = FocusNode();
  final TextEditingController targetPriceController = TextEditingController();
  final FocusNode targetPriceFocusNode = FocusNode();
  final TextEditingController trailingStopLossController =
      TextEditingController();
  final FocusNode trailingStopLossFocusNode = FocusNode();
  TextInputType priceKeyboardType =
      const TextInputType.numberWithOptions(decimal: true);
  bool isNonPoaUser = false;
  String? segment;
  final ScrollController orderpadBodyScrollController = ScrollController();

  //------basket order--------
}
