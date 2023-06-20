import 'dart:io';

import 'package:acml/src/config/app_config.dart';
import 'package:acml/src/screen_util/flutter_screenutil.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/bloc/watch_bloc.dart';
import '../../blocs/holdings/holdings/holdings_bloc.dart';
import '../../blocs/indices/indices_bloc.dart';
import '../../blocs/my_accounts/client_details/clientdetails_bloc.dart';
import '../../blocs/my_funds/funds/my_funds_bloc.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/search/search_bloc.dart';
import '../../blocs/tab/menu_bottom_tab_bloc.dart';
import '../../blocs/watchlist/watchlist_bloc.dart';
import '../../constants/app_constants.dart';
import '../../data/repository/login/login_repository.dart';
import '../../data/store/app_store.dart';
import '../../localization/app_localization.dart';
import '../screens/base/base_screen.dart';
import '../screens/my_account/my_account.dart';
import '../screens/my_funds/funds/myfunds.dart';
import '../screens/search/search_screen.dart';
import '../screens/trades/trades_screen.dart';
import '../screens/watchlist/watchlist_screen.dart';
import '../screens/watchlist/watchlisttask/watchlist_task_screen.dart';
import '../styles/app_color.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import 'screen_routes.dart';

// ignore: must_be_immutable
class MenuBottomTabNavigation extends BaseScreen {
  MenuBottomTabNavigation({
    Key? key,
    this.arguments,
  }) : super(key: key);

  Map? arguments;

  @override
  MenuBottomTabNavigationState createState() => MenuBottomTabNavigationState();
}

class MenuBottomTabNavigationState
    extends BaseAuthScreenState<MenuBottomTabNavigation> {
  late MenuBottomTabBloc _menuBottomTabBloc;
  late AppLocalizations _appLocalizations;

  int selectedTradesIndex = 2;
  int _selectedIndex = 0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (isScreenActive() && Featureflag.sessionValidation) {
          await AppStore.fetchSession?.cancel();
          AppStore.fetchSession = CancelableOperation.fromFuture(
                  LoginRepository().validateSession())
              .then((value) => {
                    if (value != true)
                      {
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          handleError(value);
                        })
                      }
                  });
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _menuBottomTabBloc = BlocProvider.of<MenuBottomTabBloc>(context)
        ..stream.listen(_menuBottomTabBlocListener);

      if (widget.arguments != null) {
        final List<String> pageNames = <String>[
          ScreenRoutes.watchlistScreen,
          ScreenRoutes.tradesScreen,
          ScreenRoutes.dashboardScreen,
          ScreenRoutes.myfundsScreen,
          ScreenRoutes.myAccount,
          ScreenRoutes.myWatch
        ];
        final String pageName = widget.arguments!['pageName'];

        final int tabIndexValue =
            pageNames.contains(pageName) ? pageNames.indexOf(pageName) : 0;
        if (tabIndexValue == 1) {
          selectedTradesIndex = widget.arguments!['selectedIndex'] ?? 2;
        }
        _onTap(tabIndexValue);
      } else if (AppStore().isPushClicked() &&
          MenuBottomTabBloc.pushNavigation.isEmpty) {
        _onTap(4);
      } else {
        _onTap(0);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _menuBottomTabBloc.close();
  }

  Future<void> _menuBottomTabBlocListener(MenuBottomTabState state) async {
    if (state is LogoutDoneState) {
      handleLogout('', state.fullExit, state.isFromMyAcc);
    } else if (state is LogoutErrorState) {
      handleError(state);
    } else if (state is UpdateTabState) {}
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;

    return BlocBuilder<MenuBottomTabBloc, MenuBottomTabState>(
      buildWhen:
          (MenuBottomTabState prevState, MenuBottomTabState currentState) {
        return currentState is UpdateTabState;
      },
      builder: (BuildContext context, MenuBottomTabState state) {
        final List<Widget> tabs = _getTabDetails();
        if (state is UpdateTabState) {
          final int tabIndex = state.tabIndex;

          final Widget collapsedView = SizedBox(
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              key: const Key('menuBottomTabBar'),
              body: tabs[tabIndex],
              bottomNavigationBar: _buildBottomNavigationBar(),
            ),
          );

          if (tabIndex == -1) {
            return Container();
          } else {
            return WillPopScope(
              child: collapsedView,
              onWillPop: () {
                return _handleOnWillPop(tabIndex);
              },
            );
          }
        }
        return Container();
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    final List<Map<String, dynamic>> menuList = _getMenuItems();
    final List<Widget> items =
        List<Widget>.generate(menuList.length, (int index) {
      return _buildTabItem(
        item: menuList[index],
        index: index,
        onPressed: _onTap,
      );
    });
    return SizedBox(
      child: BottomAppBar(
        color: AppStore().getThemeData() == AppConstants.darkMode
            ? Theme.of(context).colorScheme.background
            : Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items,
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required Map<String, dynamic> item,
    required int index,
    required Function onPressed,
  }) {
    return SizedBox(
      height: 65.w,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => onPressed(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 26.w,
                height: 26.w,
                child:
                    _selectedIndex == index ? item['activeIcon'] : item['icon'],
              ),
              Text(
                item['title'],
                key: Key('BOTTOM_NAVIGATION_MENU_$index'),
                style: _selectedIndex == index
                    ? Theme.of(context)
                        .primaryTextTheme
                        .bodySmall!
                        .copyWith(color: AppColors().positiveColor)
                    : Theme.of(context).primaryTextTheme.bodySmall!,
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget _bottomNavigationBar(BuildContext context, int tabIndex) {
  //   final List<Map<String, dynamic>> menuList = _getMenuItems();
  //   return SizedBox(
  //     child: BottomNavigationBar(
  //       key: const Key('bottomNavigationBar'),
  //       backgroundColor: AppStore().getThemeData() == AppConstants.darkMode
  //           ? Theme.of(context).backgroundColor
  //           : Theme.of(context).scaffoldBackgroundColor,
  //       type: BottomNavigationBarType.fixed,
  //       selectedLabelStyle: Theme.of(context).primaryTextTheme.caption!,
  //       selectedItemColor: AppColors().positiveColor,
  //       unselectedItemColor: Theme.of(context).primaryTextTheme.button!.color!,
  //       unselectedLabelStyle: Theme.of(context).primaryTextTheme.caption!,
  //       items: List.generate(
  //         menuList.length,
  //         (int index) {
  //           final Map<dynamic, dynamic> item = menuList[index];

  //           return BottomNavigationBarItem(
  //             icon: _buildSizexbox(item[AppConstants.icon]),
  //             activeIcon: _buildSizexbox(item[AppConstants.activeIcon]),
  //             label: item[AppConstants.title],
  //           );
  //         },
  //       ).toList(),
  //       onTap: _onTap,
  //       currentIndex: tabIndex,
  //     ),
  //   );
  // }

  // SizedBox _buildSizexbox(Widget childWidget) {
  //   return SizedBox(
  //     width: AppWidgetSize.getSize(26),
  //     height: AppWidgetSize.getSize(26),
  //     child: childWidget,
  //   );
  // }

  List<Widget> _getTabDetails() {
    List<Widget> listdata = <Widget>[
      MultiBlocProvider(
        providers: [
          BlocProvider<WatchlistBloc>(
            create: (BuildContext context) => WatchlistBloc(),
          ),
          BlocProvider<HoldingsBloc>(
            create: (BuildContext context) => HoldingsBloc(),
          ),
          BlocProvider<IndicesBloc>(
            create: (BuildContext context) => IndicesBloc(),
          ),
          BlocProvider<ClientdetailsBloc>(
            create: (BuildContext context) => ClientdetailsBloc(),
          ),
        ],
        child: const WatchlistScreen(),
      ),
      TradesScreen(
        arguments: {
          'selectedIndex': selectedTradesIndex,
          'toGtd': widget.arguments?["toGtd"] ?? false
        },
      ),
      BlocProvider<SearchBloc>(
        create: (BuildContext context) => SearchBloc(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<WatchlistBloc>(
              create: (BuildContext context) =>
                  WatchlistBloc()..add(WatchlistGetGroupsEvent(true)),
            ),
          ],
          child: const SearchScreen(arguments: {"backIconDisable": true}),
        ),
      ),
      BlocProvider<MyFundsBloc>(
        create: (BuildContext context) => MyFundsBloc(),
        child: const MyFundsScreen(arguments: {"backIconDisable": true}),
      ),
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ClientdetailsBloc(),
          ),
          BlocProvider(
            create: (context) => MyFundsBloc(),
          ),
          BlocProvider(
            create: (context) => NotificationBloc(),
          )
        ],
        child: const MyAccount(),
      ),
      BlocProvider<WatchBloc>(
        create: (BuildContext context) => WatchBloc()..add(LoadWatchEvent()),
        child: WatchlistTaskScreen(),
      ),
    ];
    return listdata;
  }

  List<Map<String, dynamic>> _getMenuItems() {
    final List<Map<String, dynamic>> menuList = <Map<String, dynamic>>[
      <String, dynamic>{
        AppConstants.icon: AppImages.watchListDisable(context,
            color: Theme.of(context).iconTheme.color, isColor: true),
        AppConstants.activeIcon: AppImages.addFilledIcon(
          context,
        ),
        AppConstants.title: _appLocalizations.watchlist
      },
      <String, dynamic>{
        AppConstants.icon: AppImages.tradeDisable(
          context,
          isColor: true,
          color: Theme.of(context).iconTheme.color,
        ),
        AppConstants.activeIcon: AppImages.tradeEnabled(
          context,
        ),
        AppConstants.title: _appLocalizations.trades
      },
      <String, dynamic>{
        AppConstants.icon: AppImages.exploreDisable(context,
            color: Theme.of(context).iconTheme.color, isColor: true),
        AppConstants.activeIcon: AppImages.exploreEnabled(
          context,
        ),
        AppConstants.title: _appLocalizations.explore
      },
      <String, dynamic>{
        AppConstants.icon: AppImages.fundsDisable(context,
            color: Theme.of(context).iconTheme.color, isColor: true),
        AppConstants.activeIcon: AppImages.fundsEnabled(
          context,
        ),
        AppConstants.title: _appLocalizations.funds
      },
      <String, dynamic>{
        AppConstants.icon: AppImages.myAccoutdisable(context,
            color: Theme.of(context).iconTheme.color, isColor: true),
        AppConstants.activeIcon: AppImages.myAccoutEnable(
          context,
        ),
        AppConstants.title: _appLocalizations.myAccout
      },
      <String, dynamic>{
        AppConstants.icon: AppImages.watchListDisable(context,
            color: Theme.of(context).iconTheme.color, isColor: true),
        AppConstants.activeIcon: AppImages.addFilledIcon(
          context,
        ),
        AppConstants.title: _appLocalizations.newwatch
      },
    ];

    return menuList;
  }

  Future<bool> _handleOnWillPop(int tabIndex) async {
    bool pop = false;
    if (tabIndex == 0) {
      exitToLogin();
    } else {
      _onTap(0);
    }
    return pop;
  }

  void onTap() {
    widget.arguments = {};
    selectedTradesIndex = 2;
    pushAndRemoveUntilNavigation(
      ScreenRoutes.homeScreen,
      arguments: {
        'pageName': ScreenRoutes.watchlistScreen,
      },
    );
  }

  void _onTap(int index) {
    if (index != 1) {
      selectedTradesIndex = 2;
    }
    setState(() {
      _selectedIndex = index;
    });
    _menuBottomTabBloc.add(ChangeTabEvent(tabIndex: index));
  }

  @override
  void exitToLogin() {
    showInfoBottomsheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Arihant",
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.w, bottom: 20.h),
            child: Text(
              "Are you sure you want to exit the app?",
              style: Theme.of(context).textTheme.headlineMedium!,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations().cancel,
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              GestureDetector(
                onTap: () {
                  pushAndRemoveUntilNavigation(ScreenRoutes.initConfig);
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else if (Platform.isIOS) {
                    exit(0);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 15.w),
                  child: Text(
                    AppLocalizations().proceed,
                    style: Theme.of(context).primaryTextTheme.headlineMedium,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
