part of 'position_convertion_bloc.dart';

abstract class PositionConvertionState extends ScreenState {}

class PositionConvertionInitial extends PositionConvertionState {}

class PositionConvertionProgressState extends PositionConvertionState {}

class PositionConvertionDataState extends PositionConvertionState {
  BaseModel baseModel;
  PositionConvertionDataState(this.baseModel);
}

class PositionConvertionFailedState extends PositionConvertionState {}

class PositionConvertionServiceExceptionState extends PositionConvertionState {}

class PositionConvertionErrorState extends PositionConvertionState {}
