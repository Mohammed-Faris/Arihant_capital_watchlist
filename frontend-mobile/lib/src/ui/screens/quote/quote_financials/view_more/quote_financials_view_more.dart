import 'package:acml/src/ui/widgets/Swapbutton_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../../../blocs/quote/financials/financials_view_more/financials_view_more_bloc.dart';
import '../../../../../blocs/quote/main_quote/quote_bloc.dart';
import '../../../../../constants/keys/quote_keys.dart';
import '../../../../../data/store/app_utils.dart';
import '../../../../../localization/app_localization.dart';
import '../../../../../models/common/symbols_model.dart';
import '../../../../navigation/screen_routes.dart';
import '../../../../styles/app_widget_size.dart';
import '../../../../widgets/custom_text_widget.dart';
import '../../../base/base_screen.dart';
import 'quote_financials_income_statements.dart';
import 'quote_financials_share_holdings.dart';

class QuoteFinancialsViewMore extends BaseScreen {
  final dynamic arguments;
  const QuoteFinancialsViewMore({Key? key, this.arguments}) : super(key: key);

  @override
  State<QuoteFinancialsViewMore> createState() =>
      _QuoteFinancialsViewMoreState();
}

class _QuoteFinancialsViewMoreState
    extends BaseAuthScreenState<QuoteFinancialsViewMore>
    with TickerProviderStateMixin {
  TabController? tabController;
  List<Map<String, dynamic>> tabs = [];
  late AppLocalizations _appLocalizations;
  late Symbols _symbols;
  late FinancialsViewMoreBloc financialsViewMoreBloc;
  late QuoteBloc quoteBloc;
  ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _appLocalizations = AppLocalizations();

    _symbols = widget.arguments['symbolItem'];
    setTabController(0);
    quoteBloc = BlocProvider.of<QuoteBloc>(context);

    financialsViewMoreBloc = BlocProvider.of<FinancialsViewMoreBloc>(context)
      ..stream.listen(financialListener);
    financialsViewMoreBloc.add(
      QuoteFinancialsStartSymStreamEvent(_symbols),
    );

    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.quoteFinancialsViewMore);
  }

  Future<void> financialListener(
    FinancialsViewMoreState state,
  ) async {
    if (state is FinancialsSymStreamState) {
      subscribeLevel1(state.streamDetails);
    }
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.quoteFinancialsViewMore;
  }

  @override
  void quote1responseCallback(ResponseData data) {
    financialsViewMoreBloc.add(
      QuoteFinancialsStreamingResponseEvent(data),
    );
  }

  void setTabController(int position) {
    tabs = _getTabList();
    tabController = TabController(vsync: this, length: tabs.length);
    tabIndex.value = position;
  }

  @override
  Widget build(BuildContext context) {
    _symbols = widget.arguments['symbolItem'];
    tabs = _getTabList();
    tabController = TabController(vsync: this, length: tabs.length);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildTabListWidget(),
      ),
    );
  }

  ValueNotifier<bool> consolidated = ValueNotifier<bool>(true);
  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      toolbarHeight: AppWidgetSize.dimen_60,
      elevation: 0.0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: AppWidgetSize.dimen_2,
                  right: AppWidgetSize.dimen_10,
                ),
                child: backIconButton(),
              ),
              _buildAppBarWidget(),
            ],
          ),
          ValueListenableBuilder<bool>(
              valueListenable: consolidated,
              builder: (context, snapshot, _) {
                return SwappingWidget.drop(
                  value: consolidated,
                  onTap: () {
                    consolidated.value = !consolidated.value;
                  },
                );
              })
        ],
      ),
    );
  }

  Widget _buildTabListWidget() {
    return DefaultTabController(
      initialIndex: tabIndex.value,
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          toolbarHeight: AppWidgetSize.dimen_40,
          automaticallyImplyLeading: false,
          elevation: 2,
          shadowColor: Theme.of(context).inputDecorationTheme.fillColor,
          flexibleSpace: Container(
            alignment: Alignment.bottomLeft,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: tabController,
              key: const Key(quoteTabViewControllerKey),
              isScrollable: true,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: AppWidgetSize.dimen_2,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(fontSize: AppWidgetSize.fontSize16),
              labelColor:
                  Theme.of(context).primaryTextTheme.headlineMedium!.color,
              unselectedLabelStyle: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontSize: AppWidgetSize.fontSize16),
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
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          children: tabs
              .map(
                (Map<String, dynamic> item) => _buildTabBarBodyView(item),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildAppBarWidget() {
    return BlocBuilder<FinancialsViewMoreBloc, FinancialsViewMoreState>(
        buildWhen: (FinancialsViewMoreState previous,
            FinancialsViewMoreState current) {
      return current is FinancialsDataState;
    }, builder: (context, state) {
      if (state is FinancialsDataState) {
        return _buildDispSymLtpChngWidget(state.symbols!);
      }
      return Container();
    });
  }

  Widget _buildDispSymLtpChngWidget(Symbols symbols) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: AppWidgetSize.dimen_15,
          width: AppWidgetSize.screenWidth(context) * 0.4,
          child: CustomTextWidget(
              symbols.companyName == null
                  ? AppUtils().dataNullCheck(symbols.dispSym!)
                  : AppUtils().dataNullCheck(symbols.dispSym!),
              Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: AppWidgetSize.fontSize14,
                  ),
              textOverflow: TextOverflow.ellipsis),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_5,
            bottom: AppWidgetSize.dimen_5,
          ),
          child: Row(
            children: [
              CustomTextWidget(
                AppUtils().dataNullCheck(symbols.ltp),
                Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: AppWidgetSize.fontSize14,
                      color: AppUtils().setcolorForChange(
                          AppUtils().dataNullCheck(symbols.chng)),
                    ),
                isShowShimmer: true,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_1,
                  left: AppWidgetSize.dimen_5,
                ),
                child: CustomTextWidget(
                  AppUtils().getChangePercentage(symbols),
                  Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                        color: Theme.of(context)
                            .inputDecorationTheme
                            .labelStyle!
                            .color,
                        fontSize: AppWidgetSize.fontSize12,
                      ),
                  isShowShimmer: true,
                ),
              ),
            ],
          ),
        )
      ],
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
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarBodyView(Map<String, dynamic> item) {
    return item['view'];
  }

  List<Map<String, dynamic>> _getTabList() {
    final List<Map<String, dynamic>> tabList = <Map<String, dynamic>>[
      <String, dynamic>{
        'title': _appLocalizations.quoteFinancialsIncomeStatements,
        'view': BlocProvider(
          create: (context) => FinancialsViewMoreBloc(),
          child: ValueListenableBuilder<bool>(
              valueListenable: consolidated,
              builder: (context, value, _) {
                return QuoteFinancialsIncomeStatements(
                    arguments: {'symbolItem': _symbols, 'consolidated': value});
              }),
        ),
      },
      <String, dynamic>{
        'title': _appLocalizations.quoteFinancialsShareHoldings,
        'view': BlocProvider(
            create: (context) => FinancialsViewMoreBloc(),
            child: ValueListenableBuilder<bool>(
                valueListenable: consolidated,
                builder: (context, value, _) {
                  return QuoteFinancialsShareHoldings(arguments: {
                    'symbolItem': _symbols,
                    'consolidated': value
                  });
                })),
      },
    ];
    return tabList;
  }
}
