import 'package:flutter/material.dart';

import '../../../config/app_config.dart';
import '../../../constants/app_constants.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/webview_widget.dart';
import '../route_generator.dart';

// ignore: must_be_immutable
class WatchlistInformationScreen extends StatelessWidget {
  WatchlistInformationScreen({Key? key}) : super(key: key);

  late AppLocalizations _appLocalizations;

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Scaffold(
          body: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(context), body: _buildBottomContent(context));
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: false,
      toolbarHeight: AppWidgetSize.dimen_60,
      elevation: 0.0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: CustomTextWidget(
        _appLocalizations.watchlists,
        Theme.of(context)
            .textTheme
            .displaySmall!
            .copyWith(fontWeight: FontWeight.w600),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.only(
              right: 20.w,
            ),
            child: AppImages.closeIcon(context,
                width: 20.w,
                height: 20.w,
                color: Theme.of(context).primaryIconTheme.color,
                isColor: true),
          ),
        )
      ],
    );
  }

  Widget _buildBottomContent(BuildContext context) {
    List<Widget> informationWidgetList = [
      _buildExpansionRow(
        context,
        _appLocalizations.watchlistInfoQue1,
        _appLocalizations.watchlistInfoAns1,
        false,
      ),
      Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowQue2(
        context,
        _appLocalizations.watchlistInfoQue2_1,
      ),
      Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowQue3(
        context,
        _appLocalizations.watchlistInfoQue3_1,
      ),
      Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowQue4(
        context,
        _appLocalizations.watchlistInfoQue4,
      ),
      Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowQue5(
        context,
        _appLocalizations.watchlistInfoQue5,
      ),
      Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowQue6(
        context,
        _appLocalizations.watchlistInfoQue6,
      ),
      Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
    ];
    return Container(
      padding: EdgeInsets.only(
        left: 30.w,
        right: 30.w,
      ),
      color: Theme.of(context).scaffoldBackgroundColor,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildExpansionRow(
      BuildContext context, String title, String description, bool isRichText) {
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
              title, Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.left),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
                description, Theme.of(context).primaryTextTheme.labelSmall,
                textAlign: TextAlign.justify),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionRowQue2(BuildContext context, String title) {
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
          title: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: Theme.of(context).textTheme.displaySmall,
              children: [
                TextSpan(text: _appLocalizations.watchlistInfoQue2_1),
                WidgetSpan(
                    child: SizedBox(
                  height: AppWidgetSize.dimen_22,
                  child: AppImages.addUnfilledIcon(context,
                      isColor: true, color: Theme.of(context).primaryColor),
                )),
                TextSpan(text: _appLocalizations.watchlistInfoQue2_2),
                WidgetSpan(
                    child: SizedBox(
                  height: AppWidgetSize.dimen_22,
                  child: AppImages.addFilledIcon(
                    context,
                  ),
                )),
                TextSpan(
                    text: "?",
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall!
                        .copyWith(fontFamily: AppConstants.interFont)),
              ],
            ),
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "A ",
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                  WidgetSpan(
                      child: SizedBox(
                    height: AppWidgetSize.dimen_22,
                    child: AppImages.addUnfilledIcon(context,
                        isColor: true, color: Theme.of(context).primaryColor),
                  )),
                  TextSpan(
                    text: _appLocalizations.watchlistInfoAns2_1,
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                  WidgetSpan(
                      child: SizedBox(
                          height: AppWidgetSize.dimen_22,
                          child: AppImages.addFilledIcon(context))),
                  TextSpan(
                    text: _appLocalizations.watchlistInfoAns2_2,
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                  TextSpan(
                    text: "?",
                    style: Theme.of(context)
                        .primaryTextTheme
                        .labelSmall!
                        .copyWith(fontFamily: AppConstants.interFont),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionRowQue3(BuildContext context, String title) {
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
          title: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: Theme.of(context).textTheme.displaySmall,
              children: [
                TextSpan(text: _appLocalizations.watchlistInfoQue3_1),
                TextSpan(
                    text: _appLocalizations.watchlistInfoQue3_2,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        fontSize: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .fontSize)),
                TextSpan(text: _appLocalizations.watchlistInfoQue3_3),
                TextSpan(
                    text: "?",
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall!
                        .copyWith(fontFamily: AppConstants.interFont)),
              ],
            ),
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: CustomTextWidget(_appLocalizations.watchlistInfoAns3_1,
                  Theme.of(context).primaryTextTheme.labelSmall),
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
                      _appLocalizations.watchlistInfoAns3_2,
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
                    child: CustomTextWidget(
                      _appLocalizations.watchlistInfoAns3_3,
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
                    child: CustomTextWidget(
                      _appLocalizations.watchlistInfoAns3_4,
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
                    child: CustomTextWidget(
                      _appLocalizations.watchlistInfoAns3_5,
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

  Widget _buildExpansionRowQue4(BuildContext context, String title) {
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
              title, Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.left),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: CustomTextWidget(_appLocalizations.watchlistInfoAns4,
                  Theme.of(context).primaryTextTheme.labelSmall),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionRowQue5(BuildContext context, String title) {
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
              title, Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.left),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomTextWidget(_appLocalizations.watchlistInfoAns5_1,
                    Theme.of(context).primaryTextTheme.labelSmall),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.only(
                      // top:8.w,
                      left: AppWidgetSize.dimen_16,
                      right: 4.w,
                    ),
                    child: CustomTextWidget(
                      "1.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    )),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      _appLocalizations.watchlistInfoAns5_2,
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
                      // top:8.w,
                      left: AppWidgetSize.dimen_16,
                      right: 4.w,
                    ),
                    child: CustomTextWidget(
                      "2.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    )),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      _appLocalizations.watchlistInfoAns5_3,
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
                      //  top:8.w,
                      left: AppWidgetSize.dimen_16,
                      right: 4.w,
                    ),
                    child: CustomTextWidget(
                      "3.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    )),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      _appLocalizations.watchlistInfoAns5_4,
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
                      //top:8.w,
                      left: AppWidgetSize.dimen_16,
                      right: 4.w,
                    ),
                    child: CustomTextWidget(
                      "4.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    )),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _appLocalizations.useThe,
                            style:
                                Theme.of(context).primaryTextTheme.labelSmall,
                          ),
                          WidgetSpan(
                              child: SizedBox(
                            height: AppWidgetSize.dimen_22,
                            child: AppImages.addUnfilledIcon(context,
                                isColor: true,
                                color: Theme.of(context).primaryColor),
                          )),
                          TextSpan(
                            text: _appLocalizations.watchlistInfoAns5_5,
                            style:
                                Theme.of(context).primaryTextTheme.labelSmall,
                          ),
                          WidgetSpan(
                              child: SizedBox(
                            height: AppWidgetSize.dimen_22,
                            child: AppImages.addFilledIcon(
                              context,
                            ),
                          )),
                          TextSpan(
                            text: _appLocalizations.watchlistInfoAns5_6,
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
            CustomTextWidget(
              _appLocalizations.watchlistInfoAns5_7,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.only(
                      // top:8.w,
                      left: AppWidgetSize.dimen_16,
                      right: 4.w,
                    ),
                    child: CustomTextWidget(
                      "1.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    )),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      _appLocalizations.watchlistInfoAns5_8,
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
                      // top:8.w,
                      left: AppWidgetSize.dimen_16,
                      right: 4.w,
                    ),
                    child: CustomTextWidget(
                      "2.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    )),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      _appLocalizations.watchlistInfoAns5_9,
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
                      // top:8.w,
                      left: AppWidgetSize.dimen_16,
                      right: 4.w,
                    ),
                    child: CustomTextWidget(
                      "3.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    )),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      _appLocalizations.watchlistInfoAns5_10,
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

  Widget _buildExpansionRowQue6(BuildContext context, String title) {
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
              title, Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.left),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              _appLocalizations.watchlistInfoAns6,
              Theme.of(context).primaryTextTheme.labelSmall,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return InkWell(
      onTap: () {
        String? url = AppConfig.boUrls?.firstWhereOrNull((element) =>
            element["key"] == "watchlistDropdownNeedHelp")?["value"];
        if (url != null) {
          {
            Navigator.push(
              context,
              SlideRoute(
                  settings: const RouteSettings(
                    name: ScreenRoutes.inAppWebview,
                  ),
                  builder: (BuildContext context) =>
                      WebviewWidget("Need Help", url)),
            );
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 20.w,
          top: 20.w,
        ),
        child: Center(
          child: CustomTextWidget(
              _appLocalizations.generalNeedHelp,
              Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w400)),
        ),
      ),
    );
  }
}
