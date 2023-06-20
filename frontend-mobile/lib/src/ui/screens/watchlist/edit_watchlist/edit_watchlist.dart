import 'package:basic_utils/basic_utils.dart' as base_utils;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/watchlist/watchlist_bloc.dart';
import '../../../../constants/keys/watchlist_keys.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../../models/watchlist/watchlist_group_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_color.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../validator/input_validator.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/error_image_widget.dart';
import '../../../widgets/fandotag.dart';
import '../../../widgets/loader_widget.dart';
import '../../base/base_screen.dart';
import '../widget/alert_bottomsheet_widget.dart';

class EditWatchlistScreen extends BaseScreen {
  final dynamic arguments;
  const EditWatchlistScreen({Key? key, this.arguments}) : super(key: key);

  @override
  EditWatchlistScreenState createState() => EditWatchlistScreenState();
}

class EditWatchlistScreenState
    extends BaseAuthScreenState<EditWatchlistScreen> {
  late WatchlistBloc watchlistBloc;
  late AppLocalizations _appLocalizations;
  final TextEditingController _renameWatchlistController =
      TextEditingController(
    text: '',
  );
  late String wId;
  late Groups group;
  bool renameEnabled = false;
  late int selectedSymbolIndex;
  late FocusNode renameTxtFieldFocusNode;

  @override
  void initState() {
    renameTxtFieldFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      watchlistBloc = BlocProvider.of<WatchlistBloc>(context)
        ..stream.listen(watchlistListener);
      if (widget.arguments != null) {
        if (widget.arguments["watchlistGroup"] != null) {
          group = widget.arguments["watchlistGroup"];
          wId = group.wId!;
          _renameWatchlistController.text = group.wName!;
          watchlistBloc.add(WatchlistGetSymbolsEvent(
              widget.arguments["watchlistGroup"], false, false));
        }
      }
    });

    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.editWatchlistScreen);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (renameEnabled) {
          FocusScope.of(context).requestFocus(renameTxtFieldFocusNode);
        }
        break;
      case AppLifecycleState.inactive:
        renameTxtFieldFocusNode.unfocus();
        break;
      case AppLifecycleState.paused:
        renameTxtFieldFocusNode.unfocus();
        break;
      case AppLifecycleState.detached:
        renameTxtFieldFocusNode.unfocus();
        break;
    }
  }

  Future<void> watchlistListener(WatchlistState state) async {
    if (state is WatchlistRearrangeSymState) {
      if (mounted) {
        showToast(
          message: state.message,
          context: context,
        );
        setState(() {
          scrollListEnable = true;
        });
      }
    } else if (state is RenameWatchlistFailedState) {
      _renameWatchlistController.text = group.wName!;
      if (mounted) {
        showToast(
          message: state.errorMsg,
          context: context,
          isError: true,
        );
        setState(() {
          scrollListEnable = true;
        });
      }
    } else if (state is RenameWatchlistDoneState) {
      if (mounted) {
        showToast(
          message: state.watchlistRenameWatchlistModel!.infoMsg,
          context: context,
        );
      }
    } else if (state is WatchlistDeleteSymbolFailedState) {
      if (mounted) {
        showToast(
          message: state.errorMsg,
          context: context,
          isError: true,
        );
      }
    } else if (state is WatchlistDeleteSymbolState) {
      if (mounted) {
        showToast(
          message: state.message,
          context: context,
        );
      }
    } else if (state is WatchlistRearrangeSymFailedState) {
      if (mounted) {
        showToast(
          message: state.errorMsg,
          context: context,
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: _buildAppBarWidget(),
      body: SafeArea(child: _buildBody()),
    );
  }

  AppBar _buildAppBarWidget() {
    return AppBar(
      centerTitle: false,
      elevation: 0.0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              BlocBuilder<WatchlistBloc, WatchlistState>(
                builder: (BuildContext context, WatchlistState state) {
                  if (state is WatchlistDoneState) {
                    final Map<String, dynamic> returnGroupMapObj =
                        <String, dynamic>{
                      'wName': _renameWatchlistController.text,
                    };
                    return WillPopScope(
                      onWillPop: () async {
                        return popNavigation(arguments: returnGroupMapObj);
                      },
                      child: backIconButton(
                          value: returnGroupMapObj,
                          customColor:
                              Theme.of(context).textTheme.displayMedium!.color),
                    );
                  }

                  return backIconButton(
                      onTap: () {
                        popNavigation(arguments: {
                          'wName': _renameWatchlistController.text,
                        });
                      },
                      customColor:
                          Theme.of(context).textTheme.displayMedium!.color);
                },
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: CustomTextWidget(
                  _appLocalizations.editWatchlist,
                  Theme.of(context)
                      .primaryTextTheme
                      .bodySmall!
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 24),
                ),
              ),
            ],
          ),
          renameEnabled
              ? GestureDetector(
                  onTap: () {
                    if (_renameWatchlistController.text != group.wName &&
                        _renameWatchlistController.text.isNotEmpty) {
                      watchlistBloc.add(WatchlistRenameGroupEvent(
                          wId, _renameWatchlistController.text, group.wName!));
                    } else if (_renameWatchlistController.text == group.wName) {
                      showToast(
                        message: _appLocalizations.watchlistNameNoChangeError,
                        context: context,
                        isError: true,
                      );
                    } else if (_renameWatchlistController.text.isEmpty) {
                      showToast(
                        message: _appLocalizations.invalidNewWnameError,
                        context: context,
                        isError: true,
                      );
                      _renameWatchlistController.text = group.wName!;
                    }

                    setState(
                      () {
                        renameEnabled = false;
                      },
                    );
                    renameTxtFieldFocusNode.unfocus();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: 20.w,
                    ),
                    child: CustomTextWidget(
                      _appLocalizations.done,
                      Theme.of(context).primaryTextTheme.headlineMedium,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
        padding: EdgeInsets.only(
          top: 30.w,
          left: 15.w,
          right: AppWidgetSize.dimen_15,
        ),
        child: _buildContentWidget());
  }

  List<Symbols> symbols = [];
  Widget _buildContentWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _buildRenameWatchlistWidget(),
        ),
        BlocBuilder<WatchlistBloc, WatchlistState>(
          builder: (context, state) {
            if (state is WatchlistProgressState) {
              return Container(
                  margin: EdgeInsets.only(top: 200.w),
                  child: const Center(child: LoaderWidget()));
            }
            if (state is WatchlistDoneState) {
              symbols = state.watchlistSymbolsModel?.symbols ?? [];
            }
            if (state is WatchlistDoneState || symbols.isNotEmpty) {
              if (symbols.isNotEmpty) {
                return _buildSymbolsSection(symbols);
              }
              return Container();
            }
            if (state is WatchlistServiceExpectionState) {
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
            } else if (state is WatchlistFailedState) {
              return Center(
                child: SizedBox(
                  child: CustomTextWidget(
                      state.errorMsg, Theme.of(context).textTheme.displaySmall),
                ),
              );
            }
            return Container();
          },
        ),
      ],
    );
  }

  Widget _buildRenameWatchlistWidget() {
    return PhysicalModel(
      borderRadius: BorderRadius.circular(AppWidgetSize.dimen_30),
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: AppWidgetSize.dimen_5,
      shadowColor: Theme.of(context).inputDecorationTheme.fillColor!,
      child: TextField(
        enableSuggestions: false,
        key: const Key(watchlistRenameTextFieldKey),
        enableInteractiveSelection: true,
        autocorrect: false,
        autofocus: renameEnabled,

        textCapitalization: TextCapitalization.sentences,
        focusNode: renameTxtFieldFocusNode,
        //readOnly: !renameEnabled,
        onTap: () {
          setState(() {
            renameEnabled = true;
          });
          FocusScope.of(context).requestFocus(renameTxtFieldFocusNode);
        },
        onChanged: (String text) {
          setState(() {});
        },
        style: Theme.of(context)
            .primaryTextTheme
            .labelLarge!
            .copyWith(decoration: TextDecoration.none),
        inputFormatters: InputValidator.watchlistName,
        controller: _renameWatchlistController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(
            left: 15.w,
            top: 12.w,
            bottom: 12.w,
            right: 10.w,
          ),
          suffix: _renameWatchlistController.text.isNotEmpty
              ? InkWell(
                  onTap: () {
                    _renameWatchlistController.clear();
                    setState(() {});
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: 10.w,
                    ),
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
                    height: 20.w,
                    width: 20.w,
                    alignment: Alignment.centerRight,
                    child: AppImages.closeIcon(context,
                        color: Theme.of(context).iconTheme.color,
                        isColor: true),
                  ),
                )
              : SizedBox(
                  width: AppWidgetSize.dimen_15,
                  height: AppWidgetSize.dimen_15,
                ),
          labelStyle: Theme.of(context).primaryTextTheme.labelSmall,
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppWidgetSize.dimen_30),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppWidgetSize.dimen_30),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppWidgetSize.dimen_30),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        maxLength: 15,
      ),
    );
  }

  bool scrollListEnable = true;

  Widget _buildSymbolsSection(List<Symbols> symbols) {
    return Expanded(
      child: ReorderableListView(
          scrollDirection: Axis.vertical,
          physics: scrollListEnable
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
          onReorder: (int oldIndex, int newIndex) {
            final bool isPositionChanged =
                (oldIndex < newIndex && oldIndex != (newIndex - 1)) ||
                    (oldIndex > newIndex && oldIndex != newIndex);
            if (symbols.length > 1 && isPositionChanged) {
              watchlistBloc.add(
                WatchlistReorderEvent(
                  widget.arguments['watchlistGroup'],
                  oldIndex,
                  newIndex,
                ),
              );
            }
          },
          children: List<Widget>.generate(
            symbols.length,
            (int index) {
              final Symbols symbolItem = symbols[index];
              return _buildSymbolsRow(symbolItem, index);
            },
          )),
    );
  }

  Widget _buildSymbolsRow(Symbols symbolItem, int index) {
    return Container(
      key: Key(watchlistEditReorderRowKey + index.toString()),
      height: AppWidgetSize.dimen_70,
      padding: EdgeInsets.only(
        top: 5.w,
        bottom: 5.w,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: ListTile(
        minLeadingWidth: 30.w,
        leading: Listener(
          onPointerHover: (d) {
            if (scrollListEnable) {
              setState(() {
                scrollListEnable = false;
              });
            }
          },
          child: ReorderableDragStartListener(
            index: index,
            enabled: true,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              height: AppWidgetSize.dimen_70,
              width: 40.w,
              padding: EdgeInsets.all(
                AppWidgetSize.dimen_7,
              ),
              child: AppImages.dragIcon(
                context,
                width: 30.w,
                height: 30.w,
                color: Theme.of(context).primaryTextTheme.titleMedium!.color,
              ),
            ),
          ),
        ),
        contentPadding: const EdgeInsets.all(0),
        title: Listener(
          onPointerHover: (details) {
            setState(() {
              scrollListEnable = true;
            });
          },
          child: buildSymolListRow(
            symbolItem,
            index,
          ),
        ),
        trailing: buildDeleteIcon(
          index,
          symbolItem,
        ),
        onTap: () {/* Do something else */},
      ),
    );
  }

  Padding buildDeleteIcon(int index, Symbols symbolItem) {
    return Padding(
      padding: EdgeInsets.only(right: AppWidgetSize.dimen_15),
      child: GestureDetector(
        onTap: () {
          selectedSymbolIndex = index;
          showAlertBottomSheetWithTwoButtons(
            context: context,
            title: _appLocalizations.deleteSymbol,
            description:
                '${_appLocalizations.deleteDescription}${symbolItem.dispSym}?',
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
    );
  }

  Widget buildSymolListRow(Symbols symbolItem, int index) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                symbolItem.sym?.optionType != null
                    ? '${symbolItem.baseSym} '
                    : AppUtils().dataNullCheck(symbolItem.dispSym),
                Theme.of(context)
                    .primaryTextTheme
                    .labelLarge!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  if (symbolItem.companyName != null &&
                      symbolItem.sym?.asset != "future")
                    SizedBox(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 5.w,
                          right: AppWidgetSize.dimen_5,
                        ),
                        child: Text(
                          AppUtils()
                                      .dataNullCheck(
                                          base_utils.StringUtils.capitalize(
                                              symbolItem.companyName!))
                                      .length >
                                  28
                              ? AppUtils().dataNullCheck(
                                  base_utils.StringUtils.capitalize(
                                          symbolItem.companyName!)
                                      .substring(0, 28))
                              : AppUtils().dataNullCheck(
                                  base_utils.StringUtils.capitalize(
                                      symbolItem.companyName!)),
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .copyWith(
                                  color: Theme.of(context)
                                      .inputDecorationTheme
                                      .labelStyle!
                                      .color),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_6),
                    child: FandOTag(symbolItem),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void deleteButtonCallBack() {
    watchlistBloc.add(
      WatchlistDeleteSymbolEvent(
        selectedSymbolIndex,
        widget.arguments['watchlistGroup'],
      ),
    );
  }
}
