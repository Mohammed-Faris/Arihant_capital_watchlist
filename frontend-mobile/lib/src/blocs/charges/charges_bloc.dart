import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import '../../data/repository/order_pad/order_pad_repository.dart';
import '../../models/charges/charges.dart';
import '../common/base_bloc.dart';
import '../common/screen_state.dart';

part 'charges_event.dart';
part 'charges_state.dart';

class ChargesBloc extends BaseBloc<ChargesEvent, ChargesState> {
  ChargesBloc(ChargesState initialState) : super(initialState);

  @override
  ChargesState getErrorState() {
    return ChargesFailedState();
  }

  @override
  Future<void> eventHandlerMethod(
      ChargesEvent event, Emitter<ChargesState> emit) async {
    if (event is FetchChargesEvent) {
      await fetchChargesEvent(event, emit);
    }
  }

  fetchChargesEvent(FetchChargesEvent event, Emitter<ChargesState> emit) async {
    emit(ChargesProgressState());
    try {
      final BaseRequest request = BaseRequest(data: event.data);
      ChargesModel chargesModel =
          await OrderPadRepository().chargesRequest(request);
      emit(ChargesDoneState(chargesModel));
    } on FailedException catch (ex) {
      emit(ChargesFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }
}
