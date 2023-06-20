import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../data/repository/quote/quote_repository.dart';
import '../../../models/common/sym_model.dart';
import '../../../models/quote/quote_analysis/technical_model.dart';
import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';

part 'technical_event.dart';
part 'technical_state.dart';

class TechnicalBloc extends BaseBloc<TechnicalEvent, TechnicalState> {
  TechnicalBloc() : super(TechnicalInitial());

  @override
  Future<void> eventHandlerMethod(
      TechnicalEvent event, Emitter<TechnicalState> emit) async {
    if (event is QuoteTechnicalEvent) {
      await _getTechnicalAnalysis(event, emit);
    }
  }

  Future<void> _getTechnicalAnalysis(
      QuoteTechnicalEvent event, Emitter<TechnicalState> emit) async {
    emit(QuoteTechnicalProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('type', event.consolidated ? 'C' : 'S');
      request.addToData('sym', event.sym);
      Technical technical =
          await QuoteRepository().getQuoteTechnicalAnalysisRequest(request);

      emit(QuoteTechnicalDoneState()..technical = technical);
    } on ServiceException catch (ex) {
      emit(QuoteTechnicalServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuotetechnicalFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  @override
  TechnicalState getErrorState() {
    return QuoteTechnicalErrorState();
  }
}
