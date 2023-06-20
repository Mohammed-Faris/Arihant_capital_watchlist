import 'package:flutter/material.dart';

import '../../../blocs/alerts/alerts_bloc.dart';
import '../../../data/store/app_utils.dart';
import '../../../models/alerts/alerts_model.dart';
import '../../../models/common/symbols_model.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/expansion_tile.dart';
import '../../widgets/fandotag.dart';
import '../base/base_screen.dart';

import 'add_alert/add_alert_popup.dart';

class PendingAlertRow extends BaseScreen {
  final AlertBySymbol alertBySymbol;
  final Function() onRowClick;
  final bool isExpanded;
  final AlertsBloc alertBloc;
  const PendingAlertRow(
    this.alertBloc, {
    Key? key,
    this.isExpanded = false,
    required this.alertBySymbol,
    required this.onRowClick,
  }) : super(key: key);

  @override
  State<PendingAlertRow> createState() => _PendingAlertRowState();
}

class _PendingAlertRowState extends BaseAuthScreenState<PendingAlertRow> {

  String tappedButtonHeader = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20.w, left: 10.w, right: 10.w),
      decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(10.w)),
      child: _buildRowWidget(
        widget.alertBySymbol,
      ),
    );
  }

  Widget _buildRowWidget(
    AlertBySymbol alertBySymbol,
  ) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(
            bottom: AppWidgetSize.dimen_10, right: 20.w, left: 20.w, top: 15.w),
        padding: EdgeInsets.only(
          bottom: AppWidgetSize.dimen_5,
        ),
        width: AppWidgetSize.fullWidth(context),
        child: InkWell(
          onTap: () {},
          child: Theme(
            data: Theme.of(context).copyWith(
                cardColor: Theme.of(context).scaffoldBackgroundColor,
                colorScheme: Theme.of(context).colorScheme.copyWith(
                    background: Theme.of(context).colorScheme.background)),
            child: AppExpansionPanelList(
              animationDuration: const Duration(milliseconds: 200),
              elevation: 0,
              expansionCallback: (int index, bool isExpanded) {
                widget.onRowClick();
              },
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  body: Container(
                    margin: EdgeInsets.only(top: AppWidgetSize.dimen_10),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: alertBySymbol.alertList.length,
                      itemBuilder: (context, index) => Container(
                        padding: EdgeInsets.only(
                            top: 15.w,
                            bottom: index + 1 == alertBySymbol.alertList.length
                                ? 0.w
                                : 15.w),
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    width: 1.w,
                                    color: Theme.of(context).dividerColor))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomTextWidget(
                                    "Current LTP",
                                    Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            fontSize:
                                                AppWidgetSize.fontSize14)),
                                Padding(
                                  padding: EdgeInsets.only(top: 10.w),
                                  child: CustomTextWidget(
                                      alertBySymbol.symbol.ltp ?? "",
                                      Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              fontSize:
                                                  AppWidgetSize.fontSize14)),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CustomTextWidget(
                                          alertBySymbol.alertList[index]
                                                  .alertName.isNotEmpty
                                              ? alertBySymbol
                                                  .alertList[index].alertName
                                              : AppUtils()
                                                      .alertTypeList()
                                                      .firstWhereOrNull(
                                                          (element) =>
                                                              element
                                                                  .alertValue ==
                                                              alertBySymbol
                                                                  .alertList[
                                                                      index]
                                                                  .criteriaType)
                                                      ?.alertName ??
                                                  "--",
                                          Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  fontSize: AppWidgetSize
                                                      .fontSize14)),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.w),
                                        child: CustomTextWidget(
                                            alertBySymbol.alertList[index]
                                                    .criteriaValue +
                                                ((AppUtils()
                                                            .alertTypeList()
                                                            .firstWhereOrNull((element) =>
                                                                element
                                                                    .alertValue ==
                                                                alertBySymbol
                                                                    .alertList[
                                                                        index]
                                                                    .criteriaType)
                                                            ?.alertName
                                                            .contains("%") ??
                                                        false)
                                                    ? " %"
                                                    : ""),
                                            Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    fontSize: AppWidgetSize
                                                        .fontSize14)),
                                      ),
                                    ]),
                                GestureDetector(
                                  onTap: () async {
                                    await AddAlert.show(
                                        context,
                                        widget.alertBySymbol.symbol,
                                        AppUtils()
                                                .alertTypeList()
                                                .firstWhereOrNull((element) =>
                                                    element.alertName ==
                                                    alertBySymbol
                                                        .alertList[index]
                                                        .alertName) ??
                                            AppUtils()
                                                .alertTypeList()
                                                .firstWhereOrNull((element) =>
                                                    element.alertValue ==
                                                    alertBySymbol
                                                        .alertList[index]
                                                        .criteriaType) ??
                                            AlertType("", "", ""),
                                        alertId: alertBySymbol
                                            .alertList[index].alertID,
                                        alertValue: alertBySymbol
                                            .alertList[index].criteriaValue);
                                    await Future.delayed(
                                        const Duration(milliseconds: 200));

                                    widget.alertBloc
                                        .add(FetchPendingAlertsEvent());
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 20.w),
                                    child: AppImages.editIcon(context),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  headerBuilder: (context, isExpanded) {
                    return _buildRowContentWidget(alertBySymbol);
                  },
                  isExpanded: widget.isExpanded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowContentWidget(
    AlertBySymbol alertBySymbol,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopRowWidget(alertBySymbol),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextWidget(
                      alertBySymbol.symbol.companyName ?? "--",
                      Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: AppWidgetSize.fontSize14)),
                  FandOTag(Symbols.fromJson(alertBySymbol.symbol.toJson())),
                ],
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AppImages.countIcon(context),
                  CustomTextWidget(
                      alertBySymbol.alertList.length.toString(),
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: AppWidgetSize.fontSize12,
                          fontWeight: FontWeight.bold))
                ],
              ),
            ),
            widget.isExpanded
                ? AppImages.upArrowIcon(
                    context,
                    color: Theme.of(context).iconTheme.color,
                    isColor: true,
                    width: AppWidgetSize.dimen_25,
                    height: AppWidgetSize.dimen_25,
                  )
                : AppImages.downArrow(
                    context,
                    color: Theme.of(context).iconTheme.color,
                    isColor: true,
                    width: AppWidgetSize.dimen_25,
                    height: AppWidgetSize.dimen_25,
                  ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopRowWidget(
    AlertBySymbol alertBySymbol,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCompanyNameWidget(alertBySymbol),
      ],
    );
  }

  Widget _buildCompanyNameWidget(AlertBySymbol symbolItem) {
    return Row(
      children: [
        Container(
          constraints: BoxConstraints(
              maxWidth: AppWidgetSize.screenWidth(context) * 0.65),
          child: Padding(
            padding: EdgeInsets.only(
              right: AppWidgetSize.dimen_5,
            ),
            child: Text(
              AppUtils()
                  .dataNullCheck((symbolItem.symbol.dispSym?.toUpperCase())),
              style: Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: AppWidgetSize.fontSize16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
