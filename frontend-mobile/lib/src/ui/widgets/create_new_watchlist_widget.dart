import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/quote/main_quote/quote_bloc.dart';
import '../../constants/keys/quote_keys.dart';
import '../../localization/app_localization.dart';
import '../../models/common/symbols_model.dart';
import '../../models/watchlist/watchlist_group_model.dart';
import '../screens/base/base_screen.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import '../validator/input_validator.dart';
import 'gradient_button_widget.dart';

class CreateNewWatchlistWidget extends BaseScreen {
  final dynamic arguments;
  const CreateNewWatchlistWidget({
    Key? key,
    this.arguments,
  }) : super(key: key);

  @override
  State<CreateNewWatchlistWidget> createState() =>
      _CreateNewWatchlistWidgetState();
}

class _CreateNewWatchlistWidgetState
    extends BaseAuthScreenState<CreateNewWatchlistWidget> {
  late QuoteBloc quoteBloc;
  bool isError = false;
  String errorMessage = "";
  late AppLocalizations _appLocalizations;
  late Symbols symbols;
  final TextEditingController _newWatchlistNameTextController =
      TextEditingController();
  FocusNode newWatchlistFocusNode = FocusNode();

  List<Groups>? groupList = <Groups>[];

  @override
  void initState() {
    symbols = widget.arguments['symbolItem'];
    groupList = widget.arguments['groupList'];
    symbols.sym!.baseSym = symbols.baseSym;
    quoteBloc = BlocProvider.of<QuoteBloc>(context);

    super.initState();
  }

  bool isWatchlistExist() {
    for (Groups group in groupList!) {
      if (group.wName!.toLowerCase() ==
          _newWatchlistNameTextController.text.trim().toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return _buildCreateWatchlistContent();
  }

  Widget _buildCreateWatchlistContent() {
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
                  padding: EdgeInsets.only(
                    right: 20.w,
                  ),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: AppImages.backButtonIcon(context,
                        color: Theme.of(context).primaryIconTheme.color),
                  ),
                ),
                // Text(
                //   _appLocalizations.createWatchlist,
                //   style: Theme.of(context).textTheme.headline2,
                // ),
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
              textCapitalization: TextCapitalization.characters,
              onChanged: (String text) {
                setState(() {});
              },
              autofocus: true,
              focusNode: newWatchlistFocusNode,
              inputFormatters: InputValidator.watchlistName,
              textInputAction: TextInputAction.done,
              controller: _newWatchlistNameTextController,
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
                    '${15 - (_newWatchlistNameTextController.text.length.toInt())} ${_appLocalizations.charactersRemaining}',
                counterStyle: Theme.of(context)
                    .primaryTextTheme
                    .bodySmall!
                    .copyWith(
                      color:
                          _newWatchlistNameTextController.text.length.toInt() ==
                                  15
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context)
                                  .inputDecorationTheme
                                  .labelStyle!
                                  .color,
                    ),
                labelText: _appLocalizations.createWatchlistDescription,
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
          _newWatchlistNameTextController.text.length.toInt() > 0
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
                                    _appLocalizations.watchlistNameExistError,
                              );
                            } else if (_newWatchlistNameTextController
                                    .text.length
                                    .toInt() >
                                0) {
                              Navigator.of(context).pop();
                              quoteBloc.add(QuoteAddSymbolEvent(
                                  _newWatchlistNameTextController.text.trim(),
                                  symbols,
                                  true));
                            }
                          },
                          width: AppWidgetSize.fullWidth(context) / 1.5,
                          key: const Key(quoteCreateWatchlistKey),
                          context: context,
                          title: _appLocalizations.createNew,
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
}
