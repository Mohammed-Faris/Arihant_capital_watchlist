import 'package:flutter/material.dart';

import '../../constants/keys/watchlist_keys.dart';
import '../../localization/app_localization.dart';
import '../../models/watchlist/watchlist_group_model.dart';
import '../screens/base/base_screen.dart';
import '../styles/app_color.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import '../validator/input_validator.dart';
import 'gradient_button_widget.dart';

class WatchListCreate extends BaseScreen {
  final List<Groups>? watchlistGroups;
  final Function(String)? onChanged;
  final double? width;
  final double? height;
  final String? title;
  const WatchListCreate(
      {Key? key,
      this.onChanged,
      this.height,
      this.width,
      this.title,
      this.watchlistGroups})
      : super(key: key);
  @override
  State<WatchListCreate> createState() => WatchListCreateState();
}

class WatchListCreateState extends BaseAuthScreenState<WatchListCreate> {
  final TextEditingController newWatchlistController = TextEditingController();
  FocusNode newWatchlistNameFocusNode = FocusNode();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        {
          newWatchlistNameFocusNode.requestFocus();
        }

        break;
      case AppLifecycleState.inactive:
        newWatchlistNameFocusNode.unfocus();
        break;
      case AppLifecycleState.paused:
        newWatchlistNameFocusNode.unfocus();
        break;
      case AppLifecycleState.detached:
        newWatchlistNameFocusNode.unfocus();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_20),
      child: Center(
        child: gradientButtonWidget(
          onTap: () {
            showCreateNewBottomSheet();
          },
          width: widget.width ?? AppWidgetSize.fullWidth(context) / 2,
          key: const Key(watchlistCreateWatchlistKey1),
          context: context,
          title: widget.title ?? AppLocalizations().createNew,
          isGradient: true,
        ),
      ),
    );
  }

  showCreateNewBottomSheet() async {
    newWatchlistController.clear();
    await showInfoBottomsheet(StatefulBuilder(
        builder: (BuildContext context, StateSetter updateState) {
      return Container(
        child: _buildCreateWatchlistContent(context, updateState),
      );
    }));
  }

  bool watchlistCreated = false;
  Widget _buildCreateWatchlistContent(
      BuildContext context, StateSetter updateState) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_15,
              bottom: 20.w,
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: AppImages.backButtonIcon(context,
                        color: Theme.of(context).primaryIconTheme.color),
                  ),
                ),
                Text(
                  AppLocalizations().createWatchlist,
                  // style: Theme.of(context).textTheme.headline2,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .bodySmall!
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 24),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
              bottom: AppWidgetSize.dimen_15,
            ),
            child: TextField(
              style: Theme.of(context).primaryTextTheme.labelLarge,
              onChanged: (String text) {
                updateState(() {});
              },
              autofocus: true,
              focusNode: newWatchlistNameFocusNode,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: InputValidator.watchlistName,
              controller: newWatchlistController,
              maxLength: 15,
              cursorColor: Theme.of(context).primaryIconTheme.color,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: 15.w,
                  top: 12.w,
                  bottom: 12.w,
                  right: 10.w,
                ),
                counterText:
                    '${15 - (newWatchlistController.text.length.toInt())} ${AppLocalizations().charactersRemaining}',
                counterStyle: Theme.of(context)
                    .primaryTextTheme
                    .bodySmall!
                    .copyWith(
                      color: newWatchlistController.text.length.toInt() == 15
                          ? AppColors.negativeColor
                          : Theme.of(context)
                              .inputDecorationTheme
                              .labelStyle!
                              .color,
                    ),
                labelText: AppLocalizations().createWatchlistDescription,
                labelStyle: Theme.of(context).primaryTextTheme.labelSmall,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.w),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).dividerColor, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).dividerColor, width: 1),
                ),
              ),
            ),
          ),
          newWatchlistController.text.length.toInt() > 0
              ? Center(
                  child: Padding(
                      padding: EdgeInsets.only(
                        top: 5.w,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: gradientButtonWidget(
                          onTap: () {
                            if (isWatchlistExist()) {
                              Navigator.of(context).pop();
                              showToast(
                                context: context,
                                isError: true,
                                message:
                                    AppLocalizations().watchlistNameExistError,
                              );
                            } else if (newWatchlistController.text.length
                                    .toInt() >
                                0) {
                              watchlistCreated = true;
                              Navigator.pop(context);
                              if (widget.onChanged != null) {
                                widget.onChanged!(
                                    newWatchlistController.text.trim());
                              }
                            }
                          },
                          width: AppWidgetSize.fullWidth(context) / 1.5,
                          key: const Key(watchlistCreateWatchlistKey2),
                          context: context,
                          title: AppLocalizations().createNew,
                          isGradient: true)),
                )
              : Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  height: MediaQuery.of(context).viewInsets.bottom + 100,
                ),
        ],
      ),
    );
  }

  bool isWatchlistExist() {
    for (Groups group in widget.watchlistGroups ?? []) {
      if (group.wName!.toLowerCase() ==
          newWatchlistController.text.trim().toLowerCase()) {
        return true;
      }
    }
    return false;
  }
}
