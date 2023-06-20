import 'package:acml/src/config/app_config.dart';
import 'package:acml/src/ui/screens/orders/gtdorder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/market_status/market_status_bloc.dart';
import '../../../blocs/orders/order_log/order_log_bloc.dart';
import '../../../blocs/orders/orders_bloc.dart';
import '../../../blocs/watchlist/watchlist_bloc.dart';
import '../../../constants/keys/watchlist_keys.dart';
import '../../../localization/app_localization.dart';
import '../../styles/app_widget_size.dart';
import '../base/base_screen.dart';
import 'orders_screen.dart';

class OrdersMainScreen extends BaseScreen {
  final bool toGtd;
  const OrdersMainScreen({Key? key, this.toGtd = false}) : super(key: key);

  @override
  State<OrdersMainScreen> createState() => _OrdersMainScreenState();
}

class _OrdersMainScreenState extends BaseAuthScreenState<OrdersMainScreen>
    with TickerProviderStateMixin {
  ValueNotifier<int> tabIndex = ValueNotifier<int>(0);
  final AppLocalizations _appLocalizations = AppLocalizations();
  FocusNode searchFocusNode = FocusNode();

  List<Map<String, dynamic>> tabs = [];
  TabController? tabController;
  String symbolType = "";
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: _buildTabListWidget()),
      ],
    );
  }

  @override
  void initState() {
    tabs = _getTabList().toList();

    if (widget.toGtd) {
      tabIndex.value = 1;
    }

    tabController = TabController(vsync: this, length: tabs.length);
    if (tabController != null) {
      tabController!.animateTo(tabIndex.value);
      tabController!.index = tabIndex.value;
    }

    super.initState();
  }



  Widget _buildTabBarTitleView(Map<String, dynamic> item) {
    return Tab(
        child: Text(
      item['title'],
    ));
  }

  Widget _buildTabListWidget() {
    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder: (context, value, _) {
        return DefaultTabController(
          // key: const Key("marketTab1"),
          initialIndex: tabIndex.value,
          length: tabs.length,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              toolbarHeight: AppWidgetSize.dimen_40,
              automaticallyImplyLeading: false,
              elevation: 0,
              flexibleSpace: Container(
                alignment: Alignment.bottomCenter,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  controller: tabController,
                  key: const Key(marketsTabViewControllerKey),
                  isScrollable: false,
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorWeight: AppWidgetSize.dimen_2,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: Theme.of(context).primaryTextTheme.headlineMedium,
                  labelColor:
                      Theme.of(context).primaryTextTheme.headlineMedium!.color,
                  unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
                  unselectedLabelColor:
                      Theme.of(context).textTheme.labelLarge!.color,
                  tabs: tabs
                      .map((Map<String, dynamic> item) =>
                          _buildTabBarTitleView(item))
                      .toList(),
                ),
              ),
            ),
            body: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: tabs
                  .map(
                    (Map<String, dynamic> item) => _buildTabBarBodyView(item),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBarBodyView(Map<String, dynamic> item) {
    return item['view'];
  }

  List<Map<String, dynamic>> _getTabList() {
    final List<Map<String, dynamic>> tabList = <Map<String, dynamic>>[
      <String, dynamic>{
        'title': _appLocalizations.orders,
        'view': getOrdersProvider(),
      },
      if (Featureflag.gTD)
        <String, dynamic>{
          'title': _appLocalizations.gtdOrders,
          'view': getGtdordersProvider(),
        }
    ];
    return tabList;
  }

  MultiBlocProvider getOrdersProvider() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => OrdersBloc(),
        ),
        BlocProvider(
          create: (context) => WatchlistBloc(),
        ),
        BlocProvider(
          create: (context) => MarketStatusBloc(),
        ),
        BlocProvider(
          create: (context) => OrderLogBloc(),
        ),
      ],
      child: OrderScreen(searchFocusNode),
    );
  }

  MultiBlocProvider getGtdordersProvider() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => OrdersBloc(),
        ),
        BlocProvider(
          create: (context) => WatchlistBloc(),
        ),
        BlocProvider(
          create: (context) => MarketStatusBloc(),
        ),
        BlocProvider(
          create: (context) => OrderLogBloc(),
        ),
      ],
      child: GtdOrderScreen(searchFocusNode),
    );
  }
}
