part of 'choose_bank_list_bloc.dart';

abstract class ChooseBankListEvent {}

class DispayBankDetailsandShowTickMarkEvent extends ChooseBankListEvent {
  BankDetailsModel? bankDetailsModel;
  List<Map<String, dynamic>>? resultDataList;
  int selectedRowIndex = 0;
  DispayBankDetailsandShowTickMarkEvent();
}

class ChooseBankListLoadHelpEvent extends ChooseBankListEvent {
  bool isexpanded = false;
}

class NetBankListLoadHelpEvent extends ChooseBankListEvent {
  bool isexpanded = false;
}

class ChooseBankPaymentModeHelpEvent extends ChooseBankListEvent {
  int indexvalue = 0;
}

class ChooseBankScreenPopEvent extends ChooseBankListEvent {}
