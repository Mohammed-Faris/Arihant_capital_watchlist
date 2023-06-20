import 'package:flutter/material.dart';

import '../../../../constants/app_constants.dart';
import '../../../../localization/app_localization.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../base/base_screen.dart';

class BuyPowerInfoHelpScreen extends BaseScreen {
  final dynamic arguments;
  const BuyPowerInfoHelpScreen({Key? key, this.arguments}) : super(key: key);

  @override
  BuyPowerInfoHelpScreenState createState() => BuyPowerInfoHelpScreenState();
}

class BuyPowerInfoHelpScreenState
    extends BaseAuthScreenState<BuyPowerInfoHelpScreen> {
  late AppLocalizations _appLocalizations;
  bool isval = false;

  @override
  String getScreenRoute() {
    return ScreenRoutes.buyPowerInfoHelpScreen;
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
              _appLocalizations.generalNeedHelp,
              Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
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
        ],
      ),
    );
  }

  Widget _buildExpansionWidget() {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20, right: AppWidgetSize.dimen_5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExpansionDataWidget(_appLocalizations.whatbuyingpwr,
              _appLocalizations.buypwrAns, false, false),
          _buildSeperator(),
          _buildExpansionDataWidget(
              _appLocalizations.incBuypwr, '', true, false),
          _buildSeperator(),
          _buildExpansionDataWidget(
              _appLocalizations.whydoesBuypwr, '', false, true),
          _buildSeperator(),
          _buildExpansionDataWidgetFivepoint(_appLocalizations.diffBuypwr,
              _appLocalizations.diffBuypwrAns, false, false),
          _buildSeperator(),
          _buildExpansionDataWidgetLastpoint(_appLocalizations.buyPwrupdate,
              _appLocalizations.buyPwrupdateAns, false, false),
          _buildSeperator(),
        ],
      ),
    );
  }

  Widget _buildExpansionDataWidget(
      String headerdata, String bodydata, bool isLink, bool isBulletPoint) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey("${DateTime.now().millisecondsSinceEpoch}"),
        initiallyExpanded: false,
        collapsedIconColor: Theme.of(context).primaryIconTheme.color,
        title: _buildHeaderWidget(headerdata),
        children: [
          if (isLink == false && bodydata.isNotEmpty)
            _buildValueWidget(bodydata),
          if (isLink == true) _buildDataWithHyperLinkWidget(),
          if (isBulletPoint == true) _buildDataWithBulletinCustomTextWidget()
        ],
      ),
    );
  }

  Widget _buildExpansionDataWidgetLastpoint(
      String headerdata, String bodydata, bool isLink, bool isBulletPoint) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey("${DateTime.now().millisecondsSinceEpoch}"),
        initiallyExpanded: false,
        collapsedIconColor: Theme.of(context).primaryIconTheme.color,
        title: _buildHeaderWidget(headerdata),
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_10,
              left: AppWidgetSize.dimen_20,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                _appLocalizations.buypwrNeedhlpque5Desc,
                Theme.of(context).textTheme.headlineSmall,
              ),
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
                    top: AppWidgetSize.dimen_8,
                    left: AppWidgetSize.dimen_16,
                    right: AppWidgetSize.dimen_4,
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
                      _appLocalizations.buypwrNeedhlpque5DescPnt1,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_20, right: AppWidgetSize.dimen_20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_8,
                    left: AppWidgetSize.dimen_16,
                    right: AppWidgetSize.dimen_4,
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
                      _appLocalizations.buypwrNeedhlpque5DescPnt2,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_20, right: AppWidgetSize.dimen_20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_8,
                    left: AppWidgetSize.dimen_16,
                    right: AppWidgetSize.dimen_4,
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
                      _appLocalizations.buypwrNeedhlpque5DescPnt3,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: AppWidgetSize.dimen_20,
                left: AppWidgetSize.dimen_20,
                right: AppWidgetSize.dimen_20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_8,
                    left: AppWidgetSize.dimen_16,
                    right: AppWidgetSize.dimen_4,
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
                      _appLocalizations.buypwrNeedhlpque5DescPnt4,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionDataWidgetFivepoint(
      String headerdata, String bodydata, bool isLink, bool isBulletPoint) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey("${DateTime.now().millisecondsSinceEpoch}"),
        initiallyExpanded: false,
        collapsedIconColor: Theme.of(context).primaryIconTheme.color,
        title: _buildHeaderWidget(headerdata),
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_10,
                left: AppWidgetSize.dimen_20,
                right: AppWidgetSize.dimen_20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                _appLocalizations.buypwrNeedhlpque4Desc1,
                Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_10,
                    left: AppWidgetSize.dimen_20,
                    right: AppWidgetSize.dimen_20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CustomTextWidget(
                    _appLocalizations.buypwrNeedhlpque4Desc2,
                    Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
            ],
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
                    top: AppWidgetSize.dimen_8,
                    left: AppWidgetSize.dimen_16,
                    right: AppWidgetSize.dimen_4,
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
                      _appLocalizations.buypwrNeedhlpque4Pnt1,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_20, right: AppWidgetSize.dimen_20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_8,
                    left: AppWidgetSize.dimen_16,
                    right: AppWidgetSize.dimen_4,
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
                      _appLocalizations.buypwrNeedhlpque4Pnt2,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: AppWidgetSize.dimen_20,
                left: AppWidgetSize.dimen_20,
                right: AppWidgetSize.dimen_20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_8,
                    left: AppWidgetSize.dimen_16,
                    right: AppWidgetSize.dimen_4,
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
                      _appLocalizations.buypwrNeedhlpque4Pnt3,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: AppWidgetSize.dimen_10,
                left: AppWidgetSize.dimen_20,
                right: AppWidgetSize.dimen_20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                _appLocalizations.buypwrNeedhlpque4Desc3,
                Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWidget(String value) {
    return CustomTextWidget(
      value,
      Theme.of(context).textTheme.headlineMedium,
      textAlign: TextAlign.left,
    );
  }

  Widget _buildValueWidget(String data) {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          bottom: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: CustomTextWidget(
          data,
          Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.justify,
        ),
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

  Widget _buildDataWithHyperLinkWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          bottom: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            children: [
              TextSpan(
                text: _appLocalizations.buypwrNeedhlpque2Desc,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextSpan(
                  text: "?",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontFamily: AppConstants.interFont)),
              /*     TextSpan(
                text: _appLocalizations.buypwrNeedhlpClickhere,
                style: Theme.of(context).textTheme.headline5,
              ),
           TextSpan(
                  text: _appLocalizations.learnmoreWithdot,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()..onTap = () async {}), */
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataWithBulletinCustomTextWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          bottom: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            children: [
              TextSpan(
                text: _appLocalizations.buypwrNeedhlpque3Desc,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextSpan(
                  text: _appLocalizations.buypwrNeedhlpque3Pnt1Head,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w600)),
              TextSpan(
                text: _appLocalizations.buypwrNeedhlpque3Pnt1Desc,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextSpan(
                  text: _appLocalizations.buypwrNeedhlpque3Pnt2Head,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w600)),
              TextSpan(
                text: _appLocalizations.buypwrNeedhlpque3Pnt2Desc,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextSpan(
                text: _appLocalizations.buypwrNeedhlpque3Desc2,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
