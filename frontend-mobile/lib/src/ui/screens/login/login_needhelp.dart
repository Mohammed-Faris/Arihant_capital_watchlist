import 'package:flutter/material.dart';

import '../../../config/app_config.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/webview_widget.dart';
import '../base/base_screen.dart';
import '../route_generator.dart';

class LoginNeedHelp extends BaseScreen {
  const LoginNeedHelp({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => LoginNeedHelpState();
}

class LoginNeedHelpState extends BaseAuthScreenState<LoginNeedHelp> {
  late AppLocalizations _appLocalizations;
  List<String> helpMsg = [];
  List<String> helpMsgAns = [];

  @override
  void initState() {
    super.initState();

    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.orderHelpScreen);
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
        appBar: _buildAppBar(),
        body: Padding(
            padding: const EdgeInsets.only(),
            child: _buildBottomContent(context)));
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      toolbarHeight: AppWidgetSize.dimen_60,
      elevation: 0.0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      leading: _buildAppBarLeftWidget(),
      title: CustomTextWidget(
        _appLocalizations.helpTopics,
        Theme.of(context)
            .primaryTextTheme
            .labelSmall!
            .copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBottomContent(BuildContext context) {
    List<Widget> informationWidgetList = [
      _buildExpansionRowWithrichtext1(context),
      Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowWithrichtext2(context),
      Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowWithrichtext3(context),
      Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowWithrichtext4(context, _appLocalizations.loginhelpQue4,
          _appLocalizations.loginhelpAns4),
      Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRow(context, _appLocalizations.loginhelpQue5,
          _appLocalizations.loginhelpAns5),
      Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRow(context, _appLocalizations.loginhelpQue6,
          _appLocalizations.loginhelpAns6),
      Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRow(context, _appLocalizations.loginhelpQue7,
          _appLocalizations.loginhelpAns7),
      Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [_buildFooter(context)],
      )
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
          // _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildExpansionRow(
      BuildContext context, String title, String description) {
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
                Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.left),
            iconColor: Theme.of(context).primaryIconTheme.color,
            children: <Widget>[
              CustomTextWidget(
                description,
                Theme.of(context).primaryTextTheme.labelSmall,
                onTap: (p0) {
                  Navigator.push(
                    context,
                    SlideRoute(
                        settings: const RouteSettings(
                          name: ScreenRoutes.inAppWebview,
                        ),
                        builder: (BuildContext context) => const WebviewWidget(
                            "Need help?",
                            "https://erekyc.arihantcapital.com/")),
                  );
                },
              ),
            ]),
      ),
    );
  }

  Widget _buildExpansionRowWithrichtext4(
      BuildContext context, String title, String description) {
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
                Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.left),
            iconColor: Theme.of(context).primaryIconTheme.color,
            children: <Widget>[
              CustomTextWidget(
                description,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
              Container(
                padding: EdgeInsets.only(top: 20.w),
                alignment: Alignment.centerLeft,
                child: CustomTextWidget(
                  _appLocalizations.loginhelpAns4_1,
                  Theme.of(context)
                      .primaryTextTheme
                      .labelSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              CustomTextWidget(
                _appLocalizations.loginhelpAns4_2,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ]),
      ),
    );
  }

  Widget _buildExpansionRowWithrichtext1(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.only(
            left: 0,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
              _appLocalizations.loginhelpQue1,
              Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.left),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _appLocalizations.loginhelpAns1_1,
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.w,
            ),
            CustomTextWidget(
                _appLocalizations.loginhelpAns1_2,
                Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontWeight: FontWeight.bold)),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10,
                  left: AppWidgetSize.dimen_20,
                  right: AppWidgetSize.dimen_20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_16,
                      right: AppWidgetSize.dimen_4,
                    ),
                    child: CustomTextWidget(
                      "1.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: CustomTextWidget(
                        _appLocalizations.loginhelpAns1_3,
                        Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10,
                  left: AppWidgetSize.dimen_20,
                  right: AppWidgetSize.dimen_20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_16,
                      right: AppWidgetSize.dimen_4,
                    ),
                    child: CustomTextWidget(
                      "2.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: CustomTextWidget(
                        _appLocalizations.loginhelpAns1_4,
                        Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10,
                  left: AppWidgetSize.dimen_20,
                  right: AppWidgetSize.dimen_20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_16,
                      right: AppWidgetSize.dimen_4,
                    ),
                    child: CustomTextWidget(
                      "3.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: CustomTextWidget(
                        _appLocalizations.loginhelpAns1_5,
                        Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.w),
              child: CustomTextWidget(
                _appLocalizations.loginhelpAns1_6,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(top: 10.w),
              child: CustomTextWidget(
                _appLocalizations.loginhelpAns1_7,
                Theme.of(context)
                    .primaryTextTheme
                    .labelSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10,
                  left: AppWidgetSize.dimen_20,
                  right: AppWidgetSize.dimen_20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_16,
                      right: AppWidgetSize.dimen_4,
                    ),
                    child: CustomTextWidget(
                      "1.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: CustomTextWidget(
                        _appLocalizations.loginhelpAns1_8,
                        Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10,
                  left: AppWidgetSize.dimen_20,
                  right: AppWidgetSize.dimen_20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_16,
                      right: AppWidgetSize.dimen_4,
                    ),
                    child: CustomTextWidget(
                      "2.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: CustomTextWidget(
                        _appLocalizations.loginhelpAns1_9,
                        Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10,
                  left: AppWidgetSize.dimen_20,
                  right: AppWidgetSize.dimen_20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_16,
                      right: AppWidgetSize.dimen_4,
                    ),
                    child: Icon(
                      Icons.circle,
                      size: AppWidgetSize.dimen_6,
                      color:
                          Theme.of(context).primaryTextTheme.labelSmall?.color,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: CustomTextWidget(
                        _appLocalizations.loginhelpAns1_10,
                        Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionRowWithrichtext3(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.only(
            left: 0,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
              _appLocalizations.loginhelpQue3,
              Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.left),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _appLocalizations.loginhelpAns3,
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.w,
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10,
                  left: AppWidgetSize.dimen_20,
                  right: AppWidgetSize.dimen_20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_16,
                      right: AppWidgetSize.dimen_4,
                    ),
                    child: CustomTextWidget(
                      "1.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: CustomTextWidget(
                        _appLocalizations.loginhelpAns3_1,
                        Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10,
                  left: AppWidgetSize.dimen_20,
                  right: AppWidgetSize.dimen_20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_16,
                      right: AppWidgetSize.dimen_4,
                    ),
                    child: CustomTextWidget(
                      "2.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                        child: RichText(
                            text: TextSpan(children: [
                          TextSpan(
                            text: _appLocalizations.loginhelpAns3_2_1,
                            style:
                                Theme.of(context).primaryTextTheme.labelSmall,
                          ),
                          TextSpan(
                            text: _appLocalizations.loginhelpAns3_2_2,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .labelSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: _appLocalizations.loginhelpAns3_2_3,
                            style:
                                Theme.of(context).primaryTextTheme.labelSmall,
                          ),
                          TextSpan(
                            text: _appLocalizations.loginhelpAns3_2_4,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .labelSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ]))),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10,
                  left: AppWidgetSize.dimen_20,
                  right: AppWidgetSize.dimen_20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_16,
                      right: AppWidgetSize.dimen_4,
                    ),
                    child: CustomTextWidget(
                      "3.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: CustomTextWidget(
                        _appLocalizations.loginhelpAns3_3,
                        Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10,
                  left: AppWidgetSize.dimen_20,
                  right: AppWidgetSize.dimen_20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_16,
                      right: AppWidgetSize.dimen_4,
                    ),
                    child: CustomTextWidget(
                      "4.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: CustomTextWidget(
                        _appLocalizations.loginhelpAns3_4,
                        Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionRowWithrichtext2(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          tilePadding: const EdgeInsets.only(
            left: 0,
          ),
          title: CustomTextWidget(
              _appLocalizations.loginhelpQue2,
              Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.left),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _appLocalizations.loginhelpAns2,
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.w,
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10,
                  left: AppWidgetSize.dimen_10,
                  right: AppWidgetSize.dimen_20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_4,
                      right: AppWidgetSize.dimen_4,
                    ),
                    child: CustomTextWidget(
                      "1.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _appLocalizations.loginhelpAns2_1,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: "${_appLocalizations.loginhelpAns2_1_1}\n",
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.bottom,
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(top: 5.w, right: 5.w),
                                  child: Image.asset(
                                    "lib/assets/images/batch.png",
                                    height: 22.w,
                                  ),
                                )),
                            TextSpan(
                              text: _appLocalizations.loginhelpAns2_1_2,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                            TextSpan(
                              text: _appLocalizations.loginhelpAns2_1_3,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.w,
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10,
                  left: AppWidgetSize.dimen_10,
                  right: AppWidgetSize.dimen_20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_4,
                      right: AppWidgetSize.dimen_4,
                    ),
                    child: CustomTextWidget(
                      "2.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _appLocalizations.loginhelpAns2_2,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: _appLocalizations.loginhelpAns2_2_1,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                            TextSpan(
                              text: "${_appLocalizations.loginhelpAns2_2_1}\n",
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.bottom,
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(top: 5.w, right: 5.w),
                                  child: Image.asset(
                                    "lib/assets/images/batch.png",
                                    height: 22.w,
                                  ),
                                )),
                            TextSpan(
                              text: _appLocalizations.loginhelpAns2_2_2,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                            TextSpan(
                              text: _appLocalizations.loginhelpAns2_2_3,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.w,
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10,
                  left: AppWidgetSize.dimen_10,
                  right: AppWidgetSize.dimen_20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_4,
                      right: AppWidgetSize.dimen_4,
                    ),
                    child: CustomTextWidget(
                      "3.",
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _appLocalizations.loginhelpAns2_3,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: "${_appLocalizations.loginhelpAns2_3_1}\n",
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.bottom,
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(top: 5.w, right: 5.w),
                                  child: Image.asset(
                                    "lib/assets/images/batch.png",
                                    height: 22.w,
                                  ),
                                )),
                            TextSpan(
                              text: _appLocalizations.loginhelpAns2_3_2,
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
            ),
            SizedBox(
              height: 10.w,
            ),
            CustomTextWidget(
              "Once you do this, you are all set up to trade on Arihant Plus.  ",
              Theme.of(context).primaryTextTheme.labelSmall,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarLeftWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        children: [
          backIconButton(
              onTap: () {
                popNavigation();
              },
              customColor: Theme.of(context).textTheme.displayMedium!.color),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 20.w,
        top: 20.w,
      ),
      child: GestureDetector(
        onTap: () async {
          String? url = AppConfig.boUrls?.firstWhereOrNull(
              (element) => element["key"] == "loginNeedHelp")?["value"];
          Navigator.push(
            context,
            SlideRoute(
                settings: const RouteSettings(
                  name: ScreenRoutes.inAppWebview,
                ),
                builder: (BuildContext context) =>
                    WebviewWidget("Contact Us", url ?? "")),
          );
          /*  await InAppBrowser.openWithSystemBrowser(
              url: Uri.parse(AppConfig.boUrls![3]["value"])); */
        },
        child: CustomTextWidget(
            _appLocalizations.learnMore,
            Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w400)),
      ),
    );
  }
}
