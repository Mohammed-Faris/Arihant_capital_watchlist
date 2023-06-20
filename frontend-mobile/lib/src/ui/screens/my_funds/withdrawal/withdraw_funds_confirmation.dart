import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/my_funds/withdraw_funds/withdraw_funds_bloc.dart';
import '../../../../constants/app_events.dart';
import '../../../../data/store/app_storage.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/my_funds/transaction_history_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/gradient_button_widget.dart';
import '../../base/base_screen.dart';

class WithdrawFundsConfirmationScreen extends BaseScreen {
  final dynamic arguments;
  const WithdrawFundsConfirmationScreen({Key? key, this.arguments})
      : super(key: key);

  @override
  WithdrawFundsConfirmationScreenState createState() =>
      WithdrawFundsConfirmationScreenState();
}

class WithdrawFundsConfirmationScreenState
    extends BaseScreenState<WithdrawFundsConfirmationScreen> {
  late AppLocalizations _appLocalizations;
  bool? isSuccessButtonPressed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<WithdrawFundsBloc>(context)
          .stream
          .listen(withdrawFundsConfirmationBlocListner);
    });
  }

  Future<void> withdrawFundsConfirmationBlocListner(
      WithdrawFundsState state) async {
    if (state is WithdrawFundsDoneState) {
      String title = (state.isSuccess == true)
          ? 'Withdrawal request received successfully'
          : 'Payment Withdrawal Failed';

      showSuccessOrFailureAcknowledgement(
        context: context,
        isSuccess: state.isSuccess,
        title: title,
        msg: state.msg,
      );
    } else if (state is WithdrawFundsConfirmationProgressState) {
      if (mounted) {
        startLoader();
      }
    } else if (state is! WithdrawFundsConfirmationProgressState) {
      if (mounted) {
        stopLoader();
      }
    } else if (state is WithdrawErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state is WithdrawFundsFailedState) {
      showToast(message: state.errorMsg);
    }
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.withdrawfundsConfirmationScreen;
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _buildButtonWidget(),
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
                _appLocalizations.confirmation,
                Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWithdrawImageWidget(),
          _buildWithdrawDataWidget(),
          _buildfooterCustomTextWidget(),
          //_buildButtonWidget(),
        ],
      ),
    );
  }

  Widget _buildButtonWidget() {
    String value = _appLocalizations.withdrawFunds;
    if (widget.arguments['modifyData'] != null) {
      value = _appLocalizations.modifyFunds;
    }

    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_30,
        bottom: AppWidgetSize.dimen_20,
        right: AppWidgetSize.dimen_70,
        left: AppWidgetSize.dimen_70,
      ),
      child: SizedBox(
        width: AppWidgetSize.fullWidth(context),
        height: AppWidgetSize.dimen_50,
        child: _getBottomButtonWidget(value),
      ),
    );
  }

  void _sendWithdrawFundsReq() {
    String amount = '';
    String accountnumber = '';
    String bankname = '';
    amount = widget.arguments['amount'];
    accountnumber = widget.arguments['bankaccountnumber'];
    bankname = widget.arguments['bankname'];

    BlocProvider.of<WithdrawFundsBloc>(context).add(GetWithdrawFundsEvent()
      ..amount = amount
      ..bank_account_id = accountnumber
      ..bank_name = bankname);
  }

  void _sendModifyWithFundReq(History history) {
    BlocProvider.of<WithdrawFundsBloc>(context)
        .add(GetModifyWithdrawFundsEvent()
          ..amount = widget.arguments['amount']
          ..instructionId = history.instructionId ?? "");
  }

  Widget _getBottomButtonWidget(String header) {
    return InkWell(
      onTap: () {
        sendEventToFirebaseAnalytics(
          AppEvents.withdrawConfirmclick,
          ScreenRoutes.withdrawfundsConfirmationScreen,
          'Withdrawing funds from withdraw confirmation screen',
        );

        if (widget.arguments['modifyData'] != null) {
          History history = widget.arguments['modifyData'];
          _sendModifyWithFundReq(history);
        } else {
          _sendWithdrawFundsReq();
        }
      },
      child: Container(
        width: AppWidgetSize.dimen_130,
        height: AppWidgetSize.dimen_50,
        padding: EdgeInsets.all(AppWidgetSize.dimen_10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.w),
          gradient: LinearGradient(
            stops: const [0.0, 1.0],
            begin: FractionalOffset.topLeft,
            end: FractionalOffset.topRight,
            colors: [
              Theme.of(context).colorScheme.onBackground,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        child: Text(
          header,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .primaryTextTheme
              .displaySmall!
              .copyWith(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }

  Widget _buildWithdrawDataWidget() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_50),
      child: Column(
        children: [
          _buildCustomTextWidget(),
          _buildSeperatorWidget(AppWidgetSize.dimen_20),
          _buildWithdrawCashDataWidget(),
          _buildFromDataWidget(),
          _buildToDataWidget(),
          _buildAccountNumberDataWidget(),
          _buildPayWithDataWidget(),
          _buildSeperatorWidget(AppWidgetSize.dimen_10),
          _buildFooterDescriptionWidget(),
          _buildTransactionDataWidget(),
        ],
      ),
    );
  }

  Widget _buildfooterCustomTextWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_30, left: AppWidgetSize.dimen_20),
      child: CustomTextWidget(
          'Good To Go?',
          Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w700, fontSize: AppWidgetSize.dimen_24),
          textAlign: TextAlign.left),
    );
  }

  SizedBox _buildSeperatorWidget(double value) {
    return SizedBox(
      height: value,
    );
  }

  Widget _buildRowData(String key, String value) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_15,
        left: AppWidgetSize.dimen_20,
        right: AppWidgetSize.dimen_20,
      ),
      child: Row(
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
      ),
    );
  }

  Widget _buildWithdrawCashDataWidget() {
    return _buildRowData('Withdrawable Cash', widget.arguments['amount']);
  }

  Widget _buildFromDataWidget() {
    return _buildRowData('From', 'Arihant Wallet');
  }

  Widget _buildToDataWidget() {
    return _buildRowData('To', widget.arguments['bankname']);
  }

  Widget _buildAccountNumberDataWidget() {
    return _buildRowData(
        'Account Number', widget.arguments['bankaccountnumber_display']);
  }

  Widget _buildPayWithDataWidget() {
    return _buildRowData('Pay With', 'NetBanking');
  }

  Widget _buildTransactionDataWidget() {
    return _buildRowData('Transaction Fee', 'Free');
  }

  Widget _buildCustomTextWidget() {
    return Text(
      _appLocalizations.withdrawalConfirmation,
      style: Theme.of(context).textTheme.displaySmall!.copyWith(
            fontWeight: FontWeight.w600,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildWithdrawImageWidget() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_20),
      child: Center(
        child: AppImages.withdrawalConfirmation(
          context,
          isColor: false,
        ),
      ),
    );
  }

  Widget _buildFooterDescriptionWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
        bottom: AppWidgetSize.dimen_10,
      ),
      child: Container(
        height: AppWidgetSize.dimen_100,
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
                  child: Text(
                      'Withdrawal request before 6 PM on trading day will be processed today EOD. Funds from shares sold will be available for withdrawal after two working days (T+2)',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showSuccessOrFailureAcknowledgement(
      {required BuildContext context,
      required bool isSuccess,
      required String title,
      required String msg,
      dynamic response}) {
    AppStorage().removeData('getRecentFundTransaction');
    AppStorage().removeData('getFundHistorydata');
    // AppStorage().removeData('getFundViewUpdatedModel');
    showModalBottomSheet(
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      context: context,
      enableDrag: false,
      isDismissible: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (_, StateSetter updateState) {
            return DraggableScrollableSheet(
              expand: false,
              maxChildSize: 1,
              initialChildSize: 1,
              builder: (_, ScrollController scrollController) {
                return Stack(
                  children: [
                    _buildTopWidget(isSuccess, context, title, msg),
                    _buildButtonBottomWidget(context, isSuccess)
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  SingleChildScrollView _buildTopWidget(
      bool isSuccess, BuildContext context, String title, String msg) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildUpperWidget(isSuccess, context, title, msg),
          if (isSuccess) _buildFundsView(context),
        ],
      ),
    );
  }

  Padding _buildButtonBottomWidget(BuildContext context, bool isSuccess) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_20,
        right: AppWidgetSize.dimen_20,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isSuccess)
              _buildButtonCallBack(context, _appLocalizations.watchlist)
            else
              _buildButtonCallBack(context, _appLocalizations.myFunds),
            if (isSuccess)
              _buildButtonCallBack(context, _appLocalizations.myFunds)
            else
              _buildButtonCallBack(context, _appLocalizations.retry)
          ],
        ),
      ),
    );
  }

  Widget _buildButtonCallBack(BuildContext context, String keyvalue) {
    return gradientButtonWidget(
      onTap: () {
        isSuccessButtonPressed = true;
        if (keyvalue == _appLocalizations.retry) {
          sendEventToFirebaseAnalytics(
            AppEvents.retryClick,
            ScreenRoutes.withdrawfundsConfirmationScreen,
            'Clicked retry in withdraw confirmation screen',
          );

          Navigator.of(context).pop();
          if (widget.arguments['modifyData'] != null) {
            History history = widget.arguments['modifyData'];
            _sendModifyWithFundReq(history);
          } else {
            _sendWithdrawFundsReq();
          }
        } else if (keyvalue == _appLocalizations.watchlist) {
          pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen,
              arguments: {'pageName': ScreenRoutes.watchlistScreen});
        } else {
          navigateToUntil(ScreenRoutes.homeScreen,
              arguments: {'pageName': ScreenRoutes.myfundsScreen});
        }
      },
      width: AppWidgetSize.fullWidth(context) / 2.5,
      key: Key(keyvalue),
      context: context,
      title: keyvalue,
      isGradient: true,
    );
  }

  Column _buildFundsView(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: AppWidgetSize.dimen_40,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              pushNavigation(ScreenRoutes.fundhistoryScreen);
            },
            child: CustomTextWidget(_appLocalizations.viewFundsHistory,
                Theme.of(context).primaryTextTheme.headlineMedium),
          ),
        ),
      ],
    );
  }

  Padding _buildUpperWidget(
      bool isSuccess, BuildContext context, String title, String msg) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
        top: AppWidgetSize.dimen_80,
        bottom: AppWidgetSize.dimen_40,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            (isSuccess)
                ? AppImages.successImage(context)
                : AppImages.paymentFailed(context),
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_30,
                bottom: AppWidgetSize.dimen_30,
              ),
              child: CustomTextWidget(
                title,
                Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_20,
                bottom: AppWidgetSize.dimen_30,
              ),
              child: CustomTextWidget(
                msg,
                Theme.of(context).primaryTextTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
