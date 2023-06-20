import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/my_funds/fund_details/fund_details_bloc.dart';
import '../../../../constants/app_constants.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/my_funds/my_fund_view_updated_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/refresh_widget.dart';
import '../../base/base_screen.dart';

class FundsDetailsScreen extends BaseScreen {
  final dynamic arguments;
  const FundsDetailsScreen({Key? key, this.arguments}) : super(key: key);

  @override
  FundsDetailsScreenState createState() => FundsDetailsScreenState();
}

class FundsDetailsScreenState extends BaseAuthScreenState<FundsDetailsScreen> {
  late AppLocalizations _appLocalizations;
  late FundViewUpdatedModel funddata;

  @override
  void initState() {
    super.initState();
    funddata = widget.arguments['fundmodeldata'];
    BlocProvider.of<FunddetailsBloc>(context).add(GetFundDetailsEvent(false));

    BlocProvider.of<FunddetailsBloc>(context)
        .stream
        .listen(funddetailsBlocListner);
  }

  Future<void> funddetailsBlocListner(FunddetailsState state) async {
    if (state is FundsViewDataDoneState) {
      if (state.fundViewModel == null) {
        BlocProvider.of<FunddetailsBloc>(context)
            .add(GetFundDetailsEvent(true));
      }
    } else if (state is FunddetailsProgressState) {
      if (mounted) {
        startLoader();
      }
    } else if (state is! FunddetailsProgressState) {
      if (mounted) {
        stopLoader();
      }
    } else if (state is FunddetailsErrorState) {
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
          right: AppWidgetSize.dimen_30,
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
            child: CustomTextWidget(_appLocalizations.fundView,
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
    return ScreenRoutes.funddetailsScreen;
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
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_25,
        right: AppWidgetSize.dimen_25,
      ),
      child: RefreshWidget(
        onRefresh: () async {
          BlocProvider.of<FunddetailsBloc>(context)
              .add(GetFundDetailsEvent(true));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_10,
                    bottom: AppWidgetSize.dimen_10),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      CustomTextWidget(
                          'A snapshot of the funds position in your Arihant account.',
                          Theme.of(context).textTheme.headlineSmall),
                      SizedBox(
                        height: AppWidgetSize.dimen_10,
                      ),
                      _buildAccountBalance(),
                      _buildTotalCollateral(),
                      _buildTodayspayIn(),
                      _buildUtilizedMargin(),
                      _buildCFS(),
                      _buildOptionbuypremium(),
                      _buildRealizedPandL(),
                      _buildUnRealizedPandL(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountBalance() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_5, bottom: AppWidgetSize.dimen_5),
      child: Container(
        height: AppWidgetSize.dimen_70,
        decoration: BoxDecoration(
          color:
              Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.6),
          borderRadius: BorderRadius.all(
            Radius.circular(AppWidgetSize.dimen_10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAccountBalanceDescriptionWidget(),
            _buildAccountBalanceWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCollateral() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
      child: Container(
        height: AppWidgetSize.dimen_80,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
          borderRadius: BorderRadius.all(
            Radius.circular(AppWidgetSize.dimen_10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTotalCollateralDescriptionWidget(),
            _buildTotalCollateralWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayspayIn() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
      child: Container(
        height: AppWidgetSize.dimen_70,
        decoration: BoxDecoration(
          color:
              Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.6),
          borderRadius: BorderRadius.all(
            Radius.circular(AppWidgetSize.dimen_10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTodaysPayinDescriptionWidget(),
            _buildTodaysPayinWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildCFS() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
      child: Container(
        height: AppWidgetSize.dimen_50,
        decoration: BoxDecoration(
          color:
              Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.6),
          borderRadius: BorderRadius.all(
            Radius.circular(AppWidgetSize.dimen_10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCFSDescriptionWidget(),
            _buildCFSWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilizedMargin() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
      child: Container(
        height: AppWidgetSize.dimen_80,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
          borderRadius: BorderRadius.all(
            Radius.circular(AppWidgetSize.dimen_10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildUtilizedMarginDescriptionWidget(),
            _buildUtilizedMarginWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildRealizedPandL() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
      child: Container(
        height: AppWidgetSize.dimen_80,
        decoration: BoxDecoration(
          color:
              Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.6),
          borderRadius: BorderRadius.all(
            Radius.circular(AppWidgetSize.dimen_10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRealizedPandLDescriptionWidget(),
            _buildRealizedPandLWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnRealizedPandL() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
      child: Container(
        height: AppWidgetSize.dimen_90,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
          borderRadius: BorderRadius.all(
            Radius.circular(AppWidgetSize.dimen_10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildUnRealizedPandLDescriptionWidget(),
            _buildUnRealizedPandLWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionbuypremium() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
      child: Container(
        height: AppWidgetSize.dimen_80,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
          borderRadius: BorderRadius.all(
            Radius.circular(AppWidgetSize.dimen_10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildOptionbuypremiumDescriptionWidget(),
            _buildOptionbuypremiumWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountBalanceDescriptionWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_15, left: AppWidgetSize.dimen_10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget('Account Balance'),
          SizedBox(
            height: AppWidgetSize.dimen_5,
          ),
          _buildSubTitle('Opening balance from your ledger'),
        ],
      ),
    );

    // return _getBaseContainerWidget(
    //   AppWidgetSize.dimen_70,
    //   AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
    //   Padding(
    //     padding: EdgeInsets.only(
    //         top: AppWidgetSize.dimen_15, left: AppWidgetSize.dimen_10),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         _buildTitleWidget('Account Balance'),
    //         SizedBox(
    //           height: AppWidgetSize.dimen_5,
    //         ),
    //         _buildSubTitle('Opening balance from your ledger'),
    //       ],
    //     ),
    //   ),
    // );
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

  Widget _buildAccountBalanceWidget() {
    return BlocBuilder<FunddetailsBloc, FunddetailsState>(
      buildWhen: (previous, current) {
        return current is FundsViewDataDoneState;
      },
      builder: (context, state) {
        if (state is FundsViewDataDoneState) {
          return Padding(
            padding: EdgeInsets.only(
                right: AppWidgetSize.dimen_10,
                left: AppWidgetSize.dimen_10,
                top: AppWidgetSize.dimen_15),
            child: Column(
              children: [
                _buildRupeeWidget(state.fundViewModel!.aLLcashBal ?? ""),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }

  /*Widget _buildAccountBalanceWidget() {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_5, right: AppWidgetSize.dimen_5),
      child: _getBaseContainerWidget(
        AppWidgetSize.dimen_70,
        AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_70,
        Padding(
          padding: EdgeInsets.only(
              right: AppWidgetSize.dimen_10,
              top: AppWidgetSize.dimen_15,
              left: AppWidgetSize.dimen_10),
          child: _buildRupeeWidget(funddata.aLLnetCashAvail ?? ""),
        ),
      ),
    );
  }*/

  Widget _buildTodaysPayinDescriptionWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_15, left: AppWidgetSize.dimen_10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget('Today\'s Pay-in'),
          SizedBox(
            height: AppWidgetSize.dimen_5,
          ),
          _buildSubTitle('Funds transfered today'),
        ],
      ),
    );

    // return _getBaseContainerWidget(
    //   AppWidgetSize.dimen_70,
    //   AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
    //   Padding(
    //     padding: EdgeInsets.only(
    //         top: AppWidgetSize.dimen_15, left: AppWidgetSize.dimen_10),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         _buildTitleWidget('Today\'s Payin'),
    //         SizedBox(
    //           height: AppWidgetSize.dimen_5,
    //         ),
    //         _buildSubTitle('Funds deposited today'),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _buildTodaysPayinWidget() {
    return BlocBuilder<FunddetailsBloc, FunddetailsState>(
      buildWhen: (previous, current) {
        return current is FundsViewDataDoneState;
      },
      builder: (context, state) {
        if (state is FundsViewDataDoneState) {
          return Padding(
            padding: EdgeInsets.only(
                right: AppWidgetSize.dimen_10,
                top: AppWidgetSize.dimen_15,
                left: AppWidgetSize.dimen_10),
            child: Column(
              children: [
                _buildRupeeWidget(state.fundViewModel!.aLLpayin ?? ""),
              ],
            ),
          );
        }
        return Container();
      },
    );

    // return Padding(
    //   padding: EdgeInsets.only(
    //       left: AppWidgetSize.dimen_5, right: AppWidgetSize.dimen_5),
    //   child: _getBaseContainerWidget(
    //     AppWidgetSize.dimen_70,
    //     AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_70,
    //     Padding(
    //       padding: EdgeInsets.only(
    //           right: AppWidgetSize.dimen_10,
    //           top: AppWidgetSize.dimen_15,
    //           left: AppWidgetSize.dimen_10),
    //       child: _buildRupeeWidget(funddata.aLLpayin ?? ""),
    //     ),
    //   ),
    // );
  }

  Widget _buildCFSDescriptionWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_15, left: AppWidgetSize.dimen_10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget('Credit for Sale (CFS)'),
        ],
      ),
    );

    // return _getBaseContainerWidget(
    //   AppWidgetSize.dimen_70,
    //   AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
    //   Padding(
    //     padding: EdgeInsets.only(
    //         top: AppWidgetSize.dimen_15, left: AppWidgetSize.dimen_10),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         _buildTitleWidget('Credit for Sale (CFS)'),
    //         SizedBox(
    //           height: AppWidgetSize.dimen_5,
    //         ),
    //         _buildSubTitle('Stock sold from DP,POA & CUSA')
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _buildCFSWidget() {
    return BlocBuilder<FunddetailsBloc, FunddetailsState>(
      buildWhen: (previous, current) {
        return current is FundsViewDataDoneState;
      },
      builder: (context, state) {
        if (state is FundsViewDataDoneState) {
          String value = "0.00";
          if (state.fundViewModel!.aLLcncCredit != null) {
            value = AppUtils()
                .doubleValue(state.fundViewModel!.aLLcncCredit ?? "0.00")
                .abs()
                .toString();
            value = AppUtils().commaFmt(value);
          }

          return Padding(
            padding: EdgeInsets.only(
                right: AppWidgetSize.dimen_10, left: AppWidgetSize.dimen_10),
            child: _buildRupeeWidget(value),
          );
        }
        return Container();
      },
    );

    // return Padding(
    //   padding: EdgeInsets.only(
    //       left: AppWidgetSize.dimen_5, right: AppWidgetSize.dimen_5),
    //   child: _getBaseContainerWidget(
    //     AppWidgetSize.dimen_70,
    //     AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_70,
    //     Padding(
    //       padding: EdgeInsets.only(
    //           right: AppWidgetSize.dimen_10,
    //           top: AppWidgetSize.dimen_15,
    //           left: AppWidgetSize.dimen_10),
    //       child: _buildRupeeWidget(funddata.aLLcncCredit ?? ""),
    //     ),
    //   ),
    // );
  }

  Widget _buildUtilizedMarginDescriptionWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_10, left: AppWidgetSize.dimen_10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget('Utilized Margin'),
          SizedBox(
            height: AppWidgetSize.dimen_5,
          ),
          SizedBox(
            width: AppWidgetSize.halfWidth(context),
            child: _buildSubTitle(
                'Margin blocked against the orders placed (Equity,F&O & currency)'),
          ),
        ],
      ),
    );
    // return _getBaseContainerWidget(
    //   AppWidgetSize.dimen_170,
    //   AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
    //   Padding(
    //     padding: EdgeInsets.only(
    //         top: AppWidgetSize.dimen_10, left: AppWidgetSize.dimen_10),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         _buildTitleWidget('Utilized Margin'),
    //         SizedBox(
    //           height: AppWidgetSize.dimen_5,
    //         ),
    //         _buildSubTitle(
    //             'Margin blocked against the orders placed (Equity,F&O,currency)'),
    //         SizedBox(
    //           height: AppWidgetSize.dimen_15,
    //         ),
    //         _buildSingleSideBoder('Equity'),
    //         _buildSingleSideBoder('F&O'),
    //         _buildSingleSideBoder('CDS'),
    //       ],
    //     ),
    //   ),
    // );
  }

  /*String _getUtilizedMarginValue(String utilizedmargin, String cfs) {
    String value = '0.00';

    if (utilizedmargin.isNotEmpty && cfs.isNotEmpty) {
      if (utilizedmargin.toLowerCase().contains('na') ||
          cfs.toLowerCase().contains('na')) {
        //debugPrint('contains na');
        return value;
      } else if (AppUtils().doubleValue(utilizedmargin) == 0 ||
          AppUtils().doubleValue(cfs) == 0) {
        //debugPrint('contains 0');
        return value;
      } else {
        double v = AppUtils().doubleValue(utilizedmargin) -
            AppUtils().doubleValue(cfs);
        if (v < 0) {
          //debugPrint('contains - value');
          return value;
        }
        value = v.toString();
        value = AppUtils().commaFmt(value);
      }
    }

    return value;
  }*/

  Widget _buildUtilizedMarginWidget() {
    return BlocBuilder<FunddetailsBloc, FunddetailsState>(
      buildWhen: (previous, current) {
        return current is FundsViewDataDoneState;
      },
      builder: (context, state) {
        if (state is FundsViewDataDoneState) {
          return Padding(
            padding: EdgeInsets.only(
                right: AppWidgetSize.dimen_10,
                top: AppWidgetSize.dimen_10,
                left: AppWidgetSize.dimen_10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildRupeeWidget(
                    state.fundViewModel!.aLLutilizedMargin ?? "0.00")
              ],
            ),
          );
        }
        return Container();
      },
    );

    // return Padding(
    //   padding: EdgeInsets.only(
    //       left: AppWidgetSize.dimen_5, right: AppWidgetSize.dimen_5),
    //   child: _getBaseContainerWidget(
    //     AppWidgetSize.dimen_170,
    //     AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_70,
    //     Padding(
    //       padding: EdgeInsets.only(
    //           right: AppWidgetSize.dimen_10,
    //           top: AppWidgetSize.dimen_10,
    //           left: AppWidgetSize.dimen_10),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.end,
    //         children: [
    //           _buildRupeeWidget(funddata.aLLmargnUsed ?? ""),
    //           SizedBox(
    //             height: AppWidgetSize.dimen_50,
    //           ),
    //           _buildRupeeWidget(funddata.cASHmargnUsed ?? ""),
    //           SizedBox(
    //             height: AppWidgetSize.dimen_10,
    //           ),
    //           _buildRupeeWidget(funddata.fOmargnUsed ?? ""),
    //           SizedBox(
    //             height: AppWidgetSize.dimen_10,
    //           ),
    //           _buildRupeeWidget(funddata.cURmargnUsed ?? ""),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _buildRealizedPandLDescriptionWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_15, left: AppWidgetSize.dimen_10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget('Realized P&L'),
          SizedBox(
            height: AppWidgetSize.dimen_5,
          ),
          SizedBox(
            width: AppWidgetSize.halfWidth(context),
            child: _buildSubTitle(
                'Profit or Loss on Positions closed by you Today (Equity,F&O & currency)'),
          ),
        ],
      ),
    );
    // return _getBaseContainerWidget(
    //   AppWidgetSize.dimen_170,
    //   AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
    //   Padding(
    //     padding: EdgeInsets.only(
    //         top: AppWidgetSize.dimen_10, left: AppWidgetSize.dimen_10),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         _buildTitleWidget('Realized P&L'),
    //         SizedBox(
    //           height: AppWidgetSize.dimen_5,
    //         ),
    //         _buildSubTitle('Profit or Loss on Positions closed by you Today'),
    //         SizedBox(
    //           height: AppWidgetSize.dimen_15,
    //         ),
    //         _buildSingleSideBoder('Equity'),
    //         _buildSingleSideBoder('F&O'),
    //         _buildSingleSideBoder('CDS'),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _buildRealizedPandLWidget() {
    return BlocBuilder<FunddetailsBloc, FunddetailsState>(
      buildWhen: (previous, current) {
        return current is FundsViewDataDoneState;
      },
      builder: (context, state) {
        if (state is FundsViewDataDoneState) {
          return Padding(
            padding: EdgeInsets.only(
                right: AppWidgetSize.dimen_10,
                top: AppWidgetSize.dimen_10,
                left: AppWidgetSize.dimen_10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildRupeeWidget(
                    state.fundViewModel!.aLLrealizedPNL ?? ""), //aLLrealMTM
              ],
            ),
          );
        }
        return Container();
      },
    );

    /*return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_5, right: AppWidgetSize.dimen_5),
      child: _getBaseContainerWidget(
        AppWidgetSize.dimen_170,
        AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_70,
        Padding(
          padding: EdgeInsets.only(
              right: AppWidgetSize.dimen_10,
              top: AppWidgetSize.dimen_10,
              left: AppWidgetSize.dimen_10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildRupeeWidget(funddata.aLLrealMTM ?? ""),
              SizedBox(
                height: AppWidgetSize.dimen_50,
              ),
              _buildRupeeWidget(funddata.cASHrealMTM ?? ""),
              SizedBox(
                height: AppWidgetSize.dimen_10,
              ),
              _buildRupeeWidget(funddata.fOrealMTM ?? ""),
              SizedBox(
                height: AppWidgetSize.dimen_10,
              ),
              _buildRupeeWidget(funddata.cURrealMTM ?? ""),
            ],
          ),
        ),
      ),
    );*/
  }

  Widget _buildUnRealizedPandLDescriptionWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_10, left: AppWidgetSize.dimen_10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget('UnRealized P&L'),
          SizedBox(
            height: AppWidgetSize.dimen_5,
          ),
          SizedBox(
            width: AppWidgetSize.halfWidth(context),
            child: _buildSubTitle(
                'Mark-to-market profit for your open postions (today + carryforward) (Equity,F&O & currency)'),
          ),
        ],
      ),
    );

    // return _getBaseContainerWidget(
    //   AppWidgetSize.dimen_170,
    //   AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
    //   Padding(
    //     padding: EdgeInsets.only(
    //         top: AppWidgetSize.dimen_10, left: AppWidgetSize.dimen_10),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         _buildTitleWidget('UnRealized P&L'),
    //         SizedBox(
    //           height: AppWidgetSize.dimen_5,
    //         ),
    //         _buildSubTitle(
    //             'Mark-to-market profit for your open postions (today + carryforward (Equity,F&O & currency))'),
    //         SizedBox(
    //           height: AppWidgetSize.dimen_15,
    //         ),
    //         _buildSingleSideBoder('Equity'),
    //         _buildSingleSideBoder('F&O'),
    //         _buildSingleSideBoder('CDS'),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _buildUnRealizedPandLWidget() {
    return BlocBuilder<FunddetailsBloc, FunddetailsState>(
      buildWhen: (previous, current) {
        return current is FundsViewDataDoneState;
      },
      builder: (context, state) {
        if (state is FundsViewDataDoneState) {
          return Padding(
              padding: EdgeInsets.only(
                  right: AppWidgetSize.dimen_10,
                  top: AppWidgetSize.dimen_10,
                  left: AppWidgetSize.dimen_10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildRupeeWidget(
                      state.fundViewModel!.aLLunrealizedPNL ?? ""),
                ],
              ));
        }
        return Container();
      },
    );

    // return Padding(
    //   padding: EdgeInsets.only(
    //       left: AppWidgetSize.dimen_5, right: AppWidgetSize.dimen_5),
    //   child: _getBaseContainerWidget(
    //     AppWidgetSize.dimen_170,
    //     AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_70,
    //     Padding(
    //       padding: EdgeInsets.only(
    //           right: AppWidgetSize.dimen_10,
    //           top: AppWidgetSize.dimen_10,
    //           left: AppWidgetSize.dimen_10),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.end,
    //         children: [
    //           _buildRupeeWidget(funddata.aLLViewUnrealMTM ?? ""),
    //           SizedBox(
    //             height: AppWidgetSize.dimen_50,
    //           ),
    //           _buildRupeeWidget(funddata.cASHViewUnrealMTM ?? ""),
    //           SizedBox(
    //             height: AppWidgetSize.dimen_10,
    //           ),
    //           _buildRupeeWidget(funddata.fOViewUnrealMTM ?? ""),
    //           SizedBox(
    //             height: AppWidgetSize.dimen_10,
    //           ),
    //           _buildRupeeWidget(funddata.cURViewUnrealMTM ?? ""),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _buildOptionbuypremiumDescriptionWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_10, left: AppWidgetSize.dimen_10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget('Option Net Premium'),
          SizedBox(
            height: AppWidgetSize.dimen_5,
          ),
          SizedBox(
            width: AppWidgetSize.halfWidth(context),
            child: _buildSubTitle(
                'Total Premium paid to Buy options (F&O and Currency)'),
          ),
        ],
      ),
    );

    // return _getBaseContainerWidget(
    //   AppWidgetSize.dimen_130,
    //   AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
    //   Padding(
    //     padding: EdgeInsets.only(
    //         top: AppWidgetSize.dimen_10, left: AppWidgetSize.dimen_10),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         _buildTitleWidget('Option Buy Premium'),
    //         SizedBox(
    //           height: AppWidgetSize.dimen_5,
    //         ),
    //         _buildSubTitle('Total Premium paid to Buy options'),
    //         SizedBox(
    //           height: AppWidgetSize.dimen_15,
    //         ),
    //         _buildSingleSideBoder('F&O'),
    //         _buildSingleSideBoder('CDS'),
    //       ],
    //     ),
    //   ),
    // );
  }

  String _getOptiumNetPreminumAmount(String value) {
    String v = '';
    if (value.isNotEmpty) {
      if (AppUtils().doubleValue(value) > 0) {
        double a = -AppUtils().doubleValue(value).abs();
        v = a.toString();
      } else if (AppUtils().doubleValue(value) < 0) {
        double a = AppUtils().doubleValue(value).abs();
        v = a.toString();
      } else {
        v = value;
      }
    }
    return v;
  }

  Widget _buildOptionbuypremiumWidget() {
    return BlocBuilder<FunddetailsBloc, FunddetailsState>(
      buildWhen: (previous, current) {
        return current is FundsViewDataDoneState;
      },
      builder: (context, state) {
        if (state is FundsViewDataDoneState) {
          return Padding(
            padding: EdgeInsets.only(
                right: AppWidgetSize.dimen_10,
                top: AppWidgetSize.dimen_10,
                left: AppWidgetSize.dimen_10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildRupeeWidget(_getOptiumNetPreminumAmount(
                    state.fundViewModel!.aLLpremiumPrsnt ?? "")),
              ],
            ),
          );
        }
        return Container();
      },
    );

    // return Padding(
    //   padding: EdgeInsets.only(
    //       left: AppWidgetSize.dimen_5, right: AppWidgetSize.dimen_5),
    //   child: _getBaseContainerWidget(
    //     AppWidgetSize.dimen_130,
    //     AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_70,
    //     Padding(
    //       padding: EdgeInsets.only(
    //           right: AppWidgetSize.dimen_10,
    //           top: AppWidgetSize.dimen_10,
    //           left: AppWidgetSize.dimen_10),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.end,
    //         children: [
    //           _buildRupeeWidget(funddata.aLLpremiumPrsnt ?? ""),
    //           SizedBox(
    //             height: AppWidgetSize.dimen_50,
    //           ),
    //           _buildRupeeWidget(funddata.fOpremiumPrsnt ?? ""),
    //           SizedBox(
    //             height: AppWidgetSize.dimen_10,
    //           ),
    //           _buildRupeeWidget(funddata.cURpremiumPrsnt ?? ""),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _buildTotalCollateralDescriptionWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_10, left: AppWidgetSize.dimen_10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget('Total collateral'),
          SizedBox(
            height: AppWidgetSize.dimen_5,
          ),
          SizedBox(
            width: AppWidgetSize.halfWidth(context),
            child: _buildSubTitle(
                'Stocks and other securities pledged with Arihant as per yesterday\'s LTP'),
          )
        ],
      ),
    );

    // return _getBaseContainerWidget(
    //   AppWidgetSize.dimen_70,
    //   AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
    //   Padding(
    //     padding: EdgeInsets.only(
    //         top: AppWidgetSize.dimen_10, left: AppWidgetSize.dimen_10),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         _buildTitleWidget('Total collateral'),
    //         SizedBox(
    //           height: AppWidgetSize.dimen_5,
    //         ),
    //         _buildSubTitle(
    //             'Stocks and other securities pledged with Arihant as per yesterday\'s LTP')
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _buildTotalCollateralWidget() {
    return BlocBuilder<FunddetailsBloc, FunddetailsState>(
      buildWhen: (previous, current) {
        return current is FundsViewDataDoneState;
      },
      builder: (context, state) {
        if (state is FundsViewDataDoneState) {
          return Padding(
            padding: EdgeInsets.only(
                right: AppWidgetSize.dimen_10,
                top: AppWidgetSize.dimen_10,
                left: AppWidgetSize.dimen_10),
            child: Column(
              children: [
                _buildRupeeWidget(
                    state.fundViewModel!.aLLtotalCollateralVal ?? ''),
              ],
            ),
          );
        }
        return Container();
      },
    );

    // return Padding(
    //   padding: EdgeInsets.only(
    //       left: AppWidgetSize.dimen_5, right: AppWidgetSize.dimen_5),
    //   child: _getBaseContainerWidget(
    //     AppWidgetSize.dimen_70,
    //     AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_70,
    //     Padding(
    //       padding: EdgeInsets.only(
    //           right: AppWidgetSize.dimen_10,
    //           top: AppWidgetSize.dimen_10,
    //           left: AppWidgetSize.dimen_10),
    //       child: _buildRupeeWidget(funddata.aLLcollateralVal ?? ""),
    //     ),
    //   ),
    // );
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

  // Widget _getBaseContainerWidget(var ht, var wd, Widget childWidget) {
  //   return Container(
  //     height: ht,
  //     width: wd,
  //     color: Theme.of(context).dividerColor.withOpacity(0.15),
  //     child: childWidget,
  //   );
  // }

  /*Container _buildSingleSideBoder(String value) {
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
        style: Theme.of(context).textTheme.button!.copyWith(
            fontWeight: FontWeight.w600, fontSize:AppWidgetSize.fontSize12),
      ),
    );
  }*/
}
