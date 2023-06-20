import '../../../data/store/app_store.dart';
import 'widgets/tradeviewchart.dart';
import '../../../blocs/quote/main_quote/quote_bloc.dart';
import '../../../data/store/app_helper.dart';
import '../../../models/common/symbols_model.dart';
import '../../navigation/screen_routes.dart';
import '../base/base_screen.dart';
import '../../widgets/chart_webview_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/streamer/models/streaming_symbol_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../blocs/linechart/historydata/bloc/history_data_bloc.dart';
import '../charts/linechartscreen.dart';

class QuoteChartArgs {
  final Symbols symbol;

  QuoteChartArgs(this.symbol);
}

class QuoteChart extends BaseScreen {
  final QuoteChartArgs quotechartargs;
  const QuoteChart(
    this.quotechartargs, {
    Key? key,
  }) : super(key: key);

  @override
  QuoteChartState createState() => QuoteChartState();
}

class QuoteChartState extends BaseAuthScreenState<QuoteChart> {
  GlobalKey<ChartWebviewWidgetState> chartWebViewGlobalKey =
      GlobalKey<ChartWebviewWidgetState>();
  GlobalKey<LineChartScreenState> chartWebViewGlobalKey2 =
      GlobalKey<LineChartScreenState>();
  late Symbols symbols;
  late Map<String, dynamic> symObj;
  late QuoteBloc quoteBloc;

  @override
  void initState() {
    symbols = widget.quotechartargs.symbol;
    symbols.sym!.baseSym = symbols.baseSym;
    symObj = symbols.sym!.toJson();
    symObj['precision'] = 2;
    symObj['baseSym'] = symbols.baseSym;
    symObj['dispSymbol'] = symbols.dispSym;
    symObj['excToken'] = symbols.excToken;
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.quoteChart);
  }

  @override
  void screenFocusIn() {
    callStream();
    super.screenFocusIn();
  }

  void callStream() {
    final List<StreamingSymbolModel> symbols = <StreamingSymbolModel>[];
    final StreamingSymbolModel symbol = StreamingSymbolModel.fromJson(
        <String, String>{'symbol': symObj['streamSym']});
    symbols.add(symbol);

    subscribeLevel1(AppHelper().streamDetails(symbols, []));
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.quoteChart;
  }

  @override
  void quote1responseCallback(ResponseData data) {
    symbols.ltp = data.ltp ?? symbols.ltp;
    symbols.chng = data.chng ?? symbols.chng;
    symbols.close = symbols.close ?? data.close;
    symbols.high = data.high ?? symbols.high;
    symbols.low = data.low ?? symbols.low;
    symbols.chngPer = data.chngPer ?? symbols.chngPer;
    chartWebViewGlobalKey2.currentState?.chatIqWebCall(data);
  }

  WebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: BlocProvider(
          create: (context) => LineChartBloc(LineChartInitial()),
          child: LineChartScreen(
            symbols,
            () async {
              unsubscribeLevel1();
              await pushNavigation(ScreenRoutes.tradingViewChart,
                  arguments: TradingViewChartArgs(
                      symbols, symObj, chartWebViewGlobalKey));
              callStream();
            },
            key: chartWebViewGlobalKey2,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    AppStore().setOrientations();
    super.dispose();
  }
}
