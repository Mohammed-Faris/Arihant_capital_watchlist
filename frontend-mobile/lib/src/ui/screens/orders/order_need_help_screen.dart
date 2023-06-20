import '../../../config/app_config.dart';
import '../../navigation/screen_routes.dart';
import '../../widgets/webview_widget.dart';
import '../base/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:msil_library/streamer/stream/streaming_manager.dart';

import '../../../localization/app_localization.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../route_generator.dart';

class NeedHelp extends BaseScreen {
  final String orderStatus;
  const NeedHelp(this.orderStatus, {Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => NeedHelpState();
}

class NeedHelpState extends BaseAuthScreenState<NeedHelp> {
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
    helpMsg = widget.orderStatus == "executed"
        ? [
            _appLocalizations.oneHelpMsg,
            _appLocalizations.successOrderheading2,
            _appLocalizations.successOrderheading3,
            _appLocalizations.successOrderheading4,
            _appLocalizations.successOrderheading5,
            _appLocalizations.fiveHelpMsg,
            _appLocalizations.sixHelpMsg,
          ]
        : widget.orderStatus == "rejected"
            ? [_appLocalizations.rejectedorderHeading1]
            : widget.orderStatus == "pending"
                ? [
                    _appLocalizations.pendingOrderheading1,
                    _appLocalizations.pendingOrderheading2,
                    _appLocalizations.pendingOrderheading3,
                    _appLocalizations.pendingOrderheading4
                  ]
                : [];
    helpMsgAns = widget.orderStatus == "executed"
        ? [
            _appLocalizations.oneHelpMsgAns,
            _appLocalizations.successOrderdescription2,
            _appLocalizations.successOrderdescription3,
            _appLocalizations.successOrderdescription4,
            _appLocalizations.successOrderdescription5,
            _appLocalizations.fiveHelpMsgAns,
            _appLocalizations.sixHelpMsgAns,
          ]
        : widget.orderStatus == "rejected"
            ? [_appLocalizations.rejectedOrderdescription1]
            : widget.orderStatus == "pending"
                ? [
                    _appLocalizations.pendingOrderdescription1,
                    _appLocalizations.pendingOrderdesc2,
                    _appLocalizations.pendingOrderdesc3,
                    _appLocalizations.pendingOrderdesc4
                  ]
                : [];
    return Scaffold(
        appBar: _buildAppBar(),
        body: Padding(
          padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_30,
            right: AppWidgetSize.dimen_30,
          ),
          child: ListView.separated(
              primary: false,
              shrinkWrap: true,
              separatorBuilder: (BuildContext ctx, int index) {
                return Divider(
                  thickness: AppWidgetSize.dimen_1,
                  color: Theme.of(context).dividerColor,
                );
              },
              itemCount: helpMsg.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == helpMsg.length - 1) {
                  return Column(
                    children: [
                      _buildLastExpansionRow(context, index),
                      Divider(
                        thickness: AppWidgetSize.dimen_1,
                        color: Theme.of(context).dividerColor,
                      ),
                      /*  Padding(
                        padding: EdgeInsets.only(
                          top: AppWidgetSize.dimen_10,
                        ),
                        child: CustomTextWidget(
                          _appLocalizations.lastHelpMsg,
                          Theme.of(context)
                              .primaryTextTheme
                              .overline!
                              .copyWith(fontWeight: FontWeight.w400),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: AppWidgetSize.dimen_10,
                        ),
                        child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            text: _appLocalizations.helpSection,
                            style: Theme.of(context).primaryTextTheme.overline,
                            children: [
                              TextSpan(
                                text: _appLocalizations.visitHelp,
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headline6!
                                    .copyWith(
                                      fontWeight: FontWeight.w400,
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ), */
                    ],
                  );
                } else {
                  return _buildExpansionRow(context, index);
                }
              }),
        ));
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
        'Help Topics',
        Theme.of(context)
            .primaryTextTheme
            .labelSmall!
            .copyWith(fontWeight: FontWeight.w600),
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
                StreamingManager()
                    .unsubscribeLevel1(getScreenRoute()); //needs to check
                popNavigation();
              },
              customColor: Theme.of(context).textTheme.displayMedium!.color),
        ],
      ),
    );
  }

  Widget _buildExpansionRow(BuildContext context, int index) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.only(
          left: 0,
          bottom: 0,
        ),
        collapsedIconColor: Theme.of(context).primaryIconTheme.color,
        title: CustomTextWidget(
          helpMsg[index],
          Theme.of(context)
              .primaryTextTheme
              .labelSmall!
              .copyWith(fontWeight: FontWeight.w600),
        ),
        iconColor: Theme.of(context).primaryIconTheme.color,
        initiallyExpanded: false,
        expandedCrossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomTextWidget(
              helpMsgAns[index],
              Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(fontWeight: FontWeight.w400),
              textAlign: TextAlign.justify, onTap: (s) {
            if (s == "1") {
              Navigator.push(
                context,
                SlideRoute(
                    settings: const RouteSettings(
                      name: ScreenRoutes.inAppWebview,
                    ),
                    builder: (BuildContext context) => WebviewWidget(
                        "Need Help", AppConfig.boUrls![18]["value"])),
              );
            } else {
              Navigator.push(
                context,
                SlideRoute(
                    settings: const RouteSettings(
                      name: ScreenRoutes.inAppWebview,
                    ),
                    builder: (BuildContext context) => WebviewWidget(
                        "Need Help", AppConfig.boUrls![5]["value"])),
              );
            }
          })
        ],
      ),
    );
  }

  Widget _buildLastExpansionRow(BuildContext context, int index) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.only(
          left: 0,
          bottom: 0,
        ),
        collapsedIconColor: Theme.of(context).primaryIconTheme.color,
        title: CustomTextWidget(
          helpMsg[index],
          Theme.of(context)
              .primaryTextTheme
              .labelSmall!
              .copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.justify,
        ),
        iconColor: Theme.of(context).primaryIconTheme.color,
        initiallyExpanded: false,
        expandedCrossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomTextWidget(
            helpMsgAns[index],
            Theme.of(context)
                .primaryTextTheme
                .labelSmall!
                .copyWith(fontWeight: FontWeight.w400),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
