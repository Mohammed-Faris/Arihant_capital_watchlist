import 'package:flutter/material.dart';

import '../styles/app_widget_size.dart';

const Color appPrimaryColor = Color(0xFF35B350); //
const Color appPrimaryLightColor = Color(0xFFFFFFFF); //
const Color appPrimaryColorSecondary = Color(0xFF3F3F3F); //
const Color appGradientColor = Color(0xFF79D98E); //
const Color appBackgroundColor = Color(0xFFF1F1F6);
const Color appBackgroundColorSecondary = Color(0xFFFFFFFF); //
const Color colorSchemaSecondaryColor = Color(0xFFFFFFFF); //
const Color appBorderColor = Color(0xFFE0E0E0); //
const Color appTextColor = Color(0xFF2B2B2B); //
const Color noInternetColor = Color(0xFFCC5439); //

Color appTextColorSecondary = const Color(0xFF000000).withOpacity(0.56); //
Color appDialogBackgroundColor = const Color(0xFFC4C4C4).withOpacity(0.2); //
const Color appAccentTextColor = Color(0xFF999999);
const Color appLightAccentTextColor = Color(0xFF000099);
const Color appOverlineColor = Color(0xFF666666);
const Color appErrorColor = Color(0xFFB00020); //
const Color appErrorBackgroundColor = Color(0xFFFBF2F4); //
const Color appIconColor = Color(0xFF747474); //
const Color appAccentIconColor = Color(0xFF717880);
const Color labelColor = Color(0xFF747474); //
const Color appInputFillColor = Color(0xFFF2F2F2); //
const Color snackBarBackgroundColor = Color(0xFFE1F4E5); //
const Color appFocusInputBorderColor = Color(0xFFEAEBEC);
Color colorSchemaBackgroundColor = const Color(0xFFF3F3F3).withOpacity(0.5); //
const Color colorSchemaPrimaryColor = Color(0xFF797979); //
const Color colorSchemeOnPrimaryColor = Color(0xFFBDF3C8); //
const Color colorSchemeOnSecondaryColor = Color(0xFFF5C1BC); //
const Color colorSchemeOnErrorColor = Color(0xFFC25E54); //
const Color colorPending = Color(0xFFFEB41C);

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: appPrimaryColor,
    primaryColorLight: appPrimaryLightColor,
    dialogBackgroundColor: appDialogBackgroundColor,
    scaffoldBackgroundColor: appBackgroundColorSecondary,
    fontFamily: 'futura',
    primaryTextTheme: TextTheme(
      titleLarge: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.headline6Size,
        fontWeight: FontWeight.w400,
        color: appPrimaryColor,
      ),
      headlineSmall: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.headline5Size,
        fontWeight: FontWeight.w400,
        color: appPrimaryColor,
      ),
      headlineMedium: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.headline4Size,
        fontWeight: FontWeight.w500,
        color: appPrimaryColor,
      ),
      displaySmall: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.headline3Size,
        fontWeight: FontWeight.w500,
        color: appPrimaryColor,
      ),
      displayMedium: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.headline2Size,
        fontWeight: FontWeight.w400,
        color: appPrimaryColor,
      ),
      displayLarge: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.headline1Size,
        fontWeight: FontWeight.w700,
        color: appPrimaryColor,
      ),
      titleMedium: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.subtitle1Size,
        fontWeight: FontWeight.w400,
        color: appPrimaryColorSecondary,
      ),
      titleSmall: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.subtitle2Size,
        fontWeight: FontWeight.w500,
        color: appPrimaryColorSecondary,
      ),
      labelLarge: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.buttonSize,
        fontWeight: FontWeight.w500,
        color: appPrimaryColorSecondary,
      ),
      labelSmall: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.overlineSize,
        fontWeight: FontWeight.w400,
        color: appPrimaryColorSecondary,
      ),
      bodySmall: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.captionSize,
        fontWeight: FontWeight.w400,
        color: appPrimaryColorSecondary,
      ),
      bodyMedium: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.bodyText2Size,
        fontWeight: FontWeight.w500,
        color: appPrimaryColor,
      ),
      bodyLarge: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.bodyText1Size,
        fontWeight: FontWeight.w500,
        color: appPrimaryColor,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.headline6Size,
        fontWeight: FontWeight.w400,
        color: appTextColor,
      ),
      headlineSmall: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.headline5Size,
        fontWeight: FontWeight.w400,
        color: appTextColor,
      ),
      headlineMedium: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.headline4Size,
        fontWeight: FontWeight.w500,
        color: appTextColor,
      ),
      displaySmall: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.headline3Size,
        fontWeight: FontWeight.w500,
        color: appTextColor,
      ),
      displayMedium: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.headline2Size,
        fontWeight: FontWeight.w400,
        color: appTextColor,
      ),
      displayLarge: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.headline1Size,
        fontWeight: FontWeight.w700,
        color: appTextColor,
      ),
      titleMedium: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.subtitle1Size,
        fontWeight: FontWeight.w400,
        color: appTextColorSecondary,
      ),
      titleSmall: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.subtitle2Size,
        fontWeight: FontWeight.w500,
        color: appTextColorSecondary,
      ),
      labelLarge: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.buttonSize,
        color: appTextColorSecondary,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.captionSize,
        fontWeight: FontWeight.w400,
        color: appTextColorSecondary,
      ),
      labelSmall: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.overlineSize,
        fontWeight: FontWeight.w400,
        color: appTextColorSecondary,
      ),
      bodyMedium: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.bodyText2Size,
        fontWeight: FontWeight.w400,
        color: appTextColor,
      ),
      bodyLarge: TextStyle(
        letterSpacing: 0,
        fontSize: AppWidgetSize.bodyText1Size,
        fontWeight: FontWeight.w400,
        color: appTextColor,
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      selectionHandleColor: Colors.transparent,
    ),
    appBarTheme: const AppBarTheme(
      color: appBackgroundColor,
      elevation: 0.0,
    ),
    indicatorColor: colorPending,
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.only(bottom: 3.w),
      labelStyle: TextStyle(
        height: 0.6,
        letterSpacing: 0,
        fontSize: AppWidgetSize.inputLabelSize,
        // fontWeight: FontWeight.w600,
        color: labelColor,
      ),
      fillColor: appInputFillColor,
      isDense: true,
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: appFocusInputBorderColor,
          width: 1,
        ),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: appFocusInputBorderColor,
          width: 1,
        ),
      ),
    ),
    primaryIconTheme: const IconThemeData(
      color: appPrimaryColorSecondary,
    ),
    iconTheme: const IconThemeData(
      color: appIconColor,
    ),
    // accentIconTheme: const IconThemeData(
    //   color: appTextColor,
    // ),
    dividerColor: appBorderColor,
    buttonTheme: ButtonThemeData(
      buttonColor: appPrimaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppWidgetSize.buttonBorderRadius,
      ),
      focusColor: appBackgroundColorSecondary,
      height: AppWidgetSize.buttonHeight,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: appBackgroundColorSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: snackBarBackgroundColor,
      contentTextStyle: TextStyle(
        fontFamily: "futura",
        fontWeight: FontWeight.bold,
      ),
    ),
    shadowColor: Colors.transparent,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: colorSchemaSecondaryColor,
      error: appErrorBackgroundColor,
      errorContainer: appErrorColor,
      background: colorSchemaBackgroundColor,
      primary: colorSchemaPrimaryColor,
      onPrimary: colorSchemeOnPrimaryColor,
      onSecondary: colorSchemeOnSecondaryColor,
      onError: colorSchemeOnErrorColor,
      onBackground: appGradientColor,
    ),
  );
}
