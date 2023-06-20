import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';
import '../../../data/repository/my_funds/my_funds_repository.dart';
import '../../../models/my_funds/check_upi_vpa_model.dart';
import '../../../models/my_funds/upi_init_process_model.dart';
import '../../../models/my_funds/upi_transaction_status_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

part 'other_upi_event.dart';
part 'other_upi_state.dart';

class OtherUPIBloc extends BaseBloc<OtherUPIEvent, OtherUPIState> {
  OtherUPIBloc() : super(OtherUPIInitialState());

  OtherUPIinitProcessDoneState otherUPIinitProcessDoneState =
      OtherUPIinitProcessDoneState();

  OtherUPITransStatusDoneState otherUPITransStatusDoneState =
      OtherUPITransStatusDoneState();

  @override
  Future<void> eventHandlerMethod(
      OtherUPIEvent event, Emitter<OtherUPIState> emit) async {
    if (event is UpiCheckVPAEvent) {
      await _handleUpiCheckVPAEvent(event, emit);
    } else if (event is UpiInitProcessEvent) {
      await _handleUpiInitProcessEvent(event, emit);
    } else if (event is UpiTransStatusEvent) {
      await _handleUpiTransStatusEvent(event, emit);
    }
  }

  Future<void> _handleUpiCheckVPAEvent(
      UpiCheckVPAEvent event, Emitter<OtherUPIState> emit) async {
    emit(OtherUPIProgressState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('payChannel', event.paychannel.replaceAll(",", ""));
      request.addToData('vpa', event.vpa.replaceAll(" ", ""));

      CheckUPIVPAModel checkUPIVPAModel =
          await MyFundsRepository().checkVpa(request);

      emit(OtherUPIChangedState());
      emit(OtherUPIVerifyVPADoneState()..checkUPIVPAModel = checkUPIVPAModel);
    } on ServiceException catch (ex) {
      emit(OtherUPIFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(OtherUPIErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleUpiInitProcessEvent(
      UpiInitProcessEvent event, Emitter<OtherUPIState> emit) async {
    emit(OtherUPIProgressState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('payChannel', event.paychannel.replaceAll(",", ""));
      request.addToData('vpa', event.vpa.replaceAll(" ", ""));
      request.addToData('amount', event.amount.replaceAll(" ", ""));
      request.addToData('accountNumbers', event.accountnumberlist);
      request.addToData('remark', "To Arihant");

      UPIInitProcessModel upiinitModel =
          await MyFundsRepository().getUpiInitprocess(request);

      emit(OtherUPIChangedState());
      emit(otherUPIinitProcessDoneState..upiInitProcessModel = upiinitModel);
    } on ServiceException catch (ex) {
      emit(OtherUPIFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(OtherUPIErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleUpiTransStatusEvent(
      UpiTransStatusEvent event, Emitter<OtherUPIState> emit) async {
    emit(OtherUPIProgressState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('transID', event.transID.replaceAll(",", ""));

      UPITransactionStatusModel upiTransactionStatusModel =
          await MyFundsRepository().getUpiTransStatus(request);

      emit(OtherUPIChangedState());
      emit(otherUPITransStatusDoneState
        ..upiTransactionStatusModel = upiTransactionStatusModel);
    } on ServiceException catch (ex) {
      emit(OtherUPIFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(OtherUPIErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  @override
  OtherUPIState getErrorState() {
    return OtherUPIErrorState();
  }
}
