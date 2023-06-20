import 'package:flutter/material.dart';

import '../../../../styles/app_color.dart';
import '../../../../styles/app_images.dart';
import '../../../../styles/app_widget_size.dart';
import '../../../../validator/input_validator.dart';

class CustomDateSelector extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool? autocorrect;
  final bool? enabled;
  final Function(String)? onChanged;

  const CustomDateSelector(
      {Key? key,
      this.controller,
      this.focusNode,
      this.labelText,
      this.hintText,
       this.initialDate,
       this.firstDate,
       this.lastDate,
      this.autocorrect,
      this.enabled,
      this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller ?? TextEditingController(),
      focusNode: focusNode ?? FocusNode(),
      autocorrect: autocorrect ?? false,
      enabled: enabled ?? true,
      enableInteractiveSelection: false,
      maxLength: 20,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: InputValidator.dob,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(
          left: AppWidgetSize.dimen_15,
          top: AppWidgetSize.dimen_3,
          bottom: AppWidgetSize.dimen_3,
          right: AppWidgetSize.dimen_10,
        ),
        hintText: hintText ?? "DD/MM/YYYY",
        hintStyle: Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
            fontSize: AppWidgetSize.fontSize10,
            color: Theme.of(context).primaryTextTheme.labelSmall!.color),
        labelText: labelText ?? "",
        labelStyle: Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
            color: Theme.of(context).primaryTextTheme.labelSmall!.color),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.w),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(1950, 1),
              lastDate: lastDate ?? DateTime.now(),
              helpText: "",
              initialEntryMode: DatePickerEntryMode.calendarOnly,
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.fromSwatch(
                      primarySwatch: MaterialColor(
                          AppColors().positiveColor.value,
                          AppColors.calendarPrimaryColorSwatch),
                    ),
                    textTheme: TextTheme(
                      labelSmall: TextStyle(fontSize: AppWidgetSize.fontSize16),
                    ),
                  ),
                  child: child!,
                );
              },
            ).then(
              (pickedDate) {
                if (pickedDate != null) {}
              },
            );
          },
          child: Padding(
            padding: EdgeInsets.all(AppWidgetSize.dimen_8),
            child: AppImages.calendarIcon(
              context,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ),
      onChanged: onChanged,
      onTap: () {},
    );
  }
}
