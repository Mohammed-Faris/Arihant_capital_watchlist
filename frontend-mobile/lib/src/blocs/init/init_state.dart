part of 'init_bloc.dart';

abstract class InitState extends ScreenState {}

class InitNotStartedState extends InitState {}

class InitProgressState extends InitState {}

class InitFailedState extends InitState {}

class InitCompletedState extends InitState {
  InitCompletedState(this.userStatus, this.configModel);
  String userStatus;
  ConfigModel configModel;
}
