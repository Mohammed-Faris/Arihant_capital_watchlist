part of 'quote_peer_bloc.dart';

abstract class QuotePeerState extends ScreenState {}

class QuotePeerInitial extends QuotePeerState {}

class QuotePeerRatiosDataState extends QuotePeerState {
  QuotePeerModel? quotePeerModel;
  List<Symbols>? quotePeerModelmain;
}

class QuotePeerProgressState extends QuotePeerState {}

class QuotePeerRatiosChangeState extends QuotePeerState {}

class QuotePeerRatiosErrorState extends QuotePeerState {}

class QuotePeerRatiosFailedState extends QuotePeerState {}

class QuotePeerRatiosServiceExceptionState extends QuotePeerState {}

class QuotePeerSymStreamState extends QuotePeerState {
  final Map<dynamic, dynamic> streamDetails;
  QuotePeerSymStreamState(this.streamDetails);
}
