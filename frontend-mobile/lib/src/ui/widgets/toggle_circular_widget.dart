import 'package:flutter/material.dart';

import '../styles/app_widget_size.dart';

typedef OnToggle = void Function(int index);

// ignore: must_be_immutable
class ToggleCircularWidget extends StatefulWidget {
  final Color? activeBgColor;
  final Color? activeTextColor;
  final Color? inactiveBgColor;
  final Color? inactiveTextColor;
  final List<String>? labels;
  final List<int>? length;
  final double cornerRadius;
  final OnToggle? onToggle;
  int initialLabel;
  final double minWidth;
  final bool? isBadgeWidget;
  final TextStyle activeTextStyle;
  final TextStyle inactiveTextStyle;
  final double height;
  final bool isDisabled;

  ToggleCircularWidget({
    this.activeBgColor,
    this.activeTextColor,
    this.inactiveBgColor,
    this.inactiveTextColor,
    this.labels,
    this.length,
    this.onToggle,
    this.isBadgeWidget,
    required Key key,
    this.cornerRadius = 8.0,
    this.initialLabel = 0,
    this.minWidth = 100,
    required this.activeTextStyle,
    required this.inactiveTextStyle,
    required this.height,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  ToggleCircularWidgetState createState() => ToggleCircularWidgetState();
}

class ToggleCircularWidgetState extends State<ToggleCircularWidget> {
  late int current;
  @override
  void initState() {
    super.initState();
    current = widget.initialLabel;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.cornerRadius),
      child: Container(
        // width: AppWidgetSize.screenWidth(context),
        height: widget.height,
        color: widget.inactiveBgColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(
            widget.isBadgeWidget!
                ? widget.labels!.length * 2 - 1
                : widget.labels!.length == 3
                    ? 6
                    : 4,
            (int index) {
              final bool active = index ~/ 2 == widget.initialLabel;
              final Color textColor =
                  active ? widget.activeTextColor! : widget.inactiveTextColor!;
              final Color bgColor =
                  active ? widget.activeBgColor! : Colors.transparent;
              if (index % 2 == 1) {
                final bool activeDivider =
                    active || index ~/ 2 == widget.initialLabel - 1;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(widget.cornerRadius),
                  child: Container(
                    width: 0,
                    color: widget.inactiveBgColor,
                    margin:
                        EdgeInsets.symmetric(vertical: activeDivider ? 0 : 8),
                  ),
                );
              } else {
                return GestureDetector(
                  onTap: () {
                    if (!widget.isDisabled) {
                      _handleOnTap(index ~/ 2);
                    }
                  },
                  child: Container(
                    constraints: widget.labels!.length == 3
                        ? BoxConstraints(minWidth: widget.minWidth / 1.5)
                        : BoxConstraints(minWidth: widget.minWidth),
                    decoration: BoxDecoration(
                      borderRadius: widget.initialLabel == 0
                          ? BorderRadius.only(
                              topLeft: Radius.circular(widget.cornerRadius),
                              bottomLeft: Radius.circular(widget.cornerRadius),
                            )
                          : widget.initialLabel == widget.labels!.length
                              ? BorderRadius.only(
                                  topRight:
                                      Radius.circular(widget.cornerRadius),
                                  bottomRight:
                                      Radius.circular(widget.cornerRadius),
                                )
                              : BorderRadius.only(
                                  topLeft:
                                      Radius.circular(AppWidgetSize.dimen_1),
                                ),
                      color: bgColor,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.labels![index ~/ 2],
                          textAlign: TextAlign.center,
                          style:
                              widget.activeTextStyle.copyWith(color: textColor),
                        ),
                        if (widget.isBadgeWidget!)
                          SizedBox(
                            width: 5.w,
                          ),
                        if (widget.isBadgeWidget!)
                          Container(
                            padding: EdgeInsets.all(AppWidgetSize.dimen_4),
                            // color: Theme.of(context).accentColor,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(widget.cornerRadius),
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 20.w,
                              minHeight: 20.w,
                            ),
                            child: Text(
                              '${widget.length![index ~/ 2]}',
                              textAlign: TextAlign.center,
                              style: active
                                  ? widget.activeTextStyle
                                  : widget.inactiveTextStyle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _handleOnTap(int index) async {
    setState(() => current = index);
    if (widget.onToggle != null) {
      widget.onToggle!(index);
      widget.initialLabel = current;
    }
  }
}
