import 'package:acml/src/ui/screens/markets/markets_cash/markets_cash_screen.dart';
import 'package:acml/src/ui/widgets/refresh_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/markets/markets_bloc.dart';
import '../../../blocs/quote/deals/deals_bloc.dart';
import '../../../constants/keys/watchlist_keys.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../styles/app_widget_size.dart';
import '../base/base_screen.dart';
import 'markets_fno/markets_fno_screen.dart';

ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

class MarketsScreen extends BaseScreen {
  const MarketsScreen({Key? key}) : super(key: key);

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends BaseAuthScreenState<MarketsScreen>
    with TickerProviderStateMixin {
  final AppLocalizations _appLocalizations = AppLocalizations();
  TabController? tabController;
  String symbolType = "";
  late TabController tabControllerFno;
  late TabController tabControllerCash;

  @override
  Widget build(BuildContext context) {
    return _buildTabListWidget();
  }

  @override
  void initState() {
    isLoading.value = false;
    tabControllerCash = TabController(
        vsync: this, length: AppUtils.marketMoverTabKeysCash.length);
    tabControllerFno = TabController(
        vsync: this, length: AppUtils.marketMoverTabKeysDerivatives.length);

    tabController = TabController(vsync: this, length: 2);

    super.initState();
  }

  Widget _buildTabListWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: DefaultTabController(
            // key: const Key("marketTab1"),
            length: tabController?.length ?? 0,
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                toolbarHeight: AppWidgetSize.dimen_40,
                automaticallyImplyLeading: false,
                elevation: 2,
                shadowColor: Theme.of(context).inputDecorationTheme.fillColor,
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
                    tabs: [
                      _appLocalizations.marketsCash,
                      _appLocalizations.marketsFandO
                    ]
                        .map((String item) => Tab(
                                child: Text(
                              item,
                            )))
                        .toList(),
                  ),
                ),
              ),
              body: TabBarView(
                  controller: tabController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  children: [
                    RefreshWidget(
                        onRefresh: () async {
                          isLoading.value = true;
                          Future.delayed(const Duration(milliseconds: 50), () {
                            isLoading.value = false;
                          });
                        },
                        child: MultiBlocProvider(
                          providers: <BlocProvider<dynamic>>[
                            BlocProvider<MarketsBloc>(
                              create: (context) => MarketsBloc(),
                            ),
                          ],
                          child: MarketsCashScreen(tabControllerCash),
                        )),
                    RefreshWidget(
                        onRefresh: () async {
                          isLoading.value = true;
                          Future.delayed(const Duration(milliseconds: 50), () {
                            isLoading.value = false;
                          });
                        },
                        child: MultiBlocProvider(
                          providers: <BlocProvider<dynamic>>[
                            BlocProvider<MarketsBloc>(
                              create: (context) => MarketsBloc(),
                            ),
                            BlocProvider(
                              create: (context) => QuotesDealsBloc(),
                            ),
                          ],
                          child: MarketsFNOScreen(tabControllerFno),
                        ))
                  ]),
            ),
          ),
        ),
      ],
    );
  }
}
