import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/quote/news/quote_news_bloc.dart';
import '../../../constants/keys/quote_keys.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/quote/quote_news_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/loader_widget.dart';
import '../base/base_screen.dart';

class QuoteNews extends BaseScreen {
  final dynamic arguments;
  const QuoteNews({
    Key? key,
    this.arguments,
  }) : super(key: key);

  @override
  QuoteNewwsState createState() => QuoteNewwsState();
}

class QuoteNewwsState extends BaseAuthScreenState<QuoteNews> {
  late QuoteNewsBloc _quoteNewsBloc;
  late Symbols symbols;

  @override
  void initState() {
    super.initState();
    symbols = widget.arguments['symbolItem'];
    symbols.sym!.baseSym = symbols.baseSym;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quoteNewsBloc = BlocProvider.of<QuoteNewsBloc>(context)
        ..stream.listen(_quoteNewsListener);
      _quoteNewsBloc.add(QuoteFetchNewsEvent(symbols.sym!));
    });
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.quoteNewsDetail);
  }

  Future<void> _quoteNewsListener(QuoteNewsState state) async {
    if (state is! QuoteNewsProgressState) {
      if (mounted) {}
    }
    if (state is QuoteNewsProgressState) {
      if (mounted) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_30,
          right: AppWidgetSize.dimen_30,
          top: AppWidgetSize.dimen_30,
        ),
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<QuoteNewsBloc, QuoteNewsState>(
      buildWhen: (QuoteNewsState prevState, QuoteNewsState currentState) {
        return currentState is QuoteNewsDataState ||
            currentState is QuoteNewsFailedState ||
            currentState is QuoteNewsProgressState ||
            currentState is QuoteNewsServiceExceptionState;
      },
      builder: (BuildContext ctx, QuoteNewsState state) {
        if (state is QuoteNewsProgressState) {
          return const LoaderWidget();
        }
        if (state is QuoteNewsDataState) {
          if (state.quoteNewsModel != null) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView.separated(
                      key: const Key(quoteNewsListKey),
                      itemCount: state.quoteNewsModel!.newsHeadlines!.length,
                      itemBuilder: (BuildContext ctx, dynamic index) {
                        return Column(
                          children: [
                            _buildContentRow(
                                state.quoteNewsModel!.newsHeadlines![index],
                                index),
                            if (index ==
                                ((state.quoteNewsModel?.newsHeadlines?.length ??
                                        0) -
                                    1))
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(
                                    thickness: 1,
                                    color: Theme.of(context).dividerColor,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: AppWidgetSize.dimen_5,
                                        top: AppWidgetSize.dimen_5),
                                    child: CustomTextWidget(
                                      "Disclaimer",
                                      Theme.of(context)
                                          .primaryTextTheme
                                          .labelSmall!
                                          .copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize:
                                                  AppWidgetSize.fontSize12),
                                    ),
                                  ),
                                  CustomTextWidget(
                                      "The news has been aggregated from information available in the public domain by reliable news agencies. Arihant Capital does not publish this news and has no responsibility on the verity, accuracy and adequacy of the data and the facts presented in this news. Please verify the information and use your judgement while using any news as the basis for placing trades.",
                                      Theme.of(context)
                                          .primaryTextTheme
                                          .bodySmall!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontSize:
                                                  AppWidgetSize.dimen_11)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: AppWidgetSize.dimen_5),
                                    child: CustomTextWidget(
                                        AppLocalizations().cmotsData,
                                        Theme.of(context)
                                            .primaryTextTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontSize:
                                                    AppWidgetSize.dimen_11)),
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          thickness: 1,
                          color: Theme.of(context).dividerColor,
                        );
                      }),
                ),
              ],
            );
          }
        } else if (state is QuoteNewsFailedState) {
          return errorWithImageWidget(
            context: context,
            imageWidget: AppUtils().getNoDateImageErrorWidget(context),
            errorMessage: AppLocalizations().noDataAvailableErrorMessageFornews,
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_30,
              right: AppWidgetSize.dimen_30,
              bottom: AppWidgetSize.dimen_30,
            ),
          );
        } else if (state is QuoteNewsServiceExceptionState) {
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

  Widget _buildContentRow(News news, int index) {
    return GestureDetector(
      onTap: () {
        pushNavigation(ScreenRoutes.quoteNewsDetail, arguments: {
          'news': news,
        });
      },
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Text(
                news.date!,
                style: Theme.of(context).primaryTextTheme.bodySmall,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_10,
                bottom: AppWidgetSize.dimen_10,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.headline!,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (news.caption != null)
                      Padding(
                        padding: EdgeInsets.only(
                          top: AppWidgetSize.dimen_10,
                        ),
                        child: Text(
                          news.caption!,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
