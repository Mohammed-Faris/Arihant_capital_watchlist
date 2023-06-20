import '../common/base_bloc.dart';
import '../common/screen_state.dart';
import '../../constants/app_constants.dart';
import '../../data/repository/edis/edis_repository.dart';
import '../../models/common/message_model.dart';
import '../../models/edis/nsdl_ack_model.dart';
import '../../models/edis/order_details_model.dart';
import '../../models/edis/verify_edis_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

part 'edis_event.dart';
part 'edis_state.dart';

class EdisBloc extends BaseBloc<EdisEvent, EdisState> {
  EdisBloc() : super(EdisInitial());

  @override
  Future<void> eventHandlerMethod(
      EdisEvent event, Emitter<EdisState> emit) async {
    if (event is VerifyEdisEvent) {
      await _handleVerifyEdisEvent(event, emit);
    } else if (event is GenerateTpinEvent) {
      await _handleGenerateTpinEvent(event, emit);
    } else if (event is GetNsdlAcknowledgementEvent) {
      await _handleGetNsdlAcknowledgementEvent(event, emit);
    }
  }

  Future<void> _handleVerifyEdisEvent(
    VerifyEdisEvent event,
    Emitter<EdisState> emit,
  ) async {
    emit(EdisProgressState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('exc', AppConstants.nse);
      request.addToData('ordDetails', event.ordDetails);

      final VerifyEdisModel verifyEdisModel =
          await EdisRepository().verifyEdisRequest(request);
      emit(VerifyEdisDoneState()..verifyEdisModel = verifyEdisModel);
    } on ServiceException catch (ex) {
      emit(VerifyEdisServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(VerifyEdisFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleGenerateTpinEvent(
    GenerateTpinEvent event,
    Emitter<EdisState> emit,
  ) async {
    emit(EdisProgressState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('reqTime', event.reqTime);
      request.addToData('reqId', event.reqId);

      final MessageModel messageModel =
          await EdisRepository().generateTpinRequest(request);
      emit(GenerateTpinDoneState()..messageModel = messageModel.infoMsg);
    } on ServiceException catch (ex) {
      emit(GenerateTpinServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(GenerateTpinFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleGetNsdlAcknowledgementEvent(
    GetNsdlAcknowledgementEvent event,
    Emitter<EdisState> emit,
  ) async {
    emit(EdisProgressState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('reqId', event.reqId);

      final NsdlAckModel nsdlAckModel =
          await EdisRepository().getNsdlAckRequest(request);
      emit(NsdlAcknowledgementDoneState()..nsdlAckModel = nsdlAckModel);
    } on ServiceException catch (ex) {
      emit(NsdlAcknowledgementFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(NsdlAcknowledgementServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  @override
  EdisState getErrorState() {
    return EdisErrorState();
  }
}
