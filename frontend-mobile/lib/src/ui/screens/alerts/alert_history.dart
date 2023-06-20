import 'package:acml/src/ui/screens/orders/gtdorder_screen.dart';
import 'package:acml/src/ui/widgets/fandotag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/alerts/alerts_bloc.dart';
import '../../../blocs/market_status/market_status_bloc.dart';
import '../../../blocs/orders/order_log/order_log_bloc.dart';
import '../../../blocs/orders/orders_bloc.dart';
import '../../../blocs/watchlist/watchlist_bloc.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/alerts/alerts_model.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/refresh_widget.dart';
import '../base/base_screen.dart';

class AlertsHistory extends BaseScreen {
  const AlertsHistory({Key? key}) : super(key: key);

  @override
  State<AlertsHistory> createState() => _AlertsHistoryState();
}

class _AlertsHistoryState extends BaseAuthScreenState<AlertsHistory>
    with TickerProviderStateMixin {
  FocusNode searchFocusNode = FocusNode();
  final AlertsBloc alertsBloc = AlertsBloc();

  @override
  void initState() {
    alertsBloc
      ..add(FetchTriggeredAlertsEvent())
      ..stream.listen((event) {
        if (event is AlertsError) {
          handleError(event);
        }
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: Theme.of(context).iconTheme,
          title: topBar(context),
        ),
        body: BlocBuilder<AlertsBloc, AlertsState>(
            bloc: alertsBloc,
            buildWhen: (previous, current) =>
                current is AlertsLoading ||
                current is TriggeredAlertsDone ||
                current is AlertsError,
            builder: (context, state) {
              if (state is AlertsLoading) {
                return const LoaderWidget();
              } else if (state is TriggeredAlertsDone &&
                  state.alerts.alertList.isNotEmpty) {
                return ListView.builder(
                  itemCount: state.alerts.alertList.length,
                  itemBuilder: (context, index) {
                    return alertList(context, state.alerts.alertList[index]);
                  },
                );
              } else {
                return RefreshWidget(
                    onRefresh: () {
                      alertsBloc.add(FetchTriggeredAlertsEvent());
                    },
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        SizedBox(
                          height: AppWidgetSize.screenHeight(context) - 150.w,
                          child: errorWithImageWidget(
                            context: context,
                            imageWidget:
                                AppUtils().getNoDateImageErrorWidget(context),
                            errorMessage:
                                AppLocalizations().noDataAvailableErrorMessage,
                            padding: EdgeInsets.only(
                              left: AppWidgetSize.dimen_30,
                              right: AppWidgetSize.dimen_30,
                              bottom: AppWidgetSize.dimen_30,
                            ),
                          ),
                        ),
                      ],
                    ));
              }
            }));
  }

  topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: backIconButton(),
        ),
        Padding(
          padding: EdgeInsets.only(left: AppWidgetSize.dimen_25),
          child: CustomTextWidget(
            "Alerts History",
            Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ],
    );
  }

  Container alertList(BuildContext context, AlertList alert) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.w),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CustomTextWidget(
                    alert.symbol.dispSym ?? "--",
                    Theme.of(context)
                        .primaryTextTheme
                        .labelSmall!
                        .copyWith(fontWeight: FontWeight.w600)),
                FandOTag(alert.symbol)
              ],
            ),

            /*        */

            Container(
              margin: EdgeInsets.only(bottom: AppWidgetSize.dimen_5),
              decoration: BoxDecoration(
                  color: Theme.of(context).snackBarTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(AppWidgetSize.dimen_5)),
              padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 20.w),
              child: CustomTextWidget(
                  "Triggered",
                  Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.only(top: 10.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: AppWidgetSize.fullWidth(context) * 0.5,
                child: CustomTextWidget(
                  "${AppUtils().alertTypeList().firstWhereOrNull((element) => element.alertValue == alert.criteriaType)?.alertName ?? "--"} ${AppUtils().commaFmt(alert.criteriaValue)}${(AppUtils().alertTypeList().firstWhereOrNull((element) => element.alertValue == alert.criteriaType)?.alertName.contains("%") ?? false) ? " %" : ""}",
                  Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: AppWidgetSize.fontSize14),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(
                width: AppWidgetSize.fullWidth(context) * 0.3,
                child: CustomTextWidget(
                  alert.triggeredAt,
                  Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: AppWidgetSize.fontSize14),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  MultiBlocProvider getGtdordersProvider() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => OrdersBloc(),
        ),
        BlocProvider(
          create: (context) => WatchlistBloc(),
        ),
        BlocProvider(
          create: (context) => MarketStatusBloc(),
        ),
        BlocProvider(
          create: (context) => OrderLogBloc(),
        ),
      ],
      child: GtdOrderScreen(searchFocusNode),
    );
  }
}
