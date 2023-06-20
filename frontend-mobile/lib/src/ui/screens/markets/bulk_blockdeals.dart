import 'package:acml/src/constants/app_constants.dart';
import 'package:acml/src/models/common/symbols_model.dart';
import 'package:acml/src/ui/screens/base/base_screen.dart';
import 'package:acml/src/ui/styles/app_color.dart';
import 'package:acml/src/ui/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/quote/deals/deals_bloc.dart';
import '../../../constants/keys/watchlist_keys.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/quote/quote_deals_block/quote_block_deals_model.dart';
import '../../../models/quote/quote_deals_bulk/quote_deals_bulk_model.dart';
import '../../../models/sort_filter/sort_filter_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/circular_colored_label.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/fandotag.dart';
import '../../widgets/sort_filter_widget.dart';
import '../../widgets/technicalspivotstrategychart/toggle_circular_tabborder_widget.dart';
import '../../widgets/toggle_circular_widget.dart';

class MarketsBulkAndBlockDealsArgs {
  final bool isFullScreen;

  final bool isBlock;
  final bool isNse;
  final Function(int)? onToggle;
  final Function(int)? onSegmentToggle;
  MarketsBulkAndBlockDealsArgs(
      {this.isFullScreen = false,
      this.isBlock = true,
      this.isNse = true,
      this.onToggle,
      this.onSegmentToggle});
}

class MarketsBulkandBlock extends BaseScreen {
  final MarketsBulkAndBlockDealsArgs arguments;

  const MarketsBulkandBlock(this.arguments, {Key? key}) : super(key: key);

  @override
  State<MarketsBulkandBlock> createState() => _MarketsBulkandBlockState();
}

class _MarketsBulkandBlockState extends BaseAuthScreenState<MarketsBulkandBlock>
    with TickerProviderStateMixin {
  late QuotesDealsBloc _quotesDealsBloc;

  late AppLocalizations _appLocalizations;
  bool toggleBlockDeals = true;
  bool toggleBulkDeals = false;
  late QuoteBlockDealsModel _quoteBlockDealsModel;
  late QuotesBulkDealsModel _quotesBulkDealsModel;
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  bool onfirstScroll = true;
  final ValueNotifier<int> intialIndex = ValueNotifier<int>(0);
  ValueNotifier<bool> isNse = ValueNotifier<bool>(true);
  @override
  void initState() {
    toggleBlockDeals = widget.arguments.isBlock;
    toggleBulkDeals = !widget.arguments.isBlock;
    intialIndex.value = widget.arguments.isBlock ? 0 : 1;
    isNse.value = widget.arguments.isNse;

    _quotesDealsBloc = BlocProvider.of<QuotesDealsBloc>(context)
      ..add(
          (toggleBlockDeals ? QuoteToggleBlockEvent() : QuoteToggleBulkEvent()))
      ..stream.listen(_quoteDealsListener);
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.quoteDeals);

    tabController =
        TabController(length: 2, initialIndex: intialIndex.value, vsync: this);
    tabController?.addListener(() {
      selectedIndex.value = tabController?.index ?? 0;
      onfirstScroll = true;
    });
    super.initState();
  }

  Future<void> _quoteDealsListener(DealsState state) async {
    if (state is DealsProgressState) {}
    if (state is DealsBlockDoneState) {
    } else if (state is DealsBulkDoneState) {
    } else if (state is DealsFailedState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state is DealsErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return widget.arguments.isFullScreen
        ? Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
                child: Scaffold(
              appBar: AppBar(
                centerTitle: false,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0.0,
                automaticallyImplyLeading: false,
                title: Padding(
                  padding: EdgeInsets.only(
                    left: 10.w,
                    right: 10.w,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          backIconButton(),
                          Padding(
                            padding: EdgeInsets.only(left: 10.w),
                            child: CustomTextWidget(
                              "Deals",
                              Theme.of(context).primaryTextTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                      _buildFilterIcon()
                    ],
                  ),
                ),
              ),
              body: buildBody(),
            )),
          )
        : Container(
            constraints: BoxConstraints(maxHeight: 480.w),
            child: buildBody(),
          );
  }

  bool sortClearClicked = false;
  late StateSetter sortStateSetter;
  void onDoneCallBack(
    SortModel selectedSortModel,
  ) {
    setState(() {});
    selectedSort = selectedSortModel;
    if (toggleBlockDeals) {
      _quotesDealsBloc.add((QuoteToggleBlockEvent()));
    } else {
      _quotesDealsBloc.add((QuoteToggleBulkEvent()));
    }
  }

  SortModel selectedSort = SortModel();

  void onClearCallBack() {
    sortClearClicked = true;
    // selectedFilters = getFilterModel();
    setState(() {});
    sortClearClicked = true;
    selectedSort = SortModel();
    if (toggleBlockDeals) {
      _quotesDealsBloc.add((QuoteToggleBlockEvent()));
    } else {
      _quotesDealsBloc.add((QuoteToggleBulkEvent()));
    }
  }

  Widget _buildFilterIcon() {
    return Opacity(
      opacity: 1,
      child: InkWell(
          onTap: () {
            sortSheet();
          },
          child: AppUtils().buildFilterIcon(context,
              isSelected: selectedSort.sortName != null &&
                  selectedSort.sortName!.isNotEmpty)),
    );
  }

  Future<void> sortSheet() async {
    sortClearClicked = false;
    showInfoBottomsheet(StatefulBuilder(
      builder: (BuildContext context, StateSetter updateState) {
        sortStateSetter = updateState;
        return SortFilterWidget(
          onCloseClickAction: false,
          screenName: ScreenRoutes.marketsBulkandBlockDeal,
          onDoneCallBack: (s, f) {
            onDoneCallBack(
              s,
            );
            updateState(() {});
          },
          onClearCallBack: () {
            onClearCallBack();
            updateState(() {});
          },
          selectedSort: selectedSort,
          selectedFilters: const [],
          isShowFilter: false,
        );
      },
    ), horizontalMargin: false);
  }

  Column buildBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildQuoteDealsToggleWidget(),
        Padding(
            padding: EdgeInsets.only(top: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                buildToggle(),
              ],
            )),
        Expanded(
          child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                buildQuotesBlockBulkToggleBlocBuilder(),
                buildQuotesBlockBulkToggleBlocBuilder()
              ]),
        )
      ],
    );
  }

  TabController? tabController;
  Widget _buildQuoteDealsToggleWidget() {
    return ValueListenableBuilder<int>(
        valueListenable: intialIndex,
        builder: (context, snapshot, _) {
          return Padding(
            padding: EdgeInsets.only(
              top:
                  widget.arguments.isFullScreen ? 10.w : AppWidgetSize.dimen_25,
            ),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_25),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: AppWidgetSize.dimen_1,
                ),
                borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppWidgetSize.dimen_2),
                child: ToggleCircularTabMWidget(
                  tabController: tabController!,
                  key: const Key(''),
                  height: AppWidgetSize.dimen_36,
                  minWidth: AppWidgetSize.dimen_150,
                  cornerRadius: AppWidgetSize.dimen_20,
                  labels: <String>[
                    _appLocalizations.blocDeals,
                    _appLocalizations.bulkDeals
                  ],
                  initialLabel: intialIndex.value,
                  onToggle: (int selectedTabValue) {
                    intialIndex.value = selectedTabValue;
                    if (selectedTabValue == 0) {
                      toggleBlockDeals = true;
                      toggleBulkDeals = false;
                      _quotesDealsBloc.add((QuoteToggleBlockEvent()));
                    } else {
                      toggleBulkDeals = true;
                      toggleBlockDeals = false;
                      _quotesDealsBloc.add((QuoteToggleBulkEvent()));
                    }

                    tabController?.animateTo(selectedTabValue);
                    if (widget.arguments.onToggle != null) {
                      widget.arguments.onToggle!(selectedTabValue);
                    }
                  },
                ),
              ),
            ),
          );
        });
  }

  BlocBuilder<QuotesDealsBloc, DealsState>
      buildQuotesBlockBulkToggleBlocBuilder() {
    return BlocBuilder<QuotesDealsBloc, DealsState>(
      bloc: _quotesDealsBloc,
      builder: (context, state) {
        if (state is DealsProgressState) {
          return const LoaderWidget();
        }
        if (state is DealsBlockToggleState) {
          _quotesDealsBloc.add(MarketsBlockEvent(
              isNse.value ? AppConstants.nse : AppConstants.bse, selectedSort));
        } else if (state is DealsBulkToggleState) {
          _quotesDealsBloc.add(MarketsBulkEvent(
              isNse.value ? AppConstants.nse : AppConstants.bse, selectedSort));
        } else if (state is DealsBlockDoneState) {
          _quoteBlockDealsModel = state.quoteBlockDealsModel;
          return _buildQuotesDealsListView(_quoteBlockDealsModel.blockDeals);
        } else if (state is DealsBulkDoneState) {
          _quotesBulkDealsModel = state.quotesBulkDealsModel;
          if (_quotesBulkDealsModel.bulkDeals != null) {
            return _buildQuotesDealsListView(_quotesBulkDealsModel.bulkDeals);
          }
        }
        if (state is DealsFailedState) {
          return errorWithImageWidget(
            context: context,
            imageWidget: AppImages.noDealsImage(context),
            errorMessage: AppLocalizations().noDealsDataAvailableErrorMessage,
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
              bottom: AppWidgetSize.dimen_30,
            ),
          );
          //return _buildErrorWidget();
        } else if (state is DealsServiceExceptionState) {
          return errorWithImageWidget(
            context: context,
            imageWidget: AppUtils().getNoDateImageErrorWidget(context),
            errorMessage: state.errorMsg,
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
              bottom: AppWidgetSize.dimen_30,
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget buildToggle() {
    return Container(
      // height: AppWidgetSize.fullWidth(context),
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_25,
          right: AppWidgetSize.dimen_25,
          bottom: 5.w,
          top: AppWidgetSize.dimen_8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
              alignment: Alignment.centerRight,
              height: AppWidgetSize.dimen_24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppWidgetSize.dimen_2),
                child: ToggleCircularWidget(
                  key: const Key(nseBseToggleKey),
                  height: AppWidgetSize.dimen_20,
                  minWidth: AppWidgetSize.dimen_40,
                  cornerRadius: AppWidgetSize.dimen_10,
                  activeBgColor:
                      Theme.of(context).primaryTextTheme.displayLarge!.color,
                  activeTextColor: Theme.of(context).colorScheme.secondary,
                  inactiveBgColor: Theme.of(context).scaffoldBackgroundColor,
                  inactiveTextColor:
                      Theme.of(context).primaryTextTheme.displayLarge!.color,
                  labels: const <String>["NSE", "BSE"],
                  initialLabel: isNse.value ? 0 : 1,
                  isBadgeWidget: false,
                  activeTextStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontSize: AppWidgetSize.fontSize12),
                  inactiveTextStyle:
                      Theme.of(context).inputDecorationTheme.labelStyle!,
                  onToggle: (int selectedTabValue) {
                    isNse.value = selectedTabValue == 0;
                    if (toggleBlockDeals) {
                      _quotesDealsBloc.add((QuoteToggleBlockEvent()));
                    } else {
                      _quotesDealsBloc.add((QuoteToggleBulkEvent()));
                    }
                    if (widget.arguments.onSegmentToggle != null) {
                      widget.arguments.onSegmentToggle!(selectedTabValue);
                    }
                  },
                ),
              )),
        ],
      ),
    );
  }

  _buildQuotesDealsListView(var quoteDeals) {
    return Container(
      padding: widget.arguments.isFullScreen
          ? EdgeInsets.zero
          : const EdgeInsets.only(top: 20.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: widget.arguments.isFullScreen
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, dynamic index) {
          return Container(
            height: 122.w,
            padding: const EdgeInsets.only(left: 25.0, right: 25, top: 0),
            child: Column(
              children: [
                _buildBlockRows(quoteDeals![index]),
                // if (index == (quoteDeals!.length - 1)) dealsDisclaimer(context)
              ],
            ),
          );
        },
        itemCount: widget.arguments.isFullScreen
            ? quoteDeals.length
            : quoteDeals!.take(3).length,
      ),
    );
  }

  Column dealsDisclaimer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(
          AppLocalizations().disclaimer,
          Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.w600, fontSize: AppWidgetSize.fontSize12),
        ),
        Padding(
          padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
          child: CustomTextWidget(
              AppLocalizations().disclaimerContent,
              Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: AppWidgetSize.fontSize11)),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_7, bottom: AppWidgetSize.dimen_5),
          child: CustomTextWidget(
              AppLocalizations().cmotsData,
              Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: AppWidgetSize.fontSize11)),
        )
      ],
    );
  }

  Widget _buildBlockRows(var quoteDeals) {
    return InkWell(
      onTap: () async {
        await pushNavigation(
          ScreenRoutes.quoteScreen,
          arguments: {
            'symbolItem': Symbols.fromJson(quoteDeals.toJson()),
          },
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_10,
              bottom: AppWidgetSize.dimen_10,
              left: AppWidgetSize.dimen_5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: AppWidgetSize.dimen_6,
                      ),
                      child: Text(
                        (quoteDeals.sym?.optionType != null)
                            ? '${quoteDeals.baseSym} '
                            : AppUtils().dataNullCheck(quoteDeals.dispSym),
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    FandOTag(Symbols.fromJson(quoteDeals.toJson())),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Qty",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .bodySmall!
                          .copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.w),
                      child: Text(
                        quoteDeals.qtyShares.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: AppWidgetSize.dimen_10,
              left: AppWidgetSize.dimen_5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: AppWidgetSize.screenWidth(context) * 0.55),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          AppUtils().dataNullCheck(quoteDeals.clientNme),
                          style: Theme.of(context)
                              .primaryTextTheme
                              .bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Avg. Price",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .bodySmall!
                          .copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.w),
                      child: Text(
                        quoteDeals.avgPrce.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircularLabelWidget(
                        itemName: quoteDeals.buySell,
                        isError: quoteDeals.buySell != 'Purchase'),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "% Traded",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .bodySmall!
                          .copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.w),
                      child: Text(
                        quoteDeals.percentTraded.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildDivider(),
          //_buildErrorWidget(),
        ],
      ),
    );
  }

  TextStyle purchaseSellStyle(quoteDeals) {
    return quoteDeals.buySell == 'Purchase'
        ? Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500, color: AppColors().positiveColor)
        : Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500, color: AppColors.negativeColor);
  }

  TableCell buildTableCellWithBackgroundColor(
    String key,
    String value, {
    bool isMiddle = false,
  }) {
    return TableCell(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: AppWidgetSize.dimen_1,
          left: isMiddle ? AppWidgetSize.dimen_10 : 0,
          right: isMiddle ? AppWidgetSize.dimen_10 : 0,
          top: AppWidgetSize.dimen_1,
        ),
        child: Container(
          padding: EdgeInsets.only(
            bottom: AppWidgetSize.dimen_5,
            top: AppWidgetSize.dimen_5,
          ),
          color: Theme.of(context).colorScheme.background,
          child: Column(
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                key,
                textAlign: TextAlign.center,
                style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
      ),
      child: Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
    );
  }
}
