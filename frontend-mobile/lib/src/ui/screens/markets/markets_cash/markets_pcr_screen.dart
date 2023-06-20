import 'package:acml/src/blocs/pcr/put_call_ratio_bloc.dart';
import 'package:acml/src/ui/styles/app_widget_size.dart';
import 'package:acml/src/ui/widgets/card_widget.dart';
import 'package:acml/src/ui/widgets/error_image_widget.dart';
import 'package:acml/src/ui/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/keys/watchlist_keys.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../widgets/scrollable_toggle_widget.dart';
import '../../../widgets/toggle_circular_widget.dart';
import '../../base/base_screen.dart';

class PutCallRationScreen extends BaseScreen {
  const PutCallRationScreen(this.expiryList, {super.key});
  final List<String> expiryList;

  @override
  State<PutCallRationScreen> createState() => _PutCallRationScreenState();
}

class _PutCallRationScreenState
    extends BaseAuthScreenState<PutCallRationScreen> {
  @override
  void didUpdateWidget(PutCallRationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (selectedExpiryDate.value.isEmpty && widget.expiryList.isNotEmpty) {
      selectedExpiryDate.value = widget.expiryList.first;
      BlocProvider.of<PutCallRatioBloc>(context)
          .add(PutCallRatioFetchEvent(selectedExpiryDate.value));
    }
    super.didChangeDependencies();
  }

  ValueNotifier<String> selectedExpiryDate = ValueNotifier<String>("");
  Widget buildToggle() {
    return Container(
      // height: AppWidgetSize.fullWidth(context),
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_30,
          right: AppWidgetSize.dimen_25,
          bottom: 0.w,
          top: AppWidgetSize.dimen_8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
              alignment: Alignment.centerRight,
              height: AppWidgetSize.dimen_24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppWidgetSize.dimen_2),
                child: ToggleCircularWidget(
                  key: const Key(pcrToggleKey),
                  height: AppWidgetSize.dimen_20,
                  minWidth: AppWidgetSize.dimen_40,
                  cornerRadius: AppWidgetSize.dimen_10,
                  activeBgColor:
                      Theme.of(context).primaryTextTheme.displayLarge!.color,
                  activeTextColor: Theme.of(context).colorScheme.secondary,
                  inactiveBgColor: Theme.of(context).scaffoldBackgroundColor,
                  inactiveTextColor:
                      Theme.of(context).primaryTextTheme.displayLarge!.color,
                  labels: const <String>["OI", "VOl"],
                  initialLabel: selectedType.value,
                  isBadgeWidget: false,
                  activeTextStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontSize: AppWidgetSize.fontSize12),
                  inactiveTextStyle:
                      Theme.of(context).inputDecorationTheme.labelStyle!,
                  onToggle: (int selectedTabValue) {
                    selectedType.value = selectedTabValue;
                  },
                ),
              )),
        ],
      ),
    );
  }

  ValueNotifier<int> selectedType = ValueNotifier<int>(0);

  Widget _buildExpiryFilterWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: 10.w,
          right: AppWidgetSize.dimen_5,
          left: AppWidgetSize.dimen_15,
          bottom: AppWidgetSize.dimen_5),
      child: ScrollCircularButtonToggleWidget(
        value: selectedExpiryDate.value,
        toggleButtonlist: widget.expiryList,
        toggleButtonOnChanged: (val) {
          selectedExpiryDate.value = val;

          BlocProvider.of<PutCallRatioBloc>(context)
              .add(PutCallRatioFetchEvent(selectedExpiryDate.value));
          setState(() {});
        },
        activeButtonColor:
            Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.5),
        activeTextColor: Theme.of(context).primaryColor,
        inactiveButtonColor: Colors.transparent,
        inactiveTextColor: Theme.of(context).primaryColor,
        key: const Key(""),
        defaultSelected: '',
        enabledButtonlist: const [],
        isBorder: false,
        context: context,
        borderColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedType,
      builder: (context, value, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                buildToggle(),
              ],
            ),
            _buildExpiryFilterWidget(),
            BlocBuilder<PutCallRatioBloc, PutCallRatioState>(
              builder: (context, state) {
                if (state is PutCallRatioDoneState) {
                  return SizedBox(
                    height: 140.w * (state.response.symList?.length ?? 0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.response.symList?.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(top: 20.w),
                        child: CardWidget(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: AppWidgetSize.screenWidth(context) - 20.w,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.w)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 12.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.response.symList?[index].dispSym ??
                                        "--",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              selectedType.value == 0
                                                  ? (state
                                                          .response
                                                          .symList?[index]
                                                          .putOI ??
                                                      "--")
                                                  : (state
                                                          .response
                                                          .symList?[index]
                                                          .putVol ??
                                                      "--"),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall,
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 8.w),
                                              child: Text(
                                                AppLocalizations()
                                                    .put
                                                    .capitalize(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              selectedType.value == 0
                                                  ? (state
                                                          .response
                                                          .symList?[index]
                                                          .callOI ??
                                                      "--")
                                                  : state
                                                          .response
                                                          .symList?[index]
                                                          .callVol ??
                                                      "--",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall,
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 8.w),
                                              child: Text(
                                                AppLocalizations()
                                                    .call
                                                    .capitalize(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              selectedType.value == 0
                                                  ? (state
                                                          .response
                                                          .symList?[index]
                                                          .oiPCR ??
                                                      "--")
                                                  : state
                                                          .response
                                                          .symList?[index]
                                                          .volPCR ??
                                                      "--",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall,
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 8.w),
                                              child: Text(
                                                AppLocalizations()
                                                    .ratio
                                                    .capitalize(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )),
                      ),
                    ),
                  );
                } else if (state is PutCallRatioLoadState) {
                  return SizedBox(height: 300.w, child: const LoaderWidget());
                } else {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 20.w),
                    child: errorWithImageWidget(
                      context: context,
                      imageWidget:
                          AppUtils().getNoDateImageErrorWidget(context),
                      errorMessage:
                          AppLocalizations().noDataAvailableErrorMessage,
                      padding: EdgeInsets.only(
                        left: 30.w,
                        right: 30.w,
                        top: 20.w,
                        bottom: 30.w,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
