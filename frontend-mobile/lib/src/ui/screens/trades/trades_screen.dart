import 'package:acml/src/config/app_config.dart';
import 'package:acml/src/ui/screens/orders/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/edis/edis_bloc.dart';
import '../../../blocs/holdings/holdings/holdings_bloc.dart';
import '../../../blocs/market_status/market_status_bloc.dart';
import '../../../blocs/my_funds/add_funds/add_funds_bloc.dart';
import '../../../blocs/my_funds/funds/my_funds_bloc.dart';
import '../../../blocs/orders/order_log/order_log_bloc.dart';
import '../../../blocs/orders/orders_bloc.dart';
import '../../../blocs/positions/positions/positions_bloc.dart';
import '../../../blocs/quote/main_quote/quote_bloc.dart';
import '../../../blocs/watchlist/watchlist_bloc.dart';
import '../../../constants/keys/positions_keys.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/market_indices_widget.dart';
import '../../widgets/toggle_circular_tabs_widget.dart';
import '../base/base_screen.dart';
import '../holdings/holdings_screen.dart';
import '../orders/orders_main.dart';
import '../positions/positions_screen.dart';

class TradesScreen extends BaseScreen {
  final dynamic arguments;

  const TradesScreen({Key? key, this.arguments}) : super(key: key);

  @override
  TradesScreenState createState() => TradesScreenState();
}

class TradesScreenState extends BaseAuthScreenState<TradesScreen>
    with TickerProviderStateMixin {
  late AppLocalizations _appLocalizations;
  List<String> toggleList = <String>[
    AppLocalizations().myOrders,
    AppLocalizations().positions,
    AppLocalizations().holdings,
  ];
  int selectedToggleIndex = 2;
  dynamic orderStatus;
  FocusNode searchFocusNode = FocusNode();
  @override
  void initState() {
    if (widget.arguments != null) {
      selectedToggleIndex = widget.arguments['selectedIndex'];
      orderStatus = widget.arguments['orderStatus'];
    }
    tabController = TabController(
        length: 3, initialIndex: selectedToggleIndex, vsync: this);
    tabController?.animation?.addListener(() {
      if (!FocusScope.of(context).hasPrimaryFocus &&
          FocusScope.of(context).focusedChild != null) {
        FocusManager.instance.primaryFocus?.unfocus();
        searchFocusNode.unfocus();
      }
      selectedToggleIndex = tabController?.index ?? 0;
      setState(() {});
    });
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.tradesScreen);
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: DefaultTabController(
          initialIndex: selectedToggleIndex,
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              automaticallyImplyLeading: false,
              centerTitle: false,
              backgroundColor: Colors.transparent,
              toolbarHeight: AppWidgetSize.getSize(AppWidgetSize.dimen_66),
              title: SizedBox(
                height: 100.w,
                child: _buildTopAppBarContent(),
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                      width: AppWidgetSize.dimen_1,
                      color: Theme.of(context).dividerColor),
                ),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: _buildBody(),
            ),
          ),
        ),
      ),
    );
  }

  TabController? tabController;

  Widget _buildTopAppBarContent() {
    return Container(
      height: AppWidgetSize.fullWidth(context),
      padding: EdgeInsets.only(
        left: 30.w,
        right: 20.w,
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppWidgetSize.screenWidth(context) * 0.63,
            child: ToggleCircularTabsWidget(
              tabController: tabController!,
              key: const Key(positionsToggleWidgetKey),
              height: AppWidgetSize.dimen_35,
              minWidth: 120.w,
              cornerRadius: AppWidgetSize.dimen_20,
              labels: toggleList,
              initialLabel: selectedToggleIndex,
              onToggle: (int selectedTabValue) {
                selectedToggleIndex = selectedTabValue;
                tabController!.animateTo(selectedToggleIndex);
              },
            ),
          ),
          SizedBox(
            width: 16.w,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (selectedToggleIndex == 2 || selectedToggleIndex == 0)
                  GestureDetector(
                    onTap: () {
                      if (selectedToggleIndex == 0) {
                        showMyordersInforBottomSheet();
                      }
                      if (selectedToggleIndex == 2) {
                        showHoldingsInforBottomSheet();
                      }
                      // if (selectedToggleIndex == 1) {
                      //   showPositionsInforBottomSheet();
                      // } else {
                      //   showHoldingsInforBottomSheet();
                      // }
                    },
                    child: AppImages.informationIcon(
                      context,
                      width: AppWidgetSize.dimen_24,
                      height: AppWidgetSize.dimen_24,
                      color: Theme.of(context).primaryIconTheme.color,
                      isColor: true,
                    ),
                  ),
                SizedBox(
                  width: 16.w,
                ),
                const MarketIndicesTopWidget()
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> showPositionsInforBottomSheet() async {
    List<Widget> informationWidgetList = [
      Divider(
        thickness: 1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowForBottomSheetHoldings(
        context,
        _appLocalizations.openInfotitle1,
        _appLocalizations.openPosDesc,
        // _appLocalizations.holdingsDesc1,
      ),
      _buildExpansionRowForBottomSheetHoldingsTile1(
        context,
        _appLocalizations.holdingsDesc1,
        _appLocalizations.holdingsDesc2,
        _appLocalizations.holdingsDesc3,
        _appLocalizations.holdingsDesc4,
        _appLocalizations.holdingsDesc5,
      ),
      _buildExpansionRowForBottomSheetHoldingsTile2(
        context,
        _appLocalizations.navNxtScn,
        _appLocalizations.navNxtScnDesc,
        _appLocalizations.navNxtScnDesc1,
        _appLocalizations.navNxtScnDesc2_1,
        _appLocalizations.navNxtScnDesc2_2,
        _appLocalizations.navNxtScnDesc3_1,
        _appLocalizations.navNxtScnDesc3_2,
        _appLocalizations.navNxtScnDesc4_1,
        _appLocalizations.navNxtScnDesc4_2,
        _appLocalizations.navNxtScnDesc5,
        _appLocalizations.navNxtScnDesc6,
        _appLocalizations.navNxtScnDesc7,
        _appLocalizations.viwRepDesc,
      ),
    ];
    return showInfoBottomsheet(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  width: 20.w,
                  height: 20.w,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true,
                ),
              )
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 20.w,
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
    );
  }

  Future<void> showHoldingsInforBottomSheet() async {
    List<Widget> informationWidgetList = [
      _buildExpansionRowForBottomSheetHoldings(
        context,
        _appLocalizations.watrHoldings,
        _appLocalizations.holdingsDesc,
        // _appLocalizations.holdingsDesc1,
      ),
      Divider(
        thickness: 1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowForBottomSheetHoldingsTile1(
        context,
        _appLocalizations.holdingsDesc1,
        _appLocalizations.holdingsDesc2,
        _appLocalizations.holdingsDesc3,
        _appLocalizations.holdingsDesc4,
        _appLocalizations.holdingsDesc5,
      ),
      Divider(
        thickness: 1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowForBottomSheetHoldingsTile2(
        context,
        _appLocalizations.navNxtScn,
        _appLocalizations.navNxtScnDesc,
        _appLocalizations.navNxtScnDesc1,
        _appLocalizations.navNxtScnDesc2_1,
        _appLocalizations.navNxtScnDesc2_2,
        _appLocalizations.navNxtScnDesc3_1,
        _appLocalizations.navNxtScnDesc3_2,
        _appLocalizations.navNxtScnDesc4_1,
        _appLocalizations.navNxtScnDesc4_2,
        _appLocalizations.navNxtScnDesc5,
        _appLocalizations.navNxtScnDesc6,
        _appLocalizations.navNxtScnDesc7,
        _appLocalizations.viwRepDesc,
      ),
      Divider(
        thickness: 1,
        color: Theme.of(context).dividerColor,
      ),
    ];
    return showInfoBottomsheet(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextWidget(
                    _appLocalizations.holdings,
                    Theme.of(context).primaryTextTheme.titleMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: AppImages.closeIcon(
                      context,
                      width: 20.w,
                      height: 20.w,
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
                  left: 24.w,
                  right: 24.w,
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

  Future<void> showMyordersInforBottomSheet() async {
    List<Widget> informationWidgetList = [
      _buildExpansionRowForBottomSheetOrders(context),
      Divider(
        thickness: 1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRowForBottomSheetOrdersTile1(context),
      Divider(
        thickness: 1,
        color: Theme.of(context).dividerColor,
      ),
    ];
    return showInfoBottomsheet(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                _appLocalizations.myOrders,
                Theme.of(context).primaryTextTheme.titleMedium,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: AppImages.closeIcon(
                  context,
                  width: 20.w,
                  height: 20.w,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true,
                ),
              )
            ],
          ),
          Divider(
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
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
        ],
      ),
      height: AppWidgetSize.screenHeight(context) * 0.75,
    );
  }

  Widget _buildExpansionRowForBottomSheetOrders(
    BuildContext context,
  ) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.only(
          right: 0,
          left: 0,
          bottom: 5.w,
        ),
        collapsedIconColor: Theme.of(context).primaryIconTheme.color,
        title: CustomTextWidget(_appLocalizations.myorderFirstQue,
            Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.left),
        iconColor: Theme.of(context).primaryIconTheme.color,
        children: <Widget>[
          CustomTextWidget(_appLocalizations.myorderFirstAns1_1,
              Theme.of(context).primaryTextTheme.labelSmall,
              textAlign: TextAlign.justify),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8.w,
                      left: AppWidgetSize.dimen_16,
                      right: 4.w,
                    ),
                    child: Icon(
                      Icons.circle,
                      size: AppWidgetSize.dimen_6,
                      color: Theme.of(context).textTheme.displaySmall?.color,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                        child: RichText(
                            textAlign: TextAlign.justify,
                            text: TextSpan(children: [
                              TextSpan(
                                text: _appLocalizations.myorderFirstAns1_2,
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .labelSmall,
                              ),
                            ]))),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8.w,
                      left: AppWidgetSize.dimen_16,
                      right: 4.w,
                    ),
                    child: Icon(
                      Icons.circle,
                      size: AppWidgetSize.dimen_6,
                      color: Theme.of(context).textTheme.displaySmall?.color,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                        child: RichText(
                            textAlign: TextAlign.justify,
                            text: TextSpan(children: [
                              TextSpan(
                                text: _appLocalizations.myorderFirstAns1_3,
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .labelSmall,
                              ),
                            ]))),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8.w,
                      left: AppWidgetSize.dimen_16,
                      right: 4.w,
                    ),
                    child: Icon(
                      Icons.circle,
                      size: AppWidgetSize.dimen_6,
                      color: Theme.of(context).textTheme.displaySmall?.color,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                        child: RichText(
                            textAlign: TextAlign.justify,
                            text: TextSpan(children: [
                              TextSpan(
                                text: _appLocalizations.myorderFirstAns1_4,
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .labelSmall,
                              ),
                            ]))),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionRowForBottomSheetHoldings(
    BuildContext context,
    String title,
    String description1,
    // String description2,
  ) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.only(
          right: 0,
          left: 0,
          bottom: 5.w,
        ),
        collapsedIconColor: Theme.of(context).primaryIconTheme.color,
        title: CustomTextWidget(
          title,
          Theme.of(context).textTheme.headlineMedium,
        ),
        iconColor: Theme.of(context).primaryIconTheme.color,
        children: <Widget>[
          CustomTextWidget(
            description1,
            Theme.of(context).primaryTextTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionRowForBottomSheetHoldingsTile1(
    BuildContext context,
    String title,
    String description1,
    String description2,
    String description3,
    String description4,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: 5.w,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
            title,
            Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.left,
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              description1,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget('${_appLocalizations.buy} : ',
                      Theme.of(context).primaryTextTheme.headlineSmall),
                  Expanded(
                    child: CustomTextWidget(
                      description2,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
            // CustomTextWidget(
            //   description2,
            //   Theme.of(context).primaryTextTheme.overline,
            // ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    '${_appLocalizations.sell} : ',
                    Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                          color: AppColors.negativeColor,
                          // Theme.of(context).primaryTextTheme.overline,
                        ),
                  ),
                  Expanded(
                    child: CustomTextWidget(
                      description3,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: 20.w, bottom: AppWidgetSize.dimen_15),
              child: Image(image: AppImages.holdingsImage()),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
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

  Widget _buildExpansionRowForBottomSheetOrdersTile1(
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 8.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: 5.w,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(_appLocalizations.myorderSecQue,
              Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.left),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              _appLocalizations.myorderSecAns2_1,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),

            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _appLocalizations.navNxtScnSubTitle1,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: _appLocalizations.myorderSecAns2_2,
                      style: Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(children: [
                      TextSpan(
                        text: _appLocalizations.navNxtScnSubTitle2,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: _appLocalizations.myorderSecAns2_3,
                        style: Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                      WidgetSpan(
                          child: AppImages.filterIcon(context,
                              isColor: true,
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .color)),
                      TextSpan(
                        text: ".",
                        style: Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                    ]))),
            Padding(
              padding: EdgeInsets.only(top: 8.w, bottom: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextWidget(
                      _appLocalizations.myorderSecAns2_4,
                      Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left),
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomTextWidget(
                  _appLocalizations.myorderSecAns2_5,
                  Theme.of(context).primaryTextTheme.labelSmall,
                ),
              ],
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.w,
                    left: AppWidgetSize.dimen_16,
                    right: 4.w,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: AppWidgetSize.dimen_6,
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text: _appLocalizations.myorderSecAns2_6,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                          ]))),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.w,
                    left: AppWidgetSize.dimen_16,
                    right: 4.w,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: AppWidgetSize.dimen_6,
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text: _appLocalizations.myorderSecAns2_7,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                          ]))),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.w,
                    left: AppWidgetSize.dimen_16,
                    right: 4.w,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: AppWidgetSize.dimen_6,
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text: _appLocalizations.myorderSecAns2_8,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                          ]))),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomTextWidget(
                  _appLocalizations.myorderSecAns2_9,
                  Theme.of(context).primaryTextTheme.labelSmall,
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.w,
                    left: AppWidgetSize.dimen_16,
                    right: 4.w,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: AppWidgetSize.dimen_6,
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text: _appLocalizations.myorderSecAns2_10,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                          ]))),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.w,
                    left: AppWidgetSize.dimen_16,
                    right: 4.w,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: AppWidgetSize.dimen_6,
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text: _appLocalizations.myorderSecAns2_11,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                          ]))),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.w,
                    left: AppWidgetSize.dimen_16,
                    right: 4.w,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: AppWidgetSize.dimen_6,
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text: _appLocalizations.myorderSecAns2_12,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                          ]))),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.w,
                    left: AppWidgetSize.dimen_16,
                    right: 4.w,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: AppWidgetSize.dimen_6,
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text: _appLocalizations.myorderSecAns2_13,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                          ]))),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.w,
                    left: AppWidgetSize.dimen_16,
                    right: 4.w,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: AppWidgetSize.dimen_6,
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text: _appLocalizations.myorderSecAns2_14,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                          ]))),
                ),
              ],
            ),
            Image(image: AppImages.tradeOrders()),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.w,
                    left: AppWidgetSize.dimen_16,
                    right: 4.w,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: AppWidgetSize.dimen_6,
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text: _appLocalizations.navNxtScnSubTitle5,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: _appLocalizations.myorderSecAns2_15,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                          ]))),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.w,
                    left: 38.w,
                    right: 4.w,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: AppWidgetSize.dimen_6,
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text: _appLocalizations.myorderSecAns2_16,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                          ]))),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.w,
                    left: 38.w,
                    right: 4.w,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: AppWidgetSize.dimen_6,
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text: _appLocalizations.myorderSecAns2_17,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                          ]))),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.w,
                    left: 38.w,
                    right: 4.w,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: AppWidgetSize.dimen_6,
                    color: Theme.of(context).textTheme.displaySmall?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text: _appLocalizations.myorderSecAns2_18,
                              style:
                                  Theme.of(context).primaryTextTheme.labelSmall,
                            ),
                          ]))),
                ),
              ],
            ),
            // Padding(
            //   padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Padding(
            //         padding: EdgeInsets.only(
            //           top:8.w,
            //           left: AppWidgetSize.dimen_16,
            //           right:4.w,
            //         ),
            //         child: Icon(
            //           Icons.circle,
            //           size: AppWidgetSize.dimen_6,
            //           color: Colors.black,
            //         ),
            //       ),
            //       Expanded(
            //         child: Padding(
            //           padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
            //           child: RichText(
            //             // textAlign: TextAlign.center,
            //             text: TextSpan(
            //               text: _appLocalizations.navNxtScnSubTitle4,
            //               style: Theme.of(context).textTheme.headline4,
            //               children: [
            //                 TextSpan(
            //                     text: description9,
            //                     style: Theme.of(context)
            //                         .primaryTextTheme
            //                         .overline),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionRowForBottomSheetHoldingsTile2(
    BuildContext context,
    String title,
    String description1,
    String description2,
    String description3_1,
    String description3_2,
    String description4_1,
    String description4_2,
    String description5_1,
    String description5_2,
    String description6,
    String description7,
    String description8,
    String description9,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 8.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: 5.w,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
            title,
            Theme.of(context).textTheme.headlineMedium,
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              description1,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),

            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: Align(
                alignment: Alignment.topLeft,
                child: CustomTextWidget(
                  _appLocalizations.navNxtScnSubTitle,
                  Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: CustomTextWidget(
                description2,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: AppWidgetSize.dimen_25, bottom: 25.h),
              child: Image(
                image: AppImages.holdingDescimg(),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(children: [
                      TextSpan(
                        text: description3_1,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: description3_2,
                        style: Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                      WidgetSpan(
                          child: AppImages.searchIcon(context,
                              isColor: true,
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .color)),
                      TextSpan(
                        text: ".",
                        style: Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                    ]))),
            Padding(
                padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(children: [
                      TextSpan(
                        text: _appLocalizations.navNxtScnDesc3_1,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: _appLocalizations.navNxtScnDesc3_2,
                        style: Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                      WidgetSpan(
                          child: AppImages.filterIcon(context,
                              isColor: true,
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .color)),
                      TextSpan(
                        text: _appLocalizations.navNxtScnDesc3_3,
                        style: Theme.of(context).primaryTextTheme.labelSmall,
                      )
                    ]))),
            Padding(
                padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
                child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(children: [
                      TextSpan(
                        text: description5_1,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: description5_2,
                        style: Theme.of(context).primaryTextTheme.labelSmall,
                      )
                    ]))),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8.w,
                      left: 24.w,
                      right: 4.w,
                    ),
                    child: Icon(
                      Icons.circle,
                      size: AppWidgetSize.dimen_6,
                      color: Theme.of(context).textTheme.displaySmall?.color,
                    ),
                  ),
                  Expanded(
                    child: CustomTextWidget(
                      description6,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8.w,
                      left: 24.w,
                      right: 4.w,
                    ),
                    child: Icon(
                      Icons.circle,
                      size: AppWidgetSize.dimen_6,
                      color: Theme.of(context).textTheme.displaySmall?.color,
                    ),
                  ),
                  Expanded(
                    child: CustomTextWidget(
                      description7,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8.w,
                      left: 24.w,
                      right: 4.w,
                    ),
                    child: Icon(
                      Icons.circle,
                      size: AppWidgetSize.dimen_6,
                      color: Theme.of(context).textTheme.displaySmall?.color,
                    ),
                  ),
                  Expanded(
                    child: CustomTextWidget(
                      description8,
                      Theme.of(context).primaryTextTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: Align(
                alignment: Alignment.topLeft,
                child: CustomTextWidget(
                  _appLocalizations.navNxtScnSubTitle4,
                  Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: CustomTextWidget(
                description9,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Padding(
            //         padding: EdgeInsets.only(
            //           top:8.w,
            //           left: AppWidgetSize.dimen_16,
            //           right:4.w,
            //         ),
            //         child: Icon(
            //           Icons.circle,
            //           size: AppWidgetSize.dimen_6,
            //           color: Colors.black,
            //         ),
            //       ),
            //       Expanded(
            //         child: Padding(
            //           padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
            //           child: RichText(
            //             // textAlign: TextAlign.center,
            //             text: TextSpan(
            //               text: _appLocalizations.navNxtScnSubTitle4,
            //               style: Theme.of(context).textTheme.headline4,
            //               children: [
            //                 TextSpan(
            //                     text: description9,
            //                     style: Theme.of(context)
            //                         .primaryTextTheme
            //                         .overline),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    return TabBarView(
      controller: tabController,
      children: [
        MultiBlocProvider(
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
          child: Featureflag.gTD
              ? OrdersMainScreen(
                  toGtd: (widget.arguments["toGtd"] ?? false) ? true : false,
                )
              : OrderScreen(searchFocusNode),
        ),
        //const OrdersMainScreen(),
        MultiBlocProvider(providers: [
          BlocProvider(
            create: (context) => PositionsBloc(),
          ),
          BlocProvider(
            create: (context) => MyFundsBloc(),
          ),
          BlocProvider<QuoteBloc>(
            create: (context) => QuoteBloc(),
          ),
          BlocProvider(
            create: (context) => AddFundsBloc(),
          ),
        ], child: PositionsScreen(searchFocusNode)),
        BlocProvider<EdisBloc>(
          create: (context) => EdisBloc(),
          child: BlocProvider<QuoteBloc>(
            create: (context) => QuoteBloc(),
            child: BlocProvider<HoldingsBloc>(
              create: (context) => HoldingsBloc(),
              child: HoldingsScreen(searchFocusNode),
            ),
          ),
        )
      ],
    );
  }
}
