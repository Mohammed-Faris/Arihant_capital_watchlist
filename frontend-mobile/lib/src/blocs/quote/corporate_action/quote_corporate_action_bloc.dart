import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';
import '../../../data/repository/quote/quote_repository.dart';
import '../../../models/common/sym_model.dart';
import '../../../models/quote/corporate_action/quote_corporate_action_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';
import '../../../models/quote/corporate_action/data_points_service.dart';
part 'quote_corporate_action_event.dart';
part 'quote_corporate_action_state.dart';

class QuoteCorporateActionBloc
    extends BaseBloc<QuoteCorporateActionEvent, QuoteCorporateActionState> {
  QuoteCorporateActionBloc() : super(QuoteCorporateActionInitial());

  QuoteCorporateActionDataState quoteCorporateActionDataState =
      QuoteCorporateActionDataState();
  DataPointsService service = DataPointsService();

  @override
  Future<void> eventHandlerMethod(QuoteCorporateActionEvent event,
      Emitter<QuoteCorporateActionState> emit) async {
    if (event is FetchQuoteCorporateActionEvent) {
      await _handleFetchQuoteCorporateActionEvent(event, emit);
    }
  }

  Future<void> _handleFetchQuoteCorporateActionEvent(
    FetchQuoteCorporateActionEvent event,
    Emitter<QuoteCorporateActionState> emit,
  ) async {
    emit(QuoteCorporateActionProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('sym', event.sym);

      final QuoteCorporateActionModel quoteCorporateActionModel =
          await QuoteRepository().getCorporateActionRequest(request);
      quoteCorporateActionDataState.quoteCorporateActionModel =
          quoteCorporateActionModel;
      quoteCorporateActionModel.dividend!.dataPoints.dataPoints.sort((a, b) =>
          DateFormat('dd-MM-yyyy')
              .parse(service.getProperties(b, 'divDate'))
              .compareTo(DateFormat('dd-MM-yyyy')
                  .parse(service.getProperties(a, 'divDate'))));
      quoteCorporateActionModel.bonus!.dataPoints.dataPoints.sort((a, b) =>
          DateFormat('dd-MM-yyyy')
              .parse(service.getProperties(b, 'bonusDte'))
              .compareTo(DateFormat('dd-MM-yyyy')
                  .parse(service.getProperties(a, 'bonusDte'))));
      quoteCorporateActionModel.rights!.dataPoints.dataPoints.sort((a, b) =>
          DateFormat('dd-MM-yyyy')
              .parse(service.getProperties(b, 'rightDte'))
              .compareTo(DateFormat('dd-MM-yyyy')
                  .parse(service.getProperties(a, 'rightDte'))));
      quoteCorporateActionModel.splits!.dataPoints.dataPoints.sort((a, b) =>
          DateFormat('dd-MM-yyyy')
              .parse(service.getProperties(b, 'spltDte'))
              .compareTo(DateFormat('dd-MM-yyyy')
                  .parse(service.getProperties(a, 'spltDte'))));
      emit(QuoteCorporateActionChangeState());
      emit(quoteCorporateActionDataState);
    } on ServiceException catch (ex) {
      emit(QuoteCorporateActionServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuoteCorporateActionFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  @override
  QuoteCorporateActionState getErrorState() {
    return QuoteCorporateActionErrorState();
  }
}
