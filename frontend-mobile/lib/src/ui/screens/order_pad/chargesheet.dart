import 'package:acml/src/models/common/symbols_model.dart';
import 'package:acml/src/ui/screens/acml_app.dart';
import 'package:acml/src/ui/widgets/custom_text_widget.dart';
import 'package:acml/src/ui/widgets/loader_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../blocs/charges/charges_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../data/store/app_utils.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/expansion_tile.dart';

class ChargeSheet extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isMcx;
  final bool isCurrency;
  const ChargeSheet(
      {Key? key,
      required this.data,
      this.isMcx = false,
      required this.isCurrency})
      : super(key: key);

  @override
  State<ChargeSheet> createState() => _ChargeSheetState();
}

class _ChargeSheetState extends State<ChargeSheet> {
  final ValueNotifier<bool> externalChargesExpanded =
      ValueNotifier<bool>(false);
  final ValueNotifier<bool> taxesExpanded = ValueNotifier<bool>(false);
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChargesBloc>(context).add(FetchChargesEvent(widget.data));
  }

  final GlobalKey externalchargekey = GlobalKey();
  final GlobalKey taxKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          width: AppWidgetSize.fullWidth(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (AppUtils()
                                .getsymbolType(Symbols(sym: widget.data["sym"]))
                                .toLowerCase() ==
                            AppConstants.equity.toLowerCase() ||
                        AppUtils()
                                .getsymbolType(Symbols(sym: widget.data["sym"]))
                                .toLowerCase() ==
                            AppConstants.fno.toLowerCase())
                    ? "Transaction & Clearing Charges"
                    : "Transaction Charges",
                style: Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: AppImages.closeIcon(
                  context,
                  width: AppWidgetSize.dimen_20,
                  height: AppWidgetSize.dimen_20,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true,
                ),
              )
            ],
          ),
        ),
        BlocBuilder<ChargesBloc, ChargesState>(
          builder: (context, state) {
            if (state is ChargesProgressState) {
              return SizedBox(height: 300.w, child: const LoaderWidget());
            }
            if (state is ChargesDoneState) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: AppWidgetSize.fullWidth(context),
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      padding: EdgeInsets.only(top: 8.0.w),
                      child: Text(
                        DateFormat('dd MMM yyyy').format(DateTime.now()),
                        style: Theme.of(context).primaryTextTheme.bodySmall,
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(
                          maxHeight: AppWidgetSize.fullHeight(context) * 0.52),
                      child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 30.w),
                              child: expandableChildRow(
                                  'Trade Value',
                                  commaFtWithPrecision(AppUtils().decimalValue(
                                      AppUtils().doubleValue(state.chargesModel
                                                  .brokerage?.qty ??
                                              "0") *
                                          AppUtils().doubleValue(state
                                                  .chargesModel
                                                  .brokerage
                                                  ?.price ??
                                              "0"))),
                                  lableBottom:
                                      '${AppUtils().intValue(state.chargesModel.brokerage?.qty ?? "0")} Qty x ${AppConstants.rupeeSymbol} ${commaFtWithPrecision(state.chargesModel.brokerage?.price ?? "0")}',
                                  isHeader: true),
                            ),
                            const Divider(),
                            Padding(
                              padding: EdgeInsets.only(top: 30.w, bottom: 10.w),
                              child: expandableChildRow(
                                  'Brokerage',
                                  commaFtWithPrecision(state.chargesModel
                                          .brokerage?.brokeragePrice ??
                                      "0"),
                                  isHeader: true),
                            ),
                            buildExpandableList(
                                context,
                                externalchargekey,
                                "External Charges",
                                commaFtWithPrecision(state.chargesModel
                                        .brokerage?.externalCharges ??
                                    "0"),
                                externalChargesExpanded,
                                [
                                  {
                                    "label": "Transaction Charges",
                                    "value": commaFtWithPrecision(
                                        state.chargesModel.brokerage?.tot ??
                                            "0")
                                  },
                                  {
                                    "label": "Stamp Duty",
                                    "value": commaFtWithPrecision(state
                                            .chargesModel
                                            .brokerage
                                            ?.stampDuty ??
                                        "0"),
                                  },
                                ]),
                            buildExpandableList(
                                context,
                                taxKey,
                                "Taxes",
                                commaFtWithPrecision(
                                    state.chargesModel.brokerage?.taxes ?? "0"),
                                taxesExpanded,
                                [
                                  if (!widget.isCurrency)
                                    {
                                      "label": widget.isMcx
                                          ? "Commodity transaction tax (CTT)"
                                          : "Security transaction tax (STT)",
                                      "value": commaFtWithPrecision(
                                          state.chargesModel.brokerage?.stt ??
                                              "0"),
                                    },
                                  {
                                    "label": "SEBI Tax",
                                    "value": commaFtWithPrecision(
                                        state.chargesModel.brokerage?.sebiFee ??
                                            "0"),
                                  },
                                  {
                                    "label": "GST",
                                    "value": commaFtWithPrecision(
                                        state.chargesModel.brokerage?.gst ??
                                            "0"),
                                    "footer":
                                        "18% of the SEBI tax, Transaction and brokerage charges"
                                  },
                                ]),
                            if (AppUtils()
                                    .getsymbolType(
                                        Symbols(sym: widget.data["sym"]))
                                    .toLowerCase() ==
                                AppConstants.currency.toLowerCase())
                              Padding(
                                padding:
                                    EdgeInsets.only(top: 20.w, bottom: 10.w),
                                child: expandableChildRow(
                                    'IPF',
                                    commaFtWithPrecision(
                                        state.chargesModel.brokerage?.ipf ??
                                            "0"),
                                    isHeader: true),
                              ),
                            const Divider(),
                            if ((AppUtils()
                                        .getsymbolType(
                                            Symbols(sym: widget.data["sym"]))
                                        .toLowerCase() ==
                                    AppConstants.equity.toLowerCase() ||
                                AppUtils()
                                        .getsymbolType(
                                            Symbols(sym: widget.data["sym"]))
                                        .toLowerCase() ==
                                    AppConstants.fno.toLowerCase()))
                              Padding(
                                padding:
                                    EdgeInsets.only(top: 20.w, bottom: 10.w),
                                child: expandableChildRow(
                                    'IPFT',
                                    commaFtWithPrecision(
                                        state.chargesModel.brokerage?.ipft ??
                                            "0"),
                                    isHeader: true),
                              ),
                            const Divider(),
                          ]),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.w, horizontal: 20.w),
                      width: AppWidgetSize.fullWidth(context),
                      color: Theme.of(context).colorScheme.background,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    AppWidgetSize.screenWidth(context) * 0.5),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Charges",
                                    style:
                                        Theme.of(navigatorKey.currentContext!)
                                            .primaryTextTheme
                                            .labelSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w500),
                                  ),
                                  CustomTextWidget(
                                    "/bNote/b: Charges are approximately calculated.\nActual charges will reflect in contract note.",
                                    Theme.of(navigatorKey.currentContext!)
                                        .primaryTextTheme
                                        .bodySmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12.w),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    AppWidgetSize.screenWidth(context) * 0.3),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: CustomTextWidget(
                                "${AppConstants.rupeeSymbol} ${commaFtWithPrecision(state.chargesModel.brokerage?.totalCharges ?? "0")}",
                                Theme.of(navigatorKey.currentContext!)
                                    .primaryTextTheme
                                    .labelSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }
            return errorWithImageWidget(
              context: context,
              imageWidget: AppUtils().getNoDateImageErrorWidget(context),
              errorMessage: state.errorMsg,
              height: 300.w,
              padding: EdgeInsets.only(
                left: 30.w,
                right: 30.w,
                bottom: 30.w,
              ),
            );
          },
        ),
      ],
    );
  }

  String commaFtWithPrecision(String data) {
    return AppUtils().commaFmt(data, decimalPoint: countDecimalPlaces(data));
  }

  countDecimalPlaces(str) {
    int decimalIndex = str.indexOf(".");
    if (decimalIndex == -1) {
      return 0;
    }

    return str.substring(decimalIndex + 1).length;
  }

  void scrollToSelectedContent({GlobalKey? expansionTileKey}) {
    final keyContext = expansionTileKey?.currentContext;
    if (keyContext != null) {
      Future.delayed(const Duration(milliseconds: 400)).then((value) {
        Scrollable.ensureVisible(keyContext,
            duration: const Duration(milliseconds: 200));
      });
    }
  }

  Padding buildExpandableList(
      BuildContext context,
      GlobalKey key,
      String header,
      String headerValue,
      ValueListenable<bool> valueListenable,
      List<Map<String, String>> childlist) {
    return Padding(
      padding: EdgeInsets.only(top: 8.w),
      child: Theme(
        data: ThemeData().copyWith(
            dividerColor: Colors.transparent,
            cardColor: Theme.of(context).scaffoldBackgroundColor,
            colorScheme: Theme.of(context).colorScheme.copyWith(
                background: Theme.of(context).colorScheme.background)),
        child: ValueListenableBuilder(
            valueListenable: valueListenable,
            builder: (context, value, _) {
              return AppExpansionPanelList(
                key: key,
                animationDuration: const Duration(milliseconds: 200),
                elevation: 0,
                expansionCallback: (int index, bool isExpanded) {
                  if (header == "External Charges") {
                    externalChargesExpanded.value =
                        !externalChargesExpanded.value;
                    if (taxesExpanded.value) {
                      taxesExpanded.value = !taxesExpanded.value;
                    }
                  } else {
                    taxesExpanded.value = !taxesExpanded.value;
                    if (externalChargesExpanded.value) {
                      externalChargesExpanded.value =
                          !externalChargesExpanded.value;
                    }
                  }
                  scrollToSelectedContent(expansionTileKey: key);
                },
                children: [
                  ExpansionPanel(
                    canTapOnHeader: true,
                    body: ListView.builder(
                      itemCount: childlist.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        vertical: AppWidgetSize.dimen_10,
                      ),
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(top: index == 0 ? 0 : 12.w),
                        child: expandableChildRow(
                            childlist[index]["label"] ?? "",
                            childlist[index]["value"] ?? "",
                            lableBottom: childlist[index]["footer"]),
                      ),
                    ),
                    headerBuilder: (context, isExpanded) {
                      return SizedBox(
                        width: AppWidgetSize.fullWidth(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(header,
                                    style:
                                        Theme.of(navigatorKey.currentContext!)
                                            .primaryTextTheme
                                            .labelSmall),
                                Padding(
                                  padding: EdgeInsets.only(left: 15.w),
                                  child: valueListenable.value
                                      ? AppImages.upArrowCircleIcon(context,
                                          color: Theme.of(
                                                  navigatorKey.currentContext!)
                                              .primaryIconTheme
                                              .color,
                                          isColor: true,
                                          width: 20.w)
                                      : AppImages.downArrowCircleIcon(context,
                                          color: Theme.of(
                                                  navigatorKey.currentContext!)
                                              .primaryIconTheme
                                              .color,
                                          isColor: true,
                                          width: 20.w),
                                ),
                              ],
                            ),
                            CustomTextWidget(
                              '${AppConstants.rupeeSymbol} $headerValue',
                              Theme.of(navigatorKey.currentContext!)
                                  .primaryTextTheme
                                  .labelSmall,
                            ),
                          ],
                        ),
                      );
                    },
                    isExpanded: valueListenable.value,
                  ),
                ],
              );
            }),
      ),
    );
  }

  Row expandableChildRow(String label, String value,
      {String? lableBottom, bool isHeader = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              label,
              style: isHeader
                  ? Theme.of(navigatorKey.currentContext!)
                      .primaryTextTheme
                      .labelSmall
                  : Theme.of(navigatorKey.currentContext!)
                      .primaryTextTheme
                      .labelSmall
                      ?.copyWith(
                          fontSize: 14.w,
                          color: Theme.of(navigatorKey.currentContext!)
                              .primaryTextTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.8)),
            ),
            if (lableBottom != null)
              Container(
                constraints: BoxConstraints(
                    maxWidth: AppWidgetSize.screenWidth(context) * 0.55),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 4.0,
                    ),
                    child: CustomTextWidget(
                      lableBottom,
                      Theme.of(context)
                          .primaryTextTheme
                          .bodySmall
                          ?.copyWith(fontSize: 12.w),
                    ),
                  ),
                ),
              ),
          ],
        ),
        Container(
          constraints: BoxConstraints(
              maxWidth: AppWidgetSize.screenWidth(context) * 0.35),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: CustomTextWidget(
              '${AppConstants.rupeeSymbol} $value',
              isHeader
                  ? Theme.of(navigatorKey.currentContext!)
                      .primaryTextTheme
                      .labelSmall
                  : Theme.of(navigatorKey.currentContext!)
                      .primaryTextTheme
                      .labelSmall
                      ?.copyWith(
                          fontSize: 14.w,
                          color: Theme.of(navigatorKey.currentContext!)
                              .primaryTextTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.8)),
            ),
          ),
        ),
      ],
    );
  }
}
