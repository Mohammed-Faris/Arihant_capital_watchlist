part of 'position_convertion_bloc.dart';

abstract class PositionConvertionEvent {}

class PostionConvertEvent extends PositionConvertionEvent {
  Positions positions;
  String qty;
  String toPrdType;
  PostionConvertEvent(this.positions, this.qty, this.toPrdType);
}
