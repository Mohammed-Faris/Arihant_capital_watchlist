import 'package:acml/src/screen_util/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ACMLTextField extends StatelessWidget {
  final FocusNode? focusNode;
  final TextEditingController textEditingController;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChange;
  final int maxLength;
  final bool isError;
  final bool autofocus;
  final bool obscure;

  final String label;
  final List<TextInputFormatter>? inputFormatters;

  final Widget? suffixIcon;
  const ACMLTextField(
      {Key? key,
      this.focusNode,
      this.onFieldSubmitted,
      required this.textEditingController,
      this.inputFormatters,
      this.autofocus = true,
      this.isError = false,
      required this.label,
      this.onChange,
      this.suffixIcon,
      this.obscure = false,
      this.maxLength = 16})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: key,
      showCursor: true,
      enableInteractiveSelection: true,
      // ignore: deprecated_member_use
      toolbarOptions: const ToolbarOptions(
        copy: false,
        cut: false,
        paste: false,
        selectAll: false,
      ),
      autocorrect: false,
      enabled: true,
      autofocus: autofocus,
      onChanged: onChange,
      focusNode: focusNode,
      obscureText: obscure,
      onFieldSubmitted: onFieldSubmitted,
      style: Theme.of(context)
          .primaryTextTheme
          .labelLarge!
          .copyWith(fontWeight: FontWeight.w400),
      textInputAction: TextInputAction.done,
      inputFormatters: inputFormatters,
      keyboardType: TextInputType.text,
      controller: textEditingController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(
          left: 15.w,
          top: 12.w,
          bottom: 12.w,
          right: 10.w,
        ),
        labelText: label,
        labelStyle: Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
            color: isError
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).primaryTextTheme.labelSmall!.color),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.w),
          borderSide: BorderSide(
              color: isError
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).dividerColor),
        ),
        suffixIcon: suffixIcon,
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: isError
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).dividerColor,
              width: 1),
        ),
      ),
      maxLength: maxLength,
    );
  }
}
