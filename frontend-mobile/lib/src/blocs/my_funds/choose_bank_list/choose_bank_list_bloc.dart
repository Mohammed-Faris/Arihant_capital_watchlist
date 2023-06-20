import '../../common/screen_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/my_funds/bank_details_model.dart';
import '../../common/base_bloc.dart';

part 'choose_bank_list_event.dart';
part 'choose_bank_list_state.dart';

class ChooseBankListBloc
    extends BaseBloc<ChooseBankListEvent, ChooseBankListState> {
  ChooseBankListBloc() : super(ChooseBankInitialState());

  DisplayandUpdateChooseBankListselectionState
      displayandUpdateChooseBankListselectionState =
      DisplayandUpdateChooseBankListselectionState();

  ChooseBankListLoadHelpState chooseBankListLoadHelpState =
      ChooseBankListLoadHelpState();

  NetBankListLoadHelpState netBankListLoadHelpState =
      NetBankListLoadHelpState();

  @override
  Future<void> eventHandlerMethod(
      ChooseBankListEvent event, Emitter<ChooseBankListState> emit) async {
    if (event is DispayBankDetailsandShowTickMarkEvent) {
      await _handleDispayBankDetailsandShowTickMarkEvent(event, emit);
    } else if (event is ChooseBankScreenPopEvent) {
      await _handleChooseBankScreenPopEvent(event, emit);
    } else if (event is ChooseBankListLoadHelpEvent) {
      await _handleChooseBankListLoadHelpEvent(event, emit);
    } else if (event is NetBankListLoadHelpEvent) {
      await _handleNetBankListLoadHelpEvent(event, emit);
    } else if (event is ChooseBankPaymentModeHelpEvent) {
      await _handleChooseBankPaymentModeHelpEvent(event, emit);
    }
  }

  Future<void> _handleChooseBankPaymentModeHelpEvent(
      ChooseBankPaymentModeHelpEvent event,
      Emitter<ChooseBankListState> emit) async {
    emit(ChooseBankPaymentModeChangedState());
    emit(ChooseBankPaymentModeDoneState()..indexvalue = event.indexvalue);
  }

  Future<void> _handleNetBankListLoadHelpEvent(
      NetBankListLoadHelpEvent event, Emitter<ChooseBankListState> emit) async {
    emit(NetBankListChangedState());
    emit(netBankListLoadHelpState..isexpanded = event.isexpanded);
  }

  Future<void> _handleChooseBankListLoadHelpEvent(
      ChooseBankListLoadHelpEvent event,
      Emitter<ChooseBankListState> emit) async {
    emit(ChooseBankListChangedState());
    emit(chooseBankListLoadHelpState..isexpanded = event.isexpanded);
  }

  Future<void> _handleChooseBankScreenPopEvent(
      ChooseBankScreenPopEvent event, Emitter<ChooseBankListState> emit) async {
    emit(ChooseBankListChangedState());
    emit(ChooseBankListsScreenPopState()
      ..bankDetailsModel =
          displayandUpdateChooseBankListselectionState.bankDetailsModel);
  }

  Future<void> _handleDispayBankDetailsandShowTickMarkEvent(
      DispayBankDetailsandShowTickMarkEvent event,
      Emitter<ChooseBankListState> emit) async {
    emit(ChooseBankListChangedState());
    List<Banks> banks = event.bankDetailsModel!.banks!;
    Map.fromIterable(banks, key: (item) => item.isBankChoosen = false);

    if (event.selectedRowIndex != -1) {
      banks[event.selectedRowIndex].isBankChoosen = true;
    }
    emit(displayandUpdateChooseBankListselectionState
      ..bankDetailsModel = event.bankDetailsModel
      ..resultDatalist = event.resultDataList);
  }

  @override
  ChooseBankListState getErrorState() {
    return ChooseBankListErroState();
  }
}
