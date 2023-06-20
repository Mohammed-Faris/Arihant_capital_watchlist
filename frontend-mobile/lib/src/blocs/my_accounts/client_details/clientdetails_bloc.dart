import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../config/app_config.dart';
import '../../../data/cache/cache_repository.dart';
import '../../../data/repository/funds/funds_repository.dart';
import '../../../data/repository/my_account/my_account_repository.dart';
import '../../../data/store/app_store.dart';
import '../../../localization/app_localization.dart';
import '../../../models/my_account/client_details.dart';
import '../../../models/my_funds/my_funds_view_model.dart';
import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';

part 'clientdetails_event.dart';
part 'clientdetails_state.dart';

class ClientdetailsBloc
    extends BaseBloc<ClientdetailsEvent, ClientdetailsState> {
  ClientdetailsBloc() : super(ClientdetailsInitial());

  ClientdetailsDoneState clientdetailsDoneState = ClientdetailsDoneState();

  @override
  Future<void> eventHandlerMethod(
      ClientdetailsEvent event, Emitter<ClientdetailsState> emit) async {
    if (event is ClientdetailsFetchEvent) {
      await handelFetchEvent(event, emit);
    } else if (event is GetFundsViewEvent) {
      await _handleGetFundsViewEvent(event, emit);
    }
  }

  @override
  ClientdetailsState getErrorState() {
    return ClientdetailsErrorState();
  }

  Future<void> _handleGetFundsViewEvent(
    GetFundsViewEvent event,
    Emitter<ClientdetailsState> emit,
  ) async {
    try {
      final BaseRequest request = BaseRequest();

      FundViewModel fundViewModel =
          await FundsRepository().getFundViewModel(request);
      emit(ClientdetailsProgressState());
      emit(BuyPowerDoneState()..fundviewModel = fundViewModel);
    } on ServiceException catch (ex) {
      emit(ClientdetailsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(ClientdetailsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> handelFetchEvent(
      ClientdetailsFetchEvent event, Emitter<ClientdetailsState> emit) async {
    {
      if (event.load) {
        emit(ClientdetailsProgressState());
      }
      try {
        final clientCacheModel =
            await CacheRepository.groupCache.get('getClientDetails');
        emit(ClientdetailsDoneState()..clientDetails = clientCacheModel);
        if (clientCacheModel == null || event.fetchApi) {
          final ClientDetails clientDetails =
              await MyAccountRepository().getClientDetails();
          emit(clientdetailsDoneState..clientDetails = clientDetails);
          if (!Featureflag.isCheckSegmentsFromBo) {
            try {
              AppStore().setFnoAvailability(clientdetailsDoneState
                  .clientDetails!.clientDtls.first.exc
                  .contains(AppLocalizations().fando));
              AppStore().setCurrencyAvailablity(clientdetailsDoneState
                  .clientDetails!.clientDtls.first.exc
                  .contains(AppLocalizations().currency));
              AppStore().setCommodityAvailablity(clientdetailsDoneState
                  .clientDetails!.clientDtls.first.exc
                  .contains(AppLocalizations().commodity));
            } catch (e) {
              AppStore().setCommodityAvailablity(false);

              AppStore().setFnoAvailability(false);
              AppStore().setCurrencyAvailablity(false);
            }
          }
        }
      } on ServiceException catch (ex) {
        emit(ClientdetailsFailedState(ex.code, ex.msg)
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
        throw (ServiceException(ex.code, ex.msg));
      } on FailedException catch (ex) {
        emit(ClientdetailsFailedState(ex.code, ex.msg)
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
      } catch (e) {
        emit(ClientdetailsFailedState("", e.toString()));
      }
    }
  }
}
