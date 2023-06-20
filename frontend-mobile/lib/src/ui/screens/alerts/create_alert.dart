import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../blocs/market_status/market_status_bloc.dart';
import '../../../blocs/quote/main_quote/quote_bloc.dart';
import '../../../blocs/watchlist/watchlist_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/keys/quote_keys.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/watchlist/watchlist_group_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_widget_size.dart';
import '../../validator/input_validator.dart';
import '../../widgets/alert_percent_toggle.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/horizontal_list_view.dart';
import '../../widgets/label_border_text_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/material_switch.dart';
import '../../widgets/scrollable_circularbutton.dart';
import '../base/base_screen.dart';

class CreateAlert extends BaseScreen {
  final dynamic arguments;
  const CreateAlert({Key? key, required this.arguments}) : super(key: key);

  @override
  CreateAlertState createState() => CreateAlertState();
}

class CreateAlertState extends BaseAuthScreenState<CreateAlert>
    with TickerProviderStateMixin {
  late QuoteBloc quoteBloc;
  late MarketStatusBloc marketStatusBloc;
  TextEditingController priceController = TextEditingController();

  final AppLocalizations _appLocalizations = AppLocalizations();
  ValueNotifier<bool> isScrolledToTop = ValueNotifier<bool>(false);
  ValueNotifier<int> tabIndex = ValueNotifier<int>(0);
  ValueNotifier<int> percentIndex = ValueNotifier<int>(0);

  ValueNotifier<bool> highToggle = ValueNotifier<bool>(false);
  ValueNotifier<bool> lowToggle = ValueNotifier<bool>(false);
  ValueNotifier<bool> smsToggle = ValueNotifier<bool>(false);
  ValueNotifier<bool> emailToggle = ValueNotifier<bool>(false);
  ValueNotifier<bool> notificationToggle = ValueNotifier<bool>(false);
  bool percentActive = false;

  late Symbols symbols;

  List<String>? exchangeList = [];
  List<Groups>? groupList = <Groups>[];
  String symbolType = "";
  List percentList = ["-15%", "-10%", "-5%", "+5%", "+10%", "+15%"];
  List validityList = ["Day", "week", "Month", "year"];
  @override
  void initState() {
    symbols = widget.arguments['symbolItem'];

    symbolType = AppUtils().getsymbolType(symbols);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      marketStatusBloc = BlocProvider.of<MarketStatusBloc>(context)
        ..add(GetMarketStatusEvent(symbols.sym!));
      quoteBloc = BlocProvider.of<QuoteBloc>(context)
        ..stream.listen(quoteListener);
      quoteBloc.add(QuoteGetSectorEvent(symbols.sym!));

      callStreaming();
    });

    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.quoteScreen);
    arguments = widget.arguments;
  }

  void callStreaming() {
    quoteBloc.add(QuoteStartSymStreamEvent(symbols));
  }

  Future<void> quoteListener(QuoteState state) async {
    if (state is! QuoteProgressState) {
      if (mounted) {}
    }
    if (state is QuoteProgressState) {
      if (mounted) {}
    } else if (state is QuoteExcChangeState) {
   unsubscribeLevel1();
      symbols = state.symbolItem;
      symbolType = AppUtils().getsymbolType(symbols);

      if (symbols.sym != null) {
        marketStatusBloc.add(GetMarketStatusEvent(symbols.sym!));
      }
      callStreaming();
    } else if (state is QuoteSymStreamState) {
      subscribeLevel1(state.streamDetails);
      setState(() {});
    } else if (state is QuotedeleteDoneState) {
      showToast(
        message: state.messageModel,
        context: context,
      );
    } else if (state is QuoteAddSymbolFailedState ||
        state is QuotedeleteSymbolFailedState) {
      showToast(
        message: state.errorMsg,
        context: context,
        isError: true,
      );
    } else if (state is QuoteAddDoneState) {
      showToast(
        message: state.messageModel,
        context: context,
      );
    } else if (state is QuoteErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  Future<void> watchlistListener(WatchlistState state) async {
    if (state is WatchlistDoneState) {
      groupList = [];
      if (state.watchlistGroupModel != null) {
        for (Groups element in state.watchlistGroupModel!.groups!) {
          groupList!.add(element);
        }
      }
    }
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.createAlert;
  }

  @override
  void quote1responseCallback(ResponseData data) {
    quoteBloc.add(QuoteStreamingResponseEvent(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildSliverAppBar(
          context,
          AppWidgetSize.dimen_140,
        ),
        body: _buildTabListWidget(),
        bottomNavigationBar: SizedBox(
          height: 90.w,
          child: Center(
            child: gradientButtonWidget(
              onTap: () {},
              width: AppWidgetSize.fullWidth(context) / 2,
              key: const Key(""),
              context: context,
              title: AppLocalizations().createAlert,
              isGradient: true,
            ),
          ),
        ));
  }

  Widget _buildQuoteStreamingContent(bool isAppBar) {
    return BlocBuilder<QuoteBloc, QuoteState>(
        buildWhen: (QuoteState previous, QuoteState current) {
      return current is QuoteSymbolItemState;
    }, builder: (context, state) {
      if (state is QuoteProgressState) {
        return const LoaderWidget();
      }
      if (state is QuoteSymbolItemState) {
        return _buildSliverAppBarContent();
      }
      return Container();
    });
  }

  _buildSliverAppBar(
    BuildContext context,
    double height,
  ) {
    return AppBar(
        toolbarHeight: 70.w,
        title: Row(
          children: [
            backIconButton(
                onTap: () {
                  popNavigation();
                },
                customColor: Theme.of(context).textTheme.displayMedium!.color),
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: CustomTextWidget(
                AppLocalizations().createAlert,
                Theme.of(context).textTheme.headlineSmall,
              ),
            )
          ],
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(100.w),
            child: _buildQuoteStreamingContent(false)));
  }

  Widget _buildSliverAppBarContent() {
    return Container(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_24,
        right: AppWidgetSize.dimen_30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
              symbols.companyName == null
                  ? AppUtils().dataNullCheck(symbols.dispSym!)
                  : AppUtils().dataNullCheck(symbols.companyName!),
              Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: AppWidgetSize.dimen_20,
                  ),
              textAlign: TextAlign.left),
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
                            color: AppUtils().setcolorForChange(
                                AppUtils().dataNullCheck(symbols.chng)),
                          ),
                      isShowShimmer: true,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: AppWidgetSize.dimen_5,
                        left: AppWidgetSize.dimen_5,
                      ),
                      child: CustomTextWidget(
                        AppUtils().getChangePercentage(symbols),
                        Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
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
                _buildMarketStatusBloc(),
              ],
            ),
          ),
          CustomTextWidget(
            '${_appLocalizations.asOf} ${AppUtils().dataNullCheck(symbols.lTradedTime)}',
            Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                  color:
                      Theme.of(context).inputDecorationTheme.labelStyle!.color,
                ),
          ),
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
                    _buildSectorNameWidget(),
                    Padding(
                      padding: EdgeInsets.only(
                        top: AppWidgetSize.dimen_3,
                      ),
                      child: CustomTextWidget(
                        '${AppUtils().dataNullCheck(symbols.vol)} ${_appLocalizations.vol}',
                        Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                              color: Theme.of(context)
                                  .inputDecorationTheme
                                  .labelStyle!
                                  .color,
                            ),
                      ),
                    ),
                  ],
                ),
                //if (symbols.isFno )
              ],
            ),
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
            isOpen ? _appLocalizations.live : _appLocalizations.closed,
            Theme.of(context)
                .primaryTextTheme
                .bodyLarge!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorNameWidget() {
    return BlocBuilder<QuoteBloc, QuoteState>(
        buildWhen: (QuoteState previous, QuoteState current) {
      return current is QuoteSectorDataState ||
          current is QuoteSectorFailedState;
    }, builder: (context, state) {
      if (state is QuoteSectorDataState) {
        if (state.sectorName.isNotEmpty) {
          double sectorLblWidth = state.sectorName == ''
              ? 5
              : state.sectorName.textSize(
                      state.sectorName,
                      Theme.of(context)
                          .inputDecorationTheme
                          .labelStyle!
                          .copyWith(
                            fontSize: AppWidgetSize.fontSize12,
                          )) +
                  15;
          if (sectorLblWidth >= 150) {
            sectorLblWidth = 140;
          }
          return Padding(
            padding: EdgeInsets.only(right: AppWidgetSize.dimen_5),
            child: Container(
              width: sectorLblWidth,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: LabelBorderWidget(
                keyText: const Key(quoteLabelKey),
                text: state.sectorName,
                textColor:
                    Theme.of(context).inputDecorationTheme.labelStyle!.color,
                fontSize: AppWidgetSize.fontSize12,
                margin: EdgeInsets.only(top: AppWidgetSize.dimen_1),
                borderRadius: AppWidgetSize.dimen_20,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                borderWidth: AppWidgetSize.dimen_1,
                borderColor: Theme.of(context).dividerColor,
              ),
            ),
          );
        } else {
          return Container();
        }
      } else if (state is QuoteSectorFailedState) {
        return Container();
      }
      return Container();
    });
  }

  Widget _buildTabListWidget() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Theme.of(context).dividerColor)),
            margin: EdgeInsets.symmetric(vertical: 20.w, horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                horizontalListViewCenter(
                  values: [
                    _appLocalizations.price,
                    _appLocalizations.volume,
                    _appLocalizations.oI
                  ],
                  selectedIndex: tabIndex.value,
                  isEnabled: true,
                  shirinkWrap: false,
                  isRectShape: false,
                  callback: (value, index) {
                    setState(() {
                      tabIndex.value = index;
                    });
                  },
                  highlighterColor:
                      Theme.of(context).primaryTextTheme.displayLarge!.color!,
                  context: context,
                ),
                tabBodywidget()
              ],
            ),
          ),
          (tabIndex.value != 2)
              ? ValueListenableBuilder<int>(
                  valueListenable: percentIndex,
                  builder: (context, value, _) {
                    return AlertPercentToggle(
                      value: percentActive ? percentList[value] : "",
                      toggleButtonlist: percentList,
                      toggleButtonOnChanged: (data) {
                        percentActive = true;
                      },
                      toggleChanged: (index) {
                        percentIndex.value = index;
                      },
                      activeButtonColor: percentIndex.value < 3
                          ? Theme.of(context)
                              .colorScheme
                              .onSecondary
                              .withOpacity(0.2)
                          : Theme.of(context)
                              .snackBarTheme
                              .backgroundColor!
                              .withOpacity(0.5),
                      activeTextColor: percentIndex.value < 3
                          ? AppColors.negativeColor
                          : AppColors.primaryColor,
                      inactiveButtonColor: Colors.transparent,
                      inactiveTextColor: Theme.of(context)
                          .primaryTextTheme
                          .titleMedium!
                          .color!,
                      key: const Key("key"),
                      defaultSelected: '',
                      enabledButtonlist: const [],
                      isBorder: true,
                      runSpacing: 15.w,
                      context: context,
                      paddingEdgeInsets: EdgeInsets.only(
                        left: AppWidgetSize.dimen_14,
                        right: AppWidgetSize.dimen_14,
                        top: AppWidgetSize.dimen_4,
                        bottom: AppWidgetSize.dimen_4,
                      ),
                      marginEdgeInsets: EdgeInsets.only(
                        right: 10.w,
                      ),
                      fontSize: 18.w,
                      islightBorderColor: true,
                      borderColor: percentIndex.value < 3
                          ? Theme.of(context).colorScheme.onError
                          : Theme.of(context).primaryColor,
                    );
                  })
              : Container()
        ],
      ),
    );
  }

  Widget tabBodywidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.w),
          child: CustomTextWidget(
              "Alert when ${tabIndex.value == 0 ? "price" : tabIndex.value == 1 ? "Volume" : "OI"} is Below",
              Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: AppWidgetSize.fontSize16)),
        ),
        Container(
          margin: EdgeInsets.only(top: 10.w, bottom: 10.w),
          width: AppWidgetSize.fullWidth(context) / 2,
          child: TextField(
              key: const Key(""),
              enabled: true,
              readOnly: false,
              enableInteractiveSelection: true,
              // ignore: deprecated_member_use
              toolbarOptions: const ToolbarOptions(
                copy: false,
                cut: false,
                paste: false,
                selectAll: false,
              ),
              scrollPadding: EdgeInsets.only(
                bottom: 50.w,
              ),
              onTap: () async {},
              controller: priceController,
              cursorColor: Theme.of(context).primaryIconTheme.color,
              textAlign: TextAlign.center,
              onChanged: (String data) {},
              decoration: InputDecoration(
                filled: true,
                isDense: true,
                enabledBorder: textBorder(),
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: textBorder(),
                focusedBorder: textBorder(),
                errorBorder: textBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15.w, horizontal: 12.w),
                disabledBorder: textBorder(
                    color: Theme.of(context).dividerColor.withOpacity(0.5)),
                prefixText: AppConstants.rupeeSymbol,
                prefixStyle: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontFamily: AppConstants.interFont),
                suffixStyle: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontFamily: AppConstants.interFont),
                hintText: '',
                hintStyle: Theme.of(context).primaryTextTheme.labelSmall,
                labelStyle: Theme.of(context).primaryTextTheme.labelSmall,
              ),
              inputFormatters: InputValidator.doubleValidator(2),
              keyboardType: TextInputType.number,
              style: Theme.of(context).primaryTextTheme.labelSmall),
        ),
        Divider(
          color: Theme.of(context).dividerColor,
        ),
        if (tabIndex.value == 0)
          expansionWidget("Set Alert if the scrip crosses", [
            setAlert("High", "3,502.40", highToggle, context, (value) {
              highToggle.value = value;
            }),
            setAlert("Low", "3,502.40", lowToggle, context, (value) {
              lowToggle.value = value;
            })
          ]),
        expansionWidget("Mode of alert & Validity", [
          alertModes("SMS", context, smsToggle, (value) {
            smsToggle.value = value;
          }),
          alertModes("Email", context, emailToggle, (value) {
            emailToggle.value = value;
          }),
          alertModes("Push Notification", context, notificationToggle, (value) {
            notificationToggle.value = value;
          }),
          buildValidityWidget()
        ]),
      ],
    );
  }

  Theme expansionWidget(String heading, List<Widget> listWidgets) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        expandedAlignment: Alignment.centerLeft,
        initiallyExpanded: false,
        tilePadding: EdgeInsets.only(
          right: 10,
          left: 10,
          bottom: 5.w,
        ),
        collapsedIconColor: Theme.of(context).primaryIconTheme.color,
        title: CustomTextWidget(
            heading,
            Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: AppWidgetSize.fontSize16)),
        iconColor: Theme.of(context).primaryIconTheme.color,
        expandedCrossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: listWidgets,
            ),
          )
        ],
      ),
    );
  }

  Row setAlert(String title, value, ValueNotifier<bool> toggleValue,
      BuildContext alertcontext, Function(bool)? onChanged) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      CustomTextWidget(
          title,
          Theme.of(alertcontext)
              .textTheme
              .bodySmall
              ?.copyWith(fontSize: AppWidgetSize.fontSize16)),
      CustomTextWidget(
          value,
          Theme.of(alertcontext).textTheme.bodySmall?.copyWith(
              color: Theme.of(alertcontext).primaryTextTheme.titleSmall?.color,
              fontWeight: FontWeight.w500,
              fontSize: AppWidgetSize.fontSize16)),
      switchWidget(toggleValue, onChanged),
    ]);
  }

  ValueListenableBuilder<bool> switchWidget(
      ValueNotifier<bool> toggleValue, Function(bool)? onChanged) {
    return ValueListenableBuilder<bool>(
        valueListenable: toggleValue,
        builder: (cxt, value, _) {
          return MaterialSwitch(
            onChanged: onChanged,
            value: toggleValue.value,
            inactiveThumbColor: Theme.of(context).primaryColor,
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Theme.of(context).snackBarTheme.backgroundColor,
            activeColor: Colors.white,
          );
        });
  }

  Column buildValidityWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomTextWidget(
                  "Validity",
                  Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: AppWidgetSize.fontSize16)),
            ],
          ),
        ),
        ScrollableCircularButtonWidget(
          value: "Day",
          toggleButtonlist: validityList,
          toggleButtonOnChanged: (data) {},
          activeButtonColor:
              Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.5),
          activeTextColor: AppColors.primaryColor,
          inactiveButtonColor: Colors.transparent,
          inactiveTextColor:
              Theme.of(context).primaryTextTheme.titleMedium!.color!,
          key: const Key("key"),
          defaultSelected: '',
          enabledButtonlist: const [],
          isBorder: true,
          runSpacing: 15.w,
          context: context,
          paddingEdgeInsets: EdgeInsets.only(
            left: AppWidgetSize.dimen_14,
            right: AppWidgetSize.dimen_14,
            top: AppWidgetSize.dimen_4,
            bottom: AppWidgetSize.dimen_4,
          ),
          marginEdgeInsets: EdgeInsets.only(
            right: 10.w,
          ),
          fontSize: 18.w,
          islightBorderColor: true,
          borderColor: Theme.of(context).primaryColor,
        ),
      ],
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

  Widget alertModes(String title, BuildContext toggleContext,
      ValueNotifier<bool> toggleValue, Function(bool)? onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextWidget(
            title,
            Theme.of(toggleContext)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: AppWidgetSize.fontSize16)),
        switchWidget(toggleValue, onChanged),
      ],
    );
  }
}
