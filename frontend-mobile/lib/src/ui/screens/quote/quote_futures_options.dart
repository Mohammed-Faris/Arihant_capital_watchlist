import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../blocs/quote/futures_option/common_quote/quote_futures_options_bloc.dart';
import '../../../constants/app_events.dart';
import '../../../constants/keys/search_keys.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/quote/quote_expiry/quote_expiry.dart';
import '../../../models/quote/quote_futures/quote_future_expiry_data.dart';
import '../../../models/quote/quote_options/quote_option_chain_data.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/circular_toggle_button_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/fandotag.dart';
import '../../widgets/label_border_text_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/technicalspivotstrategychart/toggle_circular_tabborder_widget.dart';
import '../base/base_screen.dart';
import 'widgets/measurebox.dart';

class QuoteFutureOptions extends BaseScreen {
  final dynamic arguments;
  const QuoteFutureOptions({Key? key, this.arguments}) : super(key: key);

  @override
  State<QuoteFutureOptions> createState() => QuoteFutureOptionsState();
}

class QuoteFutureOptionsState extends BaseAuthScreenState<QuoteFutureOptions>
    with TickerProviderStateMixin {
  late Symbols _symbols;
  late QuoteFuturesOptionsBloc _quoteFuturesOptionsBloc;
  ValueNotifier<bool> isScrolledToTop = ValueNotifier<bool>(false);

  late QuoteExpiry _quoteExpiry;

  bool toggleFutures = true;
  bool toggleOptions = false;
  final ValueNotifier<int> expiryPosition = ValueNotifier<int>(0);

  late List<Filters>? _filters;
  late AppLocalizations _appLocalizations;
  int selectedOrderStatusIndex = 0;
  TabController? tabController;
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _symbols = widget.arguments['symbolItem'];
    _symbols.sym!.baseSym = _symbols.baseSym;
    tabController = TabController(
        length: 2, initialIndex: selectedIndex.value, vsync: this);
    tabController?.addListener(() {
      selectedIndex.value = tabController?.index ?? 0;
      onfirstScroll = true;
    });

    _quoteFuturesOptionsBloc = BlocProvider.of<QuoteFuturesOptionsBloc>(context)
      ..add((QuoteToggleFuturesEvent()));
    _quoteFuturesOptionsBloc = BlocProvider.of<QuoteFuturesOptionsBloc>(context)
      ..stream.listen(_quoteFuturesOptionsListener);
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.quoteFuturesOptions);
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.quoteFuturesOptions;
  }

  @override
  void quote1responseCallback(ResponseData data) {
    _quoteFuturesOptionsBloc.add(QuoteFutureStreamingResponseEvent(data));
    _quoteFuturesOptionsBloc.add(QuoteOptionChainStreamingResponseEvent(data));
  }

  Future<void> _quoteFuturesOptionsListener(
      QuoteFuturesOptionsState state) async {
    if (state is QuoteFuturesOptionsProgressState) {}
    if (state is QuoteFuturesDoneState) {
      // subscribeLevel1(state.quoteFuturesModel);
    } else if (state is QuoteOptionsDoneState) {
    } else if (state is QuoteFuturesOptionsFailedState) {
      // if (state.isInvalidException) {
      //   handleError(state);
      // }
    } else if (state is QuoteFuturesOptionsErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state is QuoteFutureExcChangeState) {
      unsubscribeLevel1();
      _symbols = state.symbolItem;
      postSetState();
    } else if (state is QuoteOptionExcChangeState) {
      unsubscribeLevel1();
      _symbols = state.symbolItem;
      postSetState();
    } else if (state is QuoteFutureStreamState) {
      subscribeLevel1(state.streamDetails);
      postSetState();
    } else if (state is QuoteOptionChainSymStreamState) {
      subscribeLevel1(state.streamDetails);
      postSetState();
    }
  }

  void postSetState({Function()? function}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          if (function != null) {
            function();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFuturesOptionsToggleWidget(),
          Expanded(
            child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: tabController,
                children: [
                  buildQuotesFuturesToggleBlocBuilder(),
                  buildQuotesOptionsToggleBlocBuilder()
                ]),
          )
        ],
      ),
      /*  bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: selectedIndex,
          builder: (context, value, _) {
            return value == 0
                ? needHelp()
                : Container(
                    height: 0,
                  );
          },
        )  */ //on Tap need help need to be implemented
    );
  }

  needHelp() {
    return Padding(
      padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: AppWidgetSize.dimen_120,
            height: AppWidgetSize.dimen_30,
            child: LabelBorderWidget(
              keyText: const Key("NeedHelp"),
              text: _appLocalizations.generalNeedHelp,
              textColor: Theme.of(context).primaryColor,
              fontSize: AppWidgetSize.fontSize14,
              margin: EdgeInsets.only(
                top: AppWidgetSize.dimen_6,
                right: AppWidgetSize.dimen_5,
              ),
              borderRadius: AppWidgetSize.dimen_24,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              borderWidth: 1,
              borderColor: Theme.of(context).dividerColor,
              isSelectable: false,
              textAlign: TextAlign.center,
              labelTapAction: () async {},
            ),
          ),
        ],
      ),
    );
  }

  BlocBuilder<QuoteFuturesOptionsBloc, QuoteFuturesOptionsState>
      buildQuotesFuturesToggleBlocBuilder() {
    return BlocBuilder<QuoteFuturesOptionsBloc, QuoteFuturesOptionsState>(
      bloc: _quoteFuturesOptionsBloc,
      buildWhen: (previous, current) {
        return current is QuoteFuturesOptionsFailedState ||
            current is QuoteFuturesOptionsServiceException ||
            current is QuoteExpiryDoneState ||
            current is QuoteToggleFuturesState ||
            current is QuoteToggleOptionsState ||
            current is QuoteFuturesDoneState;
      },
      builder: (context, state) {
        if (state is QuoteFuturesOptionsFailedState) {
          return errorWithImageWidget(
            context: context,
            imageWidget: AppImages.noDataAction(context),
            errorMessage: state.errorMsg,
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
              bottom: AppWidgetSize.dimen_30,
            ),
          );
        } else if (state is QuoteFuturesOptionsServiceException) {
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
        } else if (state is QuoteToggleFuturesState) {
          _quoteFuturesOptionsBloc
              .add(QuoteFuturesExpiryEvent(_getFutureExpiryData()));
        } else if (state is QuoteToggleOptionsState) {
          _quoteFuturesOptionsBloc
              .add(QuoteExpiryDataEvent(_getQuoteExpiryData()));
        } else if (state is QuoteFuturesDoneState) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppWidgetSize.dimen_30),
            child: buildQuotesListView(state.quoteFuturesModel!.results!),
          );
        } else if (state is QuoteExpiryDoneState) {
          _quoteExpiry = state.quoteExpiry!;
          _quoteFuturesOptionsBloc.add(QuoteOptionsChainEvent(
            _getOptionChainData(_quoteExpiry, expiryPosition.value),
            false,
          ));
        }

        return const LoaderWidget();
      },
    );
  }

  BlocBuilder<QuoteFuturesOptionsBloc, QuoteFuturesOptionsState>
      buildQuotesOptionsToggleBlocBuilder() {
    return BlocBuilder<QuoteFuturesOptionsBloc, QuoteFuturesOptionsState>(
      bloc: _quoteFuturesOptionsBloc,
      buildWhen: (previous, current) {
        return current is QuoteFuturesOptionsFailedState ||
            current is QuoteFuturesOptionsServiceException ||
            current is QuoteExpiryDoneState ||
            current is QuoteOptionsDoneState ||
            current is QuoteToggleFuturesState ||
            current is QuoteToggleOptionsState;
      },
      builder: (context, state) {
        if (state is QuoteFuturesOptionsFailedState) {
          return errorWithImageWidget(
            context: context,
            imageWidget: AppImages.noDataAction(context),
            errorMessage: state.errorMsg,
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
              bottom: AppWidgetSize.dimen_30,
            ),
          );
        } else if (state is QuoteFuturesOptionsServiceException) {
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
        } else if (state is QuoteToggleFuturesState) {
          _quoteFuturesOptionsBloc
              .add(QuoteFuturesExpiryEvent(_getFutureExpiryData()));
        } else if (state is QuoteToggleOptionsState) {
          _quoteFuturesOptionsBloc
              .add(QuoteExpiryDataEvent(_getQuoteExpiryData()));
        } else if (state is QuoteExpiryDoneState) {
          _quoteExpiry = state.quoteExpiry!;
          _quoteFuturesOptionsBloc.add(QuoteOptionsChainEvent(
            _getOptionChainData(_quoteExpiry, expiryPosition.value),
            false,
          ));
        } else if (state is QuoteOptionsDoneState) {
          List<Symbols> callList = state.optionQuoteModel!.results!.call!;
          List<Symbols> putList = state.optionQuoteModel!.results!.put!;
          List<Symbols> spotList = state.optionQuoteModel!.results!.spot!;
          List<Symbols> symbolList = [];

          int lengthValue = callList.length > putList.length
              ? callList.length
              : putList.length;
          String strikeVal = (spotList.isNotEmpty)
              ? (spotList.toList().first.ltp ?? "0")
              : "0";

          for (int i = 0; i < lengthValue; i++) {
            if (callList.length >= putList.length) {
              symbolList.add(callList[i]);
              if (putList.indexWhere((element) =>
                      element.sym?.strike == callList[i].sym?.strike) !=
                  -1) {
                symbolList.add(putList[putList.indexWhere((element) =>
                    element.sym?.strike == callList[i].sym?.strike)]);
              }
            } else {
              symbolList.add(putList[i]);
              if (callList.indexWhere((element) =>
                      element.sym?.strike == putList[i].sym?.strike) !=
                  -1) {
                symbolList.add(callList[callList.indexWhere((element) =>
                    element.sym?.strike == putList[i].sym?.strike)]);
              }
            }
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
                if (onfirstScroll) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.animateTo(
                        ((height *
                                    symbolList.indexWhere((element) =>
                                        AppUtils()
                                            .doubleValue(element.sym?.strike) ==
                                        (AppUtils().doubleValue((callList
                                                        .length >
                                                    putList.length
                                                ? callList[i + 1].sym!.strike
                                                : putList[i + 1].sym!.strike) ??
                                            "0")))) -
                                2)
                            .toDouble(),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInExpo);
                  });
                  onfirstScroll = false;
                }
              }
            } catch (e) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.animateTo(
                    ((height *
                                symbolList.indexWhere((element) =>
                                    AppUtils()
                                        .doubleValue(element.sym?.strike) ==
                                    (AppUtils().doubleValue(
                                        (callList.length > putList.length
                                                ? callList[i].sym!.strike
                                                : putList[i].sym!.strike) ??
                                            "0")))) -
                            2)
                        .toDouble(),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInExpo);
              });
            }
            /*  else if (i + 1 == lengthValue) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.animateTo(
                    ((height *
                                symbolList.indexWhere((element) =>
                                    AppUtils()
                                        .doubleValue(element.sym?.strike) ==
                                    (AppUtils().doubleValue(
                                        (callList.length > putList.length
                                                ? callList[i].sym!.strike
                                                : putList[i].sym!.strike) ??
                                            "0")))) -
                            2)
                        .toDouble(),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInExpo);
              });
            } */
          }
          return buildOptionsToggleView(context, symbolList);
        }

        return const LoaderWidget();
      },
    );
  }

  bool onfirstScroll = true;

  Column buildOptionsToggleView(
    BuildContext context,
    List<Symbols> symbols,
  ) {
    return Column(
      children: [
        buildExpiryList(context),
        BlocBuilder<QuoteFuturesOptionsBloc, QuoteFuturesOptionsState>(
          builder: (context, state) {
            if (state is QuoteOptionsDoneState) {
              return buildOptionList(symbols);
            } else {
              return const Expanded(child: LoaderWidget());
            }
          },
        ),
      ],
    );
  }

  double height = 0;
  final ScrollController controller = ScrollController();
  final bool onFirstScroll = true;
  Expanded buildOptionList(List<Symbols> symbols) {
    return Expanded(
      child: ListView.separated(
          controller: controller,
          separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Theme.of(context).dividerColor,
                thickness: AppWidgetSize.dimen_1,
                indent: AppWidgetSize.dimen_30,
                endIndent: AppWidgetSize.dimen_30,
              ),
          // key: Key(FUTURES_LIST),
          itemBuilder: (BuildContext context, dynamic index) {
            return MeasureSize(
                onChange: (size) {
                  if (size.height > 0) {
                    height = size.height;
                  }
                },
                child: _buildFutureRow(
                  context,
                  symbols[index],
                  index,
                ));
          },
          itemCount: symbols.length),
    );
  }

  Padding buildExpiryList(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0, left: 0, top: 5, bottom: 10),
      child: SizedBox(
        height: AppWidgetSize.dimen_40,
        //width: AppWidgetSize.fullHeight(context) / 2.1,
        child: ValueListenableBuilder<int>(
          valueListenable: expiryPosition,
          builder: (context, value, child) => ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _quoteExpiry.results!.length,
            itemBuilder: (BuildContext context, dynamic index) {
              return CircularButtonToggleWidget(
                value: _quoteExpiry.results![expiryPosition.value],
                toggleButtonlist: [_quoteExpiry.results![index]],
                toggleButtonOnChanged: toggleButtonOnChanged,
                key: const Key(filters_),
                defaultSelected: '',
                enabledButtonlist: const [],
                marginEdgeInsets: buildMarginEdgeInsets(),
                //pfingEdgeInsets: buildPaddingEdgeInsets(),
                inactiveButtonColor: Colors.transparent,
                activeButtonColor: Theme.of(context)
                    .snackBarTheme
                    .backgroundColor!
                    .withOpacity(0.5),
                inactiveTextColor: Theme.of(context).primaryColor,
                activeTextColor: Theme.of(context).primaryColor,
                isBorder: false,
                context: context,
                borderColor: Colors.transparent,
                paddingEdgeInsets: EdgeInsets.fromLTRB(
                  AppWidgetSize.dimen_14,
                  AppWidgetSize.dimen_3,
                  AppWidgetSize.dimen_14,
                  AppWidgetSize.dimen_3,
                ),

                fontSize: 18.w,
              );
            },
          ),
        ),
      ),
    );
  }

  ListView buildQuotesListView(List<Symbols> symbols) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(context).dividerColor,
        thickness: AppWidgetSize.dimen_1,
        indent: AppWidgetSize.dimen_30,
        endIndent: AppWidgetSize.dimen_30,
      ),
      itemBuilder: (BuildContext context, dynamic index) {
        return _buildFutureRow(
          context,
          symbols[index],
          index,
        );
      },
      itemCount: symbols.length,
    );
  }

  FutureExpiryData _getFutureExpiryData() {
    _filters = <Filters>[Filters(key: 'segment', value: 'FUT')];
    return FutureExpiryData(
        dispSym: _symbols.dispSym,
        sym: _symbols.sym,
        companyName: _symbols.companyName,
        baseSym: _symbols.baseSym,
        filters: _filters);
  }

  QuoteOptionChainData _getOptionChainData(
      QuoteExpiry quoteExpiry, int expiryPosition) {
    return QuoteOptionChainData(
        dispSym: _symbols.dispSym,
        sym: _symbols.sym,
        baseSym: _symbols.baseSym,
        expiry: quoteExpiry.results![expiryPosition]);
  }

  FutureExpiryData _getQuoteExpiryData() {
    _filters = <Filters>[
      Filters(key: 'segment', value: 'opt'),
      Filters(key: 'optionType', value: 'CE')
    ];
    return FutureExpiryData(
        dispSym: _symbols.dispSym,
        sym: _symbols.sym,
        companyName: _symbols.companyName,
        baseSym: _symbols.baseSym,
        filters: _filters);
  }

  int intialIndex = 0;
  Widget _buildFuturesOptionsToggleWidget() {
    _appLocalizations = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_15,
      ),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20)),
        child: Padding(
          padding: EdgeInsets.all(AppWidgetSize.dimen_2),
          child: ToggleCircularTabMWidget(
            tabController: tabController!,
            key: const Key(''),
            height: AppWidgetSize.dimen_36,
            minWidth: AppWidgetSize.dimen_150,
            cornerRadius: AppWidgetSize.dimen_20,
            labels: <String>[
              _appLocalizations.futures,
              _appLocalizations.options
            ],
            initialLabel: intialIndex,
            onToggle: (int selectedTabValue) {
              sendEventToFirebaseAnalytics(
                  AppEvents.fandoToggle,
                  ScreenRoutes.quoteFuturesOptions,
                  'Clicked ${<String>[
                    _appLocalizations.futures,
                    _appLocalizations.options
                  ][selectedTabValue]} button in toggle',
                  key: "symbol",
                  value: _symbols.dispSym);

              intialIndex = selectedTabValue;

              if (selectedTabValue == 0) {
                toggleFutures = true;
                toggleOptions = false;

                _quoteFuturesOptionsBloc.add((QuoteToggleFuturesEvent()));
              } else {
                unsubscribeLevel1();
                toggleOptions = true;
                toggleFutures = false;
                _quoteFuturesOptionsBloc.add((QuoteToggleOptionsEvent()));
              }
              tabController?.animateTo(selectedTabValue);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFutureRow(
    BuildContext context,
    Symbols? symbol,
    index,
  ) {
    return GestureDetector(
      onTap: () {
        // if (toggleFutures) {
        //   _futureSymbolItem?.dispSym = _futureResults[index].dispSym;
        //   _futureSymbolItem?.baseSym = _futureResults[index].baseSym;
        // } else {
        //   _futureSymbolItem?.dispSym = _optionResults[index].dispSym;
        //   _futureSymbolItem?.baseSym = _optionResults[index].baseSym;
        // }

        pushNavigation(ScreenRoutes.quoteScreen, arguments: {
          'symbolItem': symbol,
        });
      },
      child: Container(
        // width: AppWidgetSize.fullWidth(context) - 15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_10),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_10,
            bottom: AppWidgetSize.dimen_10,
            left: AppWidgetSize.dimen_23,
            right: AppWidgetSize.dimen_23),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLeftRowWidget(symbol, index, context),
            _buildRightRowWidget(symbol!, index, context),
          ],
        ),
      ),
    );
  }

  // Widget _buildAppBarLeftWidget() {
  //   return Row(
  //     children: [
  //       backIconButton(
  //           onTap: () {
  //             StreamingManager()
  //                 .unsubscribeLevel1(getScreenRoute()); //needs to check
  //             popNavigation();
  //           },
  //           customColor: Theme.of(context).textTheme.headline2!.color),
  //       ValueListenableBuilder<bool>(
  //         valueListenable: isScrolledToTop,
  //         builder: (context, value, _) {
  //           if (isScrolledToTop.value) {
  //             return _buildQuoteStreamingContent(true);
  //           } else {
  //             return Container();
  //           }
  //         },
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildQuoteStreamingContent(bool isAppBar) {
  //   return BlocBuilder<QuoteFuturesOptionsBloc, QuoteFuturesOptionsState>(
  //       buildWhen: (QuoteFuturesOptionsState previous,
  //           QuoteFuturesOptionsState current) {
  //     return current is QuoteOptionsDoneState;
  //   }, builder: (context, state) {
  //     if (state is QuoteOptionsDoneState) {
  //       // _buildLeftRowWidget();
  //     }
  //     return Container();
  //   });
  // }

  Widget _buildLeftRowWidget(
    Symbols? symbolItem,
    int index,
    BuildContext context,
  ) {
    return SizedBox(
      width: AppWidgetSize.fullWidth(context) / 2 + AppWidgetSize.dimen_10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: symbolItem?.sym?.optionType != null
                  ? '${symbolItem?.baseSym} '
                  : AppUtils().dataNullCheck(symbolItem?.dispSym),
              style: Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          _buildCompanyNameWidget(symbolItem!, index, context),
        ],
      ),
    );
  }

  Widget _buildCompanyNameWidget(
    Symbols symbolItem,
    int index,
    BuildContext context,
  ) {
    return Row(
      children: [
        Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_10,
              right: AppWidgetSize.dimen_5,
            ),
            child: FandOTag(symbolItem)),
      ],
    );
  }

  Widget _buildRightRowWidget(
    Symbols symbolItem,
    int index,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CustomTextWidget(
          AppUtils().dataNullCheck(symbolItem.ltp),
          Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                fontWeight: FontWeight.w600,
                color: AppUtils().setcolorForChange(
                    AppUtils().dataNullCheck(symbolItem.chng)),
              ),
          isShowShimmer: true,
        ),
        Padding(
          padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_5,
          ),
          child: CustomTextWidget(
            AppUtils().getChangePercentage(symbolItem),
            Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  color:
                      Theme.of(context).inputDecorationTheme.labelStyle!.color,
                ),
            isShowShimmer: true,
            shimmerWidth: AppWidgetSize.dimen_80,
          ),
        ),
      ],
    );
  }

  int toggleButtonOnChanged(String name) {
    onfirstScroll = true;
    expiryPosition.value =
        _quoteExpiry.results?.indexOf(name) ?? expiryPosition.value;
    _quoteFuturesOptionsBloc.add(QuoteOptionsChainEvent(
      _getOptionChainData(_quoteExpiry, expiryPosition.value),
      false,
    ));
    return expiryPosition.value;
  }

  EdgeInsets buildPaddingEdgeInsets() {
    return EdgeInsets.all(
      AppWidgetSize.dimen_6,
    );
  }

  EdgeInsets buildMarginEdgeInsets() {
    return EdgeInsets.all(AppWidgetSize.dimen_9);
  }
}
