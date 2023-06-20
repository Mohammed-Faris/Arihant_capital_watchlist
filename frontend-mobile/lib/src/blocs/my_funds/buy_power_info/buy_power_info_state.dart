part of 'buy_power_info_bloc.dart';

abstract class BuyPowerInfoState extends ScreenState {}

class BuyPowerInfoInitial extends BuyPowerInfoState {}

class BuyPowerInfoProgressState extends BuyPowerInfoState {}

class BuyPowerInfoChangedState extends BuyPowerInfoState {}

class BuyPowerInfoFailedState extends BuyPowerInfoState {
  BuyPowerInfoFailedState();
}

class BuyPowerInfoErrorState extends BuyPowerInfoState {}

class AvailableFundsDoneState extends BuyPowerInfoState {
  FundViewUpdatedModel? fundViewUpdatedModel;
}
