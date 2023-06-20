import 'dart:io';

import 'package:acml/src/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../../blocs/quote/chart/chart_bloc.dart';
import '../../../../constants/app_constants.dart';
import '../../../../constants/keys/quote_keys.dart';
import '../../../../data/store/app_store.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_color.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/chart_webview_widget.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../base/base_screen.dart';

class TradingViewChartArgs {
  final Symbols symbols;
  final Map<String, dynamic> symObj;
  final GlobalKey<ChartWebviewWidgetState> chartkey;

  TradingViewChartArgs(this.symbols, this.symObj, this.chartkey);
}

class TraddingViewChart extends BaseScreen {
  final TradingViewChartArgs chartArgs;
  const TraddingViewChart(this.chartArgs, {Key? key}) : super(key: key);

  @override
  State<TraddingViewChart> createState() => _TraddingViewChartState();
}

class _TraddingViewChartState extends BaseScreenState<TraddingViewChart> {
  late ChartBloc chartbloc;

  @override
  void initState() {
    symbols = widget.chartArgs.symbols;
    symObj = widget.chartArgs.symObj;
    chartbloc = BlocProvider.of<ChartBloc>(context)
      ..stream.listen(chartListener);
    chartbloc.add(ChartStartSymStreamEvent(symbols));
    super.initState();
  }

  Future<void> chartListener(ChartState state) async {
    if (state is ChartSymStreamState) {
      subscribeLevel1(state.streamDetails);
    }
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.tradingViewChart;
  }

  @override
  void quote1responseCallback(ResponseData data) {
    symbols.ltp = data.ltp ?? symbols.ltp;
    symbols.chng = data.chng ?? symbols.chng;
    symbols.chngPer = data.chngPer ?? symbols.chngPer;
    symbols.vol = data.vol ?? symbols.vol;
    data.vol = data.vol ?? symbols.vol;

    widget.chartArgs.chartkey.currentState?.chatIqWebCall(data);
    chartbloc.add(ChartStreamingResponseEvent(data));
  }

  late Map<String, dynamic> symObj;
  final ValueNotifier<bool> landscape = ValueNotifier<bool>(false);

  void setOrientation() {
    if (AppConfig.orientation != Orientation.landscape) {
      SystemChrome.setPreferredOrientations([
        Platform.isIOS
            ? DeviceOrientation.landscapeRight
            : DeviceOrientation.landscapeLeft,
      ]);
    } else {
      AppStore().setOrientations();
    }
  }

  late Symbols symbols;
  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  WillPopScope buildBody() {
    return WillPopScope(
        onWillPop: () {
          AppStore().setOrientations();

          popNavigation();
          return Future.delayed(const Duration(seconds: 0));
        },
        child: ValueListenableBuilder<bool>(
          valueListenable: landscape,
          builder: (context, value, _) {
            return Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  leadingWidth: 0,
                  elevation: 0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  title: appBar(context),
                ),
                resizeToAvoidBottomInset: false,
                body: SafeArea(
                  top: WidgetsBinding.instance.window.viewInsets.bottom == 0,
                  bottom: WidgetsBinding.instance.window.viewInsets.bottom == 0,
                  child: ChartWebviewWidget(
                    widget.chartArgs.chartkey,
                    ChartWebviewWidgetArguments(
                      symObj,
                      !landscape.value
                          ? AppConstants.portraitExpand
                          : AppConstants.landscape,
                    ),
                  ),
                ));
          },
        ));
  }

  Container appBar(BuildContext context) {
    return Container(
      width: AppWidgetSize.screenWidth(context),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      height: AppWidgetSize.dimen_50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            key: const Key(quoteBackChartIconKey),
            onTap: () async {
              AppStore().setOrientations();

              Navigator.of(context).pop();
              landscape.value = false;
            },
            child: AppImages.backButtonIcon(context,
                width: AppWidgetSize.dimen_25,
                height: AppWidgetSize.dimen_25,
                color: Theme.of(context).primaryIconTheme.color),
          ),
          _buildChartStreamingContent(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (AppUtils().getsymbolType(symbols) != AppConstants.indices)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _getBottomButtonWidget(
                        quoteBuyButtonKey,
                        AppConfig.orientation == Orientation.landscape
                            ? "Buy"
                            : "B",
                        AppColors().positiveColor,
                        true,
                      ),
                      SizedBox(width: AppWidgetSize.dimen_12),
                      _getBottomButtonWidget(
                        quoteSellButtonKey,
                        AppConfig.orientation == Orientation.landscape
                            ? "Sell"
                            : "S",
                        AppColors.negativeColor,
                        false,
                      ),
                    ],
                  ),
                SizedBox(
                  width: 10.w,
                ),
                SizedBox(
                  width: AppWidgetSize.dimen_30,
                  height: AppWidgetSize.dimen_30,
                  child: GestureDetector(
                    onTap: () async {
                      setOrientation();
                      landscape.value = !landscape.value;
                      if (Platform.isIOS) {
                        Future.delayed(const Duration(milliseconds: 10), () {
                          widget.chartArgs.chartkey.currentState?.controller
                              .reload();
                        });
                      }
                    },
                    child: AppImages.rotate(
                      context,
                      color: Theme.of(context).primaryIconTheme.color,
                      isColor: true,
                      width: AppWidgetSize.dimen_30,
                      height: AppWidgetSize.dimen_30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartStreamingContent() {
    return BlocBuilder<ChartBloc, ChartState>(
        buildWhen: (ChartState previous, ChartState current) {
      return current is ChartDataState;
    }, builder: (context, state) {
      if (state is ChartDataState) {
        return builtLtpContent(state.symbols!);
      }
      return Container();
    });
  }

  Widget builtLtpContent(Symbols symbol) {
    return Container(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
        bottom: AppWidgetSize.dimen_4,
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_20,
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: AppWidgetSize.dimen_18,
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
                top: AppWidgetSize.dimen_2,
                bottom: AppWidgetSize.dimen_5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomTextWidget(
                        AppUtils().dataNullCheck(symbol.ltp),
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
                          AppUtils().getChangePercentage(symbol),
                          Theme.of(context)
                              .primaryTextTheme
                              .bodySmall!
                              .copyWith(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onCallOrderPad(
    String action,
    Symbols symbolItem,
  ) async {
    if (landscape.value) {
      AppStore().setOrientations();
    }
    await pushNavigation(
      ScreenRoutes.orderPadScreen,
      arguments: {
        'action': action,
        'symbolItem': symbolItem,
      },
    );
    if (landscape.value) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
      ]);
    }
  }

  Widget _getBottomButtonWidget(
    String key,
    String header,
    Color color,
    bool isGradient,
  ) {
    return GestureDetector(
      key: Key(key),
      onTap: () async {
        unsubscribeLevel1();
        if (header == "B" || header == "Buy") {
          _onCallOrderPad(AppLocalizations().buy, symbols);
        } else {
          _onCallOrderPad(AppLocalizations().sell, symbols);
        }
      },
      child: Container(
        width: AppConfig.orientation == Orientation.landscape
            ? AppWidgetSize.dimen_60
            : AppWidgetSize.dimen_30,
        height: AppWidgetSize.dimen_30,
        decoration: isGradient
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20.w),
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
                borderRadius: BorderRadius.circular(AppWidgetSize.dimen_30),
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
}
