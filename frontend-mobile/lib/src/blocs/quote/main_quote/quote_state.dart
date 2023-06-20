part of 'quote_bloc.dart';

abstract class QuoteState extends ScreenState {}

class QuoteInitial extends QuoteState {}

class QuoteSymbolItemState extends QuoteState {
  Symbols? symbols;

  QuoteSymbolItemState();
}

class QuoteChangeState extends QuoteState {}

class QuoteSymStreamState extends QuoteState {
  final Map<dynamic, dynamic> streamDetails;
  QuoteSymStreamState(this.streamDetails);
}

class QuoteErrorState extends QuoteState {}

class QuoteProgressState extends QuoteState {}

class QuoteAddSymbolFailedState extends QuoteState {}

class QuoteAddDoneState extends QuoteState {
  String messageModel;
  QuoteAddDoneState(this.messageModel);
}

class QuotedeleteDoneState extends QuoteState {
  String messageModel;
  QuotedeleteDoneState(this.messageModel);
}

class QuotedeleteSymbolFailedState extends QuoteState {}

class QuoteExcChangeState extends QuoteState {
  Symbols symbolItem;
  QuoteExcChangeState(this.symbolItem);
}

class QuoteExcChangeFailedState extends QuoteState {}

class QuoteSectorDataState extends QuoteState {
  String sectorName;
  QuoteSectorDataState(this.sectorName);
}

class QuoteSectorFailedState extends QuoteState {}
