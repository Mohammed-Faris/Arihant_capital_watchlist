import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../data/repository/quote/quote_repository.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/sym_model.dart';
import '../../../models/quote/quote_analysis/volume_analysis_model.dart';
import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';

part 'quote_analysis_event.dart';
part 'quote_analysis_state.dart';

class QuoteAnalysisBloc
    extends BaseBloc<QuoteAnalysisEvent, QuoteAnalysisState> {
  QuoteAnalysisBloc() : super(QuoteAnalysisInitial());

  @override
  Future<void> eventHandlerMethod(
      QuoteAnalysisEvent event, Emitter<QuoteAnalysisState> emit) async {
    if (event is QuoteAnalysisVolumeAnalysis) {
      await _getVolumeAnalysis(event, emit);
    }
  }

  Future<void> _getVolumeAnalysis(QuoteAnalysisVolumeAnalysis event,
      Emitter<QuoteAnalysisState> emit) async {
    emit(QuoteAnalysisVolumeanalysisProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('type', event.consolidated ? 'C' : 'S');
      request.addToData('sym', event.sym);
      VolumeAnalysis volumeAnalysis =
          await QuoteRepository().getQuoteVolumeRequest(request);
      volumeAnalysis.chartdat = [
        ChartData(
            AppUtils().doubleValue("0"),
            AppUtils().doubleValue(volumeAnalysis.totVol ?? "0"),
            AppLocalizations().today,
            false),
        ChartData(
            AppUtils().doubleValue(volumeAnalysis.delVol ?? "0"),
            AppUtils().doubleValue(volumeAnalysis.totVolPrev ?? "0"),
            AppLocalizations().yesterday,
            false),
        ChartData(
            AppUtils().doubleValue(volumeAnalysis.delVol1wk ?? "0"),
            AppUtils().doubleValue(volumeAnalysis.totVol1wk ?? "0"),
            AppLocalizations().oneWeekAvg,
            false),
        ChartData(
            AppUtils().doubleValue(volumeAnalysis.delVol1M ?? "0"),
            AppUtils().doubleValue(volumeAnalysis.totVol1M ?? "0"),
            AppLocalizations().oneMonthAvg,
            false)
      ];
      emit(QuoteAnalysisVolumeAnalysisDoneState()
        ..volumeAnalysis = volumeAnalysis);
    } on ServiceException catch (ex) {
      emit(QuoteAnalysisServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuoteAnalysisFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  @override
  QuoteAnalysisState getErrorState() {
    return QuoteAnalysisErrorState();
  }
}
