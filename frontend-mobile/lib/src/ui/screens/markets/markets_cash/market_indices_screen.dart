import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../../blocs/markets/markets_bloc.dart';
import '../../../../config/app_config.dart';
import '../../../../constants/app_constants.dart';
import '../../../../constants/keys/watchlist_keys.dart';
import '../../../../data/store/app_storage.dart';
import '../../../../data/store/app_store.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../../models/config/config_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_color.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/gradient_button_widget.dart';
import '../../../widgets/loader_widget.dart';
import '../../base/base_screen.dart';

class MarketIndicesScreen extends BaseScreen {
  final dynamic arguments;
  const MarketIndicesScreen({Key? key, this.arguments}) : super(key: key);

  @override
  State<MarketIndicesScreen> createState() => _MarketIndicesScreenState();
}

class _MarketIndicesScreenState
    extends BaseAuthScreenState<MarketIndicesScreen> {
  late AppLocalizations _appLocalizations;
  late String selectedSegment;
  late List<Symbols> reOrderList;
  late List<Symbols> currentEditSymbolList = [];
  late List<String> pullDownSymbolsList = [];
  ValueNotifier<bool> editSymbolListModified = ValueNotifier(false);
  ValueNotifier<int> editSymbolsCount = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return _buildMarketsBlocBuilder();
  }

  @override
  String getScreenRoute() {
    if (widget.arguments['screenName'] != null) {
      return widget.arguments["screenName"] == AppConstants.fno
          ? ScreenRoutes.marketsFNOIndicesScreen
          : widget.arguments["screenName"] == AppLocalizations().topIndices
              ? ScreenRoutes.marketsTopPullDownIndicesScreen
              : ScreenRoutes.marketsCashIndicesScreen;
    }
    if (selectedSegment == AppLocalizations().topIndices) {
      return ScreenRoutes.marketsTopPullDownIndicesScreen;
    } else {
      return ScreenRoutes.marketIndicesScreen;
    }
  }

  @override
  void didUpdateWidget(MarketIndicesScreen oldWidget) {
    loadData();

    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();

    loadData();
  }

  void loadData() {
    getSavedPullDownSymbols();
    selectedSegment = widget.arguments['screenName'];
    BlocProvider.of<MarketsBloc>(context)
        .stream
        .listen(marketIndicesBlocListener);

    getHorizontalListViewItems();
  }

  Future<void> marketIndicesBlocListener(MarketsState state) async {
    if (state is MarketIndicesStartStreamState) {
      subscribeLevel1(state.streamDetails);
    }
  }

  @override
  void quote1responseCallback(ResponseData data) {
    if (selectedSegment == AppLocalizations().topIndices) {
      BlocProvider.of<MarketsBloc>(context)
          .add(MarketIndicesStreamingPullDownMenuResponseEvent(data));
    } else {
      BlocProvider.of<MarketsBloc>(context)
          .add(MarketIndicesStreamingResponseEvent(data));
    }
  }

  void getHorizontalListViewItems() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedSegment == AppConstants.cash) {
        BlocProvider.of<MarketsBloc>(context)
            .add(FetchMarketIndicesItemsEvent(getCashSegmentItems: true));
      } else if (selectedSegment == AppLocalizations().topIndices) {
        BlocProvider.of<MarketsBloc>(context)
            .add(FetchMarketIndicesItemsEvent(getPullDownMenuItems: true));
      } else if (selectedSegment == AppLocalizations().topIndicesEditor) {
        BlocProvider.of<MarketsBloc>(context)
            .add(FetchMarketIndicesItemsEvent(getPullDownMenuEditItems: true));
      } else {
        BlocProvider.of<MarketsBloc>(context)
            .add(FetchMarketIndicesItemsEvent(getFOSegmentItems: true));
      }
    });
  }

  BlocBuilder _buildMarketsBlocBuilder() {
    return BlocBuilder<MarketsBloc, MarketsState>(
        buildWhen: (previous, current) {
      return current is MarketsFetchItemsDoneState ||
          current is MarketsFetchItemsProgressState ||
          current is MarketsPullDownItemsEditListDoneState ||
          current is MarketsPullDownItemsDoneState;
    }, builder: (context, state) {
      if (state is MarketsFetchItemsDoneState) {
        return _buildTopContentListViewWidget(state);
      } else if (state is MarketsPullDownItemsDoneState) {
        return _buildPullDownIndicesWidget(state);
      } else if (state is MarketsPullDownItemsEditListDoneState) {
        return _buildPullDownIndicesDataEdit(state);
      }
      return SizedBox(height: 90.w, child: const LoaderWidget());
    });
  }

  Widget _buildPullDownIndicesDataEdit(
    MarketsPullDownItemsEditListDoneState state,
  ) {
    getSavedPullDownSymbols();
    List<Symbols> items = [];

    AppStore().setIndicesEditList(state.pullDownMenuEditSymbols!);

    List<Symbols> editItems = AppStore().getIndicesEditorList();

    if (editSymbolListModified.value == false &&
        pullDownSymbolsList.isNotEmpty) {
      for (var element in pullDownSymbolsList) {
        items.add(AppUtils().getSymbolsItemWithDispSym(
            element, AppStore().getIndicesEditorList()));
      }
    } else {
      items = currentEditSymbolList;
    }
    editSymbolsCount.value = currentEditSymbolList
                .where((element) => element.dispSym != _appLocalizations.empty)
                .length >
            4
        ? 4
        : currentEditSymbolList
            .where((element) => element.dispSym != _appLocalizations.empty)
            .length;

    return FutureBuilder(
        future: Future.delayed(const Duration(seconds: 1)),
        builder: (context, snapshot) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                20.w,
            child: Scaffold(
              bottomNavigationBar: Container(
                margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 40.w),
                decoration: BoxDecoration(
                  // border: Border(
                  //     top: BorderSide(
                  //         width: 1.0, color: Color.fromRGBO(229, 229, 229, 1))),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      offset: const Offset(0.0, 1.0),
                      blurRadius: AppWidgetSize.dimen_2,
                    ),
                  ],
                ),
                child: cancelSaveButtonContainer(),
              ),
              body: Container(
                padding: EdgeInsets.only(
                  top: 10.w,
                  left: AppWidgetSize.dimen_16,
                  right: AppWidgetSize.dimen_16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5.w,
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                      child: Theme(
                        data: ThemeData(
                          canvasColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          dividerColor: Theme.of(context).dividerColor,
                        ),
                        child: ReorderableListView(
                          buildDefaultDragHandles: false,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: <Widget>[
                            for (int index = 0;
                                index < currentEditSymbolList.take(4).length;
                                index += 1)
                              Container(
                                alignment: Alignment.center,
                                key: Key('$index'),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Card(
                                      color: Colors.transparent,
                                      elevation: 0,
                                      key: Key('$index'),
                                      child: ListTile(
                                        leading: ReorderableDragStartListener(
                                          index: index,
                                          enabled: true,
                                          child: SizedBox(
                                            height: AppWidgetSize.dimen_40,
                                            child: AppImages.dragDrop(
                                              context,
                                              color: Theme.of(context)
                                                  .primaryIconTheme
                                                  .color,
                                              isColor: true,
                                            ),
                                          ),
                                        ),
                                        key: Key('$index'),
                                        // tileColor: items[index].isOdd ? oddItemColor : evenItemColor,
                                        trailing: !(items[index].dispSym ==
                                                _appLocalizations.empty)
                                            ? SizedBox(
                                                height: AppWidgetSize.dimen_40,
                                                child: GestureDetector(
                                                  child:
                                                      AppImages.cancelMarkets(
                                                    context,
                                                    width: 30.w,
                                                    height: 30.w,
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      editSymbolListModified
                                                          .value = true;
                                                      items.removeAt(index);

                                                      NSE nseItem = NSE();
                                                      nseItem.baseSym = "";
                                                      nseItem.dispSym =
                                                          _appLocalizations
                                                              .empty;
                                                      nseItem.hasFutOpt = false;
                                                      nseItem.sym = null;
                                                      items.insert(
                                                          index, nseItem);

                                                      currentEditSymbolList =
                                                          items;
                                                      editSymbolsCount.value--;
                                                    });
                                                  },
                                                ),
                                              )
                                            : const SizedBox(
                                                height: 0,
                                                width: 0,
                                              ),
                                        title: Opacity(
                                          opacity: items[index].dispSym ==
                                                  _appLocalizations.empty
                                              ? 0.5
                                              : 1,
                                          child: CustomTextWidget(
                                              '${items[index].dispSym}',
                                              Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontSize: AppWidgetSize
                                                        .fontSize16,
                                                  )),
                                        ),
                                      ),
                                    ),
                                    index != 3
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                                left: AppWidgetSize.dimen_16,
                                                right: AppWidgetSize.dimen_16),
                                            child: Divider(
                                              height: 1.w,
                                              // color: Colors.black38,
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                              ),
                          ],
                          onReorder: (int oldIndex, int newIndex) {
                            editSymbolListModified.value = true;
                            setState(() {
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }
                              final element = items.removeAt(oldIndex);
                              items.insert(newIndex, element);
                              currentEditSymbolList = items;
                            });
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30.w, bottom: 10.w),
                      child: CustomTextWidget(
                          _appLocalizations.chooseIndices,
                          Theme.of(context).textTheme.displaySmall!.copyWith(
                              fontSize: AppWidgetSize.fontSize16,
                              fontWeight: FontWeight.w500)),
                    ),
                    //CALCULATED THE HEIGHT OF THE CONTAINER BECAUSE LISTVIEW INSIDE EXPANDED KEPT CRASHING
                    //NEED TO CHECK
                    Expanded(
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          // primary: false,
                          shrinkWrap: true,
                          itemCount: editItems.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding:
                                      EdgeInsets.only(top: 5.w, bottom: 5.w),
                                  child: Card(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    elevation: 0,
                                    child: ListTile(
                                        visualDensity:
                                            const VisualDensity(vertical: -1),
                                        key: Key('$index'),
                                        trailing: (items.any((item) =>
                                                item.dispSym ==
                                                editItems[index]
                                                    .dispSym)) //items.contains(editItems[index])
                                            ? GestureDetector(
                                                child: AppImages.addFilledIcon(
                                                  context,
                                                  width: 30.w,
                                                  height: 30.w,
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    editSymbolListModified
                                                        .value = true;
                                                    final deletedIndex =
                                                        currentEditSymbolList
                                                            .indexWhere((element) =>
                                                                element
                                                                    .dispSym ==
                                                                editItems[index]
                                                                    .dispSym);

                                                    NSE nseItem = NSE();
                                                    nseItem.baseSym = "";
                                                    nseItem.dispSym =
                                                        _appLocalizations.empty;
                                                    nseItem.hasFutOpt = false;
                                                    nseItem.sym = null;
                                                    currentEditSymbolList
                                                        .removeAt(deletedIndex);
                                                    currentEditSymbolList
                                                        .insert(deletedIndex,
                                                            nseItem);
                                                    editSymbolsCount.value--;
                                                  });
                                                },
                                              )
                                            : GestureDetector(
                                                child: (currentEditSymbolList
                                                        .any((item) =>
                                                            item.dispSym ==
                                                            _appLocalizations
                                                                .empty))
                                                    ? AppImages.addUnfilledIcon(
                                                        context,
                                                        color: AppColors()
                                                            .positiveColor,
                                                        isColor: true,
                                                        width: 30.w,
                                                        height: 30.w,
                                                      )
                                                    : const SizedBox(
                                                        height: 0,
                                                        width: 0,
                                                      ),
                                                onTap: () {
                                                  setState(() {
                                                    final indexToBeAdded =
                                                        currentEditSymbolList
                                                            .indexWhere((element) =>
                                                                element
                                                                    .dispSym ==
                                                                _appLocalizations
                                                                    .empty);
                                                    if (indexToBeAdded >= 0) {
                                                      currentEditSymbolList
                                                          .removeAt(
                                                              indexToBeAdded);
                                                      currentEditSymbolList
                                                          .insert(
                                                              indexToBeAdded,
                                                              editItems[index]);
                                                      editSymbolsCount.value++;
                                                    }
                                                  });
                                                },
                                              ),
                                        title: Transform.translate(
                                          offset: const Offset(-16, 0),
                                          child: CustomTextWidget(
                                              '${editItems[index].dispSym}',
                                              Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontSize: AppWidgetSize
                                                        .fontSize16,
                                                  )),
                                        )),
                                  ),
                                ),
                                Divider(
                                  height: 1.w,
                                  //color: Theme.of(context).dividerColor,
                                )
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
  /*
  AppWidgetSize.screenHeight(context) -
                  ((AppWidgetSize.screenHeight(context) * 0.5) +
                      AppWidgetSize.dimen_270 +
                      AppWidgetSize.dimen_16 +
                      40 +
                      AppWidgetSize.dimen_16 +
                      topPadding)
   */

  Widget cancelSaveButtonContainer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            gradientButtonWidget(
              isErrorButton: true,
              onTap: () {
                Navigator.of(context).pop();
              },
              width:
                  AppWidgetSize.fullWidth(context) / 2 - AppWidgetSize.dimen_24,
              key: const Key(marketsPullDownCancelSaveKey),
              context: context,
              title: _appLocalizations.cancel,
              isGradient: false,
              bottom: 0,
            ),
            ValueListenableBuilder(
                valueListenable: editSymbolListModified,
                builder: (context, value, _) {
                  return Opacity(
                    opacity: getButtonOpacity(),
                    child: gradientButtonWidget(
                      onTap: () {
                        if (editSymbolsCount.value == 4 &&
                            !(reOrderList.any((item) =>
                                item.dispSym == _appLocalizations.empty)) &&
                            editSymbolListModified.value == true) {
                          Navigator.of(context).pop();
                          setSavedPullDownSymbols(currentEditSymbolList);
                          showToast(
                            message:
                                _appLocalizations.marketSequenceOrderSuccessMsg,
                            context: context,
                          );
                        }
                      },
                      width: AppWidgetSize.fullWidth(context) / 2 -
                          AppWidgetSize.dimen_24,
                      key: const Key(marketsPullDownCancelSaveKey),
                      context: context,
                      title: _appLocalizations.save,
                      isGradient: true,
                      bottom: 0,
                    ),
                  );
                }),
          ],
        )
      ],
    );
  }

  double getButtonOpacity() {
    if (editSymbolsCount.value == 4 && editSymbolListModified.value == true) {
      return 1.0;
    } else {
      return 0.5;
    }
  }

  void setSavedPullDownSymbols(List<Symbols> symbolList) {
    AppStorage().setData(savedPullDownMenuItemsKey, symbolList);
  }

  getSavedPullDownSymbols() async {
    List? data = await AppStorage().getData(savedPullDownMenuItemsKey);
    pullDownSymbolsList = [];
    for (var element in (data ?? [])) {
      pullDownSymbolsList.add(element['dispSym']);
    }
  }

  Widget _buildPullDownIndicesWidget(
    MarketsPullDownItemsDoneState state,
  ) {
    AppStore().setIndicesList(state.pullDownMenuSymbols as List<Symbols>);
    currentEditSymbolList = state.pullDownMenuSymbols as List<Symbols>;
    reOrderList = state.pullDownMenuEditSymbols as List<Symbols>;

    var symbols = pullDownSymbolsList;
    int len = 0;
    len = symbols.length;

    if (len == 0) {
      setSavedPullDownSymbols(state.pullDownMenuSymbols!);
      currentEditSymbolList = state.pullDownMenuSymbols as List<Symbols>;
    } else {
      List<Symbols> symList = [];
      for (var element in pullDownSymbolsList) {
        symList.add(AppUtils().getSymbolsItemWithDispSym(element, reOrderList));
        currentEditSymbolList = symList;
      }
    }

    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_24, right: AppWidgetSize.dimen_24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 20.w),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Wrap(
                  children: currentEditSymbolList.map((e) {
                return Container(
                  width: AppUtils.isTablet && !AppConfig.isLandScape
                      ? ((AppWidgetSize.screenWidth(context) / 2) - 24.w)
                      : 162.w,
                  padding: EdgeInsets.only(right: 8.w, left: 8.w, bottom: 12.w),
                  child: _buildListBoxContentForPullDownMenu(0, e.dispSym,
                      e.ltp ?? "", e.chng ?? "", e.chngPer ?? "", e),
                );
              }).toList())),
        ],
      ),
    );
  }

  // Widget _buildPullDownIndicesAnimatedWidget(
  //   MarketsPullDownItemsDoneState state,
  // ) {
  //   AppStore().setIndicesList(
  //       state.pullDownMenuSymbols?.take(4).toList() as List<Symbols>);
  //   currentEditSymbolList =
  //       state.pullDownMenuSymbols?.take(4).toList() as List<Symbols>;
  //   reOrderList = state.pullDownMenuEditSymbols as List<Symbols>;

  //   var symbols = pullDownSymbolsList;
  //   int len = 0;
  //   len = symbols.length;

  //   if (len == 0) {
  //     currentEditSymbolList = state.pullDownMenuSymbols as List<Symbols>;
  //   } else {
  //     List<Symbols> symList = [];
  //     for (var element in pullDownSymbolsList) {
  //       symList.add(AppUtils().getSymbolsItemWithDispSym(element, reOrderList));
  //       currentEditSymbolList = symList;
  //     }
  //   }
  //   return ScrollLoopAutoScroll(
  //       scrollDirection: Axis.horizontal,
  //       scroll: AppConstants.animateBanner.value,
  //       enableScrollInput: true,
  //       child: Container(
  //           height: 90.w,
  //           width: (140.w * 4),
  //           alignment: Alignment.center,
  //           color: Theme.of(context).scaffoldBackgroundColor,
  //           child: ListView.builder(
  //               scrollDirection: Axis.horizontal,
  //               cacheExtent: 4,
  //               itemCount: currentEditSymbolList.length,
  //               itemBuilder: (context, index) {
  //                 return Container(
  //                   width: 140.w,
  //                   padding:
  //                       EdgeInsets.only(right: 8.w, left: 8.w, bottom: 12.w),
  //                   child: _buildListBoxContentForAnimatedPullDownMenu(
  //                       0,
  //                       currentEditSymbolList[index].dispSym,
  //                       currentEditSymbolList[index].ltp ?? "",
  //                       currentEditSymbolList[index].chng ?? "",
  //                       currentEditSymbolList[index].chngPer ?? "",
  //                       currentEditSymbolList[index]),
  //                 );
  //               })));
  // }

  Widget _buildTopContentListViewWidget(
    MarketsFetchItemsDoneState state,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_15,
        left: AppWidgetSize.dimen_20,
      ),
      child: Container(
        alignment: Alignment.centerLeft,
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_5,
          bottom: AppWidgetSize.dimen_5,
        ),
        height: 98.w,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: state.nSE?.length,
          itemBuilder: (BuildContext context, int itemNumber) {
            return _buildListBoxContent(
                state,
                itemNumber,
                state.nSE?[itemNumber].dispSym,
                state.nSE?[itemNumber].ltp ?? "",
                state.nSE?[itemNumber].chng ?? "",
                state.nSE?[itemNumber].chngPer ?? "",
                isTop: true);
          },
        ),
      ),
    );
  }

  // Widget _buildListBoxContentForAnimatedPullDownMenu(
  //     int? indexNumer,
  //     String? title,
  //     String? ltp,
  //     String? chng,
  //     String? chngPer,
  //     Symbols symbolItem) {
  //   return GestureDetector(
  //       onTap: () {},
  //       child: Container(
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(
  //             10.w,
  //           ),
  //           color: Theme.of(context).scaffoldBackgroundColor,
  //           border: Border.all(
  //             width: 0.5.w,
  //             color: Theme.of(context).dividerColor,
  //           ),
  //           boxShadow: <BoxShadow>[
  //             BoxShadow(
  //               color: Theme.of(context).dividerColor,
  //               blurRadius: 2.5,
  //             ),
  //           ],
  //         ),
  //         child: _getListBoxAnimatedWidget(
  //           title!,
  //           ltp!,
  //           chng!,
  //           chngPer!,
  //           indexNumer!,
  //           symbolItem,
  //         ),
  //       ));
  // }

  Widget _buildListBoxContentForPullDownMenu(int? indexNumer, String? title,
      String? ltp, String? chng, String? chngPer, Symbols symbolItem) {
    return GestureDetector(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              10.w,
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(
              width: 0.5.w,
              color: Theme.of(context).dividerColor,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Theme.of(context).dividerColor,
                blurRadius: 2.5,
              ),
            ],
          ),
          child: _getListBoxWidget(
            title!,
            ltp!,
            chng!,
            chngPer!,
            indexNumer!,
            symbolItem,
          ),
        ));
  }

  Widget _buildListBoxContent(MarketsFetchItemsDoneState state, int? indexNumer,
      String? title, String? ltp, String? chng, String? chngPer,
      {bool isTop = false}) {
    return GestureDetector(
      onTap: () {
        _onRowClickedCallBack(state.nSE![indexNumer]);
      },
      child: Padding(
        padding: EdgeInsets.only(
          right: AppWidgetSize.dimen_10,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppWidgetSize.dimen_5, vertical: 5.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              10.w,
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(
              width: 0.5.w,
              color: Theme.of(context).dividerColor,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Theme.of(context).dividerColor,
                blurRadius: 2.5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _getListBoxWidget(title!, ltp!, chng!, chngPer!, indexNumer!,
                  state.nSE![indexNumer],
                  isTop: isTop),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _getListBoxAnimatedWidget(String title, String ltp, String chng,
  //     String chngPer, int indexNumber, Symbols symbolItem,
  //     {bool isTop = false}) {
  //   return GestureDetector(
  //     onTap: () {
  //       _onRowClickedCallBack(symbolItem);
  //     },
  //     child: Container(
  //       padding: EdgeInsets.only(
  //           left: 8.w, right: isTop ? 30.w : 10.w, top: 5.w, bottom: 5.w),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: <Widget>[
  //           Container(
  //             padding: EdgeInsets.only(top: 4.w),
  //             child: FittedBox(
  //               fit: BoxFit.scaleDown,
  //               child: CustomTextWidget(
  //                 title,
  //                 Theme.of(context)
  //                     .primaryTextTheme
  //                     .labelSmall!
  //                     .copyWith(fontWeight: FontWeight.w600, fontSize: 16.w),
  //                 textAlign: TextAlign.left,
  //               ),
  //             ),
  //           ),
  //           Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Padding(
  //                 padding: EdgeInsets.only(top: 4.w),
  //                 child: CustomTextWidget(
  //                   AppUtils().dataNullCheck(ltp),
  //                   Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 14.w,
  //                         color: AppUtils().setcolorForChange(
  //                             AppUtils().dataNullCheck(chng)),
  //                       ),
  //                   textAlign: TextAlign.end,
  //                   isShowShimmer: true,
  //                 ),
  //               ),
  //               Padding(
  //                 padding: EdgeInsets.only(top: 4.w),
  //                 child: CustomTextWidget(
  //                   AppUtils().getChangePercentage(symbolItem),
  //                   Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
  //                       color: Theme.of(context)
  //                           .inputDecorationTheme
  //                           .labelStyle!
  //                           .color,
  //                       fontSize: 12.w),
  //                   textAlign: TextAlign.end,
  //                   isShowShimmer: true,
  //                   shimmerWidth: AppWidgetSize.dimen_80,
  //                 ),
  //               ),
  //             ],
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _getListBoxWidget(String title, String ltp, String chng,
      String chngPer, int indexNumber, Symbols symbolItem,
      {bool isTop = false}) {
    return GestureDetector(
      onTap: () {
        _onRowClickedCallBack(symbolItem);
      },
      child: Container(
        padding: EdgeInsets.only(left: 6.w, right: isTop ? 30.w : 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              height: 30.w,
              padding: EdgeInsets.only(top: 4.w),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: CustomTextWidget(
                  title,
                  Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 4.w),
                  child: CustomTextWidget(
                    AppUtils().dataNullCheck(ltp),
                    Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppUtils().setcolorForChange(
                              AppUtils().dataNullCheck(chng)),
                        ),
                    textAlign: TextAlign.end,
                    isShowShimmer: true,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 4.w),
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
            )
          ],
        ),
      ),
    );
  }

  Future<void> _onRowClickedCallBack(
    Symbols symbolItem,
  ) async {
    unsubscribeLevel1();
    await pushNavigation(
      ScreenRoutes.quoteScreen,
      arguments: {
        'symbolItem': symbolItem,
        'shouldHideFooter': true,
      },
    );
    if (!mounted) return;
    BlocProvider.of<MarketsBloc>(context)
        .add(MarketMoversStartSymStreamForIndicesEvent(
      selectedSegment,
    ));
  }
}
