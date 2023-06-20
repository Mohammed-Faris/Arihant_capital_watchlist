import "dart:ui" as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/positions/position_conversion/position_convertion_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_events.dart';
import '../../../constants/keys/orderpad_keys.dart';
import '../../../constants/keys/quote_keys.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/positions/positions_model.dart';
import '../../../notifiers/notifiers.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../validator/input_validator.dart';
import '../../widgets/checkbox_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/fandotag.dart';
import '../base/base_screen.dart';

class PositionsConvertSheet extends BaseScreen {
  final dynamic arguments;
  const PositionsConvertSheet({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  PositionConversionSheetState createState() => PositionConversionSheetState();
}

class PositionConversionSheetState
    extends BaseAuthScreenState<PositionsConvertSheet> {
  late Positions positions;
  late PositionConvertionBloc positionConvertionBloc;
  late AppLocalizations _appLocalizations;
  final FocusNode _qtyFocusNode = FocusNode();
  final TextEditingController _qtyController = TextEditingController(text: '0');
  final TextEditingController _lotSizeController =
      TextEditingController(text: '');

  bool textBoxError = false;
  String errorMsg = '';

  late String convertType;
  final CheckBoxChange _checkBoxChange = CheckBoxChange(false);

  @override
  void initState() {
    positions = widget.arguments['positions'];
    if (isExcNseOrBse()) {
      convertType = positions.prdType!.toLowerCase() ==
              AppConstants.delivery.toLowerCase()
          ? AppConstants.intraday
          : AppConstants.delivery;
    } else {
      //prodtype should be sent as Normal instead of carryforward in positions.
      convertType = positions.prdType!.toLowerCase() ==
              AppConstants.carryForward.toLowerCase()
          ? AppConstants.intraday
          : AppConstants.carryForward;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      positionConvertionBloc = BlocProvider.of<PositionConvertionBloc>(context)
        ..stream.listen((_positionsConvertionListener));
    });
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.positionsConvertScreen);
  }

  bool isExcNseOrBse() {
    return positions.sym!.exc == AppConstants.nse ||
            positions.sym!.exc == AppConstants.bse
        ? true
        : false;
  }

  Future<void> _positionsConvertionListener(
      PositionConvertionState state) async {
    if (state is! PositionConvertionProgressState) {
      if (mounted) {
        stopLoader();
      }
    }
    if (state is PositionConvertionProgressState) {
      if (mounted) {
        startLoader();
      }
    } else if (state is PositionConvertionDataState) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      showToast(
        message: state.baseModel.infoMsg,
        context: context,
      );
    } else if (state is PositionConvertionFailedState ||
        state is PositionConvertionServiceExceptionState) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      showToast(
        message: state.errorMsg,
        context: context,
        isError: true,
      );
    } else if (state is PositionConvertionErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 1.0,
      initialChildSize: 1.0,
      builder: (BuildContext context, ScrollController scrollController) {
        return ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(AppWidgetSize.dimen_20),
          ),
          child: SafeArea(
              child: Scaffold(
            body: _buildBody(),
          )),
        );
      },
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitleWidget(),
              Divider(
                thickness: AppWidgetSize.dimen_1,
              ),
              buildDispSymWidget(),
              buildProductTypeWidget(),
              InkWell(
                  onTap: () {
                    onConvertChange();
                  },
                  child: buildConvertAllBannerWidget()),
              if (isExcNseOrBse())
                buildQtyWidget()
              else
                buildQtyWithLotWidget(),
              if (!textBoxError)
                buildTotalQtyWidget()
              else
                buildQtyErrorWidget(),
            ],
          ),
          buildFooterWidget(),
        ],
      ),
    );
  }

  Widget buildTitleWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_30,
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
        bottom: AppWidgetSize.dimen_20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CustomTextWidget(
            _appLocalizations.convert,
            Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 22.w),
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
    );
  }

  Widget _buildCheckboxWidget(bool value) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: AppWidgetSize.dimen_10),
            child: FittedBox(
              child: CheckboxWidget(
                checkBoxValue: true,
                valueChanged: (bool checkboxdata) {
                  onConvertChange();
                },
                addSymbolKey: orderpadCustomPriceCheckboxKey,
                enableIcon: value
                    ? AppImages.filterSelectedIcon(
                        context,
                        width: AppWidgetSize.dimen_20,
                        height: AppWidgetSize.dimen_20,
                      )
                    : AppImages.filterUnSelectedIcon(
                        context,
                        width: AppWidgetSize.dimen_20,
                        height: AppWidgetSize.dimen_20,
                      ),
              ),
            ),
          ),
          CustomTextWidget(
            '${_appLocalizations.convertCheckMsg}${positions.prdType} to $convertType',
            Theme.of(context)
                .primaryTextTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  void onConvertChange() {
    {
      if (_checkBoxChange.value) {
        _checkBoxChange.updateCheckBox(false);
      } else {
        _qtyController.text = (AppUtils()
                .intValue(positions.netQty.withMultiplierTrade(positions.sym))
                .abs())
            .toString();

        setState(() {
          textBoxError = false;
          errorMsg = '';
        });
        _checkBoxChange.updateCheckBox(true);
      }
    }
  }

  Widget buildQtyWidget() {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
      ),
      child: ValueListenableBuilder(
        valueListenable: _checkBoxChange,
        builder: (BuildContext context, bool value, Widget? child) {
          return Focus(
            onFocusChange: (value) {
              if (_qtyController.text.isEmpty) {
                _qtyController.text = '0';
              }
              if (value &&
                  (_qtyController.text.isEmpty || _qtyController.text == "0")) {
                _qtyController.text = '';
              }
            },
            child: TextField(
              enableInteractiveSelection: true,
              autocorrect: false,
              enabled: _checkBoxChange.value ? false : true,
              focusNode: _qtyFocusNode,
              onChanged: (String text) {
                if (AppUtils().intValue(text) >
                    (AppUtils()
                        .intValue(
                            positions.netQty.withMultiplierTrade(positions.sym))
                        .abs())) {
                  textBoxError = true;
                  errorMsg = _appLocalizations.qtyCannotMoreError +
                      (AppUtils()
                              .intValue(positions.netQty
                                  .withMultiplierTrade(positions.sym))
                              .abs())
                          .toString();
                } else {
                  textBoxError = false;
                  errorMsg = '';
                }
              },
              style: Theme.of(context)
                  .primaryTextTheme
                  .labelLarge!
                  .copyWith(fontWeight: FontWeight.w400),
              inputFormatters: InputValidator.qtyRegEx,
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: AppWidgetSize.dimen_15,
                  top: AppWidgetSize.dimen_15,
                  bottom: AppWidgetSize.dimen_15,
                  right: AppWidgetSize.dimen_15,
                ),
                labelText: _appLocalizations.quantity,
                labelStyle: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(
                      color: textBoxError
                          ? AppColors.negativeColor
                          : Theme.of(context).textTheme.headlineMedium!.color,
                    ),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.w),
                  borderSide: BorderSide(
                    color: textFieldColor(context),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: textFieldColor(context),
                  ),
                  borderRadius: BorderRadius.circular(5.w),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: textFieldColor(context),
                    width: 1,
                  ),
                ),
              ),
              maxLength: 10,
            ),
          );
        },
      ),
    );
  }

  Widget buildQtyWithLotWidget() {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildQtyLotWidget(),
          buildLotSizeWidget(),
        ],
      ),
    );
  }

  Widget buildQtyLotWidget() {
    return SizedBox(
      width: AppUtils.isTablet ? 180.w : 150.w,
      child: Stack(
        children: [
          ValueListenableBuilder(
              valueListenable: _checkBoxChange,
              builder: (BuildContext context, bool value, Widget? child) {
                return Focus(
                  onFocusChange: (value) {
                    if (_qtyController.text.isEmpty) {
                      _qtyController.text = '0';
                    }
                  },
                  child: TextField(
                    enableInteractiveSelection: true,
                    autocorrect: false,
                    enabled: _checkBoxChange.value ? false : true,
                    textAlign: TextAlign.center,
                    focusNode: _qtyFocusNode,
                    onChanged: (String text) {
                      if (_qtyController.text
                              .toString()
                              .removeMultipliertrade(positions.sym)
                              .exInt() ==
                          0) {
                        textBoxError = true;
                        errorMsg = _appLocalizations.lotIssueError;
                      } else if (AppUtils().intValue(_qtyController.text) >
                          (AppUtils()
                              .intValue(positions.netQty
                                  .withMultiplierTrade(positions.sym))
                              .abs())) {
                        textBoxError = true;
                        errorMsg = _appLocalizations.qtyCannotMoreError +
                            AppUtils()
                                .intValue(positions.netQty
                                    .withMultiplierTrade(positions.sym))
                                .abs()
                                .toString();
                      } else {
                        textBoxError = false;
                        errorMsg = '';
                      }
                      setState(() {});
                    },
                    style: Theme.of(context)
                        .primaryTextTheme
                        .labelLarge!
                        .copyWith(fontWeight: FontWeight.w400),
                    inputFormatters: InputValidator.qtyRegEx,
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        left: AppWidgetSize.dimen_15,
                        top: AppWidgetSize.dimen_15,
                        bottom: AppWidgetSize.dimen_15,
                        right: AppWidgetSize.dimen_15,
                      ),
                      labelText: _appLocalizations.quantity,
                      labelStyle:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                color: textBoxError
                                    ? AppColors.negativeColor
                                    : Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .color,
                              ),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.w),
                        borderSide: BorderSide(
                          color: textFieldColor(context),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: textFieldColor(context),
                        ),
                        borderRadius: BorderRadius.circular(5.w),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: textFieldColor(context),
                          width: 1,
                        ),
                      ),
                    ),
                    maxLength: 10,
                  ),
                );
              }),
          if (!isExcNseOrBse())
            Positioned(
              top: AppWidgetSize.dimen_17,
              left: AppWidgetSize.dimen_10,
              child: GestureDetector(
                onTap: () {
                  if (!_checkBoxChange.value) {
                    lotInputChange(1);
                  }
                },
                child: Opacity(
                  opacity: !_checkBoxChange.value ? 1 : 0.5,
                  child: AppImages.qtyDecreaseIcon(
                    context,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true,
                    width: AppWidgetSize.dimen_22,
                    height: AppWidgetSize.dimen_22,
                  ),
                ),
              ),
            ),
          if (!isExcNseOrBse())
            Positioned(
              top: AppWidgetSize.dimen_17,
              right: AppWidgetSize.dimen_10,
              child: GestureDetector(
                onTap: () {
                  if (!_checkBoxChange.value) {
                    lotInputChange(2);
                  }
                },
                child: Opacity(
                  opacity: !_checkBoxChange.value ? 1 : 0.5,
                  child: AppImages.qtyIncreaseIcon(
                    context,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true,
                    width: AppWidgetSize.dimen_22,
                    height: AppWidgetSize.dimen_22,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void lotInputChange(int type) {
    if (_qtyFocusNode.hasFocus) {
      keyboardFocusOut();
    }
    int qty = AppUtils()
        .intValue(_qtyController.text != '' ? _qtyController.text : '0');
    int lotSize = "1".withMultiplierTrade2(positions.sym).exInt();
    if (type == 1) {
      qty = qty - lotSize;

      if (qty >= 0) {
        final String value = (((qty / lotSize).floor()) * lotSize).toString();
        _qtyController.text = value;
      }
    } else {
      qty = qty + 1;
      final String value = (((qty / lotSize).ceil()) * lotSize).toString();
      _qtyController
        ..text = value
        ..selection = TextSelection.collapsed(offset: value.length);
    }

    if (AppUtils().intValue(_qtyController.text) %
            AppUtils().intValue(positions.sym!.lotSize!) !=
        0) {
      textBoxError = true;
      errorMsg = _appLocalizations.lotIssueError;
    } else if (AppUtils().intValue(_qtyController.text) >
        (AppUtils()
            .intValue(positions.netQty.withMultiplierTrade(positions.sym))
            .abs())) {
      textBoxError = true;
      errorMsg = _appLocalizations.qtyCannotMoreError +
          (AppUtils()
                  .intValue(positions.netQty.withMultiplierTrade(positions.sym))
                  .abs())
              .toString();
    } else {
      textBoxError = false;
      errorMsg = '';
    }

    setState(() {});
  }

  Widget buildLotSizeWidget() {
    _lotSizeController.text = "1".withMultiplierTrade2(positions.sym);
    return Container(
      padding: EdgeInsets.only(left: 10.w),
      width: AppUtils.isTablet ? 180.w : 150.w,
      child: TextField(
        enableInteractiveSelection: false,
        autocorrect: false,
        enabled: false,
        style: Theme.of(context)
            .primaryTextTheme
            .labelLarge!
            .copyWith(fontWeight: FontWeight.w400),
        inputFormatters: InputValidator.qtyRegEx,
        controller: _lotSizeController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context)
              .inputDecorationTheme
              .fillColor!
              .withOpacity(0.4),
          contentPadding: EdgeInsets.only(
            left: AppWidgetSize.dimen_15,
            top: AppWidgetSize.dimen_15,
            bottom: AppWidgetSize.dimen_15,
            right: AppWidgetSize.dimen_15,
          ),
          labelText: _appLocalizations.lotSize,
          labelStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: textBoxError
                    ? AppColors.negativeColor
                    : Theme.of(context).textTheme.headlineMedium!.color,
              ),
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.w),
            borderSide: BorderSide(
              color: textFieldColor(context),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: textFieldColor(context),
            ),
            borderRadius: BorderRadius.circular(5.w),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: textFieldColor(context),
              width: 1,
            ),
          ),
        ),
        maxLength: 10,
      ),
    );
  }

  Widget buildDispSymWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_30,
            ),
            child: CustomTextWidget(
              positions.baseSym!,
              Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5.0.w),
            child: FandOTag(positions),
          )
        ],
      ),
    );
  }

  Widget buildProductTypeWidget() {
    return Padding(
      padding:
          EdgeInsets.only(top: AppWidgetSize.dimen_20, left: 30.w, right: 30.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: AppWidgetSize.dimen_38,
            width: 130.w,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_12,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(
                AppWidgetSize.dimen_3,
              ),
              color: Theme.of(context)
                  .inputDecorationTheme
                  .fillColor!
                  .withOpacity(0.4),
            ),
            child: CustomTextWidget(
              positions.prdType.toString(),
              Theme.of(context).primaryTextTheme.bodySmall,
            ),
          ),
          AppImages.rightArrow(
            context,
            color: Theme.of(context).primaryIconTheme.color,
            isColor: true,
            width: AppWidgetSize.dimen_40,
            height: AppWidgetSize.dimen_40,
          ),
          Container(
            height: AppWidgetSize.dimen_38,
            width: 130.w,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_12,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(
                AppWidgetSize.dimen_3,
              ),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: CustomTextWidget(
              convertType,
              Theme.of(context).primaryTextTheme.bodySmall,
            ),
            // DropdownButtonFormField<String>(
            //   value: _dropDownList![0].toString(),
            //   decoration: const InputDecoration(
            //       enabledBorder: UnderlineInputBorder(
            //           borderSide: BorderSide(color: Colors.white))),
            //   alignment: Alignment.centerLeft,
            //   icon: Padding(
            //       padding: EdgeInsets.only(right: AppWidgetSize.dimen_10),
            //       child: AppImages.downArrow(
            //         context,
            //         width: AppWidgetSize.dimen_20,
            //         height: AppWidgetSize.dimen_18,
            //       )),
            //   elevation: 0,
            //   onChanged: (String? newValue) {
            //     convertType = newValue!;
            //     _checkBoxChange.updateCheckBox(_checkBoxChange.value);
            //   },
            //   items:
            //       _dropDownList?.map<DropdownMenuItem<String>>((String value) {
            //     return name(value);
            //   }).toList(),
            // ),
          ),
        ],
      ),
    );
  }

  Widget buildConvertAllBannerWidget() {
    return ValueListenableBuilder(
        valueListenable: _checkBoxChange,
        builder: (
          BuildContext context,
          bool value,
          Widget? child,
        ) {
          return Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_30,
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
              bottom: AppWidgetSize.dimen_25,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: value
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).dividerColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(
                  AppWidgetSize.dimen_5,
                ),
                color: value
                    ? Theme.of(context)
                        .snackBarTheme
                        .backgroundColor
                        ?.withOpacity(0.1)
                    : Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Padding(
                padding: EdgeInsets.all(AppWidgetSize.dimen_7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildCheckboxWidget(value),
                    Padding(
                      padding: EdgeInsets.only(
                        top: AppWidgetSize.dimen_10,
                        left: AppWidgetSize.dimen_30,
                        right: AppWidgetSize.dimen_10,
                        bottom: AppWidgetSize.dimen_10,
                      ),
                      child: CustomTextWidget(
                        getConvertAllStatementString(),
                        Theme.of(context).primaryTextTheme.bodySmall,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  String getConvertAllStatementString() =>
      '${_appLocalizations.convertCheckBoxMsg}\'${positions.prdType}\' positions to \'$convertType\' positions by selecting this option.';

  Widget buildTotalQtyWidget() {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        top: AppWidgetSize.dimen_10,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: (positions.sym!.exc != AppConstants.nse &&
                positions.sym!.exc != AppConstants.bse)
            ? CustomTextWidget(
                _appLocalizations.totalAvailableQty +
                    positions.netQty
                        .withMultiplierTrade(positions.sym)
                        .exdouble()
                        .floor()
                        .abs()
                        .toString() +
                    lotAvailability(positions),
                Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontSize: AppWidgetSize.fontSize14),
              )
            : CustomTextWidget(
                _appLocalizations.totalAvailableQty +
                    (AppUtils().intValue(positions.netQty
                            .withMultiplierTrade(positions.sym)))
                        .abs()
                        .toString(),
                Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontSize: AppWidgetSize.fontSize14),
              ),
      ),
    );
  }

  Widget buildQtyErrorWidget() {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        top: AppWidgetSize.dimen_10,
      ),
      child: Align(
          alignment: Alignment.centerLeft,
          child: CustomTextWidget(
            errorMsg,
            Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.negativeColor,
                ),
          )),
    );
  }

  Widget buildFooterWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
      ),
      child: SizedBox(
        width: AppWidgetSize.fullWidth(context),
        height: AppWidgetSize.dimen_54,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _getBottomButtonWidget(
              quoteCancelConvertButtonKey,
              _appLocalizations.cancel,
              AppColors().positiveColor,
              false,
              true,
            ),
            SizedBox(width: AppWidgetSize.dimen_32),
            _getBottomButtonWidget(
              quoteConvertButtonKey,
              _appLocalizations.convert,
              AppColors().positiveColor,
              true,
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBottomButtonWidget(
    String key,
    String header,
    Color color,
    bool isGradient,
    bool isHollowColored,
  ) {
    return Opacity(
      opacity: header == _appLocalizations.convert
          ? AppUtils().intValue(_qtyController.text) <= 0 || textBoxError
              ? 0.3
              : 1
          : 1,
      child: GestureDetector(
        key: Key(key),
        onTap: () {
          if (header == _appLocalizations.convert &&
              AppUtils().intValue(_qtyController.text) != 0 &&
              !textBoxError) {
            if (AppUtils().intValue(_qtyController.text) >
                (AppUtils()
                    .intValue(
                        positions.netQty.withMultiplierTrade(positions.sym))
                    .abs())) {
              textBoxError = true;
              errorMsg = _appLocalizations.qtyCannotMoreError +
                  (AppUtils()
                          .intValue(positions.netQty
                              .withMultiplierTrade(positions.sym))
                          .abs())
                      .toString();
              setState(() {});
              return;
            } else if (AppUtils().intValue(_qtyController.text) <= 0) {
              textBoxError = true;
              errorMsg = _appLocalizations.invalidQtyError;
              setState(() {});
              return;
            }

            sendEventToFirebaseAnalytics(
                AppEvents.convert,
                ScreenRoutes.positionScreen,
                '${_appLocalizations.convertCheckMsg}${positions.prdType} to $convertType',
                key: "symbol",
                value: positions.dispSym);

            positionConvertionBloc.add(PostionConvertEvent(
              positions,
              _qtyController.text
                  .toString()
                  .removeMultipliertrade(positions.sym),
              convertType,
            ));
          } else if (header == _appLocalizations.cancel) {
            Navigator.pop(context);
          }
        },
        child: Container(
          width: AppWidgetSize.dimen_130,
          height: AppWidgetSize.fullWidth(context) / 6,
          padding: EdgeInsets.all(AppWidgetSize.dimen_10),
          decoration: isGradient
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
                    color: isHollowColored
                        ? AppColors.negativeColor
                        : AppColors().positiveColor,
                    width: 1.5,
                  ),
                  color: isHollowColored
                      ? Colors.transparent
                      : AppColors().positiveColor,
                  borderRadius: BorderRadius.circular(AppWidgetSize.dimen_30),
                ),
          child: Text(
            header,
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.displaySmall!.copyWith(
                color: isHollowColored
                    ? AppColors.negativeColor
                    : Theme.of(context).colorScheme.secondary),
          ),
        ),
      ),
    );
  }

  ui.Color textFieldColor(BuildContext context) {
    return textBoxError
        ? AppColors.negativeColor
        : Theme.of(context).dividerColor;
  }

  String lotAvailability(Positions positions) =>
      ' (${positions.netQty.removeMultiplierTrade2(positions.sym, forall: false).exdouble().abs().floor()} lots)';

  DropdownMenuItem<String> name(String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: CustomTextWidget(
        value,
        Theme.of(context)
            .primaryTextTheme
            .bodySmall
            ?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
