import 'package:acml/src/blocs/common/base_bloc.dart';
import 'package:acml/src/blocs/common/screen_state.dart';
import 'package:acml/src/models/alerts/alerts_model.dart';
import 'package:acml/src/ui/screens/base/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_model.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';

import '../../constants/app_constants.dart';
import '../../data/repository/alerts/alert_repository.dart';
import '../../data/store/app_helper.dart';
import '../../localization/app_localization.dart';
import '../../models/alerts/create_modify_alert_model.dart';
import '../../models/common/symbols_model.dart';
import '../../ui/navigation/screen_routes.dart';
import '../../ui/screens/acml_app.dart';
import '../../ui/screens/alerts/add_alert/widgets/showsuccessorfail.dart';
import '../../ui/styles/app_images.dart';
import '../../ui/styles/app_widget_size.dart';
import '../../ui/widgets/custom_text_widget.dart';

part 'alerts_event.dart';
part 'alerts_state.dart';

class AlertsBloc extends BaseBloc<AlertsEvent, AlertsState> {
  AlertsBloc() : super(AlertsInitial());

  @override
  Future<void> eventHandlerMethod(
      AlertsEvent event, Emitter<AlertsState> emit) async {
    if (event is FetchPendingAlertsEvent) {
      await onFetchPendingAlertsEvent(event, emit);
    }
    if (event is FetchTriggeredAlertsEvent) {
      await onFetchTriggeredAlertsEvent(event, emit);
    } else if (event is CreateAlertAlertsEvent) {
      await onCreateAlertAlertsEvent(event, emit);
    } else if (event is ModifyAlertAlertsEvent) {
      await onModifyAlertAlertsEvent(event, emit);
    } else if (event is DeleteAlertEvent) {
      await onDeleteAlertAlertsEvent(event, emit);
    } else if (event is AlertsStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is AlertsAddStreamEvent) {
      emit(AlertsChange());
      emit(AlertsAddStreamDone());
    }
  }

  Future<void> onFetchPendingAlertsEvent(
      FetchPendingAlertsEvent event, Emitter<AlertsState> emit) async {
    if (pendingAlertsDoneState.alerts.alertList.isEmpty) emit(AlertsLoading());

    AlertModel alertModel = await AlertsRepository().fetchPendingAlerts();
    emit(pendingAlertsDoneState..alerts = (alertModel));
    await sendStream(emit);
  }

  Future<void> onFetchTriggeredAlertsEvent(
      FetchTriggeredAlertsEvent event, Emitter<AlertsState> emit) async {
    emit(AlertsLoading());

    AlertModel alertModel = await AlertsRepository().fetchTriggeredAlerts();
    emit(TriggeredAlertsDone()..alerts = (alertModel));
  }

  onCreateAlertAlertsEvent(
      CreateAlertAlertsEvent event, Emitter<AlertsState> emit) async {
    try {
      emit(AlertsLoading());

      BaseModel baseModel = await AlertsRepository().createAlert(
          CreateorModifyAlertModel(
              alertName: event.alertName,
              alertCriteria: event.criteria,
              sym: event.symbols.sym!));
      AlertSuccessFailureWidget.show(
          context: navigatorKey.currentContext!,
          isSuccess: true,
          title: "Alert created successfully",
          msg: '',
          fromQuote: event.fromStockQuote,
          symbol: event.symbols,
          onDoneCallBack: () {
            navigatorKey.currentState?.pop();
          },
          data:
              'Hurray! An alert been created successfully.You will be notified based on trigger.');

      // showAlertNotification(
      //     message: baseModel.infoMsg,
      //     bottomMarigin: event.fromStockQuote ? 10.w : 100.w,
      //     fromStockQuote: event.fromStockQuote);
      emit(AlertsCreateOrModifyDone(baseModel.infoMsg));
    } on FailedException catch (ex) {
      AlertSuccessFailureWidget.show(
          context: navigatorKey.currentContext!,
          isSuccess: false,
          title: "Alert Creation Failed",
          msg: '',
          symbol: event.symbols,
          fromQuote: event.fromStockQuote,
          onDoneCallBack: () {
            navigatorKey.currentState?.pop();
          },
          data: ex.msg);
    }
  }

  onModifyAlertAlertsEvent(
      ModifyAlertAlertsEvent event, Emitter<AlertsState> emit) async {
    try {
      emit(AlertsLoading());

      BaseModel baseModel = await AlertsRepository().updateAlert(
          CreateorModifyAlertModel(
              alertID: event.alertId,
              alertName: event.alertName,
              alertCriteria: event.criteria,
              sym: event.symbols.sym!));
      AlertSuccessFailureWidget.show(
          context: navigatorKey.currentContext!,
          isSuccess: true,
          fromQuote: false,
          title: "Alert modified successfully",
          msg: '',
          symbol: event.symbols,
          onDoneCallBack: () {
            navigatorKey.currentState?.pop();
          },
          data:
              'Hurray! An alert been modified successfully.You will be notified based on trigger.');

      // showToast(message: baseModel.infoMsg, bottomMarigin: 70.w);
      emit(AlertsCreateOrModifyDone(baseModel.infoMsg));
    } on FailedException catch (ex) {
      AlertSuccessFailureWidget.show(
          context: navigatorKey.currentContext!,
          isSuccess: false,
          title: "Alert Modification Failed",
          msg: '',
          fromQuote: false,
          symbol: event.symbols,
          onDoneCallBack: () {
            navigatorKey.currentState?.pop();
          },
          data: ex.msg);
      // showToast(message: ex.msg, isError: true, bottomMarigin: 70.w);
    }
  }

  onDeleteAlertAlertsEvent(
      DeleteAlertEvent event, Emitter<AlertsState> emit) async {
    try {
      BaseModel baseModel = await AlertsRepository().deleteAlert(event.alertId);
      showToast(message: baseModel.infoMsg, bottomMarigin: 70.w);
    } on FailedException catch (ex) {
      showToast(message: ex.msg, isError: true, bottomMarigin: 70.w);
    }
  }

  onDisableAlertAlertsEvent(
      DisableAlertAlertsEvent event, Emitter<AlertsState> emit) {}

  @override
  AlertsState getErrorState() {
    return AlertsError();
  }

  PendingAlertsDone pendingAlertsDoneState = PendingAlertsDone();
  Future<void> sendStream(Emitter<AlertsState> emit) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer,
      AppConstants.streamingHigh,
      AppConstants.streamingLow,
    ];
    List<Symbols> streamSymbols = [];
    for (int i = 0; i < pendingAlertsDoneState.alerts.equityList.length; i++) {
      streamSymbols.add(pendingAlertsDoneState.alerts.equityList[i].symbol);
    }
    for (int i = 0; i < pendingAlertsDoneState.alerts.futureList.length; i++) {
      streamSymbols.add(pendingAlertsDoneState.alerts.futureList[i].symbol);
    }
    for (int i = 0; i < pendingAlertsDoneState.alerts.optionList.length; i++) {
      streamSymbols.add(pendingAlertsDoneState.alerts.optionList[i].symbol);
    }
    if (streamSymbols.isNotEmpty) {
      emit(AlertSymStreamState(
        AppHelper().streamDetails(streamSymbols, streamingKeys),
      ));
    }
  }

  Future<void> responseCallback(
      ResponseData streamData, Emitter<AlertsState> emit) async {
    if (pendingAlertsDoneState.alerts.alertList.isNotEmpty) {
      final List<AlertBySymbol> symbolsEquity =
          pendingAlertsDoneState.alerts.equityList;

      final int index = symbolsEquity.indexWhere((AlertBySymbol element) {
        return element.symbol.sym!.streamSym == streamData.symbol;
      });
      if (index != -1) {
        symbolsEquity[index].symbol.ltp =
            streamData.ltp ?? symbolsEquity[index].symbol.ltp;
        symbolsEquity[index].symbol.chng =
            streamData.chng ?? symbolsEquity[index].symbol.chng;
        symbolsEquity[index].symbol.chngPer =
            streamData.chngPer ?? symbolsEquity[index].symbol.chngPer;
        symbolsEquity[index].symbol.yhigh =
            streamData.yHigh ?? symbolsEquity[index].symbol.yhigh;
        symbolsEquity[index].symbol.ylow =
            streamData.yLow ?? symbolsEquity[index].symbol.ylow;
        emit(pendingAlertsDoneState..alerts.equityList = symbolsEquity);
      }
      final List<AlertBySymbol> symbolsFuture =
          pendingAlertsDoneState.alerts.futureList;

      final int indexFuture = symbolsFuture.indexWhere((AlertBySymbol element) {
        return element.symbol.sym!.streamSym == streamData.symbol;
      });
      if (indexFuture != -1) {
        symbolsFuture[indexFuture].symbol.ltp =
            streamData.ltp ?? symbolsFuture[indexFuture].symbol.ltp;
        symbolsFuture[indexFuture].symbol.chng =
            streamData.chng ?? symbolsFuture[indexFuture].symbol.chng;
        symbolsFuture[indexFuture].symbol.chngPer =
            streamData.chngPer ?? symbolsFuture[indexFuture].symbol.chngPer;
        symbolsFuture[indexFuture].symbol.yhigh =
            streamData.yHigh ?? symbolsFuture[indexFuture].symbol.yhigh;
        symbolsFuture[indexFuture].symbol.ylow =
            streamData.yLow ?? symbolsFuture[indexFuture].symbol.ylow;
        emit(pendingAlertsDoneState..alerts.futureList = symbolsFuture);
      }
      final List<AlertBySymbol> symbolsOption =
          pendingAlertsDoneState.alerts.optionList;

      final int indexOption = symbolsOption.indexWhere((AlertBySymbol element) {
        return element.symbol.sym!.streamSym == streamData.symbol;
      });
      if (indexOption != -1) {
        symbolsOption[indexOption].symbol.ltp =
            streamData.ltp ?? symbolsOption[indexOption].symbol.ltp;
        symbolsOption[indexOption].symbol.chng =
            streamData.chng ?? symbolsOption[indexOption].symbol.chng;
        symbolsOption[indexOption].symbol.chngPer =
            streamData.chngPer ?? symbolsOption[indexOption].symbol.chngPer;
        symbolsOption[indexOption].symbol.yhigh =
            streamData.yHigh ?? symbolsOption[indexOption].symbol.yhigh;
        symbolsOption[indexOption].symbol.ylow =
            streamData.yLow ?? symbolsOption[indexOption].symbol.ylow;
        emit(pendingAlertsDoneState..alerts.optionList = symbolsOption);
      }
    }
  }

  void showAlertNotification(
      {String? message, double? bottomMarigin, required bool fromStockQuote}) {
    Color backgroundcolor =
        Theme.of(navigatorKey.currentContext!).snackBarTheme.backgroundColor!;
    ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
      padding: EdgeInsets.zero,
      backgroundColor:
          Theme.of(navigatorKey.currentContext!).scaffoldBackgroundColor,
      duration: const Duration(seconds: 5),
      content: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 500),
          curve: Curves.bounceOut,
          tween: Tween(begin: 1.0, end: 0.0),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset((value * 60), 0.0),
              child: Container(child: child),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
                decoration: BoxDecoration(
                    color: backgroundcolor.withOpacity(0.1),
                    border: Border.all(
                        color: backgroundcolor.withOpacity(0.4), width: 1.w),
                    borderRadius: BorderRadius.circular(10.w)),
                width: AppWidgetSize.fullWidth(navigatorKey.currentContext!) -
                    60.w,
                child: Row(
                  children: [
                    AppImages.bankNotificationBadgelogo(
                        navigatorKey.currentContext!,
                        height: 25.w,
                        isColor: true),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(left: 15.w),
                        child: CustomTextWidget(
                          "${message ?? ""}   ",
                          Theme.of(navigatorKey.currentContext!)
                              .primaryTextTheme
                              .labelSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.w500, fontSize: 14.w),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(navigatorKey.currentContext!)
                            .clearSnackBars();
                        if (fromStockQuote) {
                          navigatorKey.currentState
                              ?.pushNamed(ScreenRoutes.alertsScreen);
                        } else {
                          navigatorKey.currentState
                              ?.pushReplacementNamed(ScreenRoutes.alertsScreen);
                        }
                      },
                      child: CustomTextWidget(
                        AppLocalizations().manageAlerts,
                        Theme.of(navigatorKey.currentContext!)
                            .primaryTextTheme
                            .labelSmall
                            ?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 14.w,
                                decoration: TextDecoration.underline,
                                color: Theme.of(navigatorKey.currentContext!)
                                    .primaryColor),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  alignment: Alignment.centerRight,
                  height: AppWidgetSize.dimen_20,
                  child: Container(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(navigatorKey.currentContext!)
                            .clearSnackBars();
                      },
                      child: AppImages.deleteIcon(
                        navigatorKey.currentContext!,
                        color: Theme.of(
                          navigatorKey.currentContext!,
                        ).primaryIconTheme.color,
                      ),
                    ),
                  )),
            ],
          )),
      margin: EdgeInsets.only(
          bottom: bottomMarigin ?? 10.w, left: 10.w, right: 10.w),
      behavior: SnackBarBehavior.floating,
      elevation: 10,
    ));
  }
}
