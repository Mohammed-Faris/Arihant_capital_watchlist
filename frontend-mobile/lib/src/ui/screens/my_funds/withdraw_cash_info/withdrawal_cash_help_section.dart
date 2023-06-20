import '../../../../localization/app_localization.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_images.dart';
import '../../base/base_screen.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';

class WithdrawalCashInfoHelpScreen extends BaseScreen {
  final dynamic arguments;
  const WithdrawalCashInfoHelpScreen({Key? key, this.arguments})
      : super(key: key);

  @override
  WithdrawalCashInfoHelpScreenState createState() =>
      WithdrawalCashInfoHelpScreenState();
}

class WithdrawalCashInfoHelpScreenState
    extends BaseAuthScreenState<WithdrawalCashInfoHelpScreen> {
  late AppLocalizations _appLocalizations;
  bool isval = false;

  @override
  String getScreenRoute() {
    return ScreenRoutes.withdrawalCashInfoHelpScreen;
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
          child: _getAppBarLeftContent(),
        ));
  }

  Widget _getAppBarLeftContent() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget("${_appLocalizations.needHelp}?",
              Theme.of(context).primaryTextTheme.titleMedium),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: AppImages.closeIcon(
              context,
              width: AppWidgetSize.dimen_20,
              height: AppWidgetSize.dimen_20,
              color: Theme.of(context).primaryIconTheme.color,
              isColor: true,
            ),
          )
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
          left: AppWidgetSize.dimen_10, right: AppWidgetSize.dimen_10),
      child: Column(
        children: [
          _buildExpansionDataWidget('What is Withdrawable Cash?',
              'Withdrawable cash is the amount of money you can transfer from the trading account to your bank account. \n\nYour withdrawable cash may differ from your account balance as the cash due from equity and F&O trades are not settled instantly. Cash from selling equities takes T+2 days and from F&O trades takes T+1 day to be credited to your trading account by the exchanges before you can withdraw them. Moreover, if you incur any loss in your open positions, or if you had made any new purchases during the day, that amount will also be blocked as part of your utilized margin, and you will not be able to withdraw it. \n\nThe withdrawable cash may also change after the market\'s closing if you have traded during the day. This is because all charges and obligations get updated during aftermarket hours, typically between 5 pm to 9 pm.',
              expanded: true),
          _buildSeperator(),
          _buildExpansionDataWidget(
            'Why was my withdrawal request rejected?',
            'There are several reasons why you may not be able to withdraw money from your Arihant trading account. The most common reason is trying to remove funds before the settlement period is over. Following each sale, the money in your Arihant account needs to settle before it can be transferred. The settlement cycle for equity trades is T+2 days and T+1 days for futures and options.\n\nThe settlement cycle is the time taken for funds from stocks you sold or F&O positions you have closed to be credited to your trading account. In the case of intraday and F&O, it is the time taken for the realized profits, M2M, or sell value of options to be credited to your account.\n\nAlso, funds added to the trading account cannot be withdrawn on the same day.Beyond that, your withdrawal request will only be rejected if your withdrawal amount goes beyond your withdrawal limit.',
          ),
          _buildSeperator(),
          _buildExpansionDataWidget(
              'What happens when my withdrawal request amount is higher than the withdrawable balance?',
              'Withdrawal requests for amount higher than the withdrawable balance will be processed, however you will only recevie funds in your bank account that is equal to the avialable withdrawable balance. \n \n For e.g',
              bullets: Padding(
                padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_20,
                    right: AppWidgetSize.dimen_20),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(10)
                  },
                  children: [
                    bulletTableRow("Your withdrawable balance is ₹10,000. "),
                    bulletTableRow(
                        "You place a withdrawal request for ₹15,000."),
                    bulletTableRow(
                        "₹10,000 will be credited to your bank account.")
                  ],
                ),
              )),
          _buildSeperator(),
          _buildExpansionDataWidget(
            'I sold some stocks, but why is the sale amount not showing in my withdrawable cash?',
            'Following a sale in your account, the transaction needs to "settle" before you can withdraw them to your bank account. The settlement period is the trade date plus two trading days (T+2). On the third day, those funds will appear as withdrawable cash.',
          ),
          _buildSeperator(),
        ],
      ),
    );
  }

  TableRow bulletTableRow(String text) {
    return TableRow(children: [
      Padding(
        padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_5, right: AppWidgetSize.dimen_5),
        child: CustomTextWidget(
          "💰 ",
          Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.w400),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
        child: CustomTextWidget(
          text,
          Theme.of(context).textTheme.headlineSmall!,
          textAlign: TextAlign.left,
        ),
      )
    ]);
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

  Widget _buildExpansionDataWidget(String headerdata, String bodydata,
      {Widget? bullets, bool expanded = false}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey("${DateTime.now().millisecondsSinceEpoch}"),
        initiallyExpanded: expanded,
        collapsedIconColor: Theme.of(context).primaryIconTheme.color,
        title: _buildHeaderWidget(headerdata),
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_20),
            child: Column(
              children: [
                _buildValueWidget(bodydata),
                if (bullets != null) bullets
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeaderWidget(String value) {
    return CustomTextWidget(value, Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.left);
  }

  Widget _buildValueWidget(String data) {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20),
      child: Text(
        data,
        style: Theme.of(context)
            .textTheme
            .headlineSmall!
            .copyWith(fontWeight: FontWeight.w400),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
