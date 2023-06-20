import 'package:acml/src/ui/screens/base/base_screen.dart';
import 'package:acml/src/ui/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/markets/markets_bloc.dart';
import '../../../constants/keys/watchlist_keys.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/dropdown.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/toggle_circular_widget.dart';

class MarketFiiDiiArguments {
  final bool isFno;
  final bool isFullScreen;
  MarketFiiDiiArguments(this.isFno, {this.isFullScreen = false});
}

class MarketsFIIDII extends BaseScreen {
  final MarketFiiDiiArguments arguments;
  const MarketsFIIDII(this.arguments, {Key? key}) : super(key: key);

  @override
  State<MarketsFIIDII> createState() => _MarketsFIIDIIState();
}

class _MarketsFIIDIIState extends BaseAuthScreenState<MarketsFIIDII> {
  @override
  void initState() {
    BlocProvider.of<MarketsBloc>(context).add(MarketsFFIDIIFetch()
      ..category = category()
      ..type = ["D", "M", "Y"][selectedType.value]);

    super.initState();
  }

  String category() {
    return widget.arguments.isFno
        ? isFuture.value
            ? "FIIFUT"
            : "FIIOPT"
        : isFii.value
            ? "FIICASH"
            : "DIICash";
  }

  ValueNotifier<bool> isFii = ValueNotifier<bool>(true);
  ValueNotifier<bool> isFuture = ValueNotifier<bool>(true);
  ValueNotifier<int> selectedType = ValueNotifier<int>(0);
  Widget buildToggle2() {
    return Container(
      // height: AppWidgetSize.fullWidth(context),
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_25,
          bottom: 5.w,
          top: AppWidgetSize.dimen_8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
              alignment: Alignment.centerRight,
              height: AppWidgetSize.dimen_40,
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
                  key: const Key(fiiDIIToggleKey),
                  height: AppWidgetSize.dimen_40,
                  minWidth: AppWidgetSize.dimen_75,
                  cornerRadius: AppWidgetSize.dimen_20,
                  activeBgColor:
                      Theme.of(context).primaryTextTheme.displayLarge!.color,
                  activeTextColor: Theme.of(context).colorScheme.secondary,
                  inactiveBgColor: Theme.of(context).scaffoldBackgroundColor,
                  inactiveTextColor:
                      Theme.of(context).primaryTextTheme.displayLarge!.color,
                  labels: const <String>["Future", "Option"],
                  initialLabel: isFuture.value ? 0 : 1,
                  isBadgeWidget: false,
                  activeTextStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontSize: AppWidgetSize.fontSize12),
                  inactiveTextStyle:
                      Theme.of(context).inputDecorationTheme.labelStyle!,
                  onToggle: (int selectedTabValue) {
                    isFuture.value = selectedTabValue == 0;
                    BlocProvider.of<MarketsBloc>(context)
                        .add(MarketsFFIDIIFetch()
                          ..category = category()
                          ..type = ["D", "M", "Y"][selectedType.value]);
                  },
                ),
              )),
        ],
      ),
    );
  }

  Widget buildToggle3() {
    return Container(
      // height: AppWidgetSize.fullWidth(context),
      padding:
          EdgeInsets.only(left: AppWidgetSize.dimen_25, bottom: 10.w, top: 5.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
              height: AppWidgetSize.dimen_40,
              alignment: Alignment.centerRight,
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
                  key: const Key(fiiDIIToggleKey),
                  height: AppWidgetSize.dimen_40,
                  minWidth: AppWidgetSize.dimen_75,
                  cornerRadius: AppWidgetSize.dimen_20,
                  activeBgColor:
                      Theme.of(context).primaryTextTheme.displayLarge!.color,
                  activeTextColor: Theme.of(context).colorScheme.secondary,
                  inactiveBgColor: Theme.of(context).scaffoldBackgroundColor,
                  inactiveTextColor:
                      Theme.of(context).primaryTextTheme.displayLarge!.color,
                  labels: const <String>[
                    "FII",
                    "DII",
                  ],
                  initialLabel: isFii.value ? 0 : 1,
                  isBadgeWidget: false,
                  activeTextStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontSize: AppWidgetSize.fontSize14),
                  inactiveTextStyle:
                      Theme.of(context).inputDecorationTheme.labelStyle!,
                  onToggle: (int selectedTabValue) {
                    isFii.value = selectedTabValue == 0;
                    BlocProvider.of<MarketsBloc>(context)
                        .add(MarketsFFIDIIFetch()
                          ..category = category()
                          ..type = ["D", "M", "Y"][selectedType.value]);
                  },
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.arguments.isFullScreen
        ? Scaffold(
            body: fiidiiScreen(context),
          )
        : fiidiiScreen(context);
  }

  Container fiidiiScreen(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(top: 20.w),
      child: Column(
        children: [
          if (widget.arguments.isFullScreen)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 15.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      backIconButton(),
                      Padding(
                        padding: EdgeInsets.only(left: 10.w),
                        child: CustomTextWidget(
                          "FII DII Activity",
                          Theme.of(context).primaryTextTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.arguments.isFno ? buildToggle2() : buildToggle3(),
              buildToggleDay(context),
              //buildToggle(),
            ],
          ),
          widget.arguments.isFullScreen
              ? Expanded(
                  child: fiidiiActivityData(),
                )
              : fiidiiActivityData(),
        ],
      ),
    );
  }

  buildToggleDay(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: selectedType,
        builder: (context, value, _) {
          return Container(
              height: 35.w,
              margin: EdgeInsets.only(right: 20.w, top: 8.w),
              width: 120.w,
              padding: EdgeInsets.only(
                bottom: AppWidgetSize.dimen_2,
                left: 10.w,
                top: 2.w,
              ),
              // height: AppWidgetSize.dimen_24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(AppWidgetSize.dimen_5),
              ),
              child: DropdownButtonHideUnderline(
                child: CustomDropdownButton(
                  value: ["Day", "Month", "Year"][selectedType.value],
                  onChanged: (data) {
                    int selectedTabValue =
                        ["Day", "Month", "Year"].indexOf(data);
                    selectedType.value = selectedTabValue;
                    BlocProvider.of<MarketsBloc>(context)
                        .add(MarketsFFIDIIFetch()
                          ..type = ["D", "M", "Y"][selectedTabValue]
                          ..category = category());
                  },
                  dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                  icon: Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    size: 25.w,
                  ),
                  items: ["Day", "Month", "Year"].map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Row(
                        children: [
                          Text(
                            item,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.w,
                                    ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ));
        });
  }

  ValueListenableBuilder<bool> fiidiiActivityData() {
    return ValueListenableBuilder<bool>(
        valueListenable: isFuture,
        builder: (context, value2, _) {
          return ValueListenableBuilder<bool>(
              valueListenable: isFii,
              builder: (context, value, _) {
                return BlocBuilder<MarketsBloc, MarketsState>(
                  buildWhen: (previous, current) =>
                      current is MarketFIIDIIDoneState ||
                      current is MarketFIIDIIFailedState,
                  builder: (context, state) => state is MarketFIIDIIDoneState
                      ? ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: widget.arguments.isFullScreen
                              ? const AlwaysScrollableScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
                          itemCount: widget.arguments.isFullScreen
                              ? state.fiidiiModel?.fiiDii.length
                              : state.fiidiiModel?.fiiDii.take(5).length,
                          itemBuilder: (context, index) => SizedBox(
                            height: 60.w,
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                              child: Card(
                                  elevation: 0,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  margin: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppWidgetSize.dimen_10)),
                                  child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 25.w),
                                    decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 0.5)),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: 5.w,
                                        bottom: 5.w,
                                      ),
                                      child: Container(
                                          padding: EdgeInsets.only(
                                            top: 10.w,
                                            bottom: 10.w,
                                          ),
                                          child: Container(
                                            width: AppWidgetSize.screenWidth(
                                                context),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppWidgetSize.dimen_10),
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        RichText(
                                                          text: TextSpan(
                                                            text: state
                                                                .fiidiiModel
                                                                ?.fiiDii[index]
                                                                .date,
                                                            style: Theme.of(
                                                                    context)
                                                                .primaryTextTheme
                                                                .labelSmall!
                                                                .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        CustomTextWidget(
                                                          AppUtils().dataNullCheck(widget
                                                                      .arguments
                                                                      .isFno
                                                                  ? isFuture
                                                                          .value
                                                                      ? state
                                                                          .fiidiiModel
                                                                          ?.fiiDii[
                                                                              index]
                                                                          .fiiFuture
                                                                      : state
                                                                          .fiidiiModel
                                                                          ?.fiiDii[
                                                                              index]
                                                                          .fiiOption
                                                                  : isFii.value
                                                                      ? state
                                                                          .fiidiiModel
                                                                          ?.fiiDii[
                                                                              index]
                                                                          .fiiCash
                                                                      : state
                                                                          .fiidiiModel
                                                                          ?.fiiDii[
                                                                              index]
                                                                          .diiCash) +
                                                              "cr",
                                                          Theme.of(context)
                                                              .primaryTextTheme
                                                              .labelLarge!
                                                              .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: AppUtils().setcolorForChange(AppUtils().dataNullCheck(widget
                                                                        .arguments
                                                                        .isFno
                                                                    ? isFuture
                                                                            .value
                                                                        ? state
                                                                            .fiidiiModel
                                                                            ?.fiiDii[
                                                                                index]
                                                                            .fiiFuture
                                                                        : state
                                                                            .fiidiiModel
                                                                            ?.fiiDii[
                                                                                index]
                                                                            .fiiOption
                                                                    : isFii
                                                                            .value
                                                                        ? state
                                                                            .fiidiiModel
                                                                            ?.fiiDii[
                                                                                index]
                                                                            .fiiCash
                                                                        : state
                                                                            .fiidiiModel
                                                                            ?.fiiDii[index]
                                                                            .diiCash)),
                                                              ),
                                                          textAlign:
                                                              TextAlign.end,
                                                          isShowShimmer: true,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )),
                                    ),
                                  )),
                            ),
                          ),
                        )
                      : state is MarketFIIDIIFailedState
                          ? errorWithImageWidget(
                              width: AppWidgetSize.screenWidth(context),
                              context: context,
                              height: 250.w,
                              imageWidget:
                                  AppUtils().getNoDateImageErrorWidget(context),
                              errorMessage: AppLocalizations()
                                  .noDataAvailableErrorMessage,
                              padding: EdgeInsets.only(
                                left: AppWidgetSize.dimen_30,
                                right: AppWidgetSize.dimen_30,
                                bottom: AppWidgetSize.dimen_30,
                              ),
                            )
                          : const LoaderWidget(),
                );
              });
        });
  }
}
