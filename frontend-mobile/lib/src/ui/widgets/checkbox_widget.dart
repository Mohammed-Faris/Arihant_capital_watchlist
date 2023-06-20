import '../styles/app_images.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CheckboxWidget extends StatefulWidget {
  final Widget? enableIcon;
  final bool isDisabled;
  final Widget? disableIcon;
  late bool checkBoxValue;
  final Function valueChanged;
  final double? width;
  final double? height;
  final String addSymbolKey;
  bool isPositive;

  CheckboxWidget({
    Key? key,
    required this.checkBoxValue,
    required this.valueChanged,
    this.enableIcon,
    this.isDisabled = false,
    this.disableIcon,
    this.height,
    this.width,
    required this.addSymbolKey,
    this.isPositive = true,
  }) : super(key: key);

  @override
  CheckboxWidgetState createState() => CheckboxWidgetState();
}

class CheckboxWidgetState extends State<CheckboxWidget> {
  late bool checkBoxValue;

  @override
  Widget build(BuildContext context) {
    checkBoxValue = widget.checkBoxValue;
    return GestureDetector(
      key: Key(widget.addSymbolKey),
      onTap: () {
        if (!widget.isDisabled) {
          final bool value = !checkBoxValue;
          setState(() {
            checkBoxValue = value;
          });
          widget.checkBoxValue = value;
          widget.valueChanged(value);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (checkBoxValue)
            widget.enableIcon ??
                (widget.isPositive
                    ? AppImages.greenRadioEnableIcon(
                        context,
                        width: widget.width ?? 16,
                        height: widget.height ?? 16,
                        isColor: false,
                      )
                    : AppImages.redRadioEnableIcon(
                        context,
                        width: widget.width ?? 16,
                        height: widget.height ?? 16,
                        isColor: false,
                      ))
          else
            widget.disableIcon ??
                (widget.isPositive
                    ? AppImages.greenRadioDisableIcon(
                        context,
                        width: widget.width ?? 16,
                        height: widget.height ?? 16,
                      )
                    : AppImages.redRadioDisableIcon(
                        context,
                        width: widget.width ?? 16,
                        height: widget.height ?? 16,
                      )),
        ],
      ),
    );
  }
}
