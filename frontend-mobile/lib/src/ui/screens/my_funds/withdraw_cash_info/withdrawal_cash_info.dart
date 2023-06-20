import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/my_funds/choose_bank_list/choose_bank_list_bloc.dart';
import '../../../../blocs/my_funds/withdraw_cash_info/withdraw_cash_info_bloc.dart';
import '../../../../constants/app_constants.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/my_funds/my_fund_view_updated_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/refresh_widget.dart';
import '../../base/base_screen.dart';
import 'withdrawal_cash_help_section.dart';

class WithdrawalCashInfoScreen extends BaseScreen {
  final dynamic arguments;
  const WithdrawalCashInfoScreen({Key? key, this.arguments}) : super(key: key);

  @override
  WithdrawalCashInfoScreenState createState() =>
      WithdrawalCashInfoScreenState();
}

class WithdrawalCashInfoScreenState
    extends BaseAuthScreenState<WithdrawalCashInfoScreen> {
  late AppLocalizations _appLocalizations;
  late FundViewUpdatedModel funddata;
  late String maxpayout;

  @override
  void initState() {
    super.initState();
    funddata = widget.arguments['fundmodeldata'];
    maxpayout = widget.arguments['maxpayout'];

    // AppStorage().removeData('getFundViewUpdatedModel');
    BlocProvider.of<WithdrawCashInfoBloc>(context)
        .add(GetWithdrawCashEvent()..withdrawcashdata = maxpayout);
    BlocProvider.of<WithdrawCashInfoBloc>(context)
        .add(GetWithdrawCashFundViewUpdatedEvent(false));

    BlocProvider.of<WithdrawCashInfoBloc>(context)
        .stream
        .listen(withdrawCashInfoBlocListner);
  }

  Future<void> withdrawCashInfoBlocListner(WithdrawCashInfoState state) async {
    if (state is WithdrawCashInfoErrorState) {
      stopLoader();
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state is WithdrawCashInfoProgressState) {
      startLoader();
    } else if (state is! WithdrawCashInfoProgressState) {
      stopLoader();
    }
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
      child: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20,
        ),
        child: _getAppBarLeftContent(),
      ),
    );
  }

  Widget _getAppBarLeftContent() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_5,
            ),
            child: CustomTextWidget(
                _appLocalizations.withDrawalcash,
                Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(fontWeight: FontWeight.w500)),
          ),
          InkWell(
            child: AppImages.close(context,
                color: Theme.of(context).primaryIconTheme.color, isColor: true),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.withdrawalCashinfoScreen;
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SizedBox(
      height: AppWidgetSize.fullHeight(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: RefreshWidget(
              onRefresh: () async {
                // AppStorage().removeData('getFundViewUpdatedModel');
                BlocProvider.of<WithdrawCashInfoBloc>(context)
                    .add(GetWithdrawCashEvent()..withdrawcashdata = maxpayout);
                BlocProvider.of<WithdrawCashInfoBloc>(context).add(
                    GetWithdrawCashFundViewUpdatedEvent(true)
                      ..fundViewUpdatedModel = null);
              },
              child: ListView(
                children: [
                  _buildGenralDescription(),
                  _buildHorizontalCard(),
                  _builDataWidget(),
                  _buildFooterDescriptionWidget(),
                ],
              ),
            ),
          ),

          // _buildHorizontalCard(),
          // _builDataWidget(),
          // _buildFooterDescriptionWidget(),
          // _buildNeedHelpWidget()
        ],
      ),
    );
  }

  Text _buildSubTitle(String value) {
    return Text(
      value,
      style: Theme.of(context).textTheme.labelLarge!.copyWith(
            fontSize: AppWidgetSize.fontSize12,
          ),
    );
  }

  Text _buildTitleWidget(String value) {
    return Text(
      value,
      style: Theme.of(context).textTheme.labelLarge!.copyWith(
          fontSize: AppWidgetSize.headline6Size, fontWeight: FontWeight.w600),
    );
  }

  Widget _builDataWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAccountBalance(),
          _buildDeductions(),
        ],
      ),
    );
  }

  Widget _buildAccountBalance() {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_20,
        top: AppWidgetSize.dimen_20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildAccountBalanceDescriptionWidget(),
          _buildAccountBalanceWidget(),
        ],
      ),
    );
  }

  Widget _buildAccountBalanceDescriptionWidget() {
    return _getBaseContainerWidget(
      AppWidgetSize.dimen_70,
      AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
      Padding(
        padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_15, left: AppWidgetSize.dimen_10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget('Account Balance'),
            SizedBox(
              height: AppWidgetSize.dimen_5,
            ),
            _buildSubTitle('Opening balance from your ledger')
          ],
        ),
      ),
    );
  }

  Widget _buildAccountBalanceWidget() {
    return BlocBuilder<WithdrawCashInfoBloc, WithdrawCashInfoState>(
      buildWhen: (previous, current) {
        return current is WithdrawCashFundViewDoneState;
      },
      builder: (context, state) {
        if (state is WithdrawCashFundViewDoneState) {
          return Padding(
            padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_5, right: AppWidgetSize.dimen_5),
            child: _getBaseContainerWidget(
              AppWidgetSize.dimen_70,
              AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_55,
              Padding(
                padding: EdgeInsets.only(
                    right: AppWidgetSize.dimen_10,
                    top: AppWidgetSize.dimen_15,
                    left: AppWidgetSize.dimen_10),
                child: _buildRupeeWidget(funddata.aLLcashBal!),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  /*Widget _buildWithdrawalCash() {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20, top: AppWidgetSize.dimen_5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildWithdrawalCashDescriptionWidget(),
          _builWithdrawalCashWidget(),
        ],
      ),
    );
  }*/

  Widget _buildRupeeWidget(String value) {
    double iconsize = AppWidgetSize.dimen_13;
    double valsize = AppWidgetSize.dimen_14;

    if (value.length > 10) {
      iconsize = AppWidgetSize.dimen_11;
      valsize = AppWidgetSize.dimen_12;
    }
    return RichText(
      textAlign: TextAlign.right,
      text: TextSpan(
        children: [
          TextSpan(
            text: '\u{20B9} ',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                fontFamily: AppConstants.interFont,
                fontSize: iconsize,
                color: Theme.of(context).textTheme.titleLarge!.color),
          ),
          TextSpan(
            text: value,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.w600, fontSize: valsize),
          ),
        ],
      ),
    );
  }

  Widget _getBaseContainerWidget(var ht, var wd, Widget childWidget) {
    return Container(
      height: ht,
      width: wd,
      color: Theme.of(context).dividerColor.withOpacity(0.15),
      child: childWidget,
    );
  }

  Widget _buildGenralDescription() {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_25, right: AppWidgetSize.dimen_25),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          children: [
            TextSpan(
              text:
                  'Withdrawable Cash represents the amount you can request to be withdrawan from your Arihant trading account after settling the pending dues. ',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextSpan(
                text: _appLocalizations.learnMore,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    decoration: TextDecoration.underline,
                    color: Theme.of(context).primaryColor),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    showInfoBottomsheet(
                      BlocProvider<ChooseBankListBloc>(
                        create: (context) => ChooseBankListBloc(),
                        child: const WithdrawalCashInfoHelpScreen(),
                      ),
                      horizontalMargin: false,
                    );
                  })
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_20,
            right: AppWidgetSize.dimen_20,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildYouCanWithdrawWidget(),
                /*Padding(
                  padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
                  child: _buildRealizedLossWidget(),
                ),
                Padding(
                  padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
                  child: _buildUnRealizedLossWidget(),
                ),
                Padding(
                  padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
                  child: _buildTodaysPayinWidget(),
                )*/
              ],
            ),
          ),
        ),
      ],
    );
  }

  Card _buildCardIwidget(
      String keydata, String title, String value, bool iscolor) {
    return Card(
      elevation: 5,
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppWidgetSize.dimen_10)),
        side: BorderSide(
          width: 0.5,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      child: SizedBox(
        width: AppWidgetSize.dimen_180,
        height: AppWidgetSize.dimen_120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(
              height: AppWidgetSize.dimen_10,
            ),
            if (keydata == 'withdraw')
              BlocBuilder<WithdrawCashInfoBloc, WithdrawCashInfoState>(
                buildWhen: (previous, current) {
                  return current is WithdrawCashDoneState ||
                      current is WithdrawCashInfoNoDataErrorState;
                },
                builder: (context, state) {
                  if (state is WithdrawCashDoneState) {
                    return _buildWithdrawCashWidget(
                        state.withdrawfund, context);
                  } else if (state is WithdrawCashInfoNoDataErrorState) {
                    return _buildWithdrawCashWidget('0.00', context);
                  }

                  return SizedBox(
                    child: Text(
                      '--',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: AppWidgetSize.dimen_24),
                    ),
                  );
                },
              )
            else
              RichText(
                text: TextSpan(
                  children: [
                    if (!value.contains('na'))
                      TextSpan(
                        text: '\u{20B9} ',
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  fontFamily: AppConstants.interFont,
                                ),
                      ),
                    TextSpan(
                      text: value,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: AppWidgetSize.dimen_24),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Padding _buildWithdrawCashWidget(String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_5,
        right: AppWidgetSize.dimen_5,
      ),
      child: (value.contains('na'))
          ? Text(
              value,
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: AppWidgetSize.dimen_24),
            )
          : RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '\u{20B9} ',
                    style: (value.length > 10)
                        ? Theme.of(context).textTheme.headlineSmall!.copyWith(
                              fontFamily: AppConstants.interFont,
                            )
                        : Theme.of(context).textTheme.displaySmall!.copyWith(
                              fontFamily: AppConstants.interFont,
                            ),
                  ),
                  TextSpan(
                    text: value,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: (value.length > 10)
                            ? AppWidgetSize.dimen_15
                            : AppWidgetSize.dimen_24),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildYouCanWithdrawWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
      ),
      child: _buildCardIwidget(
          'withdraw', 'You can withdraw', funddata.aLLpayout ?? "0.00", true),
    );
  }

  /*Widget _buildRealizedLossWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
      ),
      child: _buildCardIwidget('realizedloss', 'Realized Loss', realPnL, true),
    );
  }

  Widget _buildUnRealizedLossWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
      ),
      child: _buildCardIwidget(
          'realizedloss', 'Unrealized Loss', unrealPnL, false),
    );
  }

  Widget _buildTodaysPayinWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
      ),
      child: _buildCardIwidget(
          'realizedloss', 'Today\'s Payin', funddata.aLLpayin!, false),
    );
  }*/

  Widget _buildFooterDescriptionWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
        bottom: AppWidgetSize.dimen_10,
      ),
      child: Container(
        height: AppWidgetSize.dimen_150,
        color: Theme.of(context).snackBarTheme.backgroundColor,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_20,
            right: AppWidgetSize.dimen_20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: AppWidgetSize.dimen_25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AppImages.bankNotificationBadgelogo(context, isColor: true),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
                child: SizedBox(
                  width:
                      AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_80,
                  child: Text(
                    'Any unsettled cheque amount or payment given to Arihant today will be deducted while processing your payout request.Moreover, amount blocked for pending orders and your mark-to-mark lossess will also not be available for withdrawal.',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeductions() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
        left: AppWidgetSize.dimen_20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildDeductionsDescriptionWidget(),
          _buildDeductionsWidget(),
        ],
      ),
    );
  }

  Widget _buildDeductionsDescriptionWidget() {
    return _getBaseContainerWidget(
      AppWidgetSize.dimen_280,
      AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
      Padding(
        padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_10, left: AppWidgetSize.dimen_10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget('Deductions'),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            Padding(
              padding: EdgeInsets.only(right: AppWidgetSize.dimen_10),
              child: _buildSingleSideBoder(
                  'Unsettled Credit(Profit T-1)(-)', false),
            ),
            _buildSingleSideBoder(
                'Same day\'s and T+1 equity credits and derivative credits cannot be withdrawn',
                true),
            // _buildSingleSideBoder('(-) Payin', false),
            // _buildSingleSideBoder(
            //     'Funds transferred to Arihant today cannot be withdrawn on the same day',
            //     true),
            _buildSingleSideBoder('Utlized Margin: Eq+FO+CDS(-)', false),
            _buildSingleSideBoder(
                'Stock collateral utilized (upto 50% of margin required in cash) (span + exposure)',
                true),
          ],
        ),
      ),
    );
  }

  Widget _buildDeductionsWidget() {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_5, right: AppWidgetSize.dimen_5),
      child: _getBaseContainerWidget(
        AppWidgetSize.dimen_280,
        AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_55,
        Padding(
          padding: EdgeInsets.only(
              right: AppWidgetSize.dimen_10,
              top: AppWidgetSize.dimen_10,
              left: AppWidgetSize.dimen_10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: AppWidgetSize.dimen_40,
              ),
              _builddeductionvalue(),
              SizedBox(
                height: AppWidgetSize.dimen_80,
              ),
              _buildRupeeWidget(funddata.aLLutilizedMargin ?? "0.00"),
            ],
          ),
        ),
      ),
    );
  }

  BlocBuilder<WithdrawCashInfoBloc, WithdrawCashInfoState>
      _builddeductionvalue() {
    return BlocBuilder<WithdrawCashInfoBloc, WithdrawCashInfoState>(
      buildWhen: (previous, current) {
        return current is WithdrawCashFundViewDoneState;
      },
      builder: (context, state) {
        if (state is WithdrawCashFundViewDoneState) {
          return _buildRupeeWidget(
              state.fundViewUpdatedModel!.aLLnotnalCash ?? "0.00");
        }
        return Container();
      },
    );
  }

  Container _buildSingleSideBoder(String value, bool isStyle) {
    return Container(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_10,
        right: AppWidgetSize.dimen_10,
        bottom: AppWidgetSize.dimen_10,
      ),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 2.0,
          ),
        ),
      ),
      child: Text(
        value,
        style: isStyle
            ? Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: AppWidgetSize.fontSize12,
                )
            : Theme.of(context).textTheme.labelLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: AppWidgetSize.fontSize14),
      ),
    );
  }
}
