import 'package:flutter/material.dart';

import '../../../../constants/app_constants.dart';
import '../../../../constants/keys/positions_keys.dart';
import '../../../../constants/keys/quote_keys.dart';
import '../../../../data/store/app_store.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/orders/order_book.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_color.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/fandotag.dart';
import '../../../widgets/label_border_text_widget.dart';
import '../../../widgets/rupee_symbol_widget.dart';
import '../../base/base_screen.dart';

class OrdersRowWidget extends BaseScreen {
  final Orders orders;
  final Function onRowClick;
  final bool isBottomSheet;
  final bool showOrdertype;
  final bool isFromGtd;
  const OrdersRowWidget(
      {Key? key,
      required this.orders,
      required this.onRowClick,
      this.isFromGtd = false,
      required this.isBottomSheet,
      this.showOrdertype = true})
      : super(key: key);

  @override
  State<OrdersRowWidget> createState() => _OrdersRowWidgetState();
}

class _OrdersRowWidgetState extends BaseAuthScreenState<OrdersRowWidget> {
  late AppLocalizations _appLocalizations;

  String tappedButtonHeader = '';
  Orders selectedOrder = Orders();

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return _buildRowWidget(
      widget.orders,
    );
  }

  Widget _buildRowWidget(
    Orders orders,
  ) {
    return GestureDetector(
      onTap: () {
        widget.onRowClick(orders);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: AppWidgetSize.dimen_1,
              color: Theme.of(context).dividerColor,
            ),
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        width: AppWidgetSize.fullWidth(context) - 10,
        padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_10,
          bottom: AppWidgetSize.dimen_10,
        ),
        child: _buildRowContentWidget(orders),
      ),
    );
  }

  Widget _buildRowContentWidget(
    Orders orders,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopRowWidget(orders),
        _buildMiddleRowWidget(orders),
        _buildBottomRowWidget(orders),
      ],
    );
  }

  Widget _buildTopRowWidget(Orders orders) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDispSymAndExcWidget(orders),
        if (widget.isBottomSheet)
          _buildStockQuoteWidget(orders)
        else
          _buildPrdTypeWidget(orders),
      ],
    );
  }

  Widget _buildStockQuoteWidget(Orders orders) {
    return LabelBorderWidget(
      keyText: const Key(quoteLabelKey),
      text: _appLocalizations.stockQuote,
      textColor: Theme.of(context).primaryColor,
      fontSize: AppWidgetSize.fontSize14,
      margin: EdgeInsets.all(AppWidgetSize.dimen_1),
      borderRadius: 20,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      borderWidth: 1,
      borderColor: Theme.of(context).dividerColor,
      isSelectable: true,
      labelTapAction: () {
        pushNavigation(
          ScreenRoutes.quoteScreen,
          arguments: {
            'symbolItem': orders,
          },
        );
      },
    );
  }

  Widget _buildDispSymAndExcWidget(Orders orders) {
    Color backGroundColor = AppStore.themeType == AppConstants.lightMode
        ? const Color(0xFFF2F2F2)
        : const Color(0xFF282F35);
    Color textColor = AppStore.themeType == AppConstants.lightMode
        ? const Color(0xFF797979)
        : const Color(0xFFFFFFFF);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_6,
          ),
          width: orders.dispSym!.textSize(
            (orders.sym?.optionType != null)
                ? '${orders.baseSym} '
                : AppUtils().dataNullCheck(orders.dispSym),
            Theme.of(context)
                .primaryTextTheme
                .labelSmall!
                .copyWith(fontWeight: FontWeight.w600),
          ),
          child: Text(
            (orders.sym?.optionType != null)
                ? '${orders.baseSym} '
                : AppUtils().dataNullCheck(orders.dispSym),
            style: Theme.of(context)
                .primaryTextTheme
                .labelSmall!
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        FandOTag(orders),
        if (orders.comments?.toLowerCase() ==
                (AppConstants.gtd.toLowerCase()) &&
            !widget.isFromGtd)
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4),
            child: Align(
              alignment: Alignment.topLeft,
              child: LabelBorderWidget(
                text: AppConstants.gtd,
                textColor: textColor,
                backgroundColor:
                    Theme.of(context).snackBarTheme.backgroundColor,
                borderColor: backGroundColor,
                fontSize: AppWidgetSize.fontSize10,
                margin: EdgeInsets.all(AppWidgetSize.dimen_1),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildPrdTypeWidget(Orders orders) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
      ),
      child: orders.ordType == null
          ? Container()
          : orders.ordType!.toUpperCase() == AppConstants.market.toUpperCase()
              ? _getLableWithRupeeSymbol(
                  orders.avgPrice ?? "0.00",
                  Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                        fontFamily: AppConstants.interFont,
                        fontWeight: FontWeight.w500,
                      ),
                  Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                )
              : _getLableWithRupeeSymbol(
                  orders.limitPrice ?? "-",
                  Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                        fontFamily: AppConstants.interFont,
                        fontSize: 16.w,
                        fontWeight: FontWeight.w500,
                      ),
                  Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.w,
                      ),
                ),
    );
  }

  Widget _buildMiddleRowWidget(Orders orders) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildOrdTypeAndOrdStatusWidget(orders),
        if (widget.isBottomSheet)
          _buildPrdTypeWidget(orders)
        else
          _buildOrdActionAndQtyWidget(orders)
      ],
    );
  }

  Widget _buildOrdTypeAndOrdStatusWidget(Orders orders) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: AppWidgetSize.screenWidth(context) * 0.52),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          children: [
            statusField2(orders.prdType.toString(), AppConstants.none, false),
            if (widget.showOrdertype)
              statusField2(orders.ordType!.capitalizeFirstofEach,
                  AppConstants.none, true),
            statusField2(
                orders.status!.capitalizeFirstofEach, orders.status!, false),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdActionAndQtyWidget(Orders orders) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: AppWidgetSize.dimen_8,
            ),
            child: CustomTextWidget(
              AppUtils().camelCase(orders.ordAction!),
              purchaseSellStyle(orders.ordAction.toString()),
            ),
          ),
          CustomTextWidget(
            qtyTitle(orders),
            Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRowWidget(Orders orders) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildOrdDateAndAmoWidget(orders),
        if (widget.isBottomSheet)
          _buildOrdActionAndQtyWidget(orders)
        else
          _buildLtpWidget(orders),
      ],
    );
  }

  Widget _buildOrdDateAndAmoWidget(Orders orders) {
    return Row(
      children: [
        // if (orders.remarks != null)
        //   Padding(
        //     padding: EdgeInsets.only(top: 5.w, right: 7.w, left: 2.w),
        //     child: AppImages.createBasketIcon(context,
        //         isColor: true, color: Theme.of(context).primaryColor),
        //   ),
        Padding(
          padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_10,
            left: AppWidgetSize.dimen_1,
          ),
          child: CustomTextWidget(
            AppUtils().getDateStringInDateFormat(
              orders.ordDate!,
              'dd/MM/yyyy HH:mm:ss',
              'dd-MM-yyyy HH:mm:ss',
            ),
            Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        if (orders.isAmo ?? false)
          Padding(
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_5,
            ),
            child: statusField(
              AppConstants.amo,
              AppConstants.none,
            ),
          ),
      ],
    );
  }

  Widget _buildLtpWidget(Orders orders) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
      ),
      child: CustomTextWidget(
        orders.ltp == null
            ? ""
            : '${_appLocalizations.ltp} ${AppUtils().dataNullCheck(orders.ltp)}',
        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
        isShowShimmer: true,
      ),
    );
  }

  Widget _getLableWithRupeeSymbol(
    String value,
    TextStyle rupeeStyle,
    TextStyle textStyle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        getRupeeSymbol(
          context,
          rupeeStyle,
        ),
        CustomTextWidget(
          value,
          textStyle,
        ),
      ],
    );
  }

  Padding statusField(
    String label,
    String type,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_8,
        right: AppWidgetSize.dimen_5,
      ),
      child: _getLabelBorderWidget(
        positionsSymbolRowProductTypeKey + label.toString(),
        label,
        type,
      ),
    );
  }

  Padding statusField2(String label, String type, bool isUpper) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_8,
        right: AppWidgetSize.dimen_5,
      ),
      child: _getLabelBorderWidget2(
          positionsSymbolRowProductTypeKey + label.toString(),
          label,
          type,
          isUpper),
    );
  }

  Widget _getLabelBorderWidget2(
      String key, String title, String status, bool isUpper) {
    return SizedBox(
      width: title.textSize(
            title,
            Theme.of(context).inputDecorationTheme.labelStyle!,
          ) +
          10.w,
      child: LabelBorderWidget(
        keyText: Key(key),
        text: title.replaceAll("Sl-m", "SL-M").replaceAll("Sl", "SL"),
        textColor: statusTextColor(status),
        fontSize: AppWidgetSize.fontSize11,
        borderRadius: AppWidgetSize.dimen_20,
        padding: EdgeInsets.all(4.w),
        margin: EdgeInsets.only(right: AppWidgetSize.dimen_1),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        borderWidth: 1.w,
        borderColor: statusBorderColor(status),
      ),
    );
  }

  Widget _getLabelBorderWidget(
    String key,
    String title,
    String status,
  ) {
    return SizedBox(
      width: title.textSize(
            title,
            Theme.of(context).inputDecorationTheme.labelStyle!,
          ) +
          AppWidgetSize.dimen_10,
      child: LabelBorderWidget(
        keyText: Key(key),
        text: title,
        textColor: statusTextColor(status),
        fontSize: AppWidgetSize.fontSize12,
        borderRadius: AppWidgetSize.dimen_20,
        margin: EdgeInsets.only(right: AppWidgetSize.dimen_1),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        borderWidth: 1,
        borderColor: statusBorderColor(status),
      ),
    );
  }

  Color statusTextColor(String status) {
    if (status.toLowerCase() == AppConstants.none.toLowerCase()) {
      return Theme.of(context).inputDecorationTheme.labelStyle!.color!;
    } else if (status.toLowerCase() == AppConstants.executed.toLowerCase()) {
      return AppColors().positiveColor;
    } else if (status.toLowerCase() == AppConstants.pending.toLowerCase()) {
      return Theme.of(context).indicatorColor;
    } else {
      return AppColors.negativeColor;
    }
  }

  Color statusBorderColor(String status) {
    if (status.toLowerCase() == AppConstants.none.toLowerCase()) {
      return Theme.of(context).dividerColor;
    } else if (status.toLowerCase() == AppConstants.executed.toLowerCase()) {
      return AppColors().positiveColor;
    } else if (status.toLowerCase() == AppConstants.pending.toLowerCase()) {
      return Theme.of(context).indicatorColor;
    } else {
      return AppColors.negativeColor;
    }
  }

  TextStyle purchaseSellStyle(String orderAction) {
    return orderAction.toLowerCase() == AppConstants.buy.toLowerCase()
        ? Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500, color: AppColors().positiveColor)
        : Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500, color: AppColors.negativeColor);
  }

  String qtyTitle(Orders orders) =>
      '${orders.tradedQty.withMultiplierTrade(orders.sym)}/${orders.qty!.withMultiplierTrade(orders.sym)} ${_appLocalizations.qty}';
}
