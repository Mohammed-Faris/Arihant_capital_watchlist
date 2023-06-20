import 'package:acml/src/ui/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/utils/config/errorMsgConfig.dart';

import '../../../../blocs/my_funds/funds/my_funds_bloc.dart';
import '../../../../constants/app_constants.dart';
import '../../../../constants/app_events.dart';
import '../../../../constants/keys/widget_keys.dart';
import '../../../../data/repository/my_account/my_account_repository.dart';
import '../../../../data/store/app_storage.dart';
import '../../../../data/store/app_store.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/my_funds/my_fund_view_updated_model.dart';
import '../../../../models/my_funds/transaction_history_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_color.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/account_suspended.dart';
import '../../../widgets/card_widget.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/gradient_button_widget.dart';
import '../../../widgets/list_tile_widget.dart';
import '../../../widgets/refresh_widget.dart';
import '../../base/base_screen.dart';

class MyFundsScreen extends BaseScreen {
  final dynamic arguments;
  const MyFundsScreen({Key? key, this.arguments}) : super(key: key);

  @override
  MyFundsScreenState createState() => MyFundsScreenState();
}

class MyFundsScreenState extends BaseAuthScreenState<MyFundsScreen> {
  bool withinLimit = true;
  String withdrawcash = '0.00';

  @override
  void initState() {
    super.initState();
    scrollListerner();
    fetchAccInfo();
    BlocProvider.of<MyFundsBloc>(context).stream.listen(myfundsListener);

    BlocProvider.of<MyFundsBloc>(context).add(GetFundsViewUpdatedEvent());
    BlocProvider.of<MyFundsBloc>(context).add(GetFundsViewEvent());
    BlocProvider.of<MyFundsBloc>(context)
        .add(GetMaxPayoutWithdrawalCashEvent());
    BlocProvider.of<MyFundsBloc>(context).add(GetTransactionHistoryEvent());
  }

  fetchAccInfo() async {
    await MyAccountRepository().getAccountInfo();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollControllerForTopContent.removeListener(() {});
  }

  Future<void> myfundsListener(MyFundsState state) async {
    if (state is MyFundsTransactionHistoryCancelDoneState) {
      BlocProvider.of<MyFundsBloc>(context).add(GetFundsViewEvent());
      BlocProvider.of<MyFundsBloc>(context)
          .add(GetMaxPayoutWithdrawalCashEvent());
      BlocProvider.of<MyFundsBloc>(context).add(GetTransactionHistoryEvent());
      showToast(
        message: state.message,
        context: context,
        isError: false,
      );
    } else if (state is MyFundsTransactionHistoryCancelFailedDoneState) {
      showToast(
        message: state.message,
        context: context,
        isError: true,
      );
    } else if (state is MyFundsWithdrawalErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state is MyFundsErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      } else if (state.isInvalidException == false) {
        showToastFixed(
            message: state.errorCode == "S01"
                ? ErrorMsgConfig.not_able_to_resolve_service
                : state.errorMsg,
            context: context,
            isError: true,
            color: noInternetColor);
      }
    } else if (state is MyFundsCancelErrorState) {
      showToast(
        message: state.errorMsg,
        context: context,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
      ),
      resizeToAvoidBottomInset: true,
      body: RefreshWidget(
        onRefresh: () async {
          fetchAccInfo();
          BlocProvider.of<MyFundsBloc>(context)
              .add(GetFundsViewEvent(fetchApi: true));
          BlocProvider.of<MyFundsBloc>(context)
              .add(GetFundsViewUpdatedEvent(fetchApi: true));

          BlocProvider.of<MyFundsBloc>(context)
              .add(GetMaxPayoutWithdrawalCashEvent(fetchApi: true));
          BlocProvider.of<MyFundsBloc>(context)
              .add(GetTransactionHistoryEvent());
        },
        child: _buildBody(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildfooterView(),
    );
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.myfundsScreen;
  }

  ValueNotifier<bool> isScrolledToTop = ValueNotifier<bool>(false);

  final ScrollController _scrollControllerForTopContent = ScrollController();
  void scrollListerner() {
    _scrollControllerForTopContent.addListener(
      () {
        isScrolledToTop.value = false;
      },
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<bool>(
      valueListenable: isScrolledToTop,
      builder: (context, value, _) {
        return ListView(
          // physics: const ClampingScrollPhysics(),
          children: [
            _buildAvialableBalanceDetailsAndFundsView(value),
            _buildRecentTransactionHeader(),
            _buildRecentTransactionDetails(value),
          ],
        );
      },
    );
  }

  Widget _buildAvialableBalanceDetailsAndFundsView(bool isHide) {
    return SizedBox(
      height: (AppUtils.isTablet ? 230.w : 270.w) +
          (isHide ? (-AppWidgetSize.dimen_30) : 120.w),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          _buildBalanceWidget(isHide),
          if (!isHide) _buildfundDetailWidget()
        ],
      ),
    );
  }

  Widget _buildBalanceWidget(bool isHide) {
    return Container(
      height: 250.w + (isHide ? (-AppWidgetSize.dimen_50) : 0),
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_70),
      color: Theme.of(context).snackBarTheme.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvialFundDescription(),
          SizedBox(height: 10.w),
          _buildAvialFundsBalance(),
          _buildBuyPowerandWithdrawalCash()
        ],
      ),
    );
  }

  Widget _buildBuyPowerData() {
    return BlocBuilder<MyFundsBloc, MyFundsState>(
      buildWhen: (previous, current) {
        return current is BuyPowerandWithdrawcashDoneState;
      },
      builder: (context, state) {
        if (state is BuyPowerandWithdrawcashDoneState) {
          return SizedBox(
            width:
                AppWidgetSize.screenWidth(context) / 2 - AppWidgetSize.dimen_30,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _getLableWithRupeeSymbol(
                state.buy_power,
                Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontFamily: AppConstants.interFont,
                      color: AppUtils().doubleValue(state.buy_power).isNegative
                          ? AppColors.negativeColor
                          : AppColors().positiveColor,
                    ),
                Theme.of(context).textTheme.displaySmall!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppUtils().doubleValue(state.buy_power).isNegative
                          ? AppColors.negativeColor
                          : AppColors().positiveColor,
                    ),
              ),
            ),
          );
        }

        return _getLableWithRupeeSymbol(
          '--',
          Theme.of(context).textTheme.titleSmall!.copyWith(
                fontFamily: AppConstants.interFont,
              ),
          Theme.of(context).textTheme.displaySmall!.copyWith(
                fontWeight: FontWeight.w500,
              ),
        );
      },
    );
  }

  Widget _buildWithdrawCashData() {
    return BlocBuilder<MyFundsBloc, MyFundsState>(
      buildWhen: (previous, current) {
        return current is GetMaxPayoutWithdrawCashDoneState ||
            current is MyFundsWithdrawalErrorState;
      },
      builder: (context, state) {
        if (state is GetMaxPayoutWithdrawCashDoneState) {
          withdrawcash = state.availableFunds;
          if (state.availableFunds.contains('na')) {
            return SizedBox(
                width: AppWidgetSize.screenWidth(context) / 2 -
                    AppWidgetSize.dimen_30,
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(state.availableFunds,
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  fontWeight: FontWeight.w500,
                                ))));
          }

          withdrawcash = state.availableFunds;
        } else if (state is MyFundsWithdrawalErrorState) {
          withdrawcash = "0.00";
        }
        return SizedBox(
            width:
                AppWidgetSize.screenWidth(context) / 2 - AppWidgetSize.dimen_30,
            child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _getLableWithRupeeSymbol(
                  withdrawcash,
                  Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontFamily: AppConstants.interFont,
                      ),
                  Theme.of(context).textTheme.displaySmall!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                )));
      },
    );
  }

  Widget _buildBuyPowerandWithdrawalCash() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBuyPowerDescription(),
            SizedBox(height: 10.w),
            _buildBuyPowerData(),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildWithdrawCashDescription(),
            SizedBox(height: 10.w),
            _buildWithdrawCashData(),
          ],
        )
      ],
    );
  }

  Widget _buildAvialFundsBalance() {
    return BlocBuilder<MyFundsBloc, MyFundsState>(
      buildWhen: (previous, current) {
        return current is BuyPowerandWithdrawcashDoneState;
      },
      builder: (context, state) {
        if (state is BuyPowerandWithdrawcashDoneState) {
          return _getLableWithRupeeSymbol(
            state.account_balance,
            Theme.of(context).primaryTextTheme.displaySmall?.copyWith(
                fontFamily: AppConstants.interFont,
                color: AppUtils().doubleValue(state.account_balance).isNegative
                    ? AppColors.negativeColor
                    : AppColors().positiveColor),
            Theme.of(context).primaryTextTheme.displaySmall?.copyWith(
                fontSize: AppWidgetSize.dimen_24,
                fontWeight: FontWeight.bold,
                color: AppUtils().doubleValue(state.account_balance).isNegative
                    ? AppColors.negativeColor
                    : AppColors().positiveColor),
          );
        }
        return _getLableWithRupeeSymbol(
          '',
          Theme.of(context).primaryTextTheme.displaySmall?.copyWith(
                fontFamily: AppConstants.interFont,
              ),
          Theme.of(context).primaryTextTheme.displaySmall?.copyWith(
              fontSize: AppWidgetSize.dimen_24, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  Widget _getLableWithRupeeSymbol(
    String value,
    TextStyle? rupeeStyle,
    TextStyle? textStyle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextWidget(
          "₹ $value",
          textStyle,
          isShowShimmer: true,
        ),
      ],
    );
  }

  Padding _buildAvialFundDescription() {
    return Padding(
      padding: EdgeInsets.only(top: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextWidget(AppLocalizations().accountBalance,
              Theme.of(context).textTheme.titleLarge),
          InkWell(
            onTap: () {
              _showAccountBalaceDescription();
            },
            child: Padding(
              padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
              child: AppImages.infoIcon(
                context,
                color: Theme.of(context).primaryIconTheme.color,
                isColor: true,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showAccountBalaceDescription() {
    showInfoBottomsheet(_buildaccountbalancedescriptionWidget(),
        horizontalMargin: false, topMargin: true, bottomMargin: 40.w);
  }

  Widget _buildaccountbalancedescriptionWidget() {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20, right: AppWidgetSize.dimen_20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations().accntBalheading,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                InkWell(
                  child: AppImages.close(
                    context,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: AppWidgetSize.dimen_20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations().accntBalinfo,
                    style: Theme.of(context).textTheme.headlineSmall!,
                  ),
                ),
              ],
            ),
          ),
          /*  Padding(
            padding: EdgeInsets.only(top: AppWidgetSize.dimen_20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations().learnMore,
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ), */
        ],
      ),
    );
  }

  Widget _buildarecenttransactiondescriptionWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_20, right: AppWidgetSize.dimen_20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.recentTransaction,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              InkWell(
                child: AppImages.close(
                  context,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_20,
              left: AppWidgetSize.dimen_20,
              right: AppWidgetSize.dimen_20),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  "Recent transactions is a snapshot of all your fund transactions with Arihant. This includes all transfers done between Arihant trading account and your bank account (deposits and withdrawals) through both online & offline modes (including cheque payments, NEFT/RTGS transfers).",
                  maxLines: 10,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showRecentTransactionDescription() {
    showInfoBottomsheet(
      _buildarecenttransactiondescriptionWidget(),
      horizontalMargin: false,
      topMargin: true,
    );
  }

  Widget _buildBuyPowerDescription() {
    return Padding(
      padding: EdgeInsets.only(top: 15.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextWidget(AppLocalizations().buyingPower,
              Theme.of(context).textTheme.titleLarge),
          GestureDetector(
            onTap: () async {
              dynamic data =
                  await AppStorage().getData('getFundViewUpdatedModel');

              FundViewUpdatedModel fundViewUpdatedModel =
                  FundViewUpdatedModel.datafromJson(data);

              pushNavigation(
                ScreenRoutes.buyPowerInfoScreen,
                arguments: {"fundmodeldata": fundViewUpdatedModel},
              );
            },
            child: Padding(
              padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
              child: AppImages.infoIcon(
                context,
                color: Theme.of(context).primaryIconTheme.color,
                isColor: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawCashDescription() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextWidget(AppLocalizations().withDrawalcash,
              Theme.of(context).textTheme.titleLarge),
          GestureDetector(
            onTap: () async {
              dynamic data =
                  await AppStorage().getData('getFundViewUpdatedModel');

              FundViewUpdatedModel fundViewUpdatedModel =
                  FundViewUpdatedModel.datafromJson(data);

              pushNavigation(
                ScreenRoutes.withdrawalCashinfoScreen,
                arguments: {
                  "fundmodeldata": fundViewUpdatedModel,
                  "maxpayout": withdrawcash
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
              child: AppImages.infoIcon(
                context,
                color: Theme.of(context).primaryIconTheme.color,
                isColor: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Positioned _buildfundDetailWidget() {
    return Positioned(
      top: 280.w - 80.w,
      child: CardWidget(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          alignment: Alignment.center,
          child: _fundsWidgets(context),
        ),
      ),
    );
  }

  Widget _fundsWidgets(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_1),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _getFundsOptions(context).length,
      itemBuilder: (context, index) {
        return _getFundsOptions(context)[index];
      },
    );
  }

  List<Widget> _getFundsOptions(BuildContext context) {
    return [
      ListTileWidget(
        //margin: EdgeInsets.only(top: AppWidgetSize.dimen_7),
        title: AppLocalizations().fundView,
        subtitle: AppLocalizations().snapshotFundposition,
        leadingImage: AppImages.funddetails(context, height: 28.w, width: 28.w),
        titleTextStyle: Theme.of(context).textTheme.headlineMedium,
        arrowIconSize: 15.0.w,
        //  isBackgroundOther: true,
        onTap: () async {
          dynamic data = await AppStorage().getData('getFundViewUpdatedModel');

          FundViewUpdatedModel fundViewUpdatedModel =
              FundViewUpdatedModel.datafromJson(data);

          pushNavigation(
            ScreenRoutes.funddetailsScreen,
            arguments: {"fundmodeldata": fundViewUpdatedModel},
          );
        },
      ),
      ListTileWidget(
          hideDivider: true,
          // margin: EdgeInsets.only(bottom: AppWidgetSize.dimen_7),
          title: AppLocalizations().fundHistory,
          subtitle: AppLocalizations().historyCashpay,
          leadingImage:
              AppImages.fundhistory(context, height: 28.w, width: 28.w),
          arrowIconSize: 15.0.w,
          titleTextStyle: Theme.of(context).textTheme.headlineMedium,
          onTap: () {
            pushNavigation(ScreenRoutes.fundhistoryScreen, arguments: {});
          }),
    ];
  }

  Widget _buildRecentTransactionHeader() {
    return Padding(
      padding: EdgeInsets.only(left: AppWidgetSize.dimen_30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomTextWidget(AppLocalizations().recentTransaction,
                  Theme.of(context).textTheme.displaySmall),
              InkWell(
                onTap: () {
                  _showRecentTransactionDescription();
                },
                child: Padding(
                  padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
                  child: AppImages.infoIcon(
                    context,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_10, right: AppWidgetSize.dimen_40),
            child: Container(
              height: AppWidgetSize.dimen_1,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ],
      ),
    );
  }

  _buildListRow(MyFundsTransactionHistoryDoneState stateObj) {
    List<Widget> widgetList = [];

    List<History> historylist = stateObj.transactionHistoryModel!.history!;
    if (stateObj.transactionHistoryModel!.history!.length >= 5) {
      historylist = stateObj.transactionHistoryModel!.history!.sublist(0, 5);
    }

    for (var history in historylist) {
      widgetList.add(_buildDataRow(history));
    }

    widgetList.add(_buildViewMoreOption());

    return ListView.builder(
        padding: EdgeInsets.only(bottom: 10.w),
        controller: _scrollControllerForTopContent,
        itemCount: historylist.take(5).length,
        itemBuilder: (context, index) =>
            (historylist.take(5).length == index + 1)
                ? Column(
                    children: [
                      _buildDataRow(historylist[index]),
                      _buildViewMoreOption(),
                    ],
                  )
                : _buildDataRow(historylist[index]));
  }

  Widget _buildRecentTransactionDetails(bool isHide) {
    return BlocBuilder<MyFundsBloc, MyFundsState>(
      buildWhen: (previous, current) {
        return current is MyFundsTransactionHistoryDoneState ||
            current is MyFundsTransactionErrorState;
      },
      builder: (context, state) {
        if (state is MyFundsTransactionHistoryDoneState) {
          return SizedBox(
            height: 200.w,
            child: RefreshWidget(
              onRefresh: () async {
                AppStorage().removeData('getRecentFundTransaction');
                BlocProvider.of<MyFundsBloc>(context)
                    .add(GetTransactionHistoryEvent());
              },
              child: _buildListRow(state),
            ),
          );
        } else if (state is MyFundsTransactionErrorState) {
          return SizedBox(
            height: 150.w,
            child: Center(
              child: Text(
                state.errorMsg,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildViewMoreOption() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
        bottom: AppWidgetSize.dimen_45,
        right: AppWidgetSize.dimen_40,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              _scrollControllerForTopContent.animateTo(0,
                  duration: const Duration(seconds: 1), curve: Curves.ease);
              pushNavigation(ScreenRoutes.fundhistoryScreen, arguments: {});
            },
            child: CustomTextWidget(
                AppLocalizations.of(context)!.viewMore,
                Theme.of(context)
                    .primaryTextTheme
                    .labelLarge!
                    .copyWith(color: Theme.of(context).primaryColor)),
          )
        ],
      ),
    );
  }

  Widget _buildDataRow(History data) {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_10,
          right: AppWidgetSize.dimen_40,
          bottom: AppWidgetSize.dimen_5),
      child: InkWell(
        onTap: () {
          _showDeatilsBottomSheet(data);
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AppUtils.buildMoneyIcon(context, data),
                    _buildWithdrawandAddStatusWidget(data),
                  ],
                ),
                _buildDateandAmountWidget(data),
              ],
            ),
            _buildSeperatorWidget()
          ],
        ),
      ),
    );
  }

  String? _getTransTypeorBankAcc(History data) {
    if (data.payIn == true) {
      return data.transType ?? "";
    } else {
      return data.dispAccnumber;
    }
  }

  Column _buildWithdrawandAddStatusWidget(History data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: AppWidgetSize.dimen_20,
          width:
              AppWidgetSize.screenWidth(context) / 2 - AppWidgetSize.dimen_45,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              AppUtils.getPayInStatus(context, data) ?? "",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Text(
          _getTransTypeorBankAcc(data) ?? "",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Padding _buildSeperatorWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
        left: AppWidgetSize.dimen_20,
      ),
      child: Container(
          height: AppWidgetSize.dimen_1, color: Theme.of(context).dividerColor),
    );
  }

  Padding _buildDateandAmountWidget(History data) {
    return Padding(
      padding: EdgeInsets.only(right: AppWidgetSize.dimen_1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_80,
            child: _buildAmountWidget(data),
          ),
          Text(data.date ?? "", style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _buildAmountWidget(History data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(AppConstants.rupeeSymbol,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontFamily: AppConstants.interFont,
                color: (data.payIn == true)
                    ? AppColors().positiveColor
                    : AppColors.negativeColor),
            textAlign: TextAlign.right),
        Flexible(
          child: Text(
            AppUtils().commaFmt(
              data.amt!.replaceAll(",", ""),
            ),
            maxLines: 2,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: (data.payIn == true)
                    ? AppColors().positiveColor
                    : AppColors.negativeColor),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildfooterView() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      height: AppWidgetSize.dimen_55,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonWidget(AppLocalizations().addFunds),
          _buildButtonWidget(AppLocalizations().withDraw),
        ],
      ),
    );
  }

  Widget _buildButtonWidget(String titlevalue) {
    return gradientButtonWidget(
      onTap: () async {
        sendEventToFirebaseAnalytics(
          titlevalue == AppLocalizations().addFunds
              ? AppEvents.addfundsClick
              : AppEvents.withdrawfundsClick,
          ScreenRoutes.myfundsScreen,
          'clicked $titlevalue button in myfunds screen',
        );

        if (AppStore().isAccountActivated) {
          if (titlevalue == AppLocalizations().addFunds) {
            var result = await pushNavigation(ScreenRoutes.addfundsScreen);
            if (!mounted) {
              return;
            }
            if (result == null) {
              BlocProvider.of<MyFundsBloc>(context)
                  .add(GetFundsViewEvent(fetchApi: true));
              BlocProvider.of<MyFundsBloc>(context)
                  .add(GetMaxPayoutWithdrawalCashEvent());
              BlocProvider.of<MyFundsBloc>(context)
                  .add(GetTransactionHistoryEvent());
            }
          } else {
            var result = await pushNavigation(ScreenRoutes.withdrawfundsScreen);
            if (!mounted) {
              return;
            }
            if (result == null) {
              BlocProvider.of<MyFundsBloc>(context)
                  .add(GetFundsViewEvent(fetchApi: true));
              BlocProvider.of<MyFundsBloc>(context)
                  .add(GetMaxPayoutWithdrawalCashEvent());
              BlocProvider.of<MyFundsBloc>(context)
                  .add(GetTransactionHistoryEvent());
            }
          }
        } else {
          showInfoBottomsheet(suspendedAccount(context));
        }
      },
      width: AppWidgetSize.dimen_120,
      height: AppWidgetSize.dimen_45,
      key: const Key(emptyWidgetButton1Key),
      context: context,
      bottom: 0,
      title: titlevalue,
      isGradient: true,
    );
  }

  void _showDeatilsBottomSheet(History data) {
    showInfoBottomsheet(_buildDetailViewWidget(data),
        horizontalMargin: false, topMargin: false);
  }

  void _showCancelTransactionConfirmationBottomSheet(History data) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      isScrollControlled: false,
      enableDrag: false,
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
      ),
      builder: (BuildContext bct) {
        return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(AppWidgetSize.dimen_20),
              ),
            ),
            child: _buildCancelTransactionConfirmation(data));
      },
    );
  }

  Widget _buildCancelTransactionConfirmation(History data) {
    return SizedBox(
      height: AppWidgetSize.dimen_120,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_10,
                right: AppWidgetSize.dimen_10,
                top: AppWidgetSize.dimen_30),
            child: CustomTextWidget(
              'Would you like to Cancel this Transaction?',
              Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: AppWidgetSize.dimen_10,
                      top: AppWidgetSize.dimen_30),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppWidgetSize.dimen_10),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: AppWidgetSize.dimen_10,
                          right: AppWidgetSize.dimen_10),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: Theme.of(context).primaryTextTheme.labelLarge,
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              InkWell(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: AppWidgetSize.dimen_20,
                      top: AppWidgetSize.dimen_30),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppWidgetSize.dimen_10),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: AppWidgetSize.dimen_10,
                          right: AppWidgetSize.dimen_10),
                      child: Text(
                        AppLocalizations.of(context)!.ok,
                        style: Theme.of(context).primaryTextTheme.labelLarge,
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  BlocProvider.of<MyFundsBloc>(context).add(
                      GetTransactionHistoryCancelEvent()
                        ..idvalue = data.instructionId!);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailViewWidget(History data) {
    return Padding(
      padding: EdgeInsets.all(AppWidgetSize.dimen_30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPayInstatus(data),
          _buildAmountValueWidget(data),
          if (data.vpa == null) _buildBankDetailWidget(data),
          if (data.vpa == null) _buildBankAccountDetailWidget(data),
          if (data.vpa != null) _buildUPIDetailWidget(data),
          _buildUPITransactionIDDetailWidget(data),
          _buildDateWidget(data),
          _buildDescriptionDetailWidget(data),
          if (data.status != null &&
              data.status!.toLowerCase().contains('pending') &&
              data.instructionId != null &&
              data.instructionId!.isNotEmpty)
            _buildCancelButtonWidget(data),
        ],
      ),
    );
  }

  Widget _buildCancelButtonWidget(History data) {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_25),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (data.instructionId != null &&
                  data.instructionId!.isNotEmpty) {
                Navigator.pop(context);
                pushNavigation(ScreenRoutes.withdrawfundsScreen,
                    arguments: {'resp_data': data});
              }
            },
            child: Container(
              width: AppWidgetSize.fullWidth(context) / 2 - 40,
              height: AppWidgetSize.dimen_50,
              padding: EdgeInsets.all(AppWidgetSize.dimen_10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors().positiveColor,
                  width: 1.5,
                ),
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(
                  AppWidgetSize.dimen_30,
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.modify,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .displaySmall!
                    .copyWith(color: AppColors().positiveColor),
              ),
            ),
          ),
          SizedBox(
            width: AppWidgetSize.dimen_10,
          ),
          InkWell(
            onTap: () {
              if (data.instructionId != null &&
                  data.instructionId!.isNotEmpty) {
                _showCancelTransactionConfirmationBottomSheet(data);
              }
            },
            child: Container(
              width: AppWidgetSize.fullWidth(context) / 2 - 40,
              height: AppWidgetSize.dimen_50,
              padding: EdgeInsets.all(AppWidgetSize.dimen_10),
              key: const Key('cancel'),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.negativeColor,
                  width: 1.5,
                ),
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(
                  AppWidgetSize.dimen_30,
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .displaySmall!
                    .copyWith(color: AppColors.negativeColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _builddetailRow(String key, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(key, style: Theme.of(context).textTheme.headlineSmall),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBankDetailWidget(History data) {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_25),
      child: _builddetailRow('Deposit From', data.bankName ?? ""),
    );
  }

  Widget _buildBankAccountDetailWidget(History data) {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_15),
      child: _builddetailRow('Account number', data.dispAccnumber),
    );
  }

  Widget _buildUPIDetailWidget(History data) {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_25),
      child: _builddetailRow('VPA', data.vpa ?? ""),
    );
  }

  Widget _buildUPITransactionIDDetailWidget(History data) {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_15),
      child: _builddetailRow('Transaction ID', data.transId ?? ""),
    );
  }

  Widget _buildDateWidget(History data) {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_15),
      child: _builddetailRow('Date', data.date ?? ""),
    );
  }

  Widget _buildDescriptionDetailWidget(History data) {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_15),
      child: _builddetailRow('Details', data.status!),
    );
  }

  Widget _buildAmountValueWidget(History data) {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_15,
          bottom: AppWidgetSize.dimen_15,
          right: AppWidgetSize.dimen_10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _getLableWithRupeeSymbol(
            AppUtils().commaFmt(
              data.amt!.replaceAll(",", ""),
            ),
            Theme.of(context).textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: AppConstants.interFont),
            Theme.of(context).textTheme.displayLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildPayInstatus(History data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppUtils.getPayInStatus(context, data) ?? "",
          style: Theme.of(context)
              .textTheme
              .displaySmall!
              .copyWith(fontWeight: FontWeight.w600),
        ),
        InkWell(
          child: AppImages.close(
            context,
            color: Theme.of(context).primaryIconTheme.color,
            isColor: true,
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
