import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/alerts/alerts_bloc.dart';
import '../../../../blocs/market_status/market_status_bloc.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../widgets/info_bottomsheet.dart';
import 'add_alert_screen.dart';

class AddAlert {
  // ignore: avoid_types_as_parameter_names
  static show(BuildContext context, Symbols symbol, AlertType alertType,
      {String? alertId, String? alertValue, bool fromStockQuote = false}) {
    return InfoBottomSheet.showInfoBottomsheet(StatefulBuilder(
        builder: (BuildContext context, StateSetter updateState) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => MarketStatusBloc(),
          ),
          BlocProvider(
            create: (context) => AlertsBloc(),
          ),
        ],
        child: AddAlertScreen(
          alertType: alertType,
          symbol: symbol,
          fromStockQuote: fromStockQuote,
          alertId: alertId,
          value: alertValue,
        ),
      );
    }), context, horizontalMargin: false);
  }
}
