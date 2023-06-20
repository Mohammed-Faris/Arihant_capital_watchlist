import '../../../../config/app_config.dart';
import '../../../../localization/app_localization.dart';
import '../../../navigation/screen_routes.dart';
import '../../../widgets/webview_widget.dart';
import '../../base/base_screen.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../route_generator.dart';

class AddFundHelpErrorContentScreen extends BaseScreen {
  final dynamic arguments;
  const AddFundHelpErrorContentScreen({Key? key, this.arguments})
      : super(key: key);

  @override
  AddFundHelpErrorContentScreenState createState() =>
      AddFundHelpErrorContentScreenState();
}

class AddFundHelpErrorContentScreenState
    extends BaseAuthScreenState<AddFundHelpErrorContentScreen> {
  late AppLocalizations _appLocalizations;

  @override
  String getScreenRoute() {
    return ScreenRoutes.addfundHelpErrorContentScreen;
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
        children: [_buildExpansionWidget(), _buildFooterWidget()],
      ),
    );
  }

  Widget _buildFooterWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          bottom: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${_appLocalizations.cantfind} \n',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextSpan(
              text: '${_appLocalizations.visit} ',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextSpan(
                text: _appLocalizations.helpsection,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    String? url = AppConfig.boUrls?.firstWhereOrNull(
                        (element) =>
                            element["key"] ==
                            "upiPaymentFailedNeedHelp")?["value"];
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
                  }),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionWidget() {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20, right: AppWidgetSize.dimen_5),
      child: Column(
        children: [
          _buildExpansionDataWidget(_appLocalizations.mytransferfailed,
              _appLocalizations.transferfailed, false),
          _buildSeperator(),
          _buildExpansionDataWidget(_appLocalizations.netbankfailmessage,
              _appLocalizations.netbankfailmessage1, false),
          _buildSeperator(),
          _buildExpansionDataWidget(
              _appLocalizations.upifail, _appLocalizations.upifail1, false),
          _buildSeperator(),
          _buildExpansionDataWidget(_appLocalizations.upifailamounttransfer,
              _appLocalizations.upifailamounttransfer1, false),
          _buildSeperator(),
          _buildExpansionDataWidget(_appLocalizations.mypayfail, '', true),
          _buildSeperator(),
        ],
      ),
    );
  }

  Widget _buildDataWithHyperLinkWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          bottom: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: _appLocalizations.addFundsHelpContentError4,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            /*   TextSpan(
              text:
                  'You can get extra buying power, without transferring cash, by using Arihant’s margin pledge facility. Through Margin Pledge you can use your existing holdings/portfolio to get an additional limit/margin. You can then use this extra margin to buy more shares. You will be charged a nominal interest rate for borrowing funds using margin pledge. To learn more about margin trading and margin pledge,',
              style: Theme.of(context).textTheme.headline5,
            ),
            TextSpan(
                text: 'Click here',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()..onTap = () async {}), */
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionDataWidget(String headerdata, String bodydata, isLink) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey("${DateTime.now().millisecondsSinceEpoch}"),
        initiallyExpanded: false,
        title: _buildHeaderWidget(headerdata),
        children: [
          if (isLink == false) _buildValueWidget(bodydata),
          if (isLink == true) _buildDataWithHyperLinkWidget(),
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

  Widget _buildValueWidget(String data) {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          bottom: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20),
      child: Text(
        data,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
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
}
