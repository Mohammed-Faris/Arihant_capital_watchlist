part of 'other_upi_bloc.dart';

abstract class OtherUPIEvent {}

class UpiCheckVPAEvent extends OtherUPIEvent {
  String paychannel = '';
  String vpa = '';
}

class UpiInitProcessEvent extends OtherUPIEvent {
  String paychannel = '';
  String vpa = '';
  String amount = '';
  List<String> accountnumberlist = [];
}

class UpiTransStatusEvent extends OtherUPIEvent {
  String transID = '';
}
