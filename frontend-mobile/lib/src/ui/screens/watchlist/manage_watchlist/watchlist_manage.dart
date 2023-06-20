// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/indices/indices_bloc.dart';
import '../../../../blocs/watchlist/watchlist_bloc.dart';
import '../../../../config/app_config.dart';
import '../../../../constants/app_constants.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/watchlist/watchlist_group_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_color.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/create_new_watchlist.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/error_image_widget.dart';
import '../../../widgets/loader_widget.dart';
import '../../../widgets/webview_widget.dart';
import '../../base/base_screen.dart';
import '../../route_generator.dart';
import '../widget/alert_bottomsheet_widget.dart';

class WatchlistManageScreen extends BaseScreen {
  const WatchlistManageScreen({Key? key}) : super(key: key);

  @override
  WatchlistManageScreenState createState() => WatchlistManageScreenState();
}

class WatchlistManageScreenState
    extends BaseAuthScreenState<WatchlistManageScreen> {
  late WatchlistBloc watchlistBloc;
  late IndicesBloc indicesBloc;
  late AppLocalizations _appLocalizations;
  late Groups selectedGroup;
  final TextEditingController _newWatchlistTextController =
      TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      watchlistBloc = BlocProvider.of<WatchlistBloc>(context)
        ..stream.listen(watchlistListener);
      indicesBloc = BlocProvider.of<IndicesBloc>(context);
      watchlistBloc.add(WatchlistGetGroupsEvent(true));
    });
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.watchlistManageScreen);
  }

  Future<void> watchlistListener(WatchlistState state) async {
    if (state is WatchlistAllSymsDoneState) {
    } else if (state is WatchlistDeleteGroupState) {
      watchlistBloc.add(SelectedWatchlistAndTabEvent(
          _appLocalizations.myStocks, AppConstants.tab1));
      if (mounted) {
        showToast(
          message: state.watchlistDeleteGroupModel!.infoMsg,
          context: context,
        );
        watchlistBloc.add(WatchlistGetGroupsEvent(true));
        setState(() {});
      }
    } else if (state is WatchlistDeleteGroupFailedState) {
      if (mounted) {
        showToast(
          message: state.errorMsg,
          context: context,
          isError: true,
        );

        watchlistBloc.add(WatchlistGetGroupsEvent(false));
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBarWidget(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBarWidget() {
    return AppBar(
      centerTitle: false,
      elevation: 0.0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          BlocBuilder<WatchlistBloc, WatchlistState>(
            builder: (BuildContext context, WatchlistState state) {
              if (state is WatchlistDoneState) {
                return WillPopScope(
                  onWillPop: () async {
                    return popNavigation();
                  },
                  child: backIconButton(
                      customColor:
                          Theme.of(context).textTheme.displayMedium!.color),
                );
              }
              return backIconButton(
                  customColor:
                      Theme.of(context).textTheme.displayMedium!.color);
            },
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Row(
              children: [
                CustomTextWidget(
                  _appLocalizations.manageWatchlist,
                  Theme.of(context)
                      .primaryTextTheme
                      .bodySmall!
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 22.w),
                  // Theme.of(context)
                  //     .textTheme
                  //     .headline2!
                  //     .copyWith(fontWeight: FontWeight.w500, fontSize: 24),
                ),
                _buildInfoWidget(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      buildWhen: (previous, current) {
        return current is WatchlistAllSymsDoneState ||
            current is WatchlistFailedState ||
            current is WatchlistServiceExpectionState;
      },
      builder: (context, state) {
        if (state is WatchlistAllSymsDoneState) {
          if (state.watchlistGroupModel!.groups!.isNotEmpty) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                          top: 10.w,
                          left: 30.w,
                          right: 30.w,
                        ),
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          primary: false,
                          shrinkWrap: true,
                          itemCount: state.watchlistGroupModel!.groups!.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return _buildRowWidget(
                                state.watchlistGroupModel!.groups![index]);
                          },
                        )),
                  ],
                ),
              ),
              bottomNavigationBar: state.watchlistGroupModel!.groups!
                          .where((element) => element.editable != false)
                          .isEmpty ||
                      state.watchlistGroupModel!.groups!
                              .where((element) => element.editable != false)
                              .length <
                          AppUtils().intValue(AppConfig.watchlistGroupLimit)
                  ? _createBottomButtonWidget(
                      state.watchlistGroupModel!.groups!)
                  : null,
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                errorWithImageWidget(
                  context: context,
                  isBold: true,
                  imageWidget: _geterrorImageWidget(),
                  errorMessage: _appLocalizations.manageWatchlistEmptyTitle,
                  padding: EdgeInsets.all(AppWidgetSize.dimen_60),
                  childErrorMsg:
                      _appLocalizations.manageWatchlistEmptyDescription,
                ),
                _createBottomButtonWidget([])
              ],
            );
          }
        } else if (state is WatchlistFailedState) {
          return SizedBox(
            height:
                AppWidgetSize.screenHeight(context) - AppWidgetSize.dimen_100,
            child: Center(
              child: CustomTextWidget(
                  state.errorMsg, Theme.of(context).textTheme.displaySmall),
            ),
          );
        } else if (state is WatchlistServiceExpectionState) {
          return errorWithImageWidget(
            context: context,
            imageWidget: AppUtils().getNoDateImageErrorWidget(context),
            errorMessage: state.errorMsg,
            padding: EdgeInsets.only(
              left: 30.w,
              right: 30.w,
              bottom: 30.w,
            ),
          );
        } else if (state is WatchlistProgressState) {
          return SizedBox(
            height:
                AppWidgetSize.screenHeight(context) - AppWidgetSize.dimen_100,
            child: const Center(
              child: LoaderWidget(),
            ),
          );
        }

        return SizedBox(
          height: AppWidgetSize.screenHeight(context) - AppWidgetSize.dimen_100,
          child: const Center(
            child: LoaderWidget(),
          ),
        );
      },
    );
  }

  Widget _buildInfoWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 10.w,
            bottom: 5.w,
            left: AppWidgetSize.dimen_6,
            right: 20.w,
          ),
          child: InkWell(
            onTap: () {
              showNeedhelpbottomsheet();
            },
            child: Center(
              child: AppImages.infoIcon(context,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _createBottomButtonWidget(List<Groups> groups) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WatchListCreate(
            watchlistGroups: groups,
            onChanged: (value) {
              _onCreateNewButtonClick(value);
            })
      ],
    );
  }

  Widget _buildRowWidget(Groups group) {
    return Column(
      children: [
        Container(
          width: AppWidgetSize.fullWidth(context) - 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppWidgetSize.dimen_10),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          padding: EdgeInsets.only(
            top: 10.w,
            bottom: 10.w,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLeftRowWidget(group),
              _buildRightRowWidget(group),
            ],
          ),
        ),
        Divider(
          thickness: AppWidgetSize.dimen_1,
          color: Theme.of(context).dividerColor,
        ),
      ],
    );
  }

  Widget _buildLeftRowWidget(Groups group) {
    return SizedBox(
      width: AppWidgetSize.fullWidth(context) / 2 + AppWidgetSize.dimen_10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
            AppUtils().dataNullCheck(group.wName),
            Theme.of(context)
                .primaryTextTheme
                .titleSmall!
                .copyWith(fontSize: 18.w),
          ),
          CustomTextWidget(
            '${group.symbolsCount} ${_appLocalizations.stocks}',
            Theme.of(context).primaryTextTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildRightRowWidget(Groups group) {
    return Container(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_12),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: 10.w,
            ),
            child: GestureDetector(
              onTap: () {
                _onEditWatchlist(group);
              },
              child: Container(
                padding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_1,
                  left: AppWidgetSize.dimen_12,
                  right: AppWidgetSize.dimen_12,
                  bottom: AppWidgetSize.dimen_1,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.w),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: CustomTextWidget(
                  _appLocalizations.edit,
                  Theme.of(context).primaryTextTheme.bodySmall,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              selectedGroup = group;
              showAlertBottomSheetWithTwoButtons(
                context: context,
                title: _appLocalizations.deleteWatchlistTitle,
                description:
                    '${_appLocalizations.deleteDescriptionWatchlist}${group.wName}?',
                leftButtonTitle: _appLocalizations.notNow,
                rightButtonTitle: _appLocalizations.delete,
                rightButtonCallback: deleteButtonCallBack,
              );
            },
            child: AppImages.deleteIcon(
              context,
              color: AppColors.negativeColor,
              width: 25.w,
              height: 25.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _geterrorImageWidget() {
    return AppImages.emptyManageWatchlist(
      context,
      isColor: false,
      width: AppWidgetSize.fullWidth(context) - AppWidgetSize.dimen_120,
      height: 200.w,
    );
  }

  Future<void> _onCreateNewButtonClick(String watchListName) async {
    final Map<String, dynamic> data = await pushNavigation(
      ScreenRoutes.searchScreen,
      arguments: {
        'watchlistBloc': watchlistBloc,
        'isNewWatchlist': true,
        'newWatchlistName': watchListName.trim(),
      },
    );

    _newWatchlistTextController.clear();

    if (data['isNewWatchlist']) {
      setState(() {});

      if (data['isNewWatchlistCreated']) {
        watchlistBloc.add(
            SelectedWatchlistAndTabEvent(data['wName'], AppConstants.tab1));

        watchlistBloc.add(WatchlistGetGroupsEvent(true));
        setState(() {});
      }
    }
  }

  void deleteButtonCallBack() {
    watchlistBloc.add(WatchlistDeleteGroupEvent(selectedGroup));
  }

  Future<void> _onEditWatchlist(Groups group) async {
    await pushNavigation(
      ScreenRoutes.editWatchlistScreen,
      arguments: {
        'watchlistGroup': group,
        'watchlistBloc': watchlistBloc,
        'indicesBloc': indicesBloc,
      },
    );

    watchlistBloc.add(WatchlistGetGroupsEvent(false));
    setState(() {});
  }

  showNeedhelpbottomsheet() {
    return showInfoBottomsheet(Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                _appLocalizations.manageWatchlist,
                Theme.of(context).primaryTextTheme.titleMedium,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: AppImages.closeIcon(
                  context,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true,
                  width: 20.w,
                  height: 20.w,
                ),
              )
            ],
          ),
        ),
        Divider(
          thickness: 1,
          color: Theme.of(context).dividerColor,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildExpansionRowForBottomSheetNeedhelp1(context),
                Divider(
                  thickness: 1,
                  color: Theme.of(context).dividerColor,
                ),
                _buildExpansionRowForBottomSheetNeedhelp2(context),
                Divider(
                  thickness: 1,
                  color: Theme.of(context).dividerColor,
                ),
                _buildExpansionRowForBottomSheetNeedhelp3(context),
                Divider(
                  thickness: 1,
                  color: Theme.of(context).dividerColor,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_buildNeedHelpWidget()],
                )
              ],
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildNeedHelpWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 10.w,
            bottom: 5.w,
            left: AppWidgetSize.dimen_6,
            right: 20.w,
          ),
          child: InkWell(
            onTap: () {
              String? url = AppConfig.boUrls?.firstWhereOrNull((element) =>
                  element["key"] == "manageWatchlistNeedHelp")?["value"];
              if (url != null) {
                {
                  Navigator.push(
                    context,
                    SlideRoute(
                        settings: const RouteSettings(
                          name: ScreenRoutes.inAppWebview,
                        ),
                        builder: (BuildContext context) =>
                            WebviewWidget("Need Help", url)),
                  );
                }
              }
            },
            child: CustomTextWidget(
                AppLocalizations.of(context)!.generalNeedHelp,
                Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.w400)),
          ),
        ),
      ],
    );
  }

  Widget _buildExpansionRowForBottomSheetNeedhelp1(
    BuildContext context,
  ) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        expandedAlignment: Alignment.centerLeft,
        initiallyExpanded: true,
        // onExpansionChanged: (bool val) {
        //   regordExp = false;
        //   updateState(() {});
        // },
        tilePadding: EdgeInsets.only(
          right: 0,
          left: 0,
          bottom: 5.w,
        ),
        collapsedIconColor: Theme.of(context).primaryIconTheme.color,
        title: CustomTextWidget(
          _appLocalizations.manageWatchlistQue1,
          Theme.of(context).textTheme.displaySmall,
        ),
        iconColor: Theme.of(context).primaryIconTheme.color,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                  _appLocalizations.manageWatchlistQue1Desc1,
                  Theme.of(context).primaryTextTheme.labelSmall,
                  textAlign: TextAlign.start),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: CustomTextWidget(
              _appLocalizations.step1,
              Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  text: _appLocalizations.manageWatchlistQue1Step1,
                  style: Theme.of(context).primaryTextTheme.labelSmall,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                _appLocalizations.step2,
                Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 5.w,
                ),
                child: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: _appLocalizations.manageWatchlistQue1Step2,
                        style: Theme.of(context).primaryTextTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                _appLocalizations.step3,
                Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
            ),
            child: CustomTextWidget(
              _appLocalizations.manageWatchlistQue1Step3,
              Theme.of(context).primaryTextTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }

  bool needhelp2 = false;
  bool needhelp3 = false;
  Widget _buildExpansionRowForBottomSheetNeedhelp2(
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: needhelp2,
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: 5.w,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(_appLocalizations.manageWatchlistQue2,
              Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.left),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                _appLocalizations.manageWatchlistQue2Desc,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionRowForBottomSheetNeedhelp3(
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: needhelp3,
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: 5.w,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(_appLocalizations.manageWatchlistQue3,
              Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.left),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: CustomTextWidget(
                _appLocalizations.manageWatchlistQue3Desc,
                Theme.of(context).primaryTextTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
