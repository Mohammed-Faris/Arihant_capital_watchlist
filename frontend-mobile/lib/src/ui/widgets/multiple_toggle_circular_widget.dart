import '../styles/app_widget_size.dart';
import 'custom_text_widget.dart';
import 'package:flutter/material.dart';

typedef OnToggle = void Function(int index);

class MultipleToggleCircularWidget extends StatefulWidget {
  const MultipleToggleCircularWidget(
      {Key? key,
      required this.listText,
      required this.listBool,
      required this.padding,
      required this.toggleButtonOnChanged})
      : super(key: key);

  final List<String> listText;
  final List<bool> listBool;
  final double padding;
  final Function toggleButtonOnChanged;

  @override
  MultipleToggleCircularWidgetState createState() =>
      MultipleToggleCircularWidgetState();
}

class MultipleToggleCircularWidgetState
    extends State<MultipleToggleCircularWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(20.w),
      borderWidth: 1,
      borderColor: Theme.of(context).primaryColor,
      selectedColor: Theme.of(context).primaryColor,
      onPressed: _handleOnPressed,
      renderBorder: false,
      isSelected: widget.listBool,
      fillColor: Theme.of(context).primaryColor,
      children: List<Widget>.generate(widget.listText.length, (int index) {
        return Padding(
          padding: EdgeInsets.only(right: widget.padding, left: widget.padding),
          child: CustomTextWidget(
              widget.listText[index],
              buildTextTheme(
                context,
                widget.listBool[index],
              ),
              textAlign: TextAlign.center),
        );
      }),
    );
  }

  TextStyle buildTextTheme(BuildContext context, bool listBool) {
    if (listBool) {
      return Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: AppWidgetSize.fontSize16,
          color: Theme.of(context).snackBarTheme.backgroundColor);
    } else {
      return Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: AppWidgetSize.fontSize16,
          color: Theme.of(context).primaryTextTheme.displayLarge!.color);
    }
  }

  void _handleOnPressed(int index) async {
    widget.toggleButtonOnChanged(index);
    setState(() {
      for (var i = 0; i < widget.listBool.length; i++) {
        widget.listBool[i] = false;
      }
      widget.listBool[index] = !widget.listBool[index];
    });
  }
}
