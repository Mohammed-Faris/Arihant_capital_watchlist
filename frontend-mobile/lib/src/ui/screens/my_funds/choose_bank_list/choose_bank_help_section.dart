// ignore_for_file: depend_on_referenced_packages

import 'package:acml/src/constants/app_constants.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../blocs/my_funds/choose_bank_list/choose_bank_list_bloc.dart';
import '../../../../config/app_config.dart';
import '../../../../localization/app_localization.dart';
import '../../../navigation/screen_routes.dart';
import '../../../widgets/webview_widget.dart';
import '../../base/base_screen.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../route_generator.dart';

class ChooseBankListHelpScreen extends BaseScreen {
  final dynamic arguments;
  const ChooseBankListHelpScreen({Key? key, this.arguments}) : super(key: key);

  @override
  ChooseBankListHelpScreenState createState() =>
      ChooseBankListHelpScreenState();
}

class ChooseBankListHelpScreenState
    extends BaseAuthScreenState<ChooseBankListHelpScreen> {
  late AppLocalizations _appLocalizations;
  bool isval = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChooseBankListBloc>(context)
        .add(ChooseBankListLoadHelpEvent()..isexpanded = false);
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.chooseBanklistHelpScreen;
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      toolbarHeight: AppWidgetSize.dimen_60,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Column(
        children: [
          _buildAppBarContent(),
        ],
      ),
    );
  }

  Widget _buildAppBarContent() {
    return Container(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_10,
      ),
      width: AppWidgetSize.fullWidth(context),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_30,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _getAppBarLeftContent(),
          ],
        ),
      ),
    );
  }

  Widget _getAppBarLeftContent() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
      ),
      child: Row(
        children: [
          backIconButton(
              onTap: () {
                popNavigation();
              },
              customColor: Theme.of(context).textTheme.displayMedium!.color),
          Padding(
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_5,
            ),
            child: CustomTextWidget(
                _appLocalizations.needHelp,
                Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildExpansionWidget(),
          _buildViewMoreWidget(),
        ],
      ),
    );
  }

  Widget _buildExpansionWidget() {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20, right: AppWidgetSize.dimen_5),
      child: Column(
        children: [
          _buildExpansionDataWidget(AppLocalizations().whatisPriBankAcc,
              AppLocalizations().whatisPriBankAccAns, false),
          _buildSeperator(),
          _buildExpansionDataWidget(AppLocalizations().choosebankNeedhelp2Qns,
              AppLocalizations().choosebankNeedhelp2Ans, false),
          _buildSeperator(),
          _buildExpansionDataWidget(
              AppLocalizations().choosebankNeedhelp3Qns, 'first', true),
          _buildSeperator(),
          _buildExpansionDataWidget(
              AppLocalizations().choosebankNeedhelp4Qns, 'second', true),
          _buildSeperator(),
        ],
      ),
    );
  }

  Widget _buildExpansionDataWidget(
      String headerdata, String bodydata, bool isdetails) {
    return BlocBuilder<ChooseBankListBloc, ChooseBankListState>(
      buildWhen: (previous, current) {
        return current is ChooseBankListLoadHelpState;
      },
      builder: (context, state) {
        if (state is ChooseBankListLoadHelpState) {
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: PageStorageKey("${DateTime.now().millisecondsSinceEpoch}"),
              initiallyExpanded: state.isexpanded,
              collapsedIconColor: Theme.of(context).primaryIconTheme.color,
              title: _buildHeaderWidget(headerdata),
              children: [
                if (bodydata != 'first' && bodydata != 'second')
                  _buildValueWidget(bodydata),
                if (isdetails && bodydata == 'first')
                  _buildBankaccountwithhyperlinkFirstWidget(),
                if (isdetails && bodydata == 'first')
                  _buildBankaccountwithhyperlinkSecondWidget(),
                if (isdetails && bodydata == 'second')
                  _buildBankaccountwithhyperlinkPrimaryWidget(),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildSeperator() {
    return Padding(
      padding: EdgeInsets.only(
          right: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_10,
          top: AppWidgetSize.dimen_5),
      child: Container(
        height: 1,
        width: AppWidgetSize.fullWidth(context),
        color: Theme.of(context).dividerColor,
      ),
    );
  }

  Widget _buildValueWidget(String data) {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          bottom: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20),
      child: CustomTextWidget(data, Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.justify),
    );
  }

  Widget _buildBankaccountwithhyperlinkPrimaryWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          bottom: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          children: [
            TextSpan(
              text: AppLocalizations().choosebankNeedhelp4Ans1,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextSpan(
                text: AppLocalizations().choosebankNeedhelp4Ans2,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()..onTap = () async {}),
            TextSpan(
              text: AppLocalizations().choosebankNeedhelp4Ans3,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankaccountwithhyperlinkFirstWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          bottom: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          children: [
            TextSpan(
              text: AppLocalizations().choosebankNeedhelp3Ans1,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextSpan(
                text: AppLocalizations().choosebankNeedhelp3Ans2,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    Navigator.push(
                      context,
                      SlideRoute(
                          settings: const RouteSettings(
                            name: ScreenRoutes.inAppWebview,
                          ),
                          builder: (BuildContext context) => WebviewWidget(
                              "re-KYC request", AppConfig.signUpUrl)),
                    );
                  }),
            TextSpan(
              text: ".",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextSpan(
                text: AppLocalizations().choosebankNeedhelp3Ans3,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    Navigator.push(
                      context,
                      SlideRoute(
                          settings: const RouteSettings(
                            name: ScreenRoutes.inAppWebview,
                          ),
                          builder: (BuildContext context) => WebviewWidget(
                              "re-KYC request", AppConfig.signUpUrl)),
                    );
                  }),
            TextSpan(
                text: AppLocalizations().choosebankNeedhelp3Ans4,
                style: Theme.of(context).textTheme.headlineSmall,
                recognizer: TapGestureRecognizer()..onTap = () async {}),
            TextSpan(
              text: AppLocalizations().rupeeSymbol,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontFamily: AppConstants.interFont),
            ),
            TextSpan(
                text: AppLocalizations().choosebankNeedhelp3Ans5,
                style: Theme.of(context).textTheme.headlineSmall,
                recognizer: TapGestureRecognizer()..onTap = () async {}),
          ],
        ),
      ),
    );
  }

  Widget _buildBankaccountwithhyperlinkSecondWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          bottom: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              children: [
                TextSpan(
                  text: AppLocalizations().choosebankNeedhelp3Ans6,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextSpan(
                    text: AppLocalizations().choosebankNeedhelp3Ans7,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        String? url = AppConfig.boUrls?.firstWhereOrNull(
                            (element) =>
                                element["key"] == "accDtlsModify")?["value"];
                        if (url != null) {
                          {
                            await ChromeSafariBrowser()
                                .open(url: Uri.parse(url.trim()));
                          }
                        }
                      }),
                TextSpan(
                  text: AppLocalizations().choosebankNeedhelp3Ans8,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          Text(
            AppLocalizations().choosebankNeedhelp3Ans9,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            AppLocalizations().choosebankNeedhelp3Ans10,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            AppLocalizations().choosebankNeedhelp3Ans11,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  Text _buildHeaderWidget(String value) {
    return Text(value,
        style: Theme.of(context)
            .textTheme
            .headlineSmall!
            .copyWith(fontWeight: FontWeight.w600));
  }

  Widget _buildViewMoreWidget() {
    return Padding(
      padding: EdgeInsets.only(
          right: AppWidgetSize.dimen_30,
          top: AppWidgetSize.dimen_20,
          bottom: AppWidgetSize.dimen_20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              bool isvalue = BlocProvider.of<ChooseBankListBloc>(context)
                  .chooseBankListLoadHelpState
                  .isexpanded;
              isvalue = !isvalue;
              BlocProvider.of<ChooseBankListBloc>(context)
                  .add(ChooseBankListLoadHelpEvent()..isexpanded = isvalue);
            },
            child: Text(
              AppLocalizations().viewMore,
              style: Theme.of(context).primaryTextTheme.headlineSmall,
            ),
          )
        ],
      ),
    );
  }
}
