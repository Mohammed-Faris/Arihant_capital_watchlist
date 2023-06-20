import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/quote/main_quote/quote_bloc.dart';
import '../../blocs/search/search_bloc.dart';
import '../../config/app_config.dart';
import '../../constants/app_constants.dart';
import '../../data/store/app_utils.dart';
import '../../localization/app_localization.dart';
import '../../models/common/symbols_model.dart';
import '../../models/watchlist/symbol_watchlist_map_holder_model.dart';
import '../../models/watchlist/watchlist_group_model.dart';
import '../screens/base/base_screen.dart';
import '../styles/app_color.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import 'create_new_watchlist.dart';
import 'custom_text_widget.dart';

class ChooseWatchlistWidget extends BaseScreen {
  final dynamic arguments;

  const ChooseWatchlistWidget({
    Key? key,
    this.arguments,
  }) : super(key: key);

  @override
  State<ChooseWatchlistWidget> createState() => _ChooseWatchlistWidgetState();
}

class _ChooseWatchlistWidgetState
    extends BaseScreenState<ChooseWatchlistWidget> {
  late QuoteBloc quoteBloc;
  late SearchBloc searchBloc;

  late AppLocalizations _appLocalizations;
  late Symbols symbols;
  List<Groups>? groupList = <Groups>[];
  List<String>? exchangeList = [];
  List<Widget> watchlistIcons = <Widget>[];
  bool fromSearchScreen = false;
  @override
  void initState() {
    symbols = widget.arguments['symbolItem'];
    groupList = widget.arguments['groupList'];
    fromSearchScreen = widget.arguments['fromSearchScreen'] ?? false;
    exchangeList!.add(symbols.sym!.exc == AppConstants.nfo
        ? AppConstants.fo
        : AppUtils().dataNullCheck(symbols.sym!.exc!));
    if (symbols.sym!.otherExch != null) {
      exchangeList!.addAll(List.from(symbols.sym!.otherExch!));
    }
    watchlistIcons = AppUtils().getWatchlistIcons(
      context,
      groupList!.length,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (fromSearchScreen) {
        searchBloc = BlocProvider.of<SearchBloc>(context);
      } else {
        quoteBloc = BlocProvider.of<QuoteBloc>(context);
      }
    });
    super.initState();
  }

  bool isWatchlistExist(String watchListName) {
    for (Groups group in groupList!) {
      if (group.wName!.toLowerCase() == watchListName.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return _buildBottomSheetContentWidget();
  }

  Widget _buildBottomSheetContentWidget() {
    return Scaffold(
      bottomNavigationBar: bottomBar(),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: AppWidgetSize.dimen_70,
            padding: EdgeInsets.only(
              top: 20.w,
              left: AppWidgetSize.dimen_32,
              right: 30.w,
              bottom: 20.w,
            ),
            child: CustomTextWidget(
              _appLocalizations.chooseWatchlistGroups,
              Theme.of(context).textTheme.displayMedium,
            ),
          ),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: _buildMyWatchlistWidget(),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox bottomBar() {
    return SizedBox(
      height: AppUtils().watchlistLimitReached(groupList ?? [])
          ? AppWidgetSize.dimen_108
          : 0,
      child: FittedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (((groupList!
                    .where((element) => element.editable != false)
                    .toList()
                    .isEmpty ||
                groupList!
                        .where((element) => element.editable != false)
                        .length <
                    AppUtils().intValue(AppConfig.watchlistGroupLimit))))
              WatchListCreate(
                  onChanged: (value) {
                    _onCreateNewButtonClick(value, symbols);
                  },
                  watchlistGroups: groupList!),
          ],
        ),
      ),
    );
  }

  Future<void> _onCreateNewButtonClick(
      String watchListName, Symbols symbolItem) async {
    Navigator.of(context).pop();
    if (!isWatchlistExist(watchListName)) {
      if (fromSearchScreen) {
        searchBloc.add(SearchAddSymbolEvent(
          watchListName,
          symbolItem,
          true,
        ));
      } else {
        quoteBloc.add(QuoteAddSymbolEvent(
          watchListName,
          symbolItem,
          true,
        ));
      }
    }
  }

  Widget _buildMyWatchlistWidget() {
    return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: groupList!.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return _buildMyWatchlistSymRowWidget(
            groupList![index],
            index,
          );
        });
  }

  Widget _buildMyWatchlistSymRowWidget(
    Groups group,
    int index,
  ) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          //color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
              bottom: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 0.5)),
        ),
        height: AppWidgetSize.dimen_70,
        child: Padding(
          padding: EdgeInsets.only(
            left: 30.w,
            right: 30.w,
            top: 10.w,
            bottom: 10.w,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (watchlistIcons.length > (index + 1))
                    watchlistIcons.elementAt(index + 1),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      if (fromSearchScreen) {
                        SymbolWatchlistMapHolder()
                                .isSymbolIdAvailableInGivenWatchlist(
                                    symbols.sym!.id!, group.wName!)
                            ? searchBloc.add(
                                SearchdeleteSymbolEvent(group.wName!, symbols))
                            : searchBloc.add(SearchAddSymbolEvent(
                                group.wName!, symbols, false));
                      } else {
                        SymbolWatchlistMapHolder()
                                .isSymbolIdAvailableInGivenWatchlist(
                                    symbols.sym!.id!, group.wName!)
                            ? quoteBloc.add(
                                QuotedeleteSymbolEvent(group.wName!, symbols))
                            : quoteBloc.add(QuoteAddSymbolEvent(
                                group.wName!, symbols, false));
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 10.w,
                      ),
                      child: CustomTextWidget(
                        group.wName!,
                        Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                ],
              ),
              _buildAddWatchlistIconForBottomSheet(
                group,
                index,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddWatchlistIconForBottomSheet(
    Groups group,
    int index,
  ) {
    return SizedBox(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          if (fromSearchScreen) {
            SymbolWatchlistMapHolder().isSymbolIdAvailableInGivenWatchlist(
                    symbols.sym!.id!, group.wName!)
                ? searchBloc.add(SearchdeleteSymbolEvent(group.wName!, symbols))
                : searchBloc
                    .add(SearchAddSymbolEvent(group.wName!, symbols, false));
          } else {
            SymbolWatchlistMapHolder().isSymbolIdAvailableInGivenWatchlist(
                    symbols.sym!.id!, group.wName!)
                ? quoteBloc.add(QuotedeleteSymbolEvent(group.wName!, symbols))
                : quoteBloc
                    .add(QuoteAddSymbolEvent(group.wName!, symbols, false));
          }
        },
        child: SymbolWatchlistMapHolder().isSymbolIdAvailableInGivenWatchlist(
                symbols.sym!.id!, group.wName!)
            ? AppImages.addFilledIcon(context, width: 30.w, height: 30.w)
            : AppImages.addUnfilledIcon(context,
                color: AppColors().positiveColor,
                isColor: true,
                width: 30.w,
                height: 30.w),
      ),
    );
  }
}
