import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../blocs/quote/analysis/quote_analysis_bloc.dart';
import '../../../blocs/quote/pivot_points/pivot_points_bloc.dart';
import '../../../blocs/quote/technical/technical_bloc.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/quote/quote_analysis/pivot_points_model.dart';
import '../../../models/quote/quote_analysis/technical_model.dart';
import '../../../models/quote/quote_analysis/volume_analysis_model.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/Swapbutton_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/technicalspivotstrategychart/technical_pivot_strategy_chart.dart';
import '../../widgets/toggle_circular_widget.dart';
import '../base/base_screen.dart';

class QuoteAnalysis extends BaseScreen {
  final dynamic arguments;
  const QuoteAnalysis({Key? key, this.arguments}) : super(key: key);

  @override
  State<QuoteAnalysis> createState() => _QuoteAnalysisState();
}

class _QuoteAnalysisState extends BaseAuthScreenState<QuoteAnalysis> {
  late AppLocalizations _appLocalizations;
  late final Symbols _symbols;

  late QuoteAnalysisBloc quoteAnalysisBloc;

  late TechnicalBloc quoteTechnicalBloc;

  late PivotPointsBloc _quotePivotpointsBloc;

  late dynamic mapvalue;
  int position = 0;

  @override
  void initState() {
    super.initState();
    _symbols = widget.arguments['symbolItem'];
    _symbols.sym!.baseSym = _symbols.baseSym;
    quoteTechnicalBloc = BlocProvider.of<TechnicalBloc>(context)
      ..add((QuoteTechnicalEvent(_symbols.sym)));
    _quotePivotpointsBloc = BlocProvider.of<PivotPointsBloc>(context)
      ..add((QuotePivotPointsEvent(_symbols.sym, 'daily')));

    quoteAnalysisBloc = BlocProvider.of<QuoteAnalysisBloc>(context)
      ..add((QuoteAnalysisVolumeAnalysis(_symbols.sym)))
      ..stream.listen(_quoteAnalysisListener);
  }

  Widget _volumeChartBarWidget(
      String? data, String? totaldata, num? total, String? title) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _volumeFractionalBoxWidget(data, totaldata!, total),
          _yAxisVolumeIntervalCustomTextWidget(title)
        ],
      ),
    );
  }

  late int periodPosition = 0;

  String dateFormaterFunction(date) {
    if (periodPosition == 0) {
      DateTime inputFormat = DateTime.parse('${date}01');
      DateFormat outputFormat = DateFormat("MMM ''yy");
      return outputFormat.format(inputFormat);
    } else {
      return date;
    }
  }

  Widget _volumeFractionalBoxWidget(
      String? data, String totalData, num? totalRevenue) {
    return SizedBox(
      width: 40.w,
      //   height: AppWidgetSize.dimen_300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            fit: StackFit.loose,
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                width: AppWidgetSize.dimen_12,
                height: _chartHeightCal(totalData, totalRevenue),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      color: 50 > 0
                          ? Theme.of(context).snackBarTheme.backgroundColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0.w),
                          topRight: Radius.circular(10.0.w),
                          bottomLeft: Radius.circular(10.0.w),
                          bottomRight: Radius.circular(10.0.w))),
                  width: 10.w,
                ),
              ),
              SizedBox(
                width: AppWidgetSize.dimen_8,
                height: _chartHeightCal(data, totalRevenue),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      color: 50 > 0
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0.w),
                          topRight: Radius.circular(10.0.w),
                          bottomLeft: Radius.circular(10.0.w),
                          bottomRight: Radius.circular(10.0.w))),
                  width: 10.w,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  double? _chartHeightCal(String? data, num? totalRevenue) {
    double s = (totalRevenue ?? 0) / (AppUtils().doubleValue(data));
    totalRevenue = 127 / s;

    return totalRevenue > 180 ? 180.w : totalRevenue.w;
  }

  Widget _yAxisVolumeIntervalCustomTextWidget(String? data) {
    return Container(
        height: AppWidgetSize.dimen_40,
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: CustomTextWidget(
          data.toString(),
          Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 10.w,
              ),
        ));
  }

  Future<void> _quoteAnalysisListener(QuoteAnalysisState state) async {
    if (state is QuoteAnalysisFailedState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state is QuoteAnalysisErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
      ),
      width: MediaQuery.of(context).size.width,
      child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(top: AppWidgetSize.dimen_16),
            child: _buildHeaderWidget(_appLocalizations.technical),
          ),
          BlocBuilder<TechnicalBloc, TechnicalState>(
            builder: (context, state) {
              if (state is QuoteTechnicalDoneState) {
                return Column(
                  children: [
                    _buildDivider(),
                    _buildTechnicalWidget(state.technical),
                  ],
                );
              }

              if (state is QuotetechnicalFailedState) {
                return errorWithImageWidget(
                  context: context,
                  imageWidget: AppImages.noDealsImage(context),
                  errorMessage: AppLocalizations().noDataAvailableErrorMessage,
                  padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_30,
                    right: AppWidgetSize.dimen_30,
                    bottom: AppWidgetSize.dimen_30,
                  ),
                );
              } else if (state is QuoteTechnicalServiceExceptionState ||
                  state is QuoteTechnicalErrorState) {
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

              if (state is QuoteTechnicalProgressState) {
                return SizedBox(
                    height: AppWidgetSize.screenHeight(context) * 0.2,
                    child: const LoaderWidget());
              }

              return Container();
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: AppWidgetSize.dimen_16),
            child: _buildHeaderWidget(_appLocalizations.movingAverages),
          ),
          BlocBuilder<TechnicalBloc, TechnicalState>(
            builder: (context, state) {
              if (state is QuoteTechnicalDoneState) {
                return Column(
                  children: [
                    _buildDivider(),
                    _buildTableWithBackgroundColor(state.technical)
                  ],
                );
              }

              if (state is QuotetechnicalFailedState) {
                return errorWithImageWidget(
                  context: context,
                  imageWidget: AppImages.noDealsImage(context),
                  errorMessage: AppLocalizations().noDataAvailableErrorMessage,
                  padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_30,
                    right: AppWidgetSize.dimen_30,
                    bottom: AppWidgetSize.dimen_30,
                  ),
                );
              } else if (state is QuoteTechnicalServiceExceptionState ||
                  state is QuoteTechnicalErrorState) {
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

              if (state is QuoteTechnicalProgressState) {
                return SizedBox(
                    height: AppWidgetSize.screenHeight(context) * 0.2,
                    child: const LoaderWidget());
              }

              return Container();
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: AppWidgetSize.dimen_16),
            child: _buildHeaderWidget(_appLocalizations.pivotsPoints),
          ),
          BlocBuilder<PivotPointsBloc, PivotPointsState>(
            buildWhen: (previous, current) =>
                (current is QuotePivotpointsProgressState) ||
                current is QuotePivotPointsDoneState ||
                current is QuotePivotPointsFailedState ||
                current is QuoteTechnicalErrorState ||
                current is QuotePivotPointsErrorState ||
                current is QuotePivotPointsServiceExceptionState,
            builder: (context, state) {
              if (state is QuotePivotPointsDoneState) {
                if (state.pivotPoints.keys?.isNotEmpty ?? false) {
                  return Column(
                    children: [
                      _buildDivider(),
                      _buildPivotView(pivotPoints: state.pivotPoints),
                    ],
                  );
                }
              }
              if (state is QuotePivotPointsFailedState ||
                  state is QuotePivotPointsErrorState) {
                return Column(
                  children: [
                    _buildDivider(),
                    _buildPivotView(errorMsg: state.errorMsg),
                  ],
                );
              } else if (state is QuotePivotPointsServiceExceptionState ||
                  state is QuoteTechnicalErrorState) {
                return Column(
                  children: [
                    _buildDivider(),
                    _buildPivotView(errorMsg: state.errorMsg),
                  ],
                );
              }

              if (state is QuotePivotpointsProgressState) {
                return SizedBox(
                    height: AppWidgetSize.screenHeight(context) * 0.35,
                    child: const LoaderWidget());
              }

              return SizedBox(
                  height: AppWidgetSize.screenHeight(context) * 0.35,
                  child: const LoaderWidget());
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: AppWidgetSize.dimen_16),
            child: _buildHeaderWidget(_appLocalizations.volumeAnalysis),
          ),
          BlocBuilder<QuoteAnalysisBloc, QuoteAnalysisState>(
            buildWhen: (previous, current) =>
                current is QuoteAnalysisVolumeanalysisProgressState ||
                current is QuoteAnalysisVolumeAnalysisDoneState ||
                current is QuoteAnalysisFailedState ||
                current is QuoteAnalysisErrorState ||
                current is QuoteAnalysisServiceExceptionState,
            builder: (context, state) {
              if (state is QuoteAnalysisVolumeAnalysisDoneState) {
                return Column(
                  children: [
                    _buildDivider(),
                    _buildVolumeDeliveryTitle(),
                    if (state.volumeAnalysis.chartdat
                            ?.where((element) => element.showData)
                            .toList()
                            .isNotEmpty ??
                        false)
                      _buildSelectedVolumeCard(state.volumeAnalysis),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0.w),
                      child: _buildVolumeChartWidget(state.volumeAnalysis),
                    ),
                    analysisDisclaimer()
                  ],
                );
              }
              if (state is QuoteAnalysisFailedState) {
                return errorWithImageWidget(
                  context: context,
                  imageWidget: AppImages.noDealsImage(context),
                  errorMessage: AppLocalizations().noDataAvailableErrorMessage,
                  padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_30,
                    right: AppWidgetSize.dimen_30,
                    bottom: AppWidgetSize.dimen_30,
                  ),
                );
              } else if (state is QuoteAnalysisServiceExceptionState ||
                  state is QuoteAnalysisErrorState) {
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

              if (state is QuoteAnalysisVolumeanalysisProgressState) {
                return SizedBox(
                    height: AppWidgetSize.screenHeight(context) * 0.2,
                    child: const LoaderWidget());
              }

              return Container();
            },
          )
        ],
      ),
    );
  }

  Column analysisDisclaimer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_5),
          child: CustomTextWidget(
            AppLocalizations().disclaimer,
            Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: AppWidgetSize.fontSize12),
          ),
        ),
        CustomTextWidget(
            AppLocalizations().disclaimerContent,
            Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontSize: AppWidgetSize.fontSize11)),
        Padding(
          padding: EdgeInsets.only(top: AppWidgetSize.dimen_7),
          child: CustomTextWidget(
              AppLocalizations().cmotsData,
              Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: AppWidgetSize.fontSize11)),
        )
      ],
    );
  }

  SizedBox _buildSelectedVolumeCard(VolumeAnalysis volumeAnalysis) {
    return SizedBox(
      height: AppWidgetSize.dimen_60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Card(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Container(
              width: 90.w,
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                      volumeAnalysis.chartdat
                              ?.where((element) => element.showData)
                              .toList()
                              .first
                              .title ??
                          "",
                      Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 10.w,
                          )),
                  Row(
                    children: [
                      Icon(Icons.circle,
                          size: 5.w,
                          color:
                              Theme.of(context).snackBarTheme.backgroundColor),
                      Padding(
                          padding: EdgeInsets.only(left: 4.0.w),
                          child: CustomTextWidget(
                            NumberFormat.compactCurrency(
                                    symbol: '',
                                    decimalDigits: 2,
                                    locale: 'en_IN')
                                .format(volumeAnalysis.chartdat
                                        ?.where((element) => element.showData)
                                        .toList()
                                        .first
                                        .totalVolume ??
                                    0),
                            Theme.of(context)
                                .primaryTextTheme
                                .titleSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10.w,
                                ),
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.circle,
                          size: 5.w, color: Theme.of(context).primaryColor),
                      Padding(
                        padding: EdgeInsets.only(left: 4.0.w),
                        child: CustomTextWidget(
                            NumberFormat.compactCurrency(
                                    symbol: '',
                                    decimalDigits: 2,
                                    locale: 'en_IN')
                                .format(volumeAnalysis.chartdat
                                    ?.where((element) => element.showData)
                                    .toList()
                                    .first
                                    .volume)
                                .toString(),
                            Theme.of(context)
                                .primaryTextTheme
                                .titleSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10.w,
                                )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row _buildVolumeDeliveryTitle() {
    return Row(
      children: [
        CustomTextWidget(
          AppLocalizations().totalVolume,
          Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 10.w,
              ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 4.0.w),
          child: Icon(Icons.circle,
              size: 5.w,
              color: Theme.of(context).snackBarTheme.backgroundColor),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10.0.w),
          child: CustomTextWidget(
              AppLocalizations().delivery,
              Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 10.w,
                  )),
        ),
        Padding(
            padding: EdgeInsets.only(left: 4.0.w),
            child: Icon(Icons.circle,
                size: 5.w, color: Theme.of(context).primaryColor)),
      ],
    );
  }

  Widget _buildVolumeChartWidget(VolumeAnalysis volumeAnalysis) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 40.w),
          height: _chartHeightCal(
              volumeAnalysis.chartdat
                  ?.reduce((a, b) {
                    if (a.totalVolume > b.totalVolume) {
                      return a;
                    } else {
                      return b;
                    }
                  })
                  .totalVolume
                  .toString(),
              volumeAnalysis.chartdat?.reduce((a, b) {
                if (a.totalVolume > b.totalVolume) {
                  return a;
                } else {
                  return b;
                }
              }).totalVolume),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i <= 4; i++)
                CustomTextWidget(
                    NumberFormat.compactCurrency(
                            symbol: '', decimalDigits: 2, locale: 'en_IN')
                        .format((((volumeAnalysis.chartdat?.reduce((a, b) {
                                  if (a.totalVolume > b.totalVolume) {
                                    return a;
                                  } else {
                                    return b;
                                  }
                                }).totalVolume) ??
                                0 / 4) *
                            (1 / (i + 1)))),
                    Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 10.w,
                        )),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0;
                      i < (volumeAnalysis.chartdat?.length ?? 0);
                      i++)
                    InkWell(
                      onTap: () {
                        setState(
                          () {
                            for (int j = 0;
                                j < (volumeAnalysis.chartdat?.length ?? 0);
                                j++) {
                              if (i == j) {
                                volumeAnalysis.chartdat![j].showData = true;
                              } else {
                                volumeAnalysis.chartdat![j].showData = false;
                              }
                            }
                          },
                        );
                      },
                      child: _volumeChartBarWidget(
                          volumeAnalysis.chartdat![i].volume.toString(),
                          volumeAnalysis.chartdat![i].totalVolume.toString(),
                          volumeAnalysis.chartdat?.reduce((a, b) {
                            if (a.totalVolume > b.totalVolume) {
                              return a;
                            } else {
                              return b;
                            }
                          }).totalVolume,
                          volumeAnalysis.chartdat![i].title),
                    ),
                ]),
          ),
        )
      ],
    );
  }

  Widget toggleCircularWidget() {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20)),
        child: Padding(
            padding: EdgeInsets.all(AppWidgetSize.dimen_2),
            child: ToggleCircularWidget(
                key: const Key(''),
                height: AppWidgetSize.dimen_36,
                minWidth: AppWidgetSize.fullWidth(context) / 2.5,
                cornerRadius: AppWidgetSize.dimen_20,
                activeBgColor:
                    Theme.of(context).primaryTextTheme.displayLarge!.color,
                activeTextColor: Theme.of(context).colorScheme.secondary,
                inactiveBgColor:
                    Theme.of(context).snackBarTheme.backgroundColor,
                inactiveTextColor:
                    Theme.of(context).primaryTextTheme.displayLarge!.color,
                labels: <String>[
                  _appLocalizations.intraDay,
                  _appLocalizations.weekly,
                  _appLocalizations.monthly,
                ],
                initialLabel: position,
                isBadgeWidget: false,
                activeTextStyle: Theme.of(context)
                    .primaryTextTheme
                    .bodyLarge!
                    .copyWith(fontSize: AppWidgetSize.fontSize16),
                inactiveTextStyle: Theme.of(context)
                    .inputDecorationTheme
                    .labelStyle!
                    .copyWith(fontSize: AppWidgetSize.fontSize16),
                onToggle: toggleChange)));
  }

  Column _buildPivotView({PivotPoints? pivotPoints, String? errorMsg}) {
    return Column(
      children: [
        toggleCircularWidget(),
        if (pivotPoints != null)
          Stack(
            alignment: Alignment.center,
            fit: StackFit.passthrough,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 150, top: 50),
                height: AppWidgetSize.dimen_220,
                width: AppWidgetSize.dimen_220,
                child: TechnicalPivotStrategyChart(
                  themeData: Theme.of(context),
                  colormapObj: <Color>[
                    AppColors().positiveColor,
                    AppColors.negativeColor
                  ],
                  list: pivotPoints.keys,
                  valueToBeHighlighted: _symbols.ltp.toString(),
                  valuesList: pivotPoints.values,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 180.w),
                child: Column(
                  children: [
                    Table(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TableRow(
                          children: [
                            _buildTableCellWithBackgroundColor(
                              'Pivot',
                              pivotPoints.values!["Pivot"] ?? '',
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildPivotWidget(_symbols, pivotPoints)
                  ],
                ),
              ),
            ],
          )
        else
          errorWithImageWidget(
            context: context,
            imageWidget: AppUtils().getNoDateImageErrorWidget(context),
            errorMessage:
                errorMsg ?? AppLocalizations().noDataAvailableErrorMessage,
            padding: EdgeInsets.only(
              top: 20.w,
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
              bottom: AppWidgetSize.dimen_30,
            ),
          )
      ],
    );
  }

  ValueNotifier<bool> technicalConsolidated = ValueNotifier<bool>(true);
  ValueNotifier<bool> volumeConsolidated = ValueNotifier<bool>(true);
  Widget _buildHeaderWidget(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CustomTextWidget(
              title,
              Theme.of(context).primaryTextTheme.titleSmall,
              // Theme.of(context).textTheme.headline2,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_6,
                left: AppWidgetSize.dimen_5,
              ),
              child: title == _appLocalizations.volumeAnalysis
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: () {
                        if (title == _appLocalizations.technical) {
                          technicalSheet();
                        }
                        if (title == _appLocalizations.movingAverages) {
                          movingAverageSheet();
                        }
                        if (title == _appLocalizations.pivotsPoints) {
                          pivotPointsSheet();
                        }
                      },
                      child: AppImages.informationIcon(
                        context,
                        color: Theme.of(context).primaryIconTheme.color,
                        isColor: true,
                        width: AppWidgetSize.dimen_22,
                        height: AppWidgetSize.dimen_22,
                      ),
                    ),
            ),
          ],
        ),
        if (_appLocalizations.technical == title)
          ValueListenableBuilder<bool>(
              valueListenable: technicalConsolidated,
              builder: (context, snapshot, _) {
                return SwappingWidget.drop(
                  value: technicalConsolidated,
                  onTap: () {
                    technicalConsolidated.value = !technicalConsolidated.value;
                    quoteTechnicalBloc.add(QuoteTechnicalEvent(_symbols.sym)
                      ..consolidated = technicalConsolidated.value);
                  },
                );
              }),
        if (_appLocalizations.volumeAnalysis == title)
          ValueListenableBuilder<bool>(
              valueListenable: volumeConsolidated,
              builder: (context, snapshot, _) {
                return SwappingWidget.drop(
                  value: volumeConsolidated,
                  onTap: () {
                    volumeConsolidated.value = !volumeConsolidated.value;
                    quoteAnalysisBloc.add(
                        (QuoteAnalysisVolumeAnalysis(_symbols.sym))
                          ..consolidated = volumeConsolidated.value);
                  },
                );
              }),
      ],
    );
  }

  Widget _buildExpansionRowForBottomSheet(
      BuildContext context, String title, String description,
      {bool initallyExpanded = false}) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_5,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initallyExpanded,
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: AppWidgetSize.dimen_5,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
              title,
              title == "RSI"
                  ? Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(color: Theme.of(context).primaryColor)
                  : Theme.of(context).textTheme.displaySmall),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              description,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionDescriptionRowForBottomSheet(
    BuildContext context,
    String title,
    String description,
    String titledescription1,
    String description1,
    String titledescription2,
    String description2,
    String description3,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_5,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          // initiallyExpanded:  false,
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: AppWidgetSize.dimen_5,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
            title,
            title == "MACD"
                ? Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(color: Theme.of(context).primaryColor)
                : Theme.of(context).textTheme.displaySmall,
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            CustomTextWidget(
              description,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: EdgeInsets.only(
                  //       top: AppWidgetSize.dimen_8,
                  //       right: AppWidgetSize.dimen_8),
                  //   child: Icon(Icons.circle,
                  //       size: AppWidgetSize.dimen_6,
                  //       color: Theme.of(context).textTheme.headline6?.color ??
                  //           Colors.black),
                  // ),
                  Expanded(
                    child: RichText(
                      // maxLines: 2,
                      text: TextSpan(
                        text: "$titledescription1 ",
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontWeight: FontWeight.w600),
                        children: <TextSpan>[
                          TextSpan(
                            text: description1,
                            style:
                                Theme.of(context).primaryTextTheme.labelSmall,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: EdgeInsets.only(
                  //       top: AppWidgetSize.dimen_8,
                  //       right: AppWidgetSize.dimen_8),
                  //   child: Icon(Icons.circle,
                  //       size: AppWidgetSize.dimen_6,
                  //       color: Theme.of(context).textTheme.headline6?.color ??
                  //           Colors.black),
                  // ),
                  Expanded(
                    child: RichText(
                      // maxLines: 2,
                      text: TextSpan(
                        text: '$titledescription2 ',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        children: <TextSpan>[
                          TextSpan(
                            text: description2,
                            style:
                                Theme.of(context).primaryTextTheme.labelSmall,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.only(
            //       top: AppWidgetSize.dimen_10, left: AppWidgetSize.dimen_10),
            //   child: RichText(
            //     text: TextSpan(
            //       text: '. ',
            //       style: Theme.of(context).primaryTextTheme.overline!.copyWith(
            //           fontWeight: FontWeight.w500,
            //           fontSize: AppWidgetSize.dimen_30),
            //       children: <TextSpan>[
            //         TextSpan(
            //           text: titledescription2 + ' ',
            //           style:
            //               Theme.of(context).primaryTextTheme.overline!.copyWith(
            //                     fontWeight: FontWeight.w500,
            //                   ),
            //         ),
            //         TextSpan(
            //           text: description2,
            //           style: Theme.of(context).primaryTextTheme.overline,
            //         )
            //       ],
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CustomTextWidget(
                description3,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
          ],
          // CustomTextWidget(
          //   description3,
          //   Theme.of(context).primaryTextTheme.overline,
          // ),
        ),
      ),
    );
  }

  Future<void> technicalSheet() async {
    showInfoBottomsheet(
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Technical',
                style: Theme.of(context).textTheme.displaySmall,
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
          Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_8,
            ),
            child: Text('Popular indicators used in technical analysis.',
                textAlign: TextAlign.justify,
                style: Theme.of(context).primaryTextTheme.labelSmall),
          ),
          Divider(
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildExpansionRowForBottomSheet1(
                  //   context,
                  //   "Technical",
                  //   "Popular indicators used in technical analysis.",
                  // ),
                  _buildExpansionRowForBottomSheet(context, "RSI",
                      "Relative Strength Index (RSI) is a momentum indicator that measures the magnitude of recent price changes to analyze overbought or oversold conditions. RSI oscillates between zero and 100, and generally an RSI of more than 70 indicates the stock is overbought, RSI below 30 indicates the stock is oversold.",
                      initallyExpanded: true),
                  _buildExpansionDescriptionRowForBottomSheet(
                    context,
                    "MACD",
                    "Moving Average Convergence/Divergence or MACD is a trend-following momentum indicator that shows the relationship between two moving averages of a security’s price. It is used by traders to determine the momentum of a stock.",
                    "MACD 12,26",
                    "is the difference between a 26-day and 12-day exponential moving average.",
                    "MACD 12,26,9",
                    'indicator also includes a 9-day exponential moving average called the "signal".',
                    "The MACD proves most effective in wide-swinging trading markets. There are three popular ways to use the MACD: crossovers, overbought/oversold conditions, and divergences.",
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> movingAverageSheet() async {
    showInfoBottomsheet(
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Moving Averages",
                style: Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
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
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   "Moving Averages",
                  //   style: Theme.of(context)
                  //       .primaryTextTheme
                  //       .subtitle2!
                  //       .copyWith(
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  // ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "A moving average is the average price of a stock over a set period of time. It's a"
                    ' "moving"'
                    " average because as new prices are made, the older data is dropped, and the newest data replaces it. They are used by traders to identify the trend direction of a stock or to determine its support and resistance levels.",
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                      "Investors commonly use two different types of moving averages:",
                      style: Theme.of(context).primaryTextTheme.labelSmall,
                      textAlign: TextAlign.justify),
                  /*     Padding(
                            padding: EdgeInsets.only(
                                top: AppWidgetSize.dimen_16,
                                right: AppWidgetSize.dimen_8),
                            child: Icon(Icons.circle,
                                size: AppWidgetSize.dimen_6,
                                color: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        ?.color ??
                                    Colors.black),
                          ), */
                  Padding(
                    padding: EdgeInsets.only(
                      top: AppWidgetSize.dimen_16,
                    ),
                    child: RichText(
                      // maxLines: 2,
                      text: TextSpan(
                        text: 'Simple Moving Average ',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelSmall!
                            .copyWith(fontWeight: FontWeight.w600),
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                'or SMA is calculated as the sum of the prices divided by the number of days.',
                            style:
                                Theme.of(context).primaryTextTheme.labelSmall,
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: AppWidgetSize.dimen_10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: EdgeInsets.only(
                        //       top: AppWidgetSize.dimen_16,
                        //       right: AppWidgetSize.dimen_8),
                        //   child: Icon(Icons.circle,
                        //       size: AppWidgetSize.dimen_6,
                        //       color: Theme.of(context)
                        //               .textTheme
                        //               .headline6
                        //               ?.color ??
                        //           Colors.black),
                        // ),
                        Expanded(
                          child: RichText(
                            // maxLines: 2,
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                              text: 'Exponential Moving Average ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.w600),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      'or EMA is a weighted moving average, where higher weight is given to more recent prices.',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "💡EMA reacts more quickly to price fluctuations than SMA. Because of this, the EMA gives out a signal of trend reversal sooner than an SMA does.",
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Both SMA and EMA are calculated for a time period. E.g.",
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                    textAlign: TextAlign.justify,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: AppWidgetSize.dimen_10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: EdgeInsets.only(
                        //       top: AppWidgetSize.dimen_16,
                        //       right: AppWidgetSize.dimen_8),
                        //   child: Icon(Icons.circle,
                        //       size: AppWidgetSize.dimen_6,
                        //       color: Theme.of(context)
                        //               .textTheme
                        //               .headline6
                        //               ?.color ??
                        //           Colors.black),
                        // ),
                        Expanded(
                          child: RichText(
                            textAlign: TextAlign.justify,
                            // maxLines: 2,
                            text: TextSpan(
                              text: 'EMA 20: ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.w600),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Exponential Moving Average for the last 20 days.',
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                    textAlign: TextAlign.justify,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: AppWidgetSize.dimen_10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: EdgeInsets.only(
                        //       top: AppWidgetSize.dimen_16,
                        //       right: AppWidgetSize.dimen_8),
                        //   child: Icon(Icons.circle,
                        //       size: AppWidgetSize.dimen_6,
                        //       color: Theme.of(context)
                        //               .textTheme
                        //               .headline6
                        //               ?.color ??
                        //           Colors.black),
                        // ),
                        Expanded(
                          child: RichText(
                            textAlign: TextAlign.justify,
                            // maxLines: 2,
                            text: TextSpan(
                              text: 'SMA 10: ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.w600),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Simple Moving Average for the last 10 days.',
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                  // RichText(
                  //   text: TextSpan(
                  //       text: ".",
                  //       style: Theme.of(context).primaryTextTheme.overline,
                  //       children: [
                  //         TextSpan(
                  //           text: "EMA 20 ",
                  //           style: Theme.of(context).primaryTextTheme.button,
                  //         ),
                  //         TextSpan(
                  //           text:
                  //               "Exponential Moving Average for the last 20 days ",
                  //         )
                  //       ]),
                  // ),
                  // RichText(
                  //   text: TextSpan(
                  //       text: ".",
                  //       style: Theme.of(context).primaryTextTheme.overline,
                  //       children: [
                  //         TextSpan(
                  //           text: "SMA 10: ",
                  //           style: Theme.of(context).primaryTextTheme.button,
                  //         ),
                  //         TextSpan(
                  //             text:
                  //                 "Simple Moving Average for the last 10 days.")
                  //       ]),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pivotPointsSheet() async {
    showInfoBottomsheet(
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: AppWidgetSize.dimen_8,
                ),
                child: Text(
                  "Pivot Points",
                  style:
                      Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Pivot points are intraday technical indicators used to identify trends and reversals in the markets. They are calculated to determine levels at which the sentiment of the market could change from bullish to bearish, and vice-versa. Day traders calculate pivot points to determine levels of entry, stops, and profit-taking.",
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "If the prices are trading below pivot levels, the traders usually look at it as a negative bias (bearish sentiment).",
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                    textAlign: TextAlign.justify,
                  ),
                  Text(
                    "If the prices are sustaining above pivot levels, then this shows a positive bias (bullish sentiment).",
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Pivot point is usually considered as a center point where support and resistance act as the floor and ceiling.",
                    style: Theme.of(context)
                        .primaryTextTheme
                        .labelSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Support",
                    style:
                        Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: AppWidgetSize.dimen_10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: EdgeInsets.only(
                        //       top: AppWidgetSize.dimen_16,
                        //       right: AppWidgetSize.dimen_8),
                        //   child: Icon(Icons.circle,
                        //       size: AppWidgetSize.dimen_6,
                        //       color: Theme.of(context)
                        //               .textTheme
                        //               .headline6
                        //               ?.color ??
                        //           Colors.black),
                        // ),
                        Expanded(
                          child: RichText(
                            textAlign: TextAlign.justify,
                            // maxLines: 2,
                            text: TextSpan(
                              text: 'S1: ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.w500),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      'Support 1 is the price below which the stock price is not expected to fall.',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: AppWidgetSize.dimen_10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: EdgeInsets.only(
                        //       top: AppWidgetSize.dimen_16,
                        //       right: AppWidgetSize.dimen_8),
                        //   child: Icon(Icons.circle,
                        //       size: AppWidgetSize.dimen_6,
                        //       color: Theme.of(context)
                        //               .textTheme
                        //               .headline6
                        //               ?.color ??
                        //           Colors.black),
                        // ),
                        Expanded(
                          child: RichText(
                            textAlign: TextAlign.justify,
                            // maxLines: 2,
                            text: TextSpan(
                              text: 'S2: ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.w500),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      'Support 2 is the next level where the stock price is expected to bounce back if it has breached support level 1.',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: AppWidgetSize.dimen_10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: EdgeInsets.only(
                        //       top: AppWidgetSize.dimen_16,
                        //       right: AppWidgetSize.dimen_8),
                        //   child: Icon(Icons.circle,
                        //       size: AppWidgetSize.dimen_6,
                        //       color: Theme.of(context)
                        //               .textTheme
                        //               .headline6
                        //               ?.color ??
                        //           Colors.black),
                        // ),
                        Expanded(
                          child: RichText(
                            // maxLines: 2,
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                              text: 'S3: ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.w500),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      'Support 3 is the next level (after S2) where high demand is expected, making the stock price reverse its plunge.',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
                    child: Text(
                      "💡If the stock breaches one support level, then it usually approaches the next support level, the level which gets breached automatically becomes the resistance. Eg: When S1 gets breached, S2 becomes the support, and S1 becomes the new Resistance ",
                      style: Theme.of(context).primaryTextTheme.labelSmall,
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  Text(
                    "Resistance:",
                    style:
                        Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: AppWidgetSize.dimen_10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: EdgeInsets.only(
                        //       top: AppWidgetSize.dimen_16,
                        //       right: AppWidgetSize.dimen_8),
                        //   child: Icon(Icons.circle,
                        //       size: AppWidgetSize.dimen_6,
                        //       color: Theme.of(context)
                        //               .textTheme
                        //               .headline6
                        //               ?.color ??
                        //           Colors.black),
                        // ),
                        Expanded(
                          child: RichText(
                            // maxLines: 2,
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                              text: 'R1: ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.w500),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      'Resistance 1 is the ceiling price, above which the stock price is not expected to trade.',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: AppWidgetSize.dimen_10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: EdgeInsets.only(
                        //       top: AppWidgetSize.dimen_16,
                        //       right: AppWidgetSize.dimen_8),
                        //   child: Icon(Icons.circle,
                        //       size: AppWidgetSize.dimen_6,
                        //       color: Theme.of(context)
                        //               .textTheme
                        //               .headline6
                        //               ?.color ??
                        //           Colors.black),
                        // ),
                        Expanded(
                          child: RichText(
                            // maxLines: 2,
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                              text: 'R2: ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.w500),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      'Resistance 2 becomes the new ceiling where the stock is expected to start its downward trend in case the stock breaks out from R1.',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: AppWidgetSize.dimen_10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: EdgeInsets.only(
                        //       top: AppWidgetSize.dimen_16,
                        //       right: AppWidgetSize.dimen_8),
                        //   child: Icon(Icons.circle,
                        //       size: AppWidgetSize.dimen_6,
                        //       color: Theme.of(context)
                        //               .textTheme
                        //               .headline6
                        //               ?.color ??
                        //           Colors.black),
                        // ),
                        Expanded(
                          child: RichText(
                            textAlign: TextAlign.justify,
                            // maxLines: 2,
                            text: TextSpan(
                              text: 'R3: ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.w500),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      'Resistance 3 is the next level, where high supply may get created putting downward pressure on the stock’s price.',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: AppWidgetSize.dimen_10,
                        bottom: AppWidgetSize.dimen_8),
                    child: Text(
                      "💡If the stock breaks out from one resistance level, then it is expected that the stock will approach the next resistance level, and the previous resistance automatically becomes the support.",
                      style: Theme.of(context).primaryTextTheme.labelSmall,
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
      ),
      child: Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
    );
  }

  Widget _buildTechnicalWidget(Technical technical) {
    return Container(
      padding: EdgeInsets.only(
          bottom: AppWidgetSize.dimen_5,
          top: AppWidgetSize.dimen_5,
          left: AppWidgetSize.dimen_5,
          right: AppWidgetSize.dimen_5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _appLocalizations.indicator,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              Text(
                _appLocalizations.value,
                textAlign: TextAlign.center,
                style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(
              bottom: AppWidgetSize.dimen_5,
              top: AppWidgetSize.dimen_5,
            ),
            padding: EdgeInsets.all(
              AppWidgetSize.dimen_5,
            ),
            color: Theme.of(context).colorScheme.background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _appLocalizations.rsi,
                  textAlign: TextAlign.center,
                  style:
                      Theme.of(context).primaryTextTheme.labelSmall!.copyWith(),
                ),
                Text(
                  technical.rsi.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              bottom: AppWidgetSize.dimen_5,
              top: AppWidgetSize.dimen_5,
            ),
            padding: EdgeInsets.all(
              AppWidgetSize.dimen_5,
            ),
            color: Theme.of(context).colorScheme.background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _appLocalizations.macd12269,
                  textAlign: TextAlign.center,
                  style:
                      Theme.of(context).primaryTextTheme.labelSmall!.copyWith(),
                ),
                Text(
                  technical.macd12269.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              bottom: AppWidgetSize.dimen_5,
              top: AppWidgetSize.dimen_5,
            ),
            padding: EdgeInsets.all(
              AppWidgetSize.dimen_5,
            ),
            color: Theme.of(context).colorScheme.background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _appLocalizations.macd1226,
                  textAlign: TextAlign.center,
                  style:
                      Theme.of(context).primaryTextTheme.labelSmall!.copyWith(),
                ),
                Text(
                  technical.macd1226.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableWithBackgroundColor(Technical technical) {
    List<Widget> widgetRowOne = [
      _buildTableCellWithBackgroundColor(
        _appLocalizations.ema10,
        technical.ema10.toString(),
      ),
      _buildTableCellWithBackgroundColor(
          _appLocalizations.ema20, technical.ema20.toString(),
          isMiddle: true),
      _buildTableCellWithBackgroundColor(
        _appLocalizations.ema50,
        technical.ema50.toString(),
      ),
    ];
    List<Widget> widgetRowTwo = [
      _buildTableCellWithBackgroundColor(
        _appLocalizations.sma10,
        technical.sma10.toString(),
      ),
      _buildTableCellWithBackgroundColor(
          _appLocalizations.sma20, technical.sma20.toString(),
          isMiddle: true),
      _buildTableCellWithBackgroundColor(
        _appLocalizations.sma50,
        technical.sma50.toString(),
      ),
    ];
    List<Widget> widgetRowThree = [
      _buildTableCellWithBackgroundColor(
        _appLocalizations.sma100,
        technical.sma100.toString(),
      ),
      _buildTableCellWithBackgroundColor(
          _appLocalizations.sma200, technical.sma200.toString(),
          isMiddle: true),
      _buildTableCellWithBackgroundColor(
        '',
        '',
      ),
    ];
    return Table(
      children: <TableRow>[
        TableRow(children: widgetRowOne),
        TableRow(children: widgetRowTwo),
        TableRow(children: widgetRowThree),
      ],
    );
  }

  TableCell _buildTableCellWithBackgroundColor(
    String key,
    String value, {
    bool isMiddle = false,
  }) {
    return TableCell(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: AppWidgetSize.dimen_5,
          left: isMiddle ? AppWidgetSize.dimen_10 : 0,
          right: isMiddle ? AppWidgetSize.dimen_10 : 10,
          top: AppWidgetSize.dimen_5,
        ),
        child: Container(
          padding: EdgeInsets.only(
            bottom: AppWidgetSize.dimen_5,
            top: AppWidgetSize.dimen_5,
          ),
          color: key != '' ? Theme.of(context).colorScheme.background : null,
          child: SizedBox(
            width: AppWidgetSize.halfWidth(context),
            child: Column(
              children: [
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style:
                      Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                ),
                Text(
                  key,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPivotWidget(Symbols symbolItem, PivotPoints pivotPoints) {
    return SizedBox(
      child: Column(
        children: [
          _buildTwoTableWithBackgroundColor(
            'S1',
            pivotPoints.values!["S1"].toString(),
            'R1',
            pivotPoints.values!["R1"].toString(),
          ),
          _buildTwoTableWithBackgroundColor(
            'S2',
            pivotPoints.values!["S2"].toString(),
            'R2',
            pivotPoints.values!["R2"].toString(),
          ),
          _buildTwoTableWithBackgroundColor(
            'S3',
            pivotPoints.values!["S3"].toString(),
            'R3',
            pivotPoints.values!["R3"].toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoTableWithBackgroundColor(
    String tableCell1Key,
    String tableCell1Value,
    String tableCell2Key,
    String tableCell2Value,
  ) {
    return SizedBox(
      width: AppWidgetSize.fullWidth(context),
      child: Table(
        children: <TableRow>[
          TableRow(
            children: <TableCell>[
              _buildTableCellWithBackgroundColor(
                tableCell1Key,
                tableCell1Value,
              ),
              _buildTableCellWithBackgroundColor(
                tableCell2Key,
                tableCell2Value,
                isMiddle: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool toggleChange(int boolPosition) {
    position = boolPosition;
    if (boolPosition == 0) {
      _quotePivotpointsBloc.add((QuotePivotPointsEvent(_symbols.sym, 'daily')));
    } else if (boolPosition == 1) {
      _quotePivotpointsBloc
          .add((QuotePivotPointsEvent(_symbols.sym, 'weekly')));
    } else {
      _quotePivotpointsBloc
          .add((QuotePivotPointsEvent(_symbols.sym, 'monthly')));
    }
    return true;
  }
}
