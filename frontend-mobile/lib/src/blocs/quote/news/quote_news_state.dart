part of 'quote_news_bloc.dart';

abstract class QuoteNewsState extends ScreenState {}

class QuoteNewsInitial extends QuoteNewsState {}

class QuoteNewsDataState extends QuoteNewsState {
  QuoteNewsModel? quoteNewsModel;
  QuoteNewsDetailModel? quoteNewsDetailModel;
}

class QuoteNewsProgressState extends QuoteNewsState {}

class QuoteNewsChangeState extends QuoteNewsState {}

class QuoteNewsErrorState extends QuoteNewsState {}

class QuoteNewsFailedState extends QuoteNewsState {}

class QuoteNewsServiceExceptionState extends QuoteNewsState {}
