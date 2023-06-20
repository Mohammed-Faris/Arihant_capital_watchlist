part of 'rollover_bloc.dart';

abstract class RollOverEvent {}

class FetchRolloverRollOverEvent extends RollOverEvent {
  FetchRolloverRollOverEvent(this.type, this.sortBy);
  final String type;
  final String sortBy;
}
class FetchRolloverResponseEvent extends RollOverEvent {
  ResponseData data;
  FetchRolloverResponseEvent(this.data);
}