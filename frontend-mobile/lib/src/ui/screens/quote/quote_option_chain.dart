import 'package:acml/src/constants/app_events.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../blocs/quote/futures_option/common_quote/quote_futures_options_bloc.dart';
import '../../../blocs/quote/main_quote/quote_bloc.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/keys/quote_keys.dart';
import '../../../data/store/app_store.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/quote/quote_futures/quote_future_expiry_data.dart';
import '../../../models/quote/quote_options/quote_option_chain_data.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/label_border_text_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/webview_widget.dart';
import '../base/base_screen.dart';
import '../route_generator.dart';
import 'widgets/option_chain_widget.dart';

class QuoteOptionChain extends BaseScreen {
  final dynamic arguments;

  const QuoteOptionChain({
    Key? key,
    this.arguments,
  }) : super(key: key);

  @override
  QuoteOptionChainState createState() => QuoteOptionChainState();
}

class QuoteOptionChainState extends BaseAuthScreenState<QuoteOptionChain>
    with TickerProviderStateMixin {
  late QuoteBloc quoteBloc;
  late QuoteFuturesOptionsBloc quoteFuturesOptionsBloc;
  late AppLocalizations _appLocalizations;
  ValueNotifier<int> tabIndex = ValueNotifier<int>(0);
  late Symbols symbols;
  List<Map<String, dynamic>> tabs = [];
  TabController? tabController;
  List<String> expiryList = [];
  ValueNotifier<bool> ishighEnabled = ValueNotifier<bool>(true);
  ValueNotifier<bool> isLowEnabled = ValueNotifier<bool>(false);
  ValueNotifier<bool> isUpDownEnabled = ValueNotifier<bool>(false);
  ValueNotifier<bool> isSameEnabled = ValueNotifier<bool>(false);

  @override
  void initState() {
    symbols = widget.arguments['symbolItem'];
    quoteBloc = BlocProvider.of<QuoteBloc>(context)
      ..stream.listen(quoteListener);

    quoteFuturesOptionsBloc = BlocProvider.of<QuoteFuturesOptionsBloc>(context)
      ..add(
        QuoteExpiryDataEvent(_getQuoteExpiryData()),
      );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setTabController(0);

      callStreaming();
    });
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.quoteOptionChain);
  }

  void setTabController(int position) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tabIndex.value = position;
    });
  }

  void callStreaming() {
    quoteBloc.add(QuoteStartSymStreamEvent(symbols));
  }

  Future<void> quoteListener(QuoteState state) async {
    if (state is QuoteSymStreamState) {
      subscribeLevel1(state.streamDetails);
    } else if (state is QuoteErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.quoteOptionChain;
  }

  @override
  void quote1responseCallback(ResponseData data) {
    quoteBloc.add(QuoteStreamingResponseEvent(data));
  }

  bool firstTime = true;
  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Scaffold(
          appBar: _buildAppBar(),
          body: BlocBuilder<QuoteFuturesOptionsBloc, QuoteFuturesOptionsState>(
            buildWhen: (previous, current) {
              return current is QuoteExpiryDoneState ||
                  current is QuoteFuturesOptionsServiceException ||
                  current is QuoteFuturesOptionsFailedState;
            },
            builder: (context, state) {
              if (state is! QuoteFuturesOptionsProgressState) {
                const LoaderWidget();
              }

              if (state is QuoteExpiryDoneState) {
                expiryList = [];
                expiryList.addAll(state.quoteExpiry!.results!);
                tabs = _getTabList();
                tabController = TabController(vsync: this, length: tabs.length);
                setTabController(tabIndex.value);
                if (tabController != null) {
                  tabController?.addListener(() {
                    if (tabIndex.value != tabController?.index &&
                        tabController?.index != 0) {
                      quoteFuturesOptionsBloc.add(QuoteOptionsChainEvent(
                        _getOptionChainData(),
                        true,
                      ));
                    }
                    tabIndex.value = tabController?.index ?? 0;
                  });
                  tabController?.index = tabIndex.value;
                  if (firstTime) {
                    if (expiryList
                        .where((element) => element == symbols.sym?.expiry)
                        .toList()
                        .isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        tabController?.animateTo(
                            expiryList.indexOf(symbols.sym!.expiry!) + 1);
                      });
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        tabController?.animateTo(1);
                      });
                    }

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      firstTime = false;
                      tabIndex.value = 1;
                    });
                  }
                }
                if (tabs.isEmpty) {
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
                } else {
                  return _buildBodyBottomContent();
                }
              }
              if (state is QuoteFuturesOptionsServiceException ||
                  state is QuoteFuturesOptionsFailedState) {
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
              return const LoaderWidget();
            },
          ),
        ),
      ),
    );
  }

  QuoteOptionChainData _getOptionChainData() {
    return QuoteOptionChainData(
      dispSym: symbols.dispSym,
      sym: symbols.sym,
      baseSym: symbols.baseSym,
      expiry: expiryList[tabController!.index - 1],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      toolbarHeight: AppWidgetSize.dimen_60,
      elevation: 0.0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: Container(
        height: AppWidgetSize.fullWidth(context),
        width: AppWidgetSize.fullWidth(context),
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_10,
          right: AppWidgetSize.dimen_10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      unsubscribeLevel1();
                      Navigator.of(context).pop();
                    },
                    child: AppImages.backButtonIcon(context,
                        color:
                            Theme.of(context).textTheme.displayMedium!.color)),
                Padding(
                  padding: EdgeInsets.only(left: AppWidgetSize.dimen_15),
                  child: _buildAppBarLeftWidget(),
                ),
              ],
            ),
            ValueListenableBuilder<int>(
                valueListenable: tabIndex,
                builder: (context, value, _) {
                  return value == 0
                      ? Container()
                      : GestureDetector(
                          onTap: () {
                            quoteFuturesOptionsBloc
                                .add(QuoteOptionChainGetFilterListEvent());

                            showSettingsSheet();
                          },
                          child: SizedBox(
                            width: AppWidgetSize.dimen_30,
                            height: AppWidgetSize.dimen_22,
                            child: Stack(
                              children: [
                                AppImages.settingsDisable(context,
                                    color: Theme.of(context)
                                        .primaryIconTheme
                                        .color,
                                    isColor: true,
                                    height: 20.w,
                                    width: 20.w),
                                selectedFilterList != null &&
                                        selectedFilterList!.isNotEmpty
                                    ? _buildSortSelectedDot()
                                    : Container()
                              ],
                            ),
                          ));
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildSortSelectedDot() {
    return Positioned(
      left: AppWidgetSize.dimen_12,
      child: Container(
        width: AppWidgetSize.dimen_8,
        height: AppWidgetSize.dimen_8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.w),
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Future<void> showSettingsSheet() async {
    backUpFilterList = List.from(selectedFilterList!);
    selectedFilters = selectedFilterList; //List.from(selectedFilterList!);
    if (selectedFilterList?.isEmpty ?? false) clearButtonClicked(load: false);
    showInfoBottomsheet(
            BlocProvider<QuoteFuturesOptionsBloc>.value(
              value: QuoteFuturesOptionsBloc(),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter updateState) {
                  return SafeArea(
                    child: _buildSettingsSheetWidget(
                      updateState,
                    ),
                  );
                },
              ),
            ),
            horizontalMargin: false)
        .then((value) {
      selectedFilters = [];
      quoteFuturesOptionsBloc.add(QuoteOptionChainStartSymStreamEvent());
    });
  }

  Widget _buildSettingsSheetWidget(
    StateSetter updateState,
  ) {
    return Container(
      height: AppWidgetSize.dimen_350,
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
      ),
      child: Wrap(
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
              bottom: AppWidgetSize.dimen_10,
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CustomTextWidget(
                  _appLocalizations.settings,
                  Theme.of(context).textTheme.displayMedium,
                ),
                GestureDetector(
                  onTap: () {
                    selectedFilters = backUpFilterList;
                    selectedFilterList = backUpFilterList;
                    quoteFuturesOptionsBloc.add(
                        QuoteOptionChainUpdateFilterListEvent(selectedFilters));
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
          _buildSettingsListView(
            updateState,
          ),
          _buildPersistentFooterButton(updateState),
        ],
      ),
    );
  }

  Widget _buildSettingsListView(
    StateSetter updateState,
  ) {
    return Container(
      width: AppWidgetSize.fullWidth(context),
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
        top: AppWidgetSize.dimen_8,
        bottom: AppWidgetSize.dimen_10,
      ),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        primary: false,
        shrinkWrap: true,
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            thickness: AppWidgetSize.dimen_1,
            color: Theme.of(context).dividerColor,
          );
        },
        itemCount: _settingsDataMap.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return _buildSettingsRowWidget(
            _settingsDataMap.elementAt(index),
            updateState,
          );
        },
      ),
    );
  }

  Widget _buildSettingsRowWidget(
    String title,
    StateSetter updateState,
  ) {
    return GestureDetector(
      onTap: () {
        if (selectedFilters != null) {
          if (selectedFilters!.contains(
              _settingsDataMap.elementAt(_settingsDataMap.indexOf(title)))) {
            // already is there in filter then remove
            if (title == AppConstants.all) {
              selectedFilters!.remove(AppConstants.all);
              selectedFilters!.remove(AppConstants.oi);
              selectedFilters!.remove(AppConstants.oiChng);
              selectedFilters!.remove(AppConstants.volume);
            } else {
              selectedFilters!.remove(AppConstants.all);
              selectedFilters!.remove(
                  _settingsDataMap.elementAt(_settingsDataMap.indexOf(title)));
            }
          } else {
            //newvalue so add in filter
            if (title == AppConstants.all) {
              //if selected is all
              selectedFilters!.removeRange(0, selectedFilters!.length);
              selectedFilters!.add(AppConstants.all);
              selectedFilters!.add(AppConstants.oi);
              selectedFilters!.add(AppConstants.oiChng);
              selectedFilters!.add(AppConstants.volume);
            } else {
              selectedFilters!.add(
                  _settingsDataMap.elementAt(_settingsDataMap.indexOf(title)));
            }
            if (selectedFilters!.contains(AppConstants.oi) &&
                selectedFilters!.contains(AppConstants.oiChng) &&
                selectedFilters!.contains(AppConstants.volume) &&
                !selectedFilters!.contains(AppConstants.all)) {
              selectedFilters!.add(AppConstants.all);
            }
          }
        }

        updateState(() {});
      },
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_5,
                bottom: AppWidgetSize.dimen_5,
              ),
              child: CustomTextWidget(
                title,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
            if (selectedFilters != null &&
                selectedFilters!.contains(_settingsDataMap
                    .elementAt(_settingsDataMap.indexOf(title))))
              _buildSelectedFilterIcon()
            else
              _buildUnSelectedFilterIcon()
          ],
        ),
      ),
    );
  }

  Widget _buildUnSelectedFilterIcon() {
    return Container(
      width: AppWidgetSize.dimen_18,
      height: AppWidgetSize.dimen_18,
      padding: EdgeInsets.only(right: AppWidgetSize.dimen_10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.w),
        border: Border.all(
          color: Theme.of(context).primaryTextTheme.titleMedium!.color!,
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  Widget _buildSelectedFilterIcon() {
    return AppImages.filterSelectedIcon(
      context,
      width: AppWidgetSize.dimen_23,
      height: AppWidgetSize.dimen_23,
    );
  }

  Widget _buildPersistentFooterButton(StateSetter updateState) {
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
        top: AppWidgetSize.dimen_20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          gradientButtonWidget(
            onTap: () {
              if (selectedFilters != null && selectedFilters!.isNotEmpty) {
                selectedFilters!.removeRange(0, selectedFilters!.length);
              }
              updateState(() {});
              clearButtonClicked();
            },
            width: AppWidgetSize.fullWidth(context) / 2.5,
            key: const Key(quoteOptionSortClearButtonKey),
            context: context,
            title: _appLocalizations.clear,
            isGradient: false,
            isErrorButton: true,
          ),
          gradientButtonWidget(
            onTap: () {
              doneButtonClicked();
              Navigator.of(context).pop();
            },
            width: AppWidgetSize.fullWidth(context) / 2.5,
            key: const Key(quoteOptionSortDoneButtonKey),
            context: context,
            title: _appLocalizations.done,
            isGradient: true,
          ),
        ],
      ),
    );
  }

  void doneButtonClicked() {
    setState(() {
      selectedFilterList = selectedFilters;
    });
    setState(() {
      loading = true;
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        loading = false;
      });
    });
  }

  bool loading = false;
  void clearButtonClicked({bool load = true}) {
    setState(() {
      selectedFilters = [];
    });
    if (load) {
      setState(() {
        loading = true;
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        setState(() {
          loading = false;
        });
      });
    }
  }

  static List<String> _getSortDataSet() {
    return <String>[
      AppConstants.all,
      AppConstants.oi,
      AppConstants.oiChng,
      AppConstants.volume,
    ];
  }

  final List<String> _settingsDataMap = _getSortDataSet();
  List<String>? selectedFilters = <String>[];
  List<String>? selectedFilterList = <String>[];
  List<String>? backUpFilterList = <String>[];

  Widget _buildAppBarLeftWidget() {
    return BlocBuilder<QuoteBloc, QuoteState>(buildWhen: (previous, current) {
      return current is QuoteSymbolItemState;
    }, builder: (context, state) {
      if (state is QuoteSymbolItemState) {
        return _buildAppBarStreamingContent();
      }
      return Container();
    });
  }

  Widget _buildAppBarStreamingContent() {
    Color backGroundColor = AppStore.themeType == AppConstants.lightMode
        ? const Color(0xFFF2F2F2)
        : const Color(0xFF282F35);
    Color textColor = AppStore.themeType == AppConstants.lightMode
        ? const Color(0xFF797979)
        : const Color(0xFFFFFFFF);
    return SizedBox(
      height: AppWidgetSize.dimen_45,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CustomTextWidget(
                  symbols.dispSym!,
                  Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (symbols.sym?.exc == AppConstants.bse &&
                    symbols.sym?.instrument != AppConstants.idx)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 4),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: LabelBorderWidget(
                        text: AppUtils().dataNullCheck(AppConstants.nse),
                        textColor: textColor,
                        backgroundColor: backGroundColor,
                        borderColor: backGroundColor,
                        fontSize: AppWidgetSize.fontSize10,
                        margin: EdgeInsets.all(AppWidgetSize.dimen_1),
                      ),
                    ),
                  )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextWidget(
                  AppUtils().dataNullCheck(symbols.ltp),
                  Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppUtils().setcolorForChange(
                            AppUtils().dataNullCheck(symbols.chng)),
                      ),
                  isShowShimmer: true,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_5,
                  ),
                  child: CustomTextWidget(
                    AppUtils().getChangePercentage(symbols),
                    Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                          color: Theme.of(context)
                              .inputDecorationTheme
                              .labelStyle!
                              .color,
                        ),
                    isShowShimmer: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyBottomContent() {
    return Column(
      children: <Widget>[
        _buildTabListWidget(),
      ],
    );
  }

  Widget _buildTabListWidget() {
    return Expanded(
      child: DefaultTabController(
        key: widget.key,
        length: tabs.length,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            toolbarHeight: AppWidgetSize.dimen_40,
            automaticallyImplyLeading: false,
            elevation: 2,
            shadowColor: Theme.of(context).inputDecorationTheme.fillColor,
            flexibleSpace: Container(
              padding: EdgeInsets.only(left: 20.w),
              alignment: Alignment.bottomLeft,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: TabBar(
                controller: tabController,
                key: const Key(quoteOptionChainTabViewControllerKey),
                isScrollable: true,
                indicatorColor: isLowEnabled.value
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).primaryColor,
                indicatorWeight: AppWidgetSize.dimen_2,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: Theme.of(context).primaryTextTheme.headlineSmall,
                labelColor: isLowEnabled.value
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).primaryTextTheme.headlineMedium!.color,
                unselectedLabelStyle: Theme.of(context).textTheme.labelSmall,
                unselectedLabelColor:
                    Theme.of(context).textTheme.labelLarge!.color,
                tabs: List.generate(tabs.length,
                    (index) => _buildTabBarTitleView(tabs[index])).toList(),
                onTap: (value) {
                  isLowEnabled.value = false;
                  isSameEnabled.value = false;
                  isUpDownEnabled.value = false;
                  ishighEnabled.value = true;
                },
              ),
            ),
          ),
          body: TabBarView(
            controller: tabController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: List.generate(
                tabs.length,
                (index) => (loading && index == tabIndex.value)
                    ? const LoaderWidget()
                    : _buildTabBarBodyView(tabs[index])).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarTitleView(Map<String, dynamic> item) {
    return Tab(
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              item['title'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarBodyView(Map<String, dynamic> item) {
    return item['view'];
  }

  List<Map<String, dynamic>> _getTabList() {
    List<Map<String, dynamic>> tabList = <Map<String, dynamic>>[
      <String, dynamic>{
        'title': _appLocalizations.discovery,
        'view': _buildDiscoverWidget(),
      },
    ];

    return tabList + _getExpiryTabs();
  }

  List<Map<String, dynamic>> _getExpiryTabs() {
    Map<String, dynamic> obj = <String, dynamic>{};

    final List<Map<String, dynamic>> returnList = <Map<String, dynamic>>[];

    for (final String tabTitle in expiryList) {
      obj = <String, dynamic>{
        'title': tabTitle,
        'view': OptionChainWidget(
          OptionChainWidgetArgs(
            selectedFilterList ?? [],
            symbols,
            tabTitle,
          ),
        )
      };
      returnList.add(obj);
    }
    return returnList;
  }

  Widget _buildDiscoverWidget() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_20,
              right: AppWidgetSize.dimen_60,
              left: AppWidgetSize.dimen_60,
              bottom: AppWidgetSize.dimen_40,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: ishighEnabled,
                  builder: (context, value, _) {
                    return GestureDetector(
                      onTap: () {
                        ishighEnabled.value = true;
                        isLowEnabled.value = false;
                        isUpDownEnabled.value = false;
                        isSameEnabled.value = false;
                      },
                      child: SizedBox(
                          child: ishighEnabled.value
                              ? AppImages.highEnable(context)
                              : AppImages.highDisable(context)),
                    );
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: isLowEnabled,
                  builder: (context, value, _) {
                    return GestureDetector(
                      onTap: () {
                        isLowEnabled.value = true;
                        ishighEnabled.value = false;
                        isUpDownEnabled.value = false;
                        isSameEnabled.value = false;
                      },
                      child: SizedBox(
                          child: isLowEnabled.value
                              ? AppImages.lowEnable(context)
                              : AppImages.lowDisable(context)),
                    );
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: isUpDownEnabled,
                  builder: (context, value, _) {
                    return GestureDetector(
                      onTap: () {
                        isUpDownEnabled.value = true;
                        isLowEnabled.value = false;
                        ishighEnabled.value = false;
                        isSameEnabled.value = false;
                      },
                      child: SizedBox(
                          child: isUpDownEnabled.value
                              ? AppImages.upDownEnable(context)
                              : AppImages.upDownDisable(context)),
                    );
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: isSameEnabled,
                  builder: (context, value, _) {
                    return GestureDetector(
                      onTap: () {
                        isSameEnabled.value = true;
                        isLowEnabled.value = false;
                        isUpDownEnabled.value = false;
                        ishighEnabled.value = false;
                      },
                      child: SizedBox(
                          child: isSameEnabled.value
                              ? AppImages.sameEnable(context)
                              : AppImages.sameDisable(context)),
                    );
                  },
                ),
              ],
            ),
          ),
          stockUpDiscoverWidget(),
          stockDownDiscoverWidget(),
          stockUpDownDiscoverWidget(),
          stocksameDiscoverWidget(),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppWidgetSize.dimen_20,
                vertical: AppWidgetSize.dimen_10),
            child: headingSubjectWidget(
                AppLocalizations().optionChainDisclaimer,
                [
                  TextSpan(
                      text: AppLocalizations().optionChainDisclaimerInfo1,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .bodySmall!
                          .copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: AppWidgetSize.fontSize11)),
                  TextSpan(
                    text: AppLocalizations().optionChainDisclaimerInfo2,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: AppWidgetSize.fontSize11,
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        sendEventToFirebaseAnalytics(
                          AppEvents.needHelp,
                          ScreenRoutes.quoteOptionChain,
                          'Need help button selected and will move to Arihant need help webview',
                        );
                        Navigator.push(
                            context,
                            SlideRoute(
                                settings: const RouteSettings(
                                  name: ScreenRoutes.inAppWebview,
                                ),
                                builder: (BuildContext context) =>
                                    WebviewWidget("Arihant Plus",
                                        AppConfig.needHelpUrl.trim())));
                      },
                  ),
                  TextSpan(
                      text: AppLocalizations().optionChainDisclaimerInfo3,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .bodySmall!
                          .copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: AppWidgetSize.fontSize11))
                ],
                padding: AppWidgetSize.dimen_2),
          ),
        ],
      ),
    );
  }

  ValueListenableBuilder<bool> stocksameDiscoverWidget() {
    return ValueListenableBuilder<bool>(
        valueListenable: isSameEnabled,
        builder: (context, value, _) {
          return !value
              ? Container()
              : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      headingSubjectWidget(
                          "I believe the price will remain the same",
                          [const TextSpan(text: "Here's what you can do:")]),
                      headingSubjectWidget(
                          "Calendar spread",
                          const [
                            TextSpan(
                                text:
                                    "Use this multi-leg strategy by entering a short call/put option in a near-term expiry date, and a long call/put option in a long- term expiry cycle on the same stock. With a call calendar spread, you could profit if the stock price stays flat or rises. With a put calendar spread, you could profit if the stock price stays flat or falls."),
                          ],
                          padding: AppWidgetSize.dimen_2),
                      headingSubjectWidget(
                          "Iron condor",
                          const [
                            TextSpan(
                                text:
                                    "Multi-leg strategy that could be used to profit if the stock price remains the same. Your potential gains and losses are limited. This multi-leg strategy involves a put spread and a call spread with the same expiration and four different strike prices."),
                          ],
                          padding: AppWidgetSize.dimen_2),
                    ],
                  ));
        });
  }

  ValueListenableBuilder<bool> stockUpDownDiscoverWidget() {
    return ValueListenableBuilder<bool>(
        valueListenable: isUpDownEnabled,
        builder: (context, value, _) {
          return !value
              ? Container()
              : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      headingSubjectWidget(
                          "I believe stock could go up or down.",
                          [const TextSpan(text: "Here's what you can do:")]),
                      headingSubjectWidget(
                          "Long straddle",
                          const [
                            TextSpan(
                                text:
                                    "Multi-leg strategy that could allow you to profit if the stock goes up or down significantly. Buy a call and a put with the same strike price and expiration date. Your maximum potential loss is the amount you paid to enter the position, and your gains are high if the stock price moves significantly."),
                          ],
                          padding: AppWidgetSize.dimen_2),
                      headingSubjectWidget(
                          "Long strangle",
                          const [
                            TextSpan(
                                text:
                                    "Take advantage of the stock volatility through a strangle strategy.Buy a call and put with the same expiration date but a different strike prices. Your maximum potential loss is the amount you paid to enter the position, and your gains are high if the stock price moves significantly."),
                          ],
                          padding: AppWidgetSize.dimen_2),
                      headingSubjectWidget(
                          "Strips",
                          const [
                            TextSpan(
                                text:
                                    "When your outlook is volatile, but you are bearish on the stock, you can create a strip straddle using one at- the-money (ATM) call and 2 at-the- money (ATM) puts. It may be costly to take this strategy, but the maximum potential loss is limited."),
                          ],
                          padding: AppWidgetSize.dimen_2),
                      headingSubjectWidget(
                          "Straps",
                          const [
                            TextSpan(
                                text:
                                    "Another strategy for limited loss potential can be applied when the market is volatile. You can create this strategy by buying 2 at-the- money (ATM) call options and one at-the-money (ATM) put option with the same strike price."),
                          ],
                          padding: AppWidgetSize.dimen_2),
                    ],
                  ));
        });
  }

  ValueListenableBuilder<bool> stockDownDiscoverWidget() {
    return ValueListenableBuilder<bool>(
        valueListenable: isLowEnabled,
        builder: (context, value, _) {
          return !value
              ? Container()
              : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      headingSubjectWidget("I believe stock will go down.",
                          [const TextSpan(text: "Here's what you can do:")]),
                      headingSubjectWidget(
                          "Buy a put",
                          const [
                            TextSpan(
                                text:
                                    "Buying a put gives you the right but not the obligation to sell one lot of a stock at the strike price, by the expiration date. You can profit if the stock price goes down, and lose money, upto your premium amount, if the stock goes up."),
                          ],
                          padding: AppWidgetSize.dimen_2),
                      headingSubjectWidget(
                          "Sell a covered call",
                          const [
                            TextSpan(
                                text:
                                    "You can sell a covered call by buying stock and selling call options, this will gives you the obligation to sell one lot of a stock at the strike price.You will earn some premium upfront🤑,but you may be obligated to sell shares at an unfavourable price. High risk strategy with limited profit and substantial maximum potential loss."),
                          ],
                          padding: AppWidgetSize.dimen_2),
                      headingSubjectWidget(
                          "Bear call spread",
                          const [
                            TextSpan(
                                text:
                                    "If you are mildly bearish on the stock and want to maximize profit while minimizing potential loss, you can create a bear spread by simultaneously selling an in-the-money (ITM) call option and hedge it by buying an out-of-money (OTM) call option. Your potential gains and losses are limited in this strategy."),
                          ],
                          padding: AppWidgetSize.dimen_2),
                      headingSubjectWidget(
                          "Bear put spread",
                          const [
                            TextSpan(
                                text:
                                    "If you are moderately bearish on the stock, you can create a bear put spread by purchasing in-the-money (ITM) put options and selling out-of-the-money (OTM) put options. The potential gains and loss are both limited."),
                          ],
                          padding: AppWidgetSize.dimen_2),
                    ],
                  ));
        });
  }

  ValueListenableBuilder<bool> stockUpDiscoverWidget() {
    return ValueListenableBuilder<bool>(
        valueListenable: ishighEnabled,
        builder: (context, value, _) {
          return !value
              ? Container()
              : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      headingSubjectWidget("I believe stock will go up.",
                          [const TextSpan(text: "Here's what you can do:")]),
                      headingSubjectWidget(
                          "Buy a call",
                          const [
                            TextSpan(text: "Buying a call gives you the "),
                            TextSpan(
                                text: "right but not an obligation",
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            TextSpan(
                                text:
                                    " to buy one lot of a stock at the strike price, by the expiration date. You can profit if the stock price goes up, and lose money, upto the premium amount you paid for the contract, if the stock goes down.")
                          ],
                          padding: AppWidgetSize.dimen_2),
                      headingSubjectWidget(
                          "Sell a covered put",
                          const [
                            TextSpan(
                                text:
                                    "Gives you the obligation to buy shares at the strike price, by the expiration date. You’ll earn a premium upfront, which is your maximum profit. However, if the price goes down, you may be obligated to buy the shares at an unfavorable price. High risk strategy with limited profit and substantial maximum potential loss."),
                          ],
                          padding: AppWidgetSize.dimen_2),
                      headingSubjectWidget(
                          "Bull call spread",
                          const [
                            TextSpan(
                                text:
                                    "This options trading strategy is used to benefit from a stock's limited increase in price. Buy an at-the-money (ATM) call option and sell an out-of-the-money (OTM) call option. This strategy gives you a limited potential gain in return for a lower potential loss."),
                          ],
                          padding: AppWidgetSize.dimen_2),
                      headingSubjectWidget(
                          "Bull put spread",
                          const [
                            TextSpan(
                                text:
                                    "When the view on the market is moderately bullish, a bull put spread strategy can be used. It involves buying a lower strike price out-of-the-money (OTM) put and selling a higher strike price in-the-money (ITM) put. Your potential loss and profits are both limited in this strategy."),
                          ],
                          padding: AppWidgetSize.dimen_2),
                    ],
                  ),
                );
        });
  }

  Widget headingSubjectWidget(String heading, List<TextSpan> subject,
      {double? padding}) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: padding ?? AppWidgetSize.dimen_10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
              heading,
              heading == AppLocalizations().optionChainDisclaimer
                  ? Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: AppWidgetSize.fontSize12)
                  : Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: AppWidgetSize.dimen_18,
                      fontWeight: FontWeight.w500),
              textAlign: TextAlign.justify),
          Padding(
              padding: EdgeInsets.symmetric(
                  vertical: padding ?? AppWidgetSize.dimen_10),
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: AppWidgetSize.fontSize16,
                      ),
                  children: subject,
                ),
              )),
        ],
      ),
    );
  }

  Widget buildComingSoonWidget(String title) {
    return SizedBox(
      child: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }

  FutureExpiryData _getQuoteExpiryData() {
    List<Filters> filters = <Filters>[
      Filters(key: 'segment', value: 'opt'),
      Filters(key: 'optionType', value: 'CE')
    ];
    return FutureExpiryData(
        dispSym: symbols.dispSym,
        sym: symbols.sym,
        companyName: symbols.companyName,
        baseSym: symbols.baseSym,
        filters: filters);
  }
}
