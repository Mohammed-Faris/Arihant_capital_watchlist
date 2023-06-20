import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../blocs/quote/peer/quote_peer_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/keys/quote_keys.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/loader_widget.dart';
import '../base/base_screen.dart';
import 'widgets/swipe_column_widget.dart';

class QuotePeers extends BaseScreen {
  final dynamic arguments;
  final Function(bool?)? nodataavailable;

  const QuotePeers({
    Key? key,
    required this.arguments,
    this.nodataavailable,
  }) : super(key: key);

  @override
  QuotePeersState createState() => QuotePeersState();
}

class QuotePeersState extends BaseAuthScreenState<QuotePeers> {
  late QuotePeerBloc _quotePeerBloc;
  late Symbols symbols;
  late AppLocalizations _appLocalizations;
  final List<String> _sortDataMap = _getSortDataSet();
  int sortIndexSelected = -1;
  ValueNotifier<bool> isPeersAvailable = ValueNotifier<bool>(false);

  get index => null;

  @override
  void initState() {
    super.initState();
    symbols = widget.arguments['symbolItem'];
    symbols.sym!.baseSym = symbols.baseSym;

    _quotePeerBloc = BlocProvider.of<QuotePeerBloc>(context)
      ..stream.listen(_quotePeersListener);
    _quotePeerBloc.add(
      QuoteFetchPeerRatiosEvent(symbols.sym!, true),
    );
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.quotePeers);
  }

  static List<String> _getSortDataSet() {
    return <String>[
      AppConstants.alphabeticalAtoZ,
      AppConstants.alphabeticalZtoA,
      AppConstants.priceLowToHigh,
      AppConstants.priceHighToLow,
      AppConstants.chngPerctLowToHigh,
      AppConstants.chngPerctHighToLow,
    ];
  }

  Future<void> _quotePeersListener(QuotePeerState state) async {
    if (state is! QuotePeerProgressState) {
      if (mounted) {}
    }
    if (state is QuotePeerProgressState) {
      if (mounted) {}
    } else if (state is QuotePeerSymStreamState) {
      subscribeLevel1(state.streamDetails);
    } else if (state is QuotePeerRatiosDataState) {
      if (state.quotePeerModel != null &&
          state.quotePeerModel!.peerRatioList!.length > 1) {
        isPeersAvailable.value = true;
      } else {
        isPeersAvailable.value = false;
      }
    } else if (state is QuotePeerRatiosFailedState ||
        state is QuotePeerRatiosServiceExceptionState) {
      isPeersAvailable.value = false;
    }
  }

  @override
  void quote1responseCallback(ResponseData data) {
    _quotePeerBloc.add(QuotePeerStreamingResponseEvent(data));
  }

  @override
  String getScreenRoute() {
    return widget.arguments['isFromOverview']
        ? ScreenRoutes.quoteSimilarStocks
        : ScreenRoutes.quotePeers;
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return widget.arguments['isFromOverview']
        ? _buildBodyForSimilarStocks(context)
        : _buildBodyForPeers(context);
  }

  Widget _buildBodyForSimilarStocks(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _buildBody(widget.arguments['context'] ?? context),
    );
  }

  Widget _buildBodyForPeers(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFloatingButtonActionWidget(context),
      body: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_30,
          right: AppWidgetSize.dimen_30,
        ),
        child: _buildBody(widget.arguments['context'] ?? context),
      ),
    );
  }

  List<Symbols> peerRatioList = [];
  Widget _buildBody(BuildContext context) {
    return BlocBuilder<QuotePeerBloc, QuotePeerState>(
      buildWhen: (QuotePeerState prevState, QuotePeerState currentState) {
        return currentState is QuotePeerRatiosDataState ||
            currentState is QuotePeerRatiosFailedState ||
            currentState is QuotePeerProgressState ||
            currentState is QuotePeerRatiosServiceExceptionState;
      },
      builder: (BuildContext ctx, QuotePeerState state) {
        if (state is QuotePeerProgressState) {
          return const LoaderWidget();
        }
        if (state is QuotePeerRatiosDataState) {
          if (state.quotePeerModel != null) {
            if (widget.arguments['isFromOverview']) {
              peerRatioList = state.quotePeerModel!.peerRatioList!.length <= 5
                  ? state.quotePeerModel!.peerRatioList!
                      .getRange(0, state.quotePeerModel!.peerRatioList!.length)
                      .toList()
                  : state.quotePeerModel!.peerRatioList!
                      .getRange(0, 5)
                      .toList();
            } else {
              peerRatioList = state.quotePeerModel!.peerRatioList!
                  .getRange(0, state.quotePeerModel!.peerRatioList!.length)
                  .toList();
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwipeColumnWidget(
                    headerList: [
                      _appLocalizations.ltpCap,
                      _appLocalizations.mktCap,
                      _appLocalizations.pE
                    ],
                    peerList: peerRatioList,
                    context: context,
                  ),
                  if (!widget.arguments['isFromOverview'])
                    SizedBox(
                      height: AppWidgetSize.dimen_30,
                    ),
                ],
              ),
            );
          }
        } else if (state is QuotePeerRatiosFailedState) {
          if (widget.nodataavailable != null) widget.nodataavailable!(true);
          return errorWithImageWidget(
            context: context,
            imageWidget: AppUtils().getNoDateImageErrorWidget(context),
            errorMessage: AppLocalizations().noDataAvailableErrorMessage,
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
              bottom: AppWidgetSize.dimen_30,
            ),
          );
        } else if (state is QuotePeerRatiosServiceExceptionState) {
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

  Widget _buildFloatingButtonActionWidget(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isPeersAvailable,
      builder: (context, value, _) {
        return isPeersAvailable.value
            ? FloatingActionButton(
                onPressed: () {
                  if (isPeersAvailable.value) sortSheet();
                },
                elevation: 1.0,
                child: Container(
                  width: AppWidgetSize.dimen_60,
                  height: AppWidgetSize.dimen_60,
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).iconTheme.color!)),
                  child: Stack(
                    children: [
                      Center(
                        child: AppImages.peersSortIcon(
                          context,
                          color: Theme.of(context).iconTheme.color,
                          width: AppWidgetSize.dimen_25,
                          height: AppWidgetSize.dimen_25,
                        ),
                      ),
                      sortIndexSelected != -1
                          ? Positioned(
                              right: AppUtils.isTablet
                                  ? AppWidgetSize.dimen_6
                                  : AppWidgetSize.dimen_14,
                              top: AppUtils.isTablet
                                  ? AppWidgetSize.dimen_7
                                  : AppWidgetSize.dimen_14,
                              child: Container(
                                width: AppWidgetSize.dimen_5,
                                height: AppWidgetSize.dimen_5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.w),
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
              )
            : Container();
      },
    );
  }

  Future<void> sortSheet() async {
    showInfoBottomsheet(
        BlocProvider<QuotePeerBloc>.value(
          value: QuotePeerBloc(),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter updateState) {
              return SafeArea(
                child: _buildSortSheetWidget(updateState),
              );
            },
          ),
        ),
        bottomMargin: 10,
        horizontalMargin: false,
        topMargin: false);
  }

  Widget _buildSortSheetWidget(StateSetter updateState) {
    return Container(
      //height: AppWidgetSize.dimen_460,
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: AppWidgetSize.dimen_1,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: AppWidgetSize.dimen_10,
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CustomTextWidget(
                  _appLocalizations.sort,
                  Theme.of(context).textTheme.displayMedium,
                ),
                GestureDetector(
                  onTap: () {
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
            ),
          ),
          _buildSortListView(updateState),
          _buildPersistentFooterButton(updateState),
        ],
      ),
    );
  }

  Widget _buildSortListView(StateSetter updateState) {
    return Container(
      width: AppWidgetSize.fullWidth(context),
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
        top: AppWidgetSize.dimen_8,
        bottom: 10.w,
      ),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        primary: false,
        shrinkWrap: true,
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            thickness: AppWidgetSize.dimen_1,
            color: Theme.of(context).dividerColor,
          );
        },
        itemCount: _sortDataMap.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return _buildSortRowWidget(
            _sortDataMap.elementAt(index),
            updateState,
          );
        },
      ),
    );
  }

  Widget _buildSortRowWidget(String title, StateSetter updateState) {
    List<String> text = title.split(
      "->",
    );
    String arrowb4 = text[0];
    String arrowa4 = text[1];

    return GestureDetector(
      onTap: () {
        sortIndexSelected = _sortDataMap.indexOf(title);
        updateState(() {});
      },
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_5,
                  bottom: AppWidgetSize.dimen_5,
                ),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: arrowb4,
                        style: Theme.of(context).textTheme.headlineSmall!),
                    WidgetSpan(
                        child: SizedBox(
                            width: 20.0,
                            child: AppImages.sortArrow(context,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color,
                                isColor: true))),
                    TextSpan(
                        text: arrowa4,
                        style: Theme.of(context).textTheme.headlineSmall!),
                  ]),
                )),
            if (sortIndexSelected != -1 &&
                sortIndexSelected == _sortDataMap.indexOf(title))
              AppImages.greenTickIcon(
                context,
                width: AppWidgetSize.dimen_25,
                height: AppWidgetSize.dimen_25,
              )
          ],
        ),
      ),
    );
  }

  Widget _buildPersistentFooterButton(StateSetter updateState) {
    return Container(
      width: AppWidgetSize.fullWidth(context),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: AppWidgetSize.dimen_1,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          gradientButtonWidget(
              onTap: () {
                updateState(() {
                  sortIndexSelected = -1;
                });
                setState(() {});
              },
              width: AppWidgetSize.fullWidth(context) / 3,
              key: const Key(quoteSortClearButtonKey),
              context: context,
              title: _appLocalizations.clear,
              isGradient: false,
              isErrorButton: true,
              bottom: 0),
          gradientButtonWidget(
              onTap: () {
                Navigator.of(context).pop();
                if (sortIndexSelected < 0) {
                  _quotePeerBloc.add(QuotePeerSortSymbolsEvent(""));
                } else {
                  _quotePeerBloc.add(
                    QuotePeerSortSymbolsEvent(
                        _sortDataMap.elementAt(sortIndexSelected)),
                  );
                }
                setState(() {});
              },
              width: AppWidgetSize.fullWidth(context) / 2.5,
              key: const Key(quoteSortDoneButtonKey),
              context: context,
              title: _appLocalizations.done,
              isGradient: true,
              bottom: 0),
        ],
      ),
    );
  }
}
