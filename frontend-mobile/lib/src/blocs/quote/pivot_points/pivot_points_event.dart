part of 'pivot_points_bloc.dart';

abstract class PivotPointsEvent {}

class QuotePivotPointsEvent extends PivotPointsEvent {
  late Sym? sym;
  late String time;
  QuotePivotPointsEvent(this.sym, this.time);
}
