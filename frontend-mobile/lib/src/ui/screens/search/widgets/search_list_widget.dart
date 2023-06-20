import 'package:acml/src/ui/screens/alerts/choose_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../blocs/search/search_bloc.dart';
import '../../../../config/app_config.dart';
import '../../../../constants/app_constants.dart';
import '../../../../constants/keys/watchlist_keys.dart';
import '../../../../data/store/app_store.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../../models/watchlist/symbol_watchlist_map_holder_model.dart';
import '../../../../models/watchlist/watchlist_group_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_color.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../validator/input_validator.dart';
import '../../../widgets/choose_watchlist_widget.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/fandotag.dart';
import '../../../widgets/gradient_button_widget.dart';
import '../../acml_app.dart';
import '../../base/base_screen.dart';

class SearchlistListWidget extends BaseScreen {
  final List<Symbols>? symbolList;
  final List<Groups>? groupList;
  final SearchBloc searchBloc;
  final bool isNewWatchlist;
  final String? newWatchlistName;
  final bool isShowRecentHist;
  final List<Widget>? watchlistIcons;
  final bool isScrollable;
  final ScrollController? scrollController;

  final bool fromAlerts;
  final bool fromBasket;
  final Map<String, dynamic>? basketData;

  const SearchlistListWidget(
      {Key? key,
      this.scrollController,
      this.symbolList,
      this.isScrollable = true,
      this.groupList,
      required this.searchBloc,
      this.isNewWatchlist = false,
      this.newWatchlistName,
      required this.isShowRecentHist,
      this.watchlistIcons,
      this.fromAlerts = false,
      this.fromBasket = false,
      this.basketData})
      : super(key: key);

  @override
  SearchlistListWidgetState createState() => SearchlistListWidgetState();
}

class SearchlistListWidgetState
    extends BaseAuthScreenState<SearchlistListWidget> {
  late AppLocalizations _appLocalizations;
  final TextEditingController _newWNameTextController = TextEditingController();
  FocusNode newWNameFocusNode = FocusNode();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (mounted) {
          if (ModalRoute.of(context)?.settings.name.toString() ==
              ScreenRoutes.loginScreen) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (newWNameFocusNode.hasFocus) {
                newWNameFocusNode.unfocus();
                Future.delayed(const Duration(milliseconds: 200), () {
                  newWNameFocusNode.requestFocus();
                });
              }
            });
          }
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return ListView.separated(
      scrollDirection: Axis.vertical,
      padding: widget.isShowRecentHist
          ? EdgeInsets.zero
          : EdgeInsets.only(bottom: 50.h),
      physics: widget.isScrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      controller: widget.scrollController,
      itemCount: widget.symbolList!.length,
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(context).dividerColor,
        thickness: AppWidgetSize.dimen_1,
        indent: AppWidgetSize.dimen_30,
        endIndent: AppWidgetSize.dimen_30,
      ),
      itemBuilder: (BuildContext ctxt, int index) {
        return _buildSymboleRowContent(widget.symbolList![index], index);
      },
    );
  }

  Widget _buildSymboleRowContent(Symbols symbolItem, int index) {
    return GestureDetector(
      onTap: () {
        if (!widget.fromBasket) {
          _onRowClickedCallBack(symbolItem, index);
        } else {
          if (!widget.isShowRecentHist) {
            widget.searchBloc.add(SymbolSearchRowTappedEvent(
              symbolItem,
            ));
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_10),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 30.w,
            right: 30.w,
          ),
          child: _buildRowWidget(symbolItem, index),
        ),
      ),
    );
  }

  Widget _buildRowWidget(Symbols symbolItem, int index) {
    return Container(
      width: AppWidgetSize.fullWidth(context) - AppWidgetSize.dimen_10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppWidgetSize.dimen_10),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      padding: EdgeInsets.only(
        top: 10.w,
        bottom: 10.w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLeftRowWidget(symbolItem, index, widget.isShowRecentHist),
          if (widget.isShowRecentHist &&
              !widget.fromAlerts &&
              !widget.fromBasket)
            Expanded(child: _buildRightRowWidget(symbolItem, index)),
          Padding(
            padding: EdgeInsets.only(
                left: widget.fromBasket ? 0 : AppWidgetSize.dimen_5),
            child: widget.fromBasket
                ? Row(
                    children: [
                      _getBottomButtonWidget(
                          "searchBuyButtonKey",
                          AppConfig.orientation == Orientation.landscape
                              ? "Buy"
                              : "B",
                          AppColors().positiveColor,
                          true,
                          symbolItem),
                      SizedBox(width: AppWidgetSize.dimen_8),
                      _getBottomButtonWidget(
                          "searchSellButtonKey",
                          AppConfig.orientation == Orientation.landscape
                              ? "Sell"
                              : "S",
                          AppColors.negativeColor,
                          false,
                          symbolItem),
                    ],
                  )
                : widget.fromAlerts
                    ? AppImages.addAlert(context)
                    : _buildAddWatchlistIconWidget(symbolItem, index),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftRowWidget(
      Symbols symbolItem, int index, bool isShowRecentHist) {
    int maximumCharacterLength = widget.isShowRecentHist ? 15 : 20;
    return SizedBox(
      width: widget.isShowRecentHist
          ? AppWidgetSize.fullWidth(context) / 2.5
          : AppWidgetSize.fullWidth(context) / 1.8,
      child: FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomTextWidget(
                    (symbolItem.sym?.optionType != null)
                        ? '${symbolItem.baseSym} '
                        : AppUtils().dataNullCheck(symbolItem.dispSym),
                    Theme.of(context)
                        .primaryTextTheme
                        .labelSmall!
                        .copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left),
                AppUtils.weekly(symbolItem, context)
              ],
            ),
            Row(
              children: [
                if (symbolItem.companyName != null && !widget.isShowRecentHist)
                  SizedBox(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 5.w,
                      ),
                      child: Text(
                        symbolItem.sym?.asset == "future" ||
                                symbolItem.sym?.asset == "option"
                            ? ""
                            : AppUtils()
                                        .dataNullCheck(
                                            (symbolItem.companyName!))
                                        .length >
                                    maximumCharacterLength
                                ? AppUtils().dataNullCheck(
                                    (symbolItem.companyName!)
                                        .substring(0, maximumCharacterLength))
                                : AppUtils()
                                    .dataNullCheck((symbolItem.companyName!)),
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(
                                color: Theme.of(context)
                                    .inputDecorationTheme
                                    .labelStyle!
                                    .color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                if (symbolItem.sym?.optionType != null &&
                    !widget.isShowRecentHist)
                  SizedBox(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 5.w,
                      ),
                      child: Text(
                        symbolItem.sym?.asset == "future"
                            ? DateFormat("dd MMM").format(
                                DateFormat('dd-MM-yyyy')
                                    .parse(symbolItem.sym!.expiry!))
                            : '${DateFormat("dd MMM").format(DateFormat('dd-MM-yyyy').parse(symbolItem.sym!.expiry!))} ${!(symbolItem.sym?.strike?.contains(".00") ?? false) ? AppUtils().decimalValue(symbolItem.sym?.strike, decimalPoint: 2) : AppUtils().intValue(symbolItem.sym?.strike)} ${symbolItem.sym?.optionType}',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(
                                color: Theme.of(context)
                                    .inputDecorationTheme
                                    .labelStyle!
                                    .color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                  child: FandOTag(
                    symbolItem,
                    showExpiry: widget.isShowRecentHist,
                    showWeekly: false,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool isWatchlistExist(String watchListName) {
    for (Groups group in widget.groupList!) {
      if (group.wName!.toLowerCase() == watchListName.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  Widget _buildAddWatchlistIconWidget(Symbols symbolItem, int index) {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
      child: GestureDetector(
        onTap: () {
          onAddSymbol(symbolItem, index);
        },
        child: (AppUtils().getsymbolType(symbolItem) == AppConstants.fno &&
                    !AppStore().getFnoAvailability()) ||
                ((AppUtils().getsymbolType(symbolItem) ==
                        AppConstants.currency.toLowerCase()) &&
                    !AppStore().getCurrencyAvailability()) ||
                (AppUtils().getsymbolType(symbolItem) ==
                        AppConstants.commodity.toLowerCase() &&
                    !AppStore().getCommodityAvailability())
            ? Container()
            : (SymbolWatchlistMapHolder().isSymbolIdAvailble(
                      symbolItem.sym?.id ?? "",
                    ) &&
                    !widget.isNewWatchlist)
                ? AppImages.addFilledIcon(context, width: 30.w, height: 30.w)
                : AppImages.addUnfilledIcon(
                    context,
                    color: AppColors().positiveColor,
                    isColor: true,
                    width: 30.w,
                    height: 30.w, //color: Theme.of(context).primaryColor,
                  ),
      ),
    );
  }

  void onAddSymbol(Symbols symbolItem, int index) {
    scaffoldkey.currentState?.clearSnackBars();

    if (!widget.isShowRecentHist) {
      widget.searchBloc.add(SymbolSearchRowTappedEvent(
        symbolItem,
      ));
    }
    if (widget.isNewWatchlist && widget.newWatchlistName != null) {
      if ((widget.groupList!.isNotEmpty &&
              !isWatchlistExist(widget.newWatchlistName!)) ||
          widget.groupList!.isEmpty) {
        widget.searchBloc.add(SearchAddSymbolEvent(
          widget.newWatchlistName!,
          symbolItem,
          true,
        ));
      } else {
        widget.searchBloc.add(SearchAddSymbolEvent(
          widget.newWatchlistName!,
          symbolItem,
          false,
        ));
      }
    } else if (widget.groupList!.isEmpty &&
        widget.isNewWatchlist &&
        !isWatchlistExist(widget.newWatchlistName!)) {
      _showCreateNewBottomSheet(symbolItem);
    } else {
      _showWatchlistGroupBottomSheet(symbolItem);
    }
  }

  void _showWatchlistGroupBottomSheet(Symbols symbolItem) {
    showInfoBottomsheet(
        ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(20.w),
            ),
            child: BlocProvider<SearchBloc>.value(
              value: BlocProvider.of<SearchBloc>(context),
              child: ChooseWatchlistWidget(
                arguments: {
                  'symbolItem': symbolItem,
                  'groupList': widget.groupList,
                  'fromSearchScreen': true
                },
              ),
            )),
        bottomMargin: 0,
        topMargin: false,
        height: (AppUtils().chooseWatchlistHeight(widget.groupList ?? []) <
                (AppWidgetSize.screenHeight(context) * 0.8))
            ? AppUtils().chooseWatchlistHeight(widget.groupList ?? [])
            : (AppWidgetSize.screenHeight(context) * 0.8),
        horizontalMargin: false);
  }

  Widget _buildRightRowWidget(Symbols symbolItem, int index) {
    return SizedBox(
      width: AppWidgetSize.fullWidth(context) / 1.9 - AppWidgetSize.dimen_70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomTextWidget(
            AppUtils().dataNullCheck(symbolItem.ltp),
            Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppUtils().setColorForText(
                      AppUtils().dataNullCheck(symbolItem.chng)),
                ),
            textAlign: TextAlign.end,
            isShowShimmer: true,
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: CustomTextWidget(
              AppUtils().getChangePercentage(symbolItem),
              Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                    color: Theme.of(context)
                        .inputDecorationTheme
                        .labelStyle!
                        .color,
                  ),
              textAlign: TextAlign.end,
              isShowShimmer: true,
              shimmerWidth: AppWidgetSize.dimen_80,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateNewBottomSheet(Symbols symbolItem) async {
    _newWNameTextController.clear();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.w),
      ),
      builder: (BuildContext bct) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(20.r),
                ),
              ),
              child: SafeArea(
                child: Container(
                  padding: EdgeInsets.fromLTRB(AppWidgetSize.dimen_20,
                      AppWidgetSize.dimen_20, AppWidgetSize.dimen_20, 0),
                  child: _buildCreateWatchlistContent(
                    bct,
                    updateState,
                    symbolItem,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCreateWatchlistContent(
    BuildContext context,
    StateSetter updateState,
    Symbols symbolItem,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_15,
              bottom: 20.w,
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right: 20.w,
                  ),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: AppImages.backButtonIcon(context,
                        color: Theme.of(context).primaryIconTheme.color),
                  ),
                ),
                Text(
                  _appLocalizations.createWatchlist,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
              bottom: AppWidgetSize.dimen_15,
            ),
            child: TextField(
              style: Theme.of(context).primaryTextTheme.labelLarge,
              onChanged: (String text) {
                updateState(() {});
              },
              autofocus: true,
              inputFormatters: InputValidator.watchlistName,
              controller: _newWNameTextController,
              focusNode: newWNameFocusNode,
              maxLength: 15,
              cursorColor: Theme.of(context).primaryIconTheme.color,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: 15.w,
                  top: 12.w,
                  bottom: 12.w,
                  right: 10.w,
                ),
                counterText:
                    '${15 - (_newWNameTextController.text.length.toInt())} ${_appLocalizations.charactersRemaining}',
                counterStyle: Theme.of(context)
                    .primaryTextTheme
                    .bodySmall!
                    .copyWith(
                      color: _newWNameTextController.text.length.toInt() == 15
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context)
                              .inputDecorationTheme
                              .labelStyle!
                              .color,
                    ),
                labelText: _appLocalizations.createWatchlistDescription,
                labelStyle: Theme.of(context).primaryTextTheme.labelSmall,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.w),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).dividerColor, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).dividerColor, width: 1),
                ),
              ),
            ),
          ),
          _newWNameTextController.text.length.toInt() > 0
              ? Center(
                  child: Padding(
                      padding: EdgeInsets.only(
                        top: 5.w,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: gradientButtonWidget(
                          onTap: () {
                            if (_newWNameTextController.text.length.toInt() >
                                0) {
                              Navigator.of(context).pop();
                              widget.searchBloc.add(SearchAddSymbolEvent(
                                  _newWNameTextController.text.trim(),
                                  symbolItem,
                                  true));
                            }
                          },
                          width: AppWidgetSize.fullWidth(context) / 1.5,
                          key: const Key(watchlistCreateWatchlistKey2),
                          context: context,
                          title: _appLocalizations.createNew,
                          isGradient: true)),
                )
              : Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  height: MediaQuery.of(context).viewInsets.bottom + 100,
                ),
        ],
      ),
    );
  }

  Future<void> _onRowClickedCallBack(Symbols symbolItem, int index) async {
    if (!widget.isNewWatchlist) {
      if (!widget.isShowRecentHist) {
        widget.searchBloc.add(SymbolSearchRowTappedEvent(
          symbolItem,
        ));
      }
      if (widget.isShowRecentHist) {
        unsubscribeLevel1();
      }

      if (widget.fromAlerts) {
        await ChooseAlerts.show(
          context,
          symbolItem,
        );

        // pushNavigation(
        //   ScreenRoutes.createAlert,
        //   arguments: {
        //     'symbolItem': symbolItem,
        //   },
        // );
      } else {
        await pushNavigation(
          ScreenRoutes.quoteScreen,
          arguments: {
            'symbolItem': symbolItem,
          },
        );
      }
      // if (widget.isShowRecentHist) {
      widget.searchBloc.add(SymbolSearchEvent()
        ..searchString = widget.searchBloc.symbolSearchDoneState.searchText
        ..selectedFilter =
            widget.searchBloc.symbolSearchDoneState.selectedSymbolFilter);
      // }
    } else {}
  }

  Widget _getBottomButtonWidget(String key, String header, Color color,
      bool isGradient, Symbols selectedSymbol) {
    return GestureDetector(
      key: Key(key),
      onTap: () async {
        if (!widget.isShowRecentHist) {
          widget.searchBloc.add(SymbolSearchRowTappedEvent(
            selectedSymbol,
          ));
        }
        if (header == "B") {
          _onCallOrderPad(_appLocalizations.buy, "", selectedSymbol);
        } else {
          _onCallOrderPad(_appLocalizations.sell, "", selectedSymbol);
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 10.w),
        width: 35.w,
        height: 35.w,
        alignment: Alignment.center,
        decoration: isGradient
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20.w),
                gradient: LinearGradient(
                  stops: const [0.0, 1.0],
                  begin: FractionalOffset.topLeft,
                  end: FractionalOffset.topRight,
                  colors: <Color>[
                    Theme.of(context).colorScheme.onBackground,
                    AppColors().positiveColor,
                  ],
                ),
              )
            : BoxDecoration(
                border: Border.all(
                  color: AppColors.negativeColor,
                  width: 1.5,
                ),
                color: AppColors.negativeColor,
                borderRadius: BorderRadius.circular(AppWidgetSize.dimen_30),
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

  Future<void> _onCallOrderPad(
      String action, String? customPrice, Symbols symbolItem) async {
    await pushNavigation(
      ScreenRoutes.orderPadScreen,
      arguments: {
        'action': action,
        'symbolItem': symbolItem,
        'customPrice': customPrice ?? "",
        "basketData": widget.basketData
      },
    );
  }
}
