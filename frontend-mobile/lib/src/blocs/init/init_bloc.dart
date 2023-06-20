import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/models/init/init_request.dart';

import '../../config/app_config.dart';
import '../../constants/storage_constants.dart';
import '../../data/repository/config/config_repository.dart';
import '../../data/repository/init/init_repository.dart';
import '../../data/store/app_storage.dart';
import '../../data/store/app_store.dart';
import '../../data/store/app_utils.dart';
import '../../models/config/config_model.dart';
import '../../models/init/init_model.dart';
import '../common/base_bloc.dart';
import '../common/screen_state.dart';

part 'init_event.dart';
part 'init_state.dart';

class InitBloc extends BaseBloc<InitEvent, InitState> {
  InitBloc() : super(InitNotStartedState());

  @override
  Future<void> eventHandlerMethod(
      InitEvent event, Emitter<InitState> emit) async {
    if (event is InitFetchAppIDEvent) {
      await _hanldeInitFetchAppIDEvent(event, emit);
    }
  }

  Future<void> _hanldeInitFetchAppIDEvent(
    InitFetchAppIDEvent event,
    Emitter<InitState> emit,
  ) async {
    emit(InitProgressState());

    final String? storedAppID = await AppStorage().getData(appid);
    AppStore().setinitFetchedTime();

    if (storedAppID == null) {
      await sendInit('0');
    } else {
      final dynamic storedInitData = await AppStorage().getData(initData);

      final InitRequest initRequest = InitRequest();
      await initRequest.buildRequest('acml', AppConfig.appVersion,
          AppConfig.androidChannelName, AppConfig.iOSChannelName);

      final Object currentInitData = initRequest.getData();
      final bool isEqual =
          json.encode(currentInitData) == json.encode(storedInitData);

      if (!isEqual) {
        await sendInit(storedAppID);
      } else {
        AppStore().setAppID(storedAppID);
      }
    }

    await sendConfig(emit);
  }

  Future<void> sendInit(String appID) async {
    final InitRequest initRequest = InitRequest();
    await initRequest.buildRequest('acml', AppConfig.appVersion,
        AppConfig.androidChannelName, AppConfig.iOSChannelName);
    initRequest.appID = appID;

    final InitModel initModel = await InitRepository().sendRequest(initRequest);

    final Object initRequestData = initRequest.getData();
    AppStore().setAppID(initModel.appID);
    // Should check for exception
    Future.wait(<Future<dynamic>>[
      AppStorage().setData(appid, initModel.appID),
      AppStorage().setData(initData, initRequestData)
    ]);
  }

  Future<void> sendConfig(Emitter<InitState> emit) async {
    late ConfigModel configModel;

    configModel = await ConfigRepository().sendRequest(BaseRequest());
    if (!configModel.isSuccess()) {
      emit(InitFailedState()
        ..errorCode = configModel.infoID
        ..errorMsg = configModel.infoMsg);
      return;
    }
    final String? getUserStatus = await AppStorage().getData(userStatus);
    final String userStatusData =
        getUserStatus != null && getUserStatus != '' ? getUserStatus : '1';

    bool isMandatoryUpdate = configModel.versionDetail != null &&
        configModel.versionDetail!.mandatory;

    if (!isMandatoryUpdate) {
      AppConfig.watchlistSymbolLimit =
          AppUtils().intValue(configModel.watchlistSymLimit);
      AppStore().setPrecision(configModel.precision ?? {});
      AppConfig.needHelpUrl = configModel.needHelpUrl ?? "";
      AppConfig.signUpUrl = configModel.signUpUrl ?? "";
      AppConfig.boUrls = configModel.boUrls;
      AppConfig.chartUrl = configModel.chartUrl ?? "";
      AppConfig.poaLink = configModel.poaLink ?? "";
      AppConfig.referUrl = configModel.referUrl ?? "";
      AppConfig.marginCalculatorUrl = configModel.marginCalculatorUrl ?? "";
      AppConfig.lineChartUrl = configModel.lineChartUrl ?? "";
      AppConfig.suggestedStocks = configModel.suggestedStocks ?? [];
      AppConfig.predefinedWatch = configModel.predefinedWatch ?? [];
      AppConfig.watchlistGroupLimit = configModel.watchlistGroupLimit ?? "5";
      AppConfig.amoMktTimings = configModel.amoMktTimings ?? [];
      AppConfig.gtdTiming = configModel.gtdTiming;
      AppConfig.overviewTab = configModel.overviewTab ?? {};
      AppConfig.quoteTabs = configModel.quoteTabs ?? {};
      AppConfig.arhtBnkDtls = configModel.arhtBnkDtls;
      AppConfig.indices = configModel.indices;
      AppConfig.refreshTime = configModel.refreshTime;
      AppConfig.chartTiming = configModel.chartTiming;
      AppConfig.chartTimingv2 = configModel.chartTiming_v2;
      AppConfig.callFortrade = configModel.callforTrade ?? "";
      AppConfig.gtdTiming = configModel.gtdTiming;
      AppConfig.holidays = configModel.holidays ?? [];
      AppConfig.maintenance = configModel.maintenance;
    }

    emit(InitCompletedState(userStatusData, configModel));
    // ignore: empty_catches
  }

  @override
  InitState getErrorState() {
    return InitFailedState();
  }
}
