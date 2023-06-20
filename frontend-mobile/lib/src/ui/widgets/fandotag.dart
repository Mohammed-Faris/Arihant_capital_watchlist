import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/app_constants.dart';
import '../../data/store/app_store.dart';
import '../../data/store/app_utils.dart';
import '../../models/common/symbols_model.dart';
import '../styles/app_widget_size.dart';
import 'label_border_text_widget.dart';

class FandOTag extends StatefulWidget {
  final Symbols symbolItem;
  final bool showTag;
  final bool showExpiry;
  final bool showWeekly;
  const FandOTag(this.symbolItem,
      {this.showExpiry = true,
      this.showTag = true,
      this.showWeekly = true,
      Key? key})
      : super(key: key);

  @override
  State<FandOTag> createState() => _FandOTagState();
}

class _FandOTagState extends State<FandOTag> {
  Color backGroundColor = AppStore.themeType == AppConstants.lightMode
      ? const Color(0xFFF2F2F2)
      : const Color(0xFF282F35);
  Color textColor = AppStore.themeType == AppConstants.lightMode
      ? const Color(0xFF797979)
      : const Color(0xFFFFFFFF);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.showExpiry)
          Row(
            children: [
              if (widget.showWeekly)
                Padding(
                  padding: EdgeInsets.only(right: 5.w),
                  child: AppUtils.weekly(widget.symbolItem, context),
                ),
              if (widget.symbolItem.sym?.optionType != null &&
                  widget.symbolItem.sym?.asset == "future")
                Align(
                  alignment: Alignment.topLeft,
                  child: LabelBorderWidget(
                    text: DateFormat("dd MMM").format(DateFormat('dd-MM-yyyy')
                        .parse(widget.symbolItem.sym!.expiry!)),
                    backgroundColor: backGroundColor,
                    borderColor: backGroundColor,
                    textColor: textColor,
                    fontSize: AppWidgetSize.fontSize10,
                    margin: EdgeInsets.all(AppWidgetSize.dimen_1),
                  ),
                )
              else if (widget.symbolItem.sym?.optionType != null)
                Align(
                  alignment: Alignment.topLeft,
                  child: LabelBorderWidget(
                    text:
                        '${DateFormat("dd MMM").format(DateFormat('dd-MM-yyyy').parse(widget.symbolItem.sym!.expiry!))} ${!(widget.symbolItem.sym?.strike?.contains(".00") ?? false) ? AppUtils().decimalValue(widget.symbolItem.sym?.strike, decimalPoint: 2) : AppUtils().intValue(widget.symbolItem.sym?.strike)} ${widget.symbolItem.sym?.optionType}',
                    textColor: textColor,
                    backgroundColor: backGroundColor,
                    borderColor: backGroundColor,
                    fontSize: AppWidgetSize.fontSize10,
                    margin: EdgeInsets.all(AppWidgetSize.dimen_1),
                  ),
                ),
            ],
          ),
        if (widget.showTag)
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4),
            child: Align(
              alignment: Alignment.topLeft,
              child: LabelBorderWidget(
                text: widget.symbolItem.sym?.exc == AppConstants.nfo
                    ? AppConstants.fo
                    : AppUtils().dataNullCheck(widget.symbolItem.sym!.exc),
                textColor: textColor,
                backgroundColor: backGroundColor,
                borderColor: backGroundColor,
                fontSize: AppWidgetSize.fontSize10,
                margin: EdgeInsets.all(AppWidgetSize.dimen_1),
              ),
            ),
          )
      ],
    );
  }
}
