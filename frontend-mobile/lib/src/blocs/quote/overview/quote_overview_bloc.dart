import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/quote2_stream_response_model.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../constants/app_constants.dart';
import '../../../data/repository/quote/quote_repository.dart';
import '../../../data/store/app_calculator.dart';
import '../../../data/store/app_helper.dart';
import '../../../data/store/app_utils.dart';
import '../../../models/common/sym_model.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/quote/quote_company_model.dart';
import '../../../models/quote/quote_fundamentals/quote_financials_ratios.dart';
import '../../../models/quote/quote_fundamentals/quote_key_stats.dart';
import '../../../models/quote/quote_peer_model.dart';
import '../../../models/quote/quote_performance/quote_contract_info.dart';
import '../../../models/quote/quote_performance/quote_delivery_data.dart';
import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';

part 'quote_overview_event.dart';
part 'quote_overview_state.dart';

class QuoteOverviewBloc
    extends BaseBloc<QuoteOverviewEvent, QuoteOverviewState> {
  QuoteOverviewBloc() : super(QuoteOverviewInitial());

  QuoteOverviewDataState quoteOverviewDataState = QuoteOverviewDataState();

  QuoteOverviewGetCompanyDataState quoteOverviewGetCompanyDataState =
      QuoteOverviewGetCompanyDataState();

  QuoteFundamentalsDoneState quoteFundamentalsDoneState =
      QuoteFundamentalsDoneState();

  bool isHoldingsAvailable = false;

  @override
  Future<void> eventHandlerMethod(
      QuoteOverviewEvent event, Emitter<QuoteOverviewState> emit) async {
    if (event is QuoteOverviewStartSymStreamEvent) {
      isHoldingsAvailable = event.isHoldingsAvailable;
      await sendStream(emit, event.symbolItem);
    } else if (event is QuoteOverviewStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is QuoteOverviewGetCompanyDetailsEvent) {
      await _handleQuoteOverviewGetCompanyDetailsEvent(event, emit);
    } else if (event is QuoteGetPerformanceContractInfoEvent) {
      await _handleQuoteGetPerformanceContractInfoEvent(event, emit);
    } else if (event is QuoteGetPerformanceDeliveryDataEvent) {
      await _handleQuoteGetPerformanceDeliveryDataEvent(event, emit);
    } else if (event is QuoteGetFundamentalsKeyStatsEvent) {
      await _handleQuoteGetFundamentalsKeyStatsEvent(event, emit);
    } else if (event is QuoteGetFundamentalsFinancialRatiosEvent) {
      await _handleQuoteGetFundamentalsFinancialRatiosEvent(event, emit);
    }
  }

  Future<void> _handleQuoteOverviewGetCompanyDetailsEvent(
    QuoteOverviewGetCompanyDetailsEvent event,
    Emitter<QuoteOverviewState> emit,
  ) async {
    emit(QuoteOverviewChangeState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('sym', event.sym);

      final QuoteCompanyModel quoteCompanyModel =
          await QuoteRepository().getQuoteCompanyRequest(request);
      quoteOverviewGetCompanyDataState.quoteCompanyModel = quoteCompanyModel;

      emit(quoteOverviewGetCompanyDataState);
    } on ServiceException catch (ex) {
      emit(QuoteOverviewGetCompanyServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuoteOverviewGetCompanyFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleQuoteGetPerformanceContractInfoEvent(
    QuoteGetPerformanceContractInfoEvent event,
    Emitter<QuoteOverviewState> emit,
  ) async {
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('sym', event.sym);
      request.addToData('baseSym', event.sym.baseSym);

      final QuoteContractInfo quoteContractInfo =
          await QuoteRepository().getContractInfoRequest(request);
      quoteOverviewDataState.quoteContractInfo = quoteContractInfo;
      emit(QuoteOverviewChangeState());

      emit(quoteOverviewDataState);
    } on ServiceException catch (ex) {
      emit(QuoteOverviewServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuoteOverviewFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleQuoteGetPerformanceDeliveryDataEvent(
    QuoteGetPerformanceDeliveryDataEvent event,
    Emitter<QuoteOverviewState> emit,
  ) async {
    emit(QuotePerformanceProgressState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('sym', event.sym);

      final QuoteDeliveryData quoteDeliveryData =
          await QuoteRepository().getDeliveryDataRequest(request);
      quoteOverviewDataState.quoteDeliveryData = quoteDeliveryData;
      emit(QuoteOverviewChangeState());

      emit(quoteOverviewDataState);
    } on ServiceException catch (ex) {
      emit(QuoteOverviewServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuoteOverviewFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleQuoteGetFundamentalsKeyStatsEvent(
    QuoteGetFundamentalsKeyStatsEvent event,
    Emitter<QuoteOverviewState> emit,
  ) async {
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('sym', event.sym);
      request.addToData('type', event.consolidated ? 'C' : 'S');

      final QuoteKeyStats quoteKeyStats =
          await QuoteRepository().getKeyStatsRequest(request);
      quoteFundamentalsDoneState.quoteKeyStats = quoteKeyStats;
      emit(QuoteOverviewChangeState());

      emit(quoteFundamentalsDoneState);
    } on ServiceException catch (ex) {
      emit(QuoteOverviewServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuoteOverviewFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleQuoteGetFundamentalsFinancialRatiosEvent(
    QuoteGetFundamentalsFinancialRatiosEvent event,
    Emitter<QuoteOverviewState> emit,
  ) async {
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('sym', event.sym);
      request.addToData('type', event.consolidated ? 'C' : 'S');

      final QuoteFinancialsRatios quoteFinancialsRatios =
          await QuoteRepository().getFinancialsRatiosRequest(request);
      quoteFundamentalsDoneState.quoteFinancialsRatios = quoteFinancialsRatios;
      emit(QuoteOverviewChangeState());

      emit(quoteFundamentalsDoneState);
    } on ServiceException catch (ex) {
      emit(QuoteOverviewServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuoteOverviewFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> sendStream(
      Emitter<QuoteOverviewState> emit, Symbols symbolItem) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingHigh,
      AppConstants.streamingLow,
      AppConstants.streamingVol,
      AppConstants.streamingAtp,
      AppConstants.streamingOpen,
      AppConstants.streamingClose,
      AppConstants.streamingLowerCircuit,
      AppConstants.streamingUpperCircuit,
      AppConstants.streamingOi,
    ];

    List<Symbols> symbols = [];

    symbols.add(symbolItem);

    quoteOverviewDataState.symbols = symbols[0];

    emit(quoteOverviewDataState);

    emit(
      QuoteOverviewSymStreamState(
        AppHelper().streamDetails(symbols, streamingKeys),
      ),
    );
  }

  Future<void> responseCallback(
    ResponseData streamData,
    Emitter<QuoteOverviewState> emit,
  ) async {
    final String symbolName = streamData.symbol!;
    final Symbols symbol = quoteOverviewDataState.symbols!;
    if (symbol.sym!.streamSym == symbolName) {
      // debugPrint("${symbol.dispSym}- LCL ${symbol.lcl} UCL ${symbol.ucl}");

      symbol.high = streamData.high ?? symbol.high;
      symbol.low = streamData.low ?? symbol.low;
      symbol.vol = streamData.vol ?? symbol.vol;
      symbol.atp = streamData.atp ?? symbol.atp;
      symbol.open = streamData.open ?? symbol.open;
      symbol.close = streamData.close ?? symbol.close;
      symbol.lcl = streamData.lcl ?? symbol.lcl;
      symbol.ucl = streamData.ucl ?? symbol.ucl;
      symbol.yhigh = streamData.yHigh ?? symbol.yhigh;
      symbol.ylow = streamData.yLow ?? symbol.ylow;
      symbol.openInterest = streamData.oI ?? symbol.openInterest;
      if (isHoldingsAvailable) {
        symbol.dayspnl = ACMCalci.holdingOnedayPnl(symbol);
        symbol.porfolioPercent =
            _calculateProfolioPercent(symbol, symbol.totalInvested);
        symbol.overallReturn = ACMCalci.holdingOverallPnl(symbol);
      }
    }
    quoteOverviewDataState.symbols = symbol;

    emit(QuoteOverviewChangeState());

    emit(quoteOverviewDataState);
  }

  String getTotalBidQtyPercent(Quote2Data quoteDepthData) {
    double totalBidQtyPercent =
        (AppUtils().doubleValue(quoteDepthData.totBuyQty) /
                (AppUtils().doubleValue(quoteDepthData.totBuyQty) +
                    AppUtils().doubleValue(quoteDepthData.totSellQty))) *
            100;
    return totalBidQtyPercent.isNaN
        ? '0'
        : totalBidQtyPercent.toStringAsFixed(2);
  }

  String getTotalAskQtyPercent(Quote2Data quoteDepthData) {
    double totalAskQtyPercent =
        (AppUtils().doubleValue(quoteDepthData.totSellQty) /
                (AppUtils().doubleValue(quoteDepthData.totBuyQty) +
                    AppUtils().doubleValue(quoteDepthData.totSellQty))) *
            100;
    return totalAskQtyPercent.isNaN
        ? '0'
        : totalAskQtyPercent.toStringAsFixed(2);
  }

  List<String> calculateBidQtyPercent(Quote2Data quoteDepthData) {
    List<String> qtyList = [];
    for (var element in quoteDepthData.bid) {
      qtyList.add(getBidQtyPercent(element.qty, quoteDepthData.totBuyQty));
    }
    return qtyList;
  }

  List<String> calculateAskQtyPercent(Quote2Data quoteDepthData) {
    List<String> qtyList = [];
    for (var element in quoteDepthData.ask) {
      qtyList.add(getAskQtyPercent(element.qty, quoteDepthData.totSellQty));
    }
    return qtyList;
  }

  String getBidQtyPercent(String qty, String totBuyQty) {
    double bidQtyPercent =
        (AppUtils().doubleValue(qty) / AppUtils().doubleValue(totBuyQty)) * 100;
    return bidQtyPercent.toStringAsFixed(2);
  }

  String getAskQtyPercent(String qty, String totSellQty) {
    double askQtyPercent =
        (AppUtils().doubleValue(qty) / AppUtils().doubleValue(totSellQty)) *
            100;
    return askQtyPercent.toStringAsFixed(2);
  }

  String _calculateProfolioPercent(Symbols holdings, String? totalInvested) {
    final double calculatedvalue = AppUtils().doubleValue(holdings.invested) /
        AppUtils().doubleValue(totalInvested) *
        100;

    return AppUtils().commaFmt(
      AppUtils().decimalValue(AppUtils().isValueNAN(calculatedvalue),
          decimalPoint: AppUtils().getDecimalpoint(holdings.sym!.exc!)),
    );
  }

  String? getAvgPrice(Symbols holdings) {
    if (holdings.isPrevClose != null) {
      return holdings.isPrevClose!
          ? holdings.close.toString()
          : holdings.avgPrice;
    }
    return holdings.avgPrice;
  }

  @override
  QuoteOverviewState getErrorState() {
    return QuoteOverviewErrorState();
  }
}
