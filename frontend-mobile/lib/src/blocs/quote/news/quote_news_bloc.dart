import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';
import '../../../data/repository/quote/quote_repository.dart';
import '../../../models/common/sym_model.dart';
import '../../../models/quote/quote_news_detail_model.dart';
import '../../../models/quote/quote_news_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

part 'quote_news_event.dart';
part 'quote_news_state.dart';

class QuoteNewsBloc extends BaseBloc<QuoteNewsEvent, QuoteNewsState> {
  QuoteNewsBloc() : super(QuoteNewsInitial());

  QuoteNewsDataState quoteNewsDataState = QuoteNewsDataState();

  @override
  Future<void> eventHandlerMethod(
      QuoteNewsEvent event, Emitter<QuoteNewsState> emit) async {
    if (event is QuoteFetchNewsEvent) {
      await _handleQuoteFetchNewsEvent(event, emit);
    } else if (event is QuoteFetchNewsDetailsEvent) {
      await _handleQuoteFetchNewsDetailsEvent(event, emit);
    }
  }

  Future<void> _handleQuoteFetchNewsEvent(
    QuoteFetchNewsEvent event,
    Emitter<QuoteNewsState> emit,
  ) async {
    emit(QuoteNewsProgressState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('sym', event.sym);

      final QuoteNewsModel quoteNewsModel =
          await QuoteRepository().getNewsRequest(request);

      quoteNewsDataState.quoteNewsModel = quoteNewsModel;

      emit(QuoteNewsChangeState());

      emit(quoteNewsDataState);
    } on ServiceException catch (ex) {
      emit(QuoteNewsServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuoteNewsFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleQuoteFetchNewsDetailsEvent(
    QuoteFetchNewsDetailsEvent event,
    Emitter<QuoteNewsState> emit,
  ) async {
    emit(QuoteNewsProgressState());

    final BaseRequest request = BaseRequest();
    request.addToData('SerialNumber', event.serialNumber);
    request.addToData('section', 'corporate-news');

    final QuoteNewsDetailModel quoteNewsDetailModel =
        await QuoteRepository().getNewsDetailRequest(request);

    quoteNewsDataState.quoteNewsDetailModel = quoteNewsDetailModel;

    emit(QuoteNewsChangeState());

    emit(quoteNewsDataState);
  }

  @override
  QuoteNewsState getErrorState() {
    return QuoteNewsErrorState();
  }
}
