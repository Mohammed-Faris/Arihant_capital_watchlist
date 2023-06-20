
part of 'rollover_bloc.dart';

abstract class RollOverState extends ScreenState {}

class RollOverLoading extends RollOverState {
 RollOverLoading();

}
class RollOverChange extends RollOverState {
 RollOverChange();

}
class RollOverSymStreamState extends RollOverState {
  Map<dynamic, dynamic> streamDetails;
  RollOverSymStreamState(this.streamDetails);
}

class RollOverDone extends RollOverState {
 RollOverDone();
 RollOverModel? rollOver;
}

class RollOverError extends RollOverState {
 RollOverError();

}

class RollOverInitial extends RollOverState {
 RollOverInitial();

}

