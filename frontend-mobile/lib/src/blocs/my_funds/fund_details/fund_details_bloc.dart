import '../../../data/store/app_storage.dart';
import '../../../models/my_funds/my_fund_view_updated_model.dart';
import '../../../data/cache/cache_repository.dart';
import '../../common/screen_state.dart';
import '../../../data/repository/funds/funds_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../common/base_bloc.dart';

part 'fund_details_event.dart';
part 'fund_details_state.dart';

class FunddetailsBloc extends BaseBloc<FunddetailsEvent, FunddetailsState> {
  FunddetailsBloc() : super(FunddetailsInitial());

  @override
  Future<void> eventHandlerMethod(
      FunddetailsEvent event, Emitter<FunddetailsState> emit) async {
    if (event is GetFundDetailsEvent) {
      await _handleGetFundDetailsEvent(event, emit);
    } else if (event is LoadFundDetailsEvent) {
      await _handleLoadFundDetailsEvent(event, emit);
    }
  }

  Future<void> _handleLoadFundDetailsEvent(
    LoadFundDetailsEvent event,
    Emitter<FunddetailsState> emit,
  ) async {
    emit(FunddetailsChangedState());
    emit(FundsViewDataDoneState()..fundViewModel = event.fundViewModel);
  }

  Future<void> _handleGetFundDetailsEvent(
    GetFundDetailsEvent event,
    Emitter<FunddetailsState> emit,
  ) async {
    emit(FunddetailsProgressState());
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
      emit(FunddetailsChangedState());
      emit(FundsViewDataDoneState()..fundViewModel = fundViewUpdatedModel);
    } on ServiceException catch (ex) {
      emit(FunddetailsFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(FunddetailsErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  @override
  FunddetailsState getErrorState() {
    return FunddetailsErrorState();
  }
}
