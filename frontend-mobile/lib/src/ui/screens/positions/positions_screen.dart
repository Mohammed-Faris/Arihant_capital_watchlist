import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:rxdart/rxdart.dart';

import '../../../blocs/holdings/holdings/holdings_bloc.dart';
import '../../../blocs/my_funds/add_funds/add_funds_bloc.dart';
import '../../../blocs/my_funds/funds/my_funds_bloc.dart' as my_funds;
import '../../../blocs/positions/position_conversion/position_convertion_bloc.dart';
import '../../../blocs/positions/positions/positions_bloc.dart';
import '../../../blocs/positions/positions_detail/positions_detail_bloc.dart';
import '../../../blocs/quote/main_quote/quote_bloc.dart';
import '../../../blocs/watchlist/watchlist_bloc.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_events.dart';
import '../../../constants/keys/positions_keys.dart';
import '../../../constants/keys/quote_keys.dart';
import '../../../data/repository/my_account/my_account_repository.dart';
import '../../../data/store/app_storage.dart';
import '../../../data/store/app_store.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/sym_model.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/my_funds/my_fund_view_updated_model.dart';
import '../../../models/positions/positions_model.dart';
import '../../../models/sort_filter/sort_filter_model.dart';
import '../../../models/watchlist/watchlist_group_model.dart';
import '../../../notifiers/notifiers.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../validator/input_validator.dart';
import '../../widgets/build_empty_widget.dart';
import '../../widgets/choose_watchlist_widget.dart';
import '../../widgets/circular_toggle_button_widget.dart';
import '../../widgets/create_new_watchlist_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/fandotag.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/label_border_text_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/refresh_widget.dart';
import '../../widgets/sort_filter_widget.dart';
import '../../widgets/table_with_bgcolor.dart';
import '../base/base_screen.dart';
import '../quote/widgets/routeanimation.dart';
import 'positions_convert_sheet.dart';
import 'positions_detail_screen.dart';

class PositionsScreen extends BaseScreen {
  const PositionsScreen(this.searchFocusNode, {Key? key}) : super(key: key);
  final FocusNode searchFocusNode;
  @override
  PositionsScreenState createState() => PositionsScreenState();
}

class PositionsScreenState extends BaseAuthScreenState<PositionsScreen>
    with TickerProviderStateMixin {
  late AppLocalizations _appLocalizations;
  late PositionsBloc _positionsBloc;
  late QuoteBloc quoteBloc;
  late WatchlistBloc watchlistBloc;
  late AddFundsBloc addFundsBloc;
  List<Groups>? groupList = <Groups>[];
  final ValueNotifier<int> selectedHeaderIndex = ValueNotifier<int>(0);

  late final SearchNotifier _searchNotifier = SearchNotifier(false);
  BehaviorSubject<bool> reachedTop = BehaviorSubject.seeded(false);
  late double kMaxSheetHeight;
  late double kMinSheetHeight;
  final TextEditingController _searchController =
      TextEditingController(text: '');

  SortModel selectedSort = SortModel();
  List<FilterModel> selectedFilters = <FilterModel>[];

  bool refreshPostions = false;
  Timer? timer;
  @override
  void initState() {
    selectedFilters = getFilterModel();
    _positionsBloc = BlocProvider.of<PositionsBloc>(context)
      ..stream.listen(_positionsListener);
    quoteBloc = BlocProvider.of<QuoteBloc>(context)
      ..stream.listen(quoteListener);
    watchlistBloc = BlocProvider.of<WatchlistBloc>(context)
      ..stream.listen(watchlistListener);
    addFundsBloc = BlocProvider.of<AddFundsBloc>(context);
    if (AppConfig.refreshTime != 0) {
      timer = Timer.periodic(Duration(seconds: AppConfig.refreshTime), (timer) {
        if (positionFetchDone && isScreenCurrent()) {
          positionsApiCallWithFilters(selectedFilters, selectedSort,
              loading: false, fetchagain: true);
        }
      });
    }
    _buildAddPostFrameCallback(context, loading: false);
    BlocProvider.of<my_funds.MyFundsBloc>(context)
        .add(my_funds.GetFundsViewUpdatedEvent());
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.positionScreen);
  }

  bool positionFetchDone = false;

  Future<void> _buildAddPostFrameCallback(BuildContext context,
      {bool loading = true}) async {
    positionsApiCallWithFilters(
      selectedFilters,
      selectedSort,
      fetchagain: true,
      loading: loading,
    );
    addFundsBloc.add(GetFundsViewEvent(fetchApi: true));
    watchlistBloc.add(WatchlistGetGroupsEvent(false));
  }

  Future<void> positionsApiCallWithFilters(
      List<FilterModel> filterModel, SortModel sortModel,
      {bool fetchagain = false, bool loading = true}) async {
    _positionsBloc.add(FetchPositionsEvent(
        filterModel,
        selectedSort,
        [
          AppLocalizations().overall,
          AppLocalizations().day,
        ][selectedtypeIndex],
        loading: loading,
        fetchAgain: fetchagain,
        searchString: _searchController.text));
  }

  int selectedtypeIndex = 0;
  Widget _buildPositionTypeWidget(
    BuildContext context,
  ) {
    return SizedBox(
      height: AppWidgetSize.dimen_40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircularButtonToggleWidget(
              value: [
                AppLocalizations().overallPosition,
                AppLocalizations().dayPosition,
              ][selectedtypeIndex],
              toggleButtonlist: [
                AppLocalizations().overallPosition,
                AppLocalizations().dayPosition,
              ].map((s) => s as dynamic).toList(),
              toggleButtonOnChanged: toggleButtonOnChanged,
              toggleChanged: (value) {
                selectedtypeIndex = value;
                positionsApiCallWithFilters(selectedFilters, selectedSort,
                    fetchagain: true, loading: true);
                setState(() {});
              },
              key: const Key("PositionType"),
              defaultSelected: '',
              enabledButtonlist: const [],
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
                AppWidgetSize.dimen_8,
                AppWidgetSize.dimen_3,
                AppWidgetSize.dimen_8,
                AppWidgetSize.dimen_3,
              ),
              fontSize: 16.w,
            ),
          ],
        ),
      ),
    );
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
  }

  @override
  void dispose() {
    screenFocusOut();
    timer?.cancel();
    super.dispose();
  }

  Future<void> _positionsListener(PositionsState state) async {
    if (state is! PositionsProgressState) {
      if (mounted) {}
    }
    if (state is PositionsProgressState) {
      if (mounted) {}
    } else if (state is PositionsStartStreamState) {
      subscribeLevel1(state.streamDetails);
      if (showAnnouncementFirstTime) {
        showAnnouncementFirstTime = false;
        Future.delayed(const Duration(seconds: 1), () {
          showAnnouncement.value = true;
          Future.delayed(const Duration(seconds: 4), () {
            showAnnouncement.value = false;
          });
        });
      }
    } else if (state is PositionsFailedState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state is PositionsErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state is PositionsDoneState) {
      positionFetchDone = true;
    }
  }

  bool showAnnouncementFirstTime = true;

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

  Future<void> quoteListener(QuoteState state) async {
    if (state is! QuoteProgressState) {
      if (mounted) {
        stopLoader();
      }
    }
    if (state is QuoteProgressState) {
      if (mounted) {
        startLoader();
      }
    } else if (state is QuotedeleteDoneState) {
      showToast(
        message: state.messageModel,
        context: context,
      );
      setState(() {});
    } else if (state is QuoteAddSymbolFailedState ||
        state is QuotedeleteSymbolFailedState) {
      setState(() {});
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
      watchlistBloc.add(WatchlistGetGroupsEvent(false));
    } else if (state is QuoteErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  @override
  void quote1responseCallback(ResponseData data) {
    _positionsBloc.add(PositionsStreamingResponseEvent(data));
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.positionScreen;
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        body: RefreshWidget(
          onRefresh: () async {
            await _buildAddPostFrameCallback(context);
          },
          child: BlocBuilder<PositionsBloc, PositionsState>(buildWhen: (
            PositionsState prevState,
            PositionsState currentState,
          ) {
            return currentState is PositionsDoneState ||
                currentState is PositionsFailedState ||
                currentState is PositionsErrorState ||
                currentState is PositionsProgressState ||
                currentState is PositionsServiceExceptionState;
          }, builder: (context, state) {
            if (state is PositionsProgressState) {
              return SizedBox(
                  height: AppWidgetSize.screenHeight(context) -
                      AppWidgetSize.dimen_120,
                  child: const LoaderWidget());
            }
            if (state is PositionsDoneState) {
              if (AppStore().getSelectedPosition() != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  Positions? position = state.positionsModel!.positions!
                      .firstWhereOrNull((element) =>
                          element.dispSym ==
                              AppStore().getSelectedPosition()?.dispSym &&
                          element.prdType ==
                              AppStore().getSelectedPosition()?.prdType);
                  AppStore().setPosition(null);
                  if (position != null) {
                    await pushtoPositionDetailScreen(
                      context,
                      position,
                      AppUtils().doubleValue(position.netQty) != 0,
                    );
                  }
                  positionsApiCallWithFilters(
                    selectedFilters,
                    selectedSort,
                    fetchagain: true,
                  );
                });
              }

              return _buildPositions(
                context,
                state.positionsModel!.positions ?? [],
                state,
              );
            } else if (state is PositionsFailedState ||
                state is PositionsErrorState) {
              if (selectedFilters[0].filters != null &&
                  selectedFilters[0].filters!.isEmpty &&
                  selectedFilters[1].filters != null &&
                  selectedFilters[1].filters!.isEmpty &&
                  selectedFilters[2].filters != null &&
                  selectedFilters[2].filters!.isEmpty &&
                  selectedFilters[3].filters != null &&
                  selectedFilters[3].filters!.isEmpty) {
                return _buildEmptyPositionsWidget();
              } else {
                return _buildPositions(
                  context,
                  [],
                  null,
                );
              }
            } else if (state is PositionsServiceExceptionState) {
              return SingleChildScrollView(
                child: SizedBox(
                  height: AppWidgetSize.fullHeight(context) - 200.w,
                  child: errorWithImageWidget(
                    context: context,
                    imageWidget: AppUtils().getNoDateImageErrorWidget(context),
                    errorMessage: state.errorMsg,
                    padding: EdgeInsets.only(
                      top: AppWidgetSize.dimen_1,
                    ),
                  ),
                ),
              );
            }

            return Container();
          }),
        ),
        bottomNavigationBar: AppUtils().labelBorderWidgetBottom(
          AppLocalizations().viewboReports,
          AppImages.analyticsIcon(context, height: AppWidgetSize.dimen_15),
          () async {
            String? ssoUrl = await MyAccountRepository().getSSO();

            await InAppBrowser.openWithSystemBrowser(url: Uri.parse(ssoUrl));
          },
        ),
      ),
    );
  }

  ValueNotifier<bool> showAnnouncement = ValueNotifier<bool>(false);

  Widget _buildPositions(
    BuildContext context,
    List<Positions> positions,
    PositionsDoneState? state,
  ) {
    return ValueListenableBuilder(
      valueListenable: _searchNotifier,
      builder: (BuildContext context, bool value, Widget? child) {
        return SingleChildScrollView(
          controller: statelessControllerA,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (!value)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: showAnnouncement,
                      builder: (context, value, _) {
                        return state != null &&
                                value &&
                                (state.positionsModel?.positions?.isNotEmpty ??
                                    false) &&
                                AppUtils().doubleValue(state.overallTodayPnL) !=
                                    0
                            ? _buildAnnocementWidget(state)
                            : Container();
                      },
                    ),
                    _buildTopContentWidget(state),
                  ],
                ),
              _buildBodyContentWidget(
                context,
                positions,
                value,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyPositionsWidget() {
    return ListView(
      children: [
        SizedBox(
          height: AppWidgetSize.screenHeight(context) - AppWidgetSize.dimen_200,
          child: buildEmptyWidget(
            context: context,
            description1: _appLocalizations.emptyPositionsDescriptions1,
            description2: _appLocalizations.emptyPositionsDescriptions2,
            buttonInRow: false,
            button1Title: _appLocalizations.placeOrder,
            button2Title: "",
            onButton1Tapped: onPlaceOrderTapped,
          ),
        ),
      ],
    );
  }

  void onViewHoldingsTapped() {
    pushAndRemoveUntilNavigation(
      ScreenRoutes.homeScreen,
      arguments: {
        'pageName': ScreenRoutes.tradesScreen,
        'selectedIndex': 2,
      },
    );
  }

  Widget _buildAnnocementWidget(
    PositionsDoneState state,
  ) {
    return Container(
      height: AppWidgetSize.dimen_30,
      width: AppWidgetSize.fullWidth(context),
      color: AppUtils().doubleValue(state.overallTodayPnL).isNegative
          ? Theme.of(context).colorScheme.onSecondary.withOpacity(0.2)
          : Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.5),
      child: Padding(
        padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_5,
          left: AppWidgetSize.dimen_30,
        ),
        child: CustomTextWidget(
          AppUtils().doubleValue(state.overallTodayPnL).isNegative
              ? _appLocalizations.positionLossAnnocementText
              : _appLocalizations.positionProfitAnnocementText,
          Theme.of(context).primaryTextTheme.bodySmall,
        ),
      ),
    );
  }

  Widget _buildTopContentWidget(
    PositionsDoneState? state,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_20,
      ),
      child: Container(
        height: AppWidgetSize.getSize(AppWidgetSize.dimen_110),
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_5,
          bottom: AppWidgetSize.dimen_5,
        ),
        child: _buildTopContentListViewWidget(state),
      ),
    );
  }

  Widget _buildTopContentListViewWidget(
    PositionsDoneState? state,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: selectedtypeIndex == 0 ? 3 : 2,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _buildListBoxContent(
            _appLocalizations.todaysPnL,
            state?.overallTodayPnL != null
                ? AppUtils().dataNullCheck(state?.overallTodayPnL)
                : '--',
            state?.overallTodayPnLPercent != null
                ? '(${AppUtils().dataNullCheck(state?.overallTodayPnLPercent)}%)'
                : '--',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headingSubjectWidget('', [
                  TextSpan(
                      text:
                          "A ${_appLocalizations.todaysPnL} ${_appLocalizations.todayPnlInfodescription1}")
                ]),
                Padding(
                  padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_10),
                  child: CustomTextWidget(
                    "For stocks purchased today,",
                    Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                ),
                CustomTextWidget(
                    "${_appLocalizations.todaysPnL} = (Current LTP – Today’s average trade price) * Quantity",
                    Theme.of(context)
                        .primaryTextTheme
                        .labelSmall!
                        .copyWith(fontWeight: FontWeight.w600)),
                headingSubjectWidget("", [
                  const TextSpan(
                      text:
                          "For F&O positions, your 1-day return would be net of current market price and your buying/selling average (or yesterday’s close if it is a carry-forward position).")
                ]),
              ],
            ),
            state != null &&
                    (state.positionsModel?.positions?.isNotEmpty ?? false)
                ? AppUtils().profitLostColor(state.overallTodayPnL)
                : Theme.of(context).primaryTextTheme.labelLarge!.color!,
          );
        } else if (index == 1 && selectedtypeIndex != 1) {
          return Featureflag.showOverallPnl
              ? _buildListBoxContent(
                  _appLocalizations.overallPL,
                  state?.overallPnL != null
                      ? AppUtils().dataNullCheck(state?.overallPnL)
                      : '--',
                  state?.overallPnLPercent != null
                      ? '(${AppUtils().dataNullCheck(state?.overallPnLPercent)}%)'
                      : '--',
                  Column(
                    children: [
                      headingSubjectWidget('', [
                        TextSpan(
                            text:
                                "${_appLocalizations.overallPL} ${_appLocalizations.overallPnlDescription1}")
                      ]),
                      headingSubjectWidget(
                          _appLocalizations.overallPnlInfoSubheading1, [
                        TextSpan(
                            text:
                                "${_appLocalizations.overallPL} ${_appLocalizations.overallPnlFormula}",
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                    ],
                  ),
                  state != null &&
                          (state.positionsModel?.positions?.isNotEmpty ?? false)
                      ? AppUtils().profitLostColor(state.overallPnL)
                      : Theme.of(context).primaryTextTheme.labelLarge!.color!,
                  initialChildSize: 0.4)
              : Container();
        } else {
          return _buildBuyPowerData();
        }
      },
    );
  }

  Widget _buildBuyPowerData() {
    return BlocBuilder<AddFundsBloc, AddFundsState>(
      buildWhen: (previous, current) {
        return current is AddFundBuyPowerandWithdrawcashDoneState;
      },
      builder: (context, state) {
        if (state is AddFundBuyPowerandWithdrawcashDoneState) {
          return _buildListBoxContent(
            _appLocalizations.buyingPower,
            state.buy_power,
            '',
            null,
            Theme.of(context).primaryTextTheme.labelLarge!.color!,
          );
        }
        return _buildListBoxContent(
          _appLocalizations.buyingPower,
          '--',
          '',
           Column(
            children: const [],
          ),
          Theme.of(context).primaryTextTheme.labelLarge!.color!,
        );
      },
    );
  }

  Widget _buildListBoxContent(
    String title,
    String value,
    String subValue,
    Widget? infoChild,
    Color color, {
    double? initialChildSize,
    bool isBottomSheet = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
        right: isBottomSheet ? AppWidgetSize.dimen_10 : AppWidgetSize.dimen_20,
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
        child: _getListBoxWidget(
          title,
          value,
          subValue,
          infoChild,
          color,
          initialChildSize: initialChildSize,
          isBottomSheet: isBottomSheet,
        ),
      ),
    );
  }

  Widget _getListBoxWidget(
    String title,
    String value,
    String subValue,
    Widget? infoChild,
    Color color, {
    double? initialChildSize,
    bool isBottomSheet = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_5,
        right: AppWidgetSize.dimen_5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextWidget(
                        AppUtils().dataNullCheck(title),
                        Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                _getLableWithRupeeSymbol(
                    AppUtils().dataNullCheckDashDash(value),
                    Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.interFont,
                          color: color,
                        ),
                    Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                    showShimmer: _positionsBloc.positionsDoneState
                            .positionsModel?.positions?.isNotEmpty ??
                        false),
                Padding(
                  padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_5,
                  ),
                  child: subValue == ''
                      ? SizedBox(
                          width: AppWidgetSize.dimen_70,
                          child: LabelBorderWidget(
                            keyText: const Key(positionsViewFundsKey),
                            text: _appLocalizations.viewFunds,
                            textColor: Theme.of(context).primaryColor,
                            fontSize: AppWidgetSize.fontSize12,
                            margin: EdgeInsets.only(top: AppWidgetSize.dimen_2),
                            borderRadius: AppWidgetSize.dimen_20,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            borderWidth: 1,
                            borderColor: Theme.of(context).dividerColor,
                            isSelectable: true,
                            labelTapAction: () {
                              pushAndRemoveUntilNavigation(
                                ScreenRoutes.homeScreen,
                                arguments: {
                                  'pageName': ScreenRoutes.myfundsScreen,
                                },
                              );
                            },
                          ),
                        )
                      : CustomTextWidget(
                          subValue,
                          Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          isShowShimmer: _positionsBloc.positionsDoneState
                                  .positionsModel?.positions?.isNotEmpty ??
                              false),
                )
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              if (infoChild != null) {
                infoIconsheet(initialChildSize, title, infoChild);
              } else {
                dynamic data =
                    await AppStorage().getData('getFundViewUpdatedModel');

                FundViewUpdatedModel fundViewUpdatedModel =
                    FundViewUpdatedModel.datafromJson(data);

                debugPrint(
                    'fundViewUpdatedModel.aLLFD -> ${fundViewUpdatedModel.aLLFD}');

                pushNavigation(
                  ScreenRoutes.buyPowerInfoScreen,
                  arguments: {"fundmodeldata": fundViewUpdatedModel},
                );
              }
            },
            child: Padding(
              padding: EdgeInsets.only(
                top: isBottomSheet
                    ? AppWidgetSize.dimen_7
                    : AppWidgetSize.dimen_13,
              ),
              child: AppImages.informationIcon(
                context,
                color: Theme.of(context).primaryIconTheme.color,
                isColor: true,
                width: AppWidgetSize.dimen_22,
                height: AppWidgetSize.dimen_22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  infoIconsheet(double? initialChildSize, String title, Widget infoChild) {
    return showInfoBottomsheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                title,
                Theme.of(context).primaryTextTheme.titleMedium,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: AppImages.closeIcon(
                  context,
                  width: AppWidgetSize.dimen_20,
                  height: AppWidgetSize.dimen_20,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true,
                ),
              )
            ],
          ),
          Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_20,
              ),
              child: infoChild),
        ],
      ),
    );
  }

  Widget headingSubjectWidget(String heading, List<TextSpan> subject,
      {double? padding}) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: padding ?? AppWidgetSize.dimen_10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heading != "")
            CustomTextWidget(
                heading,
                Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.justify),
          Padding(
              padding: EdgeInsets.symmetric(
                  vertical: padding ?? AppWidgetSize.dimen_10),
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: Theme.of(context).primaryTextTheme.labelSmall,
                  children: subject,
                ),
              )),
        ],
      ),
    );
  }

  ScrollController statelessControllerA = ScrollController();

  Widget _buildBodyContentWidget(
    BuildContext context,
    List<Positions> positions,
    bool value,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_25,
        right: AppWidgetSize.dimen_30,
        bottom: AppWidgetSize.dimen_20,
      ),
      child: Column(
        children: [
          if (!value) _buildBodyContentToolBarWidget(),
          Padding(
            padding: EdgeInsets.only(left: AppWidgetSize.dimen_5),
            child: Column(
              children: [
                if (value) _buildSearchTextBox(positions),
                BlocBuilder<PositionsBloc, PositionsState>(
                  builder: (context, state) {
                    if (state is PositionsSearchProgressState) {
                      return const LoaderWidget();
                    } else if (state is PositionsChangeState) {
                      return Container();
                    }
                    return Column(
                      children: [
                        _buildExpansionRow(
                            context,
                            _appLocalizations.open,
                            _buildPositionsListWidget(
                                context,
                                _sortOpenPositions(
                                  positions,
                                ),
                                true,
                                value),
                            _sortOpenPositions(
                              positions,
                            ).length,
                            value,
                            _positionsBloc.positionsDoneState.positionsModel
                                    ?.positions ??
                                []),
                        _buildExpansionRow(
                            context,
                            _appLocalizations.ordStatusClosed,
                            _buildPositionsListWidget(
                                context,
                                _sortClosedPositions(
                                  positions,
                                ),
                                false,
                                value),
                            _sortClosedPositions(
                              positions,
                            ).length,
                            value,
                            _positionsBloc.positionsDoneState.positionsModel
                                    ?.positions ??
                                []),
                      ],
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Positions> _sortClosedPositions(
    List<Positions> positions,
  ) {
    List<Positions> closePositions = [];
    for (var element in positions) {
      if (AppUtils().intValue(element.netQty) == 0) {
        closePositions.add(element);
      }
    }
    return closePositions;
  }

  List<Positions> _sortOpenPositions(
    List<Positions> positions,
  ) {
    List<Positions> openPositions = [];
    for (var element in positions) {
      if (AppUtils().intValue(element.netQty) != 0) {
        openPositions.add(element);
      }
    }
    return openPositions;
  }

  Widget _buildBodyContentToolBarWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
        bottom: AppWidgetSize.dimen_10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              // width: AppWidgetSize.screenWidth(context) / 1.6,
              child: _buildPositionTypeWidget(context)),
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
                isSelected: isFilterSelected() ||
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
          onTap: () => {
            _searchNotifier.changeSearchBar(true),
            widget.searchFocusNode.requestFocus()
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

  bool isFilterSelected() {
    for (FilterModel filterModel in selectedFilters) {
      if (filterModel.filters != null) {
        for (String filters in filterModel.filters!) {
          if (filters.isNotEmpty) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Widget _buildSearchTextBox(
    List<Positions> positions,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
        bottom: AppWidgetSize.dimen_10,
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
                positionsApiCallWithFilters(selectedFilters, selectedSort,
                    fetchagain: false, loading: false);
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
                  _searchNotifier.value = false;
                  _searchController.text = '';
                  positionsApiCallWithFilters(selectedFilters, selectedSort,
                      fetchagain: false, loading: false);
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

  Widget _buildPositionsListWidget(BuildContext context,
      List<Positions> positions, bool isOpen, bool isSearch) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_10),
          child: isOpen
              ? ValueListenableBuilder<int>(
                  valueListenable: selectedHeaderIndex,
                  builder: (BuildContext context, int value, Widget? child) {
                    return GestureDetector(
                      onTap: () {
                        onTypeChange();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(right: AppWidgetSize.dimen_5),
                            child: AppImages.swapIcon(
                              context,
                              width: AppWidgetSize.dimen_16,
                              height: AppWidgetSize.dimen_18,
                            ),
                          ),
                          CustomTextWidget(
                            selectedtypeIndex == 0
                                ? (selectedHeaderIndex.value == 0
                                    ? _appLocalizations.oneDayPLChange
                                    : selectedHeaderIndex.value == 1
                                        ? _appLocalizations.overallPnL
                                        : _appLocalizations.getCurrent)
                                : selectedHeaderIndex.value == 0
                                    ? _appLocalizations.oneDayPLChange
                                    : _appLocalizations.getCurrent,
                            Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(
                                    fontSize: AppWidgetSize.fontSize14,
                                    color: const Color(0xFF797979)),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : ValueListenableBuilder<int>(
                  valueListenable: selectedHeaderIndex,
                  builder: (BuildContext context, int value, Widget? child) {
                    return GestureDetector(
                      onTap: () {
                        onTypeChange();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(right: AppWidgetSize.dimen_5),
                            child: AppImages.swapIcon(
                              context,
                              width: AppWidgetSize.dimen_16,
                              height: AppWidgetSize.dimen_18,
                            ),
                          ),
                          CustomTextWidget(
                            selectedtypeIndex == 0
                                ? (selectedHeaderIndex.value == 0
                                    ? _appLocalizations.oneDayPLChange
                                    : selectedHeaderIndex.value == 1
                                        ? _appLocalizations.overallPnL
                                        : _appLocalizations.getCurrent)
                                : selectedHeaderIndex.value == 0
                                    ? _appLocalizations.oneDayPLChange
                                    : _appLocalizations.getCurrent,
                            Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(
                                    fontSize: AppWidgetSize.fontSize14,
                                    color: const Color(0xFF797979)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              positions.isNotEmpty
                  ? ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      shrinkWrap: true,
                      itemCount: positions.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return _buildRowWidget(
                          context,
                          index,
                          positions[index],
                          isOpen,
                        );
                      },
                    )
                  : errorWithImageWidget(
                      context: context,
                      height: isSearch
                          ? AppWidgetSize.dimen_350
                          : AppWidgetSize.dimen_250,
                      imageWidget:
                          AppUtils().getNoDateImageErrorWidget(context),
                      errorMessage: isSearch
                          ? AppLocalizations().oopsNoresults
                          : AppLocalizations().noDataAvailableErrorMessage,
                      childErrorMsg:
                          isSearch ? AppLocalizations().trywithdiffFilter : "",
                      padding: EdgeInsets.only(
                        left: AppWidgetSize.dimen_30,
                        right: AppWidgetSize.dimen_30,
                        bottom: AppWidgetSize.dimen_30,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  void onTypeChange() {
    if (selectedtypeIndex == 1) {
      if (selectedHeaderIndex.value == 0) {
        selectedHeaderIndex.value = 1;
      } else {
        selectedHeaderIndex.value = 0;
      }
    } else {
      if (selectedHeaderIndex.value < 2) {
        selectedHeaderIndex.value++;
        if (!Featureflag.showOverallPnl &&
            selectedHeaderIndex.value == 1 &&
            selectedtypeIndex == 1) {
          selectedHeaderIndex.value = 1;
        } else if (!Featureflag.showOverallPnl &&
            selectedHeaderIndex.value == 1) {
          selectedHeaderIndex.value = 2;
        }
      } else {
        selectedHeaderIndex.value = 0;
      }
    }
  }

  Widget _buildRowWidget(
    BuildContext context,
    int index,
    Positions positions,
    bool isOpen,
  ) {
    return Container(
      alignment: Alignment.centerLeft,
      width: AppWidgetSize.fullWidth(context) - 10,
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: InkWell(
                  onTap: () {
                    showPositionsBottomSheet(
                      positions,
                      isOpen,
                    );
                  },
                  child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: _buildLeftRowWidget(index, positions)))),
          TextButton(
            onPressed: () {
              onTypeChange();
            },
            style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.all(0)),
                overlayColor: MaterialStateProperty.all<Color>(Theme.of(context)
                    .dialogBackgroundColor
                    .withOpacity(0.1))), // <-- Does not work

            child: _buildRightRowWidget(
              context,
              index,
              positions,
              isOpen,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLeftRowWidget(
    int index,
    Positions positions,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    constraints: BoxConstraints(
                        maxWidth: AppWidgetSize.screenWidth(context) * 0.4),
                    height: AppWidgetSize.dimen_25,
                    child: CustomTextWidget(
                        (positions.sym?.optionType != null)
                            ? '${positions.baseSym} '
                            : AppUtils().dataNullCheck(positions.dispSym),
                        Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.left,
                        textOverflow: TextOverflow.ellipsis)),
                //                  Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 5.w),
                //   child: AppUtils.weekly(positions, context),
                // ),
                FandOTag(
                  positions,
                ),
              ],
            ),
            Padding(
                padding: EdgeInsets.only(
                  bottom: AppWidgetSize.dimen_8,
                ),
                child: Row(
                  children: [
                    getLableBorderWidget(
                        positionsSymbolRowProductTypeKey + index.toString(),
                        positions.prdType.toString(),
                        position: positions),
                  ],
                )),
            _getLabelWithRupeeAndValue(
                (positions.netQty.withMultiplierTrade(
                  positions.sym,
                )),
                ' ${_appLocalizations.qty} @ ',
                positions.avgPrice!,
                MainAxisAlignment.start,
                key: const Key("positionQtyKey")),
          ],
        ),
      ],
    );
  }

  Widget _getLabelWithRupeeAndValue(String netQty, String lableTitle,
      String value, MainAxisAlignment mainAxisAlignment,
      {Key? key}) {
    return Row(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        CustomTextWidget(
          netQty,
          Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                color: AppUtils().intValue(netQty) >= 0
                    ? Theme.of(context).colorScheme.primary
                    : Colors.orange,
              ),
        ),
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

  Widget _getLableWithRupeeSymbol(
      String value, TextStyle rupeeStyle, TextStyle textStyle,
      {bool showShimmer = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextWidget(
          AppConstants.rupeeSymbol + value,
          textStyle,
          isShowShimmer: showShimmer,
        ),
      ],
    );
  }

  Widget _buildRightRowWidget(
    BuildContext context,
    int index,
    Positions positions,
    bool isOpen,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ValueListenableBuilder(
          valueListenable: selectedHeaderIndex,
          builder: (
            BuildContext ctx,
            int value,
            Widget? child,
          ) {
            String data = selectedtypeIndex == 0
                ? (selectedHeaderIndex.value == 0
                    ? AppUtils().dataNullCheck(positions.oneDayPnL)
                    : selectedHeaderIndex.value == 1
                        ? AppUtils().dataNullCheck(positions.overallPnL)
                        : AppUtils().commaFmt(
                            AppUtils()
                                .doubleValue(positions.currentValue)
                                .abs()
                                .toStringAsFixed(AppUtils()
                                    .getDecimalpoint(positions.sym!.exc)),
                            decimalPoint:
                                AppUtils().getDecimalpoint(positions.sym!.exc)))
                : (selectedHeaderIndex.value == 0
                    ? AppUtils().dataNullCheck(positions.oneDayPnL)
                    : AppUtils().commaFmt(
                        AppUtils()
                            .doubleValue(positions.currentValue)
                            .abs()
                            .toStringAsFixed(
                                AppUtils().getDecimalpoint(positions.sym!.exc)),
                        decimalPoint:
                            AppUtils().getDecimalpoint(positions.sym!.exc)));
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    bottom: AppWidgetSize.dimen_5,
                    left: AppWidgetSize.dimen_2,
                  ),
                  child: CustomTextWidget(
                    data == "" ? "" : "${AppConstants.rupeeSymbol} $data",
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selectedtypeIndex == 0
                              ? (selectedHeaderIndex.value == 0
                                  ? AppUtils().setColorForText(AppUtils()
                                      .dataNullCheck(positions.oneDayPnL))
                                  : selectedHeaderIndex.value == 1
                                      ? AppUtils().setColorForText(AppUtils()
                                          .dataNullCheck(positions.overallPnL))
                                      : (AppUtils().doubleValue(
                                                  positions.currentValue) ==
                                              0)
                                          ? AppColors.labelColor
                                          : AppUtils().intValue(positions.netQty) >=
                                                  0
                                              ? (AppUtils().doubleValue(positions.currentValue) <
                                                      AppUtils().doubleValue(
                                                          positions.invested))
                                                  ? AppColors.negativeColor
                                                  : AppColors().positiveColor
                                              : (AppUtils().doubleValue(positions.currentValue) >
                                                      AppUtils().doubleValue(
                                                          positions.invested))
                                                  ? AppColors.negativeColor
                                                  : AppColors().positiveColor)
                              : (selectedHeaderIndex.value == 0
                                  ? AppUtils().setColorForText(
                                      AppUtils().dataNullCheck(positions.oneDayPnL))
                                  : (AppUtils().doubleValue(positions.currentValue) == 0)
                                      ? AppColors.labelColor
                                      : AppUtils().intValue(positions.netQty) >=
                                                  0
                                              ? (AppUtils().doubleValue(positions.currentValue) <
                                                      AppUtils().doubleValue(
                                                          positions.invested))
                                                  ? AppColors.negativeColor
                                                  : AppColors().positiveColor
                                              : (AppUtils().doubleValue(positions.currentValue) >
                                                      AppUtils().doubleValue(
                                                          positions.invested))
                                                  ? AppColors.negativeColor
                                                  : AppColors().positiveColor),
                        ),
                    isShowShimmer: true,
                  ),
                )
              ],
            );
          },
        ),
        Padding(
            padding: EdgeInsets.only(
              bottom: AppWidgetSize.dimen_8,
            ),
            child: ValueListenableBuilder(
              valueListenable: selectedHeaderIndex,
              builder: (
                BuildContext ctx,
                int value,
                Widget? child,
              ) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomTextWidget(
                      selectedtypeIndex == 0
                          ? selectedHeaderIndex.value == 0
                              ? '(${AppUtils().dataNullCheck(positions.oneDayPnLPercent)} %)'
                              : selectedHeaderIndex.value == 1
                                  ? '(${AppUtils().dataNullCheck(positions.overallPnLPercent)} %)'
                                  : '(${AppConstants.rupeeSymbol} ${AppUtils().commaFmt(AppUtils().doubleValue(positions.invested).abs().toStringAsFixed(AppUtils().getDecimalpoint(positions.sym!.exc)), decimalPoint: AppUtils().getDecimalpoint(positions.sym!.exc))})'
                          : selectedHeaderIndex.value == 0
                              ? '(${AppUtils().dataNullCheck(positions.oneDayPnLPercent)} %)'
                              : '(${AppConstants.rupeeSymbol} ${AppUtils().commaFmt(AppUtils().doubleValue(positions.invested).abs().toStringAsFixed(AppUtils().getDecimalpoint(positions.sym!.exc)), decimalPoint: AppUtils().getDecimalpoint(positions.sym!.exc))})',
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      isShowShimmer: true,
                    ),
                  ],
                );
              },
            )),
        _getLtpWidget(positions.ltp!),
      ],
    );
  }

  Widget _getLtpWidget(String ltp) {
    return _getLabelWithRupeeAndValue(
      '',
      '${_appLocalizations.ltpCap}: ',
      ltp,
      MainAxisAlignment.end,
    );
  }

  Widget _buildExpansionRow(
      BuildContext context,
      String title,
      Widget childWidget,
      int length,
      bool isSearch,
      List<Positions> positions) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_5,
      ),
      child: Theme(
        data: ThemeData().copyWith(
          primaryTextTheme: Theme.of(context).primaryTextTheme,
          textTheme: Theme.of(context).primaryTextTheme,
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.only(
            left: 0,
            bottom: 0,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: _buildHeaderWidget(
            title,
            length,
            isSearch,
          ),
          maintainState: false,
          iconColor: Theme.of(context).primaryIconTheme.color,
          initiallyExpanded: title == _appLocalizations.open
              ? _sortOpenPositions(
                  positions,
                ).isEmpty
                  ? false
                  : true
              : _sortClosedPositions(positions).isEmpty
                  ? false
                  : true,
          expandedCrossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _buildDivider(),
            childWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionRowForBottomSheetOpenPos1(
    BuildContext context,
    String title,
    String description1,
    String description2,
    String description3,
    String description4,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_5,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: AppWidgetSize.dimen_5,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
              title,
              Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w600)),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  description1,
                  Theme.of(context).primaryTextTheme.labelSmall,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomTextWidget(
                      "Understanding Positions Table:", //_appLocalizations.navNxtScnSubTitle,
                      Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                        "On the left side, you will find the details of the security you bought/sold, your order type (e.g., delivery or intraday) and the quantity and average price of your order. On the right column, by default, you will see the day’s profit and loss, as of now, in absolute and percentage terms. Tapping on the right column header will display the current value of your investment and the amount you invested along with the last traded price of that security.",
                        Theme.of(context).primaryTextTheme.labelSmall!),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_15, bottom: AppWidgetSize.dimen_15),
              child: Image(
                image: AppImages.posDescimg(),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomTextWidget(
                    'Search: ',
                    Theme.of(context)
                        .primaryTextTheme
                        .labelSmall!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                  child: CustomTextWidget(_appLocalizations.serchDesc,
                      Theme.of(context).primaryTextTheme.labelSmall!),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomTextWidget(
                      'Sort and filter: ',
                      Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: _appLocalizations.sortDesc,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!),
                          WidgetSpan(
                              child: AppImages.filterIcon(context,
                                  isColor: true,
                                  color: Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall!
                                      .color)),
                          TextSpan(
                              text: ".",
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomTextWidget(
                      'Close or Add to your position: ',
                      Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: _appLocalizations.closeDesc1,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!),
                          TextSpan(
                              text: _appLocalizations.closeDesc2,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.w600)),
                          TextSpan(
                              text: _appLocalizations.closeDesc3,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!),
                          TextSpan(
                              text: _appLocalizations.closeDesc4,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.w600)),
                          TextSpan(
                              text: _appLocalizations.closeDesc5,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!),
                          TextSpan(
                              text: _appLocalizations.closeDesc6,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.w600)),
                          TextSpan(
                              text: _appLocalizations.closeDesc7,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionRowForBottomSheetOpenPos(
    BuildContext context,
    String title,
    String description1,
    String description2,
    String description3,
    String description4,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_5,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: AppWidgetSize.dimen_5,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
              title,
              Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w600)),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              description1,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    'Cash :',
                    Theme.of(context)
                        .primaryTextTheme
                        .labelSmall!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      description2,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    'F&O :',
                    Theme.of(context)
                        .primaryTextTheme
                        .labelSmall!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                    child: CustomTextWidget(
                      description3,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_13),
              child: CustomTextWidget(
                description4,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  openPosExpansionBottomSheet() async {
    List<Widget> informationWidgetList = [
      _buildExpansionRowForBottomSheetOpenPos(
        context,
        _appLocalizations.openInfotitle1,
        _appLocalizations.openPosDesc,
        _appLocalizations.openPosDesc1,
        _appLocalizations.openPosDesc2,
        _appLocalizations.openPosDesc3,
      ),
      Divider(
        thickness: 1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowForBottomSheetOpenPos1(
        context,
        _appLocalizations.openInfotitle3,
        _appLocalizations.openInfotitle4,
        _appLocalizations.navNxtScnDesc1,
        _appLocalizations.openPosDesc2,
        _appLocalizations.openPosDesc3,
      ),
    ];
    return showInfoBottomsheet(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: AppWidgetSize.dimen_24, right: AppWidgetSize.dimen_24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextWidget(
                    _appLocalizations.openPos,
                    Theme.of(context).primaryTextTheme.titleMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: AppImages.closeIcon(
                      context,
                      width: AppWidgetSize.dimen_20,
                      height: AppWidgetSize.dimen_20,
                      color: Theme.of(context).primaryIconTheme.color,
                      isColor: true,
                    ),
                  )
                ],
              ),
            ),
            Divider(
              thickness: 1,
              color: Theme.of(context).dividerColor,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_24,
                    right: AppWidgetSize.dimen_24),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        primary: false,
                        shrinkWrap: true,
                        itemCount: informationWidgetList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return informationWidgetList[index];
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        horizontalMargin: false);
  }

  Widget _buildHeaderWidget(
    String title,
    int length,
    bool isSearch,
  ) {
    return Row(
      children: [
        CustomTextWidget(
          title,
          title == _appLocalizations.open
              ? Theme.of(context).primaryTextTheme.headlineMedium
              : Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onError,
                  ),
        ),
        Row(
          children: [
            _buildCircleBadgetWidget(title, length),
            if (title == _appLocalizations.open)
              Padding(
                padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_2,
                  left: AppWidgetSize.dimen_5,
                ),
                child: GestureDetector(
                  onTap: () {
                    openPosExpansionBottomSheet();
                  },
                  child: AppImages.informationIcon(
                    context,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true,
                    width: AppWidgetSize.dimen_24,
                    height: AppWidgetSize.dimen_24,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleBadgetWidget(
    String title,
    int length,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_10,
        top: AppWidgetSize.dimen_1,
      ),
      child: Container(
        alignment: Alignment.center,
        width: AppWidgetSize.dimen_16,
        height: AppWidgetSize.dimen_16,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
          color: title == _appLocalizations.open
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.onError,
        ),
        child: Center(
          child: Text(
            length.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      thickness: AppWidgetSize.dimen_1,
      color: Theme.of(context).dividerColor,
    );
  }

  Future<void> showPositionsBottomSheet(
    Positions positions,
    bool isOpen,
  ) async {
    showInfoBottomsheet(
        BlocProvider<PositionsBloc>.value(
          value: _positionsBloc,
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter updateState) {
            return ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(AppWidgetSize.dimen_20),
                ),
                child: GestureDetector(
                    onVerticalDragEnd: (details) async {
                      int sensitivity = 0;
                      if ((details.primaryVelocity ?? 0) < sensitivity) {
                        await pushtoPositionDetailswithPop(
                            context, positions, isOpen);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: _bottomSheetBody(
                      positions,
                      isOpen,
                    )));
          }),
        ),
        topMargin: false,
        horizontalMargin: false);
  }

  Future<void> pushtoPositionDetailswithPop(
      BuildContext context, Positions positions, bool isOpen) async {
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 200), () {});
    // ignore: use_build_context_synchronously
    await pushtoPositionDetailScreen(
      context,
      positions,
      isOpen,
    );
  }

  Future<void> pushtoPositionDetailScreen(
    BuildContext context,
    Positions positions,
    bool isOpen,
  ) async {
    Navigator.push(
      context,
      SlideUpRoute(
        page: BlocProvider<QuoteBloc>(
          create: (context) => QuoteBloc(),
          child: BlocProvider<QuoteBloc>(
            create: (context) => QuoteBloc(),
            child: BlocProvider<PositionsDetailBloc>(
              create: (context) => PositionsDetailBloc(),
              child: BlocProvider<WatchlistBloc>(
                create: (context) => WatchlistBloc(),
                child: BlocProvider(
                  create: (context) => HoldingsBloc(),
                  child: PositionsDetailsScreen(
                    arguments: {
                      'symbolItem': positions,
                      'groupList': groupList,
                      'isOpen': isOpen
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ).then((value) => _buildAddPostFrameCallback(context, loading: false));
  }

  Widget _bottomSheetBody(
    Positions positions,
    bool isOpen,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
        left: AppWidgetSize.dimen_20,
        right: AppWidgetSize.dimen_20,
        bottom: AppWidgetSize.dimen_10,
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () async {
                  await pushtoPositionDetailswithPop(
                      context, positions, isOpen);
                },
                child: AppImages.upArrowIcon(
                  context,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true,
                ),
              ),
            ),
            _getBottomSheetHeaderWidget(positions),
            _getBottomSheetSegmentWidget(positions),
            Padding(
              padding: EdgeInsets.only(
                bottom: AppWidgetSize.dimen_8,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      right: AppWidgetSize.dimen_8,
                    ),
                    child: getLableBorderWidget(
                      positionsSymbolRowProductTypeKey,
                      positions.prdType.toString(),
                    ),
                  ),
                  getLableBorderWidget(
                    positionsSymbolRowProductTypeKey,
                    isOpen
                        ? _appLocalizations.open
                        : _appLocalizations.ordStatusClosed,
                  ),
                ],
              ),
            ),
            _getBottomSheetButtonsWidget(isOpen, positions),
            buildTableWithBackgroundColor(
              positions.isOneDay
                  ? _appLocalizations.netdayQty
                  : _appLocalizations.netQty,
              positions.netQty!.withMultiplierTrade(positions.sym),
              _appLocalizations.avgPrice,
              positions.avgPrice!,
              '',
              '',
              context,
              isRupeeSymbol: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBottomSheetButtonsWidget(isOpen, Positions positions) {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          gradientButtonWidget(
            onTap: () {
              String action;
              bool buy;
              if (AppUtils().intValue(positions.netQty) > 0) {
                buy = true;
              } else {
                buy = false;
              }
              if (buy) {
                if (AppUtils().intValue(positions.netQty) < 0) {
                  action = isOpen ? AppConstants.sell : AppConstants.buy;
                } else {
                  action = isOpen ? AppConstants.buy : AppConstants.sell;
                }
              } else {
                if (AppUtils().intValue(positions.netQty) > 0) {
                  action = isOpen ? AppConstants.buy : AppConstants.sell;
                } else {
                  action = isOpen ? AppConstants.sell : AppConstants.buy;
                }
              }
              _onCallOrderPad(action, isOpen, _appLocalizations.add, positions);
            },
            width: gradientButtonSizes(isOpen, positions),
            key: const Key(emptyPositionsPlaceOrderKey),
            context: context,
            gradientColors: AppUtils().intValue(positions.netQty) >= 0
                ? [
                    Theme.of(context).colorScheme.onBackground,
                    AppColors().positiveColor
                  ]
                : [AppColors.negativeColor, AppColors.negativeColor],
            title: !isOpen ? AppLocalizations().buy : _appLocalizations.add,
            isGradient: true,
          ),
          if (isSquareOff(positions) || !isOpen)
            SizedBox(
              width: AppWidgetSize.dimen_8,
            ),
          if (isTransferable(positions) && isOpen)
            gradientButtonWidget(
              onTap: () async {
                await _showPositionsConvertBottomSheet(positions);
                if (!mounted) return;
                await _buildAddPostFrameCallback(context, loading: false);
              },
              width: gradientButtonSizes(isOpen, positions),
              key: const Key(emptyPositionsPlaceOrderKey),
              context: context,
              title: _appLocalizations.convert,
              isGradient: false,
              isErrorButton: false,
            ),
          if (isTransferable(positions))
            SizedBox(
              width: AppWidgetSize.dimen_8,
            ),
          if (isSquareOff(positions) || !isOpen)
            gradientButtonWidget(
              onTap: () {
                if (AppUtils().intValue(positions.netQty) > 0) {
                  _onCallOrderPad(isOpen ? AppConstants.sell : AppConstants.buy,
                      isOpen, _appLocalizations.exit, positions);
                } else {
                  _onCallOrderPad(isOpen ? AppConstants.buy : AppConstants.sell,
                      isOpen, _appLocalizations.exit, positions);
                }
              },
              width: gradientButtonSizes(isOpen, positions),
              key: const Key(emptyPositonsViewWatchlistKey),
              context: context,
              title: !isOpen ? AppLocalizations().sell : _appLocalizations.exit,
              isGradient: true,
              gradientColors: AppUtils().intValue(positions.netQty) < 0
                  ? [
                      Theme.of(context).colorScheme.onBackground,
                      AppColors().positiveColor
                    ]
                  : [AppColors.negativeColor, AppColors.negativeColor],
            ),
        ],
      ),
    );
  }

  double gradientButtonSizes(bool isOpen, Positions positions) {
    double width = AppWidgetSize.fullWidth(context) / 1.5;
    if (isTransferable(positions) && isOpen) {
      width = AppWidgetSize.fullWidth(context) / 2.7;
    }
    if (isSquareOff(positions) || !isOpen) {
      width = AppWidgetSize.fullWidth(context) / 2.7;
    }
    if (isSquareOff(positions) && isTransferable(positions) && isOpen) {
      width = AppWidgetSize.fullWidth(context) / 3.8;
    }
    return width;
  }

  bool isSquareOff(Positions positions) => positions.isSquareoff == 'true';

  bool isTransferable(Positions positions) => positions.transferable == 'true';

  Widget _getBottomSheetHeaderWidget(
    Positions positions,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: AppWidgetSize.fullWidth(context) / 1.4,
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: CustomTextWidget(
                    positions.dispSym!,
                    Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: AppWidgetSize.dimen_80,
                    child: LabelBorderWidget(
                      keyText: const Key(positionsBottomSheetStockQuoteKey),
                      text: _appLocalizations.stockQuote,
                      textColor: Theme.of(context).primaryColor,
                      fontSize: AppWidgetSize.fontSize12,
                      margin: EdgeInsets.only(top: AppWidgetSize.dimen_2),
                      borderRadius: 20.w,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      borderWidth: AppWidgetSize.dimen_1,
                      borderColor: Theme.of(context).dividerColor,
                      isSelectable: true,
                      labelTapAction: () {
                        pushNavigation(
                          ScreenRoutes.quoteScreen,
                          arguments: {
                            'symbolItem': positions,
                          },
                        );
                      },
                    ),
                  ),
                  if (AppUtils().getsymbolType(positions) !=
                      AppConstants.indices)
                    Container(
                      margin: EdgeInsets.only(left: AppWidgetSize.dimen_5),
                      width: AppWidgetSize.dimen_100,
                      child: LabelBorderWidget(
                        keyText: const Key(quoteLabelKey),
                        text: _appLocalizations.optionChain,
                        textColor: Theme.of(context).primaryColor,
                        fontSize: AppWidgetSize.fontSize12,
                        margin: EdgeInsets.only(top: AppWidgetSize.dimen_2),
                        borderRadius: 20.w,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        borderWidth: 1,
                        borderColor: Theme.of(context).dividerColor,
                        isSelectable: true,
                        labelTapAction: () {
                          optionChainTapAction(positions);
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
                child: GestureDetector(
                  onTap: () {
                    if (groupList!.isEmpty) {
                      _showCreateNewBottomSheet(positions);
                    } else {
                      _showWatchlistGroupBottomSheet(positions);
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
    Positions positions,
  ) {
    return BlocBuilder<PositionsBloc, PositionsState>(
      buildWhen: (previous, current) {
        return current is PositionsDoneState;
      },
      builder: (context, state) {
        return buildBottomSheetSegmentContainer(
          positions,
        );
      },
    );
  }

  Future<void> optionChainTapAction(Symbols positions) async {
    sendEventToFirebaseAnalytics(
        AppEvents.optionchainClick,
        ScreenRoutes.positionScreen,
        'clicked option chain from position bottom sheet',
        key: "symbol",
        value: positions.dispSym);
    unsubscribeLevel1();

    await pushNavigation(
      ScreenRoutes.quoteOptionChain,
      arguments: {'symbolItem': positions, 'expiry': positions.sym?.expiry},
    );
    _positionsBloc.add(PositionStartStream());
  }

  Widget buildBottomSheetSegmentContainer(
    Positions positions,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_20,
        top: AppWidgetSize.dimen_20,
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
                AppUtils().dataNullCheck(positions.oneDayPnL),
                '(${AppUtils().decimalValue(positions.oneDayPnLPercent)}%)',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headingSubjectWidget(_appLocalizations.todaysPnL, [
                      TextSpan(
                          text:
                              "A ${_appLocalizations.todaysPnL} shows the profitability of your current positions since the last trading day in absolute and percentage terms.")
                    ]),
                    Padding(
                      padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_10),
                      child: CustomTextWidget(
                        "For stocks purchased today,",
                        Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                    ),
                    CustomTextWidget(
                        "${_appLocalizations.todaysPnL} = (Current LTP – Today’s average trade price) * Quantity",
                        Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontWeight: FontWeight.w600)),
                    headingSubjectWidget("", [
                      const TextSpan(
                          text:
                              "For F&O positions, your 1-day return would be net of current market price and your buying/selling average (or yesterday’s close if it is a carry-forward position).")
                    ]),
                  ],
                ),
                AppUtils().profitLostColor(positions.oneDayPnL),
                isBottomSheet: true,
                initialChildSize: 0.5);
          } else if (index == 1 && selectedtypeIndex != 1) {
            return Featureflag.showOverallPnl
                ? _buildListBoxContent(
                    _appLocalizations.overallPL,
                    positions.overallPnL!,
                    '(${AppUtils().decimalValue(positions.overallPnLPercent)}%)',
                    Column(
                      children: [
                        headingSubjectWidget(_appLocalizations.overallPL, [
                          TextSpan(
                              text:
                                  "${_appLocalizations.overallPL} shows the overall profit or loss of your position (cash and derivatives) in absolute and percentage terms.")
                        ]),
                        headingSubjectWidget("For stocks purchased today,", [
                          TextSpan(
                              text:
                                  "${_appLocalizations.overallPL} = (Current LTP – Avg buy price/ sell price) x Quantity",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                        ]),
                      ],
                    ),
                    AppUtils().profitLostColor(positions.overallPnL ?? "0"),
                    initialChildSize: 0.4,
                    isBottomSheet: true,
                  )
                : Container();
          } else {
            return Container();
          }
        },
      ),
    );
  }

  void _showWatchlistGroupBottomSheet(
    Positions positions,
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
                  'symbolItem': positions,
                  'groupList': groupList,
                },
              ),
            )),
        topMargin: false,
        bottomMargin: 0,
        height: (AppUtils().chooseWatchlistHeight(groupList ?? []) <
                (AppWidgetSize.screenHeight(context) * 0.8))
            ? AppUtils().chooseWatchlistHeight(groupList ?? [])
            : (AppWidgetSize.screenHeight(context) * 0.8),
        horizontalMargin: false);
  }

  Future<void> _showCreateNewBottomSheet(
    Positions positions,
  ) async {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
      ),
      builder: (BuildContext bct) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(AppWidgetSize.dimen_20),
            ),
          ),
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.fromLTRB(AppWidgetSize.dimen_20,
                  AppWidgetSize.dimen_20, AppWidgetSize.dimen_20, 0),
              child: BlocProvider<QuoteBloc>.value(
                value: quoteBloc,
                child: CreateNewWatchlistWidget(
                  arguments: {
                    'symbolItem': positions,
                    'groupList': groupList,
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future _showPositionsConvertBottomSheet(Positions positions) async {
    positions.isFUT = _isFutures(positions.sym!);

    await showInfoBottomsheet(
        BlocProvider<PositionConvertionBloc>(
          create: (context) => PositionConvertionBloc(),
          child: PositionsConvertSheet(
            arguments: {
              'positions': positions,
            },
          ),
        ),
        horizontalMargin: false,
        topMargin: false,
        bottomMargin: 0);
  }

  _isFutures(Sym sym) {
    if (sym.asset == 'future') {
      return true;
    }
    return false;
  }

  Widget getLableBorderWidget(String key, String title, {Positions? position}) {
    return SizedBox(
      width: title.textSize(
            title,
            Theme.of(context).inputDecorationTheme.labelStyle!,
          ) +
          AppWidgetSize.dimen_10,
      child: LabelBorderWidget(
        keyText: Key(key),
        text: title,
        textColor: Theme.of(context).inputDecorationTheme.labelStyle!.color,
        fontSize: AppWidgetSize.fontSize12,
        borderRadius: AppWidgetSize.dimen_20,
        margin: EdgeInsets.only(right: AppWidgetSize.dimen_1),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        borderWidth: 1,
        borderColor: Theme.of(context).dividerColor,
      ),
    );
  }

  Future<void> sortSheet() async {
    showInfoBottomsheet(StatefulBuilder(
        builder: (BuildContext context, StateSetter updateState) {
      return SortFilterWidget(
        screenName: ScreenRoutes.positionScreen,
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
    }), height: double.maxFinite, horizontalMargin: false);
  }

  void onDoneCallBack(
    SortModel selectedSortModel,
    List<FilterModel> filterList,
  ) {
    selectedSort = selectedSortModel;

    selectedFilters = filterList;
    unsubscribeLevel1Streaming();
    positionsApiCallWithFilters(selectedFilters, selectedSort,
        fetchagain: true);
  }

  void onClearCallBack() {
    bool fetchagain = selectedFilters
        .where((element) => (element.filters?.isNotEmpty ?? false))
        .toList()
        .isNotEmpty;
    selectedFilters = getFilterModel();
    selectedSort = SortModel();
    positionsApiCallWithFilters(selectedFilters, selectedSort,
        fetchagain: fetchagain);
  }

  void unsubscribeLevel1Streaming() {
    unsubscribeLevel1();
  }

  Future<void> onPlaceOrderTapped() async {
    unsubscribeLevel1();
    await pushNavigation(
      ScreenRoutes.searchScreen,
      arguments: {
        'watchlistBloc': watchlistBloc,
      },
    );
  }

  EdgeInsets buildPaddingEdgeInsets() {
    return EdgeInsets.only(
        left: AppWidgetSize.dimen_10, right: AppWidgetSize.dimen_10);
  }

  EdgeInsets buildMarginEdgeInsets() {
    return EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
        left: AppWidgetSize.dimen_1,
        right: AppWidgetSize.dimen_11);
  }

  String toggleButtonOnChanged(String name) {
    return name;
  }

  Future<void> _onCallOrderPad(
      String action, bool isOpen, String header, Positions positions) async {
    popNavigation();

    await pushNavigation(
      ScreenRoutes.orderPadScreen,
      arguments: {
        'action': action,
        'symbolItem': positions,
        AppConstants.positionExitOrAdd:
            positions.netQty.withMultiplierTrade(positions.sym),
        AppConstants.positionsPrdType: (positions.prdType?.toLowerCase() ==
                    AppConstants.coverOrder.toLowerCase() ||
                positions.prdType?.toLowerCase() ==
                    AppConstants.bracketOrder.toLowerCase())
            ? AppLocalizations().intraDay.toUpperCase()
            : positions.prdType,
        AppConstants.isOpenPosition: isOpen,
        AppConstants.positionButtonHeader: header,
      },
    );
    positionsApiCallWithFilters(selectedFilters, selectedSort,
        loading: false, fetchagain: true);
  }
}
