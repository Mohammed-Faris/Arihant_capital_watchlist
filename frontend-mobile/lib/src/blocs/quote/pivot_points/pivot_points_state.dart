part of 'pivot_points_bloc.dart';

abstract class PivotPointsState extends ScreenState {}

class PivotPointsInitial extends PivotPointsState {}

class QuotePivotpointsProgressState extends PivotPointsState {}

class QuotePivotPointsDoneState extends PivotPointsState {
  late PivotPoints pivotPoints;
}

class QuotePivotPointsFailedState extends PivotPointsState {}

class QuotePivotPointsServiceExceptionState extends PivotPointsState {}

class QuotePivotPointsErrorState extends PivotPointsState {}
