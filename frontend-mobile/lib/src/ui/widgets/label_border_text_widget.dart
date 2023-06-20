import 'package:flutter/material.dart';

import '../../data/store/app_utils.dart';
import '../styles/app_widget_size.dart';

// ignore: must_be_immutable
class LabelBorderWidget extends StatefulWidget {
  final String? text;
  final Key? keyText;
  final Color? textColor;
  final double? fontSize;
  final bool? isSelectable;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  TextAlign? textAlign;
  final bool withicon;
  bool isSelected = false;
  Color? selectedColor;
  Function? labelTapAction;
  final double borderRadius;
  final Color? backgroundColor;
  final double borderWidth;
  final Color? borderColor;
  final Widget? svgPicture;
  final bool showNSETag;
  LabelBorderWidget(
      {this.text,
      this.keyText,
      this.textColor,
      this.fontSize,
      this.isSelectable = false,
      this.selectedColor,
      this.isSelected = false,
      this.labelTapAction,
      this.withicon = false,
      this.margin = const EdgeInsets.all(3),
      this.textAlign = TextAlign.center,
      this.padding = const EdgeInsets.only(
        left: 2,
        right: 2,
        top: 1,
        bottom: 1,
      ),
      this.borderRadius = 4,
      this.backgroundColor,
      this.borderWidth = 0.7,
      this.borderColor,
      this.svgPicture,
      this.showNSETag = true,
      Key? key})
      : super(key: key);

  @override
  LabelBorderWidgetState createState() => LabelBorderWidgetState();
}

class LabelBorderWidgetState extends State<LabelBorderWidget> {
  @override
  Widget build(BuildContext context) {
    dynamic bgColor;

    if (widget.isSelectable == true) {
      if (widget.isSelected && widget.selectedColor == null) {
        bgColor = widget.backgroundColor ??
            Theme.of(context).inputDecorationTheme.fillColor;
      } else if (widget.isSelected && widget.selectedColor != null) {
        bgColor = widget.backgroundColor ??
            Theme.of(context).inputDecorationTheme.fillColor;
      } else {
        bgColor = widget.backgroundColor ?? Theme.of(context).dividerColor;
      }
    } else {
      bgColor = widget.backgroundColor ??
          Theme.of(context).inputDecorationTheme.fillColor;
    }
    return IgnorePointer(
      ignoring: !widget.isSelectable!,
      child: InkWell(
        onTap: () {
          if (widget.isSelectable!) {
            setState(() {
              widget.isSelected = !widget.isSelected;
            });
            widget.labelTapAction!();
          }
        },
        child: Container(
          alignment: widget.withicon ? Alignment.centerRight : Alignment.center,
          key: widget.keyText,
          margin: widget.margin,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: bgColor,
            border:
                Border.all(color: _getBorderColor(), width: widget.borderWidth),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: widget.svgPicture != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8.0.w),
                      child: widget.svgPicture!,
                    ),
                    Text(
                      AppUtils().dataNullCheck(widget.text),
                      textAlign: widget.textAlign,
                      style: TextStyle(
                        color: _getTextColor(),
                        fontSize: widget.isSelectable == true
                            ? AppWidgetSize.dimen_12
                            : widget.fontSize,
                      ),
                    ),
                  ],
                )
              : widget.showNSETag
                  ? Text(
                      AppUtils().dataNullCheck(widget.text),
                      textAlign: widget.textAlign,
                      // softWrap: false,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: _getTextColor(),
                        fontSize: widget.isSelectable == true
                            ? AppWidgetSize.dimen_12
                            : widget.fontSize,
                      ),
                    )
                  : Container(),
        ),
      ),
    );
  }

  Color _getTextColor() {
    if (widget.isSelectable == true) {
      if (widget.isSelected == true) {
        return widget.textColor!;
      } else {
        return widget.textColor!;
      }
    } else {
      return widget.textColor!;
    }
  }

  Color _getBorderColor() {
    if (widget.isSelectable == true) {
      if (widget.isSelected == true) {
        return Theme.of(context).primaryColor;
      } else {
        return Theme.of(context).dividerColor;
      }
    } else {
      return widget.borderColor ??
          Theme.of(context).inputDecorationTheme.fillColor ??
          Theme.of(context).colorScheme.background;
    }
  }
}
