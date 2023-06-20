import '../../../data/repository/funds/funds_repository.dart';
import '../../../data/store/app_storage.dart';
import '../../../models/my_funds/my_fund_view_updated_model.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../data/cache/cache_repository.dart';
import '../../common/screen_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/base_bloc.dart';

part 'withdraw_cash_info_event.dart';
part 'withdraw_cash_info_state.dart';

class WithdrawCashInfoBloc
    extends BaseBloc<WithdrawCashInfoEvent, WithdrawCashInfoState> {
  WithdrawCashInfoBloc() : super(WithdrawCashInfoInitial());

  @override
  Future<void> eventHandlerMethod(
      WithdrawCashInfoEvent event, Emitter<WithdrawCashInfoState> emit) async {
    if (event is GetWithdrawCashEvent) {
      await _handleGetWithdrawCaseEvent(event, emit);
    } else if (event is GetWithdrawCashFundViewUpdatedEvent) {
      await _handleGetWithdrawCashFundViewUpdatedEvent(event, emit);
    }
  }

  Future<void> _handleGetWithdrawCashFundViewUpdatedEvent(
    GetWithdrawCashFundViewUpdatedEvent event,
    Emitter<WithdrawCashInfoState> emit,
  ) async {
    if (event.fundViewUpdatedModel != null) {
      emit(WithdrawCashFundViewDoneState()
        ..fundViewUpdatedModel = event.fundViewUpdatedModel);
    } else {
      emit(WithdrawCashInfoProgressState());
      try {
        final BaseRequest request = BaseRequest();
        request.addToData('segment', ['ALL']);
        final getFundViewUpdateModel =
            await CacheRepository.groupCache.get('fundViewUpdatedModel');

        late FundViewUpdatedModel fundViewUpdatedModel;

        if (getFundViewUpdateModel == null || event.fetchApi) {
          fundViewUpdatedModel =
              await FundsRepository().getFundViewUpdatedModel(request);
          AppStorage().setData('getFundViewUpdatedModel', fundViewUpdatedModel);
        } else {
          fundViewUpdatedModel = getFundViewUpdateModel;
        }
        emit(WithdrawCashInfoChangedState());
        emit(WithdrawCashFundViewDoneState()
          ..fundViewUpdatedModel = fundViewUpdatedModel);
      } on ServiceException catch (ex) {
        emit(WithdrawCashInfoErrorState()
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
        throw (ServiceException(ex.code, ex.msg));
      } on FailedException catch (ex) {
        emit(WithdrawCashInfoErrorState()
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
      }
    }
  }

  Future<void> _handleGetWithdrawCaseEvent(
    GetWithdrawCashEvent event,
    Emitter<WithdrawCashInfoState> emit,
  ) async {
    emit(WithdrawCashInfoChangedState());
    emit(WithdrawCashDoneState()..withdrawfund = event.withdrawcashdata);
  }

  @override
  WithdrawCashInfoErrorState getErrorState() {
    return WithdrawCashInfoErrorState();
  }
}
