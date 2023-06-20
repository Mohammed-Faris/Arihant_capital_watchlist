import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../data/repository/quote/quote_repository.dart';
import '../../../data/store/app_utils.dart';
import '../../../models/common/sym_model.dart';
import '../../../models/quote/quote_financials/financials_data.dart';
import '../../../models/quote/quote_financials/financials_model.dart';
import '../../../models/quote/quote_financials/financials_yearly_model.dart';
import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';

part 'financials_event.dart';
part 'financials_state.dart';

class QuoteFinancialsBloc
    extends BaseBloc<QuoteFinancialsEvent, QuoteFinancialsState> {
  QuoteFinancialsBloc() : super(FinancialsInitial());

  @override
  Future<void> eventHandlerMethod(
      QuoteFinancialsEvent event, Emitter<QuoteFinancialsState> emit) async {
    if (event is QuoteToggleRevenueEvent) {
      await _toggleQuoteRevenue(emit);
    } else if (event is QuoteToggleProfitEvent) {
      await _toggleQuoteProfit(emit);
    } else if (event is QuoteToggleProfitEvent) {
      await _toggleQuoteNetWorth(emit);
    } else if (event is QuoteFinancialsRevenueEvent) {
      await _getQuotesFinancialRevenueEvent(
          event, emit, event.financialsData, event.quarterly);
    } else if (event is QuoteFinancialsProfitEvent) {
      await _getQuotesFinancialProfitEvent(
          event, emit, event.financialsData, event.quarterly);
    } else if (event is QuoteRevenueYearlyEvent) {
      await _getQuotesYearlyRevenueEvent(event, emit);
    } else if (event is QuoteProfitYearlyEvent) {
      await _getQuotesYearlyProfitEvent(event, emit);
    }
  }

  Future<void> _toggleQuoteRevenue(Emitter<QuoteFinancialsState> emit) async =>
      emit(FinancialsRevenueToggleState()..financialsRevenue = true);

  Future<void> _toggleQuoteProfit(Emitter<QuoteFinancialsState> emit) async =>
      emit(FinancialsProfitToggleState()..financialsProfit = true);

  Future<void> _toggleQuoteNetWorth(Emitter<QuoteFinancialsState> emit) async =>
      emit(FinancialsNetWorthToggleState()..financialsNetWorth = true);

  Future<void> _getQuotesFinancialRevenueEvent(
      QuoteFinancialsRevenueEvent event,
      Emitter<QuoteFinancialsState> emit,
      FinancialsData financialsData,
      bool isQuarterly) async {
    emit(FinancialsProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('type', event.consolidated ? 'C' : 'S');
      request.addToData('sym', financialsData.sym);
      final FinancialsModel financialsModel;
      financialsModel =
          await QuoteRepository().getQuoteFinancialQuarterRequest(request);

      financialsModel.financials
          ?.sort((a, b) => a.yrc!.compareTo(b.yrc.toString()));
      double positivePeak =
          AppUtils().doubleValue(financialsModel.financials?.reduce((a, b) {
        if (AppUtils().doubleValue(a.ttlIncome) >
            AppUtils().doubleValue(b.ttlIncome)) {
          return a;
        } else {
          return b;
        }
      }).ttlIncome);
      double negativePeakValue = (AppUtils().doubleValue((financialsModel
                  .financials
                  ?.where((element) =>
                      AppUtils().doubleValue(element.ttlIncome).isNegative)
                  .toList()
                  .isEmpty ??
              true)
          ? "0"
          : (AppUtils().doubleValue(financialsModel.financials
              ?.where((element) =>
                  AppUtils().doubleValue(element.ttlIncome).isNegative)
              .toList()
              .reduce((a, b) {
              if (AppUtils().doubleValue(a.ttlIncome).abs() >
                  AppUtils().doubleValue(b.ttlIncome).abs()) {
                return a;
              } else {
                return b;
              }
            }).ttlIncome))));
      emit(FinancialsRevenueDoneState()
        ..financialsModel = financialsModel
        ..positivePeak = positivePeak
        ..negativePeak = negativePeakValue.abs());
    } on ServiceException catch (ex) {
      emit(FinancialsServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(FinancialsErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _getQuotesFinancialProfitEvent(
      QuoteFinancialsProfitEvent event,
      Emitter<QuoteFinancialsState> emit,
      FinancialsData financialsData,
      bool isQuarterly) async {
    emit(FinancialsProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('type', event.consolidated ? 'C' : 'S');
      request.addToData('sym', financialsData.sym);
      final FinancialsModel financialsModel;
      financialsModel =
          await QuoteRepository().getQuoteFinancialQuarterRequest(request);

      financialsModel.financials
          ?.sort((a, b) => a.yrc.toString().compareTo(b.yrc.toString()));

      emit(FinancialsProfitDoneState()
        ..financialsModel = financialsModel
        ..positivePeak = AppUtils().doubleValue(
            AppUtils().doubleValue(financialsModel.financials?.reduce((a, b) {
          if (AppUtils().doubleValue(a.netproftLoss) >
              AppUtils().doubleValue(b.netproftLoss)) {
            return a;
          } else {
            return b;
          }
        }).netproftLoss))
        ..negativePeak = (AppUtils().doubleValue((financialsModel.financials
                        ?.where((element) => AppUtils()
                            .doubleValue(element.netproftLoss)
                            .isNegative)
                        .toList()
                        .isEmpty ??
                    true)
                ? "0"
                : AppUtils().doubleValue(AppUtils().doubleValue(financialsModel
                    .financials
                    ?.where((element) =>
                        AppUtils().doubleValue(element.netproftLoss).isNegative)
                    .toList()
                    .reduce((a, b) {
                    if (AppUtils().doubleValue(a.netproftLoss).abs() >
                        AppUtils().doubleValue(b.netproftLoss).abs()) {
                      return a;
                    } else {
                      return b;
                    }
                  }).netproftLoss))))
            .abs());
    } on ServiceException catch (ex) {
      emit(FinancialsServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(FinancialsErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _getQuotesYearlyRevenueEvent(
      QuoteRevenueYearlyEvent event, Emitter<QuoteFinancialsState> emit) async {
    emit(FinancialsProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('type', event.consolidated ? 'C' : 'S');
      request.addToData('sym', event.sym);
      final FinancialsYearly financialsYearly;
      financialsYearly =
          await QuoteRepository().getQuoteFinancialYearlyRequest(request);

      financialsYearly.yrc = financialsYearly.yrc?.reversed.toList();
      financialsYearly.values?.revenue =
          financialsYearly.values?.revenue?.reversed.toList();

      emit(FinancialsYearlyRevenueDoneState()
        ..financialsYearly = financialsYearly
        ..positivePeak = AppUtils()
            .doubleValue(financialsYearly.values!.revenue!.reduce((a, b) {
          if (AppUtils().doubleValue(a) > AppUtils().doubleValue(b)) {
            return a;
          } else {
            return b;
          }
        }))
        ..negativePeak = (AppUtils().doubleValue((financialsYearly
                    .values!.revenue!
                    .where(
                        (element) => AppUtils().doubleValue(element).isNegative)
                    .toList()
                    .isEmpty)
                ? "0"
                : financialsYearly.values!.revenue!
                    .where(
                        (element) => AppUtils().doubleValue(element).isNegative)
                    .toList()
                    .reduce((a, b) {
                    if (AppUtils().doubleValue(a).abs() >
                        AppUtils().doubleValue(b).abs()) {
                      return a;
                    } else {
                      return b;
                    }
                  })))
            .abs());
    } on ServiceException catch (ex) {
      emit(FinancialsServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(FinancialsErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _getQuotesYearlyProfitEvent(
      QuoteProfitYearlyEvent event, Emitter<QuoteFinancialsState> emit) async {
    emit(FinancialsProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('type', event.consolidated ? 'C' : 'S');
      request.addToData('sym', event.sym);
      final FinancialsYearly financialsYearly;
      financialsYearly =
          await QuoteRepository().getQuoteFinancialYearlyRequest(request);

      financialsYearly.yrc = financialsYearly.yrc?.reversed.toList();
      financialsYearly.values?.netPrft =
          financialsYearly.values?.netPrft?.reversed.toList();

      emit(FinancialsYearlyProfitDoneState()
        ..financialsYearly = financialsYearly
        ..positivePeak = AppUtils()
            .doubleValue(financialsYearly.values?.netPrft?.reduce((a, b) {
          if (AppUtils().doubleValue(a) > AppUtils().doubleValue(b)) {
            return a;
          } else {
            return b;
          }
        }))
        ..negativePeak = (AppUtils().doubleValue((financialsYearly
                        .values?.netPrft
                        ?.where((element) =>
                            AppUtils().doubleValue(element).isNegative)
                        .toList()
                        .isEmpty ??
                    true)
                ? "0"
                : financialsYearly.values?.netPrft
                    ?.where(
                        (element) => AppUtils().doubleValue(element).isNegative)
                    .toList()
                    .reduce((a, b) {
                    if (AppUtils().doubleValue(a).abs() >
                        AppUtils().doubleValue(b).abs()) {
                      return a;
                    } else {
                      return b;
                    }
                  })))
            .abs());
    } on ServiceException catch (ex) {
      emit(FinancialsServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(FinancialsErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  @override
  QuoteFinancialsState getErrorState() {
    return FinancialsErrorState();
  }
}
