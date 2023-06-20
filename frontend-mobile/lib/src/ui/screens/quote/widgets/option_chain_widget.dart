import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../../blocs/quote/futures_option/common_quote/quote_futures_options_bloc.dart';
import '../../../../constants/app_constants.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../../models/quote/quote_options/quote_option_chain_data.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/loader_widget.dart';
import '../../base/base_screen.dart';
import 'measurebox.dart';

class OptionChainWidgetArgs {
  final List<String> selectedlist;
  final Symbols symbol;
  final String expiry;
  OptionChainWidgetArgs(
    this.selectedlist,
    this.symbol,
    this.expiry,
  );
}

class OptionChainWidget extends BaseScreen {
  final OptionChainWidgetArgs arguments;

  const OptionChainWidget(
    this.arguments, {
    Key? key,
  }) : super(key: key);

  @override
  OptionChainWidgetState createState() => OptionChainWidgetState();
}

class OptionChainWidgetState extends BaseAuthScreenState<OptionChainWidget> {
  late QuoteFuturesOptionsBloc quoteFuturesOptionsBloc;
  bool onfirstScroll = true;

  @override
  void initState() {
    _appLocalizations = AppLocalizations();

    quoteFuturesOptionsBloc = BlocProvider.of<QuoteFuturesOptionsBloc>(context)
      ..stream.listen(quoteFuturesOptionsListener);
    quoteFuturesOptionsBloc.add(QuoteOptionChainGetFilterListEvent());
    quoteFuturesOptionsBloc.add(
      QuoteOptionsChainEvent(
        _getOptionChainData(),
        true,
      ),
    );
    quoteFuturesOptionsBloc.add(
        QuoteOptionChainUpdateFilterListEvent(widget.arguments.selectedlist));

    controller.addListener(scrollListenerWithItemCount);
    super.initState();
  }

  int lengthList = 0;

  Future<void> quoteFuturesOptionsListener(
      QuoteFuturesOptionsState state) async {
    if (state is QuoteOptionChainProgressState) {
      if (mounted) {
        startLoader();
      }
    } else if (state is QuoteOptionChainSymStreamState) {
      subscribeLevel1(state.streamDetails);
    } else if (state is QuoteOptionChainFilterDoneState) {
      if (mounted) {
        stopLoader();
      }
    } else if (state is QuoteFuturesOptionsErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  @override
  void quote1responseCallback(ResponseData data) {
    quoteFuturesOptionsBloc.add(
      QuoteOptionChainStreamingResponseEvent(data),
    );
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.quoteOptionChainCallPut + widget.arguments.expiry;
  }

  @override
  void dispose() {
    unsubscribeLevel1();
    super.dispose();
  }

  late AppLocalizations _appLocalizations;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppWidgetSize.screenHeight(context),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Column(
          children: [
            _buildHeader(),
            _buildContentWidget(),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
        top: AppWidgetSize.dimen_20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            child: Center(
              child: CustomTextWidget(
                _appLocalizations.call,
                Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          Container(
            height: AppWidgetSize.dimen_44,
            width: AppWidgetSize.dimen_80,
            margin: EdgeInsets.only(
              right: AppWidgetSize.dimen_5,
            ),
            color: Theme.of(context).snackBarTheme.backgroundColor,
            child: Center(
              child: CustomTextWidget(
                _appLocalizations.strikePrice,
                Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          ),
          SizedBox(
            child: Center(
              child: CustomTextWidget(
                _appLocalizations.put,
                Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  final ScrollController controller = ScrollController();

  Widget _buildContentWidget() {
    return Expanded(
      child: Column(
        children: [
          spotPriceTopView(),
          Expanded(
            child: buildTableBodyView(),
          ),
          spotPriceBottomView()
        ],
      ),
    );
  }

  ValueListenableBuilder<int> spotPriceBottomView() {
    return ValueListenableBuilder<int>(
        valueListenable: lastVisibleItem,
        builder: (context, value, _) {
          if (strikeIndex.value > (value) && strikeIndex.value != 0) {
            return strikePriceWidget();
          } else {
            return Container();
          }
        });
  }

  ValueListenableBuilder<int> spotPriceTopView() {
    return ValueListenableBuilder<int>(
        valueListenable: firstVisibleItem,
        builder: (context, value, _) {
          if (strikeIndex.value < (value) && strikeIndex.value != 0) {
            return strikePriceWidget();
          } else {
            return Container();
          }
        });
  }

  ValueListenableBuilder<String> strikePriceWidget() {
    return ValueListenableBuilder<String>(
        valueListenable: strikeValue,
        builder: (context, value, _) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              const Divider(
                thickness: 2,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).iconTheme.color,
                    borderRadius:
                        BorderRadius.circular(AppWidgetSize.dimen_11)),
                padding: EdgeInsets.all(AppWidgetSize.dimen_4),
                child: Text("Spot Price : $value",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.background,
                        )),
              ),
            ],
          );
        });
  }

  Widget buildTableBodyView() {
    return BlocBuilder<QuoteFuturesOptionsBloc, QuoteFuturesOptionsState>(
        buildWhen: (QuoteFuturesOptionsState prevState,
            QuoteFuturesOptionsState currentState) {
      return currentState is QuoteOptionsDoneState;
    }, builder: (BuildContext ctx, QuoteFuturesOptionsState state) {
      if (state is QuoteOptionsDoneState &&
          state.optionQuoteModel != null &&
          state.optionQuoteModel!.results!.call != null &&
          state.optionQuoteModel!.results!.put != null) {
        List<Symbols> callList = state.optionQuoteModel!.results!.call!;
        List<Symbols> putList = state.optionQuoteModel!.results!.put!;
        List<Symbols> spotList = state.optionQuoteModel!.results!.spot!;
        int lengthValue =
            callList.length > putList.length ? callList.length : putList.length;
        lengthList = lengthValue;
        String strikeVal =
            (spotList.isNotEmpty) ? (spotList.toList().first.ltp ?? "0") : "0";
        WidgetsBinding.instance.addPostFrameCallback((_) {
          strikeValue.value = strikeVal;
        });

        for (int i = 0; i < lengthValue; i++) {
          try {
            if ((AppUtils().doubleValue((callList.length > putList.length
                            ? callList[i].sym!.strike
                            : putList[i].sym!.strike) ??
                        "0") <
                    AppUtils().doubleValue(strikeVal) &&
                AppUtils().doubleValue(strikeVal) <=
                    (i == lengthValue //tempfix
                        ? 0
                        : (AppUtils().doubleValue(
                            (callList.length > putList.length
                                    ? callList[i + 1].sym!.strike
                                    : putList[i + 1].sym!.strike) ??
                                "0"))))) {
              strikeIndex.value = i;
              if (onfirstScroll) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.animateTo((height * 1),
                      duration: const Duration(seconds: 2),
                      curve: Curves.linear);
                });
              }
            }
          } catch (e) {
            strikeIndex.value = i;
            if (onfirstScroll) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.animateTo((height * 1),
                    duration: const Duration(seconds: 2), curve: Curves.linear);
              });
            }
          }
        }
        return buildOptionChainBody(
          lengthValue,
          callList,
          putList,
          strikeVal,
        );
      } else {
        return const Center(
          child: LoaderWidget(),
        );
      }
    });
  }

  double height = 0;
  ListView buildOptionChainBody(
    int lengthValue,
    List<Symbols> callList,
    List<Symbols> putList,
    String strikeVal,
  ) {
    final dataKey = GlobalKey();

    return ListView.builder(
      itemCount: lengthValue,
      shrinkWrap: true,
      cacheExtent: lengthValue.toDouble(),
      controller: controller,
      itemBuilder: (context, index) {
        Symbols callItem;
        Symbols putItem;
        if (callList.length >= putList.length) {
          callItem = callList[index];
          putItem = putList.indexWhere((element) =>
                      element.sym?.strike == callItem.sym?.strike) !=
                  -1
              ? putList[putList.indexWhere(
                  (element) => element.sym?.strike == callItem.sym?.strike)]
              : Symbols(
                  ltp: "--",
                  chngPer: "--",
                  chng: "--",
                  openInterest: "--",
                  vol: "--",
                  oiChangePer: "--");
        } else {
          putItem = putList[index];
          callItem = callList.indexWhere((element) =>
                      element.sym?.strike == putItem.sym?.strike) !=
                  -1
              ? callList[callList.indexWhere(
                  (element) => element.sym?.strike == putItem.sym?.strike)]
              : Symbols(
                  ltp: "--",
                  chngPer: "--",
                  chng: "--",
                  openInterest: "--",
                  vol: "--",
                  oiChangePer: "--");
        }

        final String? strikePrice;
        if (callItem.sym?.strike != null) {
          strikePrice = callItem.sym?.strike;
        } else {
          strikePrice = putItem.sym?.strike ?? "--";
        }
        bool isSpot = false;

        try {
          isSpot = (AppUtils().doubleValue((callList.length > putList.length
                          ? callList[index].sym!.strike
                          : putList[index].sym!.strike) ??
                      "0") <
                  AppUtils().doubleValue(strikeVal) &&
              AppUtils().doubleValue(strikeVal) <=
                  (index == lengthValue //tempfix
                      ? 0
                      : (AppUtils().doubleValue(
                          (callList.length > putList.length
                                  ? callList[index + 1].sym!.strike
                                  : putList[index + 1].sym!.strike) ??
                              "0"))));
        } catch (e) {
          if (index + 1 == lengthValue) {
            isSpot = true;
          }
        }

        return MeasureSize(
            onChange: (size) {
              if (size.height > 0) {
                height = size.height;
              }
            },
            child: Stack(
              key: isSpot ? dataKey : Key(index.toString()),
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_30,
                    right: AppWidgetSize.dimen_30,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border(
                        bottom: isSpot
                            ? BorderSide.none
                            : BorderSide(
                                width: AppWidgetSize.dimen_1,
                                color: Theme.of(context).dividerColor,
                              ),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        buildRowContent(
                            true,
                            callItem.ltp,
                            callItem.chngPer,
                            callItem.openInterest,
                            callItem.oiChangePer,
                            callItem.vol,
                            callItem,
                            index),
                        Container(
                          margin: EdgeInsets.only(
                            left: AppWidgetSize.dimen_7,
                            right: AppWidgetSize.dimen_5,
                          ),
                          height: widget.arguments.selectedlist.isNotEmpty
                              ? widget.arguments.selectedlist.length * 15 +
                                  (isSpot
                                      ? AppWidgetSize.dimen_70
                                      : AppWidgetSize.dimen_50)
                              : (isSpot
                                  ? AppWidgetSize.dimen_70
                                  : AppWidgetSize.dimen_50),
                          width: AppWidgetSize.dimen_80,
                          color:
                              Theme.of(context).snackBarTheme.backgroundColor,
                          child: Center(
                            child: Text(
                              strikePrice!,
                              style:
                                  Theme.of(context).primaryTextTheme.bodySmall,
                            ),
                          ),
                        ),
                        buildRowContent(
                            false,
                            putItem.ltp,
                            putItem.chngPer,
                            putItem.openInterest,
                            putItem.oiChangePer,
                            putItem.vol,
                            putItem,
                            index),
                      ],
                    ),
                  ),
                ),
                if (isSpot)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const Divider(
                        thickness: 2,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).iconTheme.color,
                            borderRadius:
                                BorderRadius.circular(AppWidgetSize.dimen_11)),
                        padding: EdgeInsets.all(AppWidgetSize.dimen_4),
                        child: Text(
                            "Spot Price : ${strikeVal == "0" ? "--" : strikeVal}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                )),
                      ),
                    ],
                  ),
              ],
            ));
      },
    );
  }

  ValueNotifier<int> firstVisibleItem = ValueNotifier<int>(0);
  ValueNotifier<int> lastVisibleItem = ValueNotifier<int>(0);
  ValueNotifier<int> strikeIndex = ValueNotifier<int>(0);
  ValueNotifier<String> strikeValue = ValueNotifier<String>("0");

  scrollListenerWithItemCount() {
    int itemCount = lengthList;
    double? scrollOffset = controller.position.pixels;
    double? viewportHeight = controller.position.viewportDimension;
    double? scrollRange = (controller.position.maxScrollExtent) -
        (controller.position.minScrollExtent);
    lastVisibleItem.value = (((scrollOffset) + (viewportHeight)) /
            (scrollRange + (viewportHeight)) *
            itemCount)
        .floor();

    firstVisibleItem.value =
        (((scrollOffset)) / (scrollRange + (viewportHeight)) * itemCount)
            .floor();
    if (onfirstScroll) {
      controller.animateTo(
          (height *
                  (strikeIndex.value -
                      (((firstVisibleItem.value + lastVisibleItem.value) / 2))))
              .toDouble(),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInExpo);
      onfirstScroll = false;
    }
  }

  Widget buildRowContent(
      bool isLeft,
      String? ltp,
      String? chngPer,
      String? openInterest,
      String? oiChangePer,
      String? vol,
      Symbols symbol,
      int index) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (symbol.dispSym != null) {
            pushNavigation(
              ScreenRoutes.quoteScreen,
              arguments: {
                'symbolItem': symbol,
              },
            );
          }
        },
        child: Column(
          children: [
            _buildLtpWidget(isLeft, ltp, chngPer, symbol.dispSym != null),
            _buildOiWidget(isLeft, openInterest, symbol.dispSym != null),
            _buildOiChngWidget(isLeft, oiChangePer, symbol.dispSym != null),
            _buildVolWidget(isLeft, vol, symbol.dispSym != null),
          ],
        ),
      ),
    );
  }

  Widget _buildLtpWidget(
      bool isLeft, String? ltp, String? chngPer, bool showShimmer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (isLeft)
          CustomTextWidget(
            '${AppUtils().dataNullCheck(chngPer)}%',
            Theme.of(context)
                .primaryTextTheme
                .bodyLarge
                ?.copyWith(color: AppUtils().profitLostColor(chngPer)),
            isShowShimmer: showShimmer,
            shimmerWidth: AppWidgetSize.dimen_50,
          ),
        CustomTextWidget(
          AppUtils().dataNullCheck(ltp),
          Theme.of(context).primaryTextTheme.bodySmall,
          isShowShimmer: showShimmer,
          shimmerWidth: AppWidgetSize.dimen_50,
        ),
        if (!isLeft)
          CustomTextWidget(
            '${AppUtils().dataNullCheck(chngPer)}%',
            Theme.of(context)
                .primaryTextTheme
                .bodyLarge
                ?.copyWith(color: AppUtils().profitLostColor(chngPer)),
            isShowShimmer: showShimmer,
            shimmerWidth: AppWidgetSize.dimen_50,
          ),
      ],
    );
  }

  Widget _buildOiWidget(bool isLeft, String? openInterest, bool showShimmer) {
    return widget.arguments.selectedlist.contains(AppConstants.oi)
        ? Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_2,
              bottom: AppWidgetSize.dimen_2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isLeft)
                  Text(
                    _appLocalizations.oI,
                    style:
                        Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                  ),
                CustomTextWidget(
                  AppUtils().dataNullCheck(openInterest),
                  Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                        color: Theme.of(context)
                            .primaryTextTheme
                            .titleMedium!
                            .color,
                      ),
                  isShowShimmer: showShimmer,
                  shimmerWidth: AppWidgetSize.dimen_50,
                ),
                if (!isLeft)
                  Text(
                    _appLocalizations.oI,
                    style:
                        Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                  ),
              ],
            ),
          )
        : Container();
  }

  Widget _buildOiChngWidget(
      bool isLeft, String? oiChangePer, bool showShimmer) {
    return widget.arguments.selectedlist.contains(AppConstants.oiChng)
        ? Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_2,
              bottom: AppWidgetSize.dimen_2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isLeft)
                  Text(
                    _appLocalizations.oiChg,
                    style:
                        Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                  ),
                CustomTextWidget(
                  AppUtils().dataNullCheckNumeric(oiChangePer),
                  Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                        color: Theme.of(context)
                            .primaryTextTheme
                            .titleMedium!
                            .color,
                      ),
                  isShowShimmer: showShimmer,
                  shimmerWidth: AppWidgetSize.dimen_50,
                ),
                if (!isLeft)
                  Text(
                    _appLocalizations.oiChg,
                    style:
                        Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                  ),
              ],
            ),
          )
        : Container();
  }

  Widget _buildVolWidget(bool isLeft, String? vol, bool showShimmer) {
    return widget.arguments.selectedlist.contains(AppConstants.volume)
        ? Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_2,
              bottom: AppWidgetSize.dimen_2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isLeft)
                  Text(
                    _appLocalizations.vol,
                    style:
                        Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                  ),
                CustomTextWidget(
                  AppUtils().dataNullCheck(vol),
                  Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                        color: Theme.of(context)
                            .primaryTextTheme
                            .titleMedium!
                            .color,
                      ),
                  isShowShimmer: showShimmer,
                  shimmerWidth: AppWidgetSize.dimen_50,
                ),
                if (!isLeft)
                  Text(
                    _appLocalizations.vol,
                    style:
                        Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                  ),
              ],
            ),
          )
        : Container();
  }

  QuoteOptionChainData _getOptionChainData() {
    return QuoteOptionChainData(
      dispSym: widget.arguments.symbol.dispSym,
      sym: widget.arguments.symbol.sym,
      baseSym: widget.arguments.symbol.baseSym,
      expiry: widget.arguments.expiry,
    );
  }
}
