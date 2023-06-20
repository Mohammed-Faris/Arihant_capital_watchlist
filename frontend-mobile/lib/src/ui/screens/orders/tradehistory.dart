// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../blocs/orders/trade_history/tradehistory_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/keys/search_keys.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/sort_filter/sort_filter_model.dart';
import '../../../notifiers/notifiers.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../validator/dob_validator.dart';
import '../../validator/input_validator.dart';
import '../../widgets/circular_toggle_button_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/sort_filter_widget.dart';
import '../base/base_screen.dart';
import 'widgets/trade_row_widget.dart';

class TradeHistoryScreen extends BaseScreen {
  const TradeHistoryScreen({
    Key? key,
  }) : super(key: key);

  @override
  TradeHistoryScreenState createState() => TradeHistoryScreenState();
}

class TradeHistoryScreenState extends BaseAuthScreenState<TradeHistoryScreen> {
  late AppLocalizations _appLocalizations;
  late DateTime? fromDate;
  late DateTime? toDate;
  @override
  void initState() {
    super.initState();

    fromDate = DateTime.now().subtract(const Duration(days: 7));
    toDate = DateTime.now();
    fetchTradeHistory();
    selectedFilters = getFilterModel();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.tradeHistory);
  }

  List<String> gettradeHistoryFilter() {
    return [
      AppLocalizations().oneweek,
      AppLocalizations().onemonth,
      AppLocalizations().threemonths,
      AppLocalizations().customDates,
    ];
  }

  String toggleButtonOnChanged(String name) {
    return name;
  }

  FocusNode fromFocus = FocusNode();
  FocusNode toFocus = FocusNode();

  Widget _buildSearch(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {});
        _searchNotifier.changeSearchBar(true);

        FocusScope.of(context).requestFocus();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_15,
        ),
        child: AppImages.search(
          context,
          color: Theme.of(context).primaryIconTheme.color,
          isColor: true,
          width: AppWidgetSize.dimen_25,
          height: AppWidgetSize.dimen_25,
        ),
      ),
    );
  }

  late final SearchNotifier _searchNotifier = SearchNotifier(false);

  final TextEditingController _fromController = TextEditingController(text: '');
  final TextEditingController _toController = TextEditingController(text: '');

  int selectedFilterIndex = 0;
  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          centerTitle: false,
          titleSpacing: 0,
          toolbarHeight: AppWidgetSize.getSize(AppWidgetSize.dimen_66),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          actions: [
            ValueListenableBuilder(
              valueListenable: _searchNotifier,
              builder: (BuildContext context, bool value, Widget? child) {
                if (!value) {
                  return Padding(
                    padding: EdgeInsets.only(right: AppWidgetSize.dimen_20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFilter(context),
                        SizedBox(
                          height: AppWidgetSize.dimen_22,
                          child: VerticalDivider(
                            color:
                                Theme.of(context).textTheme.labelLarge!.color,
                            width: 1.5,
                          ),
                        ),
                        _buildSearch(context)
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              },
            )
          ],
          title: ValueListenableBuilder(
              valueListenable: _searchNotifier,
              builder: (BuildContext context, bool value, Widget? child) {
                return Container(
                  padding: EdgeInsets.only(left: AppWidgetSize.dimen_20),
                  width: AppWidgetSize.screenWidth(context),
                  child: Column(
                    children: [
                      if (value) _buildSearchTextBox() else topBar(context),
                    ],
                  ),
                );
              })),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            topFilterWidget(context),
            if (selectedFilterIndex == 3) customDateFilter(context),
            bodyListview()
          ],
        ),
      ),
    );
  }

  final TextEditingController _searchController =
      TextEditingController(text: '');
  Widget _buildSearchTextBox() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
        bottom: AppWidgetSize.dimen_20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          backIconButton(
            onTap: () {
              popNavigation();
            },
          ),
          Container(
            width: AppWidgetSize.screenWidth(context) - AppWidgetSize.dimen_60,
            height: AppWidgetSize.dimen_45,
            alignment: Alignment.centerLeft,
            child: Stack(
              children: [
                TextField(
                  cursorColor: Theme.of(context).iconTheme.color,
                  enableInteractiveSelection: true,
                  autocorrect: false,
                  enabled: true,
                  controller: _searchController,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (String text) {
                    fetchTradeHistory(fetchApi: false);
                  },
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  inputFormatters: InputValidator.searchSymbol,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelLarge!
                      .copyWith(fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      top: AppWidgetSize.dimen_10,
                      bottom: AppWidgetSize.dimen_7,
                      right: AppWidgetSize.dimen_10,
                    ),
                    hintText: _appLocalizations.holdingsSearchHint,
                    hintStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context)
                            .dialogBackgroundColor
                            .withAlpha(-1)),
                    counterText: '',
                  ),
                  maxLength: 25,
                ),
                Positioned(
                  right: 0,
                  top: AppWidgetSize.dimen_12,
                  child: GestureDetector(
                    onTap: () {
                      _searchNotifier.value = false;
                      _searchController.text = "";
                      fetchTradeHistory(fetchApi: false);
                    },
                    child: Center(
                      child: AppImages.deleteIcon(
                        context,
                        width: AppWidgetSize.dimen_25,
                        height: AppWidgetSize.dimen_25,
                        color: Theme.of(context).primaryIconTheme.color,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isValidDate() {
    fetchchedCustomDateData.value = false;
    bool isValidDate = false;
    if (_toController.text.length == 10 && _fromController.text.length == 10) {
      if (DateFormat('dd/MM/yyyy')
          .parse(_fromController.text)
          .isAfter(DateFormat('dd/MM/yyyy').parse(_toController.text))) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showToast(
              message: "To Date should be greater than From date",
              isError: true);
        });

        isValidDate = false;
      } else {
        isValidDate = DateFormatter.isValidDOB(
                _toController.text.trim(), "dd/MM/yyyy") &&
            DateFormatter.isValidDOB(_fromController.text.trim(), "dd/MM/yyyy");
      }
    } else {
      isValidDate = false;
    }
    return isValidDate;
  }

  Widget customDateFilter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.38,
            child: TextFormField(
              showCursor: true,
              toolbarOptions: const ToolbarOptions(
                copy: false,
                cut: false,
                paste: false,
                selectAll: false,
              ),
              enableInteractiveSelection: true,
              autocorrect: false,
              enabled: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: InputValidator.dob,
              onChanged: (a) {
                if (_fromController.text.length == 10) {
                  toFocus.requestFocus();
                }
                validDate.value = isValidDate();
              },
              focusNode: fromFocus,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              controller: _fromController,
              style: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: AppWidgetSize.fontSize14),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: AppWidgetSize.dimen_10,
                  top: AppWidgetSize.dimen_12,
                  bottom: AppWidgetSize.dimen_12,
                ),
                hintText: "DD/MM/YYYY",
                hintStyle: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(
                        fontSize: AppWidgetSize.fontSize10,
                        color: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .color),
                errorStyle: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(color: Theme.of(context).colorScheme.error),
                labelText: _appLocalizations.fromDate,
                labelStyle: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(
                        fontSize: AppWidgetSize.fontSize14,
                        color: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .color),
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
                  onTap: () async {
                    _fromController.text =
                        await _displayDatePickerWidget(context);
                    validDate.value = isValidDate();
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
              maxLength: 10,
            ),
          ),
          SizedBox(
            width: AppWidgetSize.dimen_10,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.38,
            child: TextFormField(
              showCursor: true,
              toolbarOptions: const ToolbarOptions(
                copy: false,
                cut: false,
                paste: false,
                selectAll: false,
              ),
              enableInteractiveSelection: true,
              autocorrect: false,
              enabled: true,
              onChanged: (e) {
                validDate.value = isValidDate();
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: InputValidator.dob,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              controller: _toController,
              style: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: AppWidgetSize.fontSize14),
              focusNode: toFocus,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: AppWidgetSize.dimen_10,
                  top: AppWidgetSize.dimen_12,
                  bottom: AppWidgetSize.dimen_12,
                ),
                hintText: "DD/MM/YYYY",
                hintStyle: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(
                        fontSize: AppWidgetSize.fontSize10,
                        color: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .color),
                errorStyle: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(color: Theme.of(context).colorScheme.error),
                labelText: _appLocalizations.toDate,
                labelStyle: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(
                        fontSize: AppWidgetSize.fontSize14,
                        color: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .color),
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
                  onTap: () async {
                    _toController.text =
                        await _displayDatePickerWidget(context);
                    validDate.value = isValidDate();
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
              maxLength: 10,
            ),
          ),
          ValueListenableBuilder<bool>(
              valueListenable: validDate,
              builder: (context, value, s) {
                return ValueListenableBuilder<bool>(
                    valueListenable: fetchchedCustomDateData,
                    builder: (context, value, s) {
                      return GestureDetector(
                        onTap: () {
                          if (validDate.value &&
                              fetchchedCustomDateData.value) {
                            fromDateToDateSetter(clear: true);
                            fetchTradeHistory();
                            validDate.value = false;
                            fetchchedCustomDateData.value = true;
                            fromFocus.requestFocus();
                          } else if (validDate.value) {
                            fetchchedCustomDateData.value = true;
                            fromDateToDateSetter();
                            fetchTradeHistory();
                            fromFocus.unfocus();
                            toFocus.unfocus();
                          } else {}
                        },
                        child: validDate.value && fetchchedCustomDateData.value
                            ? AppImages.crossButton(
                                context,
                              )
                            : validDate.value
                                ? AppImages.tickEnable(
                                    context,
                                    color: Theme.of(context)
                                        .primaryIconTheme
                                        .color,
                                    isColor: true,
                                  )
                                : AppImages.tickDisable(context,
                                    color: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .color,
                                    isColor: true),
                      );
                    });
              }),
        ],
      ),
    );
  }

  final ValueNotifier<bool> validDate = ValueNotifier<bool>(false);
  final ValueNotifier<bool> fetchchedCustomDateData =
      ValueNotifier<bool>(false);
  void fromDateToDateSetter({bool clear = false}) {
    if (clear) {
      _fromController.text = "";
      _toController.text = "";
    }
    fromDate = (clear || _fromController.text == "")
        ? null
        : DateFormat('dd/MM/yyyy').parse(_fromController.text);
    toDate = (clear || _toController.text == "")
        ? null
        : DateFormat('dd/MM/yyyy').parse(_toController.text);
  }

  Future<String> _displayDatePickerWidget(BuildContext context) async {
    final DateTime? selectedDateOfBirth = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1920, 1),
      lastDate: DateTime.now(),
      helpText: "",
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: MaterialColor(AppColors().positiveColor.value,
                  AppColors.calendarPrimaryColorSwatch),
            ),
            textTheme: TextTheme(
              labelSmall: TextStyle(fontSize: AppWidgetSize.fontSize16),
            ),
          ),
          child: child!,
        );
      },
    );
    return selectedDateOfBirth == null
        ? ""
        : DateFormat('dd/MM/yyyy').format(selectedDateOfBirth);
  }

  List<bool>? isExpanded;
  BlocBuilder<TradehistoryBloc, TradeHistoryState> bodyListview() {
    return BlocBuilder<TradehistoryBloc, TradeHistoryState>(
        buildWhen: (previous, current) =>
            current is TradeHistoryFetchDone ||
            current is TradeHistoryFetchFail ||
            current is TradehistoryLoad,
        builder: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (state.fromDate != null && selectedFilterIndex != 3) {
              _fromController.text =
                  DateFormat('dd/MM/yyyy').format(state.fromDate!);
            }
            if (state.toDate != null && selectedFilterIndex != 3) {
              _toController.text =
                  DateFormat('dd/MM/yyyy').format(state.toDate!);
            }
          });
          if (state is TradeHistoryFetchDone) {
            if (isExpanded == null ||
                state.tradeHistory?.reportList.length != isExpanded?.length) {
              isExpanded = List.generate(
                state.tradeHistory?.reportList.length ?? 0,
                (index) => false,
              );
            }
            if (state.tradeHistory?.reportList.isEmpty ?? true) {
              return failedWidget(
                context,
              );
            } else {
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        primary: false,
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.tradeHistory?.reportList.length ?? 0,
                        padding: EdgeInsets.only(
                          top: AppWidgetSize.dimen_30,
                          bottom: AppWidgetSize.dimen_10,
                        ),
                        itemBuilder: (context, int index) {
                          bool isSameDate = true;
                          final DateTime date =
                              state.tradeHistory!.reportList[index].tradeddate!;

                          if (index == 0) {
                            isSameDate = false;
                          } else {
                            final DateTime prevDate = state.tradeHistory!
                                .reportList[index - 1].tradeddate!;

                            isSameDate = date.isAtSameMomentAs(prevDate);
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index == 0 || !(isSameDate))
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: AppWidgetSize.dimen_15),
                                      child: CustomTextWidget(
                                          DateFormat('dd MMM yyyy')
                                              .format(date),
                                          Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w500)),
                                    ),
                                    Divider(
                                      thickness: AppWidgetSize.dimen_1,
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ],
                                ),
                              TradeHistoryRowWidget(
                                isExpanded: isExpanded?[index] ?? false,
                                onRowClick: () {
                                  for (int i = 0; i < isExpanded!.length; i++) {
                                    if (i == index) {
                                      isExpanded?[i] =
                                          !(isExpanded?[i] ?? false);
                                    } else {
                                      isExpanded?[i] = false;
                                    }
                                  }
                                  setState(() {});
                                },
                                trades: state.tradeHistory!.reportList[index],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          } else if (state is TradeHistoryFetchFail) {
            if (state.isInvalidException) {
              handleError(state);
            }
            return failedWidget(context, state: state);
          } else {
            return const Expanded(child: LoaderWidget());
          }
        });
  }

  failedWidget(BuildContext context, {TradeHistoryFetchFail? state}) {
    return ValueListenableBuilder<bool>(
        valueListenable: validDate,
        builder: (context, value, s) {
          return ValueListenableBuilder<bool>(
              valueListenable: fetchchedCustomDateData,
              builder: (context, value, s) {
                return (selectedFilterIndex == 3 &&
                        (!validDate.value || !fetchchedCustomDateData.value))
                    ? Expanded(
                        child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomTextWidget(
                                "Choose custom Date Range",
                                Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500)),
                            Padding(
                                padding: EdgeInsets.only(
                                    top: AppWidgetSize.dimen_15),
                                child: CustomTextWidget(
                                    "Pick the date Range as you wish to check trade History",
                                    Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                            fontSize: AppWidgetSize.fontSize16,
                                            fontWeight: FontWeight.w500))),
                          ],
                        ),
                      ))
                    : Expanded(
                        child: errorWithImageWidget(
                          context: context,
                          height: AppWidgetSize.dimen_250,
                          imageWidget:
                              AppUtils().getNoDateImageErrorWidget(context),
                          errorMessage: state?.errorMsg ??
                              AppLocalizations().noDataAvailableErrorMessage,
                          childErrorMsg: "",
                          padding: EdgeInsets.only(
                            left: AppWidgetSize.dimen_30,
                            right: AppWidgetSize.dimen_30,
                            bottom: AppWidgetSize.dimen_30,
                          ),
                        ),
                      );
              });
        });
  }

  Padding topFilterWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
      ),
      child: CircularButtonToggleWidget(
        value: gettradeHistoryFilter()[selectedFilterIndex],
        toggleButtonlist:
            gettradeHistoryFilter().map((s) => s as dynamic).toList(),
        toggleButtonOnChanged: toggleButtonOnChanged,
        toggleChanged: (value) {
          setState(() {
            selectedFilterIndex = value;
          });
          if (selectedFilterIndex == 0) {
            fromDate = DateTime.now().subtract(const Duration(days: 7));
            toDate = DateTime.now();
          } else if (selectedFilterIndex == 1) {
            fromDate = DateTime.now().subtract(const Duration(days: 30));
            toDate = DateTime.now();
          } else if (selectedFilterIndex == 2) {
            fromDate = DateTime.now().subtract(const Duration(days: 90));
            toDate = DateTime.now();
          } else if (selectedFilterIndex == 3) {
            fromDate = null;
            toDate = null;
            _fromController.clear();
            _toController.clear();
            fromFocus.requestFocus();
          }
          _searchController.clear();
          selectedFilters = getFilterModel();
          _searchNotifier.changeSearchBar(false);

          if (selectedFilterIndex != 3) {
            fetchTradeHistory();
          } else {
            fromDateToDateSetter(clear: true);
            fetchTradeHistory();
            validDate.value = false;
            fetchchedCustomDateData.value = true;
            fromFocus.requestFocus();
          }
          isValidDate();

          fetchchedCustomDateData.value = true;
        },
        key: const Key(filters_),
        defaultSelected: '',
        enabledButtonlist: const [],
        inactiveButtonColor: Colors.transparent,
        activeButtonColor: AppUtils().isLightTheme()
            ? Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.5)
            : Theme.of(context).primaryColor,
        inactiveTextColor: Theme.of(context).primaryColor,
        activeTextColor: AppUtils().isLightTheme()
            ? Theme.of(context).primaryColor
            : Theme.of(context).primaryColorLight,
        isBorder: false,
        context: context,
        borderColor: Colors.transparent,
        paddingEdgeInsets: EdgeInsets.fromLTRB(
          AppWidgetSize.dimen_12,
          AppWidgetSize.dimen_3,
          AppWidgetSize.dimen_12,
          AppWidgetSize.dimen_3,
        ),
      ),
    );
  }

  SortModel selectedSort = SortModel();
  List<FilterModel> selectedFilters = <FilterModel>[];

  Future<void> sortSheet() async {
    showInfoBottomsheet(StatefulBuilder(
        builder: (BuildContext context, StateSetter updateState) {
      return SortFilterWidget(
        screenName: ScreenRoutes.tradeHistory,
        onDoneCallBack: (s, f) {
          onDoneCallBack(s, f);
          updateState(() {});
        },
        onClearCallBack: () {
          onClearCallBack();
          updateState(() {});
        },
        selectedSort: selectedSort,
        isShowSort: false,
        selectedFilters: selectedFilters,
      );
    }), horizontalMargin: false);
  }

  List<FilterModel> getFilterModel() {
    return [
      FilterModel(
        filterName: AppConstants.action,
        filters: [],
        filtersList: [],
      ),
      FilterModel(
        filterName: AppConstants.segment,
        filters: [],
        filtersList: [],
      ),
      // FilterModel(
      //   filterName: AppConstants.instrumentSegment,
      //   filters: [],
      //   filtersList: [],
      // ),
    ];
  }

  void onDoneCallBack(
    SortModel selectedSortModel,
    List<FilterModel> filterList,
  ) {
    setState(() {
      selectedFilters = filterList;
    });
    selectedSort = SortModel();
    fetchTradeHistory();
  }

  void onClearCallBack() {
    setState(() {
      selectedFilters = getFilterModel();
    });
    selectedSort = SortModel();
    fetchTradeHistory();
  }

  Future<void> fetchTradeHistory(
      {bool fetchApi = true, bool clearData = false}) async {
    if (clearData) {
      BlocProvider.of<TradehistoryBloc>(context).add(TradeHistoryClear());
    } else {
      BlocProvider.of<TradehistoryBloc>(context).add(TradeHistoryFetch(
          fromDate, toDate, selectedFilters, _searchController.text,
          fetchApi: fetchApi, clearData: clearData));
    }
  }

  Widget _buildFilter(BuildContext context) {
    return InkWell(
        onTap: () {
          sortSheet();
        },
        child: Padding(
            padding: EdgeInsets.only(
              right: AppWidgetSize.dimen_5,
            ),
            child: AppUtils().buildFilterIcon(context,
                isSelected: selectedFilters
                    .where((element) => element.filters?.isNotEmpty ?? false)
                    .toList()
                    .isNotEmpty)));
  }

  topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        backIconButton(
          onTap: () {
            popNavigation();
          },
        ),
        Padding(
          padding: EdgeInsets.only(left: AppWidgetSize.dimen_15),
          child: CustomTextWidget(AppLocalizations().tradeHistory,
              Theme.of(context).textTheme.headlineSmall),
        )
      ],
    );
  }
}

class StackImageIconButton extends StatelessWidget {
  final SvgPicture image;
  final bool isActive;
  const StackImageIconButton({
    required this.image,
    this.isActive = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(AppWidgetSize.dimen_20),
      decoration: BoxDecoration(
          border: Border.all(
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_10)),
      child: Stack(
        children: [
          Positioned(
            right: AppWidgetSize.dimen_1,
            top: AppWidgetSize.dimen_1,
            height: AppWidgetSize.dimen_10,
            child: isActive
                ? AppImages.readyInvest(context)
                : AppImages.checkDisable(context),
          ),
          Padding(
            padding: EdgeInsets.all(AppWidgetSize.dimen_10),
            child: image,
          ),
        ],
      ),
    );
  }
}
