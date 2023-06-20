import '../../../styles/app_color.dart';

import '../../../../constants/app_constants.dart';
import '../../../../constants/keys/positions_keys.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../widgets/fandotag.dart';
import '../../base/base_screen.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/label_border_text_widget.dart';
import '../../../widgets/rupee_symbol_widget.dart';
import '../../../widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../models/orders/tradehistory_model.dart';
import '../../../styles/app_images.dart';
import '../../../widgets/expansion_tile.dart';

class TradeHistoryRowWidget extends BaseScreen {
  final ReportList trades;
  final Function() onRowClick;
  final bool isExpanded;
  const TradeHistoryRowWidget({
    Key? key,
    this.isExpanded = false,
    required this.trades,
    required this.onRowClick,
  }) : super(key: key);

  @override
  State<TradeHistoryRowWidget> createState() => _TradeHistoryRowWidgetState();
}

class _TradeHistoryRowWidgetState
    extends BaseAuthScreenState<TradeHistoryRowWidget> {
  late AppLocalizations _appLocalizations;

  String tappedButtonHeader = '';

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return _buildRowWidget(
      widget.trades,
    );
  }

  Widget _buildRowWidget(
    ReportList trades,
  ) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(bottom: AppWidgetSize.dimen_10),
        padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_10),
        decoration: BoxDecoration(
          border: Border(
              bottom:
                  BorderSide(color: Theme.of(context).dividerColor, width: 1)),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        width: AppWidgetSize.fullWidth(context),
        child: InkWell(
          onTap: () {},
          child: Theme(
            data: ThemeData().copyWith(
                dividerColor: Colors.transparent,
                cardColor: Theme.of(context).scaffoldBackgroundColor,
                colorScheme: Theme.of(context).colorScheme.copyWith(
                    background: Theme.of(context).colorScheme.background)),
            child: AppExpansionPanelList(
              animationDuration: const Duration(milliseconds: 200),
              elevation: 0,
              expansionCallback: (int index, bool isExpanded) {
                widget.onRowClick();
              },
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  body: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding:
                        EdgeInsets.symmetric(vertical: AppWidgetSize.dimen_10),
                    child: _buildTwoLabelsWidget(
                      _appLocalizations.orderID,
                      AppUtils().dataNullCheck(trades.orderNo),
                      isCopy: true,
                    ),
                  ),
                  headerBuilder: (context, isExpanded) {
                    return _buildRowContentWidget(trades);
                  },
                  isExpanded: widget.isExpanded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTwoLabelsWidget(
    String title,
    String value, {
    bool isCopy = false,
  }) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_11,
        left: AppWidgetSize.dimen_15,
        right: AppWidgetSize.dimen_15,
        bottom: AppWidgetSize.dimen_11,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
            title,
            Theme.of(context).primaryTextTheme.bodySmall!,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTextWidget(
                value,
                Theme.of(context)
                    .primaryTextTheme
                    .bodySmall!
                    .copyWith(fontWeight: FontWeight.w500),
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
                        isColor: true,
                        color: Theme.of(context)
                            .primaryTextTheme
                            .bodySmall
                            ?.color),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRowContentWidget(
    ReportList trades,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopRowWidget(trades),
        Padding(
          padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                  trades.tradeDate,
                  Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: AppWidgetSize.fontSize14)),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      right: AppWidgetSize.dimen_8,
                    ),
                    child: CustomTextWidget(
                      AppUtils().intValue(trades.netQty).isNegative
                          ? AppConstants.sell
                          : AppConstants.buy,
                      AppUtils().intValue(trades.netQty).isNegative
                          ? Theme.of(context)
                              .primaryTextTheme
                              .bodySmall!
                              .copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.negativeColor)
                          : Theme.of(context)
                              .primaryTextTheme
                              .bodySmall!
                              .copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge
                                      ?.color),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: AppWidgetSize.dimen_5),
                    child: CustomTextWidget(
                      '${trades.netQty} Qty${trades.avgPrice.isNotEmpty ? '@ ${AppConstants.rupeeSymbol}${trades.avgPrice}' : ""}',
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  widget.isExpanded
                      ? AppImages.upArrowIcon(
                          context,
                          color: Theme.of(context).iconTheme.color,
                          isColor: true,
                          width: AppWidgetSize.dimen_20,
                          height: AppWidgetSize.dimen_20,
                        )
                      : AppImages.downArrow(
                          context,
                          color: Theme.of(context).iconTheme.color,
                          isColor: true,
                          width: AppWidgetSize.dimen_20,
                          height: AppWidgetSize.dimen_20,
                        ),
                ],
              )
            ],
          ),
        )
      ],
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

  Widget _buildTopRowWidget(
    ReportList trades,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCompanyNameWidget(trades),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_10,
            ),
            child: _getLableWithRupeeSymbol(
              AppUtils().commaFmt(trades.netAmt),
              Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                    fontFamily: AppConstants.interFont,
                    fontWeight: FontWeight.w500,
                  ),
              Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildCompanyNameWidget(ReportList symbolItem) {
    return Row(
      children: [
        Container(
          constraints: BoxConstraints(
              maxWidth: AppWidgetSize.screenWidth(context) * 0.65),
          child: Padding(
            padding: EdgeInsets.only(
              right: AppWidgetSize.dimen_5,
            ),
            child: Text(
              AppUtils().dataNullCheck((symbolItem.companyName.toUpperCase())),
              style: Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: AppWidgetSize.fontSize16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        FandOTag(Symbols.fromJson(symbolItem.toJson()))
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
      return Theme.of(context).primaryColor;
    } else if (status.toLowerCase() == AppConstants.pending.toLowerCase()) {
      return Theme.of(context).indicatorColor;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }

  Color statusBorderColor(String status) {
    if (status.toLowerCase() == AppConstants.none.toLowerCase()) {
      return Theme.of(context).dividerColor;
    } else if (status.toLowerCase() == AppConstants.executed.toLowerCase()) {
      return Theme.of(context).primaryColor;
    } else if (status.toLowerCase() == AppConstants.pending.toLowerCase()) {
      return Theme.of(context).indicatorColor;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }

  TextStyle purchaseSellStyle(String orderAction) {
    return orderAction.toLowerCase() == AppConstants.buy.toLowerCase()
        ? Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).primaryTextTheme.titleLarge?.color)
        : Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.error);
  }
}
