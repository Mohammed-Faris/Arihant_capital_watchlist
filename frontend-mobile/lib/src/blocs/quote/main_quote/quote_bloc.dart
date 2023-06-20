import 'package:acml/src/models/watchlist/watchlist_symbols_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../constants/app_constants.dart';
import '../../../data/cache/cache_repository.dart';
import '../../../data/repository/quote/quote_repository.dart';
import '../../../data/repository/search/search_repository.dart';
import '../../../data/store/app_helper.dart';
import '../../../models/common/message_model.dart';
import '../../../models/common/sym_model.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/quote/get_symbol_info_model.dart';
import '../../../models/quote/sector_model.dart';
import '../../../models/watchlist/symbol_watchlist_map_holder_model.dart';
import '../../../models/watchlist/watchlist_group_model.dart';
import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';

part 'quote_event.dart';
part 'quote_state.dart';

class QuoteBloc extends BaseBloc<QuoteEvent, QuoteState> {
  QuoteBloc() : super(QuoteInitial());

  QuoteSymbolItemState quoteSymbolItemState = QuoteSymbolItemState();

  @override
  Future<void> eventHandlerMethod(
      QuoteEvent event, Emitter<QuoteState> emit) async {
    if (event is QuoteStartSymStreamEvent) {
      await sendStream(emit, event.symbolItem);
    } else if (event is QuoteStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is QuoteAddSymbolEvent) {
      await _handleAddSymbolEvent(event, emit);
    } else if (event is QuotedeleteSymbolEvent) {
      await _handledeleteSymbolEvent(event, emit);
    } else if (event is QuoteExcChangeEvent) {
      await _handleQuoteExcChangeEvent(event, emit);
    } else if (event is QuoteGetSectorEvent) {
      await _handleQuoteGetSectorEvent(event, emit);
    }
  }

  Future<void> _handleQuoteExcChangeEvent(
    QuoteExcChangeEvent event,
    Emitter<QuoteState> emit,
  ) async {
    emit(QuoteProgressState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('sym', quoteSymbolItemState.symbols!.sym!.toJson());
      request.addToData('otherExch', event.exchange);
      GetSymbolModel getSymbolModel =
          await QuoteRepository().getSymbolInfoRequest(request);

      Symbols quoteItem = getSymbolModel.symbol!;
      emit(QuoteExcChangeState(quoteItem));
    } on ServiceException catch (ex) {
      emit(QuoteExcChangeFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuoteExcChangeFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleQuoteGetSectorEvent(
    QuoteGetSectorEvent event,
    Emitter<QuoteState> emit,
  ) async {
    emit(QuoteProgressState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('sym', event.sym);
      SectorModel sectorModel =
          await QuoteRepository().getSectorNameRequest(request);
      emit(QuoteSectorDataState(sectorModel.sctrNme ?? ""));
    } on ServiceException catch (ex) {
      emit(QuoteExcChangeFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuoteExcChangeFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleAddSymbolEvent(
      QuoteAddSymbolEvent event, Emitter<QuoteState> emit) async {
    emit(QuoteProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('wName', event.groupname);
      request.addToData('syms', [event.symbolItem.sym]);
      MessageModel messageModel;
      if (event.isNewWatchlist) {
        messageModel = await SearchRepository().addSymbolsToNewGroup(request);
        // WatchlistRepository().clearAllWatchlistGroups();
        if (messageModel.isSuccess()) {
          Groups group = Groups(
            wId: event.groupname,
            wName: event.groupname,
            defaultMarketWatch: true,
            editable: true,
          );
          await SearchRepository().updateWatchlistGroup(group);
        }
        emit(QuoteChangeState());
      } else {
        messageModel = await SearchRepository().addSymbolInGroups(request);
      }
      SymbolWatchlistMapHolder()
          .add(event.symbolItem.sym!.id!, event.groupname);
      WatchlistSymbolsModel? previousData =
          await CacheRepository.watchlistCache.get(event.groupname);
      if (previousData != null) {
        previousData.symbols.add(event.symbolItem);
        CacheRepository.watchlistCache.put(event.groupname, previousData);
      }
      emit(QuoteChangeState());
      emit(QuoteAddDoneState(messageModel.infoMsg));
    } on ServiceException catch (ex) {
      emit(QuoteAddSymbolFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuoteAddSymbolFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handledeleteSymbolEvent(
      QuotedeleteSymbolEvent event, Emitter<QuoteState> emit) async {
    emit(QuoteProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('wName', event.groupname);
      request.addToData('symbols', [event.symbolItem.sym]);
      MessageModel messageModel =
          await SearchRepository().deleteSymbolInGroups(request);
      SymbolWatchlistMapHolder()
          .remove(event.symbolItem.sym!.id!, event.groupname);
      WatchlistSymbolsModel? previousData =
          await CacheRepository.watchlistCache.get(event.groupname);
      if (previousData != null) {
        previousData.symbols
            .removeWhere((e) => e.dispSym == event.symbolItem.dispSym);
        CacheRepository.watchlistCache.put(event.groupname, previousData);
      }
      emit(QuotedeleteDoneState(messageModel.infoMsg));
    } on ServiceException catch (ex) {
      emit(QuotedeleteSymbolFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuotedeleteSymbolFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> sendStream(
    Emitter<QuoteState> emit,
    Symbols symbolItem,
  ) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer,
      AppConstants.streamingLtt,
      AppConstants.streamingVol,
    ];

    List<Symbols> symbols = [];

    symbols.add(symbolItem);

    quoteSymbolItemState.symbols = symbols[0];

    emit(quoteSymbolItemState);

    emit(
      QuoteSymStreamState(
        AppHelper().streamDetails(symbols, streamingKeys),
      ),
    );
  }

  Future<void> responseCallback(
    ResponseData streamData,
    Emitter<QuoteState> emit,
  ) async {
    final String symbolName = streamData.symbol!;
    final Symbols symbol = quoteSymbolItemState.symbols!;
    if (symbol.sym!.streamSym == symbolName) {
      symbol.ltp = streamData.ltp ?? symbol.ltp;
      symbol.chng = streamData.chng ?? symbol.chng;
      symbol.chngPer = streamData.chngPer ?? symbol.chngPer;
      symbol.lTradedTime = streamData.ltt ?? symbol.lTradedTime;
      symbol.vol = streamData.vol ?? symbol.vol;
    }
    quoteSymbolItemState.symbols = symbol;

    emit(QuoteChangeState());

    emit(quoteSymbolItemState);
  }

  @override
  QuoteState getErrorState() {
    return QuoteErrorState();
  }
}
