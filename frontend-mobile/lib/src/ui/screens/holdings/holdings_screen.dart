import "dart:ui" as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../blocs/edis/edis_bloc.dart';
import '../../../blocs/holdings/holdings/holdings_bloc.dart';
import '../../../blocs/holdings/holdings_detail/holdings_detail_bloc.dart';
import '../../../blocs/market_status/market_status_bloc.dart';
import '../../../blocs/quote/main_quote/quote_bloc.dart';
import '../../../blocs/watchlist/watchlist_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/keys/holdings_keys.dart';
import '../../../constants/keys/login_keys.dart';
import '../../../data/repository/my_account/my_account_repository.dart';
import '../../../data/store/app_storage.dart';
import '../../../data/store/app_store.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/edis/order_details_model.dart';
import '../../../models/sort_filter/sort_filter_model.dart';
import '../../../models/watchlist/watchlist_group_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../validator/input_validator.dart';
import '../../widgets/build_empty_widget.dart';
import '../../widgets/choose_watchlist_widget.dart';
import '../../widgets/create_new_watchlist_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/label_border_text_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/refresh_widget.dart';
import '../../widgets/sort_filter_widget.dart';
import '../../widgets/table_with_bgcolor.dart';
import '../base/base_screen.dart';
import '../quote/widgets/routeanimation.dart';
import 'holdings_details_screen.dart';

class HoldingsScreen extends BaseScreen {
  final FocusNode searchFocusNode;
  const HoldingsScreen(
    this.searchFocusNode, {
    Key? key,
  }) : super(key: key);
  @override
  HoldingsScreenState createState() => HoldingsScreenState();
}

class HoldingsScreenState extends BaseAuthScreenState<HoldingsScreen> {
  late HoldingsBloc _holdingsBloc;
  late WatchlistBloc watchlistBloc;
  late QuoteBloc quoteBloc;
  late EdisBloc edisBloc;
  late AppLocalizations _appLocalizations;
  List<Groups>? groupList = <Groups>[];

  final ValueNotifier<int> selectedHeaderIndex = ValueNotifier<int>(0);
  final ValueNotifier<bool> isSearchSelected = ValueNotifier<bool>(false);

  final TextEditingController _searchController =
      TextEditingController(text: '');
  SortModel selectedSort = SortModel();
  List<FilterModel> selectedFilters = <FilterModel>[];

  List<OrderDetails> ordDetails = [];
  final ValueNotifier<bool> isNonPoaUser = ValueNotifier<bool>(false);

  String? segment;

  @override
  void initState() {
    checkToShowNote();
    selectedFilters = getFilterModel();

    _holdingsBloc = BlocProvider.of<HoldingsBloc>(context)
      ..stream.listen(_holdingsListener);
    _holdingsBloc.add(HoldingsFetchEvent(false, isFetchAgain: true));
    watchlistBloc = BlocProvider.of<WatchlistBloc>(context)
      ..stream.listen(watchlistListener);
    getWatchlistGroup();
    quoteBloc = BlocProvider.of<QuoteBloc>(context)
      ..stream.listen(quoteListener);
    edisBloc = BlocProvider.of<EdisBloc>(context)..stream.listen(edisListener);
    isShowAuthorize();
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.holdingsScreen);
  }

  void getWatchlistGroup() {
    watchlistBloc.add(WatchlistGetGroupsEvent(false));
  }

  Future<void> fetchHoldings() async {
    holdingsApiCallWithFilters(
      selectedFilters,
      selectedSort,
    );
  }

  Future<void> isShowAuthorize() async {
    final dynamic userLoginDetails =
        await AppStorage().getData(userLoginDetailsKey);
    if (userLoginDetails != null) {
      if (userLoginDetails['isNonPoaUser'] != null) {
        isNonPoaUser.value = userLoginDetails['isNonPoaUser'];
        segment = userLoginDetails['segment'];
      }
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      postSetState();
    });
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

  List<FilterModel> getFilterModel() {
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

  void holdingsApiCallWithFilters(
    List<FilterModel>? filterModel,
    SortModel? sortModel,
  ) {
    _holdingsBloc.add(FetchHoldingsWithFiltersEvent(
      filterModel,
      selectedSort,
    ));
    if (_holdingsBloc.holdingsFetchDoneState.holdingsModel != null) {
      _holdingsBloc.add(HoldingsStartSymStreamEvent());
    }
  }

  Future<void> watchlistListener(WatchlistState state) async {
    if (state is WatchlistDoneState) {
      groupList = [];
      if (state.watchlistGroupModel != null) {
        for (Groups element in state.watchlistGroupModel!.groups!) {
          groupList!.add(element);
        }
      }
    }
  }

  Future<void> edisListener(EdisState state) async {
    if (state is! EdisProgressState) {
      if (mounted) {}
    }
    if (state is EdisProgressState) {
      if (mounted) {}
    } else if (state is VerifyEdisDoneState) {
      final Map<String, dynamic>? data = await pushNavigation(
        ScreenRoutes.edisScreen,
        arguments: {
          'edis': state.verifyEdisModel!.edis![0],
          'segment': segment,
        },
      );
      _holdingsBloc.add(HoldingsFetchEvent(true));

      if (data?['isNsdlAckNeeded'] == 'true') {
        edisBloc.add(GetNsdlAcknowledgementEvent(
            state.verifyEdisModel!.edis![0].reqId!));
      }
    } else if (state is NsdlAcknowledgementDoneState) {
      if (state.nsdlAckModel!.status == AppConstants.authorizationSuccessful) {
        showToast(
          message: state.nsdlAckModel!.msg,
          context: context,
          secondsToShowToast: 5,
          isCenter: true,
        );
      } else {
        showToast(
          message: state.nsdlAckModel!.msg,
          context: context,
          isError: true,
          secondsToShowToast: 5,
          isCenter: true,
        );
      }
    } else if (state is NsdlAcknowledgementFailedState ||
        state is NsdlAcknowledgementServiceExceptionState) {
      showToast(
        message: state.errorMsg,
        context: context,
        isError: true,
        secondsToShowToast: 5,
        isCenter: true,
      );
    } else if (state is VerifyEdisFailedState ||
        state is VerifyEdisServiceExceptionState) {
      showToast(
        message: state.errorMsg,
        context: context,
        isError: true,
        secondsToShowToast: 5,
        isCenter: true,
      );
    } else if (state is EdisErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  Future<void> quoteListener(QuoteState state) async {
    if (state is! QuoteProgressState) {
      if (mounted) {}
    }
    if (state is QuoteProgressState) {
      if (mounted) {}
    } else if (state is QuotedeleteDoneState) {
      showToast(
        message: state.messageModel,
        context: context,
      );
    } else if (state is QuoteAddSymbolFailedState ||
        state is QuotedeleteSymbolFailedState) {
      showToast(
        message: state.errorMsg,
        context: context,
        isError: true,
      );
    } else if (state is QuoteAddDoneState) {
      showToast(
        message: state.messageModel,
        context: context,
      );
      getWatchlistGroup();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    } else if (state is QuoteErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  Map<dynamic, dynamic> streamDetails = {};

  Future<void> _holdingsListener(HoldingsState state) async {
    if (state is! HoldingsProgressState) {
      if (mounted) {}
    }
    if (state is HoldingsProgressState) {
      if (mounted) {}
    } else if (state is HoldingsStartStreamState) {
      subscribeLevel1(state.streamDetails);
      streamDetails = state.streamDetails;
    } else if (state is HoldingsFailedState) {
    } else if (state is HoldingsErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.holdingsScreen;
  }

  @override
  void quote1responseCallback(ResponseData data) {
    _holdingsBloc.add(HoldingsStreamingResponseEvent(data));
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: AppUtils().labelBorderWidgetBottom(
          AppLocalizations().viewboReports,
          AppImages.analyticsIcon(context, height: AppWidgetSize.dimen_15),
          () async {
            String? ssoUrl = await MyAccountRepository().getSSO();

            await InAppBrowser.openWithSystemBrowser(url: Uri.parse(ssoUrl));
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: ((_holdingsBloc.holdingsFetchDoneState.holdingsModel?.holdings
                        ?.isEmpty ??
                    true) &&
                (!_holdingsBloc.holdingsFetchDoneState.isFilterSelected) &&
                !_holdingsBloc.holdingsFetchDoneState.isSortSelected)
            ? RefreshWidget(
                onRefresh: () async {
                  _holdingsBloc.add(HoldingsFetchEvent(false,
                      loading: _holdingsBloc
                              .holdingsFetchDoneState.mainHoldingsSymbols ==
                          null));
                },
                child: SafeArea(
                  child: SizedBox(
                      width: AppWidgetSize.screenWidth(context),
                      height: AppWidgetSize.screenHeight(context),
                      child: _buildBody()),
                ))
            : SafeArea(
                child: SizedBox(
                    width: AppWidgetSize.screenWidth(context),
                    height: AppWidgetSize.screenHeight(context),
                    child: _buildBody())));
  }

  Widget floatingAuthorizeButton() {
    return BlocBuilder<HoldingsBloc, HoldingsState>(builder: (context, state) {
      return (isNonPoaUser.value)
          ? GestureDetector(
              onTap: () {
                edisBloc.add(VerifyEdisEvent(ordDetails));
              },
              child: Container(
                width: AppWidgetSize.dimen_130,
                height: AppWidgetSize.dimen_35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppWidgetSize.dimen_20,
                  ),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                  ),
                  color: Theme.of(context)
                      .snackBarTheme
                      .backgroundColor!
                      .withOpacity(0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppImages.authorizationLockIcon(context),
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppWidgetSize.dimen_5,
                      ),
                      child: CustomTextWidget(
                        _appLocalizations.authorization,
                        Theme.of(context).primaryTextTheme.headlineSmall,
                      ),
                    )
                  ],
                ),
              ),
            )
          : Container();
    });
  }

  Widget _buildBody() {
    return BlocBuilder<HoldingsBloc, HoldingsState>(
      buildWhen: (HoldingsState prevState, HoldingsState currentState) {
        return currentState is HoldingsFetchDoneState ||
            currentState is HoldingsFailedState ||
            currentState is HoldingsInitState ||
            currentState is HoldingsProgressState ||
            currentState is HoldingsServiceExpectionState;
      },
      builder: (BuildContext ctx, HoldingsState state) {
        if (_holdingsBloc
                .holdingsFetchDoneState.holdingsModel?.holdings?.isEmpty ??
            true && state is HoldingsFetchDoneState) {
          closeNote.value = true;
        }
        if ((state is HoldingsProgressState || state is HoldingsInitState)) {
          return const LoaderWidget();
        } else if (state is HoldingsFailedState ||
            state is HoldingsServiceExpectionState) {
          if (selectedFilters[0].filters != null &&
              selectedFilters[0].filters!.isEmpty &&
              selectedFilters[1].filters != null &&
              selectedFilters[1].filters!.isEmpty) {
            return _buildEmptyHoldingsWidget();
          } else {
            return _buildHoldingsWidget(
              null,
              [],
              isError: true,
            );
          }
        } else if (state is HoldingsServiceExpectionState) {
          return errorWithImageWidget(
            context: context,
            imageWidget: AppUtils().getNoDateImageErrorWidget(context),
            errorMessage: state.errorMsg,
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_1,
            ),
          );
        }
        if (AppConstants.loadHoldingsFromQuote &&
            AppStore().getSelectedHolding() != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            AppConstants.loadHoldingsFromQuote = false;

            if (_holdingsBloc.holdingsFetchDoneState.holdingsModel != null) {
              pushToHoldingDetail(
                  context,
                  _holdingsBloc.holdingsFetchDoneState.holdingsModel!.holdings!
                      .where((element) =>
                          element.dispSym ==
                          AppStore().getSelectedHolding()?.dispSym)
                      .first);
            }
          });
        }
        if (_holdingsBloc.holdingsFetchDoneState.holdingsModel?.holdings !=
            null) {
          setOrdDetailsForEdisVerify(
              _holdingsBloc.holdingsFetchDoneState.holdingsModel!.holdings);
          if (isSearchSelected.value) {
            if (_holdingsBloc.holdingsFetchDoneState.searchHoldingsSymbols !=
                    null &&
                _holdingsBloc
                    .holdingsFetchDoneState.searchHoldingsSymbols!.isNotEmpty) {
              return _buildHoldingsWidget(
                _holdingsBloc.holdingsFetchDoneState,
                _holdingsBloc.holdingsFetchDoneState.searchHoldingsSymbols!,
              );
            } else if (_searchController.text.isEmpty) {
              return _buildHoldingsWidget(
                _holdingsBloc.holdingsFetchDoneState,
                _holdingsBloc.holdingsFetchDoneState.holdingsModel!.holdings!,
              );
            } else {
              return _buildHoldingsWidget(
                _holdingsBloc.holdingsFetchDoneState,
                _holdingsBloc.holdingsFetchDoneState.holdingsModel!.holdings!,
                isSearchEmpty: true,
              );
            }
          } else {
            return _buildHoldingsWidget(
              _holdingsBloc.holdingsFetchDoneState,
              _holdingsBloc.holdingsFetchDoneState.holdingsModel!.holdings!,
            );
          }
        } else {
          return _buildEmptyHoldingsWidget();
        }
      },
    );
  }

  Widget _buildEmptyHoldingsWidget() {
    return ListView(
      children: [
        SizedBox(
          height: AppWidgetSize.screenHeight(context) - AppWidgetSize.dimen_200,
          child: buildEmptyWidget(
              context: context,
              description1: _appLocalizations.emptyHoldingsDescriptions1,
              description2: _appLocalizations.emptyHoldingsDescriptions2,
              buttonInRow: false,
              button1Title: _appLocalizations.placeOrder,
              button2Title: '',
              topPadding: AppWidgetSize.dimen_20,
              onButton1Tapped: onPlaceOrderTapped,
              emptyImage: AppImages.empty_holdings(context, height: 230.w)),
        ),
      ],
    );
  }

  final GlobalKey<ScaffoldMessengerState> scaffoldkeys =
      GlobalKey<ScaffoldMessengerState>();

  Widget _buildHoldingsWidget(
    HoldingsFetchDoneState? state,
    List<Symbols> holdings, {
    bool isSearchEmpty = false,
    bool isError = false,
  }) {
    return Scaffold(
      body: _buildBodyContentWidget(
        context,
        holdings,
        isSearchEmpty,
        isError: isError,
      ),
      appBar: isSearchSelected.value
          ? null
          : AppBar(
              leadingWidth: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              toolbarHeight: AppWidgetSize.getSize(AppWidgetSize.dimen_110),
              title: SizedBox(
                  height: AppWidgetSize.getSize(AppWidgetSize.dimen_110),
                  child: _buildTopContentWidget(
                    state,
                  )),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      floatingActionButton: ValueListenableBuilder<bool>(
          valueListenable: closeNote,
          builder: (_, value, child) => !value
              ? Container(
                  height: 0,
                )
              : GestureDetector(
                  onTap: () {
                    closeNote.value = false;
                    AppStorage().setData(AppConstants.showHoldingsNote, true);
                  },
                  child: SizedBox(
                      height: AppWidgetSize.dimen_40,
                      child: AppImages.informationIcon(context,
                          color: Theme.of(context).primaryIconTheme.color,
                          isColor: true,
                          height: 25.w,
                          width: 25.w)),
                )),
      bottomNavigationBar: ValueListenableBuilder<bool>(
          valueListenable: closeNote,
          builder: (_, value, child) => value
              ? Container(
                  height: 0,
                )
              : _buildFooterDescriptionWidget()),
    );
  }

  Widget _buildTopContentWidget(
    HoldingsFetchDoneState? state,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_5,
        bottom: AppWidgetSize.dimen_5,
      ),
      child: _buildTopContentListViewWidget(
        state,
      ),
    );
  }

  Widget _buildTopContentListViewWidget(
    HoldingsFetchDoneState? state,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _buildListBoxContent(
            _appLocalizations.overallReturn,
            state != null && state.holdingsModel?.overallReturn != null
                ? AppUtils().dataNullCheck(state.holdingsModel?.overallReturn)
                : '--',
            state != null && state.holdingsModel?.overallReturnPercent != null
                ? '(${AppUtils().dataNullCheck(state.holdingsModel?.overallReturnPercent)}%)'
                : '--',
            state != null
                ? AppUtils().profitLostColor(state.holdingsModel?.overallReturn)
                : Theme.of(context).primaryTextTheme.labelLarge!.color!,
          );
        } else if (index == 1) {
          return _buildListBoxContent(
            _appLocalizations.todaysReturn,
            state != null && state.holdingsModel?.oneDayReturn != null
                ? AppUtils().dataNullCheck(state.holdingsModel?.oneDayReturn)
                : '--',
            state != null && state.holdingsModel?.oneDayReturnPercent != null
                ? '(${AppUtils().dataNullCheck(state.holdingsModel?.oneDayReturnPercent)}%)'
                : '--',
            state != null
                ? AppUtils().profitLostColor(state.holdingsModel?.oneDayReturn)
                : Theme.of(context).primaryTextTheme.labelLarge!.color!,
          );
        } else if (index == 2) {
          return _buildListBoxContent(
            _appLocalizations.currentValue,
            state != null && state.holdingsModel?.overallcurrentValue != null
                ? AppUtils()
                    .dataNullCheck(state.holdingsModel?.overallcurrentValue)
                : '--',
            '',
            Theme.of(context).primaryTextTheme.labelLarge!.color!,
          );
        } else {
          return _buildListBoxContent(
            _appLocalizations.investedAmount,
            state != null && state.holdingsModel?.totalInvested != null
                ? AppUtils().dataNullCheck(state.holdingsModel?.totalInvested)
                : '--',
            '',
            Theme.of(context).primaryTextTheme.labelLarge!.color!,
          );
        }
      },
    );
  }

  //infoIncon
  Future<void> informationIconBottomSheet(String title) async {
    String titleText = '';
    String descpText = '';
    if (title == _appLocalizations.overText) {
      titleText = _appLocalizations.overText;
      descpText = _appLocalizations.ovrRetDesp;
    } else if (title == _appLocalizations.todaysReturn) {
      titleText = _appLocalizations.todaysReturn;
      descpText = _appLocalizations.todayRetDesc;
    } else if (title == _appLocalizations.ltp) {
      titleText = _appLocalizations.lastTradePrice;
      descpText = _appLocalizations.ltpDesc;
    } else if (title == _appLocalizations.currValText) {
      titleText = _appLocalizations.currValText;
      descpText = _appLocalizations.curValDesp;
    } else if (title == _appLocalizations.invsText) {
      titleText = _appLocalizations.invsText;
      descpText = _appLocalizations.invAmntDesp;
    }
    List<Widget> informationWidgetList = [
      _buildExpansionRowForBottomSheet(context, descpText),
    ];
    showInfoBottomsheet(
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  titleText,
                  Theme.of(context).primaryTextTheme.titleMedium,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: AppImages.closeIcon(context,
                      width: AppWidgetSize.dimen_20,
                      height: AppWidgetSize.dimen_20,
                      color: Theme.of(context).primaryIconTheme.color,
                      isColor: true),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      shrinkWrap: true,
                      itemCount: informationWidgetList.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Column(
                          children: [
                            informationWidgetList[index],
                            if (title == _appLocalizations.currValText)
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8.0, top: 8),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: _appLocalizations.note,
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .labelSmall!
                                            .copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                      ),
                                      TextSpan(
                                        text:
                                            " ${_appLocalizations.curValDesp2}",
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .labelSmall,
                                      )
                                    ],
                                  ),
                                ),
                              )
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionRowForBottomSheet(
    BuildContext context,
    String description,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_5,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: CustomTextWidget(
          description,
          Theme.of(context).primaryTextTheme.labelSmall,
        ),
      ),
    );
  }

  Widget _buildListBoxContent(
    String title,
    String value,
    String subValue,
    Color color, {
    bool isBottomSheet = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
        right: isBottomSheet ? AppWidgetSize.dimen_10 : AppWidgetSize.dimen_10,
      ),
      child: Container(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_8,
          right: AppWidgetSize.dimen_8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            AppWidgetSize.dimen_6,
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _getListBoxWidget(
              title,
              value,
              subValue,
              color,
            ),
            InkWell(
              onTap: () {
                informationIconBottomSheet(title);
              },
              child: Padding(
                  padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_10,
                  ),
                  child: AppImages.informationIcon(
                    context,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true,
                    width: AppWidgetSize.dimen_20,
                    height: AppWidgetSize.dimen_20,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getListBoxWidget(
    String title,
    String value,
    String subValue,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_5,
          top: AppWidgetSize.dimen_10,
          right: AppWidgetSize.dimen_10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                title,
                Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_5,
            ),
            child: _getLableWithRupeeSymbol(
              value,
              Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: AppConstants.interFont,
                    color: color,
                  ),
              Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_5,
            ),
            child: CustomTextWidget(
              subValue,
              Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
              isShowShimmer: subValue.isNotEmpty,
            ),
          )
        ],
      ),
    );
  }

  final ValueNotifier<bool> closeNote = ValueNotifier<bool>(false);

  Widget _buildBodyContentWidget(
    BuildContext context,
    List<Symbols> holdings,
    bool isSearchEmpty, {
    bool isError = false,
  }) {
    return Container(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isSearchSelected.value)
            _buildSearchBar()
          else
            _buildBodyContentToolBarWidget(),
          if (!isSearchEmpty)
            Padding(
              padding: EdgeInsets.only(
                bottom: AppWidgetSize.dimen_10,
              ),
              child: _buildHoldingsListToolBarWidget(holdings),
            ),
          if (isSearchEmpty || holdings.isEmpty || isError)
            RefreshWidget(
                onRefresh: () async {
                  await fetchHoldings();
                },
                child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: AppWidgetSize.dimen_18,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          errorWithImageWidget(
                            width: AppWidgetSize.screenWidth(context),
                            context: context,
                            imageWidget:
                                AppUtils().getNoDateImageErrorWidget(context),
                            errorMessage: isError
                                ? AppLocalizations().noDataAvailableErrorMessage
                                : (!isSearchSelected.value || (!isSearchEmpty)
                                    ? AppLocalizations()
                                        .noDataAvailableErrorMessage
                                    : "${AppLocalizations().noDataHoldings}'${_searchController.text}'"),
                            padding: EdgeInsets.only(
                              left: AppWidgetSize.dimen_30,
                              right: AppWidgetSize.dimen_30,
                              bottom: AppWidgetSize.dimen_30,
                            ),
                          ),
                        ],
                      ),
                    )))
          else
            _buildHoldingsListWidget(context, holdings)
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
        bottom: AppWidgetSize.dimen_20,
      ),
      child: Container(
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
                _holdingsBloc.add(HoldingsSearchEvent(_searchController.text));
              },
              focusNode: widget.searchFocusNode,
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
                    color:
                        Theme.of(context).dialogBackgroundColor.withAlpha(-1)),
                counterText: '',
              ),
              maxLength: 25,
            ),
            Positioned(
              right: 0,
              top: AppWidgetSize.dimen_12,
              child: GestureDetector(
                onTap: () {
                  _searchController.text = '';
                  setState(() {});
                  _holdingsBloc.add(HoldingsResetSearchEvent());
                  isSearchSelected.value = false;
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
    );
  }

  Widget _buildBodyContentToolBarWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 10.w, bottom: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          floatingAuthorizeButton(),
          _buildToolBarRightWidget(),
        ],
      ),
    );
  }

  Widget _buildToolBarRightWidget() {
    return Row(
      children: [
        InkWell(
            onTap: () {
              sortSheet();
            },
            child: AppUtils().buildFilterIcon(context,
                isSelected: selectedFilters[0].filters != null &&
                        selectedFilters[0].filters!.isNotEmpty ||
                    selectedFilters[1].filters != null &&
                        selectedFilters[1].filters!.isNotEmpty ||
                    selectedSort.sortName != null &&
                        selectedSort.sortName!.isNotEmpty)),
        Padding(
          padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_2,
            right: AppWidgetSize.dimen_10,
          ),
          child: Container(
            width: AppWidgetSize.dimen_1,
            height: AppWidgetSize.dimen_25,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  width: AppWidgetSize.dimen_1,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            isSearchSelected.value = true;
            setState(() {});
            widget.searchFocusNode.requestFocus();
          },
          child: AppImages.search(
            context,
            color: Theme.of(context).primaryIconTheme.color,
            isColor: true,
            width: AppWidgetSize.dimen_25,
            height: AppWidgetSize.dimen_25,
          ),
        ),
      ],
    );
  }

  final ScrollController scrollcontroller = ScrollController();
  Widget _buildHoldingsListWidget(
    BuildContext context,
    List<Symbols> holdings,
  ) {
    return Expanded(
        child: RefreshWidget(
            onRefresh: () async {
              _holdingsBloc.add(HoldingsFetchEvent(false, loading: false));
            },
            child: NotificationListener(
              onNotification: (t) {
                if (t is ScrollStartNotification) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (closeNote.value == false) {
                      closeNote.value = true;
                    }
                  });
                }
                return false;
              },
              child: ListView.builder(
                controller: scrollcontroller,
                physics: const AlwaysScrollableScrollPhysics(),
                primary: false,
                itemCount: holdings.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return _buildRowWidgets(
                    context,
                    index,
                    holdings[index],
                  );
                },
              ),
            )));
  }

  Widget _buildRowWidgets(
    BuildContext context,
    int index,
    Symbols? holdings,
  ) {
    return Container(
      width: AppWidgetSize.fullWidth(context) - 10.w,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: AppWidgetSize.dimen_1,
            color: Theme.of(context).dividerColor,
          ),
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
        bottom: AppWidgetSize.dimen_10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLeftRowWidgets(index, holdings!),
          ValueListenableBuilder<int>(
              valueListenable: selectedHeaderIndex,
              builder: (_, value, child) => TextButton(
                    onPressed: () {
                      if (selectedHeaderIndex.value < 2) {
                        selectedHeaderIndex.value++;
                      } else {
                        selectedHeaderIndex.value = 0;
                      }
                    },
                    style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all<Color>(
                            Theme.of(context)
                                .dialogBackgroundColor
                                .withOpacity(0.1))), // <-- Does not work

                    child: _buildRightRowWidgets(
                      context,
                      holdings,
                    ),
                  )),
        ],
      ),
    );
  }

  Widget _buildLeftRowWidgets(
    int index,
    Symbols holdingItem,
  ) {
    return Flexible(
      flex: 8,
      child: InkWell(
        onTap: () {
          showHoldingsBottomSheet(holdingItem);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getDispSymWidget(
              AppUtils().dataNullCheck(holdingItem.dispSym),
              holdingItem,
            ),
            _getQtyAndAvgPriceWidget(
              AppUtils().dataNullCheck(holdingItem.qty),
              AppUtils().dataNullCheck(holdingItem.avgPrice),
            ),
            _getLtpWidget(
              AppUtils().dataNullCheck(holdingItem.ltp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightRowWidgets(
    BuildContext context,
    Symbols holdingItem,
  ) {
    return _getChildWidget(
      selectedHeaderIndex.value,
      holdingItem,
    );
  }

  Widget _buildHoldingsListToolBarWidget(
    List<Symbols> holdings,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextWidget(
          '${holdings.length} ${_appLocalizations.scrips}',
          Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
              fontSize: AppWidgetSize.fontSize14,
              color: const Color(0xFF797979)),
        ),
        _buildHeaderWidget(),
      ],
    );
  }

  Widget _buildHeaderWidget() {
    return ValueListenableBuilder<int>(
      valueListenable: selectedHeaderIndex,
      builder: (_, value, child) {
        return GestureDetector(
          onTap: () {
            if (selectedHeaderIndex.value < 2) {
              selectedHeaderIndex.value++;
            } else {
              selectedHeaderIndex.value = 0;
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(right: AppWidgetSize.dimen_5),
                child: AppImages.swapIcon(
                  context,
                  width: AppWidgetSize.dimen_16,
                  height: AppWidgetSize.dimen_18,
                ),
              ),
              CustomTextWidget(
                selectedHeaderIndex.value == 0
                    ? _appLocalizations.mktValueOverallPnL
                    : selectedHeaderIndex.value == 1
                        ? _appLocalizations.mktValueOneDayPnL
                        : _appLocalizations.currentValueInvestedValue,
                Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    fontSize: AppWidgetSize.fontSize14,
                    color: const Color(0xFF797979)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getDispSymWidget(
    String dispSym,
    Symbols holdingItem,
  ) {
    return Container(
      width: AppWidgetSize.fullWidth(context),
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_6,
      ),
      child: RichText(
        text: TextSpan(
          text: dispSym,
          style: Theme.of(context)
              .primaryTextTheme
              .labelSmall!
              .copyWith(fontWeight: FontWeight.w600),
          children: [
            if (holdingItem.ylow != null &&
                AppUtils().doubleValue(holdingItem.ltp) <
                    AppUtils().doubleValue(holdingItem.ylow))
              _buildWidgetSpan(
                AppConstants.fiftyTwoWL,
                AppColors.negativeColor,
              ),
            if (holdingItem.yhigh != null &&
                AppUtils().doubleValue(holdingItem.ltp) >
                    AppUtils().doubleValue(holdingItem.yhigh))
              _buildWidgetSpan(
                AppConstants.fiftyTwoWH,
                AppColors().positiveColor,
              ),
            if (AppUtils().dataNullCheck(holdingItem.usedQty) != ' ' &&
                AppUtils().dataNullCheck(holdingItem.usedQty) != '0')
              _buildHoldingsWidgetSpan(holdingItem),
            if (AppUtils().dataNullCheck(holdingItem.btst) != ' ' &&
                AppUtils().dataNullCheck(holdingItem.btst) != '0')
              _buildBtstWidgetSpan(holdingItem),
          ],
        ),
      ),
    );
  }

  WidgetSpan _buildHoldingsWidgetSpan(
    Symbols holdingItem,
  ) {
    return WidgetSpan(
      alignment: ui.PlaceholderAlignment.middle,
      child: Container(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_3,
        ),
        width: holdingItem.qty!.textSize(
              holdingItem.qty!,
              Theme.of(context).primaryTextTheme.labelLarge!,
            ) +
            AppWidgetSize.dimen_40,
        child: Row(
          children: [
            AppImages.positionsRedIcon(context),
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_2,
                left: AppWidgetSize.dimen_3,
              ),
              child: CustomTextWidget(
                '-${AppUtils().dataNullCheck(holdingItem.usedQty)}',
                Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: AppColors.negativeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  WidgetSpan _buildBtstWidgetSpan(
    Symbols holdingItem,
  ) {
    return WidgetSpan(
      alignment: ui.PlaceholderAlignment.middle,
      child: Padding(
        padding: EdgeInsets.only(left: AppWidgetSize.dimen_3),
        child: Container(
          padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_3,
            right: AppWidgetSize.dimen_3,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppWidgetSize.dimen_15,
            ),
            color: AppStore().getThemeData() == AppConstants.darkMode
                ? Theme.of(context).colorScheme.background
                : Theme.of(context).colorScheme.primary,
          ),
          child: Padding(
            padding: EdgeInsets.all(AppWidgetSize.dimen_2),
            child: FittedBox(
              child: Row(
                children: [
                  Text(
                    _appLocalizations.t1,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: AppWidgetSize.fontSize9,
                        ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_1),
                    child: Text(
                      holdingItem.btst!,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: AppWidgetSize.fontSize9,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getQtyAndAvgPriceWidget(
    String qty,
    String avgPrice,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
        bottom: AppWidgetSize.dimen_5,
      ),
      child: _getLabelWithRupeeAndValue(
        '$qty ${_appLocalizations.qty} @ ',
        avgPrice,
      ),
    );
  }

  Widget _getLtpWidget(String ltp) {
    return _getLabelWithRupeeAndValue(
      '${_appLocalizations.ltpCap}: ',
      ltp,
    );
  }

  Widget _getLabelWithRupeeAndValue(
    String lableTitle,
    String value,
  ) {
    return Row(
      children: [
        CustomTextWidget(
          lableTitle,
          Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        _getLableWithRupeeSymbol(
          value,
          Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontFamily: AppConstants.interFont,
              ),
          Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  Widget _buildFooterDescriptionWidget() {
    return ValueListenableBuilder<bool>(
        valueListenable: isNonPoaUser,
        builder: (context, value, _) {
          return Container(
            height: AppWidgetSize.dimen_140,
            color: Theme.of(context).snackBarTheme.backgroundColor,
            child: Padding(
              padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_10,
                right: AppWidgetSize.dimen_10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AppImages.bankNotificationBadgelogo(context,
                            isColor: true),
                        Text(
                          _appLocalizations.note,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: AppWidgetSize.dimen_10,
                          right: AppWidgetSize.dimen_10),
                      child: Text(
                        _appLocalizations.holdingsNote,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    width: AppWidgetSize.dimen_25,
                    height: AppWidgetSize.dimen_130,
                    padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                    child: GestureDetector(
                      onTap: (() => {
                            closeNote.value = true,
                            AppStorage()
                                .setData(AppConstants.showHoldingsNote, false),
                          }),
                      child: AppImages.close(context,
                          color: Theme.of(context).primaryIconTheme.color,
                          isColor: true),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _getChildWidget(
    int index,
    Symbols holdings,
  ) {
    if (index == 0) {
      return _buildLabelForRightWidget(
          holdings.isBond == true ? "--" : holdings.overallPnL,
          holdings.isBond == true ? "--" : holdings.overallPnLPercent,
          holdings.mktValueChng,
          change: true);
    } else if (index == 1) {
      return _buildLabelForRightWidget(
          holdings.oneDayPnL, holdings.oneDayPnLPercent, holdings.mktValueChng,
          change: true);
    } else if (index == 2) {
      return _buildLabelForRightWidget(
        holdings.mktValue,
        holdings.invested,
        holdings.mktValueChng,
      );
    }
    return Container();
  }

  Widget _buildLabelForRightWidget(
      String? firstValue, String? secondValue, String? mktValChng,
      {bool change = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _getLableWithRupeeSymbol(
          AppUtils().dataNullCheck(firstValue),
          Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
              fontFamily: AppConstants.interFont,
              color: change
                  ? AppUtils().profitLostColor(firstValue)
                  : AppUtils().profitLostColor(mktValChng)),
          Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: change
                    ? AppUtils().profitLostColor(firstValue)
                    : AppUtils().profitLostColor(mktValChng),
              ),
          showShimmer: firstValue != "--",
        ),
        Padding(
          padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (change)
                CustomTextWidget(
                  '(${AppUtils().dataNullCheck(secondValue)}%)',
                  Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                        fontFamily: AppConstants.interFont,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  isShowShimmer: firstValue != "--",
                  shimmerWidth: 60,
                )
              else
                CustomTextWidget(
                  '(${AppConstants.rupeeSymbol}${AppUtils().dataNullCheck(secondValue)})',
                  Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                        fontFamily: AppConstants.interFont,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  isShowShimmer: firstValue != "--",
                  shimmerWidth: 60,
                ),
            ],
          ),
        ),
      ],
    );
  }

  WidgetSpan _buildWidgetSpan(
    String title,
    Color color,
  ) {
    return WidgetSpan(
      alignment: ui.PlaceholderAlignment.middle,
      child: Padding(
        padding: EdgeInsets.only(left: AppWidgetSize.dimen_3),
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
                      fontSize: AppWidgetSize.fontSize9,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showHoldingsBottomSheet(
    Symbols holdingItem,
  ) async {
    showInfoBottomsheet(
        ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.w),
              topRight: Radius.circular(20.w),
            ),
            child: BlocProvider<HoldingsBloc>.value(
              value: _holdingsBloc,
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter updateState) {
                  return GestureDetector(
                      onVerticalDragEnd: (details) async {
                        int sensitivity = 0;
                        if ((details.primaryVelocity ?? 0) < sensitivity) {
                          pushtoHoldingswithPop(context, holdingItem);
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: _bottomContent(holdingItem));
                },
              ),
            )),
        topMargin: false,
        horizontalMargin: false);
  }

  Future<void> pushtoHoldingswithPop(
      BuildContext context, Symbols holdingItem) async {
    popNavigation();
    Future.delayed(const Duration(milliseconds: 200), () {
      pushToHoldingDetail(context, holdingItem);
    });
  }

  pushToHoldingDetail(BuildContext context, Symbols holdingItem) async {
    await Navigator.push(
        context,
        SlideUpRoute(
            page: BlocProvider<QuoteBloc>(
          create: (context) => QuoteBloc(),
          child: BlocProvider<HoldingsDetailBloc>(
            create: (context) => HoldingsDetailBloc(),
            child: BlocProvider<MarketStatusBloc>(
              create: (context) => MarketStatusBloc(),
              child: BlocProvider<WatchlistBloc>(
                create: (context) => WatchlistBloc(),
                child: HoldingsDetailsScreen(
                  arguments: {
                    'symbolItem': holdingItem,
                    'portfolioWeightage': AppUtils().doubleValue(_holdingsBloc
                                .holdingsFetchDoneState
                                .holdingsModel!
                                .totalInvested) ==
                            0
                        ? AppUtils().decimalValue(0)
                        : AppUtils().decimalValue(
                            (AppUtils().doubleValue(holdingItem.invested) /
                                    AppUtils().doubleValue(_holdingsBloc
                                        .holdingsFetchDoneState
                                        .holdingsModel!
                                        .totalInvested)) *
                                100),
                    'totalInvested': _holdingsBloc
                        .holdingsFetchDoneState.holdingsModel?.totalInvested,
                  },
                ),
              ),
            ),
          ),
        )));
    _holdingsBloc.add(HoldingsFetchEvent(true, loading: false));
    AppStore().setHolding(null);
  }

  Widget _bottomContent(
    Symbols holdingItem,
  ) {
    return _bottomSheetBody(holdingItem);
  }

  Widget _bottomSheetBody(
    Symbols holdingItem,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: 10.w,
        left: 20.w,
        right: 20.w,
        bottom: 10.w,
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: GestureDetector(
                onTap: () async {
                  pushtoHoldingswithPop(context, holdingItem);
                },
                child: AppImages.upArrowIcon(context,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true,
                    width: 30.w,
                    height: 30.w),
              ),
            ),
            _getBottomSheetHeaderWidget(holdingItem),
            _getBottomSheetSegmentWidget(holdingItem),
            buildTableWithBackgroundColor(
              _appLocalizations.netQty,
              holdingItem.qty!,
              _appLocalizations.avgPrice,
              holdingItem.avgPrice!,
              '',
              '',
              context,
              isRupeeSymbol: true,
            ),
            buildTableWithBackgroundColor(
              _appLocalizations.pledgedQty,
              holdingItem.pledgedQty ?? "--",
              _appLocalizations.freeQty,
              holdingItem.freeQty ?? "--",
              '',
              '',
              context,
              isRupeeSymbol: true,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.w),
              child: _buildPresistentFooterWidget(holdingItem),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBottomSheetHeaderWidget(
    Symbols holdingItem,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
            holdingItem.dispSym!,
            Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Row(
            children: [
              SizedBox(
                width: AppWidgetSize.dimen_80,
                child: LabelBorderWidget(
                  keyText: const Key(holdingsBottomSheetStockQuoteKey),
                  text: _appLocalizations.stockQuote,
                  textColor: Theme.of(context).primaryColor,
                  fontSize: AppWidgetSize.fontSize12,
                  margin: EdgeInsets.only(top: AppWidgetSize.dimen_2),
                  borderRadius: AppWidgetSize.dimen_20,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  borderWidth: AppWidgetSize.dimen_1,
                  borderColor: Theme.of(context).dividerColor,
                  isSelectable: true,
                  labelTapAction: () async {
                    await pushNavigation(
                      ScreenRoutes.quoteScreen,
                      arguments: {
                        'symbolItem': holdingItem,
                      },
                    );
                    _holdingsBloc.add(HoldingsFetchEvent(true));
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
                child: GestureDetector(
                  onTap: () {
                    if (groupList!.isEmpty) {
                      _showCreateNewBottomSheet(holdingItem);
                    } else {
                      _showWatchlistGroupBottomSheet(holdingItem);
                    }
                  },
                  child: AppImages.addUnfilledIcon(context,
                      color: AppColors().positiveColor,
                      isColor: true,
                      width: 30.w,
                      height: 30.w),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getBottomSheetSegmentWidget(
    Symbols holdingItem,
  ) {
    return BlocBuilder<HoldingsBloc, HoldingsState>(
      buildWhen: (previous, current) {
        return current is HoldingsFetchDoneState;
      },
      builder: (context, state) {
        return buildBottomSheetSegmentContainer(
          holdingItem,
        );
      },
    );
  }

  Widget buildBottomSheetSegmentContainer(
    Symbols holdingsItem,
  ) {
    return Center(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.only(
          bottom: AppWidgetSize.dimen_20,
          top: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_10,
        ),
        height: AppWidgetSize.dimen_140,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return _buildListBoxContent(
                _appLocalizations.todaysPnL,
                AppUtils().dataNullCheck(holdingsItem.oneDayPnL),
                '(${holdingsItem.oneDayPnLPercent}%)',
                AppUtils().profitLostColor(holdingsItem.oneDayPnL),
                isBottomSheet: true,
              );
            } else {
              return _buildListBoxContent(
                _appLocalizations.ltp,
                holdingsItem.ltp!,
                AppUtils().getChangePercentage(holdingsItem),
                AppUtils().setcolorForChange(holdingsItem.chng ?? ""),
                isBottomSheet: true,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildPresistentFooterWidget(
    Symbols holdingItem,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _getBottomButtonWidget(
            holdingsAddButtonKey,
            _appLocalizations.buy,
            AppColors().positiveColor,
            true,
            holdingItem,
          ),
          SizedBox(width: 20.w),
          _getBottomButtonWidget(
            holdingsExitButtonKey,
            _appLocalizations.sell,
            AppColors.negativeColor,
            false,
            holdingItem,
          ),
        ],
      ),
    );
  }

  Widget _getBottomButtonWidget(
    String key,
    String header,
    Color color,
    bool isGradient,
    Symbols holdingItem,
  ) {
    return GestureDetector(
      key: Key(key),
      onTap: () async {
        if (header == _appLocalizations.buy) {
          _onCallOrderPad(
            _appLocalizations.buy,
            holdingItem,
          );
        } else {
          _onCallOrderPad(
            _appLocalizations.sell,
            holdingItem,
          );
        }
      },
      child: Container(
        width: 150.w,
        height: 50.w,
        padding: EdgeInsets.all(10.w),
        decoration: isGradient
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(25.w),
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
                borderRadius: BorderRadius.circular(30.w),
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

  Widget _getLableWithRupeeSymbol(
      String value, TextStyle rupeeStyle, TextStyle textStyle,
      {bool showShimmer = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextWidget(
          (showShimmer ? AppConstants.rupeeSymbol : "") + value,
          textStyle,
          isShowShimmer: showShimmer,
        ),
      ],
    );
  }

  void _showWatchlistGroupBottomSheet(
    Symbols symbolItem,
  ) {
    Navigator.of(context).pop();

    showInfoBottomsheet(
        ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(AppWidgetSize.dimen_20),
            ),
            child: BlocProvider<QuoteBloc>.value(
              value: quoteBloc,
              child: ChooseWatchlistWidget(
                arguments: {
                  'symbolItem': symbolItem,
                  'groupList': groupList,
                },
              ),
            )),
        bottomMargin: 0,
        topMargin: false,
        height: (AppUtils().chooseWatchlistHeight(groupList ?? []) <
                (AppWidgetSize.screenHeight(context) * 0.8))
            ? AppUtils().chooseWatchlistHeight(groupList ?? [])
            : (AppWidgetSize.screenHeight(context) * 0.8),
        horizontalMargin: false);
  }

  Future<void> _showCreateNewBottomSheet(
    Symbols symbolItem,
  ) async {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
      ),
      builder: (BuildContext bct) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(AppWidgetSize.dimen_20),
              ),
            ),
            padding: EdgeInsets.fromLTRB(AppWidgetSize.dimen_20,
                AppWidgetSize.dimen_20, AppWidgetSize.dimen_20, 0),
            child: BlocProvider<QuoteBloc>.value(
              value: quoteBloc,
              child: CreateNewWatchlistWidget(
                arguments: {
                  'symbolItem': symbolItem,
                  'groupList': groupList,
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> sortSheet() async {
    showInfoBottomsheet(StatefulBuilder(
        builder: (BuildContext context, StateSetter updateState) {
      return SortFilterWidget(
        screenName: ScreenRoutes.holdingsScreen,
        onDoneCallBack: (s, f) {
          onDoneCallBack(s, f);
          updateState(() {});
        },
        onClearCallBack: () {
          onClearCallBack();
          updateState(() {});
        },
        selectedSort: selectedSort,
        selectedFilters: selectedFilters,
      );
    }), horizontalMargin: false);
  }

  //Functions

  void onDoneCallBack(
    SortModel selectedSortModel,
    List<FilterModel> filterList,
  ) {
    selectedSort = selectedSortModel;
    selectedFilters = filterList;
    unsubscribeLevel1Streaming();
    holdingsApiCallWithFilters(
      filterList,
      selectedSortModel,
    );
  }

  void onClearCallBack() {
    selectedFilters = getFilterModel();
    selectedSort = SortModel();
    unsubscribeLevel1Streaming();
    _holdingsBloc.holdingsFetchDoneState.isFilterSelected = false;
    _holdingsBloc.holdingsFetchDoneState.isSortSelected = false;
    _holdingsBloc.holdingsFetchDoneState.selectedSortBy = null;
    _holdingsBloc.holdingsFetchDoneState.selectedSortBy = null;

    holdingsApiCallWithFilters(
      selectedFilters,
      selectedSort,
    );
  }

  void unsubscribeLevel1Streaming() {
    unsubscribeLevel1();
  }

  void setOrdDetailsForEdisVerify(
    List<Symbols>? holdings,
  ) {
    ordDetails = [];
    List<OrderDetails> tempOrdDetails = [];
    for (Symbols element in holdings!) {
      tempOrdDetails.add(OrderDetails(isin: element.isin, qty: element.qty));
    }
    ordDetails = tempOrdDetails;
  }

  Future<void> onPlaceOrderTapped() async {
    unsubscribeLevel1();
    await pushNavigation(
      ScreenRoutes.searchScreen,
      arguments: {
        'watchlistBloc': watchlistBloc,
      },
    );
    _holdingsBloc.add(HoldingsFetchEvent(true));
    await fetchHoldings();
  }

  void onViewReportsTapped() {}

  Future<void> _onCallOrderPad(
    String action,
    Symbols symbolItem,
  ) async {
    popNavigation();
    await pushNavigation(
      ScreenRoutes.orderPadScreen,
      arguments: {
        'action': action,
        'symbolItem': symbolItem,
        AppConstants.holdingsNavigation:
            action == _appLocalizations.sell ? symbolItem.qty : null,
      },
    );
    _holdingsBloc.add(HoldingsFetchEvent(true));
  }

  Future<void> checkToShowNote() async {
    bool showHoldingNote =
        await AppStorage().getData(AppConstants.showHoldingsNote) ?? true;
    closeNote.value = !showHoldingNote;
  }
}
