import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/screen_state.dart';


part 'arihant_ledger_event.dart';
part 'arihant_ledger_state.dart';

class ArihantLedgerBloc extends Bloc<ArihantLedgerEvent, ArihantLedgerState> {
  ArihantLedgerBloc() : super(ArihantLedgerInitial()) {
    on<ArihantLedgerEvent>((event, emit) {
      
    });
  }
}
