import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/streamer/stream/streaming_manager.dart';

import '../../blocs/quote/overview/quote_overview_bloc.dart';
import '../../data/store/app_utils.dart';
import '../../localization/app_localization.dart';
import '../../models/common/symbols_model.dart';
import '../../models/quote/quote_performance/quote_contract_info.dart';
import '../../models/quote/quote_performance/quote_delivery_data.dart';
import '../navigation/screen_routes.dart';
import '../screens/base/base_screen.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import 'custom_text_widget.dart';
import 'error_image_widget.dart';
import 'loader_widget.dart';
import 'table_with_bgcolor.dart';

class PerformanceBottomSheet extends BaseScreen {
  final dynamic arguments;
  const PerformanceBottomSheet({
    Key? key,
    this.arguments,
  }) : super(key: key);

  @override
  PerformanceBottomSheetState createState() => PerformanceBottomSheetState();
}

class PerformanceBottomSheetState
    extends BaseAuthScreenState<PerformanceBottomSheet> {
  late QuoteOverviewBloc quoteOverviewBloc;
  late AppLocalizations _appLocalizations;
  late Symbols symbols;

  @override
  void initState() {
    symbols = widget.arguments['symbolItem'];
    symbols.sym!.baseSym = symbols.baseSym;
    quoteOverviewBloc = BlocProvider.of<QuoteOverviewBloc>(context)
      ..stream.listen(overviewBlocListener);
    quoteOverviewBloc.add(QuoteGetPerformanceContractInfoEvent(symbols.sym!));
    quoteOverviewBloc.add(QuoteGetPerformanceDeliveryDataEvent(symbols.sym!));
    callStream();
    super.initState();
  }

  void callStream() {
    quoteOverviewBloc.add(QuoteOverviewStartSymStreamEvent(symbols, false));
  }

  Future<void> overviewBlocListener(QuoteOverviewState state) async {
    if (state is QuoteOverviewSymStreamState) {
      subscribeLevel1(state.streamDetails);
    }
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.quotePerformaceBottomSheet;
  }

  @override
  void quote1responseCallback(ResponseData data) {
    quoteOverviewBloc.add(QuoteOverviewStreamingResponseEvent(data));
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 20.w,
        left: 30.w,
        right: 30.w,
      ),
      child: _getPerformaceBottomSheetContent(),
    );
  }

  Widget _getPerformaceBottomSheetContent() {
    return BlocBuilder<QuoteOverviewBloc, QuoteOverviewState>(
      buildWhen: (previous, current) =>
          current is QuoteOverviewDataState ||
          current is QuotePerformanceProgressState,
      builder: (BuildContext context, QuoteOverviewState state) {
        if (state is QuoteOverviewDataState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _getPerformanceBottomSheetHeader(),
              SizedBox(
                height: AppWidgetSize.dimen_10,
              ),
              Divider(
                thickness: AppWidgetSize.dimen_1,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 20.w,
                ),
                child: _buildPerformanceTableWidget(
                  symbols,
                  state.quoteContractInfo,
                  state.quoteDeliveryData,
                ),
              ),
            ],
          );
        }
        if (state is QuotePerformanceProgressState) {
          return const LoaderWidget();
        }
        return errorWithImageWidget(
          context: context,
          imageWidget: AppUtils().getNoDateImageErrorWidget(context),
          errorMessage: AppLocalizations().noDataAvailableErrorMessage,
          padding: EdgeInsets.only(
            left: 30.w,
            right: 30.w,
            bottom: 30.w,
          ),
        );
      },
    );
  }

  Widget _getPerformanceBottomSheetHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        CustomTextWidget(
          _appLocalizations.performance,
          Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        GestureDetector(
          onTap: () {
            StreamingManager()
                .unsubscribeLevel2(ScreenRoutes.quotePerformaceBottomSheet);
            Navigator.of(context).pop();
          },
          child: AppImages.closeIcon(
            context,
            color: Theme.of(context).primaryIconTheme.color,
            isColor: true,
            width: AppWidgetSize.dimen_22,
            height: AppWidgetSize.dimen_22,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceTableWidget(
    Symbols symbolItem,
    QuoteContractInfo? quoteContractInfo,
    QuoteDeliveryData? quoteDeliveryData,
  ) {
    return SizedBox(
      child: Column(
        children: [
          buildTableWithBackgroundColor(
              _appLocalizations.open,
              AppUtils().dataNullCheckDashDash(symbolItem.open),
              _appLocalizations.high,
              AppUtils().dataNullCheckDashDash(symbolItem.high),
              _appLocalizations.low,
              AppUtils().dataNullCheckDashDash(symbolItem.low),
              context,
              isReduceFontSize: true),
          buildTableWithBackgroundColor(
              _appLocalizations.volume,
              AppUtils().dataNullCheckDashDash(symbolItem.vol),
              _appLocalizations.avgPrice,
              AppUtils().dataNullCheckDashDash(symbolItem.atp),
              _appLocalizations.prevClose,
              AppUtils().dataNullCheckDashDash(symbolItem.close),
              context,
              isReduceFontSize: true),
          buildTableWithBackgroundColor(
              _appLocalizations.lowerCircuit,
              AppUtils().dataNullCheckDashDash(symbolItem.lcl),
              _appLocalizations.upperCircuit,
              AppUtils().dataNullCheckDashDash(symbolItem.ucl),
              _appLocalizations.oI,
              AppUtils().dataNullCheckDashDash(symbolItem.openInterest),
              context,
              isReduceFontSize: true),
          buildTableWithBackgroundColor(
              _appLocalizations.fifityTwoWeekH,
              AppUtils().dataNullCheckDashDash(symbolItem.yhigh),
              _appLocalizations.fifityTwoWeekL,
              AppUtils().dataNullCheckDashDash(symbolItem.ylow),
              _appLocalizations.faceValue,
              quoteContractInfo != null ? quoteContractInfo.faceValue! : '--',
              context,
              isReduceFontSize: true),
          buildTableWithBackgroundColor(
              _appLocalizations.varMargin,
              quoteContractInfo != null ? quoteContractInfo.varMargin! : '--',
              _appLocalizations.series,
              AppUtils().dataNullCheckDashDash(quoteContractInfo?.series),
              _appLocalizations.lotSize,
              AppUtils().dataNullCheckDashDash(symbolItem.sym!.lotSize),
              context,
              isReduceFontSize: true),
          buildTableWithBackgroundColor(
              _appLocalizations.tickSize,
              AppUtils().dataNullCheckDashDash(symbolItem.sym!.tickSize),
              _appLocalizations.deliveryPercent,
              quoteDeliveryData != null
                  ? quoteDeliveryData.deliveryPerChng!
                  : '--',
              _appLocalizations.maxOrderSize,
              quoteContractInfo != null ? quoteContractInfo.maxOrdSize! : '--',
              context,
              isReduceFontSize: true),
        ],
      ),
    );
  }
}
