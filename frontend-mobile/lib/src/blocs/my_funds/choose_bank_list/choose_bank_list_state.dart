part of 'choose_bank_list_bloc.dart';

abstract class ChooseBankListState extends ScreenState {}

class ChooseBankInitialState extends ChooseBankListState {}

class ChooseBankListChangedState extends ChooseBankListState {}

class NetBankListChangedState extends ChooseBankListState {}

class ChooseBankPaymentModeChangedState extends ChooseBankListState {}

class ChooseBankPaymentModeDoneState extends ChooseBankListState {
  int indexvalue = 0;
}

class ChooseBankListLoadHelpState extends ChooseBankListState {
  bool isexpanded = false;
}

class NetBankListLoadHelpState extends ChooseBankListState {
  bool isexpanded = false;
}

class DisplayandUpdateChooseBankListselectionState extends ChooseBankListState {
  BankDetailsModel? bankDetailsModel;
  List<Map<String, dynamic>>? resultDatalist;
}

class ChooseBankListsScreenPopState extends ChooseBankListState {
  BankDetailsModel? bankDetailsModel;
}

class ChooseBankListErroState extends ChooseBankListState {}
