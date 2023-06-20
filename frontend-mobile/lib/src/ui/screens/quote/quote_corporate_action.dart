import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../blocs/quote/corporate_action/quote_corporate_action_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/keys/quote_keys.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/quote/corporate_action/data_point_base.dart';
import '../../../models/quote/corporate_action/data_points_service.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/circular_toggle_button_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/loader_widget.dart';
import '../base/base_screen.dart';

class QuoteCorporateAction extends BaseScreen {
  final dynamic arguments;
  const QuoteCorporateAction({Key? key, this.arguments}) : super(key: key);

  @override
  QuoteCorporateActionsState createState() => QuoteCorporateActionsState();
}

class QuoteCorporateActionsState
    extends BaseAuthScreenState<QuoteCorporateAction> {
  late QuoteCorporateActionBloc _quoteCorporateActionBloc;
  late AppLocalizations _appLocalizations;
  late Symbols symbols;
  List<String> filterList = [];
  String selectedFilter = AppConstants.all;
  DataPointsService service = DataPointsService();

  @override
  void initState() {
    super.initState();
    symbols = widget.arguments['symbolItem'];
    symbols.sym!.baseSym = symbols.baseSym;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quoteCorporateActionBloc =
          BlocProvider.of<QuoteCorporateActionBloc>(context)
            ..stream.listen(_quoteCorporateActionListener);
      _quoteCorporateActionBloc
          .add(FetchQuoteCorporateActionEvent(symbols.sym!));
    });
  }

  Future<void> _quoteCorporateActionListener(
      QuoteCorporateActionState state) async {
    if (state is! QuoteCorporateActionProgressState) {
      if (mounted) {}
    }
    if (state is QuoteCorporateActionProgressState) {
      if (mounted) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCircularFilterWidget(context),
          Expanded(child: _buildCorporateActionListWidget(context)),
        ],
      ),
    );
  }

  Column corporateactionDisclaimer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
          child: CustomTextWidget(
            AppLocalizations().disclaimer,
            Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: AppWidgetSize.fontSize12),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
          child: CustomTextWidget(
              AppLocalizations().disclaimerContent,
              Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: AppWidgetSize.fontSize11)),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_5, bottom: AppWidgetSize.dimen_5),
          child: CustomTextWidget(
              AppLocalizations().cmotsData,
              Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: AppWidgetSize.fontSize11)),
        ),
      ],
    );
  }

  Widget _buildCircularFilterWidget(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_10,
          bottom: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_30,
          right: AppWidgetSize.dimen_30,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            BlocBuilder<QuoteCorporateActionBloc, QuoteCorporateActionState>(
              buildWhen: (previous, current) {
                return current is QuoteCorporateActionDataState ||
                    current is QuoteCorporateActionFailedState ||
                    current is QuoteCorporateActionServiceExceptionState;
              },
              builder: (context, state) {
                if (state is QuoteCorporateActionDataState) {
                  filterList =
                      service.getFilterList(state.quoteCorporateActionModel);
                  if (filterList.length == 1) {
                    selectedFilter = filterList.elementAt(0);
                    return Container();
                  } else {
                    return _getCircularButtonToggleWidget();
                  }
                } else if (state is QuoteCorporateActionFailedState ||
                    state is QuoteCorporateActionServiceExceptionState) {
                  return Container();
                }
                return _getCircularButtonToggleWidget();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCircularButtonToggleWidget() {
    return CircularButtonToggleWidget(
      value: selectedFilter,
      toggleButtonlist: filterList,
      toggleButtonOnChanged: (data) {
        toggleButtonOnChanged(data);
      },
      activeButtonColor:
          Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.5),
      activeTextColor: Theme.of(context).primaryColor,
      inactiveButtonColor: Colors.transparent,
      inactiveTextColor: Theme.of(context).primaryColor,
      key: const Key(quoteCorporateActionFilterKey),
      defaultSelected: '',
      enabledButtonlist: const [],
      isBorder: false,
      context: context,
      borderColor: Colors.transparent,
      fontSize: 18.w,
    );
  }

  Widget _buildCorporateActionListWidget(BuildContext context) {
    return BlocBuilder<QuoteCorporateActionBloc, QuoteCorporateActionState>(
      buildWhen: (QuoteCorporateActionState prevState,
          QuoteCorporateActionState currentState) {
        return currentState is QuoteCorporateActionDataState ||
            currentState is QuoteCorporateActionFailedState ||
            currentState is QuoteCorporateActionProgressState ||
            currentState is QuoteCorporateActionServiceExceptionState;
      },
      builder: (BuildContext ctx, QuoteCorporateActionState state) {
        if (state is QuoteCorporateActionProgressState) {
          return const LoaderWidget();
        }
        if (state is QuoteCorporateActionDataState) {
          if (state.quoteCorporateActionModel != null) {
            if (selectedFilter == AppConstants.bonus) {
              List<DataPointBase> bonusDataPoints =
                  service.getBonus(state.quoteCorporateActionModel!);
              return checkEmptyAndBuildContentWidget(
                bonusDataPoints,
                service.getBonusMsg(
                  state.quoteCorporateActionModel!,
                ),
              );
            } else if (selectedFilter == AppConstants.rights) {
              List<DataPointBase> rightsDataPoints =
                  service.getRights(state.quoteCorporateActionModel!);
              return checkEmptyAndBuildContentWidget(
                rightsDataPoints,
                service.getRightsMsg(
                  state.quoteCorporateActionModel!,
                ),
              );
            } else if (selectedFilter == AppConstants.splits) {
              List<DataPointBase> splitsDataPoints = service.getSplits(
                state.quoteCorporateActionModel!,
              );
              return checkEmptyAndBuildContentWidget(
                splitsDataPoints,
                service.getSplitsMsg(
                  state.quoteCorporateActionModel!,
                ),
              );
            } else if (selectedFilter == AppConstants.dividend) {
              List<DataPointBase> dividendDataPoints =
                  service.getDividend(state.quoteCorporateActionModel!);
              return checkEmptyAndBuildContentWidget(
                dividendDataPoints,
                service.getDividendMsg(
                  state.quoteCorporateActionModel!,
                ),
              );
            } else {
              List<DataPointBase> allDataPoints =
                  service.getAllDataPoints(state.quoteCorporateActionModel!);
              allDataPoints.sort((a, b) => DateFormat('dd-MM-yyyy')
                  .parse(service.getProperties(
                      b,
                      (service.getTypeAsString(b.type!) == AppConstants.bonus)
                          ? "bonusDte"
                          : ((service.getTypeAsString(b.type!) ==
                                  AppConstants.rights)
                              ? 'rightDte'
                              : (service.getTypeAsString(b.type!) ==
                                      AppConstants.splits)
                                  ? 'spltDte'
                                  : 'divDate')))
                  .compareTo(DateFormat('dd-MM-yyyy').parse(
                      service.getProperties(
                          a,
                          (service.getTypeAsString(a.type!) ==
                                  AppConstants.bonus)
                              ? "bonusDte"
                              : ((service.getTypeAsString(a.type!) ==
                                      AppConstants.rights)
                                  ? 'rightDte'
                                  : (service.getTypeAsString(a.type!) ==
                                          AppConstants.splits)
                                      ? 'spltDte'
                                      : 'divDate')))));
              return checkEmptyAndBuildContentWidget(allDataPoints, '');
            }
          }
        } else if (state is QuoteCorporateActionFailedState) {
          return errorWithImageWidget(
            context: context,
            imageWidget: _geterrorImageWidget(),
            errorMessage: _appLocalizations.emptyCorporateActionMessage,
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
              bottom: AppWidgetSize.dimen_30,
            ),
          );
        } else if (state is QuoteCorporateActionServiceExceptionState) {
          return errorWithImageWidget(
            context: context,
            imageWidget: AppUtils().getNoDateImageErrorWidget(context),
            errorMessage: state.errorMsg,
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
              bottom: AppWidgetSize.dimen_30,
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget checkEmptyAndBuildContentWidget(
    List<DataPointBase> dataPointsList,
    String errorMsg,
  ) {
    return dataPointsList.isNotEmpty
        ? _buildContentListWigdet(dataPointsList)
        : SizedBox(
            height: AppWidgetSize.fullWidth(context),
            child: Center(
              child: Text(
                errorMsg.isNotEmpty
                    ? errorMsg
                    : _appLocalizations.noDataAvailableErrorMessage,
                style: Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
          );
  }

  Widget _geterrorImageWidget() {
    return AppImages.emptyCorporateAction(context,
        isColor: false,
        width: AppWidgetSize.fullWidth(context) - AppWidgetSize.dimen_100,
        height: AppWidgetSize.dimen_150);
  }

  Widget _buildContentListWigdet(List<DataPointBase> dataPointsList) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        key: const Key(quoteCorporateActionListKey),
        itemCount: dataPointsList.length,
        itemBuilder: (BuildContext ctx, dynamic index) {
          DataPointBase dataPoint = dataPointsList[index];
          return Column(
            children: [
              InkWell(
                onTap: () {
                  showBottomSheet(
                    context,
                    dataPoint,
                  );
                },
                child: SizedBox(
                    width: AppWidgetSize.screenWidth(context),
                    child: _buildContentRow(dataPoint)),
              ),
              Divider(
                thickness: 1,
                color: Theme.of(context).dividerColor,
              ),
              if (index == dataPointsList.length - 1)
                corporateactionDisclaimer(context)
            ],
          );
        },
      ),
    );
  }

  Widget _buildContentRow(DataPointBase dataPoint) {
    String? date;
    Widget iconWidget;
    if (service.getTypeAsString(dataPoint.type!) == AppConstants.bonus) {
      date = service.getProperties(dataPoint, 'bonusDte');
      iconWidget = AppImages.bonusIcon(
        context,
        width: AppWidgetSize.dimen_22,
        height: AppWidgetSize.dimen_22,
      );
    } else if (service.getTypeAsString(dataPoint.type!) ==
        AppConstants.rights) {
      date = service.getProperties(dataPoint, 'rightDte');
      iconWidget = AppImages.rightsIcon(
        context,
        width: AppWidgetSize.dimen_22,
        height: AppWidgetSize.dimen_22,
      );
    } else if (service.getTypeAsString(dataPoint.type!) ==
        AppConstants.splits) {
      date = service.getProperties(dataPoint, 'spltDte');
      iconWidget = AppImages.splitIcon(
        context,
        width: AppWidgetSize.dimen_22,
        height: AppWidgetSize.dimen_22,
      );
    } else {
      date = service.getProperties(dataPoint, 'divDate');
      iconWidget = AppImages.dividendIcon(
        context,
        width: AppWidgetSize.dimen_22,
        height: AppWidgetSize.dimen_22,
      );
    }
    return SizedBox(
      child: Stack(
        children: [
          SizedBox(
            width: AppWidgetSize.fullWidth(context) / 1.6,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: AppWidgetSize.dimen_5),
                  child: iconWidget,
                ),
                Container(
                  padding: EdgeInsets.only(top: AppWidgetSize.dimen_2),
                  width: AppWidgetSize.fullWidth(context) / 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.getTypeAsString(dataPoint.type!),
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: AppWidgetSize.dimen_5,
                        ),
                        child: Text(
                          service.getProperties(dataPoint, "desc"),
                          style: Theme.of(context)
                              .primaryTextTheme
                              .bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: AppWidgetSize.dimen_2,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  date!,
                  style:
                      Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                  textAlign: TextAlign.end,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_5,
                  ),
                  child: Row(
                    children: [
                      Text(
                        service.getTypeAsString(dataPoint.type!) ==
                                AppConstants.bonus
                            ? _appLocalizations.actionDate
                            : _appLocalizations.exDate,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .bodySmall!
                            .copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showBottomSheet(
                            context,
                            dataPoint,
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: AppWidgetSize.dimen_2,
                          ),
                          child: AppImages.downArrow(
                            context,
                            color: Theme.of(context).primaryIconTheme.color,
                            isColor: true,
                            width: AppWidgetSize.dimen_20,
                            height: AppWidgetSize.dimen_20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showBottomSheet(
    BuildContext context,
    DataPointBase dataPoint,
  ) async {
    showInfoBottomsheet(
      SafeArea(
        child: _buildBottomSheetContentWidget(
          context,
          dataPoint,
        ),
      ),
      horizontalMargin: false,
    );
  }

  Widget _buildBottomSheetContentWidget(
    BuildContext context,
    DataPointBase dataPoint,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_80,
              left: AppWidgetSize.dimen_32,
              right: AppWidgetSize.dimen_32,
              bottom: AppWidgetSize.dimen_15,
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getTableWidget(dataPoint),
                  if (service.getTypeAsString(dataPoint.type!) !=
                      AppConstants.dividend)
                    _buildRemarksWidget(dataPoint),
                  _buildDetailsWidget(dataPoint),
                ],
              ),
            ),
          ),
          Positioned(
            top: AppWidgetSize.dimen_15,
            left: 0,
            right: AppWidgetSize.dimen_32,
            child: Padding(
              padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_32,
                bottom: AppWidgetSize.dimen_20,
              ),
              child: _getBottomSheetHeaderWidget(
                service.getTypeAsString(dataPoint.type!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBottomSheetHeaderWidget(String title) {
    return Container(
      alignment: Alignment.center,
      width: AppWidgetSize.fullWidth(context) - AppWidgetSize.dimen_64,
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
              title,
              Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.left),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: AppImages.closeIcon(
              context,
              color: Theme.of(context).primaryIconTheme.color,
              isColor: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTableWidget(
    DataPointBase dataPoint,
  ) {
    if (service.getTypeAsString(dataPoint.type!) == AppConstants.bonus) {
      return _buildBonusTable(dataPoint);
    } else if (service.getTypeAsString(dataPoint.type!) ==
        AppConstants.rights) {
      return _buildRightsTable(dataPoint);
    } else if (service.getTypeAsString(dataPoint.type!) ==
        AppConstants.splits) {
      return _buildSplitsTable(dataPoint);
    } else {
      return _buildDividendTable(dataPoint);
    }
  }

  Widget _buildBonusTable(
    DataPointBase dataPoint,
  ) {
    return Wrap(
      children: [
        _getBottomSheetRow(
          _appLocalizations.annocementDate,
          service.getProperties(dataPoint, 'anncmntDate'),
        ),
        _getBottomSheetRow(
          _appLocalizations.recordDate,
          service.getProperties(dataPoint, 'recordDate'),
        ),
        _getBottomSheetRow(
          _appLocalizations.bonusDate,
          service.getProperties(dataPoint, 'bonusDte'),
        ),
        _getBottomSheetRow(
          _appLocalizations.bonusRatio,
          service.getProperties(dataPoint, 'ratio'),
        ),
      ],
    );
  }

  Widget _buildRightsTable(
    DataPointBase dataPoint,
  ) {
    return Wrap(
      children: [
        _getBottomSheetRow(
          _appLocalizations.annocementDate,
          service.getProperties(dataPoint, 'anncmntDate'),
        ),
        _getBottomSheetRow(
          _appLocalizations.recordDate,
          service.getProperties(dataPoint, 'recordDate'),
        ),
        _getBottomSheetRow(
          _appLocalizations.rightDate,
          service.getProperties(dataPoint, 'rightDte'),
        ),
        _getBottomSheetRow(
          _appLocalizations.rightsRatio,
          service.getProperties(dataPoint, 'rightRatio'),
        ),
        _getBottomSheetRow(
          _appLocalizations.premium,
          service.getProperties(dataPoint, 'premium'),
        ),
        _getBottomSheetRow(
          _appLocalizations.noDeliveryStartDate,
          service.getProperties(dataPoint, 'noStrtDte'),
        ),
        _getBottomSheetRow(
          _appLocalizations.noDeliveryEndDate,
          service.getProperties(dataPoint, 'noEmdDte'),
        ),
      ],
    );
  }

  Widget _buildSplitsTable(
    DataPointBase dataPoint,
  ) {
    return Wrap(
      children: [
        _getBottomSheetRow(
          _appLocalizations.annocementDate,
          service.getProperties(dataPoint, 'anncmntDate'),
        ),
        _getBottomSheetRow(
          _appLocalizations.splitDate,
          service.getProperties(dataPoint, 'spltDte'),
        ),
        _getBottomSheetRow(
          _appLocalizations.recordDate,
          service.getProperties(dataPoint, 'recordDate'),
        ),
        _getBottomSheetRow(
          _appLocalizations.faceValueBefore,
          service.getProperties(dataPoint, 'fvBefore'),
        ),
        _getBottomSheetRow(
          _appLocalizations.faceValueAfter,
          service.getProperties(dataPoint, 'fvAftr'),
        ),
        _getBottomSheetRow(
          _appLocalizations.splitRatio,
          service.getProperties(dataPoint, 'ratio'),
        ),
        _getBottomSheetRow(
          _appLocalizations.noDeliveryStartDate,
          service.getProperties(dataPoint, 'noStrtDte'),
        ),
        _getBottomSheetRow(
          _appLocalizations.noDeliveryEndDate,
          service.getProperties(dataPoint, 'noEmdDte'),
        ),
      ],
    );
  }

  Widget _buildDividendTable(
    DataPointBase dataPoint,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_20,
      ),
      child: Wrap(
        children: [
          _getBottomSheetRow(
            _appLocalizations.annocementDate,
            service.getProperties(dataPoint, 'anncmntDate'),
          ),
          _getBottomSheetRow(
            _appLocalizations.exDividendDate,
            service.getProperties(dataPoint, 'divDate'),
          ),
          _getBottomSheetRow(
            _appLocalizations.recordDate,
            service.getProperties(dataPoint, 'recordDate'),
          ),
          _getBottomSheetRow(
            _appLocalizations.dividendType,
            service.getProperties(dataPoint, 'divType'),
          ),
          _getBottomSheetRow(
            _appLocalizations.amount,
            service.getProperties(dataPoint, 'dividendAmnt'),
          ),
          _getBottomSheetRow(
            _appLocalizations.dividendPercent,
            service.getProperties(dataPoint, 'divPercent'),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarksWidget(
    DataPointBase dataPoint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_10,
            bottom: AppWidgetSize.dimen_10,
          ),
          child: CustomTextWidget(
            _appLocalizations.remarks,
            Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: AppWidgetSize.dimen_20,
          ),
          child: CustomTextWidget(
            service.getProperties(dataPoint, 'remark'),
            Theme.of(context).primaryTextTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsWidget(
    DataPointBase dataPoint,
  ) {
    return Wrap(
      children: [
        CustomTextWidget(
          _appLocalizations.details,
          Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_20,
            bottom: AppWidgetSize.dimen_20,
          ),
          child: CustomTextWidget(
            service.getProperties(dataPoint, 'desc'),
            Theme.of(context).primaryTextTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _getBottomSheetRow(String key, String value) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      margin: EdgeInsets.only(bottom: AppWidgetSize.dimen_10),
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_12,
        left: AppWidgetSize.dimen_15,
        right: AppWidgetSize.dimen_15,
        bottom: AppWidgetSize.dimen_12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
            key,
            Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          CustomTextWidget(
            value,
            Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          )
        ],
      ),
    );
  }

  void toggleButtonOnChanged(String data) {
    // print('data $data');
    setState(() {
      selectedFilter = data;
    });
  }
}
