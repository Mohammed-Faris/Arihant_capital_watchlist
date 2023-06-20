import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../../constants/app_constants.dart';
import '../../../../data/repository/quote/quote_repository.dart';
import '../../../../data/store/app_helper.dart';
import '../../../../models/common/sym_model.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../../models/quote/quote_financials/quote_financials_view_more/quote_financials_share_holidings_data.dart';
import '../../../../models/quote/quote_financials/quote_financials_view_more/quote_financials_share_holidings_model.dart';
import '../../../../models/quote/quote_financials/quote_financials_view_more/quote_quarterly_income_statements.dart';
import '../../../../models/quote/quote_financials/quote_financials_view_more/quote_yearly_income_statement.dart';
import '../../../common/base_bloc.dart';
import '../../../common/screen_state.dart';

part 'financials_view_more_event.dart';
part 'financials_view_more_state.dart';

class FinancialsViewMoreBloc
    extends BaseBloc<FinancialsViewMoreEvent, FinancialsViewMoreState> {
  FinancialsViewMoreBloc() : super(FinancialsViewMoreInitial());

  FinancialsDataState financialsDataState = FinancialsDataState();

  @override
  Future<void> eventHandlerMethod(
    FinancialsViewMoreEvent event,
    Emitter<FinancialsViewMoreState> emit,
  ) async {
    if (event is ViewMoreShareHoldingEvent) {
      await _getQuotesFinancialShareHoldingRevenueEvent(
        event,
        emit,
        event.quoteFinancialsShareHoldingsData,
      );
    } else if (event is ViewMoreIncomeQuarterlyStatementHoldingEvent) {
      await _getQuarterlyIncomeStatementsEvent(event, emit);
    } else if (event is ViewMoreIncomeYearlyStatementHoldingEvent) {
      await _getYearlyIncomeStatementsEvent(event, emit);
    } else if (event is QuoteFinancialsStartSymStreamEvent) {
      await sendStream(emit, event.symbolItem);
    } else if (event is QuoteFinancialsStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    }
  }

  Future<void> sendStream(
    Emitter<FinancialsViewMoreState> emit,
    Symbols symbolItem,
  ) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer,
    ];

    List<Symbols> symbols = [];

    symbols.add(symbolItem);

    financialsDataState.symbols = symbols[0];

    emit(financialsDataState);

    emit(
      FinancialsSymStreamState(
        AppHelper().streamDetails(symbols, streamingKeys),
      ),
    );
  }

  Future<void> responseCallback(
    ResponseData streamData,
    Emitter<FinancialsViewMoreState> emit,
  ) async {
    final String symbolName = streamData.symbol!;
    final Symbols symbol = financialsDataState.symbols!;
    if (symbol.sym!.streamSym == symbolName) {
      symbol.ltp = streamData.ltp ?? symbol.ltp;
      symbol.chng = streamData.chng ?? symbol.chng;
      symbol.chngPer = streamData.chngPer ?? symbol.chngPer;
    }
    financialsDataState.symbols = symbol;
    emit(FinancialsChangeState());

    emit(financialsDataState);
  }

  Future<void> _getQuotesFinancialShareHoldingRevenueEvent(
    ViewMoreShareHoldingEvent event,
    Emitter<FinancialsViewMoreState> emit,
    QuoteFinancialsShareHoldingsData quoteFinancialsShareHoldingsData,
  ) async {
    emit(FinancialsViewMoreProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('type', event.consolidated ? 'C' : 'S');
      request.addToData('sym', quoteFinancialsShareHoldingsData.sym);
      final FinancialsShareHoldings financialsShareHoldings =
          await QuoteRepository().getQuoteShareHoldingRequest(request);

      emit(FinancialsShareHoldingsDoneState()
        ..financialsShareHoldings = financialsShareHoldings);
    } on ServiceException catch (ex) {
      emit(FinancialsServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(FinancialsViewMoreErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _getQuarterlyIncomeStatementsEvent(
      ViewMoreIncomeQuarterlyStatementHoldingEvent event,
      Emitter<FinancialsViewMoreState> emit) async {
    emit(FinancialsViewMoreProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('type', event.consolidated ? 'C' : 'S');
      request.addToData('sym', event.sym);
      final QuarterlyIncomeStatement quarterlyIncomeStatement =
          await QuoteRepository()
              .getQuoteQuarterlyIncomeStatementRequest(request);

      emit(FinancialsQuarterlyIncomeStatementDoneState()
        ..quarterlyIncomeStatement = quarterlyIncomeStatement);
    } on ServiceException catch (ex) {
      emit(FinancialsServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(FinancialsViewMoreFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _getYearlyIncomeStatementsEvent(
      ViewMoreIncomeYearlyStatementHoldingEvent event,
      Emitter<FinancialsViewMoreState> emit) async {
    emit(FinancialsViewMoreProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('type', event.consolidated ? 'C' : 'S');
      request.addToData('sym', event.sym);
      final YearlyIncomeStatement yearlyIncomeStatement =
          await QuoteRepository().getQuoteYearlyIncomeStatementRequest(request);

      emit(FinancialsYearlyIncomeStatementDoneState()
        ..yearlyIncomeStatement = yearlyIncomeStatement);
    } on ServiceException catch (ex) {
      emit(FinancialsServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(FinancialsViewMoreFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  @override
  FinancialsViewMoreState getErrorState() {
    return FinancialsViewMoreErrorState();
  }
}
