import 'package:acml/src/screen_util/flutter_screenutil.dart';
import 'package:flutter/material.dart';

export 'package:acml/src/screen_util/flutter_screenutil.dart';
// ignore: depend_on_referenced_packages
export 'package:collection/collection.dart';

class ExceptionHandler implements Exception {
  late String code;
  late String msg;

  ExceptionHandler(
    this.code,
    this.msg,
  );
}

class AppWidgetSize {
  // Minumum screen width Ratio as per the UI/UX
  static double bodyPadding = 16.w;
  static double dimen_1 = 1.w;
  static double dimen_2 = 2.w;
  static double dimen_3 = 3.w;
  static double dimen_4 = 4.w;
  static double dimen_5 = 5.w;
  static double dimen_6 = 6.w;
  static double dimen_7 = 7.w;
  static double dimen_8 = 8.w;
  static double dimen_9 = 9.w;
  static double dimen_10 = 10.w;
  static double dimen_11 = 11.w;
  static double dimen_12 = 12.w;
  static double dimen_13 = 13.w;
  static double dimen_14 = 14.w;
  static double dimen_15 = 15.w;
  static double dimen_16 = 16.w;
  static double dimen_17 = 17.w;
  static double dimen_18 = 18.w;
  static double dimen_19 = 19.w;
  static double dimen_20 = 20.w;
  static double dimen_22 = 22.w;
  static double dimen_23 = 23.w;
  static double dimen_24 = 24.w;
  static double dimen_25 = 25.w;
  static double dimen_27 = 27.w;
  static double dimen_28 = 28.w;
  static double dimen_30 = 30.w;
  static double dimen_32 = 32.w;
  static double dimen_33 = 33.w;
  static double dimen_34 = 34.w;
  static double dimen_35 = 35.w;
  static double dimen_36 = 36.w;
  static double dimen_38 = 38.w;
  static double dimen_40 = 40.w;
  static double dimen_44 = 44.w;
  static double dimen_45 = 45.w;
  static double dimen_48 = 48.w;
  static double dimen_50 = 50.w;
  static double dimen_54 = 54.w;
  static double dimen_55 = 55.w;
  static double dimen_56 = 56.w;
  static double dimen_57 = 57.w;
  static double dimen_60 = 60.w;
  static double dimen_62 = 62.w;
  static double dimen_64 = 64.w;
  static double dimen_66 = 66.w;
  static double dimen_70 = 70.w;
  static double dimen_72 = 72.w;
  static double dimen_75 = 75.w;
  static double dimen_78 = 78.w;
  static double dimen_79 = 79.w;
  static double dimen_80 = 80.w;
  static double dimen_85 = 85.w;
  static double dimen_88 = 88.w;
  static double dimen_89 = 89.w;
  static double dimen_90 = 90.w;
  static double dimen_97 = 97.w;
  static double dimen_100 = 100.w;
  static double dimen_108 = 108.w;
  static double dimen_110 = 110.w;
  static double dimen_115 = 115.w;
  static double dimen_118 = 118.w;

  static double dimen_120 = 120.w;
  static double dimen_128 = 128.w;
  static double dimen_130 = 130.w;
  static double dimen_135 = 135.w;
  static double dimen_140 = 140.w;
  static double dimen_145 = 145.w;
  static double dimen_150 = 150.w;
  static double dimen_153 = 153.w;
  static double dimen_155 = 155.w;
  static double dimen_160 = 160.w;
  static double dimen_168 = 168.w;
  static double dimen_170 = 170.w;
  static double dimen_175 = 175.w;
  static double dimen_180 = 180.w;
  static double dimen_190 = 190.w;
  static double dimen_200 = 200.w;
  static double dimen_220 = 220.w;
  static double dimen_224 = 224.w;
  static double dimen_228 = 228.w;

  static double dimen_230 = 230.w;
  static double dimen_240 = 240.w;
  static double dimen_245 = 245.w;
  static double dimen_250 = 250.w;
  static double dimen_254 = 254.w;
    static double dimen_256 = 256.w;

  static double dimen_270 = 270.w;
  static double dimen_280 = 280.w;
  static double dimen_285 = 285.w;
  static double dimen_290 = 290.w;

  static double dimen_300 = 300.w;
  static double dimen_320 = 320.w;
  static double dimen_350 = 350.w;
  static double dimen_354 = 354.w;
  static double dimen_390 = 390.w;

  static double dimen_400 = 400.w;
  static double dimen_420 = 420.w;
  static double dimen_440 = 440.w;
  static double dimen_450 = 450.w;
  static double dimen_460 = 460.w;
  static double dimen_480 = 480.w;

  static double dimen_500 = 500.w;
  static double dimen_550 = 550.w;
  static double dimen_569 = 569.w;
  static double dimen_667 = 667.w;
  static double dimen_510 = 510.w;
  static double dimen_530 = 530.w;
  static double dimen_580 = 580.w;
  static double dimen_600 = 600.w;

  static double subtitle1Size = 28.w;
  static double subtitle2Size = 22.w;
  static double buttonSize = 18.w;
  static double overlineSize = 16.w;
  static double captionSize = 14.w;
  static double fontSize14 = 14.w;
  static double fontSize10 = 10.w;
  static double fontSize18 = 18.w;

  static double fontSize12 = 12.w;
  static double fontSize28 = 28.w;
  static double fontSize36 = 36.w;
  static double fontSize16 = 16.w;
  static double fontSize17 = 17.w;
  static double fontSize22 = 22.w;
  static double fontSize15 = 15.w;
  static double fontSize11 = 11.w;
  static double fontSize9 = 9.w;

  static double bodyText1Size = 12.w;
  static double bodyText2Size = 10.w;
  static double headline1Size = 38.w;
  static double headline2Size = 28.w;
  static double headline3Size = 22.w;
  static double headline4Size = 18.w;
  static double headline5Size = 16.w;
  static double headline6Size = 14.w;
  static double mainHeadLineSize = 20.w;
  static double inputLabelSize = 13.w;
  static double cardBorderRadius = dimen_6.w;
  static double buttonHeight = 45.h;
  static BorderRadius buttonBorderRadius = BorderRadius.circular(6).r;
  static double safeAreaSpace = 0.h;
  static double labelStyleTextHeight = 0.5.h;

  initSize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    bodyPadding = 16.w;
    dimen_1 = 1.w;
    dimen_2 = 2.w;
    dimen_3 = 3.w;
    dimen_4 = 4.w;
    dimen_5 = 5.w;
    dimen_6 = 6.w;
    dimen_7 = 7.w;
    dimen_8 = 8.w;
    dimen_9 = 9.w;
    dimen_10 = 10.w;
    dimen_11 = 11.w;
    dimen_12 = 12.w;
    dimen_13 = 13.w;
    dimen_14 = 14.w;
    dimen_15 = 15.w;
    dimen_16 = 16.w;
    dimen_17 = 17.w;
    dimen_18 = 18.w;
    dimen_19 = 19.w;
    dimen_20 = 20.w;
    dimen_22 = 22.w;
    dimen_23 = 23.w;
    dimen_24 = 24.w;
    dimen_25 = 25.w;
    dimen_28 = 28.w;
    dimen_30 = 30.w;
    dimen_32 = 32.w;
    dimen_33 = 33.w;
    dimen_34 = 34.w;
    dimen_35 = 35.w;
    dimen_36 = 36.w;
    dimen_38 = 38.w;
    dimen_40 = 40.w;
    dimen_44 = 44.w;
    dimen_45 = 45.w;
    dimen_48 = 48.w;
    dimen_50 = 50.w;
    dimen_54 = 54.w;
    dimen_55 = 55.w;
    dimen_56 = 56.w;
    dimen_57 = 57.w;
    dimen_60 = 60.w;
    dimen_62 = 62.w;
    dimen_64 = 64.w;
    dimen_66 = 66.w;
    dimen_70 = 70.w;
    dimen_72 = 72.w;
    dimen_75 = 75.w;
    dimen_79 = 79.w;
    dimen_80 = 80.w;
    dimen_85 = 85.w;
    dimen_88 = 88.w;
    dimen_89 = 89.w;
    dimen_90 = 90.w;
    dimen_97 = 97.w;
    dimen_100 = 100.w;
    dimen_108 = 108.w;
    dimen_110 = 110.w;
    dimen_115 = 115.w;
    dimen_118 = 118.w;

    dimen_120 = 120.w;
    dimen_128 = 128.w;
    dimen_130 = 130.w;
    dimen_135 = 135.w;
    dimen_140 = 140.w;
    dimen_145 = 145.w;
    dimen_150 = 150.w;
    dimen_153 = 153.w;
    dimen_155 = 155.w;
    dimen_160 = 160.w;
    dimen_168 = 168.w;
    dimen_170 = 170.w;
    dimen_180 = 180.w;
    dimen_190 = 190.w;
    dimen_200 = 200.w;
    dimen_220 = 220.w;
    dimen_224 = 224.w;
    dimen_228 = 228.w;

    dimen_230 = 230.w;
    dimen_240 = 240.w;
    dimen_245 = 245.w;
    dimen_250 = 250.w;
    dimen_254 = 254.w;

    dimen_270 = 270.w;
    dimen_280 = 280.w;
    dimen_285 = 285.w;
    dimen_290 = 290.w;

    dimen_300 = 300.w;
    dimen_320 = 320.w;
    dimen_350 = 350.w;
    dimen_354 = 354.w;
    dimen_390 = 390.w;

    dimen_400 = 400.w;
    dimen_420 = 420.w;
    dimen_440 = 440.w;
    dimen_450 = 450.w;
    dimen_460 = 460.w;
    dimen_480 = 480.w;
    dimen_569 = 569.w;
    dimen_667 = 667.w;
    dimen_510 = 510.w;
    dimen_530 = 530.w;
    dimen_580 = 580.w;
    dimen_600 = 600.w;

    subtitle1Size = 28.w;
    subtitle2Size = 22.w;
    buttonSize = 18.w;
    overlineSize = 16.w;
    captionSize = 14.w;
    fontSize14 = 14.w;
    fontSize10 = 10.w;
    fontSize18 = 18.w;

    fontSize12 = 12.w;
    fontSize28 = 28.w;
    fontSize36 = 36.w;
    fontSize16 = 16.w;
    fontSize17 = 17.w;
    fontSize22 = 22.w;
    fontSize15 = 15.w;
    fontSize11 = 11.w;
    fontSize9 = 9.w;

    bodyText1Size = 12.w;
    bodyText2Size = 10.w;
    headline1Size = 38.w;
    headline2Size = 28.w;
    headline3Size = 22.w;
    headline4Size = 18.w;
    headline5Size = 16.w;
    headline6Size = 14.w;
    mainHeadLineSize = 20.w;
    inputLabelSize = 13.w;
    cardBorderRadius = dimen_6.w;
    buttonHeight = 45.h;
    buttonBorderRadius = BorderRadius.circular(6).r;
    safeAreaSpace = 0.h;
    labelStyleTextHeight = 0.5.h;
  }

  static double getSize(double size) {
    return size * 1;
  }

  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).viewPadding;
  }

  static double screenHeight(BuildContext context, {double dividedBy = 1}) {
    return (screenSize(context).height - safeAreaSpace) / dividedBy;
  }

  static double bottomInset(BuildContext context) {
    return (MediaQuery.of(context).viewInsets.bottom);
  }

  static double screenWidth(BuildContext context, {double dividedBy = 1}) {
    return screenSize(context).width / dividedBy;
  }

  static double fullWidth(BuildContext context) {
    return screenWidth(context, dividedBy: 1);
  }

  static double halfWidth(BuildContext context) {
    return screenWidth(context, dividedBy: 2);
  }

  static double fullHeight(BuildContext context) {
    return screenHeight(context, dividedBy: 1);
  }

  static double halfHeight(BuildContext context) {
    return screenHeight(context, dividedBy: 2);
  }

  static double threeEightHeight(BuildContext context) {
    return screenHeight(context, dividedBy: 2.2);
  }

  static double quaterHeight(BuildContext context) {
    return screenHeight(context, dividedBy: 3);
  }

  static double toolbarHeight() {
    return kToolbarHeight + dimen_16;
  }
}
