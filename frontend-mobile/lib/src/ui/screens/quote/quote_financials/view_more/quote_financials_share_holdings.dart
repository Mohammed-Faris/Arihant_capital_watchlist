import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/quote/financials/financials_view_more/financials_view_more_bloc.dart';
import '../../../../../data/store/app_utils.dart';
import '../../../../../localization/app_localization.dart';
import '../../../../../models/common/symbols_model.dart';
import '../../../../../models/quote/quote_financials/quote_financials_view_more/quote_financials_share_holidings_data.dart';
import '../../../../../models/quote/quote_financials/quote_financials_view_more/quote_financials_share_holidings_model.dart';
import '../../../../../notifiers/notifiers.dart';
import '../../../../styles/app_images.dart';
import '../../../../styles/app_widget_size.dart';
import '../../../../widgets/error_image_widget.dart';
import '../../../../widgets/loader_widget.dart';
import '../../../base/base_screen.dart';

class QuoteFinancialsShareHoldings extends BaseScreen {
  final dynamic arguments;
  const QuoteFinancialsShareHoldings({Key? key, this.arguments})
      : super(key: key);

  @override
  State<QuoteFinancialsShareHoldings> createState() =>
      _QuoteFinancialsShareHoldingsState();
}

class _QuoteFinancialsShareHoldingsState
    extends BaseAuthScreenState<QuoteFinancialsShareHoldings> {
  late AppLocalizations _appLocalizations;
  late Symbols _symbols = Symbols();
  late FinancialsViewMoreBloc _financialsViewMoreBloc;
  late FinancialsShareHoldings _financialsShareHoldings;
  late List<ShareHoldDta>? shareHoldDta;
  final ScrollController _contentController = ScrollController();
  late final SelectFilterNotifier _filterNotifier = SelectFilterNotifier(0);
  int filterPosition = 0;
  int viewPosition = 0;

  @override
  void initState() {
    super.initState();
    _symbols = widget.arguments['symbolItem'];
    _financialsViewMoreBloc = BlocProvider.of<FinancialsViewMoreBloc>(context)
      ..add((ViewMoreShareHoldingEvent(
          QuoteFinancialsShareHoldingsData(sym: _symbols.sym))))
      ..stream.listen(_quoteShareHoldingListener);
  }

  @override
  void didUpdateWidget(QuoteFinancialsShareHoldings oldWidget) {
    _symbols = widget.arguments['symbolItem'];
    _financialsViewMoreBloc = BlocProvider.of<FinancialsViewMoreBloc>(context)
      ..add((ViewMoreShareHoldingEvent(
          QuoteFinancialsShareHoldingsData(sym: _symbols.sym))
        ..consolidated = widget.arguments["consolidated"]))
      ..stream.listen(_quoteShareHoldingListener);

    super.didUpdateWidget(oldWidget);
  }

  Future<void> _quoteShareHoldingListener(FinancialsViewMoreState state) async {
    if (state is FinancialsViewMoreProgressState) {}
    if (state is FinancialsShareHoldingsDoneState) {
    } else if (state is FinancialsViewMoreFailedState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state is FinancialsViewMoreErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: BlocBuilder<FinancialsViewMoreBloc, FinancialsViewMoreState>(
        bloc: _financialsViewMoreBloc,
        builder: (context, state) {
          if (state is FinancialsViewMoreProgressState) {
            return const LoaderWidget();
          }
          if (state is FinancialsShareHoldingsDoneState) {
            _financialsShareHoldings = state.financialsShareHoldings;
            shareHoldDta = _financialsShareHoldings.shareHoldDta;
            currentPostion = 0;
            return _buildShareHoldingView();
          }
          if (state is FinancialsServiceExceptionState) {
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
          return errorWithImageWidget(
            context: context,
            height: AppWidgetSize.dimen_250,
            imageWidget: AppUtils().getNoDateImageErrorWidget(context),
            errorMessage: AppLocalizations().noDataAvailableErrorMessage,
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
              bottom: AppWidgetSize.dimen_30,
            ),
          );
        },
      ),
    );
  }

  Widget _buildShareHoldingView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildYearsPeriod(),
          _buildShareHoldingsWidget(_appLocalizations),
        ],
      ),
    );
  }

  double currentPostion = 0;

  Widget _buildYearsPeriod() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: SizedBox(
        height: AppWidgetSize.dimen_40,
        child: ValueListenableBuilder(
            valueListenable: _filterNotifier,
            builder: (BuildContext context, dynamic value, Widget? child) {
              return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AbsorbPointer(
                    absorbing: value <= 0,
                    child: GestureDetector(
                        onTap: () {
                          currentPostion = currentPostion -
                              (((AppWidgetSize.screenWidth(context) / 1.5) -
                                      (AppWidgetSize.dimen_80)) /
                                  2);
                          _contentController.jumpTo(currentPostion);

                          _filterNotifier.changeFilterPosition(value - 1);

                          viewPosition--;
                        },
                        child: value <= 0
                            ? AppImages.leftSwipeDisabledIcon(
                                context,
                                isColor: true,
                                color: Theme.of(context).primaryIconTheme.color,
                                width: AppWidgetSize.dimen_22,
                                height: AppWidgetSize.dimen_22,
                              )
                            : AppImages.leftSwipeEnabledIcon(
                                context,
                                isColor: true,
                                color: Theme.of(context).primaryIconTheme.color,
                                width: AppWidgetSize.dimen_22,
                                height: AppWidgetSize.dimen_22,
                              )),
                  ),
                ),
                _buildTimePeriodFilterList(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AbsorbPointer(
                      absorbing: value >= shareHoldDta!.length - 2,
                      child: GestureDetector(
                        onTap: () {
                          currentPostion = currentPostion +
                              (((AppWidgetSize.screenWidth(context) / 1.5) -
                                      (AppWidgetSize.dimen_80)) /
                                  2);
                          _contentController.jumpTo(
                            currentPostion,
                          );
                          _filterNotifier.changeFilterPosition(value + 1);
                          /*if(viewPosition<2) {
                              viewPosition = viewPosition + 2;
                            } else {
                              viewPosition = viewPosition + 1;
                            }*/
                          viewPosition++;
                        },
                        child: value >= shareHoldDta!.length - 2
                            ? AppImages.rightSwipeDisabledIcon(
                                context,
                                isColor: true,
                                color: Theme.of(context).primaryIconTheme.color,
                                width: AppWidgetSize.dimen_22,
                                height: AppWidgetSize.dimen_22,
                              )
                            : AppImages.rightSwipeEnabledIcon(
                                context,
                                isColor: true,
                                color: Theme.of(context).primaryIconTheme.color,
                                width: AppWidgetSize.dimen_22,
                                height: AppWidgetSize.dimen_22,
                              ),
                      )),
                )
              ]);
            }),
      ),
    );
  }

  Widget _buildTimePeriodFilterList() {
    return SizedBox(
      width:
          (AppWidgetSize.screenWidth(context) / 1.5) - (AppWidgetSize.dimen_80),
      height: AppWidgetSize.dimen_25,
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          controller: _contentController,
          scrollDirection: Axis.horizontal,
          itemCount: shareHoldDta!.length,
          itemBuilder: (BuildContext context, dynamic index) {
            return SizedBox(
              width: ((AppWidgetSize.screenWidth(context) / 1.5) -
                      (AppWidgetSize.dimen_80)) /
                  2,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Text(
                  shareHoldDta![index].date.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontSize: AppWidgetSize.fontSize14),
                ),
              ),
            );
          }),
    );
  }

  Widget _buildShareHoldingsWidget(AppLocalizations appLocalizations) {
    return Container(
      padding: EdgeInsets.only(
          bottom: AppWidgetSize.dimen_5,
          top: AppWidgetSize.dimen_5,
          left: AppWidgetSize.dimen_5,
          right: AppWidgetSize.dimen_5),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: _buildShareHoldingsLabels(),
          ),
          Expanded(
            flex: 6,
            child: ValueListenableBuilder(
                valueListenable: _filterNotifier,
                builder: (BuildContext context, dynamic value, Widget? child) {
                  return _buildShareHoldingsData(context, viewPosition);
                }),
          ),
        ],
      ),
    );
  }

  Column _buildShareHoldingsLabels() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppWidgetSize.fullWidth(context),
          height: AppWidgetSize.dimen_40,
          color: Theme.of(context).colorScheme.background,
          margin: marginEdgeInsets(),
          padding: paddingEdgeInsets(),
          alignment: Alignment.centerLeft,
          child: Text(
            _appLocalizations.promoters,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .labelSmall!
                .copyWith(fontSize: AppWidgetSize.fontSize14),
          ),
        ),
        Container(
          width: AppWidgetSize.fullWidth(context),
          height: AppWidgetSize.dimen_40,
          color: Theme.of(context).colorScheme.background,
          margin: marginEdgeInsets(),
          padding: paddingEdgeInsets(),
          alignment: Alignment.centerLeft,
          child: Text(
            _appLocalizations.fiis,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .labelSmall!
                .copyWith(fontSize: AppWidgetSize.fontSize14),
          ),
        ),
        Container(
          width: AppWidgetSize.fullWidth(context),
          height: AppWidgetSize.dimen_40,
          color: Theme.of(context).colorScheme.background,
          margin: marginEdgeInsets(),
          padding: paddingEdgeInsets(),
          alignment: Alignment.centerLeft,
          child: Text(
            _appLocalizations.mutualFunds,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .labelSmall!
                .copyWith(fontSize: AppWidgetSize.fontSize14),
          ),
        ),
        Container(
          width: AppWidgetSize.fullWidth(context),
          height: AppWidgetSize.dimen_40,
          color: Theme.of(context).colorScheme.background,
          margin: marginEdgeInsets(),
          padding: paddingEdgeInsets(),
          alignment: Alignment.centerLeft,
          child: Text(
            _appLocalizations.insuranceCompanies,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .labelSmall!
                .copyWith(fontSize: AppWidgetSize.fontSize14),
          ),
        ),
        Container(
          width: AppWidgetSize.fullWidth(context),
          height: AppWidgetSize.dimen_40,
          color: Theme.of(context).colorScheme.background,
          margin: marginEdgeInsets(),
          padding: paddingEdgeInsets(),
          alignment: Alignment.centerLeft,
          child: Text(
            _appLocalizations.otherDiis,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .labelSmall!
                .copyWith(fontSize: AppWidgetSize.fontSize14),
          ),
        ),
        Container(
          width: AppWidgetSize.fullWidth(context),
          height: AppWidgetSize.dimen_40,
          color: Theme.of(context).colorScheme.background,
          margin: marginEdgeInsets(),
          padding: paddingEdgeInsets(),
          alignment: Alignment.centerLeft,
          child: Text(
            _appLocalizations.nonInstitution,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .labelSmall!
                .copyWith(fontSize: AppWidgetSize.fontSize14),
          ),
        ),
      ],
    );
  }

  Widget _buildShareHoldingsData(BuildContext context, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppWidgetSize.fullWidth(context),
          height: AppWidgetSize.dimen_40,
          color: Theme.of(context).colorScheme.background,
          margin: marginEdgeInsets(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '${shareHoldDta![index].promoters}%',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontSize: AppWidgetSize.fontSize14),
              ),
              Text(
                '${shareHoldDta![index + 1].promoters}%',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontSize: AppWidgetSize.fontSize14),
              ),
            ],
          ),
        ),
        Container(
          width: AppWidgetSize.fullWidth(context),
          height: AppWidgetSize.dimen_40,
          color: Theme.of(context).colorScheme.background,
          margin: marginEdgeInsets(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '${shareHoldDta![index].fiis}%',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontSize: AppWidgetSize.fontSize14),
              ),
              Text(
                '${shareHoldDta![index + 1].fiis}%',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontSize: AppWidgetSize.fontSize14),
              ),
            ],
          ),
        ),
        Container(
          width: AppWidgetSize.fullWidth(context),
          height: AppWidgetSize.dimen_40,
          color: Theme.of(context).colorScheme.background,
          margin: marginEdgeInsets(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '${shareHoldDta![index].mutualFunds}%',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontSize: AppWidgetSize.fontSize14),
              ),
              Text(
                '${shareHoldDta![index + 1].mutualFunds}%',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontSize: AppWidgetSize.fontSize14),
              ),
            ],
          ),
        ),
        Container(
          width: AppWidgetSize.fullWidth(context),
          height: AppWidgetSize.dimen_40,
          color: Theme.of(context).colorScheme.background,
          margin: marginEdgeInsets(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '${shareHoldDta![index].insuranceComp}%',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontSize: AppWidgetSize.fontSize14),
              ),
              Text(
                '${shareHoldDta![index + 1].insuranceComp}%',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontSize: AppWidgetSize.fontSize14),
              ),
            ],
          ),
        ),
        Container(
          width: AppWidgetSize.fullWidth(context),
          height: AppWidgetSize.dimen_40,
          color: Theme.of(context).colorScheme.background,
          margin: marginEdgeInsets(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '${shareHoldDta![index].otherDiis}%',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontSize: AppWidgetSize.fontSize14),
              ),
              Text(
                '${shareHoldDta![index + 1].otherDiis}%',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontSize: AppWidgetSize.fontSize14),
              ),
            ],
          ),
        ),
        Container(
          width: AppWidgetSize.fullWidth(context),
          height: AppWidgetSize.dimen_40,
          color: Theme.of(context).colorScheme.background,
          margin: marginEdgeInsets(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '${shareHoldDta![index].nonInstitution}%',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontSize: AppWidgetSize.fontSize14),
              ),
              Text(
                '${shareHoldDta![index + 1].nonInstitution}%',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontSize: AppWidgetSize.fontSize14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  EdgeInsets marginEdgeInsets() => EdgeInsets.only(
      right: AppWidgetSize.dimen_5, bottom: AppWidgetSize.dimen_5);
  EdgeInsets paddingEdgeInsets() => EdgeInsets.only(
        left: AppWidgetSize.dimen_5,
      );
}
