import 'package:flutter/material.dart';

import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/circular_toggle_button_widget.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../base/base_screen.dart';
import '../widgets/pl_widget.dart';

class PlCashScreen extends BaseScreen {
  const PlCashScreen({Key? key}) : super(key: key);

  @override
  State<PlCashScreen> createState() => _PlCashScreenState();
}

class _PlCashScreenState extends BaseAuthScreenState<PlCashScreen> {
  final List<String> _tabs = [
    AppLocalizations().all,
    AppLocalizations().realized,
    AppLocalizations().unrealized,
  ];
  final ScrollController _scrollControllerForTopContent = ScrollController();
  final ScrollController _scrollControllerForContent = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: Theme.of(context).iconTheme,
          title: _topBar(context),
          actions: [_filterIcon()],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_15.w,
                    bottom: AppWidgetSize.dimen_20.w,
                    left: AppWidgetSize.dimen_20,
                    right: AppWidgetSize.dimen_20),
                child: Row(
                  children: [
                    _boxWidget(AppLocalizations().realizedPL, "315.00"),
                    SizedBox(width: AppWidgetSize.dimen_15),
                    _boxWidget(AppLocalizations().unrealizedPL, "-4,766.00"),
                    SizedBox(width: AppWidgetSize.dimen_15),
                    _boxWidget(AppLocalizations().overallPl, "6,033.00"),
                    SizedBox(width: AppWidgetSize.dimen_15),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              controller: _scrollControllerForTopContent,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppWidgetSize.dimen_20,
                  right: AppWidgetSize.dimen_20,
                ),
                child: CircularButtonToggleWidget(
                  value: _tabs.first,
                  toggleButtonlist: _tabs,
                  toggleButtonOnChanged: toggleButtonOnChanged,
                  marginEdgeInsets: EdgeInsets.only(
                    right: AppWidgetSize.dimen_1,
                    top: AppWidgetSize.dimen_6,
                  ),
                  paddingEdgeInsets: EdgeInsets.fromLTRB(
                    AppWidgetSize.dimen_14,
                    AppWidgetSize.dimen_6,
                    AppWidgetSize.dimen_14,
                    AppWidgetSize.dimen_6,
                  ),
                  activeButtonColor: AppUtils().isLightTheme()
                      ? Theme.of(context)
                          .snackBarTheme
                          .backgroundColor!
                          .withOpacity(0.5)
                      : Theme.of(context).primaryColor,
                  activeTextColor: AppUtils().isLightTheme()
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColorLight,
                  inactiveButtonColor: Colors.transparent,
                  inactiveTextColor: Theme.of(context).primaryColor,
                  key: const Key("options_"),
                  defaultSelected: '',
                  enabledButtonlist: const [],
                  isBorder: false,
                  context: context,
                  borderColor: Colors.transparent,
                  fontSize: 18.w,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                  controller: _scrollControllerForContent,
                  padding: EdgeInsets.symmetric(
                      horizontal: AppWidgetSize.dimen_25,
                      vertical: AppWidgetSize.dimen_10.w),
                  itemBuilder: (context, index) => const PlWidget(
                        symbol: "ARIHANTCAP",
                        companyName: "Arihant Capital Market Ltd.",
                        value: "6.32",
                        chngPer: "0.54",
                        quantity: "800",
                        plType: PLType.realized,
                        buyValue: "706.15",
                        buyAvg: "1,2706.15",
                        sellValue: "1,160.60",
                        sellAvg: "1,160.60",
                        prevCloseVal: "130",
                        marketValue: "1,160.60",
                      ),
                  separatorBuilder: (context, index) =>
                      const Divider(thickness: 1),
                  itemCount: 3),
            )
          ],
        ));
  }

  _topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: backIconButton(),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_25, right: AppWidgetSize.dimen_8),
          child: CustomTextWidget(
            AppLocalizations().cashplreport,
            Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        _infoIcon()
      ],
    );
  }

  _filterIcon() {
    return IconButton(
      icon: AppImages.filterIcon(context,
          isColor: true,
          color: Theme.of(context).primaryTextTheme.labelSmall!.color),
      onPressed: () {},
    );
  }

  _infoIcon() {
    return InkWell(
      child: AppImages.infoIcon(
        context,
        color: Theme.of(context).primaryIconTheme.color,
        isColor: true,
      ),
      onTap: () {},
    );
  }

  void toggleButtonOnChanged(String data) {
    if (_scrollControllerForTopContent.positions.isNotEmpty) {
      _scrollControllerForTopContent.animateTo(0,
          duration: const Duration(microseconds: 1), curve: Curves.ease);
    }
    if (_scrollControllerForContent.positions.isNotEmpty) {
      _scrollControllerForContent.animateTo(0,
          duration: const Duration(microseconds: 1), curve: Curves.ease);
    }
  }

  Widget _boxWidget(String label, String balance, {bool changeColor = true}) {
    return Material(
      borderRadius: BorderRadius.circular(10.w),
      elevation: 4,
      shadowColor: Theme.of(context).dividerColor,
      child: Container(
          width: 180,
          padding: EdgeInsets.symmetric(
              horizontal: AppWidgetSize.dimen_15, vertical: 15.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(
              width: 0.5.w,
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextWidget(
                    label,
                    Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                          color: Theme.of(context)
                              .inputDecorationTheme
                              .labelStyle!
                              .color,
                        ),
                  ),
                  _infoIcon()
                ],
              ),
              CustomTextWidget(
                balance,
                Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: changeColor
                          ? AppUtils().setcolorForChange(
                              AppUtils().dataNullCheck(balance))
                          : null,
                    ),
                isRupee: true,
                padding: EdgeInsets.only(top: 5.w),
              ),
              CustomTextWidget(
                "(9.11%)",
                Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                      color: Theme.of(context)
                          .inputDecorationTheme
                          .labelStyle!
                          .color,
                    ),
                padding: EdgeInsets.only(top: 4.w),
              ),
            ],
          )),
    );
  }
}
