part of 'buy_power_info_bloc.dart';

abstract class BuyPowerInfoEvent {}

class GetAvailableFundsEvent extends BuyPowerInfoEvent {
  FundViewUpdatedModel? fundViewUpdatedModel;
}
