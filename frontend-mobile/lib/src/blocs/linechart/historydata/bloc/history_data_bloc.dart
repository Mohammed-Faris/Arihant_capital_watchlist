import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../../config/app_config.dart';
import '../../../../data/repository/linechart/linechart_repository.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../../models/linechart/historydata.dart';
import '../../../common/base_bloc.dart';
import '../../../common/screen_state.dart';

part 'history_data_event.dart';
part 'history_data_state.dart';

class LineChartBloc extends BaseBloc<LineChartEvent, LineChartState> {
  LineChartBloc(LineChartState initialState) : super(initialState);
  LineChartDone linechartDone = LineChartDone();
  @override
  Future<void> eventHandlerMethod(
      LineChartEvent event, Emitter<LineChartState> emit) async {
    if (event is HistoryDataFetchEvent) {
      await _historyDataFetchEvent(event, emit);
    } else if (event is HistoryDataUpdatedEvent) {
      await _historyDataUpdatevent(event, emit);
    }
  }

  @override
  LineChartState getErrorState() {
    return LineChartError();
  }

  _historyDataFetchEvent(
      HistoryDataFetchEvent event, Emitter<LineChartState> emit) async {
    emit(LineChartLoad()
      ..selectedIndex =
          AppUtils().periodList(event.symbol).indexOf(event.period));
    try {
      String startdate = DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .toIso8601String();
      if (event.period == "1W") {
        startdate =
            DateTime.now().subtract(const Duration(days: 10)).toIso8601String();
      } else if (event.period == "1Y") {
        startdate = DateTime.now()
            .subtract(const Duration(days: 365))
            .toIso8601String();
      } else if (event.period == "1M") {
        startdate =
            DateTime.now().subtract(const Duration(days: 50)).toIso8601String();
      } else if (event.period == "3M") {
        startdate = DateTime.now()
            .subtract(const Duration(days: 100))
            .toIso8601String();
      } else if (event.period == "3Y") {
        startdate = DateTime.now()
            .subtract(const Duration(days: 1095))
            .toIso8601String();
      } else if (event.period == "5Y") {
        startdate = DateTime.now()
            .subtract(const Duration(days: 1825))
            .toIso8601String();
      }
      DateTime endDate = DateTime.now();
      final BaseRequest request = BaseRequest();
      request.addToData("endDate", endDate.toIso8601String());
      request.addToData("sym", event.symbol.sym!.toJson());
      request.addToData("baseSym", event.symbol.baseSym);
      request.addToData("interval", "1day");
      request.addToData("startDate", startdate);

      HistoryData historyData = event.period == "1W" || event.period == "1D"
          ? await LineChartRepository().getIntradayData(request)
          : await LineChartRepository().getHistoryData(request);

      int divisbleBy = state.selectedIndex == 0
          ? 2
          : state.selectedIndex == 1
              ? 5
              : state.selectedIndex == 2
                  ? 0
                  : state.selectedIndex == 3
                      ? 0
                      : state.selectedIndex == 4
                          ? 2
                          : state.selectedIndex == 5
                              ? 6
                              : 6;
      List<DataPoints> dataPoints = [];
      if (divisbleBy > 0) {
        for (int i = 0; i < historyData.dataPoints.length; i++) {
          if (i % divisbleBy == 0) {
            dataPoints.add(historyData.dataPoints[i]);
          }
        }
      } else {
        dataPoints = historyData.dataPoints;
      }
      oneWeekandOneDayChartDataPointsBasedonTimings(event, endDate, dataPoints);

      emit(linechartDone
        ..startDate = DateTime.parse(startdate)
        ..endDate = endDate
        ..dataPoints = dataPoints
        ..selectedIndex =
            AppUtils().periodList(event.symbol).indexOf(event.period));
    } on ServiceException catch (ex) {
      emit(LineChartError()
        ..selectedIndex =
            AppUtils().periodList(event.symbol).indexOf(event.period)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(LineChartError()
        ..selectedIndex =
            AppUtils().periodList(event.symbol).indexOf(event.period)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  void oneWeekandOneDayChartDataPointsBasedonTimings(
      HistoryDataFetchEvent event,
      DateTime endDate,
      List<DataPoints> dataPoints) {
    try {
      String symbolType = AppUtils().getsymbolType(event.symbol);

      if (AppConfig.chartTimingv2 != null && event.period == "1W") {
        DateTime startTime = DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
            AppUtils().intValue(AppConfig.chartTimingv2
                ?.toJson()[symbolType]["oneWeekTmng"]
                .toString()
                .substring(0, 2)),
            AppUtils().intValue(AppConfig.chartTimingv2
                ?.toJson()[symbolType]["oneWeekTmng"]
                .toString()
                .substring(3, 5)));
        DateTime endTime = DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
            AppUtils().intValue(AppConfig.chartTimingv2
                ?.toJson()[symbolType]["oneWeekTmng"]
                .toString()
                .substring(6, 8)),
            AppUtils().intValue(AppConfig.chartTimingv2
                ?.toJson()[symbolType]["oneWeekTmng"]
                .toString()
                .substring(9, 11)));
        dataPoints.removeWhere((e) {
          return ((!isBetween(
              DateTime(endDate.year, endDate.month, endDate.day,
                  DateTime.parse(e.date).hour, DateTime.parse(e.date).minute),
              startTime,
              endTime)));
        });
      }
      if (AppConfig.chartTimingv2 != null && event.period == "1D") {
        DateTime startTime = DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
            AppUtils().intValue(AppConfig.chartTimingv2
                ?.toJson()[symbolType]["oneDayTmng"]
                .toString()
                .substring(0, 2)),
            AppUtils().intValue(AppConfig.chartTimingv2
                ?.toJson()[symbolType]["oneDayTmng"]
                .toString()
                .substring(3, 5)));
        DateTime endTime = DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
            AppUtils().intValue(AppConfig.chartTimingv2
                ?.toJson()[symbolType]["oneDayTmng"]
                .toString()
                .substring(6, 8)),
            AppUtils().intValue(AppConfig.chartTimingv2
                ?.toJson()[symbolType]["oneDayTmng"]
                .toString()
                .substring(9, 11)));
        dataPoints.removeWhere((e) {
          return ((!isBetween(
              DateTime(endDate.year, endDate.month, endDate.day,
                  DateTime.parse(e.date).hour, DateTime.parse(e.date).minute),
              startTime,
              endTime)));
        });
      }
    } catch (e) {
      debugPrint("LineChart Error $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        null,
        fatal: false,
      );
    }
  }

  _historyDataUpdatevent(
      HistoryDataUpdatedEvent event, Emitter<LineChartState> emit) {
    emit(LineChartLoad());
    if (DateTime.parse(event.dataPoint.date)
            .difference(DateTime.parse(linechartDone.dataPoints.last.date))
            .inSeconds <
        60) {
      linechartDone.dataPoints.removeLast();
      linechartDone.dataPoints.add(event.dataPoint);
    } else {
      linechartDone.dataPoints.add(event.dataPoint);
    }

    emit(linechartDone);
  }

  bool isBetween(
    DateTime compareTime,
    DateTime fromDateTime,
    DateTime toDateTime,
  ) {
    final isAfter = compareTime.isAfter(fromDateTime);
    final isSameMomentTo = compareTime.isAtSameMomentAs(toDateTime);
    final isSameMomentFrom = compareTime.isAtSameMomentAs(fromDateTime);

    final isBefore = compareTime.isBefore(toDateTime);
    return (isAfter || isSameMomentFrom) && (isBefore || isSameMomentTo);
  }
}
