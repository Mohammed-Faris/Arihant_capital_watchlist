import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../blocs/my_funds/fund_history/fund_history_bloc.dart';
import '../../../../constants/app_constants.dart';
import '../../../../data/store/app_storage.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/my_funds/transaction_history_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_color.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../validator/input_validator.dart';
import '../../../widgets/circular_toggle_button_widget.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/refresh_widget.dart';
import '../../../widgets/rupee_symbol_widget.dart';
import '../../base/base_screen.dart';

class FundsHistoryScreen extends BaseScreen {
  final dynamic arguments;
  const FundsHistoryScreen({Key? key, this.arguments}) : super(key: key);

  @override
  FundsHistoryScreenState createState() => FundsHistoryScreenState();
}

class FundsHistoryScreenState extends BaseAuthScreenState<FundsHistoryScreen> {
  final List<String> _optionList = <String>[
    AppConstants.all,
    AppConstants.fundadded,
    AppConstants.fundwithdraw,
    AppConstants.customdates,
  ];

  final TextEditingController _fromdateController =
      TextEditingController(text: '');
  final TextEditingController _todateController =
      TextEditingController(text: '');
  FocusNode fromdateFocusNode = FocusNode();
  FocusNode todateFocusNode = FocusNode();
  final DateFormat _formatter = DateFormat('dd/MM/yyyy');
  String selectedSegment = AppConstants.all;
  final ScrollController _scrollControllerForTopContent = ScrollController();
  final ScrollController _scrollControllerForContent = ScrollController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FundhistoryBloc>(context).add(
        FundHistoryOptionSelectedEvent()..selectedValue = AppConstants.all);
    BlocProvider.of<FundhistoryBloc>(context).add(GetTransactionHistoryEvent());
    BlocProvider.of<FundhistoryBloc>(context)
        .stream
        .listen(fundhistoryBlocListner);
  }

  Future<void> fundhistoryBlocListner(FundHistoryState state) async {
    if (state is FundTransactionHistoryDoneState) {
      _fromdateController.text = '';
      _todateController.text = '';

      if (state.selectedFromDate.isNotEmpty) {
        _fromdateController.text = state.selectedFromDate;
      }

      if (state.selectedToDate.isNotEmpty) {
        _todateController.text = state.selectedToDate;
      }
    } else if (state is FundHistoryShowCalenderErrorDoneState) {
      showToast(
        message: state.msg,
        context: context,
        isError: true,
      );
    } else if (state is FundHistoryCancelDoneState) {
      showToast(
        message: state.message,
        context: context,
        isError: false,
      );
      BlocProvider.of<FundhistoryBloc>(context)
          .add(GetTransactionHistoryEvent());
    } else if (state is FundHistoryCancelFailedState) {
      showToast(
        message: state.message,
        context: context,
        isError: true,
      );
    } else if (state is FundHistoryErrorState) {
      stopLoader();
      if (state.isInvalidException) {
        handleError(state);
      } else if (!state.isInvalidException) {
        showToast(
          message: state.errorMsg,
          context: context,
          isError: true,
        );
      }
    } else if (state is FundHistoryProgressState) {
      if (mounted) {
        startLoader();
      }
    } else if (state is! FundHistoryProgressState) {
      if (mounted) {
        stopLoader();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        appBar: _buildAppBar(),
        resizeToAvoidBottomInset: true,
        body: RefreshWidget(
          onRefresh: () async {
            debugPrint('called !!!');
            if (selectedSegment == AppConstants.fundadded ||
                selectedSegment == AppConstants.fundwithdraw) {
              AppStorage().removeData('getFundHistorydata');
              BlocProvider.of<FundhistoryBloc>(context).add(
                  GetTransactionHistoryEvent()
                    ..selectedSegment = selectedSegment);
            } else if (selectedSegment == AppConstants.all) {
              AppStorage().removeData('getFundHistorydata');
              BlocProvider.of<FundhistoryBloc>(context)
                  .add(GetTransactionHistoryEvent()..selectedSegment = '');
            } else if (selectedSegment == AppConstants.customdates) {
              fromdateFocusNode.unfocus();
              todateFocusNode.unfocus();

              BlocProvider.of<FundhistoryBloc>(context)
                  .add(GetTransactionHistoryEvent()
                    ..fromdate = _fromdateController.text
                    ..todate = _todateController.text
                    ..selectedSegment = AppConstants.customdates);
            }
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
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
              child: InkWell(
                  onTap: () {
                    _showFundHistoryDescription();
                  },
                  child: AppImages.infoIcon(
                    context,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true,
                  )),
            ),
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
              AppLocalizations().alltransaction,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggleWidget(),
        _buildCalendarWidget(),
        _buildDescrpitionWidget(),
        _buildDataWidget(),
      ],
    );
  }

  Widget _buildDescrpitionWidget() {
    return BlocBuilder<FundhistoryBloc, FundHistoryState>(
      buildWhen: (previous, current) {
        return current is FundTransactionHistoryDoneState;
      },
      builder: (context, state) {
        if (state is FundTransactionHistoryDoneState) {
          if (state.isCustomDateOptionSelected == true) {
            if (state.transactionHistoryModel != null) {
              return Expanded(
                child: SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.transactionHistoryModel!.history!.length,
                    itemBuilder: (context, index) {
                      return _buildListData(state, index);
                    },
                  ),
                ),
              );
            }
            if (state.isHideTextDescription == false) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_40,
                      right: AppWidgetSize.dimen_30),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CustomTextWidget(
                          "Select custom date",
                          Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        CustomTextWidget(
                          'View your fund transaction history for the period of your choice',
                          Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          }
        }

        return Container();
      },
    );
  }

  Widget _buildCalendarWidget() {
    return BlocBuilder<FundhistoryBloc, FundHistoryState>(
      buildWhen: (previous, current) {
        return current is FundTransactionHistoryDoneState;
      },
      builder: (context, state) {
        if (state is FundTransactionHistoryDoneState) {
          if (state.isCustomDateOptionSelected == true) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFromDateWidget(),
                  _buildToDateWidget(),
                  _buildTickMarkWidget(state),
                ],
              ),
            );
          }
        }

        return Container();
      },
    );
  }

  Widget _buildTickMarkWidget(FundTransactionHistoryDoneState state) {
    return GestureDetector(
      onTap: () {
        if (state.isShowCrossMark == true) {
          BlocProvider.of<FundhistoryBloc>(context)
              .add(GetTransactionClearDateEvent());

          BlocProvider.of<FundhistoryBloc>(context)
              .add(GetTransactionHistoryEvent()
                ..selectedSegment = AppConstants.customdates
                ..fromdate = ''
                ..todate = '');
        } else {
          BlocProvider.of<FundhistoryBloc>(context)
              .add(GetTransactionHistoryEvent()
                ..fromdate = _fromdateController.text
                ..todate = _todateController.text
                ..selectedSegment = AppConstants.customdates);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_20, right: AppWidgetSize.dimen_25),
        child: (state.isShowCrossMark == true)
            ? AppImages.crossButton(
                context,
              )
            : (state.isTickMarkEnable == true)
                ? AppImages.tickEnable(
                    context,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true,
                  )
                : AppImages.tickDisable(context,
                    color: Theme.of(context).textTheme.displaySmall!.color,
                    isColor: true),
      ),
    );
  }

  Widget _buildToDateWidget() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_20,
            right: AppWidgetSize.dimen_15,
            left: AppWidgetSize.dimen_10),
        child: TextFormField(
          autocorrect: false,
          enabled: true,
          enableInteractiveSelection: false,
          focusNode: todateFocusNode,
          onChanged: (String text) {
            if (text.length == 10) {
              BlocProvider.of<FundhistoryBloc>(context)
                  .add(FundHistoryDateSelectEvent()
                    ..selectedFromDate = _fromdateController.text
                    ..selectedToDate = text);
            }
          },
          onTap: () {},
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: InputValidator.dob,
          controller: _todateController,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(
              left: AppWidgetSize.dimen_15,
              top: AppWidgetSize.dimen_3,
              bottom: AppWidgetSize.dimen_3,
              right: AppWidgetSize.dimen_10,
            ),
            hintText: "DD/MM/YYYY",
            hintStyle: Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                fontSize: AppWidgetSize.fontSize10,
                color: Theme.of(context).primaryTextTheme.labelSmall!.color),
            labelText: 'To Date',
            labelStyle: Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                color: Theme.of(context).primaryTextTheme.labelSmall!.color),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.w),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1950, 1),
                  lastDate: DateTime.now(),
                  helpText: "",
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.fromSwatch(
                          primarySwatch: MaterialColor(
                              AppColors().positiveColor.value,
                              AppColors.calendarPrimaryColorSwatch),
                        ),
                        textTheme: TextTheme(
                          labelSmall:
                              TextStyle(fontSize: AppWidgetSize.fontSize16),
                        ),
                      ),
                      child: child!,
                    );
                  },
                ).then(
                  (pickedDate) {
                    if (pickedDate != null) {
                      final String formatted = _formatter.format(pickedDate);

                      BlocProvider.of<FundhistoryBloc>(context)
                          .add(FundHistoryDateSelectEvent()
                            ..selectedFromDate = _fromdateController.text
                            ..selectedToDate = formatted);
                    }
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.all(AppWidgetSize.dimen_8),
                child: AppImages.calendarIcon(
                  context,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ),
          maxLength: 20,
        ),
      ),
    );
  }

  Widget _buildFromDateWidget() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_25,
          right: AppWidgetSize.dimen_2,
        ),
        child: TextFormField(
          autocorrect: false,
          enabled: true,
          enableInteractiveSelection: false,
          focusNode: fromdateFocusNode,
          onChanged: (String text) {
            if (text.length == 10) {
              BlocProvider.of<FundhistoryBloc>(context)
                  .add(FundHistoryDateSelectEvent()
                    ..selectedFromDate = text
                    ..selectedToDate = _todateController.text);
            }
          },
          onTap: () {},
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: InputValidator.dob,
          controller: _fromdateController,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(
              left: AppWidgetSize.dimen_15,
              top: AppWidgetSize.dimen_3,
              bottom: AppWidgetSize.dimen_3,
              right: AppWidgetSize.dimen_10,
            ),
            hintText: "DD/MM/YYYY",
            hintStyle: Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                fontSize: AppWidgetSize.fontSize10,
                color: Theme.of(context).primaryTextTheme.labelSmall!.color),
            labelText: 'From Date',
            labelStyle: Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                color: Theme.of(context).primaryTextTheme.labelSmall!.color),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.w),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1950, 1),
                  lastDate: DateTime.now(),
                  helpText: "",
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.fromSwatch(
                          primarySwatch: MaterialColor(
                              AppColors().positiveColor.value,
                              AppColors.calendarPrimaryColorSwatch),
                        ),
                        textTheme: TextTheme(
                          labelSmall:
                              TextStyle(fontSize: AppWidgetSize.fontSize16),
                        ),
                      ),
                      child: child!,
                    );
                  },
                ).then(
                  (pickedDate) {
                    if (pickedDate != null) {
                      final String formatted = _formatter.format(pickedDate);
                      BlocProvider.of<FundhistoryBloc>(context)
                          .add(FundHistoryDateSelectEvent()
                            ..selectedFromDate = formatted
                            ..selectedToDate = _todateController.text);
                    }
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.all(AppWidgetSize.dimen_8),
                child: AppImages.calendarIcon(
                  context,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ),
          maxLength: 20,
        ),
      ),
    );
  }

  Widget _buildDataWidget() {
    return BlocBuilder<FundhistoryBloc, FundHistoryState>(
      buildWhen: (previous, current) {
        return current is FundTransactionHistoryDoneState ||
            current is FundHistoryTransactionErrorState;
      },
      builder: (context, state) {
        if (state is FundHistoryTransactionErrorState) {
          return Expanded(
            child: Center(
              child: Text(
                state.errorMsg,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          );
        } else if (state is FundTransactionHistoryDoneState) {
          if (state.isCustomDateOptionSelected == false) {
            if (state.filteredhistorydata != null &&
                state.filteredhistorydata!.isEmpty) {
              return Expanded(
                  child: ListView(
                children: [
                  SizedBox(
                    height: AppWidgetSize.screenHeight(context) -
                        AppWidgetSize.dimen_200,
                    child: Center(
                      child: Text(
                        "No data available",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                ],
              ));
            } else {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: _scrollControllerForContent,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: (state.filteredhistorydata != null)
                        ? state.filteredhistorydata!.length
                        : state.transactionHistoryModel!.history!.length,
                    itemBuilder: (context, index) {
                      return _buildListData(state, index);
                    },
                  ),
                ),
              );
            }
          }
        }

        return Container();
      },
    );
  }

  Widget _buildListData(FundTransactionHistoryDoneState stateObj, int index) {
    History data = stateObj.transactionHistoryModel!.history!.elementAt(index);
    if (stateObj.filteredhistorydata != null) {
      data = stateObj.filteredhistorydata!.elementAt(index);
    }

    return _buildDataRow(data);
  }

  Widget _buildDataRow(History data) {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_10, right: AppWidgetSize.dimen_30),
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

  Column _buildWithdrawandAddStatusWidget(History data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: AppWidgetSize.dimen_20,
          width:
              AppWidgetSize.screenWidth(context) / 2 - AppWidgetSize.dimen_40,
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

  String? _getTransTypeorBankAcc(History data) {
    if (data.payIn == true) {
      return data.transType ?? "";
    } else {
      return data.dispAccnumber;
    }
  }

  void _showCancelTransactionConfirmationBottomSheet(History data) {
    Navigator.of(context).pop();
    showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
        isScrollControlled: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
        ),
        enableDrag: false,
        isDismissible: true,
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
        });
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
                  BlocProvider.of<FundhistoryBloc>(context).add(
                      FundHistoryCancelEvent()..idvalue = data.instructionId!);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeatilsBottomSheet(History data) {
    showInfoBottomsheet(_buildDetailViewWidget(data));
  }

  Widget _buildDetailViewWidget(History data) {
    return Column(
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

  Widget _buildUPIDetailWidget(History data) {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_25),
      child: _builddetailRow('VPA', data.vpa ?? ""),
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

  SingleChildScrollView _buildToggleWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollControllerForTopContent,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20,
        ),
        child: _buildOptionToggelWidget(),
      ),
    );
  }

  Widget _buildOptionToggelWidget() {
    return BlocBuilder<FundhistoryBloc, FundHistoryState>(
      buildWhen: (previous, current) {
        return current is FundHistoryOptionSelectedDoneState;
      },
      builder: (context, state) {
        if (state is FundHistoryOptionSelectedDoneState) {
          return CircularButtonToggleWidget(
            value: state.selectedValue,
            toggleButtonlist: _optionList,
            toggleButtonOnChanged: toggleButtonOnChanged,
            marginEdgeInsets: EdgeInsets.only(
              right: AppWidgetSize.dimen_1,
              top: AppWidgetSize.dimen_6,
            ),
            paddingEdgeInsets: EdgeInsets.fromLTRB(
              AppWidgetSize.dimen_14,
              AppWidgetSize.dimen_6,
              AppWidgetSize.dimen_14,
              AppWidgetSize.dimen_6,
            ),
            activeButtonColor: AppUtils().isLightTheme()
                ? Theme.of(context)
                    .snackBarTheme
                    .backgroundColor!
                    .withOpacity(0.5)
                : Theme.of(context).primaryColor,
            activeTextColor: AppUtils().isLightTheme()
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColorLight,
            inactiveButtonColor: Colors.transparent,
            inactiveTextColor: Theme.of(context).primaryColor,
            key: const Key("options_"),
            defaultSelected: '',
            enabledButtonlist: const [],
            isBorder: false,
            context: context,
            borderColor: Colors.transparent,
            fontSize: 18.w,
          );
        }
        return Container();
      },
    );
  }

  void toggleButtonOnChanged(String data) {
    if (_scrollControllerForTopContent.positions.isNotEmpty) {
      _scrollControllerForTopContent.animateTo(0,
          duration: const Duration(microseconds: 1), curve: Curves.ease);
    }
    if (_scrollControllerForContent.positions.isNotEmpty) {
      _scrollControllerForContent.animateTo(0,
          duration: const Duration(microseconds: 1), curve: Curves.ease);
    }

    selectedSegment = data;
    BlocProvider.of<FundhistoryBloc>(context)
        .add(FundHistoryOptionSelectedEvent()..selectedValue = data);

    if (data == AppConstants.fundadded || data == AppConstants.fundwithdraw) {
      BlocProvider.of<FundhistoryBloc>(context)
          .add(GetTransactionHistoryEvent()..selectedSegment = data);
    } else if (data == AppConstants.all) {
      BlocProvider.of<FundhistoryBloc>(context)
          .add(GetTransactionHistoryEvent()..selectedSegment = '');
    } else if (data == AppConstants.customdates) {
      if (!AppUtils.isTablet) {
        _scrollControllerForTopContent.animateTo(AppWidgetSize.dimen_100,
            duration: const Duration(microseconds: 5), curve: Curves.ease);
      }
      fromdateFocusNode.unfocus();
      todateFocusNode.unfocus();

      BlocProvider.of<FundhistoryBloc>(context)
          .add(GetTransactionClearDateEvent());

      BlocProvider.of<FundhistoryBloc>(context).add(GetTransactionHistoryEvent()
        ..selectedSegment = AppConstants.customdates);
    }
  }

  void _showFundHistoryDescription() {
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
              child: _buildareceFundHistorydescriptionWidget());
        });
  }

  Widget _buildareceFundHistorydescriptionWidget() {
    return SizedBox(
      height: AppWidgetSize.dimen_200,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_30,
                left: AppWidgetSize.dimen_20,
                right: AppWidgetSize.dimen_20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Fund History",
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
                  child: CustomTextWidget(
                    "This view shows all fund transfers and withdrawals initiated through your mobile trading app and web. This will include both, your failed and successfully completed transactions.",
                    Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
