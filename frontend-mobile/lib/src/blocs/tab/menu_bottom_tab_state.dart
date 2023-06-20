part of 'menu_bottom_tab_bloc.dart';

abstract class MenuBottomTabState extends ScreenState {}

class InitialState extends MenuBottomTabState {}

class UpdateTabState extends MenuBottomTabState {
  int tabIndex;
  UpdateTabState(this.tabIndex);
}

class LogoutDoneState extends MenuBottomTabState {
  final bool fullExit;
  final bool isFromMyAcc;

  LogoutDoneState(this.fullExit, this.isFromMyAcc);
}

class LogoutChangeState extends MenuBottomTabState {}

class LogoutErrorState extends MenuBottomTabState {}
