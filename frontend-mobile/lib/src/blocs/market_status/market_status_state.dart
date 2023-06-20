part of 'market_status_bloc.dart';

abstract class MarketStatusState extends ScreenState {}

class MarketStatusInitial extends MarketStatusState {}

class MarketStatusDoneState extends MarketStatusState {
  bool isOpen = false;
  bool isAmo = false;
}

class MarketStatusProgressState extends MarketStatusState {}

class MarketStatusServiceExpectionState extends MarketStatusState {}

class MarketStatusFailedState extends MarketStatusState {}

class MarketStatusErrorState extends MarketStatusState {}
