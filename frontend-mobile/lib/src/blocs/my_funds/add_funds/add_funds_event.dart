// ignore_for_file: non_constant_identifier_names

part of 'add_funds_bloc.dart';

abstract class AddfundsEvent {}

class AddfundsEventFetchEvent extends AddfundsEvent {}

class GetFundsViewEvent extends AddfundsEvent {
  final bool fetchApi;

  GetFundsViewEvent({this.fetchApi = false});
}

class GetFundsViewUpdatedEvent extends AddfundsEvent {
  final bool fetchApi;

  GetFundsViewUpdatedEvent({this.fetchApi = false});
}

class GetTransactionStatusEvent extends AddfundsEvent {
  String transactionID = '';
}

class ShowPrefixIconEvent extends AddfundsEvent {
  bool isShow = false;
}

class UpdateAmountEvent extends AddfundsEvent {
  final int amount_entered;
  final int amount_already_present;
  UpdateAmountEvent(this.amount_entered, this.amount_already_present);
}

class GetBankDetailsEvent extends AddfundsEvent {}

class GetPaymentOptionEvent extends AddfundsEvent {
  final BankDetailsModel bankDetailsModel;
  GetPaymentOptionEvent(this.bankDetailsModel);
}

class AddfundsUpdatedBankdetailsEvent extends AddfundsEvent {
  BankDetailsModel? bankDetailsModel;
}

class AddfundsfetchUPIDataEvent extends AddfundsEvent {
  String url = '';
  String payChannel = '';
  String amount = '';
  List<String> accountnumberlist = [];
}

class AddfundsfetchNetBankingDataEvent extends AddfundsEvent {
  String url = '';
  String payChannel = '';
  String clientAccNo = '';
  String bankName = '';
  String amount = '';
}

class AddfundsFailedEvent extends AddfundsEvent {}

class AddfundsErrorEvent extends AddfundsEvent {}
