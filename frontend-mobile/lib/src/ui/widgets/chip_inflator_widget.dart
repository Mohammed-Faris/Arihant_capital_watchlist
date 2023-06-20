import '../styles/app_widget_size.dart';
import 'package:flutter/material.dart';

class ChipInflater extends StatefulWidget {
  final String? label;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? labelColor;
  final bool? isRectShape;
  final double? verticalPadding;
  final double? horizontalPadding;
  const ChipInflater(
      {Key? key,
      this.label,
      this.backgroundColor,
      this.labelColor,
      this.borderColor,
      this.isRectShape = false,
      this.verticalPadding,
      this.horizontalPadding})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChipInflaterWidget();
  }
}

class ChipInflaterWidget extends State<ChipInflater> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppWidgetSize.dimen_4,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: Border.all(
          color: widget.borderColor!,
          width: AppWidgetSize.dimen_1,
        ),
        borderRadius: widget.isRectShape!
            ? BorderRadius.circular(AppWidgetSize.dimen_5)
            : BorderRadius.circular(AppWidgetSize.dimen_16),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: widget.verticalPadding ?? AppWidgetSize.dimen_4,
            horizontal: widget.horizontalPadding ?? AppWidgetSize.dimen_16),
        child: Text(
          widget.label!,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: widget.labelColor,
              ),
          key: Key(widget.label!),
        ),
      ),
    );
  }
}
