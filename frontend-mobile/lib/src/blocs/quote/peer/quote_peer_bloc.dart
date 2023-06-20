import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../constants/app_constants.dart';
import '../../../data/repository/quote/quote_repository.dart';
import '../../../data/store/app_helper.dart';
import '../../../data/store/app_utils.dart';
import '../../../models/common/sym_model.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/quote/quote_peer_model.dart';
import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';

part 'quote_peer_event.dart';
part 'quote_peer_state.dart';

class QuotePeerBloc extends BaseBloc<QuotePeerEvent, QuotePeerState> {
  QuotePeerBloc() : super(QuotePeerInitial());

  QuotePeerRatiosDataState quotePeerRatiosDataState =
      QuotePeerRatiosDataState();

  @override
  Future<void> eventHandlerMethod(
      QuotePeerEvent event, Emitter<QuotePeerState> emit) async {
    if (event is QuoteFetchPeerRatiosEvent) {
      await _handleQuoteFetchPeerRatiosEvent(event, emit);
    } else if (event is QuotePeerStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is QuotePeerStartSymStreamEvent) {
      await sendStream(emit);
    } else if (event is QuotePeerSortSymbolsEvent) {
      await _handleQuotePeerSortSymbolsEvent(event, emit);
    }
  }

  Future<void> _handleQuoteFetchPeerRatiosEvent(
    QuoteFetchPeerRatiosEvent event,
    Emitter<QuotePeerState> emit,
  ) async {
    if (event.isLoaderNeeded) {
      emit(QuotePeerProgressState());
    }

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('sym', event.sym);
      request.addToData('finFormat', 'c');

      final QuotePeerModel quotePeerModel =
          await QuoteRepository().getPeersRatioRequest(request);

      quotePeerRatiosDataState.quotePeerModel = quotePeerModel;

//remove the first value since first value is same as sym block
      quotePeerRatiosDataState.quotePeerModel!.peerRatioList = quotePeerModel
          .peerRatioList!
          .getRange(1, quotePeerModel.peerRatioList!.length)
          .toList();
      quotePeerRatiosDataState.quotePeerModelmain =
          List.from(quotePeerModel.peerRatioList ?? []);
      if (quotePeerRatiosDataState.quotePeerModel?.peerRatioList?.isEmpty ??
          false) {
        emit(QuotePeerRatiosFailedState());
      } else {
        emit(QuotePeerRatiosChangeState());

        await sendStream(emit);
        emit(quotePeerRatiosDataState);
      }
    } on ServiceException catch (ex) {
      emit(QuotePeerRatiosServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuotePeerRatiosFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> sendStream(Emitter<QuotePeerState> emit) async {
    if (quotePeerRatiosDataState.quotePeerModel != null) {
      final List<String> streamingKeys = <String>[
        AppConstants.streamingLtp,
        AppConstants.streamingChng,
        AppConstants.streamingChgnPer,
      ];

      if (quotePeerRatiosDataState.quotePeerModel!.peerRatioList!.isNotEmpty) {
        emit(QuotePeerSymStreamState(
          AppHelper().streamDetails(
              quotePeerRatiosDataState.quotePeerModel!.peerRatioList,
              streamingKeys),
        ));
      }
    }
  }

  Future<void> responseCallback(
      ResponseData streamData, Emitter<QuotePeerState> emit) async {
    if (quotePeerRatiosDataState.quotePeerModel != null) {
      final List<Symbols>? symbols =
          quotePeerRatiosDataState.quotePeerModel!.peerRatioList;

      if (symbols != null) {
        final int index = symbols.indexWhere((Symbols element) {
          return element.sym!.streamSym == streamData.symbol;
        });
        if (index != -1) {
          symbols[index].ltp = streamData.ltp ?? symbols[index].ltp;
          symbols[index].chng = streamData.chng ?? symbols[index].chng;
          symbols[index].chngPer = streamData.chngPer ?? symbols[index].chngPer;
          symbols[index].yhigh = streamData.yHigh ?? symbols[index].yhigh;
          symbols[index].ylow = streamData.yLow ?? symbols[index].ylow;
          emit(QuotePeerRatiosChangeState());
          emit(quotePeerRatiosDataState
            ..quotePeerModel!.peerRatioList = symbols);
        }
      }
    }
  }

  Future<void> _handleQuotePeerSortSymbolsEvent(
      QuotePeerSortSymbolsEvent event, Emitter<QuotePeerState> emit) async {
    final List<Symbols> symbols =
        List.from(quotePeerRatiosDataState.quotePeerModelmain ?? []);

    if (event.selectedSort == AppConstants.priceLowToHigh) {
      symbols.sort((Symbols a, Symbols b) => AppUtils()
          .doubleValue(AppUtils().decimalValue(a.ltp ?? '0'))
          .compareTo(
              AppUtils().doubleValue(AppUtils().decimalValue(b.ltp ?? '0'))));
    } else if (event.selectedSort == AppConstants.priceHighToLow) {
      symbols.sort((Symbols a, Symbols b) => AppUtils()
          .doubleValue(AppUtils().decimalValue(b.ltp ?? '0'))
          .compareTo(
              AppUtils().doubleValue(AppUtils().decimalValue(a.ltp ?? '0'))));
    } else if (event.selectedSort == AppConstants.chngPerctLowToHigh) {
      symbols.sort((Symbols a, Symbols b) => AppUtils()
          .doubleValue(AppUtils().decimalValue(a.chngPer ?? '0'))
          .compareTo(AppUtils()
              .doubleValue(AppUtils().decimalValue(b.chngPer ?? '0'))));
    } else if (event.selectedSort == AppConstants.chngPerctHighToLow) {
      symbols.sort((Symbols a, Symbols b) => AppUtils()
          .doubleValue(AppUtils().decimalValue(b.chngPer ?? '0'))
          .compareTo(AppUtils()
              .doubleValue(AppUtils().decimalValue(a.chngPer ?? '0'))));
    } else if (event.selectedSort == AppConstants.alphabeticalAtoZ) {
      symbols.sort((Symbols a, Symbols b) {
        return a.dispSym!.toLowerCase().compareTo(b.dispSym!.toLowerCase());
      });
    } else if (event.selectedSort == AppConstants.alphabeticalZtoA) {
      symbols.sort((Symbols a, Symbols b) {
        return b.dispSym!.toLowerCase().compareTo(a.dispSym!.toLowerCase());
      });
    }

    quotePeerRatiosDataState.quotePeerModel!.peerRatioList = symbols;

    emit(QuotePeerRatiosChangeState());

    emit(quotePeerRatiosDataState);
  }

  @override
  QuotePeerState getErrorState() {
    return QuotePeerRatiosErrorState();
  }
}
