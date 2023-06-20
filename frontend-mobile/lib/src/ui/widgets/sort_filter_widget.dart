import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../constants/keys/watchlist_keys.dart';
import '../../localization/app_localization.dart';
import '../../models/sort_filter/sort_filter_model.dart';
import '../navigation/screen_routes.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import 'circular_toggle_button_widget.dart';
import 'custom_text_widget.dart';
import 'gradient_button_widget.dart';

class SortFilterWidget extends StatefulWidget {
  final String screenName;
  final Function onDoneCallBack;
  final Function onClearCallBack;
  final SortModel selectedSort;
  final List<FilterModel> selectedFilters;
  final bool isShowFilter;
  final bool onCloseClickAction;
  final bool isShowSort;
  final bool mystock;
  const SortFilterWidget({
    Key? key,
    required this.screenName,
    required this.onDoneCallBack,
    required this.onClearCallBack,
    required this.selectedSort,
    required this.selectedFilters,
    this.isShowFilter = true,
    this.mystock = false,
    this.isShowSort = true,
    this.onCloseClickAction = false,
  }) : super(key: key);

  @override
  State<SortFilterWidget> createState() => _SortFilterWidgetState();
}

class _SortFilterWidgetState extends State<SortFilterWidget> {
  late AppLocalizations _appLocalizations;
  Map<String, List<dynamic>> _sortFilterDataMap = {};
  bool isSortTab = true;
  SortModel selectedSort = SortModel();
  List<FilterModel> filterModel = <FilterModel>[];

  @override
  void initState() {
    _sortFilterDataMap = _getSortFilterDataSet();
    selectedSort = widget.selectedSort;
    // filterModel = widget.selectedFilters;
    for (var element in List.from(widget.selectedFilters)) {
      filterModel.add(FilterModel.copyModel(element));
    }
    isSortTab = widget.isShowSort;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return _buildSortSheetWidget();
  }

  Widget _buildSortSheetWidget() {
    return Wrap(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: AppWidgetSize.dimen_1,
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: 20.w,
            left: 30.w,
            right: AppWidgetSize.dimen_25,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CustomTextWidget(
                _appLocalizations.sortAndFilter,
                // Theme.of(context).textTheme.headline2,
                Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: AppWidgetSize.fontSize22),
              ),
              GestureDetector(
                onTap: () {
                  if (widget.onCloseClickAction == true &&
                      !(selectedSort.sortName != null &&
                          selectedSort.sortName!.isNotEmpty)) {
                    widget.onDoneCallBack(selectedSort, filterModel);
                  }
                  Navigator.of(context).pop();
                },
                child: AppImages.closeIcon(
                  context,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true,
                  width: AppWidgetSize.dimen_22,
                  height: AppWidgetSize.dimen_22,
                ),
              ),
            ],
          ),
        ),
        _buildSortContentWidget(),
        _buildPersistentFooterButton(),
      ],
    );
  }

  Widget _buildSelectedDot() {
    return Positioned(
      right: 10.w,
      child: Container(
        width: 5.w,
        height: 5.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.w),
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSortContentWidget() {
    return Container(
      color: Theme.of(context).inputDecorationTheme.fillColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 100.w,
            color: Theme.of(context).scaffoldBackgroundColor,
            width: AppWidgetSize.fullWidth(context) / 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isShowSort)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSortTab = true;
                      });
                    },
                    child: Container(
                      height: 50.w,
                      width: AppWidgetSize.fullWidth(context) / 3,
                      padding: EdgeInsets.only(
                        left: 30.w,
                        top: AppWidgetSize.dimen_15,
                        bottom: AppWidgetSize.dimen_15,
                      ),
                      color: isSortTab
                          ? Theme.of(context).scaffoldBackgroundColor
                          : Theme.of(context).inputDecorationTheme.fillColor,
                      child: Stack(children: [
                        CustomTextWidget(
                          AppConstants.sortby,
                          Theme.of(context)
                              .primaryTextTheme
                              .bodySmall!
                              .copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: AppWidgetSize.fontSize16),
                        ),
                        if (widget.selectedSort.sortName != null)
                          _buildSelectedDot()
                      ]),
                    ),
                  ),
                if (widget.isShowFilter)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSortTab = false;
                      });
                    },
                    child: Container(
                      height: 50.w,
                      width: AppWidgetSize.fullWidth(context) / 3,
                      padding: EdgeInsets.only(
                        left: 30.w,
                        top: AppWidgetSize.dimen_15,
                        bottom: AppWidgetSize.dimen_15,
                      ),
                      color: isSortTab
                          ? Theme.of(context).inputDecorationTheme.fillColor
                          : Theme.of(context).scaffoldBackgroundColor,
                      child: Stack(
                        children: [
                          CustomTextWidget(
                            AppConstants.filter,
                            Theme.of(context)
                                .primaryTextTheme
                                .bodySmall!
                                .copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: AppWidgetSize.fontSize16),
                          ),
                          if (widget.selectedFilters
                              .where((element) =>
                                  element.filters?.isNotEmpty ?? false)
                              .toList()
                              .isNotEmpty)
                            _buildSelectedDot()
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          isSortTab
              ? Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: _buildSortListView())
              : Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: _buildFilterView()),
        ],
      ),
    );
  }

  Widget _buildPersistentFooterButton() {
    return Container(
      width: AppWidgetSize.fullWidth(context),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: AppWidgetSize.dimen_1,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: 20.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          gradientButtonWidget(
            onTap: () {
              widget.onClearCallBack();
              setState(() {
                isSortTab = widget.isShowSort;
              });
              selectedSort = SortModel();

              filterModel = getFilterModel();
            },
            width: AppWidgetSize.fullWidth(context) / 2.5,
            key: const Key(watchlistSortClearButtonKey),
            context: context,
            title: _appLocalizations.clear,
            isGradient: false,
            isErrorButton: true,
            bottom: 20,
          ),
          gradientButtonWidget(
            onTap: () {
              widget.onDoneCallBack(selectedSort, filterModel);
              setState(() {
                isSortTab = true;
              });

              Navigator.of(context).pop();
            },
            width: AppWidgetSize.fullWidth(context) / 2.5,
            key: const Key(watchlistSortDoneButtonKey),
            context: context,
            title: _appLocalizations.done,
            isGradient: true,
            bottom: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSortListView() {
    return SizedBox(
      height: (_sortFilterDataMap[AppConstants.sortby]?.length ?? 0) *
          AppWidgetSize.dimen_50,
      width: AppWidgetSize.screenWidth(context) * 0.7,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        primary: false,
        shrinkWrap: true,
        itemCount: _sortFilterDataMap[AppConstants.sortby]?.length ?? 0,
        itemBuilder: (BuildContext ctxt, int index) {
          return Container(
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_20,
              right: 20.w,
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Container(
              padding: EdgeInsets.only(
                top: 10.w,
                bottom: 10.w,
              ),
              decoration: BoxDecoration(
                  border: index !=
                          (_sortFilterDataMap[AppConstants.sortby]?.length ??
                                  0) -
                              1
                      ? Border(
                          bottom: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1))
                      : null),
              child: _buildSortRowWidget(
                _sortFilterDataMap[AppConstants.sortby]!.elementAt(index),
                index,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortRowWidget(
    SortModel sortData,
    int index,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_4,
        bottom: AppWidgetSize.dimen_4,
      ),
      child: Table(children: [
        TableRow(
          children: [
            CustomTextWidget(
              sortData.sortName!,
              Theme.of(context)
                  .primaryTextTheme
                  .bodySmall!
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    selectedSort = SortModel(
                      sortName: sortData.sortName,
                      sortType: Sort.ASCENDING,
                    );
                    setState(() {});
                  },
                  child: _getSortIcons(
                    sortData,
                    true,
                  ),
                ),
                SizedBox(
                  width: AppWidgetSize.dimen_10,
                ),
                GestureDetector(
                  onTap: () {
                    selectedSort = SortModel(
                      sortName: sortData.sortName,
                      sortType: Sort.DESCENDING,
                    );
                    setState(() {});
                  },
                  child: _getSortIcons(
                    sortData,
                    false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ]),
    );
  }

  Widget _getSortIcons(
    SortModel sortData,
    bool isAsc,
  ) {
    late String sortIcon;
    if (sortData.sortName == AppConstants.alphabetically) {
      sortIcon =
          isAsc ? AppConstants.alphabeticalAtoZ : AppConstants.alphabeticalZtoA;
    } else if (sortData.sortName == AppConstants.time) {
      sortIcon = isAsc ? AppConstants.latest : AppConstants.earliest;
    } else {
      sortIcon = isAsc ? AppConstants.hToL : AppConstants.lToH;
    }

    late Color color;
    if (selectedSort.sortName != null &&
        selectedSort.sortName == sortData.sortName) {
      if (isAsc) {
        color = selectedSort.sortType == Sort.ASCENDING
            ? Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.5)
            : Theme.of(context).scaffoldBackgroundColor;
      } else {
        color = selectedSort.sortType == Sort.DESCENDING
            ? Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.5)
            : Theme.of(context).scaffoldBackgroundColor;
      }
    } else {
      color = Theme.of(context).scaffoldBackgroundColor;
    }

    return Container(
      padding: EdgeInsets.only(
        top: 2.w,
        bottom: 2.w,
        left: AppWidgetSize.dimen_7,
        right: AppWidgetSize.dimen_7,
      ),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppWidgetSize.dimen_10,
        ),
        color: color,
      ),
      child: (sortIcon == AppConstants.hToL)
          ? AppImages.htol(context, height: 18.w)
          : (sortIcon == AppConstants.lToH)
              ? AppImages.ltoh(context, height: 18.w)
              : (sortIcon == AppConstants.alphabeticalAtoZ)
                  ? AppImages.atoz(context, height: 18.w)
                  : (sortIcon == AppConstants.alphabeticalZtoA)
                      ? AppImages.ztoa(context, height: 18.w)
                      : CustomTextWidget(
                          sortIcon,
                          Theme.of(context)
                              .primaryTextTheme
                              .titleLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.w500, fontSize: 14.w)),
    );
  }

  Widget _buildFilterView() {
    return Container(
      width: AppWidgetSize.screenWidth(context) * 0.7,
      constraints: BoxConstraints(
          minHeight: 100.w,
          maxHeight: AppWidgetSize.screenHeight(context) * 0.75 -
              AppWidgetSize.dimen_200),
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_20,
        bottom: 20.w,
      ),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        primary: false,
        shrinkWrap: true,
        itemCount: _sortFilterDataMap[AppConstants.filterOptions]!.length,
        itemBuilder: (context, index) => _buildFilterRowWidget(index),
      ),
    );
  }

  Widget _buildFilterRowWidget(
    int index,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderWidget(
          _sortFilterDataMap[AppConstants.filterOptions]!.elementAt(index),
        ),
        _buildFilterToggleList(
          context,
          _sortFilterDataMap[AppConstants.filter]!.elementAt(index)[
              _sortFilterDataMap[AppConstants.filterOptions]!.elementAt(index)],
          index,
        ),
      ],
    );
  }

  Widget _buildHeaderWidget(
    String header,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20.w,
      ),
      child: CustomTextWidget(
        header,
        Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildFilterToggleList(
    BuildContext context,
    List<String> filterLabel,
    int index,
  ) {
    return SizedBox(
      width: AppWidgetSize.fullWidth(context) / 1.6,
      child: CircularButtonToggleWidget(
        value: '',
        toggleButtonlist: filterLabel,
        superScript: widget.screenName == ScreenRoutes.watchlistScreen
            ? [
                filterLabel[0] == AppConstants.nse ? "EQ" : "",
                filterLabel[1] == AppConstants.bse ? "EQ" : ""
              ]
            : null,
        toggleButtonOnChanged: (data) {
          toggleButtonChanged(
            data,
            index,
          );
        },
        activeButtonColor:
            Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.5),
        activeTextColor: Theme.of(context).primaryColor,
        inactiveButtonColor: Colors.transparent,
        inactiveTextColor: Theme.of(context).primaryTextTheme.bodySmall!.color!,
        key: const Key('quoteCorporateActionFilterKey'),
        defaultSelected: '',
        enabledButtonlist: const [],
        selectedButtons: filterModel[index].filters,
        isBorder: false,
        borderColor: Colors.transparent,
        context: context,
        fontSize: AppWidgetSize.fontSize12.w,
        paddingEdgeInsets: EdgeInsets.only(
          top: 3.w,
          left: 5.w,
          right: AppWidgetSize.dimen_5,
          bottom: 3.w,
        ),
      ),
    );
  }

  void toggleButtonChanged(
    String data,
    int index,
  ) {
    if (_sortFilterDataMap[AppConstants.filterOptions]!.elementAt(index) ==
        filterModel[index].filterName) {
      if (filterModel[index].filters != null &&
          filterModel[index].filters!.contains(data)) {
        int i = 0;
        for (Filters element in List.from(filterModel[index].filtersList!)) {
          if (element.key == data) {
            filterModel[index].filtersList!.removeAt(i);
          }
          i++;
        }

        filterModel[index].filters!.remove(data);
      } else {
        filterModel[index].filters!.remove(data);

        filterModel[index].filters!.add(data);
        int i = 0;
        for (var element in List.from(
            _sortFilterDataMap[AppConstants.filterKeys]!
                .elementAt(index)[filterModel[index].filterName])) {
          if (element.key.toString().toLowerCase() == data.toLowerCase()) {
            filterModel[index].filtersList!.add(
                _sortFilterDataMap[AppConstants.filterKeys]!
                    .elementAt(index)[filterModel[index].filterName][i]);
          }
          i++;
        }
      }
    }

    setState(() {});
  }

  Map<String, List<dynamic>> _getSortFilterDataSet() {
    if (widget.screenName == ScreenRoutes.holdingsScreen) {
      return <String, List<dynamic>>{
        AppConstants.sortby: <SortModel>[
          SortModel(
            sortName: AppConstants.alphabetically,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.oneDayReturn,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.oneDayReturnPercent,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.overallReturn,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.overallReturnPercent,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.currentValue,
            sortType: Sort.NONE,
          ),
        ],
        AppConstants.filterOptions: <String>[
          AppConstants.segment,
          AppConstants.moreFilters,
        ],
        AppConstants.filter: <Map<String, List<String>>>[
          <String, List<String>>{
            AppConstants.segment: <String>[
              AppConstants.nse,
              AppConstants.bse,
            ],
          },
          <String, List<String>>{
            AppConstants.moreFilters: <String>[
              AppConstants.profitHoldings,
              AppConstants.lossHoldings,
            ],
          },
        ],
        AppConstants.filterKeys: <Map<String, List<Filters>>>[
          <String, List<Filters>>{
            AppConstants.segment: <Filters>[
              Filters(
                key: AppConstants.nse,
                value: AppConstants.nse,
              ),
              Filters(
                key: AppConstants.bse,
                value: AppConstants.bse,
              ),
            ],
          },
          <String, List<Filters>>{
            AppConstants.moreFilters: <Filters>[
              Filters(
                key: AppConstants.profitHoldings,
                value: AppConstants.profit,
              ),
              Filters(
                key: AppConstants.lossHoldings,
                value: AppConstants.loss,
              ),
            ],
          },
        ],
      };
    } else if (widget.screenName == ScreenRoutes.positionScreen) {
      return <String, List<dynamic>>{
        AppConstants.sortby: <SortModel>[
          SortModel(
            sortName: AppConstants.alphabetically,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.returns,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.absoluteChange,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.currentValue,
            sortType: Sort.NONE,
          ),
        ],
        AppConstants.filterOptions: <String>[
          AppConstants.action,
          AppConstants.segment,
          AppConstants.productType,
          AppConstants.moreFilters,
        ],
        AppConstants.filter: <Map<String, List<String>>>[
          <String, List<String>>{
            AppConstants.action: <String>[
              AppConstants.buy,
              AppConstants.sell,
            ],
          },
          <String, List<String>>{
            AppConstants.segment: <String>[
              AppConstants.nse,
              AppConstants.bse,
              AppConstants.fo,
              // AppConstants.bfo,
              AppConstants.mcx,
              AppConstants.cds,
            ],
          },
          <String, List<String>>{
            AppConstants.productType: <String>[
              AppConstants.delivery,
              AppConstants.intraday,
              AppConstants.carryForward,
            ],
          },
          <String, List<String>>{
            AppConstants.moreFilters: <String>[
              AppConstants.profitPositions,
              AppConstants.lossPositions,
            ],
          },
        ],
        AppConstants.filterKeys: <Map<String, List<Filters>>>[
          <String, List<Filters>>{
            AppConstants.action: <Filters>[
              Filters(
                key: AppConstants.buy,
                value: AppConstants.buy.toLowerCase(),
              ),
              Filters(
                key: AppConstants.sell,
                value: AppConstants.sell.toLowerCase(),
              ),
            ],
          },
          <String, List<Filters>>{
            AppConstants.segment: <Filters>[
              Filters(
                key: AppConstants.nse,
                value: AppConstants.nse,
              ),
              Filters(
                key: AppConstants.bse,
                value: AppConstants.bse,
              ),
              Filters(
                key: AppConstants.fo,
                value: AppConstants.fo,
              ),
              // Filters(
              //   key: AppConstants.bfo,
              //   value: AppConstants.bfo,
              // ),
              Filters(
                key: AppConstants.mcx,
                value: AppConstants.mcx,
              ),
              Filters(
                key: AppConstants.cds,
                value: AppConstants.cds,
              ),
            ],
          },
          <String, List<Filters>>{
            AppConstants.productType: <Filters>[
              Filters(
                key: AppConstants.delivery,
                value: AppConstants.delivery,
              ),
              Filters(
                key: AppConstants.intraday,
                value: AppConstants.intraday,
              ),
              Filters(
                key: AppConstants.carryForward,
                value: AppConstants.carryForward,
              ),
            ],
          },
          <String, List<Filters>>{
            AppConstants.moreFilters: <Filters>[
              Filters(
                key: AppConstants.profitPositions,
                value: AppConstants.profit,
              ),
              Filters(
                key: AppConstants.lossPositions,
                value: AppConstants.loss,
              ),
            ],
          },
        ],
      };
    } else if (widget.screenName == ScreenRoutes.tradeHistory) {
      return <String, List<dynamic>>{
        AppConstants.filterOptions: <String>[
          AppConstants.action,
          AppConstants.segment,
          // AppConstants.instrumentSegment,
        ],
        AppConstants.filter: <Map<String, List<String>>>[
          <String, List<String>>{
            AppConstants.action: <String>[
              AppConstants.buy,
              AppConstants.sell,
            ],
          },
          <String, List<String>>{
            AppConstants.segment: <String>[
              AppConstants.nse,
              AppConstants.bse,
              AppConstants.fo,
              // AppConstants.bfo,
              AppConstants.mcx,
              AppConstants.cds,
            ],
          },
          // <String, List<String>>{
          //   AppConstants.instrumentSegment: <String>[
          //     AppConstants.cash,
          //     AppConstants.futureStock,
          //     AppConstants.optionsStock,
          //     AppConstants.futureIndex,
          //     AppConstants.optionsIndex,
          //     AppConstants.futureCurrency,
          //     AppConstants.optionsCurrency,
          //   ],
          // },
        ],
        AppConstants.filterKeys: <Map<String, List<Filters>>>[
          <String, List<Filters>>{
            AppConstants.action: <Filters>[
              Filters(
                key: AppConstants.buy,
                value: AppConstants.buy.toLowerCase(),
              ),
              Filters(
                key: AppConstants.sell,
                value: AppConstants.sell.toLowerCase(),
              ),
            ],
          },
          <String, List<Filters>>{
            AppConstants.segment: <Filters>[
              Filters(
                key: AppConstants.nse,
                value: AppConstants.nse,
              ),
              Filters(
                key: AppConstants.bse,
                value: AppConstants.bse,
              ),
              Filters(
                key: AppConstants.fo,
                value: AppConstants.fo,
              ),
              // Filters(
              //   key: AppConstants.bfo,
              //   value: AppConstants.bfo,
              // ),
              Filters(
                key: AppConstants.mcx,
                value: AppConstants.mcx,
              ),
              Filters(
                key: AppConstants.cds,
                value: AppConstants.cds,
              ),
            ],
          },
          // <String, List<Filters>>{
          //   AppConstants.instrumentSegment: <Filters>[
          //     Filters(
          //       key: AppConstants.cash,
          //       value: AppConstants.stk,
          //     ),
          //     Filters(
          //       key: AppConstants.futureStock,
          //       value: AppConstants.futureStockKey,
          //     ),
          //     Filters(
          //       key: AppConstants.optionsStock,
          //       value: AppConstants.optionsStockKey,
          //     ),
          //     Filters(
          //       key: AppConstants.futureIndex,
          //       value: AppConstants.futureIndexKey,
          //     ),
          //     Filters(
          //       key: AppConstants.optionsIndex,
          //       value: AppConstants.optionsIndexKey,
          //     ),
          //     Filters(
          //       key: AppConstants.futureCurrency,
          //       value: AppConstants.futureCurrencyKey,
          //     ),
          //     Filters(
          //       key: AppConstants.optionsCurrency,
          //       value: AppConstants.optionsCurrencyKey,
          //     ),
          //   ],
          // },
        ]
      };
    } else if (widget.screenName == ScreenRoutes.orderScreen) {
      return <String, List<dynamic>>{
        AppConstants.sortby: <SortModel>[
          SortModel(
            sortName: AppConstants.alphabetically,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.orderValue,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.quantity,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.time,
            sortType: Sort.NONE,
          ),
        ],
        AppConstants.filterOptions: <String>[
          AppConstants.action,
          AppConstants.segment,
          AppConstants.orderStatus,
          AppConstants.instrumentSegment,
          AppConstants.productType,
          AppLocalizations().validity,
          AppConstants.moreFilters,
        ],
        AppConstants.filter: <Map<String, List<String>>>[
          <String, List<String>>{
            AppConstants.action: <String>[
              AppConstants.buy,
              AppConstants.sell,
            ],
          },
          <String, List<String>>{
            AppConstants.segment: <String>[
              AppConstants.nse,
              AppConstants.bse,
              AppConstants.fo,
              // AppConstants.bfo,
              AppConstants.mcx,
              AppConstants.cds,
            ],
          },
          <String, List<String>>{
            AppConstants.orderStatus: <String>[
              AppConstants.executed,
              AppConstants.rejected,
              AppConstants.cancelled,
              AppConstants.pending,
            ],
          },
          <String, List<String>>{
            AppConstants.instrumentSegment: <String>[
              AppConstants.cash,
              AppConstants.futureStock,
              AppConstants.optionsStock,
              AppConstants.futureIndex,
              AppConstants.optionsIndex,
              AppConstants.futureCurrency,
              AppConstants.optionsCurrency,
            ],
          },
          <String, List<String>>{
            AppConstants.productType: <String>[
              AppConstants.delivery,
              AppConstants.intraday,
              AppConstants.carryForward,
              AppConstants.coverOrder,
              AppConstants.bracketOrder,
            ],
          },
          <String, List<String>>{
            AppLocalizations().validity: <String>[
              AppConstants.day,
              AppConstants.ioc,
              AppConstants.gtd,
            ],
          },
          <String, List<String>>{
            AppConstants.moreFilters: <String>[
              AppConstants.market,
              AppConstants.limit,
              AppConstants.sl,
              AppConstants.slM,
              AppConstants.amo,
            ],
          },
        ],
        AppConstants.filterKeys: <Map<String, List<Filters>>>[
          <String, List<Filters>>{
            AppConstants.action: <Filters>[
              Filters(
                key: AppConstants.buy,
                value: AppConstants.buy.toLowerCase(),
              ),
              Filters(
                key: AppConstants.sell,
                value: AppConstants.sell.toLowerCase(),
              ),
            ],
          },
          <String, List<Filters>>{
            AppConstants.segment: <Filters>[
              Filters(
                key: AppConstants.nse,
                value: AppConstants.nse,
              ),
              Filters(
                key: AppConstants.bse,
                value: AppConstants.bse,
              ),
              Filters(
                key: AppConstants.fo,
                value: AppConstants.fo,
              ),
              Filters(
                key: AppConstants.bfo,
                value: AppConstants.bfo,
              ),
              Filters(
                key: AppConstants.mcx,
                value: AppConstants.mcx,
              ),
              Filters(
                key: AppConstants.cds,
                value: AppConstants.cds,
              ),
            ],
          },
          <String, List<Filters>>{
            AppConstants.orderStatus: <Filters>[
              Filters(
                key: AppConstants.executed,
                value: AppConstants.executed.toLowerCase(),
              ),
              Filters(
                key: AppConstants.rejected,
                value: AppConstants.rejected.toLowerCase(),
              ),
              Filters(
                key: AppConstants.cancelled,
                value: AppConstants.cancelled.toLowerCase(),
              ),
              Filters(
                key: AppConstants.pending,
                value: AppConstants.pending.toLowerCase(),
              ),
            ],
          },
          <String, List<Filters>>{
            AppConstants.instrumentSegment: <Filters>[
              Filters(
                key: AppConstants.cash,
                value: AppConstants.stk,
              ),
              Filters(
                key: AppConstants.futureStock,
                value: AppConstants.futureStockKey,
              ),
              Filters(
                key: AppConstants.optionsStock,
                value: AppConstants.optionsStockKey,
              ),
              Filters(
                key: AppConstants.futureIndex,
                value: AppConstants.futureIndexKey,
              ),
              Filters(
                key: AppConstants.optionsIndex,
                value: AppConstants.optionsIndexKey,
              ),
              Filters(
                key: AppConstants.futureCurrency,
                value: AppConstants.futureCurrencyKey,
              ),
              Filters(
                key: AppConstants.optionsCurrency,
                value: AppConstants.optionsCurrencyKey,
              ),
            ],
          },
          <String, List<Filters>>{
            AppConstants.productType: <Filters>[
              Filters(
                key: AppConstants.delivery,
                value: AppConstants.delivery,
              ),
              Filters(
                key: AppConstants.intraday,
                value: AppConstants.intraday,
              ),
              Filters(
                key: AppConstants.carryForward,
                value: AppConstants.carryForward,
              ),
              Filters(
                key: AppConstants.coverOrder,
                value: AppConstants.coverOrder,
              ),
              Filters(
                key: AppConstants.bracketOrder,
                value: AppConstants.bracketOrder,
              ),
            ],
          },
          <String, List<Filters>>{
            AppLocalizations().validity: <Filters>[
              Filters(
                key: AppConstants.day,
                value: AppConstants.day.toLowerCase(),
              ),
              Filters(
                key: AppConstants.ioc,
                value: AppConstants.ioc.toLowerCase(),
              ),
              Filters(
                key: AppConstants.gtd,
                value: AppConstants.gtd.toLowerCase(),
              ),
            ]
          },
          <String, List<Filters>>{
            AppConstants.moreFilters: <Filters>[
              Filters(
                key: AppConstants.market,
                value: AppConstants.market.toLowerCase(),
              ),
              Filters(
                key: AppConstants.limit,
                value: AppConstants.limit.toLowerCase(),
              ),
              Filters(
                key: AppConstants.sl,
                value: AppConstants.sl,
              ),
              Filters(
                key: AppConstants.slM,
                value: AppConstants.slM,
              ),
              Filters(
                key: AppConstants.amo,
                value: AppConstants.amo,
              ),
            ],
          },
        ],
      };
    } else if (widget.screenName == ScreenRoutes.marketsBulkandBlockDeal) {
      return <String, List<dynamic>>{
        AppConstants.sortby: <SortModel>[
          SortModel(
            sortName: AppConstants.alphabetically,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.price,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.tradePercent,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.quantity,
            sortType: Sort.NONE,
          ),
        ],
      };
    } else {
      // watchlist
      return <String, List<dynamic>>{
        AppConstants.sortby: <SortModel>[
          SortModel(
            sortName: AppConstants.alphabetically,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.price,
            sortType: Sort.NONE,
          ),
          SortModel(
            sortName: AppConstants.chngPercent,
            sortType: Sort.NONE,
          ),
        ],
        AppConstants.filterOptions: <String>[
          AppConstants.segment,
        ],
        AppConstants.filter: <Map<String, List<String>>>[
          <String, List<String>>{
            AppConstants.segment: <String>[
              AppConstants.nse,
              AppConstants.bse,
              if (!widget.mystock) AppConstants.future,
              if (!widget.mystock) AppConstants.options,
            ],
          },
        ],
        AppConstants.filterKeys: <Map<String, List<Filters>>>[
          <String, List<Filters>>{
            AppConstants.segment: <Filters>[
              Filters(
                key: AppConstants.nse,
                value: AppConstants.nse,
              ),
              Filters(
                key: AppConstants.bse,
                value: AppConstants.bse,
              ),
              if (!widget.mystock)
                Filters(
                  key: AppConstants.future,
                  value: AppConstants.future,
                ),
              if (!widget.mystock)
                Filters(
                  key: AppConstants.options,
                  value: AppConstants.options,
                ),
            ],
          },
        ],
      };
    }
  }

  List<FilterModel> getFilterModel() {
    if (widget.screenName == ScreenRoutes.holdingsScreen) {
      return [
        FilterModel(
          filterName: AppConstants.segment,
          filters: [],
          filtersList: [],
        ),
        FilterModel(
          filterName: AppConstants.moreFilters,
          filters: [],
          filtersList: [],
        ),
      ];
    } else if (widget.screenName == ScreenRoutes.positionScreen) {
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
        FilterModel(
          filterName: AppConstants.productType,
          filters: [],
          filtersList: [],
        ),
        FilterModel(
          filterName: AppConstants.moreFilters,
          filters: [],
          filtersList: [],
        ),
      ];
    } else if (widget.screenName == ScreenRoutes.orderScreen) {
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
        FilterModel(
          filterName: AppConstants.orderStatus,
          filters: [],
          filtersList: [],
        ),
        FilterModel(
          filterName: AppConstants.instrumentSegment,
          filters: [],
          filtersList: [],
        ),
        FilterModel(
          filterName: AppConstants.productType,
          filters: [],
          filtersList: [],
        ),
        FilterModel(
          filterName: AppLocalizations().validity,
          filters: [],
          filtersList: [],
        ),
        FilterModel(
          filterName: AppConstants.moreFilters,
          filters: [],
          filtersList: [],
        ),
      ];
    } else if (widget.screenName == ScreenRoutes.tradeHistory) {
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
        //   filterName: AppConstants.instrument,
        //   filters: [],
        //   filtersList: [],
        // ),
      ];
    } else {
      return [
        FilterModel(
          filterName: AppConstants.segment,
          filters: [],
          filtersList: [],
        ),
        FilterModel(
          filterName: AppConstants.moreFilters,
          filters: [],
          filtersList: [],
        ),
      ];
    }
  }
}
