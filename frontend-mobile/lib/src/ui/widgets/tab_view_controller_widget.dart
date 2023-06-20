import 'package:flutter/material.dart';

import '../../constants/keys/widget_keys.dart';
import '../../localization/app_localization.dart';
import '../styles/app_widget_size.dart';

class TabViewControllerWidget extends StatefulWidget {
  final String screenName;
  final List<Map<String, dynamic>> paramlist;
  final String? extras;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final Alignment? alignment;
  final Color? indicatorColor;
  final TabBarIndicatorSize? indicatorSize;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? tabBackgroundColor;
  final Color? scaffoldColor;
  final int? currentTab;

  const TabViewControllerWidget(
      {Key? key,
      required this.screenName,
      required this.paramlist,
      this.extras,
      this.labelStyle,
      this.unselectedLabelStyle,
      this.alignment,
      this.indicatorColor,
      this.indicatorSize,
      this.labelColor,
      this.unselectedLabelColor,
      this.tabBackgroundColor,
      this.scaffoldColor,
      this.currentTab})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TabViewControllerState();
  }
}

class _TabViewControllerState extends State<TabViewControllerWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AppLocalizations appLocalizations;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentTab ?? 0;
    _tabController = TabController(
        initialIndex: 0, length: widget.paramlist.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context)!;
    _tabController = TabController(
        initialIndex: 0, length: widget.paramlist.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        currentIndex = _tabController.index;
      }
    });
    return _buildTabView();
  }

  Widget _buildTabView() {
    if (widget.extras == 'quoteExchangeToggle') {
      if (currentIndex >= widget.paramlist.length) {
        currentIndex = widget.paramlist.length - 1;
      }
    }

    _tabController.animateTo(currentIndex);

    return DefaultTabController(
      key: widget.key,
      initialIndex: currentIndex,
      length: widget.paramlist.length,
      child: Scaffold(
        backgroundColor:
            widget.scaffoldColor ?? Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          toolbarHeight: 40.w,
          automaticallyImplyLeading: false,
          elevation: 2,
          shadowColor: Theme.of(context).inputDecorationTheme.fillColor,
          flexibleSpace: Container(
              alignment: widget.alignment ?? Alignment.bottomCenter,
              color: widget.tabBackgroundColor ?? Colors.transparent,
              child: TabBar(
                  controller: _tabController,
                  key: const Key(tabViewControllerTabListKey),
                  isScrollable: true,
                  indicatorColor:
                      widget.indicatorColor ?? Theme.of(context).primaryColor,
                  indicatorWeight: AppWidgetSize.dimen_2,
                  indicatorSize:
                      widget.indicatorSize ?? TabBarIndicatorSize.tab,
                  labelStyle: widget.labelStyle ??
                      Theme.of(context)
                          .primaryTextTheme
                          .labelLarge!
                          .copyWith(fontWeight: FontWeight.w700),
                  labelColor: widget.labelColor ??
                      Theme.of(context).primaryTextTheme.labelLarge!.color,
                  unselectedLabelStyle: widget.unselectedLabelStyle ??
                      Theme.of(context)
                          .primaryTextTheme
                          .labelLarge!
                          .copyWith(fontWeight: FontWeight.w400),
                  unselectedLabelColor: widget.unselectedLabelColor ??
                      Theme.of(context).textTheme.labelLarge!.color,
                  tabs: widget.paramlist
                      .map((Map<String, dynamic> item) =>
                          _buildTabBarTitleView(item))
                      .toList())),
        ),
        body: TabBarView(
            controller: _tabController,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            children: widget.paramlist
                .map((Map<String, dynamic> item) => _buildTabBarBodyView(item))
                .toList()),
      ),
    );
  }

  Widget _buildTabBarTitleView(Map<String, dynamic> item) {
    return Tab(
      key: Key(tabViewControllerTabKey_ + item['title'].toLowerCase()),
      child: SizedBox(
        child: Text(
          item['title'],
        ),
      ),
    );
  }

  Widget _buildTabBarBodyView(Map<String, dynamic> item) {
    return item['view'];
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}
