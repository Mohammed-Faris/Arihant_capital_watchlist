part of 'menu_bottom_tab_bloc.dart';

abstract class MenuBottomTabEvent {}

class ChangeTabEvent extends MenuBottomTabEvent {
  int tabIndex;
  ChangeTabEvent({required this.tabIndex});
}

class LogoutEvent extends MenuBottomTabEvent {
  bool exittoLogin;
  bool isFromMyaccount;
  LogoutEvent(this.exittoLogin, this.isFromMyaccount);
}
