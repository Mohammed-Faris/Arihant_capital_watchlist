import "dart:ui" as ui;

import 'package:flutter/material.dart';

import '../../../../constants/app_constants.dart';
import '../../../../constants/keys/watchlist_keys.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../../models/watchlist/watchlist_group_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_color.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/fandotag.dart';
import '../../../widgets/onepointerwidget.dart';
import '../../base/base_screen.dart';

// ignore: must_be_immutable
class WatchlistListWidget extends BaseScreen {
  List<Symbols>? symbolList;
  Groups? group;
  bool isShowEditWatchlist;
  Function? onEditWatchlistCallback;
  Function? onRowClicked;
  Function refreshWatchlist;
  List<Symbols>? holdingsList;
  bool disableSwipe;
  bool isFromWatchlistScreen;
  bool isScroll;
  bool isRollOver;
  bool showNSETag;
  int? limit;
  ScrollController? scrollController;
  WatchlistListWidget(
      {Key? key,
      this.symbolList,
      this.isShowEditWatchlist = false,
      this.group,
      this.scrollController,
      this.onEditWatchlistCallback,
      this.holdingsList,
      this.isFromWatchlistScreen = false,
      this.isScroll = true,
      this.limit,
      required this.onRowClicked,
      required this.refreshWatchlist,
      this.disableSwipe = false,
      this.isRollOver = false,
      this.showNSETag = true})
      : super(key: key);

  @override
  WatchlistListWidgetState createState() => WatchlistListWidgetState();
}

class WatchlistListWidgetState
    extends BaseAuthScreenState<WatchlistListWidget> {
  late AppLocalizations _appLocalizations;
  late DismissDirection dismissDirection;
  bool isDirectionSelected = false;
  int holdingsIndex = 0;
  bool isSymbolAvailable = false;

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;

    return OnlyOnePointerRecognizerWidget(
      child: widget.isFromWatchlistScreen && !widget.isShowEditWatchlist
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: buildStockListWidget(),
                ),
              ],
            )
          : widget.isRollOver
              ? buildStockListWidget()
              : SingleChildScrollView(
                  physics: widget.isScroll
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  controller: widget.scrollController,
                  child: Column(
                    children: [
                      buildStockListWidget(),
                      editWatchlistWidget(context),
                    ],
                  ),
                ),
    );
  }

  ListView buildStockListWidget() {
    return ListView.builder(
      physics: widget.isFromWatchlistScreen && !widget.isShowEditWatchlist
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      primary: false,
      shrinkWrap: true,
      cacheExtent: 20,
      controller: widget.scrollController,
      itemCount: widget.limit != null
          ? widget.symbolList?.take(widget.limit ?? 0).length
          : widget.symbolList?.length,
      itemBuilder: (BuildContext ctxt, int index) {
        return _buildSlideRowContent(
          widget.symbolList![index],
          index,
        );
      },
    );
  }

  Widget editWatchlistWidget(BuildContext context) {
    return widget.isShowEditWatchlist
        ? Padding(
            padding: EdgeInsets.only(
              top: 20.w,
              bottom: 20.w,
            ),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  widget.onEditWatchlistCallback!();
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    AppWidgetSize.dimen_25,
                    AppWidgetSize.dimen_10,
                    AppWidgetSize.dimen_25,
                    AppWidgetSize.dimen_10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.w),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).dividerColor,
                        offset: const Offset(0.0, 1.0),
                        blurRadius: AppWidgetSize.dimen_2,
                      ),
                    ],
                  ),
                  child: CustomTextWidget(
                    _appLocalizations.editWatchlist,
                    Theme.of(context).primaryTextTheme.bodySmall,
                  ),
                ),
              ),
            ),
          )
        : Container();
  }

  Widget _buildSlideRowContent(
    Symbols symbolItem,
    int index,
  ) {
    return Dismissible(
      direction: widget.disableSwipe
          ? DismissDirection.none
          : DismissDirection.horizontal,
      background: buildBackGroundTextContainer(
        _appLocalizations.buy,
        AppUtils().isLightTheme()
            ? AppColors.primaryColor
            : AppColors().positiveColor,
        Alignment.centerLeft,
      ),
      secondaryBackground: buildBackGroundTextContainer(
        _appLocalizations.sell,
        AppColors.negativeColor,
        Alignment.centerRight,
      ),
      key: Key(watchlistSymbolRowKey + index.toString()),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Card(
            elevation: 0,
            color: Theme.of(context).scaffoldBackgroundColor,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppWidgetSize.dimen_10)),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 25.w),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 0.5)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: 5.w,
                  bottom: 5.w,
                ),
                child: _buildRowWidget(symbolItem, index),
              ),
            )),
      ),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          dismissDirection = DismissDirection.startToEnd;
          _onCallOrderPad(_appLocalizations.buy, symbolItem);
          return false;
        } else if (direction == DismissDirection.endToStart) {
          dismissDirection = DismissDirection.endToStart;
          _onCallOrderPad(_appLocalizations.sell, symbolItem);
          return false;
        }

        return false;
      },
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.startToEnd) {
        } else if (direction == DismissDirection.endToStart) {}
      },
    );
  }

  Widget buildBackGroundTextContainer(
    String title,
    Color color,
    Alignment alignment,
  ) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.all(AppWidgetSize.dimen_14),
      color: color,
      child: Text(
        title,
        style: Theme.of(context).primaryTextTheme.displaySmall!.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }

  Widget _buildRowWidget(Symbols symbolItem, int index) {
    return GestureDetector(
      onLongPress: () {
        if (widget.isShowEditWatchlist) {
          widget.onEditWatchlistCallback!();
        }
      },
      onTap: () {
        widget.onRowClicked!(symbolItem);
      },
      child: Container(
        padding: EdgeInsets.only(
          top: 10.w,
          bottom: 10.w,
        ),
        child: Container(
          width: AppWidgetSize.screenWidth(context),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppWidgetSize.dimen_10),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Column(
            // columnWidths: const {
            //   0: FlexColumnWidth(9),
            //   1: FlexColumnWidth(4),
            // },
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: symbolItem.sym?.optionType != null
                              ? '${symbolItem.baseSym} '
                              : AppUtils().dataNullCheck(symbolItem.dispSym),
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .copyWith(fontWeight: FontWeight.w600),
                          children: [
                            if (symbolItem.sym?.isWeekly ?? false)
                              WidgetSpan(
                                alignment: ui.PlaceholderAlignment.middle,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      child: AppImages.weeklyBackground(context,
                                          width: 15.w),
                                    ),
                                    CustomTextWidget(
                                      "W",
                                      Theme.of(context)
                                          .primaryTextTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 9.w,
                                            color: Colors.white,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            _buildCorpSymWidgetSpan(symbolItem),
                            if (symbolItem.sym!.exc == AppConstants.bse ||
                                symbolItem.sym!.exc == AppConstants.nse)
                              if (isNseBse(symbolItem.sym!.exc))
                                if (AppUtils().doubleValue(symbolItem.yhigh) !=
                                        0 &&
                                    (AppUtils().doubleValue(symbolItem.ltp) <=
                                            AppUtils()
                                                .doubleValue(symbolItem.ylow) ||
                                        AppUtils()
                                                .doubleValue(symbolItem.ylow) ==
                                            AppUtils()
                                                .doubleValue(symbolItem.low)) &&
                                    AppUtils().doubleValue(symbolItem.ltp) != 0)
                                  _buildWidgetSpan(
                                    AppConstants.fiftyTwoWL,
                                    AppColors.negativeColor,
                                  ),
                            if (isNseBse(symbolItem.sym!.exc))
                              if (AppUtils().doubleValue(symbolItem.yhigh) !=
                                      AppUtils().doubleValue(symbolItem.ylow) &&
                                  AppUtils().doubleValue(symbolItem.ylow) !=
                                      AppUtils().doubleValue(symbolItem.low) &&
                                  AppUtils().doubleValue(symbolItem.yhigh) !=
                                      0 &&
                                  (AppUtils().doubleValue(symbolItem.ltp) >=
                                          AppUtils()
                                              .doubleValue(symbolItem.yhigh) ||
                                      AppUtils()
                                              .doubleValue(symbolItem.yhigh) ==
                                          AppUtils()
                                              .doubleValue(symbolItem.high)) &&
                                  AppUtils().doubleValue(symbolItem.ltp) != 0)
                                _buildWidgetSpan(
                                  AppConstants.fiftyTwoWH,
                                  AppColors().positiveColor,
                                ),
                            if (isHoldingsAvailableInSymbol(symbolItem))
                              _buildHoldingsWidgetSpan(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                        child: _buildCompanyNameWidget(symbolItem, index),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomTextWidget(
                        widget.isRollOver
                            ? AppUtils().dataNullCheck(symbolItem.roPer) + " %"
                            : AppUtils().dataNullCheck(symbolItem.ltp),
                        Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppUtils().setcolorForChange(widget
                                      .isRollOver
                                  ? (AppUtils().dataNullCheck(symbolItem.roPer))
                                  : AppUtils().dataNullCheck(symbolItem.chng)),
                            ),
                        textAlign: TextAlign.end,
                        isShowShimmer: true,
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                        height: AppWidgetSize.dimen_25,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: CustomTextWidget(
                            AppUtils().getChangePercentage(symbolItem),
                            Theme.of(context)
                                .primaryTextTheme
                                .bodySmall!
                                .copyWith(
                                  color: Theme.of(context)
                                      .inputDecorationTheme
                                      .labelStyle!
                                      .color,
                                ),
                            textAlign: TextAlign.end,
                            isShowShimmer: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isNseBse(exc) {
    if (exc == AppConstants.nse || exc == AppConstants.bse) {
      return true;
    }
    return false;
  }

  WidgetSpan _buildWidgetSpan(String title, Color color) {
    return WidgetSpan(
      alignment: ui.PlaceholderAlignment.middle,
      child: Padding(
        padding: EdgeInsets.only(left: AppWidgetSize.dimen_5),
        child: Container(
          padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_3,
            right: AppWidgetSize.dimen_3,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppWidgetSize.dimen_15,
            ),
            color: color,
          ),
          child: Padding(
            padding: EdgeInsets.all(AppWidgetSize.dimen_2),
            child: FittedBox(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 9.w,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  WidgetSpan _buildHoldingsWidgetSpan() {
    return WidgetSpan(
      alignment: ui.PlaceholderAlignment.middle,
      child: SizedBox(
        width: widget.holdingsList![holdingsIndex].qty!.textSize(
                widget.holdingsList![holdingsIndex].qty!,
                Theme.of(context).primaryTextTheme.labelLarge!) +
            AppWidgetSize.dimen_30,
        child: Row(
          children: [
            AppImages.positionsIcon(
              context,
              color: Theme.of(context).primaryIconTheme.color,
              isColor: true,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 3.w,
              ),
              child: CustomTextWidget(
                AppUtils()
                    .dataNullCheck(widget.holdingsList![holdingsIndex].qty),
                Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context)
                        .inputDecorationTheme
                        .labelStyle!
                        .color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  WidgetSpan _buildCorpSymWidgetSpan(Symbols symbol) {
    return WidgetSpan(
      alignment: ui.PlaceholderAlignment.middle,
      child: getCorpSym(symbol),
    );
  }

  Widget getCorpSym(Symbols symbol) {
    return FutureBuilder<bool>(
      future: AppUtils().isSymAvailableInCorpSymList(symbol),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return Padding(
            padding: EdgeInsets.only(
              left: 5.w,
            ),
            child: SizedBox(
              child: AppImages.watchlist_exdividend(
                context,
              ),
            ),
          );
        }
        return const SizedBox(
          width: 0,
          height: 0,
        );
      },
    );
  }

  Widget _buildCompanyNameWidget(Symbols symbolItem, int index) {
    return Row(
      children: [
        if (symbolItem.companyName != null)
          Container(
            constraints: BoxConstraints(
                maxWidth: AppWidgetSize.screenWidth(context) * 0.46),
            child: Padding(
              padding: EdgeInsets.only(
                right: AppWidgetSize.dimen_5,
              ),
              child: Text(
                AppUtils()
                    .dataNullCheck((symbolItem.companyName!.toUpperCase())),
                style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                    fontSize: 12.w,
                    color: Theme.of(context)
                        .inputDecorationTheme
                        .labelStyle!
                        .color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        FandOTag(
          symbolItem,
          showWeekly: false,
        )
      ],
    );
  }

  bool isHoldingsAvailableInSymbol(Symbols symbolItem) {
    bool isHoldingsAvailableInSymbol = false;
    int index = 0;
    if (widget.holdingsList != null) {
      for (Symbols element in widget.holdingsList!) {
        if (element.dispSym == symbolItem.dispSym &&
            isNseBse(symbolItem.sym!.exc)) {
          holdingsIndex = index;
          isHoldingsAvailableInSymbol = true;
        }
        index++;
      }
    }
    return isHoldingsAvailableInSymbol;
  }

  Future<void> _onCallOrderPad(
    String action,
    Symbols symbolItem,
  ) async {
    await pushNavigation(
      ScreenRoutes.orderPadScreen,
      arguments: {
        'action': action,
        'symbolItem': symbolItem,
      },
    );
    widget.refreshWatchlist();
  }
}
