import 'dart:async';

import 'package:acml/src/localization/app_localization.dart';
import 'package:acml/src/ui/styles/app_images.dart';
import 'package:acml/src/ui/styles/app_widget_size.dart';
import 'package:acml/src/ui/widgets/refresh_widget.dart';
import 'package:flutter/material.dart';

import '../../../data/store/app_utils.dart';
import '../../widgets/card_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/totp/totp.dart';
import '../base/base_screen.dart';

class Totp extends BaseScreen {
  const Totp({Key? key}) : super(key: key);

  @override
  State<Totp> createState() => _TotpState();
}

class _TotpState extends BaseAuthScreenState<Totp> {
  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final code3 = OTP.generateTOTPCodeString(
          'JBSWY3DPEHPK3PXP', DateTime.now().millisecondsSinceEpoch,
          interval: 30, algorithm: Algorithm.SHA512);
      codeGenerated.value = code3;
    });
    super.initState();
  }

  ValueNotifier<bool> isScrolledToTop = ValueNotifier<bool>(false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: backIconButton(),
            ),
            Padding(
              padding: EdgeInsets.only(left: AppWidgetSize.dimen_25),
              child: CustomTextWidget(
                "TOTP Authentication",
                Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        toolbarHeight: AppWidgetSize.dimen_60,
      ),
      resizeToAvoidBottomInset: true,
      body: RefreshWidget(
        onRefresh: () {},
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              ValueListenableBuilder<bool>(
                  valueListenable: isScrolledToTop,
                  builder: (context, value, _) {
                    return _buildCodewidget();
                  }),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25.w),
                padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_5,
                    right: AppWidgetSize.dimen_5,
                    bottom: AppWidgetSize.dimen_15),
                child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(0),
                    shrinkWrap: true,
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildStepswidget(
                        index,
                      );
                    }),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15.w, top: 20.w),
                child: gradientButtonWidget(
                    onTap: () async {},
                    width: 120.w,
                    key: const Key(""),
                    context: context,
                    bottom: 0,
                    title: AppLocalizations().disableTotp,
                    isGradient: false,
                    height: 40.w,
                    isErrorButton: true,
                    backgroundcolor: Theme.of(context).colorScheme.error,
                    fontsize: 16.w),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepswidget(
    int index,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepbullet(
          index,
        ),
        _buildstepContent(
          index,
        ),
      ],
    );
  }

  List totpSteps = [
    AppLocalizations().totpStep1,
    AppLocalizations().totpStep2,
    AppLocalizations().totpStep3,
    AppLocalizations().totpStep4
  ];

  Widget _buildstepContent(
    int index,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_15,
      ),
      child: SizedBox(
        width: (AppWidgetSize.fullWidth(context) - 250.w),
        child: CustomTextWidget(
            totpSteps[index],
            Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w400,
                ),
            textAlign: TextAlign.left),
      ),
    );
  }

  Widget _buildStepbullet(
    int index,
  ) {
    return Column(
      children: [
        CustomTextWidget(
            "•",
            Theme.of(context)
                .primaryTextTheme
                .bodySmall!
                .copyWith(fontWeight: FontWeight.w900, fontSize: 18.w)),
        if (index < totpSteps.length - 1)
          SizedBox(
            height: 45.w,
            child: VerticalDivider(
              width: 1.5,
              thickness: 1.5,
              color: Theme.of(context).dividerColor,
            ),
          ),
      ],
    );
  }

  ValueNotifier<String> codeGenerated = ValueNotifier<String>('');

  Widget _buildCodewidget() {
    return SizedBox(
      height: (AppUtils.isTablet ? 230.w : 280.w) + (70.w),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          _buildDescwidget(),
          ValueListenableBuilder<String>(
              valueListenable: codeGenerated,
              builder: (context, value, _) {
                return _buildCodedisplayWidget(code: value);
              }),
          StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Padding(
                  padding: EdgeInsets.only(
                      top: AppWidgetSize.dimen_110, left: 80.w, right: 80.w),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbColor: Colors.transparent,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 0.0)),
                          child: Slider(
                            value:
                                OTP.remainingSeconds(interval: 30).toDouble(),
                            max: 30,
                            min: 0,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (double value) {},
                          ),
                        ),
                        CustomTextWidget(
                            OTP.remainingSeconds(interval: 30).toString(),
                            Theme.of(context)
                                .primaryTextTheme
                                .bodySmall!
                                .copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).primaryColor))
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _buildDescwidget() {
    return Container(
      height: 240.w,
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_40),
      color: Theme.of(context).snackBarTheme.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: AppWidgetSize.screenWidth(context),
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              AppLocalizations().totpDesc,
              style: TextStyle(
                fontSize: 17.w,
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Positioned _buildCodedisplayWidget({String? code}) {
    return Positioned(
      bottom: 50.w,
      child: CardWidget(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          alignment: Alignment.center,
          child: code != ""
              ? Container(
                  margin: EdgeInsets.symmetric(vertical: 10.w),
                  padding:
                      EdgeInsets.symmetric(horizontal: 25.w, vertical: 7.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomTextWidget(
                          codeGenerated.value,
                          Theme.of(context)
                              .primaryTextTheme
                              .bodySmall!
                              .copyWith(
                                  fontWeight: FontWeight.w500, fontSize: 20.w)),
                      Padding(
                        padding:
                            EdgeInsets.only(right: 15.w, left: 15.w, top: 25.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            iconButton(
                                AppLocalizations().resetCode,
                                AppImages.refreshIcon(context,
                                    isColor: true,
                                    height: 18.w,
                                    color: Theme.of(context).colorScheme.error),
                                Theme.of(context).colorScheme.error),
                            iconButton(
                                AppLocalizations().copyCode,
                                AppImages.copyIcon(context,
                                    height: 18.w,
                                    isColor: true,
                                    color: Theme.of(context).primaryColor),
                                Theme.of(context).primaryColor),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : Container(
                  margin: EdgeInsets.symmetric(vertical: 10.w),
                  padding:
                      EdgeInsets.symmetric(horizontal: 25.w, vertical: 5.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        AppLocalizations().generateotpDesc,
                        style: TextStyle(fontSize: 17.w),
                      ),
                      SizedBox(
                        height: 15.w,
                      ),
                      gradientButtonWidget(
                          key: const Key(""),
                          onTap: () {
                            // codeGenerated.value = !codeGenerated.value;
                          },
                          bottom: 0,
                          width: AppWidgetSize.dimen_200,
                          context: context,
                          title: AppLocalizations().generateOtp,
                          isGradient: true,
                          height: 40.w,
                          fontsize: 18.w),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  TextButton iconButton(String name, Widget icon, Color color) {
    return TextButton.icon(
        onPressed: () {},
        icon: icon,
        label: CustomTextWidget(
            name,
            Theme.of(context)
                .primaryTextTheme
                .bodySmall!
                .copyWith(fontWeight: FontWeight.w400, color: color)));
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}
