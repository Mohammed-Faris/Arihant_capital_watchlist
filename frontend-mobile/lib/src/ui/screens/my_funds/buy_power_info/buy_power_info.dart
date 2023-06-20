import '../../../../constants/app_constants.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../models/my_funds/my_fund_view_updated_model.dart';

import '../../../../blocs/my_funds/buy_power_info/buy_power_info_bloc.dart';
import '../../../../localization/app_localization.dart';
import '../../../navigation/screen_routes.dart';
import '../../../widgets/refresh_widget.dart';
import '../../base/base_screen.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/card_widget.dart';
import '../../../widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuyPowerInfoScreen extends BaseScreen {
  final dynamic arguments;
  const BuyPowerInfoScreen({Key? key, this.arguments}) : super(key: key);

  @override
  BuyPowerInfoScreenState createState() => BuyPowerInfoScreenState();
}

class BuyPowerInfoScreenState extends BaseAuthScreenState<BuyPowerInfoScreen> {
  late AppLocalizations _appLocalizations;
  late FundViewUpdatedModel funddata;
  String realPL = '';
  String unrealPL = '';

  @override
  void initState() {
    super.initState();
    funddata = widget.arguments['fundmodeldata'];

    BlocProvider.of<BuyPowerInfoBloc>(context)
        .stream
        .listen(buyPowerInfoBlocListener);
    // AppStorage().removeData('getFundViewUpdatedModel');
    BlocProvider.of<BuyPowerInfoBloc>(context)
        .add(GetAvailableFundsEvent()..fundViewUpdatedModel = null);
  }

  Future<void> buyPowerInfoBlocListener(BuyPowerInfoState state) async {
    if (state is BuyPowerInfoProgressState) {
      if (mounted) {
        startLoader();
      }
    } else if (state is! BuyPowerInfoProgressState) {
      if (mounted) {
        stopLoader();
      }
    } else if (state is BuyPowerInfoErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
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
            child: CustomTextWidget(_appLocalizations.buyingPower,
                Theme.of(context).textTheme.displayMedium),
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
    return ScreenRoutes.buyPowerInfoScreen;
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: RefreshWidget(
            onRefresh: () async {
              // AppStorage().removeData('getFundViewUpdatedModel');
              BlocProvider.of<BuyPowerInfoBloc>(context)
                  .add(GetAvailableFundsEvent()..fundViewUpdatedModel = null);
            },
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildGenralDescription(),
                Center(child: _buildCardWidget()),
                _buildFooterDescriptionWidget(),
                _builDataWidget(),
              ],
            ),
          ),
        ),
        _buildNeedHelpWidget(),
      ],
    );
  }

  Widget _buildNeedHelpWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_25),
      child: InkWell(
        onTap: () {
          pushNavigation(ScreenRoutes.buyPowerInfoHelpScreen);
        },
        child: CustomTextWidget(
            AppLocalizations.of(context)!.generalNeedHelp,
            Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w400)),
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
          _buildUnsettledCredits(),
          _buildTodayspayinBalance(),
          _buildTotalCollateralStock(),
          _buildStockCFS(),
          _buildUtilizedMargin(),
          //_buildMyBuyingPower(),
        ],
      ),
    );
  }

  Widget _buildAccountBalance() {
    return Padding(
      padding: EdgeInsets.only(left: AppWidgetSize.dimen_20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildAccountBalanceDescriptionWidget(),
          _buildAccountBalanceWidget(),
        ],
      ),
    );
  }

  Widget _buildUnsettledCredits() {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20, top: AppWidgetSize.dimen_5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildUnsettledCreditDescriptionWidget(),
          _buildUnsettledCreditWidget(),
        ],
      ),
    );
  }

  Widget _buildTodayspayinBalance() {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20, top: AppWidgetSize.dimen_5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildTodaysPayinDescriptionWidget(),
          _buildTodaysPayinWidget(),
        ],
      ),
    );
  }

  Widget _buildTotalCollateralStock() {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20, top: AppWidgetSize.dimen_5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildTotalCollateralStockDescriptionWidget(),
          _buildTotalCollateralStockWidget(),
        ],
      ),
    );
  }

  Widget _buildStockCFS() {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20, top: AppWidgetSize.dimen_5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildStockCFSDescriptionWidget(),
          _builStockCFSnWidget(),
        ],
      ),
    );
  }

  /*Widget _buildMyBuyingPower() {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20, top: AppWidgetSize.dimen_5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildMyBuyingPowerDescriptionWidget(),
          _builMyBuyingPowerWidget(),
        ],
      ),
    );
  }*/

  Widget _buildUtilizedMargin() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
        left: AppWidgetSize.dimen_20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildUtilizedMarginDescriptionWidget(),
          _buildUtilizedMarginWidget(),
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
    return BlocBuilder<BuyPowerInfoBloc, BuyPowerInfoState>(
      buildWhen: (previous, current) {
        return current is AvailableFundsDoneState;
      },
      builder: (context, state) {
        if (state is AvailableFundsDoneState) {
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
                child:
                    _buildRupeeWidget(state.fundViewUpdatedModel!.aLLcashBal!),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildUnsettledCreditDescriptionWidget() {
    return _getBaseContainerWidget(
      AppWidgetSize.dimen_70,
      AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
      Padding(
        padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_15, left: AppWidgetSize.dimen_10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget('Unsettled Credits (-)'),
            SizedBox(
              height: AppWidgetSize.dimen_5,
            ),
            _buildSubTitle('Previous day intraday profit (T-1)')
          ],
        ),
      ),
    );
  }

  Widget _buildUnsettledCreditWidget() {
    return BlocBuilder<BuyPowerInfoBloc, BuyPowerInfoState>(
      buildWhen: (previous, current) {
        return current is AvailableFundsDoneState;
      },
      builder: (context, state) {
        if (state is AvailableFundsDoneState) {
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
                child: _buildRupeeWidget(
                    state.fundViewUpdatedModel!.aLLnotnalCash ?? ""),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildTodaysPayinDescriptionWidget() {
    return _getBaseContainerWidget(
      AppWidgetSize.dimen_70,
      AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
      Padding(
        padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_15, left: AppWidgetSize.dimen_10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget('Todays cash payin (+)'),
            SizedBox(
              height: AppWidgetSize.dimen_5,
            ),
            _buildSubTitle('Cash transferred to Arihant today')
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysPayinWidget() {
    return BlocBuilder<BuyPowerInfoBloc, BuyPowerInfoState>(
      buildWhen: (previous, current) {
        return current is AvailableFundsDoneState;
      },
      builder: (context, state) {
        if (state is AvailableFundsDoneState) {
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
                child: _buildRupeeWidget(
                    state.fundViewUpdatedModel!.aLLpayin ?? ""),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildTotalCollateralStockDescriptionWidget() {
    return _getBaseContainerWidget(
      AppWidgetSize.dimen_80,
      AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
      Padding(
        padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_15, left: AppWidgetSize.dimen_10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget('Total Collateral (+)'),
            SizedBox(
              height: AppWidgetSize.dimen_5,
            ),
            _buildSubTitle('Stocks and other securities pledged with Arihant')
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCollateralStockWidget() {
    return BlocBuilder<BuyPowerInfoBloc, BuyPowerInfoState>(
      buildWhen: (previous, current) {
        return current is AvailableFundsDoneState;
      },
      builder: (context, state) {
        if (state is AvailableFundsDoneState) {
          return Padding(
            padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_5, right: AppWidgetSize.dimen_5),
            child: _getBaseContainerWidget(
              AppWidgetSize.dimen_80,
              AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_55,
              Padding(
                padding: EdgeInsets.only(
                    right: AppWidgetSize.dimen_10,
                    top: AppWidgetSize.dimen_15,
                    left: AppWidgetSize.dimen_10),
                child: _buildRupeeWidget(
                    state.fundViewUpdatedModel!.aLLtotalCollateralVal ?? ""),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  /*Widget _buildMyBuyingPowerDescriptionWidget() {
    return _getBaseContainerWidget(
      AppWidgetSize.dimen_60,
      AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
      Padding(
        padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_15, left: AppWidgetSize.dimen_10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildTitleWidget('My Buying Power')],
        ),
      ),
    );
  }

  Widget _builMyBuyingPowerWidget() {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_5, right: AppWidgetSize.dimen_5),
      child: _getBaseContainerWidget(
        AppWidgetSize.dimen_60,
        AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_55,
        Padding(
          padding: EdgeInsets.only(
              right: AppWidgetSize.dimen_10,
              top: AppWidgetSize.dimen_15,
              left: AppWidgetSize.dimen_10),
          child: _buildRupeeWidget(funddata.aLLbuypwr ?? ""),
        ),
      ),
    );
  }*/

  Widget _buildStockCFSDescriptionWidget() {
    return _getBaseContainerWidget(
      AppWidgetSize.dimen_70,
      AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
      Padding(
        padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_15, left: AppWidgetSize.dimen_10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget('Stock CFS (+)'),
            SizedBox(
              height: AppWidgetSize.dimen_5,
            ),
            _buildSubTitle('DP CFS + Pool CFS')
          ],
        ),
      ),
    );
  }

  Widget _builStockCFSnWidget() {
    return BlocBuilder<BuyPowerInfoBloc, BuyPowerInfoState>(
      buildWhen: (previous, current) {
        return current is AvailableFundsDoneState;
      },
      builder: (context, state) {
        if (state is AvailableFundsDoneState) {
          String value = "0.00";
          if (state.fundViewUpdatedModel!.aLLcncCredit != null) {
            value = AppUtils()
                .doubleValue(state.fundViewUpdatedModel!.aLLcncCredit ?? "0.00")
                .abs()
                .toString();
            value = AppUtils().commaFmt(value);
          }
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
                child: _buildRupeeWidget(value),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildUtilizedMarginDescriptionWidget() {
    return _getBaseContainerWidget(
      AppWidgetSize.dimen_220,
      AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
      Padding(
        padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_10, left: AppWidgetSize.dimen_10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget('Utilized Margin (-)'),
            SizedBox(
              height: AppWidgetSize.dimen_5,
            ),
            SizedBox(
              height: AppWidgetSize.dimen_15,
            ),
            _buildSingleSideBoder('Margin Blocked', false),
            _buildSingleSideBoder(
                'EQ + F&O and CDS(span+exposure)+Option premium+margin for pending orders',
                true),
            _buildSingleSideBoder('Unrealised M2M Loss', false),
            _buildSingleSideBoder('Realized M2M Loss', false),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilizedMarginWidget() {
    return BlocBuilder<BuyPowerInfoBloc, BuyPowerInfoState>(
      buildWhen: (previous, current) {
        return current is AvailableFundsDoneState;
      },
      builder: (context, state) {
        if (state is AvailableFundsDoneState) {
          return Padding(
            padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_5, right: AppWidgetSize.dimen_5),
            child: _getBaseContainerWidget(
              AppWidgetSize.dimen_220,
              AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_55,
              Padding(
                padding: EdgeInsets.only(
                    right: AppWidgetSize.dimen_10,
                    top: AppWidgetSize.dimen_10,
                    left: AppWidgetSize.dimen_10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildRupeeWidget(
                        state.fundViewUpdatedModel!.aLLutilizedMargin ??
                            "0.00"),
                    SizedBox(
                      height: AppWidgetSize.dimen_20,
                    ),
                    SizedBox(
                      height: AppWidgetSize.dimen_80,
                    ),
                    const Text(''),
                    SizedBox(
                      height: AppWidgetSize.dimen_10,
                    ),
                    const Text(''),
                  ],
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

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
                color: Theme.of(context).textTheme.headlineMedium!.color),
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
      color: Theme.of(context).dividerColor.withOpacity(0.3),
      child: childWidget,
    );
  }

  Widget _buildFooterDescriptionWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
        bottom: AppWidgetSize.dimen_10,
      ),
      child: Container(
        height: AppWidgetSize.dimen_80,
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
              AppImages.bankNotificationBadgelogo(context, isColor: true),
              Padding(
                padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
                child: SizedBox(
                  width:
                      AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_80,
                  child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'On selling your Demat holdings, 80% of the sale value will be available to trade the same day. The rest 20% will be available on the next day. ',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        /*  TextSpan(
                          text: AppLocalizations().learnMore,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  color: Theme.of(context).primaryColor,
                                  decoration: TextDecoration.underline),
                        ), */
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardWidget() {
    return BlocBuilder<BuyPowerInfoBloc, BuyPowerInfoState>(
      buildWhen: (previous, current) {
        return current is AvailableFundsDoneState;
      },
      builder: (context, state) {
        if (state is AvailableFundsDoneState) {
          return Padding(
            padding: EdgeInsets.only(top: AppWidgetSize.dimen_20),
            child: CardWidget(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: EdgeInsets.all(AppWidgetSize.dimen_25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Buying Power',
                        style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(
                      height: AppWidgetSize.dimen_10,
                    ),
                    CustomTextWidget(
                      '\u{20B9} ${state.fundViewUpdatedModel!.aLLbuypwr!}',
                      Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: AppUtils().profitLostColor(
                              state.fundViewUpdatedModel?.aLLbuypwr),
                          fontWeight: FontWeight.w600,
                          fontSize:
                              (state.fundViewUpdatedModel!.aLLbuypwr!.length >
                                      10)
                                  ? AppWidgetSize.dimen_20
                                  : AppWidgetSize.dimen_24),
                    )
                  ],
                ),
              ),
            ),
          );
        }
        return Container();
      },
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
                  'Buying power is the amount of money you can use to purchase stocks,ETFs or derivatives through Arihant Capital. This amount includes your cash and collateral. This amount is different from your account balance, which is your ledger balance. ',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            /*  TextSpan(
              text: AppLocalizations().learnMore,
              style: Theme.of(context).textTheme.headline6!.copyWith(
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline),
            ), */
          ],
        ),
      ),
    );
  }

  Container _buildSingleSideBoder(String value, bool isStyle) {
    return Container(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_10,
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
