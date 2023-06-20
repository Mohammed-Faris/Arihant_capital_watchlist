import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../blocs/my_funds/add_funds/add_funds_bloc.dart';
import '../../../../config/app_config.dart';
import '../../../../constants/app_constants.dart';
import '../../../../constants/app_events.dart';
import '../../../../constants/keys/login_keys.dart';
import '../../../../data/store/app_storage.dart';
import '../../../../data/store/app_store.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/my_funds/bank_details_model.dart';
import '../../../../models/my_funds/get_payments_option_model.dart';
import '../../../../models/my_funds/my_fund_view_updated_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../validator/indian_rupee_formatter.dart';
import '../../../widgets/card_widget.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/gradient_button_widget.dart';
import '../../../widgets/keypad_done_widget/keypad_overlay_widget.dart';
import '../../../widgets/loader_widget.dart';
import '../../../widgets/refresh_widget.dart';
import '../../../widgets/rupee_symbol_widget.dart';
import '../../base/base_screen.dart';

class AddFundsScreen extends BaseScreen {
  final dynamic arguments;
  const AddFundsScreen({Key? key, this.arguments}) : super(key: key);

  @override
  AddFundsScreenState createState() => AddFundsScreenState();
}

class AddFundsScreenState extends BaseAuthScreenState<AddFundsScreen>
    with WidgetsBindingObserver {
  late AppLocalizations _appLocalizations;
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  InAppWebViewController? _webViewController;
  bool? isSuccessButtonPressed;
  bool? isFailButtonPressed;
  bool? isUPICalled;
  bool isNetbankingLoader = false;
  bool isPaused = false;
  bool isInactive = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (isUPICalled == true) {
          if (isInactive == false) {
            BlocProvider.of<AddFundsBloc>(context)
                .add(GetTransactionStatusEvent());
          }

          isUPICalled = false;
        }
        break;
      case AppLifecycleState.inactive:
        isInactive = true;
        isPaused = false;
        if (isUPICalled == false) {
          isUPICalled = null;
        }
        break;
      case AppLifecycleState.paused:
        isInactive = false;
        isPaused = true;
        if (isUPICalled == false) {
          isUPICalled = null;
        }
        break;
      case AppLifecycleState.detached:
        if (isUPICalled == false) {
          isUPICalled = null;
        }
        break;
    }
  }

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
      BlocProvider.of<AddFundsBloc>(context).stream.listen(addFundsBlocListner);
      BlocProvider.of<AddFundsBloc>(context)
          .add(ShowPrefixIconEvent()..isShow = false);
      _sendgetbankDetails();
      _getBuyPowerDetails();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    if (Platform.isIOS) {
      _amountFocusNode.dispose();
    }

    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> addFundsBlocListner(AddFundsState state) async {
    if (state is AddFundsUpdateAmountState) {
      _amountController.text = state.updatedvalue;
    } else if (state is AddFundsErrorState) {
      stopLoader();
      if (state.isInvalidException) {
        handleError(state);
      } else {
        showToast(message: state.errorMsg, isError: true);
      }
    } else if (state is AddFundUPITransactionStatusDoneState) {
      if (state.fundsTransactionStatusUPIModel.status != null &&
          state.fundsTransactionStatusUPIModel.status!.isNotEmpty) {
        if (state.fundsTransactionStatusUPIModel.status!
            .toLowerCase()
            .contains('success')) {
          showSuccessAcknowledgement(
              context: context,
              title: 'Payment Successful',
              msg: '',
              transID: state.fundsTransactionStatusUPIModel.transId!,
              reason: state.fundsTransactionStatusUPIModel.reason ?? "",
              data: state.fundsTransactionStatusUPIModel.reason!
                  .split('\u{20B9}'));
        } else {
          Map<String, String> data = _getDataForUPIFailcase();
          showFailedAcknowledgement(
              context: context,
              title: 'Payment Failed',
              msg: state.fundsTransactionStatusUPIModel.reason ?? "",
              mapdata: data,
              isUPI: true);
        }
      } else {
        Map<String, String> data = _getDataForUPIFailcase();
        showFailedAcknowledgement(
            context: context,
            title: 'Payment Failed',
            msg: state.fundsTransactionStatusUPIModel.reason ?? "",
            mapdata: data,
            isUPI: true);
      }
    } else if (state is AddFundsNetBankingDataDoneState) {
      if (state.netBankingDataModel!.payUrl!.isNotEmpty) {
        if (state.netBankingDataModel!.method!.isNotEmpty &&
            state.netBankingDataModel!.listenUrl!.isNotEmpty) {
          stopLoader();
          _showPaymentNetBankingPage(
              state.netBankingDataModel!.method,
              state.netBankingDataModel!.payUrl,
              state.netBankingDataModel!.listenUrl);
        }
      }
    } else if (state is AddFundsUPIDataDoneState) {
      stopLoader();
      if (state.upiBankingDataModel?.payUrl?.isNotEmpty ?? false) {
        Uri myUri = Uri.parse(state.upiBankingDataModel?.payUrl ?? "");
        isUPICalled = true;
        WidgetsBinding.instance.removeObserver(this);
        WidgetsBinding.instance.addObserver(this);

        await launchUrl(
          myUri,
        );
      }
    } else if (state is AddFundsFailedState) {
      stopLoader();
      if (state.isInvalidException) {
        handleError(state);
      }

      if (state.errorCode.toLowerCase().contains('egn002')) {
        showToast(message: state.errorMsg, isError: true);
      }
    } else if (state is AddFundsProgressState) {
      if (mounted) {
        startLoader();
      }
    } else if (state is! AddFundsProgressState) {
      if (mounted) {
        stopLoader();
      }
    }
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.addfundsScreen;
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        appBar: _buildAppBar(),
        resizeToAvoidBottomInset: true,
        body: RefreshWidget(
          onRefresh: () async {
            _getBuyPowerDetails();
            _sendgetbankDetails();
          },
          child: _buildBody(),
        ),
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
                _amountFocusNode.unfocus();
                popNavigation();
              },
              customColor: Theme.of(context).textTheme.displayMedium!.color),
          Padding(
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_5,
            ),
            child: CustomTextWidget(
              _appLocalizations.transferToArihant,
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

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAddAmountView(),
          _buildBuyPower(),
          _buildSeperatorWidget(),
          _buildChooseBankStepdescriptionWidget(),
          _buildDisplayPrimaryBank(),
          _buildChoosePaymentModeStepdescriptionWidget(),
          if (Platform.isAndroid) _buildUPIWidget(),
          _buildOtherUPIWidget(),
          _buildIMPSWidget(),
          _buildNetBankingWidget(),
          _buildFooterDescriptionWidget()
        ],
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

  Widget _buildDisplayPrimaryBank() {
    return BlocBuilder<AddFundsBloc, AddFundsState>(
      buildWhen: (previous, current) {
        return current is AddFundsGetbankListDoneState ||
            current is AddFundsGetBankListNoData;
      },
      builder: (context, state) {
        if (state is AddFundsGetbankListDoneState) {
          Map<String, dynamic> data =
              state.resultDataList!.elementAt(state.dataindex);

          return _buildbankRowWidget(data, state.isBankPrimary);
        } else if (state is AddFundsGetBankListNoData) {
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

  Widget _buildOtherUPIWidget() {
    return Container(
      margin: EdgeInsets.only(
        top: 10,
        left: AppWidgetSize.dimen_35,
        right: AppWidgetSize.dimen_35,
      ),
      child: InkWell(
        overlayColor: MaterialStateProperty.all<Color>(
            Theme.of(context).dialogBackgroundColor.withOpacity(0.1)),
        onTap: () {
          sendEventToFirebaseAnalytics(
            AppEvents.otherupiClick,
            ScreenRoutes.addfundsScreen,
            'clicked other upi option in add funds screen',
          );
          if (BlocProvider.of<AddFundsBloc>(context)
                  .addFundsGetBankListNoData
                  .isValid ==
              true) {
            if (BlocProvider.of<AddFundsBloc>(context)
                .getbankListDoneState
                .upiURL
                .isNotEmpty) {
              if (_amountController.text.isEmpty ||
                  AppUtils().doubleValue(
                          AppUtils().removeCommaFmt(_amountController.text)) ==
                      0) {
                _showvalidationmessage('Amount cannot be empty or zero');
              } else {
                PayOptions? dataobj = BlocProvider.of<AddFundsBloc>(context)
                    .getbankListDoneState
                    .selectedpayOption;

                List<String> bankaccountNumberList = [];

                for (var element in BlocProvider.of<AddFundsBloc>(context)
                    .getbankListDoneState
                    .bankDetailsModel!
                    .banks!) {
                  if (element.accountNo != null &&
                      element.accountNo!.isNotEmpty) {
                    bankaccountNumberList.add(element.accountNo!);
                  }
                }

                if (bankaccountNumberList.length >= 5) {
                  bankaccountNumberList = bankaccountNumberList.sublist(0, 4);
                }

                String paychannel = '';
                if (dataobj!.channels!.uPI != null &&
                    dataobj.channels!.uPI!.isNotEmpty) {
                  paychannel = dataobj.channels!.uPI!.toList().first;
                }

                pushNavigation(
                  ScreenRoutes.otherUpi,
                  arguments: {
                    'paychannel': paychannel,
                    'amount': AppUtils().removeCommaFmt(_amountController.text),
                    'bankaccountnumberlist': bankaccountNumberList
                  },
                );
              }
            }
          } else {
            if (_amountController.text.isEmpty ||
                AppUtils().doubleValue(
                        AppUtils().removeCommaFmt(_amountController.text)) ==
                    0) {
              _showvalidationmessage('Amount cannot be empty or zero');
            } else if (BlocProvider.of<AddFundsBloc>(context)
                    .addFundsGetBankListNoData
                    .isValid ==
                false) {
              showToast(
                message: BlocProvider.of<AddFundsBloc>(context)
                    .addFundsGetBankListNoData
                    .msg,
                context: context,
                isError: true,
              );
            } else {
              showToast(
                message: 'No data Found',
                context: context,
                isError: true,
              );
            }
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_5,
              right: AppWidgetSize.dimen_5,
              top: AppWidgetSize.dimen_5,
              bottom: AppWidgetSize.dimen_5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildLogoWidget(AppImages.upiLogo(context)),
              Expanded(
                  child: _buildPaymodeAndDescription(
                      'Web UPI', 'Fast,secure payment', 'free')),
              _buildArrowIconWidget()
            ],
          ),
        ),
      ),
    );
  }

  void _showvalidationmessage(String msg) {
    return showToast(
      message: msg,
      context: context,
      isError: true,
    );
  }

  Widget _buildUPIWidget() {
    return Container(
      margin: EdgeInsets.only(
        top: 10,
        left: AppWidgetSize.dimen_35,
        right: AppWidgetSize.dimen_35,
      ),
      child: InkWell(
        overlayColor: MaterialStateProperty.all<Color>(
            Theme.of(context).dialogBackgroundColor.withOpacity(0.1)),
        onTap: () {
          sendEventToFirebaseAnalytics(
            AppEvents.upiclick,
            ScreenRoutes.addfundsScreen,
            'clicked upi option in add funds screen',
          );
          if (BlocProvider.of<AddFundsBloc>(context)
                  .addFundsGetBankListNoData
                  .isValid ==
              true) {
            if (BlocProvider.of<AddFundsBloc>(context)
                .getbankListDoneState
                .upiURL
                .isNotEmpty) {
              if (_amountController.text.isEmpty ||
                  AppUtils().doubleValue(
                          AppUtils().removeCommaFmt(_amountController.text)) ==
                      0) {
                _showvalidationmessage('Amount cannot be empty or zero');
              } else {
                List<String> bankaccountNumberList = [];

                for (var element in BlocProvider.of<AddFundsBloc>(context)
                    .getbankListDoneState
                    .bankDetailsModel!
                    .banks!) {
                  if (element.accountNo != null &&
                      element.accountNo!.isNotEmpty) {
                    bankaccountNumberList.add(element.accountNo!);
                  }
                }

                if (bankaccountNumberList.length >= 5) {
                  bankaccountNumberList = bankaccountNumberList.sublist(0, 4);
                }

                String payChannel = "";
                if (BlocProvider.of<AddFundsBloc>(context)
                            .getbankListDoneState
                            .selectedpayOption!
                            .channels!
                            .uPI !=
                        null &&
                    BlocProvider.of<AddFundsBloc>(context)
                        .getbankListDoneState
                        .selectedpayOption!
                        .channels!
                        .uPI!
                        .isNotEmpty) {
                  payChannel = BlocProvider.of<AddFundsBloc>(context)
                      .getbankListDoneState
                      .selectedpayOption!
                      .channels!
                      .uPI!
                      .last;
                }

                BlocProvider.of<AddFundsBloc>(context).add(
                  AddfundsfetchUPIDataEvent()
                    ..url = BlocProvider.of<AddFundsBloc>(context)
                        .getbankListDoneState
                        .upiURL
                    ..amount = AppUtils().removeCommaFmt(_amountController.text)
                    ..payChannel = payChannel
                    ..accountnumberlist = bankaccountNumberList,
                );
              }
            }
          } else {
            if (_amountController.text.isEmpty ||
                AppUtils().doubleValue(
                        AppUtils().removeCommaFmt(_amountController.text)) ==
                    0) {
              _showvalidationmessage('Amount cannot be empty or zero');
            } else if (BlocProvider.of<AddFundsBloc>(context)
                    .addFundsGetBankListNoData
                    .isValid ==
                false) {
              showToast(
                message: BlocProvider.of<AddFundsBloc>(context)
                    .addFundsGetBankListNoData
                    .msg,
                context: context,
                isError: true,
              );
            } else {
              showToast(
                message: 'No data Found',
                context: context,
                isError: true,
              );
            }
          }
        },
        child: Container(
          padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_5,
              right: AppWidgetSize.dimen_5,
              top: AppWidgetSize.dimen_5,
              bottom: AppWidgetSize.dimen_5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildLogoWidget(AppImages.upiMoneyLogo(context)),
              Expanded(
                child: _buildPaymodeAndDescription(
                    'UPI', 'Fast,secure payment', 'free'),
              ),
              _buildArrowIconWidget()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetBankingWidget() {
    return BlocBuilder<AddFundsBloc, AddFundsState>(
      buildWhen: (previous, current) {
        return current is AddFundsGetbankListDoneState ||
            current is AddFundsGetBankListNoData;
      },
      builder: (context, state) {
        if (state is AddFundsGetbankListDoneState ||
            state is AddFundsGetBankListNoData) {
          //List<String> paymode = state.selectedpayOption!.payMode!;
          //String data = paymode.elementAt(0);
          //paymode = paymode.map((email) => email.toLowerCase()).toList();
          //bool isPG = paymode.contains('pg');

          //if (isPG) {
          return Container(
            margin: EdgeInsets.only(
              top: AppWidgetSize.dimen_10,
              left: AppWidgetSize.dimen_35,
              right: AppWidgetSize.dimen_35,
            ),
            child: InkWell(
              overlayColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).dialogBackgroundColor.withOpacity(0.1)),
              onTap: () {
                sendEventToFirebaseAnalytics(
                  AppEvents.netbankingClick,
                  ScreenRoutes.addfundsScreen,
                  'clicked Netbanking option in add funds screen',
                );
                WidgetsBinding.instance.removeObserver(this);
                isUPICalled = false;
                isSuccessButtonPressed = null;
                isFailButtonPressed = null;
                isNetbankingLoader = true;

                if (state is AddFundsGetBankListNoData) {
                  pushNavigation(ScreenRoutes.netBankingErrorScreen);
                }

                if (state is AddFundsGetbankListDoneState) {
                  if (state.pgURL.isNotEmpty) {
                    if (state.bankDetailsModel!.banks!.isEmpty) {
                      pushNavigation(ScreenRoutes.netBankingErrorScreen);
                    } else {
                      int index =
                          state.bankDetailsModel!.banks!.indexWhere((element) {
                        return element.isBankChoosen;
                      });

                      Banks selectedbankdata =
                          state.bankDetailsModel!.banks!.elementAt(0);
                      if (index != -1) {
                        selectedbankdata =
                            state.bankDetailsModel!.banks!.elementAt(index);
                      }

                      if (_amountController.text.isEmpty ||
                          AppUtils().doubleValue(AppUtils()
                                  .removeCommaFmt(_amountController.text)) ==
                              0) {
                        _showvalidationmessage(
                            'Amount cannot be empty or zero');
                      } else if (_amountController.text.isNotEmpty &&
                          ((AppUtils().doubleValue(AppUtils()
                                      .removeCommaFmt(_amountController.text)) <
                                  50.0 ||
                              AppUtils().doubleValue(AppUtils()
                                      .removeCommaFmt(_amountController.text)) >
                                  500000.0))) {
                        _showvalidationmessage(
                            'Kindly Enter an Amount from Rs 50 to Rs 5,00,000');
                      } else {
                        if (BlocProvider.of<AddFundsBloc>(context)
                            .getbankListDoneState
                            .selectedpayOption!
                            .channels!
                            .pG!
                            .isEmpty) {
                          pushNavigation(ScreenRoutes.netBankingErrorScreen);
                        } else {
                          _fetchNetbankingData(selectedbankdata);
                        }
                      }
                    }
                  } else {
                    showToast(
                      message: 'No data Found',
                      context: context,
                      isError: true,
                    );
                  }
                }
              },
              child: Padding(
                padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_5,
                    right: AppWidgetSize.dimen_5,
                    top: AppWidgetSize.dimen_5,
                    bottom: AppWidgetSize.dimen_5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLogoWidget(AppImages.netBankinglogo(context)),
                    Expanded(
                      child: _buildPaymodeAndDescription('Net Banking',
                          'Instant transfers from Bank accounts', ''),
                    ),
                    _buildArrowIconWidget()
                  ],
                ),
              ),
            ),
          );
        }
        //}

        return Container();
      },
    );
  }

  void _fetchNetbankingData(Banks selectedbank) {
    BlocProvider.of<AddFundsBloc>(context).add(
      AddfundsfetchNetBankingDataEvent()
        ..url =
            BlocProvider.of<AddFundsBloc>(context).getbankListDoneState.pgURL
        ..amount = AppUtils().removeCommaFmt(_amountController.text)
        ..bankName = selectedbank.bankName!
        ..clientAccNo = selectedbank.accountNo!
        ..payChannel = BlocProvider.of<AddFundsBloc>(context)
            .getbankListDoneState
            .selectedpayOption!
            .channels!
            .pG!
            .elementAt(0),
    );
  }

  Widget _buildIMPSWidget() {
    return Container(
      margin: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
        left: AppWidgetSize.dimen_35,
        right: AppWidgetSize.dimen_35,
      ),
      child: InkWell(
        overlayColor: MaterialStateProperty.all<Color>(
            Theme.of(context).dialogBackgroundColor.withOpacity(0.1)),
        onTap: () async {
          sendEventToFirebaseAnalytics(
            AppEvents.impsClick,
            ScreenRoutes.addfundsScreen,
            'clicked NEFT/RTGS/IMPS option in add funds screen',
          );
          WidgetsBinding.instance.removeObserver(this);
          isUPICalled = false;

          if (BlocProvider.of<AddFundsBloc>(context)
                  .addFundsGetBankListNoData
                  .isValid ==
              false) {
            showToast(
              message: BlocProvider.of<AddFundsBloc>(context)
                  .addFundsGetBankListNoData
                  .msg,
              context: context,
              isError: true,
            );
          } else {
            String name =
                await AppStore().getSavedDataFromAppStorage(userIdKey);
            _amountFocusNode.unfocus();
            if (!mounted) return;
            pushNavigation(ScreenRoutes.addfundIMPSScreen, arguments: {
              'resultbanklist': BlocProvider.of<AddFundsBloc>(context)
                  .getbankListDoneState
                  .resultDataList,
              'userID': name
            });
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_5,
              right: AppWidgetSize.dimen_5,
              top: AppWidgetSize.dimen_5,
              bottom: AppWidgetSize.dimen_5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildLogoWidget(AppImages.impsLogo(context)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: AppWidgetSize.dimen_5),
                          child: SizedBox(
                            width: AppWidgetSize.dimen_130,
                            child: Text(
                              'Add money via',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                        _buildFreeCustomTextWidget('free', false),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_5),
                      child: SizedBox(
                        width: AppWidgetSize.dimen_150,
                        child: Text(
                          'NEFT/RTGS/IMPS',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: AppWidgetSize.dimen_15,
                          left: AppWidgetSize.dimen_5),
                      child: Text(
                        'Get quick cash with your manual transfer',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: AppWidgetSize.fontSize12),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [_buildArrowIconWidget()],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterDescriptionWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_25, bottom: AppWidgetSize.dimen_25),
      child: Container(
        height: AppWidgetSize.dimen_70,
        color: Theme.of(context).snackBarTheme.backgroundColor,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_40,
            right: AppWidgetSize.dimen_35,
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
                      AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_50,
                  child: Text(
                      'Make sure to transfer your funds only from your bank accounts registered with Arihant.',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildbankRowWidget(Map<String, dynamic>? data, bool isPrimaryBank) {
    return Container(
      margin: EdgeInsets.only(
        top: 15,
        left: AppWidgetSize.dimen_35,
        right: AppWidgetSize.dimen_35,
      ),
      child: InkWell(
        overlayColor: MaterialStateProperty.all<Color>(
            Theme.of(context).dialogBackgroundColor.withOpacity(0.1)),
        onTap: () async {
          WidgetsBinding.instance.removeObserver(this);
          _amountFocusNode.unfocus();
          final Map<String, dynamic>? data = await pushNavigation(
            ScreenRoutes.chooseBanklistScreen,
            arguments: {
              'resultbanklist': BlocProvider.of<AddFundsBloc>(context)
                  .getbankListDoneState
                  .resultDataList,
              'banklistmodel': BlocProvider.of<AddFundsBloc>(context)
                  .getbankListDoneState
                  .bankDetailsModel,
              'selectedRow': BlocProvider.of<AddFundsBloc>(context)
                  .getbankListDoneState
                  .dataindex,
            },
          );

          if (data != null) {
            if (data['bankdatamodel'] != null) {
              BankDetailsModel dataModel = data['bankdatamodel'];
              if (!mounted) return;
              BlocProvider.of<AddFundsBloc>(context).add(
                  AddfundsUpdatedBankdetailsEvent()
                    ..bankDetailsModel = dataModel);
            }
          }
        },
        child: Container(
          padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_5,
              right: AppWidgetSize.dimen_5,
              top: AppWidgetSize.dimen_5,
              bottom: AppWidgetSize.dimen_5),
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
            borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20)),
        padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 20.w),
        child: CustomTextWidget(
          "Primary",
          Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: AppWidgetSize.dimen_15,
                color: Theme.of(context).primaryColor,
              ),
        ),
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
            Text(
              data['accountno'],
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: AppWidgetSize.fontSize12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoWidget(Widget logo) {
    return Padding(
      padding: EdgeInsets.only(right: AppWidgetSize.dimen_5),
      child: logo,
    );
  }

  Widget _buildChooseBankStepdescriptionWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_20, left: AppWidgetSize.dimen_40),
          child: CustomTextWidget(
            _appLocalizations.chooseBank,
            Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildChoosePaymentModeStepdescriptionWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_30, left: AppWidgetSize.dimen_40),
          child: CustomTextWidget(
              _appLocalizations.choosePaymentmode,
              Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ),
        GestureDetector(
          onTap: () {
            pushNavigation(ScreenRoutes.addFundPaymentModeHelpContentScreen);
          },
          child: Padding(
            padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_5, top: AppWidgetSize.dimen_30),
            child: AppImages.infoIcon(context,
                color: Theme.of(context).primaryIconTheme.color, isColor: true),
          ),
        )
      ],
    );
  }

  Widget _buildFreeCustomTextWidget(String value, bool isLeftpad) {
    return Container(
      margin: EdgeInsets.only(
          left: isLeftpad ? AppWidgetSize.dimen_5 : 0,
          bottom: AppWidgetSize.dimen_5),
      decoration: BoxDecoration(
          color: Theme.of(context).snackBarTheme.backgroundColor,
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20)),
      padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 20.w),
      child: CustomTextWidget(
          value,
          Theme.of(context).textTheme.displayMedium?.copyWith(
              fontSize: AppWidgetSize.fontSize12,
              color: Theme.of(context).primaryColor)),
    );
  }

  Widget _buildPaymodeAndDescription(String title, String subtile, String sub) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (sub.isNotEmpty) _buildFreeCustomTextWidget(sub, true),
            ],
          ),
          Text(
            subtile,
            overflow: TextOverflow.clip,
            maxLines: 1,
            softWrap: false,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontSize: AppWidgetSize.fontSize12),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyPower() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextWidget('${AppLocalizations().buyingPower}:',
              Theme.of(context).textTheme.titleLarge),
          Padding(
            padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
            child: _buildBuyPowerData(),
          ),
          GestureDetector(
            onTap: () async {
              _amountFocusNode.unfocus();
              dynamic data =
                  await AppStorage().getData('getFundViewUpdatedModel');
              FundViewUpdatedModel fundViewUpdatedModel =
                  FundViewUpdatedModel.datafromJson(data);

              pushNavigation(
                ScreenRoutes.buyPowerInfoScreen,
                arguments: {"fundmodeldata": fundViewUpdatedModel},
              );

              /*pushNavigation(
                ScreenRoutes.buyPowerInfoScreen,
                arguments: {
                  "fundmodeldata": BlocProvider.of<AddFundsBloc>(context)
                      .addFundBuyPowerandWithdrawcashDoneState
                      .fundViewModel
                },
              );*/
            },
            child: Padding(
              padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
              child: AppImages.infoIcon(context,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true),
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
          bottom: AppWidgetSize.dimen_30,
          right: AppWidgetSize.dimen_30,
          left: AppWidgetSize.dimen_30),
      child: CardWidget(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          padding: EdgeInsets.all(AppWidgetSize.dimen_20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildCardTitle(),
              SizedBox(
                height: AppWidgetSize.dimen_20,
              ),
              _buildCustomTextWidget(),
              SizedBox(
                height: AppWidgetSize.dimen_20,
              ),
              _buildAmountlistWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Text _buildCardTitle() {
    return Text(
      _appLocalizations.addFunds,
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
                BlocProvider.of<AddFundsBloc>(context)
                    .add(ShowPrefixIconEvent()..isShow = true);
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
                child: _buildTextfieldWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextfieldWidget() {
    return BlocBuilder<AddFundsBloc, AddFundsState>(
      buildWhen: (previous, current) {
        return current is ShowPrefixIconState;
      },
      builder: (context, state) {
        if (state is ShowPrefixIconState) {
          return TextField(
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: AppWidgetSize.fontSize22,
                  fontFamily: AppConstants.interFont,
                ),

            autofocus: false,
            inputFormatters: [
              IndianRupeeFormatter(
                  formatter: NumberFormat(
                    "##,##,###.##",
                    "en_IN", // local US
                  ),
                  allowFraction: false),
            ],
            focusNode: _amountFocusNode,
            controller: _amountController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            // const TextInputType.numberWithOptions(
            //     signed: true, decimal: false),
            //textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              prefixIcon: Text("${AppConstants.rupeeSymbol} ",
                  style: _amountController.text.isNotEmpty ||
                          _amountFocusNode.hasPrimaryFocus
                      ? Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: AppWidgetSize.fontSize22,
                            fontFamily: AppConstants.interFont,
                          )
                      : Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: AppWidgetSize.fontSize22,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontFamily: AppConstants.interFont,
                          )),
              prefixIconConstraints: BoxConstraints(
                  minWidth: 0, minHeight: AppWidgetSize.dimen_30),
              hintText: _amountFocusNode.hasPrimaryFocus ? "" : "0",
              hintStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: AppWidgetSize.fontSize22,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontFamily: AppConstants.interFont,
                  ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.transparent, width: AppWidgetSize.dimen_1),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
            ),
          );
        }

        return Container();
      },
    );
  }

  Widget _buildAmountlistWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppWidgetSize.dimen_15),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),
            onPressed: () => {_addamount(5000)},
            child: Text(
              "+ ${AppConstants.rupeeSymbol}5,000",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: AppConstants.interFont,
                  ),
            )),
        TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppWidgetSize.dimen_15),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),
            onPressed: () => {_addamount(10000)},
            child: Text(
              "+ ${AppConstants.rupeeSymbol}10,000",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: AppConstants.interFont,
                  ),
            )),
        TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppWidgetSize.dimen_15),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),
            onPressed: () => {_addamount(25000)},
            child: Text(
              "+ ${AppConstants.rupeeSymbol}25,000",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: AppConstants.interFont,
                  ),
            )),
      ],
    );
  }

  void _addamount(int value) {
    _amountFocusNode.unfocus();
    int enteredvalue = _amountController.text.isNotEmpty
        ? AppUtils().intValue(AppUtils().removeCommaFmt(_amountController.text))
        : 0;
    BlocProvider.of<AddFundsBloc>(context)
        .add(UpdateAmountEvent(value, enteredvalue));
  }

  void _sendgetbankDetails() {
    BlocProvider.of<AddFundsBloc>(context).add(GetBankDetailsEvent());
  }

  void _getBuyPowerDetails({bool fetchApi = false}) {
    BlocProvider.of<AddFundsBloc>(context)
        .add(GetFundsViewUpdatedEvent(fetchApi: fetchApi));
    BlocProvider.of<AddFundsBloc>(context)
        .add(GetFundsViewEvent(fetchApi: fetchApi));
  }

  Future<void> _showPaymentNetBankingPage(
    String? type,
    String? url,
    String? listenUrl,
  ) async {
    //debugPrint('url -> $url');

    await showDialog(
      useSafeArea: true,
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter updateState) {
          return Stack(
            children: <Widget>[
              Scaffold(
                body: InAppWebView(
                  onReceivedServerTrustAuthRequest:
                      (controller, challenge) async {
                    return ServerTrustAuthResponse(
                        action: ServerTrustAuthResponseAction.PROCEED);
                  },
                  onWebViewCreated: (InAppWebViewController controller) {
                    _webViewController = controller;
                    _webViewController?.postUrl(
                        url: Uri.parse(url!),
                        postData: Uint8List.fromList(utf8.encode('')));
                  },
                  onConsoleMessage: (InAppWebViewController controller,
                      ConsoleMessage consoleMessage) {
                    //debugPrint('console msg $consoleMessage');
                  },
                  onLoadStart: (InAppWebViewController controller, Uri? data) {
                    startLoader();
                  },
                  onLoadStop: (InAppWebViewController controller, Uri? data) {
                    stopLoader();
                    updateState(() {
                      isNetbankingLoader = false;
                    });
                    // debugPrint(
                    //     'listenUrl -> ${listenUrl!.toLowerCase()} and ${data!.path.toLowerCase()}');

                    if (listenUrl!
                        .toLowerCase()
                        .contains(data!.path.toLowerCase())) {
                      String datavalue = data.queryParameters.keys.first;
                      List listData = datavalue.split("&");
                      //debugPrint('list_data -> $list_data');

                      var mapData = {};
                      for (var element in listData) {
                        List interData = element.toString().split("=");
                        mapData[interData.first] = interData.last;
                      }
                      //debugPrint('map_data -> $map_data');
                      //{status: FAILURE, msg: FAILED, amount: 1.00, transactionId: TRANS100965}
                      if (mapData['status'] != null &&
                          mapData['status'].toString().isNotEmpty) {
                        if (mapData['status']
                            .toString()
                            .toLowerCase()
                            .contains('success')) {
                          showSuccessAcknowledgement(
                              context: context,
                              title: 'Payment Successful',
                              msg: mapData['msg'],
                              transID: mapData['transactionId'],
                              reason: "",
                              data: []);
                        } else {
                          Map<String, String> data = _getData(
                              mapData['amount'], mapData['transactionId']);
                          Navigator.of(context).pop();

                          showFailedAcknowledgement(
                              context: context,
                              title: 'Payment Failed',
                              msg: mapData['msg'],
                              mapdata: data,
                              isUPI: false);
                        }
                      } else {
                        Map<String, String> data = _getData(
                            mapData['amount'], mapData['transactionId']);
                        Navigator.of(context).pop();

                        showFailedAcknowledgement(
                            context: context,
                            title: 'Payment Failed',
                            msg: mapData['msg'],
                            mapdata: data,
                            isUPI: false);
                      }
                    }
                  },
                ),
              ),
              Positioned(
                top: AppWidgetSize.dimen_2,
                right: AppWidgetSize.dimen_10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    //Navigator.of(context).pop();
                  },
                  child: AppImages.close(
                    context,
                    width: AppWidgetSize.dimen_20,
                    height: AppWidgetSize.dimen_20,
                  ),
                ),
              ),
              isNetbankingLoader
                  ? Container(
                      alignment: Alignment.center,
                      child: const LoaderWidget(),
                    )
                  : Container(),
            ],
          );
        });
      },
    );
  }

  dynamic _getData(String amount, String transID) {
    int indexdata =
        BlocProvider.of<AddFundsBloc>(context).getbankListDoneState.dataindex;

    var dataResult = BlocProvider.of<AddFundsBloc>(context)
        .getbankListDoneState
        .resultDataList!
        .elementAt(indexdata);

    Banks bank = BlocProvider.of<AddFundsBloc>(context)
        .getbankListDoneState
        .bankDetailsModel!
        .banks!
        .elementAt(indexdata);

    Map<String, String> data = {
      'amount': amount,
      'transID': transID,
      'bank_name': bank.bankName!,
      'account_number': dataResult['accountno'],
      'to': 'Arihant Wallet'
    };
    return data;
  }

  dynamic _getDataForUPIFailcase() {
    int indexdata =
        BlocProvider.of<AddFundsBloc>(context).getbankListDoneState.dataindex;
    Banks bank = BlocProvider.of<AddFundsBloc>(context)
        .getbankListDoneState
        .bankDetailsModel!
        .banks!
        .elementAt(indexdata);

    String amount = BlocProvider.of<AddFundsBloc>(context)
        .addFundUPITransactionStatusDoneState
        .fundsTransactionStatusUPIModel
        .amount!;
    String transID = BlocProvider.of<AddFundsBloc>(context)
        .addFundUPITransactionStatusDoneState
        .fundsTransactionStatusUPIModel
        .transId!;
    String vpa = BlocProvider.of<AddFundsBloc>(context)
        .addFundUPITransactionStatusDoneState
        .fundsTransactionStatusUPIModel
        .vpa!;

    Map<String, String> data = {
      'amount': amount,
      'transID': transID,
      'bank_name': bank.bankName!,
      'vpa': vpa,
    };

    //debugPrint('data part is $data');
    return data;
  }

  void showFailedAcknowledgement(
      {required BuildContext context,
      required String title,
      required String msg,
      required Map<String, String> mapdata,
      required bool isUPI}) {
    // Future.delayed(
    //   const Duration(seconds: 5),
    //   () {
    //     if (isFailButtonPressed == null) {
    //       //Navigator.of(context).pop();
    //       //Navigator.of(context).pop();
    //     }
    //   },
    // );
    AppStorage().removeData('getRecentFundTransaction');
    AppStorage().removeData('getFundHistorydata');
    // AppStorage().removeData('getFundViewUpdatedModel');
    showModalBottomSheet(
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      context: context,
      enableDrag: false,
      isDismissible: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (_, StateSetter updateState) {
            return DraggableScrollableSheet(
              expand: false,
              maxChildSize: 1,
              initialChildSize: 1,
              builder: (_, ScrollController scrollController) {
                return Scaffold(
                  body: Stack(
                    children: [
                      _buildTopFailWidget(context, title, msg, mapdata, isUPI),
                      _buildButtonBottomFailWidget(context, isUPI)
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void showSuccessAcknowledgement(
      {required BuildContext context,
      required String title,
      required String msg,
      required String transID,
      required String reason,
      List<String>? data}) {
    // Future.delayed(
    //   const Duration(seconds: 5),
    //   () {
    //     if (isSuccessButtonPressed == null) {
    //       //Navigator.of(context).pop();
    //       //Navigator.of(context).pop();
    //     }
    //   },
    // );
    AppStorage().removeData('getRecentFundTransaction');
    AppStorage().removeData('getFundHistorydata');
    AppStorage().removeData('getFundViewUpdatedModel');
    _getBuyPowerDetails(fetchApi: true);
    showModalBottomSheet(
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      context: context,
      enableDrag: false,
      isDismissible: true,
      isScrollControlled: true,
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
                    _buildTopWidget(
                        context, title, msg, transID, reason, data!),
                    _buildButtonBottomWidget(context, true)
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTopFailWidget(BuildContext context, String title, String msg,
      Map<String, String> data, bool isUPI) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _buildUpperTopWidget(context, title, msg, isUPI),
          if (isUPI)
            _buildUPIFailDataWidget(data)
          else
            _buildFailDataWidget(data),
        ],
      ),
    );
  }

  SingleChildScrollView _buildTopWidget(BuildContext context, String title,
      String msg, String transID, String reason, List<String> data) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildUpperWidget(context, title, msg, transID, reason, data),
          _buildFundsView(context),
        ],
      ),
    );
  }

  Padding _buildButtonBottomFailWidget(BuildContext context, bool isUPI) {
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
            _buildButtonCallBack(
                context, _appLocalizations.myFunds, 'fail', isUPI),
            _buildButtonCallBack(
                context, _appLocalizations.retry, 'fail', isUPI)
          ],
        ),
      ),
    );
  }

  Padding _buildButtonBottomWidget(BuildContext context, bool value) {
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
            _buildButtonCallBack(
                context, _appLocalizations.myFunds, 'success', value),
            _buildButtonCallBack(
                context, _appLocalizations.startInvesting, 'success', value)
          ],
        ),
      ),
    );
  }

  Widget _buildButtonCallBack(
      BuildContext context, String keyvalue, String source, bool isUPI) {
    return gradientButtonWidget(
        onTap: () {
          if (source.contains('fail')) {
            isFailButtonPressed = true;
          } else {
            isSuccessButtonPressed = true;
          }

          if (keyvalue == _appLocalizations.retry) {
            if (isUPI) {
              navigateToUntil(ScreenRoutes.addfundsScreen);
            } else {
              Navigator.pop(context);
              Navigator.pop(context);
            }
          } else {
            if (keyvalue == _appLocalizations.startInvesting) {
              pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen,
                  arguments: {'pageName': ScreenRoutes.watchlistScreen});
            } else {
              pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen,
                  arguments: {'pageName': ScreenRoutes.myfundsScreen});
            }
          }
        },
        width: AppWidgetSize.fullWidth(context) / 2.5,
        key: Key(keyvalue),
        context: context,
        title: keyvalue,
        isGradient: true,
        bottom: AppWidgetSize.dimen_20);
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

  Widget _buildUPIFailDataWidget(Map<String, String> datavalue) {
    return Column(
      children: [
        _buildAmountDataWidget(datavalue['amount']!),
        _buildBankNameDataWidget(datavalue['bank_name']!),
        _buildVPADataWidget(datavalue['vpa']!),
        _buildToDataWidget(),
        _buildTransactionIDDataWidget(datavalue['transID']!),
        _buildNeedHelpWidget(),
      ],
    );
  }

  Widget _buildFailDataWidget(Map<String, String> datavalue) {
    return Column(
      children: [
        _buildAmountDataWidget(datavalue['amount']!),
        _buildBankNameDataWidget(datavalue['bank_name']!),
        _buildAccountnumberDataWidget(datavalue['account_number']!),
        _buildToDataWidget(),
        _buildTransactionIDDataWidget(datavalue['transID']!),
        _buildNeedHelpWidget(),
      ],
    );
  }

  Widget _buildNeedHelpWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20, bottom: AppWidgetSize.dimen_20),
      child: InkWell(
        onTap: () {
          pushNavigation(ScreenRoutes.addfundHelpErrorContentScreen);
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

  Widget _getLableWithRupeeSymbol(
    String value,
    TextStyle? rupeeStyle,
    TextStyle? textStyle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        getRupeeSymbol(
          context,
          rupeeStyle!,
        ),
        CustomTextWidget(
          value,
          textStyle,
        ),
      ],
    );
  }

  Widget _buildRowData(String key, String value, bool iscopy) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_15,
        left: AppWidgetSize.dimen_20,
        right: AppWidgetSize.dimen_20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: Theme.of(context).textTheme.titleLarge!),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (key.toLowerCase().contains('amount'))
                _getLableWithRupeeSymbol(
                  value,
                  Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontFamily: AppConstants.interFont,
                      fontWeight: FontWeight.w500),
                  Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontFamily: AppConstants.interFont,
                      fontWeight: FontWeight.w500),
                )
              else
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontFamily: AppConstants.interFont,
                      fontWeight: FontWeight.w500),
                ),
              if (iscopy)
                Padding(
                  padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_3,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      showToast(
                        message: "Copied",
                        context: context,
                      );
                    },
                    child: AppImages.copyIcon(context,
                        color: Theme.of(context).textTheme.labelSmall!.color,
                        isColor: true),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDataWidget(String amount) {
    return _buildRowData('Amount', amount, false);
  }

  Widget _buildBankNameDataWidget(String bankname) {
    return _buildRowData('From', bankname, false);
  }

  Widget _buildAccountnumberDataWidget(String accountnumber) {
    return _buildRowData('Account Number', accountnumber, false);
  }

  Widget _buildToDataWidget() {
    return _buildRowData('To', 'Arihant Wallet', false);
  }

  Widget _buildTransactionIDDataWidget(String transID) {
    return _buildRowData('Transaction ID', transID, true);
  }

  Widget _buildVPADataWidget(String vpa) {
    return _buildRowData('vpa', vpa, true);
  }

  Widget _buildUpperTopWidget(
      BuildContext context, String title, String msg, bool isUPI) {
    //debugPrint("screenheigth -> ${AppWidgetSize.screenHeight(context)}");
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
        top: AppWidgetSize.dimen_70,
        bottom: AppWidgetSize.dimen_10,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AppImages.paymentFailed(context,
                height: AppWidgetSize.screenHeight(context) <
                        AppWidgetSize.dimen_600
                    ? AppWidgetSize.dimen_150
                    : (AppConfig.isLandScape
                        ? AppWidgetSize.dimen_170
                        : AppWidgetSize.dimen_220)),
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_30,
                bottom: AppWidgetSize.dimen_10,
              ),
              child: CustomTextWidget(
                title,
                Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (msg.isNotEmpty)
              CustomTextWidget(
                msg,
                Theme.of(context).primaryTextTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Padding _buildUpperWidget(BuildContext context, String title, String msg,
      String transID, String reason, List<String> data) {
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
            AppImages.successImage(context),
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
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_20,
                //bottom: AppWidgetSize.dimen_30,
              ),
              child: reason.isEmpty
                  ? RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: 'Hurray!',
                              style: Theme.of(context).textTheme.headlineSmall),
                          TextSpan(
                            text: ' \u{20B9}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontFamily: AppConstants.interFont,
                                ),
                          ),
                          TextSpan(
                            text:
                                '${_amountController.text} has been added succesfully to your account. And its transaction reference number is $transID',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    )
                  : RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: data.first,
                              style: Theme.of(context).textTheme.headlineSmall),
                          TextSpan(
                            text: ' \u{20B9}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontFamily: AppConstants.interFont,
                                ),
                          ),
                          TextSpan(
                            text: data.last,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),

              // Text(
              //     reason,
              //     style: Theme.of(context).textTheme.headline5,
              //     textAlign: TextAlign.center,
              //   ),
            ),
            /*Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_20,
                bottom: AppWidgetSize.dimen_20,
              ),
              child: CustomTextWidget(
                msg,
                Theme.of(context).primaryTextTheme.overline,
                textAlign: TextAlign.center,
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildBuyPowerData() {
    return BlocBuilder<AddFundsBloc, AddFundsState>(
      buildWhen: (previous, current) {
        return current is AddFundBuyPowerandWithdrawcashDoneState;
      },
      builder: (context, state) {
        if (state is AddFundBuyPowerandWithdrawcashDoneState) {
          return _getLableWithRupeeSymbol(
            state.buy_power,
            Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: AppConstants.interFont,
                fontSize: AppWidgetSize.dimen_15),
            Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.w600),
          );
        }
        return _getLableWithRupeeSymbol(
          '',
          Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: AppConstants.interFont,
              fontSize: AppWidgetSize.dimen_15),
          Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.w600),
        );
      },
    );
  }
}
