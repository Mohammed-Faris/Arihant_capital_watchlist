import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/quote/deals/deals_bloc.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/quote/quote_deals_block/quote_block_deals.dart';
import '../../../models/quote/quote_deals_block/quote_block_deals_model.dart';
import '../../../models/quote/quote_deals_bulk/quote_deals_bulk.dart';
import '../../../models/quote/quote_deals_bulk/quote_deals_bulk_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/technicalspivotstrategychart/toggle_circular_tabborder_widget.dart';
import '../base/base_screen.dart';

class QuoteDeals extends BaseScreen {
  final dynamic arguments;
  const QuoteDeals({Key? key, this.arguments}) : super(key: key);

  @override
  State<QuoteDeals> createState() => _QuoteDealsState();
}

class _QuoteDealsState extends BaseAuthScreenState<QuoteDeals>
    with TickerProviderStateMixin {
  late QuotesDealsBloc _quotesDealsBloc;

  late AppLocalizations _appLocalizations;
  late Symbols _symbols = Symbols();
  bool toggleBlockDeals = true;
  bool toggleBulkDeals = false;
  late QuoteBlockDealsModel _quoteBlockDealsModel;
  late QuotesBulkDealsModel _quotesBulkDealsModel;
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  bool onfirstScroll = true;
  @override
  void initState() {
    super.initState();
    _symbols = widget.arguments['symbolItem'];
    _symbols.sym!.baseSym = _symbols.baseSym;

    _quotesDealsBloc = BlocProvider.of<QuotesDealsBloc>(context)
      ..add((QuoteToggleBlockEvent()))
      ..stream.listen(_quoteDealsListener);
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.quoteDeals);

    tabController = TabController(
        length: 2, initialIndex: selectedIndex.value, vsync: this);
    tabController?.addListener(() {
      selectedIndex.value = tabController?.index ?? 0;
      onfirstScroll = true;
    });
  }

  Future<void> _quoteDealsListener(DealsState state) async {
    if (state is DealsProgressState) {}
    if (state is DealsBlockDoneState) {
    } else if (state is DealsBulkDoneState) {
    } else if (state is DealsFailedState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    } else if (state is DealsErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildQuoteDealsToggleWidget(),
        Expanded(
          child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                buildQuotesBlockBulkToggleBlocBuilder(),
                buildQuotesBlockBulkToggleBlocBuilder()
              ]),
        )
      ],
    );
  }

  int intialIndex = 0;
  TabController? tabController;
  Widget _buildQuoteDealsToggleWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_25,
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_25),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: AppWidgetSize.dimen_1,
          ),
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppWidgetSize.dimen_2),
          child: ToggleCircularTabMWidget(
            tabController: tabController!,
            key: const Key(''),
            height: AppWidgetSize.dimen_36,
            minWidth: AppWidgetSize.dimen_150,
            cornerRadius: AppWidgetSize.dimen_20,
            labels: <String>[
              _appLocalizations.blocDeals,
              _appLocalizations.bulkDeals
            ],
            initialLabel: intialIndex,
            onToggle: (int selectedTabValue) {
              intialIndex = selectedTabValue;
              if (selectedTabValue == 0) {
                toggleBlockDeals = true;
                toggleBulkDeals = false;
                _quotesDealsBloc.add((QuoteToggleBlockEvent()));
              } else {
                toggleBulkDeals = true;
                toggleBlockDeals = false;
                _quotesDealsBloc.add((QuoteToggleBulkEvent()));
              }

              tabController?.animateTo(selectedTabValue);
            },
          ),
        ),
      ),
    );
  }

  BlocBuilder<QuotesDealsBloc, DealsState>
      buildQuotesBlockBulkToggleBlocBuilder() {
    return BlocBuilder<QuotesDealsBloc, DealsState>(
      bloc: _quotesDealsBloc,
      builder: (context, state) {
        //print(';state is $state');
        if (state is DealsProgressState) {
          return const LoaderWidget();
        }
        if (state is DealsBlockToggleState) {
          BlockDeals blockDeals = BlockDeals();
          blockDeals.sym = _symbols.sym;
          _quotesDealsBloc.add(QuoteBlockEvent(blockDeals));
        } else if (state is DealsBulkToggleState) {
          BulkDeals bulkDeals = BulkDeals();
          bulkDeals.sym = _symbols.sym;
          bulkDeals.dispSym = _symbols.dispSym;
          _quotesDealsBloc.add(QuoteBulkEvent(bulkDeals));
        } else if (state is DealsBlockDoneState) {
          _quoteBlockDealsModel = state.quoteBlockDealsModel;
          return _buildQuotesDealsListView(_quoteBlockDealsModel.blockDeals);
        } else if (state is DealsBulkDoneState) {
          _quotesBulkDealsModel = state.quotesBulkDealsModel;
          if (_quotesBulkDealsModel.bulkDeals != null) {
            return _buildQuotesDealsListView(_quotesBulkDealsModel.bulkDeals);
          }
        }
        if (state is DealsFailedState) {
          return errorWithImageWidget(
            context: context,
            imageWidget: AppImages.noDealsImage(context),
            errorMessage: AppLocalizations().noDealsDataAvailableErrorMessage,
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
              bottom: AppWidgetSize.dimen_30,
            ),
          );
          //return _buildErrorWidget();
        } else if (state is DealsServiceExceptionState) {
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

  Padding _buildQuotesDealsListView(var quoteDeals) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ListView.builder(
        // key: Key(FUTURES_LIST),
        itemBuilder: (BuildContext context, dynamic index) {
          return Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25, top: 0),
            child: Column(
              children: [
                _buildBlockRows(quoteDeals![index]),
                if (index == (quoteDeals!.length - 1)) dealsDisclaimer(context)
              ],
            ),
          );
        },
        itemCount: quoteDeals!.length,
      ),
    );
  }

  Column dealsDisclaimer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(
          AppLocalizations().disclaimer,
          Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.w600, fontSize: AppWidgetSize.fontSize12),
        ),
        Padding(
          padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
          child: CustomTextWidget(
              AppLocalizations().disclaimerContent,
              Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: AppWidgetSize.fontSize11)),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_7, bottom: AppWidgetSize.dimen_5),
          child: CustomTextWidget(
              AppLocalizations().cmotsData,
              Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: AppWidgetSize.fontSize11)),
        )
      ],
    );
  }

  Widget _buildBlockRows(var quoteDeals) {
    return SizedBox(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  quoteDeals.date.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                Text(
                  quoteDeals.buySell.toString(),
                  textAlign: TextAlign.center,
                  style: purchaseSellStyle(quoteDeals),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_10,
              bottom: AppWidgetSize.dimen_20,
              left: AppWidgetSize.dimen_5,
              right: AppWidgetSize.dimen_30,
            ),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    quoteDeals.clientNme.toString(),
                    maxLines: 2,
                    //overflow: TextOverflow.fade,
                    style:
                        Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                  ),
                ),
              ],
            ),
          ),
          _buildQuotesDealsBlockBulckWidget(quoteDeals),
          _buildDivider(),
          //_buildErrorWidget(),
        ],
      ),
    );
  }

  TextStyle purchaseSellStyle(quoteDeals) {
    return quoteDeals.buySell == 'Purchase'
        ? Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500, color: AppColors().positiveColor)
        : Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500, color: AppColors.negativeColor);
  }

  Widget _buildQuotesDealsBlockBulckWidget(var quoteDeals) {
    //print(quoteDeals.qtyShares);
    return SizedBox(
      child: Column(
        children: [
          _buildTableWithBackgroundColor(
            _appLocalizations.quantity,
            quoteDeals.qtyShares ?? '',
            _appLocalizations.price,
            quoteDeals.avgPrce ?? '',
            _appLocalizations.tradedPercentage,
            quoteDeals.percentTraded ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildTableWithBackgroundColor(
    String tableCell1Key,
    String tableCell1Value,
    String tableCell2Key,
    String tableCell2Value,
    String tableCell3Key,
    String tableCell3Value,
  ) {
    return SizedBox(
      width: AppWidgetSize.fullWidth(context),
      child: Table(
        children: <TableRow>[
          TableRow(
            children: <TableCell>[
              _buildTableCellWithBackgroundColor(
                tableCell1Key,
                tableCell1Value,
              ),
              _buildTableCellWithBackgroundColor(
                tableCell2Key,
                tableCell2Value,
                isMiddle: true,
              ),
              _buildTableCellWithBackgroundColor(
                tableCell3Key,
                tableCell3Value,
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableCell _buildTableCellWithBackgroundColor(
    String key,
    String value, {
    bool isMiddle = false,
  }) {
    return TableCell(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: AppWidgetSize.dimen_1,
          left: isMiddle ? AppWidgetSize.dimen_10 : 0,
          right: isMiddle ? AppWidgetSize.dimen_10 : 0,
          top: AppWidgetSize.dimen_1,
        ),
        child: Container(
          padding: EdgeInsets.only(
            bottom: AppWidgetSize.dimen_5,
            top: AppWidgetSize.dimen_5,
          ),
          color: Theme.of(context).colorScheme.background,
          child: Column(
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                key,
                textAlign: TextAlign.center,
                style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildErrorWidget() {
  //   return errorWithImageWidget(
  //       errorMessage: AppLocalizations().noDataAvailableErrorMessage,
  //       padding: const EdgeInsets.all(0.0),
  //       context: context,
  //       imageWidget: AppImages.noDealsImage(
  //         context,
  //         height: AppWidgetSize.dimen_190,
  //         width: AppWidgetSize.dimen_250,
  //       )
  //   );
  // }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
      ),
      child: Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
    );
  }
}
