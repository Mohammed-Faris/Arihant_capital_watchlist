import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../styles/app_widget_size.dart';
import 'custom_text_widget.dart';

Widget buildTableWithBackgroundColor(
    String tableCell1Key,
    String tableCell1Value,
    String tableCell2Key,
    String tableCell2Value,
    String tableCell3Key,
    String tableCell3Value,
    BuildContext context,
    {bool isRupeeSymbol = false,
    bool isShowShimmer = false,
    bool isReduceFontSize = false,
    bool isRupeeSymbol1 = false,
    bool showtable = true,
    double? fontSize,
    double? keyFontSize}) {
  return SizedBox(
    width: AppWidgetSize.fullWidth(context),
    child: Table(
      children: <TableRow>[
        TableRow(
          children: <TableCell>[
            _buildTableCellWithBackgroundColor(
                tableCell1Key, tableCell1Value, context,
                isReduceFontSize: isReduceFontSize,
                isRupeeSymbol: isRupeeSymbol1,
                isShowShimmer: isShowShimmer,
                fontSize: fontSize,
                keyFontSize: keyFontSize),
            if (showtable && tableCell2Key.isNotEmpty)
              _buildTableCellWithBackgroundColor(
                  tableCell2Key, tableCell2Value, context,
                  isMiddle: true,
                  isReduceFontSize: isReduceFontSize,
                  isRupeeSymbol: isRupeeSymbol,
                  isShowShimmer: isShowShimmer,
                  fontSize: fontSize,
                  keyFontSize: keyFontSize),
            if (tableCell3Key.isNotEmpty)
              _buildTableCellWithBackgroundColor(
                  tableCell3Key, tableCell3Value, context,
                  isMiddle: true,
                  isReduceFontSize: isReduceFontSize,
                  isShowShimmer: isShowShimmer,
                  fontSize: fontSize,
                  keyFontSize: keyFontSize),
          ],
        ),
      ],
    ),
  );
}

TableCell _buildTableCellWithBackgroundColor(
    String key, String value, BuildContext context,
    {bool isMiddle = false,
    bool isReduceFontSize = false,
    bool isRupeeSymbol = false,
    bool isShowShimmer = false,
    double? fontSize,
    double? keyFontSize}) {
  return TableCell(
    child: Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
        left: isMiddle ? 10.w : 0,
        right: isMiddle ? 10.w : 0,
        top: 5.w,
      ),
      child: Container(
        padding: EdgeInsets.only(
          bottom: 5.w,
          top: 5.w,
        ),
        color: Theme.of(context).colorScheme.background,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextWidget(
                  isRupeeSymbol
                      ? (AppConstants.rupeeSymbol + value == "--"
                          ? "NA"
                          : value)
                      : value == "--"
                          ? "NA"
                          : value,
                  Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize ??
                          (isReduceFontSize ? AppWidgetSize.fontSize12 : null)),
                  textAlign: TextAlign.center,
                  isShowShimmer: isShowShimmer,
                ),
              ],
            ),
            Text(
              key,
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: keyFontSize ??
                      (isReduceFontSize ? AppWidgetSize.fontSize11 : null)),
            ),
          ],
        ),
      ),
    ),
  );
}
