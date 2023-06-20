import 'package:acml/src/blocs/alerts/alerts_bloc.dart';
import 'package:acml/src/ui/styles/app_images.dart';
import 'package:acml/src/ui/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../constants/keys/watchlist_keys.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/build_empty_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/refresh_widget.dart';
import '../base/base_screen.dart';
import 'alert_row_widget.dart';

class MyAlerts extends BaseScreen {
  const MyAlerts({Key? key}) : super(key: key);

  @override
  State<MyAlerts> createState() => _MyAlertsState();
}

class _MyAlertsState extends BaseAuthScreenState<MyAlerts>
    with TickerProviderStateMixin {
  ValueNotifier<int> tabIndex = ValueNotifier<int>(0);
  final AppLocalizations _appLocalizations = AppLocalizations();
  final AlertsBloc alertsBloc = AlertsBloc();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            topBar(context),
            Expanded(child: _buildTabListWidget()),
          ],
        ),
      ),
    );
  }

  TabController? tabController;

  @override
  void initState() {
    tabController = TabController(length: 3, initialIndex: 0, vsync: this);
    tabController?.addListener(() {
      tabIndex.value = tabController?.index ?? 0;
    });

    alertsBloc
      ..add(FetchPendingAlertsEvent())
      ..stream.listen((event) {
        if (event is AlertSymStreamState) {
          subscribeLevel1(event.streamDetails);
        }
        if (event is AlertsError) {
          handleError(event);
        }
      });
    super.initState();
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.alertsScreen;
  }

  @override
  void quote1responseCallback(ResponseData data) {
    alertsBloc.add(AlertsStreamingResponseEvent(data));
  }

  Widget _buildTabBarTitleView(Map<String, dynamic> item) {
    return Tab(
        child: Text(
      item['title'],
    ));
  }

  Widget _buildTabListWidget() {
    return BlocBuilder<AlertsBloc, AlertsState>(
      bloc: alertsBloc,
      buildWhen: (previous, current) =>
          current is AlertsLoading ||
          current is PendingAlertsDone ||
          current is AlertsError,
      builder: (context, state) {
        if (state is AlertsLoading) return const LoaderWidget();

        if (state is PendingAlertsDone) {
          if (isExpandedEquity.isEmpty ||
              state.alerts.equityList.length != isExpandedEquity.length) {
            isExpandedEquity = List.generate(state.alerts.equityList.length,
                (index) => ValueNotifier(false));
          }
          if (isExpandedFuture.isEmpty ||
              state.alerts.futureList.length != isExpandedFuture.length) {
            isExpandedFuture = List.generate(state.alerts.futureList.length,
                (index) => ValueNotifier(false));
          }
          if (isExpandedOption.isEmpty ||
              state.alerts.optionList.length != isExpandedOption.length) {
            isExpandedOption = List.generate(state.alerts.optionList.length,
                (index) => ValueNotifier(false));
          }
          return ValueListenableBuilder<int>(
            valueListenable: tabIndex,
            builder: (context, value, _) {
              return DefaultTabController(
                initialIndex: tabController?.index ?? 0,
                length: 3,
                child: Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  appBar: AppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    toolbarHeight: AppWidgetSize.dimen_40,
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    flexibleSpace: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      alignment: Alignment.bottomCenter,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: TabBar(
                        controller: tabController,
                        key: const Key(marketsTabViewControllerKey),
                        isScrollable: false,
                        indicatorColor: Theme.of(context).primaryColor,
                        indicatorWeight: AppWidgetSize.dimen_5,
                        indicator: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  style: BorderStyle.solid,
                                  color: Theme.of(context).primaryColor,
                                  width: 3.w)),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelStyle:
                            Theme.of(context).primaryTextTheme.headlineMedium,
                        labelColor: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .color,
                        unselectedLabelStyle:
                            Theme.of(context).textTheme.labelLarge,
                        unselectedLabelColor:
                            Theme.of(context).textTheme.labelLarge!.color,
                        tabs: _getTabList(state)
                            .map((Map<String, dynamic> item) =>
                                _buildTabBarTitleView(item))
                            .toList(),
                      ),
                    ),
                  ),
                  body: TabBarView(
                    controller: tabController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: _getTabList(state)
                        .map(
                          (Map<String, dynamic> item) =>
                              _buildTabBarBodyView(item),
                        )
                        .toList(),
                  ),
                ),
              );
            },
          );
        } else {
          return RefreshWidget(
              onRefresh: () {
                alertsBloc.add(FetchPendingAlertsEvent());
              },
              child: SingleChildScrollView(
                child: SizedBox(
                  height: AppWidgetSize.screenHeight(context) - 200.w,
                  child: buildEmptyWidget(
                    context: context,
                    emptyImage: AppImages.noDataAlerts(context),
                    description1: state.errorMsg.isEmpty
                        ? _appLocalizations.noDataAvailableErrorMessage
                        : state.errorMsg,
                    buttonInRow: false,
                    button1Title: 'Add Alert',
                    button2Title: '',
                    topPadding: AppWidgetSize.dimen_20,
                    onButton1Tapped: () {},
                    description2: state.errorCode,
                  ),
                ),
              ));
        }
      },
    );
  }

  topBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.w, top: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: backIconButton(),
              ),
              Padding(
                padding: EdgeInsets.only(left: AppWidgetSize.dimen_25),
                child: CustomTextWidget(
                  AppLocalizations().myAlerts,
                  Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: AppImages.settingsMarkets(context, width: 30.w),
                  ),
                  onTap: () {
                    pushNavigation(ScreenRoutes.alertSettings);
                  }),
              GestureDetector(
                  onTap: () {
                    pushNavigation(ScreenRoutes.alertHistory);
                  },
                  child: AppImages.history(context)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTabBarBodyView(Map<String, dynamic> item) {
    return item['view'];
  }

  List<ValueNotifier<bool>> isExpandedEquity = [];
  List<ValueNotifier<bool>> isExpandedFuture = [];
  List<ValueNotifier<bool>> isExpandedOption = [];

  List<Map<String, dynamic>> _getTabList(PendingAlertsDone state) {
    final List<Map<String, dynamic>> tabList = <Map<String, dynamic>>[
      <String, dynamic>{
        'title': _appLocalizations.stocks,
        'view': state.alerts.equityList.isNotEmpty
            ? Scaffold(
                bottomNavigationBar: bottomWidget(),
                body: RefreshWidget(
                    child: ListView.builder(
                      itemCount: state.alerts.equityList.length,
                      itemBuilder: (context, index) {
                        return ValueListenableBuilder<bool>(
                            valueListenable: isExpandedEquity[index],
                            builder: (context, value, _) {
                              return PendingAlertRow(
                                alertsBloc,
                                alertBySymbol: state.alerts.equityList[index],
                                isExpanded: isExpandedEquity[index].value,
                                onRowClick: () {
                                  for (int i = 0;
                                      i < isExpandedEquity.length;
                                      i++) {
                                    if (i == index) {
                                      isExpandedEquity[i].value =
                                          !(isExpandedEquity[i].value);
                                    } else {
                                      isExpandedEquity[i].value = false;
                                    }
                                  }
                                },
                              );
                            });
                      },
                    ),
                    onRefresh: () {
                      alertsBloc.add(FetchPendingAlertsEvent());
                    }),
              )
            : addAlertWhenEmpty(),
      },
      <String, dynamic>{
        'title': _appLocalizations.futures,
        'view': state.alerts.futureList.isNotEmpty
            ? Scaffold(
                bottomNavigationBar: bottomWidget(),
                body: RefreshWidget(
                    child: ListView.builder(
                      itemCount: state.alerts.futureList.length,
                      itemBuilder: (context, index) {
                        return ValueListenableBuilder<bool>(
                            valueListenable: isExpandedFuture[index],
                            builder: (context, value, _) {
                              return PendingAlertRow(
                                alertsBloc,
                                alertBySymbol: state.alerts.futureList[index],
                                isExpanded: isExpandedFuture[index].value,
                                onRowClick: () {
                                  for (int i = 0;
                                      i < isExpandedFuture.length;
                                      i++) {
                                    if (i == index) {
                                      isExpandedFuture[i].value =
                                          !(isExpandedFuture[i].value);
                                    } else {
                                      isExpandedFuture[i].value = false;
                                    }
                                  }
                                },
                              );
                            });
                      },
                    ),
                    onRefresh: () {
                      alertsBloc.add(FetchPendingAlertsEvent());
                    }),
              )
            : addAlertWhenEmpty()
      },
      <String, dynamic>{
        'title': _appLocalizations.options,
        'view': state.alerts.optionList.isNotEmpty
            ? Scaffold(
                bottomNavigationBar: bottomWidget(),
                body: RefreshWidget(
                    child: ListView.builder(
                      itemCount: state.alerts.optionList.length,
                      itemBuilder: (context, index) {
                        return ValueListenableBuilder<bool>(
                            valueListenable: isExpandedOption[index],
                            builder: (context, value, _) {
                              return PendingAlertRow(
                                alertsBloc,
                                alertBySymbol: state.alerts.optionList[index],
                                isExpanded: isExpandedOption[index].value,
                                onRowClick: () {
                                  for (int i = 0;
                                      i < isExpandedOption.length;
                                      i++) {
                                    if (i == index) {
                                      isExpandedOption[i].value =
                                          !(isExpandedOption[i].value);
                                    } else {
                                      isExpandedOption[i].value = false;
                                    }
                                  }
                                },
                              );
                            });
                      },
                    ),
                    onRefresh: () {
                      alertsBloc.add(FetchPendingAlertsEvent());
                    }),
              )
            : addAlertWhenEmpty(),
      }
    ];
    return tabList;
  }

  RefreshWidget addAlertWhenEmpty() {
    return RefreshWidget(
        onRefresh: () {
          alertsBloc.add(FetchPendingAlertsEvent());
        },
        child: SingleChildScrollView(
          child: SizedBox(
            height: AppWidgetSize.screenHeight(context) - 130.w,
            child: buildEmptyWidget(
              context: context,
              emptyImage: AppImages.noDataAlerts(context),
              description1: 'No Alerts Available',
              buttonInRow: false,
              button1Title: _appLocalizations.addAlert,
              button2Title: '',
              topPadding: AppWidgetSize.dimen_20,
              onButton1Tapped: () async {
                await addAlertPopup();
              },
              description2: "Explore market and Add alerts",
            ),
          ),
        ));
  }

  Future<void> addAlertPopup() async {
    await pushNavigation(ScreenRoutes.searchScreen,
        arguments: {"backIconDisable": false, "fromAlerts": true});
    await Future.delayed(const Duration(milliseconds: 200));

    alertsBloc.add(FetchPendingAlertsEvent());
  }

  Column bottomWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.w),
          child: gradientButtonWidget(
            onTap: () async {
              await addAlertPopup();
            },
            width: 200.w,
            key: const Key(""),
            context: context,
            title: AppLocalizations().addAlert,
            isGradient: true,
          ),
        ),
      ],
    );
  }
}
