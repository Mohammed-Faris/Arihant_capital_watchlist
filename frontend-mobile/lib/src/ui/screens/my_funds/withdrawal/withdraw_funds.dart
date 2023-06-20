import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../blocs/my_funds/withdraw_funds/withdraw_funds_bloc.dart';
import '../../../../constants/app_constants.dart';
import '../../../../data/store/app_storage.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/my_funds/bank_details_model.dart';
import '../../../../models/my_funds/my_fund_view_updated_model.dart';
import '../../../../models/my_funds/transaction_history_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../validator/indian_rupee_formatter.dart';
import '../../../widgets/card_widget.dart';
import '../../../widgets/checkbox_widget.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/keypad_done_widget/keypad_overlay_widget.dart';
import '../../base/base_screen.dart';

class WithdrawFundsScreen extends BaseScreen {
  final dynamic arguments;
  const WithdrawFundsScreen({Key? key, this.arguments}) : super(key: key);

  @override
  WithdrawFundsScreenState createState() => WithdrawFundsScreenState();
}

class WithdrawFundsScreenState
    extends BaseAuthScreenState<WithdrawFundsScreen> {
  late AppLocalizations _appLocalizations;
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  History? _history;
  String withdrawcash = "0.00";

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      _amountFocusNode.addListener(() {
        bool hasFocus = _amountFocusNode.hasFocus;
        if (hasFocus) {
          KeyboardOverlay.showOverlay(context);
        } else {
          KeyboardOverlay.removeOverlay();
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<WithdrawFundsBloc>(context)
          .stream
          .listen(withdrawFundsBlocListner);
      _enableanddisbaleButtonWidget(false);
      _getFundViewDetails();
      _getMaxpayout();
      _sendgetbankDetails();
    });

    if (widget.arguments != null) {
      _history = widget.arguments['resp_data'];

      if (_history!.amt != null) {
        if (_history!.amt!.isNotEmpty) {
          String value = AppUtils().removeCommaFmt(_history!.amt!);
          value = AppUtils().commaFmt(value);
          _amountController.text = value;
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (Platform.isIOS) {
      _amountFocusNode.dispose();
    }
  }

  Future<void> withdrawFundsBlocListner(WithdrawFundsState state) async {
    if (state is ShowErrorMessageOnContinueButtonPressedState) {
      if (state.isShowError) {
        showToast(message: state.errorMsg, context: context, isError: true);
      } else {
        if (BlocProvider.of<WithdrawFundsBloc>(context)
                .getbankListDoneState
                .bankDetailsModel !=
            null) {
          int index = BlocProvider.of<WithdrawFundsBloc>(context)
              .getbankListDoneState
              .dataindex;
          Banks bankdata = BlocProvider.of<WithdrawFundsBloc>(context)
              .getbankListDoneState
              .bankDetailsModel!
              .banks![index];
          Map dataobj = BlocProvider.of<WithdrawFundsBloc>(context)
              .getbankListDoneState
              .resultDataList![index];

          Map data = {
            'bankname': bankdata.bankName ?? "",
            'bankaccountnumber_display': dataobj['accountno'] ?? "",
            'bankaccountnumber': bankdata.accountNo ?? "",
            'amount': _amountController.text,
            if (_history != null) 'modifyData': _history
          };
          // AppStorage().removeData('getFundViewUpdatedModel');

          // BlocProvider.of<WithdrawFundsBloc>(context)
          //     .add(GetFundsViewUpdatedEvent());

          pushNavigation(ScreenRoutes.withdrawfundsConfirmationScreen,
              arguments: data);
        } else {
          showToast(message: 'No Banks Found', context: context, isError: true);
        }
      }
    } else if (state is WithdrawFundsGetbankListDoneState) {
      //modify
      if (widget.arguments != null) {
        BlocProvider.of<WithdrawFundsBloc>(context).add(
            WithdrawfundsModifyUpdatedBankdetailsEvent()..history = _history);
      }
    } else if (state is GetMaxPayoutWithdrawCashFailedState) {
      stopLoader();
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state is WithdrawErrorState) {
      stopLoader();
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state is WithdrawFundsProgressState) {
      if (mounted) {
        startLoader();
      }
    } else if (state is! WithdrawFundsProgressState) {
      if (mounted) {
        stopLoader();
      }
    }
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.withdrawfundsScreen;
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(),
        body: _buildBody(),
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
                _appLocalizations.withDraw,
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
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              _buildAddAmountView(),
              _buildWithdrawCash(),
              _buildSeperatorWidget(),
              _buildFindTransferdescriptionWidget(),
              _buildDisplayPrimaryBank(),
            ],
          ),
        ),
        _buildfooterWidget(),
      ],
    );
  }

  Padding _buildfooterWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Wrap(
          children: [
            _buildBottomWidget(),
          ],
        ),
      ),
    );
  }

  Center _buildBottomWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          bottom: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_70,
          left: AppWidgetSize.dimen_70,
        ),
        child: SizedBox(
          width: AppWidgetSize.fullWidth(context),
          height: AppWidgetSize.dimen_50,
          child: _getBottomButtonWidget('Continue'),
        ),
      ),
    );
  }

  Widget _getBottomButtonWidget(
    String header,
  ) {
    return BlocBuilder<WithdrawFundsBloc, WithdrawFundsState>(
      buildWhen: (previous, current) {
        return current is EnableAndDisableContinueButtonState;
      },
      builder: (context, state) {
        if (state is EnableAndDisableContinueButtonState) {
          return Opacity(
            opacity: state.isEnableButton ? 1.0 : 0.3,
            child: InkWell(
              onTap: () {
                if (state.isEnableButton) {
                  BlocProvider.of<WithdrawFundsBloc>(context).add(
                      CheckForErrorMessageEvent()
                        ..amount =
                            AppUtils().removeCommaFmt(_amountController.text));
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
                      ]),
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
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildFindTransferdescriptionWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_20, left: AppWidgetSize.dimen_40),
          child: CustomTextWidget(
            _appLocalizations.fundsWillTransfer,
            Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayPrimaryBank() {
    return BlocBuilder<WithdrawFundsBloc, WithdrawFundsState>(
      buildWhen: (previous, current) {
        return current is WithdrawFundsGetbankListDoneState ||
            current is WithdrawalFundsGetBankListNoData ||
            current is WithdrawFundsGetbankListModifyDoneState;
      },
      builder: (context, state) {
        if (state is WithdrawFundsGetbankListDoneState) {
          Map<String, dynamic> data =
              state.resultDataList!.elementAt(state.dataindex);
          return _buildbankRowWidget(data, state.isBankPrimary);
        } else if (state is WithdrawFundsGetbankListModifyDoneState) {
          Map<String, dynamic> data =
              state.resultDataList!.elementAt(state.dataindex);
          return _buildbankRowWidget(data, state.isBankPrimary);
        } else if (state is WithdrawalFundsGetBankListNoData) {
          return Padding(
            padding: EdgeInsets.only(top: AppWidgetSize.dimen_20),
            child: CustomTextWidget(
              state.msg,
              Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        return Container();
      },
    );
  }

  Widget _buildbankRowWidget(Map<String, dynamic>? data, bool isPrimaryBank) {
    return Container(
      margin: EdgeInsets.only(
        top: 10,
        left: AppWidgetSize.dimen_35,
        right: AppWidgetSize.dimen_35,
      ),
      child: InkWell(
        overlayColor: MaterialStateProperty.all<Color>(
            Theme.of(context).dialogBackgroundColor.withOpacity(0.1)),
        onTap: () async {
          if (widget.arguments == null) {
            final Map<String, dynamic>? data = await pushNavigation(
              ScreenRoutes.chooseBanklistScreen,
              arguments: {
                'resultbanklist': BlocProvider.of<WithdrawFundsBloc>(context)
                    .getbankListDoneState
                    .resultDataList,
                'banklistmodel': BlocProvider.of<WithdrawFundsBloc>(context)
                    .getbankListDoneState
                    .bankDetailsModel,
                'selectedRow': BlocProvider.of<WithdrawFundsBloc>(context)
                    .getbankListDoneState
                    .dataindex,
              },
            );
            if (!mounted) return;

            if (data != null) {
              if (data['bankdatamodel'] != null) {
                BankDetailsModel dataModel = data['bankdatamodel'];
                BlocProvider.of<WithdrawFundsBloc>(context).add(
                    WithdrawfundsUpdatedBankdetailsEvent()
                      ..bankDetailsModel = dataModel);
              }
            }
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_5,
            right: AppWidgetSize.dimen_5,
            top: AppWidgetSize.dimen_6,
            bottom: AppWidgetSize.dimen_6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppUtils().buildBankLogo(data!['bankLogo']),
              _buildBankNameandAccountNumber(data),
              if (isPrimaryBank == true) _buildPrimaryCustomTextWidget(),
              _buildArrowIconWidget()
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildArrowIconWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_15, left: AppWidgetSize.dimen_10),
      child: AppImages.rightArrowIos(
        context,
        color: Theme.of(context).primaryIconTheme.color,
        isColor: true,
      ),
    );
  }

  Flexible _buildPrimaryCustomTextWidget() {
    return Flexible(
      child: Container(
        margin: EdgeInsets.only(left: AppWidgetSize.dimen_5),
        decoration: BoxDecoration(
          color: Theme.of(context).snackBarTheme.backgroundColor,
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
        ),
        padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 20.w),
        child: CustomTextWidget(
            "Primary",
            Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: AppWidgetSize.dimen_15,
                color: Theme.of(context).primaryColor)),
      ),
    );
  }

  Expanded _buildBankNameandAccountNumber(Map<String, dynamic> data) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: AppWidgetSize.halfWidth(context),
              child: Text(
                data['bankName'],
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(data['accountno'],
                style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }

  Padding _buildSeperatorWidget() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_25),
      child: Divider(
        indent: AppWidgetSize.dimen_40,
        endIndent: AppWidgetSize.dimen_40,
        thickness: 1.0,
        color: Theme.of(context).dividerColor,
      ),
    );
  }

  Widget _buildWithdrawCash() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextWidget('${AppLocalizations().withDrawalcash}:',
              Theme.of(context).textTheme.titleLarge),
          Padding(
            padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
            child: _buildWithdrawCashData(),
          ),
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
          )
        ],
      ),
    );
  }

  Widget _buildAddAmountView() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          bottom: AppWidgetSize.dimen_10,
          right: AppWidgetSize.dimen_30,
          left: AppWidgetSize.dimen_30),
      child: CardWidget(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppWidgetSize.dimen_20,
              vertical: AppWidgetSize.dimen_10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildCardTitle(),
              SizedBox(
                height: AppWidgetSize.dimen_20,
              ),
              _buildCustomTextWidget(),
              BlocBuilder<WithdrawFundsBloc, WithdrawFundsState>(
                  builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.only(top: 5.w),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 5.w),
                          child: CheckboxWidget(
                            addSymbolKey: "",
                            checkBoxValue: state.withdrawAll,
                            valueChanged: (bool checkboxdata) {
                              if (!state.withdrawAll) {
                                _amountController.text =
                                    BlocProvider.of<WithdrawFundsBloc>(context)
                                        .getMaxPayoutWithdrawCashDoneState
                                        .availableFunds;
                                _amountController.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: _amountController.text.length));
                              } else {
                                _amountController.clear();
                              }
                              _enableanddisbaleButtonWidget(!state.withdrawAll);
                            },
                            enableIcon: state.withdrawAll
                                ? AppImages.filterSelectedIcon(
                                    context,
                                    width: 16.w,
                                    height: 16.w,
                                  )
                                : AppImages.redCheckboxEnableIcon(
                                    context,
                                    width: 16.w,
                                    height: 16.w,
                                  ),
                            disableIcon: AppImages.filterUnSelectedIcon(
                              context,
                              width: 16.w,
                              height: 16.w,
                              isColor: true,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        /* Checkbox(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppWidgetSize.dimen_5)),
                            value: state.withdrawAll,
                            onChanged: (s) {
                              if (!state.withdrawAll) {
                                _amountController.text =
                                    BlocProvider.of<WithdrawFundsBloc>(context)
                                        .getMaxPayoutWithdrawCashDoneState
                                        .availableFunds;
                                _amountController.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: _amountController.text.length));
                              } else {
                                _amountController.clear();
                              }
                              _enableanddisbaleButtonWidget(!state.withdrawAll);
                            }), */
                        CustomTextWidget(_appLocalizations.withdrawAll,
                            Theme.of(context).textTheme.titleLarge)
                      ]),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Text _buildCardTitle() {
    return Text(
      _appLocalizations.amountToWithdrawal,
      style: Theme.of(context)
          .textTheme
          .headlineSmall!
          .copyWith(fontWeight: FontWeight.w600),
    );
  }

  Padding _buildCustomTextWidget() {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_10,
        right: AppWidgetSize.dimen_10,
      ),
      child: Container(
        height: AppWidgetSize.dimen_50,
        width: AppWidgetSize.fullWidth(context),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(
            AppWidgetSize.dimen_3,
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InkWell(
              onTap: () async {
                if (WidgetsBinding.instance.window.viewInsets.bottom == 0.0) {
                  _amountFocusNode.unfocus();
                  await Future<void>.delayed(const Duration(milliseconds: 200));
                }
                if (!mounted) return;

                FocusScope.of(context).requestFocus(_amountFocusNode);
              },
              child: SizedBox(
                height: AppWidgetSize.dimen_50,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            IntrinsicWidth(
              child: Center(
                child: TextField(
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 22.w,
                        fontFamily: AppConstants.interFont,
                      ),
                  onChanged: (String amount) {
                    _enableanddisbaleButtonWidget(false);
                  },
                  autofocus: false,
                  focusNode: _amountFocusNode,
                  inputFormatters: [
                    IndianRupeeFormatter(
                        formatter: NumberFormat(
                          "##,##,###.##",
                          "en_IN", // local US
                        ),
                        allowFraction: true),
                  ],
                  controller: _amountController,
                  textAlign: TextAlign.center,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixIcon: Text("${AppConstants.rupeeSymbol} ",
                        style: _amountController.text.isNotEmpty ||
                                _amountFocusNode.hasPrimaryFocus
                            ? Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  fontSize: AppWidgetSize.fontSize22,
                                  fontFamily: AppConstants.interFont,
                                )
                            : Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  fontSize: AppWidgetSize.fontSize22,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                  fontFamily: AppConstants.interFont,
                                )),
                    prefixIconConstraints: BoxConstraints(
                        minWidth: 0, minHeight: AppWidgetSize.dimen_30),
                    hintText: _amountFocusNode.hasPrimaryFocus ? "" : "0",
                    hintStyle: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(
                          fontSize: AppWidgetSize.fontSize22,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontFamily: AppConstants.interFont,
                        ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 0),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendgetbankDetails() {
    BlocProvider.of<WithdrawFundsBloc>(context).add(GetBankDetailsEvent());
  }

  void _getFundViewDetails() {
    BlocProvider.of<WithdrawFundsBloc>(context).add(GetFundsViewUpdatedEvent());
  }

  void _getMaxpayout() {
    BlocProvider.of<WithdrawFundsBloc>(context)
        .add(GetMaxPayoutWithdrawalCashEvent());
  }

  void _enableanddisbaleButtonWidget(bool withdrawAll) {
    BlocProvider.of<WithdrawFundsBloc>(context)
        .add(EnableAndDisableContinueButtonEvent()
          ..withdrawAll = withdrawAll
          ..amount = _amountController.text);
    setState(() {});
  }

  Widget _getLableWithRupeeSymbol(
    String value,
    TextStyle? textStyle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextWidget(
          value,
          textStyle,
          isRupee: true,
        ),
      ],
    );
  }

  Widget _buildWithdrawCashData() {
    return BlocBuilder<WithdrawFundsBloc, WithdrawFundsState>(
      buildWhen: (previous, current) {
        return current is GetMaxPayoutWithdrawCashDoneState ||
            current is GetMaxPayoutWithdrawCashFailedState;
      },
      builder: (context, state) {
        if (state is GetMaxPayoutWithdrawCashDoneState) {
          withdrawcash = state.availableFunds;
          if (state.availableFunds.contains('na')) {
            return Text(
              state.availableFunds,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.w600),
            );
          }

          return _getLableWithRupeeSymbol(
              state.availableFunds,
              Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.w600));
        } else if (state is GetMaxPayoutWithdrawCashFailedState) {
          withdrawcash = "0.00";
          return _getLableWithRupeeSymbol(
            '0.00',
            Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.w600),
          );
        }
        return _getLableWithRupeeSymbol(
            '',
            Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.w600));
      },
    );
  }
}
