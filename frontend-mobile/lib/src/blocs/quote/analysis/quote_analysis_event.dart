part of 'quote_analysis_bloc.dart';

abstract class QuoteAnalysisEvent {
  bool consolidated = true;
}

class QuoteAnalysisVolumeAnalysis extends QuoteAnalysisEvent {
  late Sym? sym;
  QuoteAnalysisVolumeAnalysis(this.sym);
}
