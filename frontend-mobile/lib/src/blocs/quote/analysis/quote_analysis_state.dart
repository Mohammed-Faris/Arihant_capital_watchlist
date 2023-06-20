part of 'quote_analysis_bloc.dart';

abstract class QuoteAnalysisState extends ScreenState {}

class QuoteAnalysisInitial extends QuoteAnalysisState {}

class QuoteAnalysisVolumeanalysisProgressState extends QuoteAnalysisState {}

class QuoteAnalysisVolumeAnalysisDoneState extends QuoteAnalysisState {
  late VolumeAnalysis volumeAnalysis;
}

class QuoteAnalysisFailedState extends QuoteAnalysisState {}

class QuoteAnalysisServiceExceptionState extends QuoteAnalysisState {}

class QuoteAnalysisErrorState extends QuoteAnalysisState {}
