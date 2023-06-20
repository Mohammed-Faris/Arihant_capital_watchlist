import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../config/app_config.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/keys/orderpad_keys.dart';
import '../../../constants/storage_constants.dart';
import '../../../data/store/app_storage.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/info_bottomsheet.dart';
import '../../widgets/webview_widget.dart';
import '../route_generator.dart';

class OrderPadInfo {
  static Future<void> showInformationIconBottomSheet(
      BuildContext context) async {
    AppLocalizations appLocalizations = AppLocalizations();

    InfoBottomSheet.showInfoBottomsheet(SafeArea(child: StatefulBuilder(
      builder: (BuildContext context, StateSetter updateState) {
        List<Widget> informationWidgetList = [
          _buildExpansionRowForBottomSheetPlaceOrder(
            context,
            updateState,
            appLocalizations.placingOrder,
            appLocalizations.placingOrdertext1,
            appLocalizations.placingOrdertext2,
            appLocalizations.placingOrdertext3,
            appLocalizations.placingOrdertext4_1,
            appLocalizations.placingOrdertext4_2,
            appLocalizations.placingOrdertext4_3,
            appLocalizations.placingOrdertext4_4,
            appLocalizations.placingOrdertextNote,
            appLocalizations.placingOrdertext5,
            appLocalizations.placingOrdertext6,
            appLocalizations.placingOrdertext7,
          ),
          Divider(
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          _buildExpansionRowForBottomSheetRegular(
            context,
            appLocalizations.regularOrder,
            appLocalizations.regularOrdertext1,
            appLocalizations.regularTypes,
            appLocalizations.mktOdr,
            appLocalizations.regularOrdertext2,
            appLocalizations.lmtOdr,
            appLocalizations.regularOrdertext3,
          ),
          Divider(
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          _buildExpansionRowForBottomSheetCover(
            context,
            appLocalizations.coverOrder,
            appLocalizations.cvrDesctext,
            appLocalizations.cvrDesctext1_1,
            appLocalizations.stopLossTrigger,
            appLocalizations.cvrDesctext1_3,
            appLocalizations.cvrDesctext2,
            appLocalizations.cvrDesctext3,
            appLocalizations.cvrDesctext4,
          ),
          Divider(
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          _buildExpansionRowForBottomSheetBracket(
            context,
            appLocalizations.bracketOrder,
            appLocalizations.bracOrdDesc,
            appLocalizations.bracOrdDesc1,
            appLocalizations.bracSubDesc1,
            appLocalizations.bracSubDesc2,
            appLocalizations.bracSubDesc3,
            appLocalizations.bracOrdDesc2,
            appLocalizations.bracOrdDesc3,
            appLocalizations.bracOrdDesc4,
          ),
        ];
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 22.w,
                  left: 24.w,
                  bottom: 10.w,
                  right: 24.w,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      appLocalizations.orderDetails,
                      Theme.of(context).primaryTextTheme.titleMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: AppImages.closeIcon(
                        context,
                        width: 20.w,
                        height: 20.w,
                        color: Theme.of(context).primaryIconTheme.color,
                        isColor: true,
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                color: Theme.of(context).dividerColor,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24.w,
                    right: 24.w,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          primary: false,
                          shrinkWrap: true,
                          itemCount: informationWidgetList.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return informationWidgetList[index];
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    )), context, horizontalMargin: false, topMargin: false);
  }

  static Future<void> tgPriceInformationIconBottomSheet(
      BuildContext context) async {
    AppLocalizations appLocalizations = AppLocalizations();

    List<Widget> informationWidgetList = [
      _buildExpansionRowForBottomSheetTP(
        context,
        appLocalizations.sl,
        appLocalizations.tgDesc,
        appLocalizations.tgDesc1,
        appLocalizations.tgDesc2,
      ),
    ];
    InfoBottomSheet.showInfoBottomsheet(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  appLocalizations.triggerPrice,
                  Theme.of(context).primaryTextTheme.titleMedium,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: AppImages.closeIcon(
                    context,
                    width: 20.w,
                    height: 20.w,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true,
                  ),
                )
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 20.w,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        primary: false,
                        shrinkWrap: true,
                        itemCount: informationWidgetList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return informationWidgetList[index];
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        context);
  }

  //bottomsheet for Information icon
  static Widget _buildExpansionRowForBottomSheetPlaceOrder(
    BuildContext context,
    StateSetter updateState,
    String title,
    String description1,
    String description2,
    String description3,
    String description4_1,
    String description4_2,
    String description4_3,
    String description4_4,
    String description5,
    String description6,
    String description7,
    String description8,
  ) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        expandedAlignment: Alignment.centerLeft,
        initiallyExpanded: true,
        // onExpansionChanged: (bool val) {
        //   regordExp = false;
        //   updateState(() {});
        // },
        tilePadding: EdgeInsets.only(
          right: 0,
          left: 0,
          bottom: 5.w,
        ),
        collapsedIconColor: Theme.of(context).primaryIconTheme.color,
        title: CustomTextWidget(
          title,
          Theme.of(context).textTheme.displaySmall,
        ),
        iconColor: Theme.of(context).primaryIconTheme.color,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 10.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                  "Here’s how to place your buy or sell order. ",
                  Theme.of(context).primaryTextTheme.labelSmall,
                  textAlign: TextAlign.start),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: CustomTextWidget(
              'Step 1: ',
              Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  text: description1,
                  style: Theme.of(context).primaryTextTheme.labelSmall,
                  children: [
                    WidgetSpan(
                        child: Padding(
                      padding: EdgeInsets.only(
                          left: AppWidgetSize.dimen_4,
                          top: AppWidgetSize.dimen_5),
                      child: AppImages.buysellIcon(
                        context,
                      ),
                    )),
                    const TextSpan(text: " .")
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                'Step 2: ',
                Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "If the market is Live, you will see a green dot ",
                      style: Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                    WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: AppImages.liveIcon(context)),
                    TextSpan(
                      text:
                          " along with the stock prices on both exchanges. The stock price on both the exchanges is shown and you can choose the exchange you want to trade on.",
                      style: Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                'Step 3: ',
                Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                description3,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                'Step 4: ',
                Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(
                top: 5.w,
              ),
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(children: [
                  TextSpan(
                    text: description4_1,
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                  TextSpan(
                    text: description4_2,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .labelSmall!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: description4_3,
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                  TextSpan(
                      text: description4_4,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(fontWeight: FontWeight.w600))
                ]),
              )),
          Padding(
            padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
            child: CustomTextWidget(
              description5,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                'Step 5: ',
                Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: CustomTextWidget(
              description6,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                'Step 6: ',
                Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                top: 5.w,
              ),
              child: CustomTextWidget(
                description7,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                'Step 7: ',
                Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(
                top: 5.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Choose ",
                            style:
                                Theme.of(context).primaryTextTheme.labelSmall,
                          ),
                          TextSpan(
                            text: "Advanced Options,",
                            style: Theme.of(context)
                                .primaryTextTheme
                                .labelSmall!
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text:
                                "if you need additional options for placing the order like validity (IOC, GTD) or want to place a stop loss order. You will have to input additional information like Trigger Price, according to the type of order. You can set the trigger price in both absolute terms ",
                            style:
                                Theme.of(context).primaryTextTheme.labelSmall,
                          ),
                          TextSpan(
                            text: "(₹)",
                            style: Theme.of(context)
                                .primaryTextTheme
                                .labelSmall!
                                .copyWith(fontFamily: AppConstants.interFont),
                          ),
                          TextSpan(
                            text:
                                "or as a percentage change from the price. You can also choose to disclose your order partially or place an After Market Order (AMO) here.",
                            style:
                                Theme.of(context).primaryTextTheme.labelSmall,
                          )
                        ],
                      )),
                  Wrap(
                    children: [
                      CustomTextWidget("To know more about disclosing trades,",
                          Theme.of(context).primaryTextTheme.labelSmall,
                          textAlign: TextAlign.left),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            SlideRoute(
                                settings: const RouteSettings(
                                  name: ScreenRoutes.inAppWebview,
                                ),
                                builder: (BuildContext context) =>
                                    WebviewWidget("Need Help",
                                        AppConfig.boUrls![11]["value"])),
                          );
                        },
                        child: CustomTextWidget(
                            "click here.",
                            Theme.of(context)
                                .primaryTextTheme
                                .labelSmall!
                                .copyWith(
                                    decoration: TextDecoration.underline,
                                    color: Theme.of(context).primaryColor),
                            textAlign: TextAlign.left),
                      )
                    ],
                  )
                ],
              )),
        ],
      ),
    );
  }

  static Widget _buildExpansionRowForBottomSheetRegular(
    BuildContext context,
    String title,
    String description1,
    String description2,
    String description3,
    String description4,
    String description5,
    String description6,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: 5.w,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
            title,
            Theme.of(context).textTheme.displaySmall,
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              description1,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                  child: CustomTextWidget(
                    description2,
                    Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 5.w,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomTextWidget(
                  description3,
                  Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 5.w,
              ),
              child: CustomTextWidget(
                description4,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 5.w,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomTextWidget(
                  description5,
                  Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                  top: 5.w,
                ),
                child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(children: [
                      TextSpan(
                        text:
                            "A limit order is when you want to buy or sell a stock at a fixed price. You can place a limit order by entering your desired quantity and clicking on ",
                        style: Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                      TextSpan(
                        text: "“Custom Price”",
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            "(within the daily price range set by the exchange for that stock). You should know that limit orders aren't guaranteed to execute. There must be a buyer and seller on both sides of the trade. If there aren't enough shares in the market at your limit price, it may take multiple trades to fill the entire order, or the order may not be filled at all.",
                        style: Theme.of(context).primaryTextTheme.labelSmall,
                      )
                    ]))),
          ],
        ),
      ),
    );
  }

  static Widget _buildExpansionRowForBottomSheetCover(
    BuildContext context,
    String title,
    String description1,
    String description2_1,
    String description2_2,
    String description2_3,
    String description3,
    String description4,
    String description5,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: 5.w,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
            title,
            Theme.of(context).textTheme.displaySmall,
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              description1,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
                padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
                child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(children: [
                      TextSpan(
                        text: description2_1,
                        style: Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                      TextSpan(
                        text: description2_2,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: description2_3,
                        style: Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                    ]))),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
              child: CustomTextWidget(
                description3,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
              child: CustomTextWidget(
                description4,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomTextWidget(
                  description5,
                  Theme.of(context).primaryTextTheme.labelSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
//bottomsheet for SL & SL-M

  static Future<void> showSlSlmInformationBottomSheet(
      BuildContext context) async {
    AppStorage().setData(orderTypeBottomSheetShown, true);
    AppLocalizations appLocalizations = AppLocalizations();

    InfoBottomSheet.showInfoBottomsheet(
        SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 30.w,
              right: 30.w,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: AppImages.closeIcon(
                        context,
                        width: 20.w,
                        height: 20.w,
                        color: Theme.of(context).primaryIconTheme.color,
                        isColor: true,
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 20.w,
                  ),
                  child: CustomTextWidget(
                    appLocalizations.forSlSlm,
                    Theme.of(context).primaryTextTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 20.w,
                    bottom: 20.w,
                  ),
                  child: Center(
                    child: CustomTextWidget(appLocalizations.slSlmDescription,
                        Theme.of(context).primaryTextTheme.labelLarge,
                        textAlign: TextAlign.center),
                  ),
                ),
                gradientButtonWidget(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  width: AppWidgetSize.fullWidth(context) / 2.3,
                  key: const Key(orderpadOkButtonKey),
                  context: context,
                  title: appLocalizations.ok,
                  isGradient: true,
                ),
              ],
            ),
          ),
        ),
        context,
        horizontalMargin: false);
  }

  static Widget _buildExpansionRowForBottomSheetBracket(
    BuildContext context,
    String title,
    String description1,
    String description2,
    String description3,
    String description4,
    String description5,
    String description6,
    String description7,
    String description8,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: 5.w,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
            title,
            Theme.of(context).textTheme.displaySmall,
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              description1,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                  child: CustomTextWidget(
                    description2,
                    Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.w,
                    left: AppWidgetSize.dimen_16,
                    right: 4.w,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: AppWidgetSize.dimen_6,
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      description3,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.w,
                    left: AppWidgetSize.dimen_16,
                    right: 4.w,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: AppWidgetSize.dimen_6,
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text: "A corresponding stop-loss order (2",
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                            TextSpan(
                              text: "\u207f" "\u1d48",
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(
                                      fontFamily: AppConstants.interFont,
                                      fontFeatures: [
                                    (const FontFeature.superscripts())
                                  ]),
                            ),
                            TextSpan(
                              text: " leg)",
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            )
                          ]))),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.w,
                    left: AppWidgetSize.dimen_16,
                    right: 4.w,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: AppWidgetSize.dimen_6,
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text:
                                  "A corresponding profit objective limit order (3",
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                            TextSpan(
                              text: "\u02b3" "\u1d48",
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(
                                      fontFamily: AppConstants.interFont,
                                      fontFeatures: [
                                    (const FontFeature.superscripts())
                                  ]),
                            ),
                            TextSpan(
                              text: " leg)",
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            )
                          ]))),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "If the stop loss trigger price is hit, the stop loss order gets executed as a market order and the 3rd leg (the profit objective order) automatically gets cancelled. Similarly, if the profit objective trigger price gets hit, the 2",
                      style: Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                    TextSpan(
                      text: "\u207f" "\u1d48",
                      style: Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(
                        fontFamily: AppConstants.interFont,
                        fontFeatures: [(const FontFeature.superscripts())],
                      ),
                    ),
                    TextSpan(
                      text:
                          " leg stop loss automatically gets cancelled. If the condition for the two limit trades is not met by 3:15pm, the order is automatically squared off (unless its manually closed by the trader).",
                      style: Theme.of(context).primaryTextTheme.labelSmall,
                    )
                  ],
                ),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
            //   child: CustomTextWidget(
            //     description7,
            //     Theme.of(context).primaryTextTheme.overline,
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  text:
                      'For placing a bracket order, you need to specify a trigger price (in ',
                  style: Theme.of(context).primaryTextTheme.labelSmall,
                  children: <TextSpan>[
                    TextSpan(
                      text: AppConstants.rupeeSymbol,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(fontFamily: AppConstants.interFont),
                    ),
                    TextSpan(
                        text: 'or in %), the limit price, target price ',
                        style: Theme.of(context).primaryTextTheme.labelSmall),

                    TextSpan(
                        text: 'stop loss price',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: ' (your floor price) and the ',
                        style: Theme.of(context).primaryTextTheme.labelSmall),
                    //
                    TextSpan(
                        text: 'target price',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            ' (your ceiling price). You can also choose to add a trailing stop loss here.',
                        style: Theme.of(context).primaryTextTheme.labelSmall),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: CustomTextWidget(
                description8,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(children: [
                      TextSpan(
                          text: "Learn more",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .copyWith(
                                  decoration: TextDecoration.underline,
                                  color: Theme.of(context).primaryColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                SlideRoute(
                                    settings: const RouteSettings(
                                      name: ScreenRoutes.inAppWebview,
                                    ),
                                    builder: (BuildContext context) =>
                                        WebviewWidget("Need Help",
                                            AppConfig.boUrls![12]["value"])),
                              );
                            }),
                      TextSpan(
                        text: " here.",
                        style: Theme.of(context).primaryTextTheme.labelSmall,
                      )
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildExpansionRowForBottomSheetTP(
    BuildContext context,
    String title,
    String description,
    String description1,
    String description2,
  ) {
    AppLocalizations appLocalizations = AppLocalizations();

    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: Column(
          children: [
            // AppImages.stoplossIcon(context),
            Image.asset("lib/assets/images/stop_loss.png"), //testimage
            CustomTextWidget(
              description,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: CustomTextWidget(
                description1,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: CustomTextWidget(
                description2,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CustomTextWidget(
                    '1) ',
                    Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: CustomTextWidget(
                    appLocalizations.tgDesc3,
                    Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CustomTextWidget(
                    '2) ',
                    Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: CustomTextWidget(
                    appLocalizations.tgDesc4,
                    Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                ),

                //tgDesc5
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CustomTextWidget(
                appLocalizations.tgDesc5,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideRoute(
                            settings: const RouteSettings(
                              name: ScreenRoutes.inAppWebview,
                            ),
                            builder: (BuildContext context) => WebviewWidget(
                                "Need Help", AppConfig.boUrls![15]["value"])),
                      );
                    },
                    child: CustomTextWidget(
                      appLocalizations.learnMore,
                      Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                  CustomTextWidget(
                    " about trigger price.",
                    Theme.of(context).primaryTextTheme.labelSmall,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  static Future<void> advancedInformationIconBottomSheet(
      BuildContext context) async {
    AppLocalizations appLocalizations = AppLocalizations();
    List<Widget> informationWidgetList = [
      _buildExpansionRowForBottomSheetSL(
          context,
          appLocalizations.sl,
          appLocalizations.slOrderDespText,
          appLocalizations.slOrderDespText1,
          appLocalizations.slOrderDespText2,
          appLocalizations.slOrderDespText3),
      Divider(
        thickness: 1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowForBottomSheetSLM(
        context,
        appLocalizations.slm,
        appLocalizations.slMOrderDespText,
        appLocalizations.slMOrderDespText1,
        appLocalizations.clickhere,
        appLocalizations.slMOrderDespText2,
      ),
      Divider(
        thickness: 1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowForBottomSheetValidty(
        context,
        appLocalizations.validity,
        appLocalizations.validtyDesc1,
        appLocalizations.validtyDesc2,
        appLocalizations.validtyDesc3,
      ),
      Divider(
        thickness: 1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowForBottomSheetAMO(
        context,
        appLocalizations.amo,
        appLocalizations.amoDesc1,
        appLocalizations.amoDesc2,
        appLocalizations.amoDesc3,
      ),
      Divider(
        thickness: 1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowForBottomSheetDQTY(
        context,
        appLocalizations.disclosedQty,
        appLocalizations.dQtyDesc,
        appLocalizations.dQtyDesc1,
        appLocalizations.dQtyDesc2,
        appLocalizations.dQtyDesc3,
      ),
    ];
    InfoBottomSheet.showInfoBottomsheet(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 32.w,
                left: 24.w,
                right: 24.w,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextWidget(
                    appLocalizations.advancedOptions,
                    Theme.of(context).primaryTextTheme.titleMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: AppImages.closeIcon(
                      context,
                      width: 20.w,
                      height: 20.w,
                      color: Theme.of(context).primaryIconTheme.color,
                      isColor: true,
                    ),
                  )
                ],
              ),
            ),
            // Divider(
            //   thickness: 1,
            //   color: Theme.of(context).dividerColor,
            // ),
            Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomTextWidget(
                  AppLocalizations().advOptDesc,
                  Theme.of(context).primaryTextTheme.labelSmall,
                ),
              ),
            ),
            Divider(
              thickness: 1,
              color: Theme.of(context).dividerColor,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24.w,
                  right: 24.w,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        primary: false,
                        shrinkWrap: true,
                        itemCount: informationWidgetList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return informationWidgetList[index];
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        context,
        horizontalMargin: false,
        topMargin: false);
  }

  static Widget _buildExpansionRowForBottomSheetSLM(
    BuildContext context,
    String title,
    String description1,
    String description2,
    String description2_1,
    String description3,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: 5.w,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
            title,
            Theme.of(context).textTheme.displaySmall,
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              description1,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: description2,
                            style:
                                Theme.of(context).primaryTextTheme.labelSmall,
                          ),
                          TextSpan(
                            text: description2_1,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .labelSmall!
                                .copyWith(
                                    decoration: TextDecoration.underline,
                                    color: Theme.of(context).primaryColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  SlideRoute(
                                      settings: const RouteSettings(
                                        name: ScreenRoutes.inAppWebview,
                                      ),
                                      builder: (BuildContext context) =>
                                          WebviewWidget("Need Help",
                                              AppConfig.boUrls![13]["value"])),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        children: [
                          WidgetSpan(
                              child: //AppImages.stopIcon(context),//testimage
                                  Image.asset(
                                      "lib/assets/images/stop_emoji.png",
                                      height: 30.w)),
                          TextSpan(
                            text: description3,
                            style:
                                Theme.of(context).primaryTextTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildExpansionRowForBottomSheetValidty(
    BuildContext context,
    String title,
    String description1,
    String description2,
    String description3,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          expandedAlignment: Alignment.centerLeft,
          tilePadding: EdgeInsets.only(
            right: 0,
            bottom: 5.w,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
            title,
            Theme.of(context).textTheme.displaySmall,
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    '${AppLocalizations().day} :',
                    Theme.of(context).textTheme.headlineMedium,
                  ),
                  CustomTextWidget(
                    description1,
                    Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 5.w,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomTextWidget(
                      'IOC :',
                      Theme.of(context).textTheme.headlineMedium,
                    ),
                    CustomTextWidget(
                      description2,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 5.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    'GTD :',
                    Theme.of(context).textTheme.headlineMedium,
                  ),
                  CustomTextWidget(
                    description3,
                    Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildExpansionRowForBottomSheetAMO(
    BuildContext context,
    String title,
    String description1,
    String description2,
    String description3,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: 5.w,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
            title,
            Theme.of(context).textTheme.displaySmall,
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              description1,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      description2,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      description3,
                      Theme.of(context).primaryTextTheme.labelSmall,
                      onTap: (e) {
                        Navigator.push(
                          context,
                          SlideRoute(
                              settings: const RouteSettings(
                                name: ScreenRoutes.inAppWebview,
                              ),
                              builder: (BuildContext context) => WebviewWidget(
                                  AppLocalizations().amo,
                                  AppConfig.boUrls![14]["value"])),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildExpansionRowForBottomSheetDQTY(
    BuildContext context,
    String title,
    String description1,
    String description2,
    String description3,
    String description4,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: 5.w,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
            title,
            Theme.of(context).textTheme.displaySmall,
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              description1,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      description2,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      description3,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      description4,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildExpansionRowForBottomSheetSL(
    BuildContext context,
    String title,
    String description1,
    String description2,
    String description3,
    String description4,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: 5.w,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
            title,
            Theme.of(context).textTheme.displaySmall,
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              description1,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      description2,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      description3,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      description4,
                      Theme.of(context).primaryTextTheme.labelSmall!,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
