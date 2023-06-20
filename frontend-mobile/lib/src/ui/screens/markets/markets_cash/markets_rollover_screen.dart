import 'package:acml/src/blocs/rollover/rollover_bloc.dart';
import 'package:acml/src/ui/screens/base/base_screen.dart';
import 'package:acml/src/ui/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../../constants/app_constants.dart';
import '../../../../constants/keys/watchlist_keys.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/error_image_widget.dart';
import '../../../widgets/refresh_widget.dart';
import '../../watchlist/widget/watchlist_list_widget.dart';

class MarketsRollOverArgs {
  final bool isFullScreen;
  final int index;

  MarketsRollOverArgs(this.isFullScreen, this.index);
}

class MarketsRollOver extends BaseScreen {
  // ignore: prefer_typing_uninitialized_variables
  final MarketsRollOverArgs args;
  const MarketsRollOver(this.args, {super.key});

  @override
  State<MarketsRollOver> createState() => _MarketsRollOverState();
}

class _MarketsRollOverState extends BaseAuthScreenState<MarketsRollOver>
    with TickerProviderStateMixin {
  late TabController tabControllerRollOver;

  @override
  void initState() {
    tabControllerRollOver = TabController(vsync: this, length: 3);
    tabControllerRollOver.animateTo(widget.args.index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.args.isFullScreen
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: backIconButton(
                        customColor:
                            Theme.of(context).textTheme.headlineMedium!.color),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: AppWidgetSize.dimen_25),
                    child: CustomTextWidget(AppLocalizations().rollOver,
                        Theme.of(context).textTheme.headlineMedium),
                  ),
                ],
              ),
              toolbarHeight: AppWidgetSize.dimen_60,
            ),
            body: _buildTabListWidget(),
          )
        : _buildTabListWidget();
  }

  Widget _buildTabListWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.args.isFullScreen)
          Expanded(child: tabBody())
        else
          SizedBox(
            height: widget.args.isFullScreen
                ? AppWidgetSize.screenHeight(context) - 120.w
                : AppWidgetSize.dimen_550,
            child: tabBody(),
          ),
      ],
    );
  }

  DefaultTabController tabBody() {
    return DefaultTabController(
      // key: const Key("marketTab1"),
      initialIndex: tabControllerRollOver.index,
      length: tabControllerRollOver.length,
      child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            toolbarHeight: AppWidgetSize.dimen_48,
            automaticallyImplyLeading: false,
            elevation: 2,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            centerTitle: false,
            leading: const SizedBox.shrink(),
            leadingWidth: 0,
            shadowColor: Theme.of(context).inputDecorationTheme.fillColor,
            flexibleSpace: Container(
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.only(left: 20.w),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: topBar()),
          ),
          body: tabView()),
    );
  }

  TabBarView tabView() {
    return TabBarView(
      controller: tabControllerRollOver,
      physics: const AlwaysScrollableScrollPhysics(),
      children: List.generate(
          AppUtils.rollOverCashKeys.length,
          (index) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!widget.args.isFullScreen)
                    Container(
                      height: 425.w,
                      padding: EdgeInsets.only(top: 10.w),
                      child: BlocProvider(
                          create: (context) => RollOverBloc(),
                          child: MarkrtRollOverDataScreen(AppConstants.cash,
                              AppUtils.rollOverCashKeys[index], false)),
                    )
                  else
                    Expanded(
                      child: BlocProvider(
                          create: (context) => RollOverBloc(),
                          child: MarkrtRollOverDataScreen(AppConstants.cash,
                              AppUtils.rollOverCashKeys[index], true)),
                    ),
                  if (!widget.args.isFullScreen)
                    Padding(
                      padding: EdgeInsets.only(top: 5.w),
                      child: GestureDetector(
                        onTap: () {
                          pushNavigation(ScreenRoutes.rollOverScreen,
                              arguments: MarketsRollOverArgs(true, index));
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: AppWidgetSize.dimen_20,
                              right: AppWidgetSize.dimen_20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomTextWidget(
                                AppLocalizations().viewMore,
                                Theme.of(context)
                                    .primaryTextTheme
                                    .headlineMedium
                                    ?.copyWith(
                                        fontSize: AppWidgetSize.fontSize16),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                ],
              )).toList(),
    );
  }

  TabBar topBar() {
    return TabBar(
      padding: EdgeInsets.zero,
      controller: tabControllerRollOver,
      key: const Key(marketsRolloverTabControllerKey),
      isScrollable: true,
      labelPadding: EdgeInsets.only(right: 15.w, left: 8.w),
      indicatorPadding: EdgeInsets.only(right: 3.w, left: 0.w),
      indicatorColor: Theme.of(context).primaryColor,
      indicatorWeight: AppWidgetSize.dimen_2,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: Theme.of(context).primaryTextTheme.headlineMedium,
      labelColor: Theme.of(context).primaryTextTheme.headlineMedium!.color,
      unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
      unselectedLabelColor: Theme.of(context).textTheme.labelLarge!.color,
      tabs: AppUtils.rollOverDispKeys
          .map((String item) => _buildTabBarTitleView(item))
          .toList(),
    );
  }

  Widget _buildTabBarTitleView(String item) {
    return Tab(
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              item,
            ),
          ],
        ),
      ),
    );
  }
}

class MarkrtRollOverDataScreen extends BaseScreen {
  final String type;
  final String sort;
  final bool isFullScreen;
  const MarkrtRollOverDataScreen(this.type, this.sort, this.isFullScreen,
      {super.key});

  @override
  State<MarkrtRollOverDataScreen> createState() =>
      _MarkrtRollOverDataScreenState();
}

class _MarkrtRollOverDataScreenState
    extends BaseAuthScreenState<MarkrtRollOverDataScreen> {
  @override
  void initState() {
    BlocProvider.of<RollOverBloc>(context)
      ..add(FetchRolloverRollOverEvent(widget.type, widget.sort))
      ..stream.listen((event) {
        if (event is RollOverSymStreamState) {
          subscribeLevel1(event.streamDetails);
        }
      });

    super.initState();
  }

  @override
  void quote1responseCallback(ResponseData data) {
    BlocProvider.of<RollOverBloc>(context)
        .add(FetchRolloverResponseEvent(data));
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.rollOverTabScreen +
        widget.sort +
        widget.isFullScreen.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RollOverBloc, RollOverState>(
      buildWhen: (previous, current) =>
          current is RollOverLoading ||
          current is RollOverError ||
          current is RollOverDone,
      builder: (context, state) {
        if (state is RollOverLoading) {
          return const LoaderWidget();
        }
        if (state is RollOverError) {
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
        } else if (state is RollOverDone) {
          return RefreshWidget(
            onRefresh: () {
              BlocProvider.of<RollOverBloc>(context)
                  .add(FetchRolloverRollOverEvent(widget.type, widget.sort));
            },
            child: WatchlistListWidget(
                onRowClicked: (symbolItem) async {
                  await pushNavigation(
                    ScreenRoutes.quoteScreen,
                    arguments: {
                      'symbolItem': symbolItem,
                    },
                  );
                },
                refreshWatchlist: () {
                  BlocProvider.of<RollOverBloc>(context).add(
                      FetchRolloverRollOverEvent(widget.type, widget.sort));
                },
                isScroll: widget.isFullScreen,
                limit: widget.isFullScreen ? null : 5,
                symbolList: state.rollOver?.symList,
                isRollOver: true),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
