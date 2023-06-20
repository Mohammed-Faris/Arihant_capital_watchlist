import 'package:acml/src/ui/screens/acml_app.dart';
import 'package:flutter/material.dart';

import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../base/base_screen.dart';

class SwipeColumnWidget extends BaseScreen {
  final List<String> headerList;
  final List<Symbols> peerList;
  final BuildContext context;
  const SwipeColumnWidget({
    Key? key,
    required this.headerList,
    required this.peerList,
    required this.context,
  }) : super(key: key);

  @override
  SwipeColumnWidgetState createState() => SwipeColumnWidgetState();
}

class SwipeColumnWidgetState extends BaseScreenState<SwipeColumnWidget> {
  final ScrollController _headerController = ScrollController();
  final ScrollController _contentController = ScrollController();
  bool isLeftAllowed = false;
  bool isRightAllowed = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (isLeftAllowed) {
          _headerController.jumpTo(0);
          _contentController.jumpTo(0);
          setState(() {
            isLeftAllowed = false;
            isRightAllowed = true;
          });
        } else {
          if (isRightAllowed) {
            _headerController.jumpTo(
                (((AppWidgetSize.fullWidth(navigatorKey.currentContext!) -
                                AppWidgetSize.dimen_60) *
                            0.62) -
                        (_headerController.position.pixels > 0
                            ? AppWidgetSize.dimen_25
                            : 0)) *
                    0.5);
            _contentController.jumpTo(
                ((AppWidgetSize.fullWidth(navigatorKey.currentContext!) -
                            AppWidgetSize.dimen_60) *
                        0.62) *
                    0.5);
            setState(() {
              isLeftAllowed = true;
              isRightAllowed = false;
            });
          }
        }

        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(widget.context).scaffoldBackgroundColor,
      child: _buildBody(widget.context),
    );
  }

  Widget _buildBody(BuildContext ctx) {
    return Container(
      color: Theme.of(widget.context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildHeaderWidget(ctx),
            _buildContentListWidget(ctx),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWidget(BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          color: Theme.of(widget.context).scaffoldBackgroundColor,
          padding: EdgeInsets.only(right: AppWidgetSize.dimen_10),
          width: AppWidgetSize.dimen_45,
          child: GestureDetector(
            onTap: () {
              if (isLeftAllowed) {
                _headerController.jumpTo(0);
                _contentController.jumpTo(0);
                setState(() {
                  isLeftAllowed = false;
                  isRightAllowed = true;
                });
              }
            },
            child: SizedBox(
              height: AppWidgetSize.dimen_50,
              child: Center(
                child: isLeftAllowed
                    ? AppImages.leftSwipeEnabledIcon(
                        context,
                        color: Theme.of(ctx).primaryTextTheme.labelSmall!.color,
                        isColor: true,
                        width: AppWidgetSize.dimen_22,
                        height: AppWidgetSize.dimen_22,
                      )
                    : AppImages.leftSwipeDisabledIcon(
                        context,
                        isColor: true,
                        color: Theme.of(ctx)
                            .primaryTextTheme
                            .labelSmall!
                            .color!
                            .withOpacity(1),
                        width: AppWidgetSize.dimen_22,
                        height: AppWidgetSize.dimen_22,
                      ),
              ),
            ),
          ),
        ),
        SizedBox(
          width:
              ((AppWidgetSize.fullWidth(ctx) - AppWidgetSize.dimen_60) * 0.62) -
                  AppWidgetSize.dimen_25,
          height: AppWidgetSize.dimen_50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: _headerController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.headerList.length,
            itemBuilder: (context, index) {
              return Container(
                alignment: Alignment.center,
                width: (((AppWidgetSize.fullWidth(ctx) -
                                AppWidgetSize.dimen_60) *
                            0.62) -
                        ((index == 1 && _headerController.position.pixels == 0)
                            ? AppWidgetSize.dimen_25
                            : 0)) *
                    0.5,
                height: AppWidgetSize.dimen_45,
                padding: EdgeInsets.only(
                    left: (index == 0) ? AppWidgetSize.dimen_5 : 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      if (widget.headerList[index] ==
                          AppLocalizations().mktCap) {
                        if (_headerController.offset == 0.0) {
                          _headerController.jumpTo(
                              (((AppWidgetSize.fullWidth(ctx) -
                                              AppWidgetSize.dimen_60) *
                                          0.62) -
                                      (_headerController.position.pixels > 0
                                          ? AppWidgetSize.dimen_25
                                          : 0)) *
                                  0.5);
                          _contentController.jumpTo(
                              ((AppWidgetSize.fullWidth(ctx) -
                                          AppWidgetSize.dimen_60) *
                                      0.62) *
                                  0.5);
                          setState(() {
                            isLeftAllowed = true;
                            isRightAllowed = false;
                          });
                        } else {
                          _headerController.jumpTo(0);
                          _contentController.jumpTo(0);
                          setState(() {
                            isLeftAllowed = false;
                            isRightAllowed = true;
                          });
                        }
                      }
                    },
                    child: Text(
                      widget.headerList[index],
                      style: Theme.of(ctx).primaryTextTheme.bodySmall,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        GestureDetector(
          onTap: () {
            if (isRightAllowed) {
              _headerController.jumpTo(
                  (((AppWidgetSize.fullWidth(ctx) - AppWidgetSize.dimen_60) *
                              0.62) -
                          (_headerController.position.pixels > 0
                              ? AppWidgetSize.dimen_25
                              : 0)) *
                      0.5);
              _contentController.jumpTo(
                  ((AppWidgetSize.fullWidth(ctx) - AppWidgetSize.dimen_60) *
                          0.62) *
                      0.5);
              setState(() {
                isLeftAllowed = true;
                isRightAllowed = false;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.only(left: AppWidgetSize.dimen_5),
            width: AppWidgetSize.dimen_27,
            height: AppWidgetSize.dimen_50,
            child: isRightAllowed
                ? AppImages.rightSwipeEnabledIcon(
                    context,
                    color: Theme.of(ctx).primaryTextTheme.labelSmall!.color,
                    isColor: true,
                    width: AppWidgetSize.dimen_22,
                    height: AppWidgetSize.dimen_22,
                  )
                : AppImages.rightSwipeDisabledIcon(context,
                    isColor: true,
                    width: AppWidgetSize.dimen_25,
                    height: AppWidgetSize.dimen_25,
                    color: Theme.of(ctx)
                        .primaryTextTheme
                        .labelSmall!
                        .color!
                        .withOpacity(1)),
          ),
        ),
      ],
    );
  }

  Widget _buildContentListWidget(BuildContext ctx) {
    return SizedBox(
      width: AppWidgetSize.fullWidth(ctx),
      height: AppWidgetSize.dimen_70 * widget.peerList.length,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildLeftListWidget(ctx),
          _buildRightListWidget(ctx),
        ],
      ),
    );
  }

  Widget _buildLeftListWidget(BuildContext ctx) {
    return SizedBox(
      width: (AppWidgetSize.fullWidth(ctx) - AppWidgetSize.dimen_60) * 0.38,
      height: double.infinity,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.peerList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              pushNavigation(ScreenRoutes.quoteScreen, arguments: {
                'symbolItem': widget.peerList[index],
              });
            },
            child: Container(
              padding: EdgeInsets.only(
                right: AppWidgetSize.dimen_10,
                top: AppWidgetSize.dimen_15,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(width: 1, color: Theme.of(ctx).dividerColor),
                ),
              ),
              height: AppWidgetSize.dimen_70,
              child: Text(
                widget.peerList[index].dispSym!,
                style: Theme.of(ctx).primaryTextTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRightListWidget(BuildContext ctx) {
    return SizedBox(
        width: (AppWidgetSize.fullWidth(ctx) - AppWidgetSize.dimen_60) * 0.62,
        height: AppWidgetSize.dimen_70 * widget.peerList.length,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.peerList.length,
          itemBuilder: (context, peerListIndex) {
            return SizedBox(
              width: AppWidgetSize.dimen_200,
              height: AppWidgetSize.dimen_70,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                controller: _contentController,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(
                  3,
                  (int index) {
                    final String item = index == 0
                        ? widget.peerList[peerListIndex].ltp!
                        : index == 1
                            ? widget.peerList[peerListIndex].mcap!
                            : widget.peerList[peerListIndex].pE!;
                    return Container(
                      alignment: Alignment.topCenter,
                      width: ((AppWidgetSize.fullWidth(ctx) -
                                  AppWidgetSize.dimen_60) *
                              0.62) *
                          0.5,
                      padding: EdgeInsets.only(
                          right: AppWidgetSize.dimen_10,
                          top: AppWidgetSize.dimen_15,
                          bottom: 0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 1, color: Theme.of(ctx).dividerColor),
                        ),
                      ),
                      child: index == 0
                          ? Align(
                              alignment: Alignment.topLeft,
                              child: _buildLtpChngChngPercentWidget(
                                  peerListIndex, ctx))
                          : Align(
                              alignment: Alignment.topLeft,
                              child: FittedBox(
                                child: Text(
                                  item,
                                  style:
                                      Theme.of(ctx).primaryTextTheme.labelSmall,
                                  // textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                    );
                  },
                ),
              ),
            );
          },
        ));
  }

  Widget _buildLtpChngChngPercentWidget(
    int peerListIndex,
    BuildContext ctx,
  ) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
            widget.peerList[peerListIndex].ltp!,
            Theme.of(ctx).primaryTextTheme.labelSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: widget.peerList[peerListIndex].chng != null
                    ? AppUtils().setcolorForChange(AppUtils()
                        .dataNullCheck(widget.peerList[peerListIndex].chng))
                    : Theme.of(ctx).primaryTextTheme.labelSmall!.color),
            textAlign: TextAlign.start,
            isShowShimmer: true,
          ),
          CustomTextWidget(
            widget.peerList[peerListIndex].chng != null
                ? AppUtils().getChangePercentage(widget.peerList[peerListIndex])
                : '',
            Theme.of(ctx).primaryTextTheme.bodyLarge!.copyWith(
                  color: Theme.of(ctx).inputDecorationTheme.labelStyle!.color,
                ),
            textAlign: TextAlign.start,
            isShowShimmer: true,
            shimmerWidth: AppWidgetSize.dimen_60,
          ),
        ],
      ),
    );
  }
}
