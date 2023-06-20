import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../../blocs/alerts/alerts_bloc.dart';
import '../../../../blocs/market_status/market_status_bloc.dart';
import '../../../../constants/app_constants.dart';
import '../../../../constants/keys/watchlist_keys.dart';
import '../../../../constants/keys/widget_keys.dart';
import '../../../../data/store/app_helper.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/alerts/create_modify_alert_model.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_color.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../validator/input_validator.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/gradient_button_widget.dart';
import '../../acml_app.dart';
import '../../base/base_screen.dart';

class AddAlertScreen extends BaseScreen {
  final Symbols symbol;
  final AlertType alertType;
  final String? alertId;
  final String? value;
  final bool fromStockQuote;

  const AddAlertScreen(
      {super.key,
      required this.symbol,
      this.alertId,
      this.value,
      this.fromStockQuote = false,
      required this.alertType});

  @override
  State<AddAlertScreen> createState() => _AddAlertScreenState();
}

class _AddAlertScreenState extends BaseAuthScreenState<AddAlertScreen> {
  late Symbols symbols;
  TextEditingController alertVal = TextEditingController();
  @override
  void initState() {
    symbols = widget.symbol;

    BlocProvider.of<MarketStatusBloc>(context)
        .add(GetMarketStatusEvent(widget.symbol.sym!));
    subscribeLevel1(
      AppHelper().streamDetails([
        symbols
      ], [
        AppConstants.streamingLtp,
        AppConstants.streamingChng,
        AppConstants.streamingChgnPer,
        AppConstants.streamingLtt,
        AppConstants.streamingVol,
        AppConstants.streamingHigh,
        AppConstants.streamingLow,
      ]),
    );
    alertVal.text = widget.value ?? "";
    super.initState();
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.addAlertScreen;
  }

  @override
  void quote1responseCallback(ResponseData data) {
    final String symbolName = data.symbol!;
    if (symbols.sym!.streamSym == symbolName) {
      symbols.ltp = data.ltp ?? symbols.ltp;
      symbols.chng = data.chng ?? symbols.chng;
      symbols.chngPer = data.chngPer ?? symbols.chngPer;
      symbols.lTradedTime = data.ltt ?? symbols.lTradedTime;
      symbols.vol = data.vol ?? symbols.vol;
      symbols.yhigh = data.yHigh ?? symbols.yhigh;
      symbols.ylow = data.yLow ?? symbols.ylow;

      if (widget.alertType.alertName == AppLocalizations().priceHits52WH) {
        alertVal.text = symbols.yhigh ?? "";
      }
      if (widget.alertType.alertName == AppLocalizations().priceHits52WL) {
        alertVal.text = symbols.ylow ?? "";
      }
      BlocProvider.of<AlertsBloc>(context).add(AlertsAddStreamEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        topRowWithBackButton(context),
        if (!widget.fromStockQuote)
          BlocBuilder<AlertsBloc, AlertsState>(builder: (context, state) {
            return streamingData(context);
          }),
        addAlertField(context),
        if (widget.alertId == null)
          createAlertButton(context)
        else
          modifyAlertButton(context)
      ],
    );
  }

  Center modifyAlertButton(BuildContext context) {
    return Center(
      child: Padding(
          padding: EdgeInsets.only(
            top: 5.w,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              gradientButtonWidget(
                onTap: () async {
                  validated = true;

                  BlocProvider.of<AlertsBloc>(context)
                      .add(DeleteAlertEvent(widget.alertId ?? ""));
                  navigatorKey.currentState?.pop();
                },
                width: AppWidgetSize.fullWidth(context) / 2.5,
                key: const Key(negativeButtonKey),
                context: context,
                title: AppLocalizations().delete,
                isGradient: false,
                isErrorButton: true,
              ),
              SizedBox(
                width: AppWidgetSize.dimen_10,
              ),
              ValueListenableBuilder(
                  valueListenable: alertVal,
                  builder: (context, value, child) => Opacity(
                        opacity: widget.alertId != null &&
                                widget.value == alertVal.text
                            ? 0.3
                            : 1,
                        child: gradientButtonWidget(
                            onTap: () {
                              validated = true;

                              if (!(widget.alertId != null &&
                                  widget.value == alertVal.text)) {
                                if (_formKey.currentState!.validate()) {
                                  BlocProvider.of<AlertsBloc>(context).add(
                                      ModifyAlertAlertsEvent(
                                          widget.symbol,
                                          AlertCriteria(
                                              criteriaType:
                                                  widget.alertType.alertValue,
                                              criteriaVal: alertVal.text),
                                          widget.alertId ?? "",
                                          widget.alertType.alertName));
                                  navigatorKey.currentState?.pop();
                                }
                              }
                            },
                            width: AppWidgetSize.fullWidth(context) / 2.5,
                            key: const Key(updateAlertKey),
                            context: context,
                            title: AppLocalizations().update,
                            isGradient: true),
                      ))
            ],
          )),
    );
  }

  Center createAlertButton(BuildContext context) {
    return Center(
      child: Padding(
          padding: EdgeInsets.only(
            top: 5.w,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: gradientButtonWidget(
              onTap: () {
                validated = true;
                if (_formKey.currentState!.validate()) {
                  BlocProvider.of<AlertsBloc>(context)
                      .add(CreateAlertAlertsEvent(
                          widget.symbol,
                          AlertCriteria(
                            criteriaType: widget.alertType.alertValue,
                            criteriaVal: alertVal.text,
                          ),
                          widget.fromStockQuote,
                          widget.alertType.alertName));
                  navigatorKey.currentState?.pop();
                  if (!widget.fromStockQuote) {
                    navigatorKey.currentState?.pop();
                  }
                }
              },
              bottom: 0,
              width: AppWidgetSize.fullWidth(context) / 1.5,
              key: const Key(addAlertKey),
              context: context,
              title: AppLocalizations().createAlert,
              isGradient: true)),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool validated = false;
  Container addAlertField(BuildContext context) {
    return Container(
      width: 200.w,
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        top: 5.w,
        bottom: AppWidgetSize.dimen_15,
      ),
      child: Column(
        children: [
          ValueListenableBuilder(
              valueListenable: alertVal,
              builder: (context, value, _) {
                return Form(
                    key: _formKey,
                    child: TextFormField(
                      style: Theme.of(context).primaryTextTheme.labelLarge,
                      controller: alertVal,
                      autofocus: true,
                      inputFormatters: InputValidator.doubleValidator(
                          AppUtils().getDecimalpoint(widget.symbol.sym?.exc)),
                      readOnly: (widget.alertType.alertName ==
                              AppLocalizations().priceHits52WH) ||
                          (widget.alertType.alertName ==
                              AppLocalizations().priceHits52WL),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      cursorColor: Theme.of(context).primaryIconTheme.color,
                      textAlign: TextAlign.center,
                      autovalidateMode: validated
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      validator: (value) {
                        if (widget.alertType.alertValue ==
                            AppConstants.priceMoveAboveKey) {
                          if (alertVal.text.exdouble() >
                              symbols.ltp.exdouble()) {
                            return null;
                          }
                        } else if (widget.alertType.alertValue ==
                            AppConstants.priceMoveBelowKey) {
                          if (symbols.ltp.exdouble() >
                              alertVal.text.exdouble()) {
                            return null;
                          }
                        } else if (widget.alertType.alertValue ==
                            AppConstants.priceMoveUpByPerKey) {
                          if (alertVal.text.exdouble() >
                              symbols.chngPer.exdouble()) {
                            return null;
                          }
                        } else if (widget.alertType.alertValue ==
                            AppConstants.priceMoveBelowPerKey) {
                          if (symbols.chngPer.exdouble() >
                              alertVal.text.exdouble()) {
                            return null;
                          }
                        } else if (widget.alertType.alertValue ==
                            AppConstants.volumeMovesaboveKey) {
                          if (alertVal.text.exdouble() >
                              symbols.vol.exdouble()) {
                            return null;
                          }
                        } else if (widget.alertType.alertValue ==
                            AppConstants.volumeMovesBelowKey) {
                          if (symbols.vol.exdouble() >
                              alertVal.text.exdouble()) {
                            return null;
                          }
                        }
                        return "Rule condition already met";
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                          left: 15.w,
                          top: 15.w,
                          bottom: 15.w,
                          right: 10.w,
                        ),
                        errorMaxLines: 5,
                        errorStyle: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.negativeColor),
                        errorBorder: textBorder(color: AppColors.negativeColor),
                        prefixStyle: Theme.of(context)
                            .primaryTextTheme
                            .labelLarge
                            ?.copyWith(
                              fontFamily: AppConstants.interFont,
                            ),
                        suffixStyle: Theme.of(context)
                            .primaryTextTheme
                            .labelLarge
                            ?.copyWith(
                              fontFamily: AppConstants.interFont,
                            ),
                        prefixText: !widget.alertType.alertName.contains("%") &&
                                (widget.alertType.alertName.contains("price") ||
                                    widget.alertType.alertName
                                        .contains("Price"))
                            ? AppConstants.rupeeSymbol
                            : "",
                        suffixText:
                            widget.alertType.alertName.contains("%") ? "%" : "",
                        labelStyle:
                            Theme.of(context).primaryTextTheme.labelSmall,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.w),
                          borderSide:
                              BorderSide(color: Theme.of(context).dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                        ),
                      ),
                    ));
              }),
          // if ((widget.alertType.alertType != AppConstants.volumeAlerts))
          //   showBottomData()
        ],
      ),
    );
  }

  OutlineInputBorder textBorder({Color? color}) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color ?? Theme.of(context).dividerColor,
        width: 1.w,
      ),
      borderRadius: BorderRadius.circular(
        3.w,
      ),
    );
  }

  ValueListenableBuilder<TextEditingValue> showBottomData() {
    return ValueListenableBuilder(
        valueListenable: alertVal,
        builder: (context, value, _) {
          return (alertVal.text.isNotEmpty)
              ? Container(
                  height: 25.w,
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: RichText(
                        text: TextSpan(children: [
                      if (widget.alertType.alertName.contains("%"))
                        TextSpan(
                          text: widget.alertType.alertName.contains("%")
                              ? AppConstants.rupeeSymbol
                              : "",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .bodyLarge!
                              .copyWith(
                                  fontFamily: AppConstants.interFont,
                                  color: AppUtils().profitLostColor(((1 +
                                                  (alertVal.value.text
                                                          .exdouble() /
                                                      100)) *
                                              symbols.ltp.exdouble()) >=
                                          symbols.ltp.exdouble()
                                      ? "1"
                                      : "-1")),
                        ),
                      TextSpan(
                          text: !widget.alertType.alertName.contains("%") &&
                                  (widget.alertType.alertName.contains("Price") ||
                                      widget.alertType.alertName
                                          .contains("price"))
                              ? '${(((alertVal.value.text.exdouble() - symbols.ltp.exdouble()) / symbols.ltp.exdouble()) * 100).toStringAsFixed(2)}% '
                              : widget.alertType.alertName.contains("%")
                                  ? " ${((1 + (alertVal.value.text.exdouble() / 100)) * symbols.ltp.exdouble()).toStringAsFixed(2)}"
                                  : "",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .bodyLarge!
                              .copyWith(
                                  color: AppUtils().profitLostColor(
                                      !widget.alertType.alertName.contains("%") &&
                                              (widget.alertType.alertName.contains("Price") ||
                                                  widget.alertType.alertName
                                                      .contains("price"))
                                          ? (((alertVal.value.text.exdouble() - symbols.ltp.exdouble()) /
                                                      symbols.ltp.exdouble()) *
                                                  100)
                                              .toStringAsFixed(2)
                                          : ((1 + (alertVal.value.text.exdouble() / 100)) *
                                                      symbols.ltp.exdouble()) >=
                                                  symbols.ltp.exdouble()
                                              ? "1"
                                              : "-1"))),
                    ])),
                  ),
                )
              : Container();
        });
  }

  streamingData(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 30.w, bottom: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CustomTextWidget(
                  widget.symbol.companyName == null
                      ? AppUtils().dataNullCheck(widget.symbol.dispSym!)
                      : AppUtils().dataNullCheck(widget.symbol.companyName!),
                  Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: AppWidgetSize.dimen_16,
                      ),
                  textAlign: TextAlign.left),
              Padding(
                padding: EdgeInsets.only(left: 10.w, bottom: 2.w),
                child: _buildMarketStatusBloc(),
              ),
            ],
          ),
          if ((widget.alertType.alertType != AppConstants.volumeAlerts))
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_5,
                bottom: AppWidgetSize.dimen_5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomTextWidget(
                        AppUtils().dataNullCheck(symbols.ltp),
                        Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.w,
                              color: AppUtils().setcolorForChange(
                                  AppUtils().dataNullCheck(widget.symbol.chng)),
                            ),
                        isShowShimmer: true,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: AppWidgetSize.dimen_5,
                        ),
                        child: CustomTextWidget(
                          AppUtils().getChangePercentage(symbols),
                          Theme.of(context)
                              .primaryTextTheme
                              .bodySmall!
                              .copyWith(
                                fontSize: 14.w,
                                color: Theme.of(context)
                                    .inputDecorationTheme
                                    .labelStyle!
                                    .color,
                              ),
                          isShowShimmer: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (widget.alertType.alertType == AppConstants.volumeAlerts)
            Padding(
                padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_5,
                  bottom: AppWidgetSize.dimen_5,
                ),
                child: CustomTextWidget(
                  "Volume : ${symbols.vol}",
                  Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                        fontSize: 14.w,
                        color: Theme.of(context)
                            .inputDecorationTheme
                            .labelStyle!
                            .color,
                      ),
                  isShowShimmer: true,
                )),
        ],
      ),
    );
  }

  Padding topRowWithBackButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 20.w,
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10.w, left: 20.w),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: AppImages.backButtonIcon(context,
                  color: Theme.of(context).primaryIconTheme.color),
            ),
          ),
          Text(
            widget.alertType.alertName,
            // style: Theme.of(context).textTheme.headline2,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: 22.w),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketStatusBloc() {
    return BlocBuilder<MarketStatusBloc, MarketStatusState>(
      buildWhen: (MarketStatusState previous, MarketStatusState current) {
        return current is MarketStatusDoneState ||
            current is MarketStatusFailedState ||
            current is MarketStatusServiceExpectionState;
      },
      builder: (context, state) {
        if (state is MarketStatusDoneState) {
          return _buildMarketStatusWidget(state.isOpen);
        } else if (state is MarketStatusFailedState ||
            state is MarketStatusServiceExpectionState) {
          return Container();
        }
        return Container();
      },
    );
  }

  Widget _buildMarketStatusWidget(
    bool isOpen,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: AppWidgetSize.dimen_3,
            ),
            child: Container(
              width: AppWidgetSize.dimen_5,
              height: AppWidgetSize.dimen_5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.w),
                color: isOpen
                    ? AppColors().positiveColor
                    : AppColors.negativeColor,
              ),
            ),
          ),
          CustomTextWidget(
            isOpen ? AppLocalizations().live : AppLocalizations().closed,
            Theme.of(navigatorKey.currentContext!)
                .primaryTextTheme
                .bodyLarge!
                .copyWith(
                    color: Theme.of(navigatorKey.currentContext!)
                        .colorScheme
                        .primary),
          ),
        ],
      ),
    );
  }
}
