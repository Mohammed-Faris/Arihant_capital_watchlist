import 'package:flutter/material.dart';

import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/circular_toggle_button_widget.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../base/base_screen.dart';

enum LedgerType { fundsAdded, fundsWithDrawn, tradesExecuted, otherCharges }

class ArihantLedgerScreen extends BaseScreen {
  const ArihantLedgerScreen({Key? key}) : super(key: key);

  @override
  State<ArihantLedgerScreen> createState() => _ArihantLedgerScreenState();
}

class _ArihantLedgerScreenState
    extends BaseAuthScreenState<ArihantLedgerScreen> {
  final List<String> _tabs = ["All", "Funds", "Trades Executed", "Dp Charges"];
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
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_15.w,
                  bottom: AppWidgetSize.dimen_20.w,
                  left: AppWidgetSize.dimen_25,
                  right: AppWidgetSize.dimen_25),
              child: Row(
                children: [
                  _balanceWidget(
                      AppLocalizations().openingBalance, "39,99,456"),
                  SizedBox(width: AppWidgetSize.dimen_15),
                  _balanceWidget(AppLocalizations().closingBalance, "39,99,456",
                      changeColor: false)
                ],
              ),
            ),
            SingleChildScrollView(
              controller: _scrollControllerForTopContent,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_25,
                    right: AppWidgetSize.dimen_25,
                    bottom: AppWidgetSize.dimen_10),
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
                itemBuilder: (context, index) => _listTile(),
                separatorBuilder: (context, index) =>
                    const Divider(thickness: 1),
                itemCount: 3,
              ),
            )
          ],
        ));
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

  // Tab _tab(String label, {String? count}) {
  //   return Tab(
  //       child: Row(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       CustomTextWidget(
  //         label,
  //         Theme.of(context).textTheme.headlineSmall!.copyWith(
  //               color: AppUtils().isLightTheme()
  //                   ? Theme.of(context).primaryColor
  //                   : Theme.of(context).primaryColorLight,
  //               fontSize: 18.w,
  //               fontWeight: FontWeight.w500,
  //             ),
  //       ),
  //       if (count != null && count.isNotEmpty) _badge(count)
  //     ],
  //   ));
  // }

  double _getBadgeSize(int length) {
    if (length <= 1) {
      return 20;
    } else {
      return length * 12;
    }
  }

  Widget _badge(String? label) {
    return Padding(
      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
      child: Container(
        height: AppWidgetSize.dimen_20,
        width: _getBadgeSize(label!.length),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: CustomTextWidget(
            label,
            Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).primaryColorLight,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }

  _listTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
      horizontalTitleGap: 2,
      leading: AppImages.fundsEnabled(context),
      title: CustomTextWidget(
          "Funds added",
          Theme.of(context)
              .textTheme
              .headlineMedium!
              .copyWith(fontWeight: FontWeight.w500)),
      subtitle: CustomTextWidget(
        "05 Mar 2022",
        padding: EdgeInsets.only(top: 5.w),
        Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Theme.of(context).inputDecorationTheme.labelStyle!.color,
            ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomTextWidget(
                "5,544",
                Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppUtils()
                          .setcolorForChange(AppUtils().dataNullCheck("5,544")),
                    ),
                isRupee: true,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextWidget(
                    "Bal: ",
                    Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Theme.of(context)
                              .inputDecorationTheme
                              .labelStyle!
                              .color,
                        ),
                    padding: EdgeInsets.only(top: 5.w),
                  ),
                  CustomTextWidget(
                    "-5,544",
                    Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Theme.of(context)
                              .inputDecorationTheme
                              .labelStyle!
                              .color,
                        ),
                    isRupee: true,
                    padding: EdgeInsets.only(top: 5.w),
                  ),
                ],
              )
            ],
          ),
          SizedBox(width: AppWidgetSize.dimen_10),
          AppImages.rightArrowIos(context),
        ],
      ),
      onTap: () {
        _showDetail(LedgerType.fundsAdded);
      },
    );
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
            AppLocalizations().arihantLedger,
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

  Widget _balanceWidget(String label, String balance,
      {bool changeColor = true}) {
    return Expanded(
      child: Material(
        borderRadius: BorderRadius.circular(10.w),
        elevation: 4,
        shadowColor: Theme.of(context).dividerColor,
        child: Container(
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
                )
              ],
            )),
      ),
    );
  }

  void _showDetail(LedgerType type) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
        isScrollControlled: false,
        enableDrag: false,
        isDismissible: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppWidgetSize.dimen_20),
              topRight: Radius.circular(AppWidgetSize.dimen_20)),
        ),
        builder: (BuildContext ctx) => _sheetBuilder(type));
  }

  Widget _sheetBuilder(LedgerType type) {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_30,
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20),
      child: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextWidget(
                    _getLabel(type),
                    Theme.of(context).textTheme.displaySmall!,
                  ),
                  InkWell(
                    child: AppImages.close(
                      context,
                      color: Theme.of(context).primaryIconTheme.color,
                      isColor: true,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              CustomTextWidget(
                "3,983",
                Theme.of(context)
                    .primaryTextTheme
                    .displayMedium!
                    .copyWith(fontWeight: FontWeight.w600),
                isRupee: true,
                padding: EdgeInsets.only(top: 15.w, bottom: 10.w),
              ),
              CustomTextWidget(
                "Being amount received as on AXIS UPI 112231232312",
                Theme.of(context).textTheme.bodySmall!,
                padding: EdgeInsets.only(bottom: 10.w),
              ),
              if (type == LedgerType.fundsAdded) _detailItems("From", "UPI"),
              if (type == LedgerType.fundsWithDrawn)
                _detailItems("To", "Axis Bank"),
              _detailItems("Exchange", "NSE"),
              if (type == LedgerType.tradesExecuted ||
                  type == LedgerType.otherCharges)
                _detailItems("Book Type", "Normal"),
              if (type == LedgerType.tradesExecuted ||
                  type == LedgerType.otherCharges)
                _detailItems("Settlement No", "2021105"),
              if (type == LedgerType.fundsAdded)
                _detailItems("Transaction No", "2323235454"),
              _detailItems("Transaction Date", "12 Jan 2023"),
              _detailItems("Transaction Time", "2:03 PM"),
              _detailItems("Internal Reference ID", "JVAC89340234",
                  showCopy: true),
              _needHelpWidget()
            ]),
      ),
    );
  }

  _needHelpWidget() {
    return SizedBox(
      height: 70.w,
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppWidgetSize.dimen_4),
            child: CustomTextWidget(
              AppLocalizations().generalNeedHelp,
              Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailItems(String label, String? info, {bool showCopy = false}) {
    return Padding(
      padding: EdgeInsets.only(top: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
            label,
            Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color:
                      Theme.of(context).inputDecorationTheme.labelStyle!.color,
                ),
          ),
          if (!showCopy)
            CustomTextWidget(
              info ?? "--",
              Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextWidget(
                  info ?? "--",
                  Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const Icon(Icons.copy),
              ],
            )
        ],
      ),
    );
  }

  String _getLabel(LedgerType type) {
    switch (type) {
      case LedgerType.fundsAdded:
        return "Funds Added";
      case LedgerType.fundsWithDrawn:
        return "Funds Withdrawn";
      case LedgerType.tradesExecuted:
        return "Trades Executed";
      case LedgerType.otherCharges:
        return "Other Charges";
      default:
        return "--";
    }
  }
}
