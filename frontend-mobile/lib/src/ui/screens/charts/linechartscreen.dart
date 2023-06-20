import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import '../../../blocs/linechart/historydata/bloc/history_data_bloc.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/keys/quote_keys.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/linechart/historydata.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/loader_widget.dart';
import '../base/base_screen.dart';

class LineChartScreen extends BaseScreen {
  const LineChartScreen(this.symbol, this.onExpand, {Key? key})
      : super(key: key);
  final Symbols symbol;

  final Function() onExpand;

  @override
  State<LineChartScreen> createState() => LineChartScreenState();
}

class LineChartScreenState extends BaseAuthScreenState<LineChartScreen> {
  var format = DateFormat('dd-MM-yyyy');
  List<HorizontalLine> _horiDashLine = [];
  @override
  void initState() {
    BlocProvider.of<LineChartBloc>(context)
      ..stream.listen((event) {
        if (event is LineChartError) {
          if (event.isInvalidException) {
            handleError(event);
          }
        }
      })
      ..add(HistoryDataFetchEvent(
          widget.symbol, AppUtils().periodList(widget.symbol)[0]));

    super.initState();
  }

  bool init = true;
  void chatIqWebCall(ResponseData quoteOverviewData) {
    if (data.isNotEmpty &&
        selectedIndex == 0 &&
        quoteOverviewData.ltp != null) {
      BlocProvider.of<LineChartBloc>(context).add(HistoryDataUpdatedEvent(
          DataPoints(
              open: quoteOverviewData.open ?? "0",
              high: quoteOverviewData.high ?? "0",
              low: quoteOverviewData.low ?? "0",
              close: quoteOverviewData.ltp ?? widget.symbol.ltp ?? "0",
              volume: quoteOverviewData.vol ?? "0",
              date: DateTime.now().toIso8601String())));
    }
  }

  List<DataPoints> data = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.symmetric(
          vertical: AppWidgetSize.dimen_20, horizontal: AppWidgetSize.dimen_5),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
          Widget>[
        Expanded(
            child: BlocBuilder<LineChartBloc, LineChartState>(
          buildWhen: (previous, current) =>
              current is LineChartDone ||
              (current is LineChartLoad && datapoints.isEmpty) ||
              current is LineChartError,
          builder: (context, state) {
            if (state is LineChartDone) {
              if (state.selectedIndex == 0) {
                firsTime = false;
                _horiDashLine = [
                  HorizontalLine(
                    y: AppUtils().doubleValue(widget.symbol.close),
                    strokeWidth: 1,
                    label: HorizontalLineLabel(
                        labelResolver: ((p0) =>
                            "\u{20B9} ${AppUtils().doubleValue(widget.symbol.close)}"),
                        show: false,
                        style:
                            const TextStyle(fontFamily: AppConstants.interFont),
                        alignment: Alignment.topRight),
                    color: Theme.of(context).iconTheme.color,
                    dashArray: [5, 5],
                  )
                ];
              } else {
                _horiDashLine = [];
              }
              data = [];
              data = state.dataPoints;

              datapoints.clear();
              for (int i = 0; i < data.length; i++) {
                datapoints.add(FlSpot(
                    i.toDouble(), AppUtils().doubleValue(data[i].close)));
              }
              if (datapoints.isEmpty) {
                return errorWithImageWidget(
                  context: context,
                  imageWidget: AppUtils().getNoDateImageErrorWidget(context),
                  errorMessage: AppLocalizations().noDataAvailableErrorMessage,
                  padding: EdgeInsets.only(
                    left: 30.w,
                    right: 30.w,
                    bottom: 30.w,
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.only(
                      top: 20.w,
                      left: AppWidgetSize.dimen_20,
                      bottom: 20.w,
                      right: state.selectedIndex == 0
                          ? AppWidgetSize.dimen_50
                          : 0),
                  child: chartData(),
                );
              }
            } else if (state is LineChartLoad) {
              return const LoaderWidget();
            } else if (state is LineChartError) {
              return errorWithImageWidget(
                context: context,
                imageWidget: AppUtils().getNoDateImageErrorWidget(context),
                errorMessage: AppLocalizations().noDataAvailableErrorMessage,
                padding: EdgeInsets.only(
                  left: 30.w,
                  right: 30.w,
                  bottom: 30.w,
                ),
              );
            }
            return Container();
          },
        )),
        dateSelection(),
      ]),
    ));
  }

  int selectedIndex = 0;
  Widget dateSelection() {
    return BlocBuilder<LineChartBloc, LineChartState>(
      builder: (context, state) {
        selectedIndex = state.selectedIndex;

        return Padding(
          padding: EdgeInsets.only(
            right: 20.w,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: EdgeInsets.only(left: 10.w),
                width: AppWidgetSize.screenWidth(context) * 0.8,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      AppUtils().periodList(widget.symbol).length,
                      (index) => InkWell(
                          onTap: () {
                            firsTime = true;
                            BlocProvider.of<LineChartBloc>(context).add(
                                HistoryDataFetchEvent(
                                    widget.symbol,
                                    AppUtils()
                                        .periodList(widget.symbol)[index]));
                          },
                          child: Container(
                            margin:
                                EdgeInsets.only(right: AppWidgetSize.dimen_15),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: index == state.selectedIndex
                                  ? Theme.of(context)
                                      .snackBarTheme
                                      .backgroundColor
                                  : null,
                              borderRadius: BorderRadius.circular(
                                AppWidgetSize.dimen_10,
                              ),
                            ),
                            child: _chartSelectionText(
                              AppUtils().periodList(widget.symbol)[index],
                              index == state.selectedIndex,
                            ),
                          )),
                    )),
              ),
              GestureDetector(
                key: const Key(quoteExpandChartIconKey),
                onTap: widget.onExpand,
                child: SizedBox(
                  child: AppImages.expandIcon(
                    context,
                    isColor: true,
                    color: Theme.of(context).primaryIconTheme.color,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool firsTime = true;
  Widget chartData() {
    return LineChart(
      mainData(),
      swapAnimationDuration: firsTime
          ? const Duration(milliseconds: 200)
          : const Duration(seconds: 0),
      swapAnimationCurve: Curves.linear,
    );
  }

  Widget _chartSelectionText(String text, bool isSelected) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: AppWidgetSize.fontSize16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  List<FlSpot> datapoints = [];
  LineChartData mainData() {
    return LineChartData(
      backgroundColor: Colors.transparent,
      gridData: griddata(),
      titlesData: tilesData(),
      borderData: borderData(),
      lineTouchData: linetouchData(),
      minX: datapoints.first.x,
      maxX: selectedIndex == 0
          ? getMaxXData()
          : (datapoints.last.x + datapoints.last.x * 0.10),
      minY: getMinYData(),
      maxY: getMaxYData(),
      extraLinesData: ExtraLinesData(
        horizontalLines: _horiDashLine,
      ),
      lineBarsData: lineBarsData,
    );
  }

  FlGridData griddata() {
    return FlGridData(
      show: false,
      drawVerticalLine: false,
      horizontalInterval: 1,
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: const Color(0xff37434d),
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: const Color(0xff37434d),
          strokeWidth: 1,
        );
      },
    );
  }

  FlBorderData borderData() {
    return FlBorderData(
      show: false,
      border: Border.all(color: const Color(0xff37434d), width: 1),
    );
  }

  FlTitlesData tilesData() {
    return FlTitlesData(
        show: false,
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)));
  }

  int currentspotindex = 0;
  bool showMarketChange = true;
  LineTouchData linetouchData() {
    return LineTouchData(
      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
        if ((event is FlLongPressMoveUpdate || event is FlPanUpdateEvent) &&
            currentspotindex != touchResponse?.lineBarSpots?.first.spotIndex &&
            touchResponse?.lineBarSpots != null) {
          HapticFeedback.lightImpact();
          showMarketChange = false;
          currentspotindex = touchResponse?.lineBarSpots?.first.spotIndex ?? 0;
        }
        if (event is FlPanEndEvent) {
          showMarketChange = true;
        }
      },
      getTouchedSpotIndicator:
          (LineChartBarData barData, List<int> indicators) {
        return indicators.map(
          (int index) {
            final line =
                FlLine(color: Colors.grey, strokeWidth: 1, dashArray: [5]);
            return TouchedSpotIndicatorData(
              line,
              FlDotData(show: true),
            );
          },
        ).toList();
      },
      enabled: true,
      touchTooltipData: toolTipData(),
    );
  }

  LineTouchTooltipData toolTipData() {
    return LineTouchTooltipData(
      fitInsideHorizontally: true,
      maxContentWidth: 400,
      fitInsideVertically: true,
      tooltipBgColor: Theme.of(context).colorScheme.background,
      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
        return touchedBarSpots.map((barSpot) {
          final flSpot = barSpot;
          var date = DateTime.parse(data[flSpot.x.toInt()].date);
          return LineTooltipItem(
            '\u{20B9} ${AppUtils().decimalValue(flSpot.y, decimalPoint: AppUtils().getDecimalpoint((widget.symbol.sym?.exc) ?? AppConstants.nse))} | ${DateFormat(AppUtils().periodList(widget.symbol)[selectedIndex] == "1D" ? 'hh:mm a' : AppUtils().periodList(widget.symbol)[selectedIndex] == "1W" ? 'dd-MMM hh:mm a' : 'dd-MMM-yyyy ').format(date)}',
            Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                  fontSize: 12,
                  fontFamily: AppConstants.interFont,
                ),
          );
        }).toList();
      },
    );
  }

  Color getChartColor() {
    return (AppUtils().periodList(widget.symbol)[selectedIndex] == "1D"
            ? (AppUtils().doubleValue(widget.symbol.ltp ?? "0") >
                AppUtils().doubleValue(widget.symbol.close ?? "0"))
            : datapoints.last.y > datapoints.first.y)
        ? Theme.of(context).primaryColor
        : AppColors.negativeColor;
  }

  List<LineChartBarData> get lineBarsData {
    return [
      LineChartBarData(
        color: getChartColor(),
        spots: datapoints,
        isCurved: true,
        preventCurveOvershootingThreshold: 10,
        lineChartStepData: LineChartStepData(),
        barWidth: 2,
        isStepLineChart: false,
        isStrokeCapRound: true,
        isStrokeJoinRound: true,
        preventCurveOverShooting: true,
        dotData: FlDotData(
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
                radius: showMarketChange ? (Random().nextDouble() * 1) + 2 : 2,
                color: getChartColor(),
                strokeWidth:
                    showMarketChange ? (Random().nextDouble() * 2) + 5 : 5,
                strokeColor: getChartColor().withOpacity(0.2));
          },
          checkToShowDot: (spot, barData) =>
              (selectedIndex == 0 && barData.spots.last == spot) ? true : false,
        ),
      ),
    ];
  }

  double getMinYData() {
    double x = datapoints.first.y;
    for (var data in datapoints) {
      {
        if (data.y < x) {
          x = data.y;
        }
      }
    }
    return (AppUtils().doubleValue(widget.symbol.close) < x - 1 &&
            selectedIndex == 0)
        ? AppUtils().doubleValue(widget.symbol.close) -
            (AppUtils().doubleValue(widget.symbol.close) * 0.01)
        : x - (x * 0.01);
  }

  double getMaxXData() {
    double minutesMarket = 210;

    try {
      String symbolType = AppUtils().getsymbolType(widget.symbol);

      if (AppConfig.chartTimingv2 != null) {
        DateTime startTime = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            AppUtils().intValue(AppConfig.chartTimingv2
                ?.toJson()[symbolType]["oneDayTmng"]
                .toString()
                .substring(0, 2)),
            AppUtils().intValue(AppConfig.chartTimingv2
                ?.toJson()[symbolType]["oneDayTmng"]
                .toString()
                .substring(3, 5)));
        DateTime endTime = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            AppUtils().intValue(AppConfig.chartTimingv2
                ?.toJson()[symbolType]["oneDayTmng"]
                .toString()
                .substring(6, 8)),
            AppUtils().intValue(AppConfig.chartTimingv2
                ?.toJson()[symbolType]["oneDayTmng"]
                .toString()
                .substring(9, 11)));

        minutesMarket = endTime.difference(startTime).inMinutes.toDouble();
        minutesMarket = (minutesMarket / 2);
      }
    } catch (e) {
      return minutesMarket > datapoints.last.x
          ? minutesMarket
          : datapoints.last.x;
    }

    return minutesMarket > datapoints.last.x
        ? minutesMarket
        : datapoints.last.x;
  }

  double getMaxYData() {
    double x = datapoints.first.y;
    for (var data in datapoints) {
      {
        if (data.y > x) {
          x = data.y;
        }
      }
    }
    return (AppUtils().doubleValue(widget.symbol.close) > x + 1 &&
            selectedIndex == 0)
        ? AppUtils().doubleValue(widget.symbol.close) +
            (AppUtils().doubleValue(widget.symbol.close) * 0.01)
        : x + (x * 0.01);
  }
}
