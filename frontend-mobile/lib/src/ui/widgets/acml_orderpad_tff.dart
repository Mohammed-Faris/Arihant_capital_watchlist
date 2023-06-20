import 'package:acml/src/localization/app_localization.dart';
import 'package:acml/src/ui/screens/acml_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../constants/app_constants.dart';
import '../../constants/keys/orderpad_keys.dart';
import '../screens/base/base_screen.dart';
import '../styles/app_color.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';

// ignore: must_be_immutable
class ACMLTextFormField extends StatelessWidget {
  final String lblText;
  final TextEditingController txtCtrl;
  final FocusNode focusnode;
  final List<TextInputFormatter> formatter;
  final TextInputType keyboardType;
  final bool isTxtEnabled;
  final bool positiveColor;
  final bool isQty;
  final String? hintText;
  final bool isDate;
  final Widget? trailingWidget;
  final Widget? footerWidget;
  final bool isRupeeSymbolRequired;
  final bool isPercentSymbolRequired;
  final bool isToggle;

  TextStyle? style;
  final double width;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;
  final bool showCloseButton;
  final Function()? onInfoTap;
  final Function(bool value)? onToogle;

  final Function(bool value)? onFocusChange;
  final Function()? onTap;
  final Function(String value)? onChange;
  final String? Function(String?)? validator;
  ACMLTextFormField({
    Key? key,
    required this.lblText,
    required this.txtCtrl,
    required this.focusnode,
    required this.formatter,
    required this.keyboardType,
    required this.isTxtEnabled,
    this.isQty = false,
    this.isDate = false,
    required this.trailingWidget,
    required this.footerWidget,
    this.isRupeeSymbolRequired = false,
    this.isPercentSymbolRequired = false,
    this.style,
    this.width = 200,
    this.textAlign = TextAlign.center,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.showCloseButton = true,
    this.onInfoTap,
    this.onFocusChange,
    this.onTap,
    this.onChange,
    this.hintText,
    this.positiveColor = true,
    this.validator,
    this.isToggle = false,
    this.onToogle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    style ??= Theme.of(context).primaryTextTheme.labelSmall;
    return ValueListenableBuilder(
      valueListenable: txtCtrl,
      builder: (context, value, child) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          SizedBox(
            width: width.w,
            height: 25.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      if (onInfoTap != null) {
                        onInfoTap!();
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (lblText.startsWith("Trailing"))
                          SizedBox(
                            width: width,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                lblText,
                                style: style,
                              ),
                            ),
                          )
                        else
                          Text(
                            lblText,
                            style: style,
                          ),
                        if (onInfoTap != null)
                          AppImages.informationIcon(
                            context,
                            color: Theme.of(context).primaryIconTheme.color,
                            isColor: true,
                            width: 22.w,
                            height: 22.w,
                          ),
                      ],
                    )),
                if (trailingWidget != null) trailingWidget!
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: SizedBox(
              width: width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FocusScope(
                    child: Focus(
                      onFocusChange: onFocusChange,
                      child: Opacity(
                        opacity: isTxtEnabled ||
                                txtCtrl.text == AppLocalizations().atMarket
                            ? 1
                            : 0.65,
                        child: TextFormField(
                          key: key,
                          // enabled: isTxtEnabled,
                          readOnly: !isTxtEnabled,
                          validator: validator,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          enableInteractiveSelection: true,
                          // ignore: deprecated_member_use
                          toolbarOptions: const ToolbarOptions(
                            copy: false,
                            cut: false,
                            paste: false,
                            selectAll: false,
                          ),
                          scrollPadding: EdgeInsets.only(
                            bottom: 50.w,
                          ),
                          onTap: onTap,
                          controller: txtCtrl,
                          focusNode: focusnode,
                          cursorColor: Theme.of(context).primaryIconTheme.color,
                          textAlign: textAlign,
                          onChanged: onChange,
                          decoration: InputDecoration(
                            filled: isTxtEnabled,
                            isDense: true,
                            enabledBorder: textBorder(),
                            enabled: isTxtEnabled ||
                                txtCtrl.text == AppLocalizations().atMarket,
                            fillColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            border: textBorder(),
                            focusedBorder: textBorder(),
                            errorBorder:
                                textBorder(color: AppColors.negativeColor),
                            focusedErrorBorder:
                                textBorder(color: AppColors.negativeColor),
                            contentPadding: EdgeInsets.all(15.w),
                            disabledBorder: textBorder(
                                color: Theme.of(context)
                                    .disabledColor
                                    .withOpacity(0.1)),
                            prefixText: isRupeeSymbolRequired
                                ? AppConstants.rupeeSymbol
                                : '',
                            prefixStyle: Theme.of(context)
                                .primaryTextTheme
                                .labelSmall!
                                .copyWith(fontFamily: AppConstants.interFont),
                            suffixStyle: Theme.of(context)
                                .primaryTextTheme
                                .labelSmall!
                                .copyWith(fontFamily: AppConstants.interFont),
                            hintText: hintText,
                            errorMaxLines: 2,
                            errorStyle: Theme.of(context)
                                .primaryTextTheme
                                .bodyLarge!
                                .copyWith(
                                  color: AppColors.negativeColor,
                                ),
                            hintStyle:
                                Theme.of(context).primaryTextTheme.labelSmall,
                            labelStyle:
                                Theme.of(context).primaryTextTheme.labelSmall,
                          ),

                          inputFormatters: formatter,
                          keyboardType: keyboardType,
                          style: Theme.of(context).primaryTextTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
                  if (isDate)
                    Positioned(
                      right: 0.w,
                      child: GestureDetector(
                        key: const Key(orderpadCalendarIconKey),
                        onTap: () {
                          _displayDatePickerWidget(context);
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
                  if (isToggle)
                    Positioned(
                      left: 10.w,
                      top: 14.w,
                      child: GestureDetector(
                        onTap: () {
                          onToogle!(false);
                        },
                        child: AppImages.qtyDecreaseIcon(
                          context,
                          color: Theme.of(context).primaryIconTheme.color,
                          isColor: true,
                          width: AppWidgetSize.dimen_22,
                          height: AppWidgetSize.dimen_22,
                        ),
                      ),
                    ),
                  if (isToggle)
                    Positioned(
                      right: 10.w,
                      top: 14.w,
                      child: GestureDetector(
                        onTap: () {
                          onToogle!(true);
                        },
                        child: AppImages.qtyIncreaseIcon(
                          context,
                          color: Theme.of(context).primaryIconTheme.color,
                          isColor: true,
                          width: AppWidgetSize.dimen_22,
                          height: AppWidgetSize.dimen_22,
                        ),
                      ),
                    ),
                  if (showCloseButton)
                    closeButton(showCloseButton, txtCtrl, key),
                ],
              ),
            ),
          ),
          if (footerWidget != null)
            Container(
              height: 20.w,
              width: width,
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_4,
              ),
              child: footerWidget,
            )
        ],
      ),
    );
  }

  closeButton(bool showCloseButton, TextEditingController txtCtrl, Key? key) {
    return Positioned(
      right: 10.w,
      top: 14.w,
      child: Container(
        alignment: Alignment.centerRight,
        height: AppWidgetSize.dimen_20,
        width: AppWidgetSize.dimen_20,
        child: showCloseButton &&
                (txtCtrl.text != '' &&
                    txtCtrl.text != AppLocalizations().atMarket) &&
                (/* key != const Key(orderPadQuantityTextFieldKey) && */
                    txtCtrl.text != '0')
            ? Container(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    txtCtrl.clear();
                    if (onChange != null) onChange!("");
                  },
                  child: AppImages.deleteIcon(
                    navigatorKey.currentContext!,
                    color: Theme.of(
                      navigatorKey.currentContext!,
                    ).primaryIconTheme.color,
                  ),
                ),
              )
            : Container(
                width: 0,
              ),
      ),
    );
  }

  OutlineInputBorder textBorder({Color? color}) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color ?? Theme.of(navigatorKey.currentContext!).dividerColor,
        width: 1.w,
      ),
      borderRadius: BorderRadius.circular(
        3.w,
      ),
    );
  }

  Future<void> _displayDatePickerWidget(BuildContext context) async {
    DateTime initialDate = DateTime.now(); //.add(const Duration(days: 30));
    DateTime lastDate = DateTime.now().add(const Duration(days: 30));
    final DateTime? selectedDateOfBirth = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: lastDate,
      helpText: "",
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: positiveColor
                  ? MaterialColor(AppColors().positiveColor.value,
                      AppColors.calendarPrimaryColorSwatch)
                  : MaterialColor(AppColors.negativeColor.value,
                      AppColors.calendarSecondaryColorSwatch),
            ),
            textTheme: TextTheme(
              labelSmall: TextStyle(
                fontSize: AppWidgetSize.fontSize16.w,
              ),
            ),
            // dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: child!,
        );
      },
    );

    if (selectedDateOfBirth != null) {
      txtCtrl.text = getdatevalue(
        selectedDateOfBirth,
        AppConstants.dateFormatConstantDDMMYYYY,
      );
      if (txtCtrl.text.isNotEmpty) {
        showToast(
          message: "This order will expire on ${txtCtrl.text}",
        );
      }
    }
  }

  String getdatevalue(DateTime date, String formateString) {
    final dynamic now = date;
    final dynamic formatter = DateFormat(formateString);
    return formatter.format(now);
  }
}
