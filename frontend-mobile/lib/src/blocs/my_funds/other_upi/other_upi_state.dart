part of 'other_upi_bloc.dart';

abstract class OtherUPIState extends ScreenState {}

class OtherUPIInitialState extends OtherUPIState {}

class OtherUPIProgressState extends OtherUPIState {}

class OtherUPIChangedState extends OtherUPIState {}

class OtherUPIVerifyVPADoneState extends OtherUPIState {
  CheckUPIVPAModel? checkUPIVPAModel;
}

class OtherUPIinitProcessDoneState extends OtherUPIState {
  UPIInitProcessModel? upiInitProcessModel;
}

class OtherUPITransStatusDoneState extends OtherUPIState {
  UPITransactionStatusModel? upiTransactionStatusModel;
}

class OtherUPIFailedState extends OtherUPIState {}

class OtherUPIErrorState extends OtherUPIState {}
