import '../../../../blocs/quote/news/quote_news_bloc.dart';
import '../../../../data/store/app_utils.dart';
import '../../../../models/quote/quote_news_model.dart';
import '../../base/base_screen.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuoteNewsDetail extends BaseScreen {
  final dynamic arguments;
  const QuoteNewsDetail({Key? key, this.arguments}) : super(key: key);

  @override
  QuoteNewsDetailState createState() => QuoteNewsDetailState();
}

class QuoteNewsDetailState extends BaseAuthScreenState<QuoteNewsDetail> {
  late QuoteNewsBloc _quoteNewsBloc;
  late News news;

  @override
  void initState() {
    super.initState();
    news = widget.arguments['news'];

    _quoteNewsBloc = BlocProvider.of<QuoteNewsBloc>(context)
      ..stream.listen(_quoteNewsListener);
    _quoteNewsBloc.add(QuoteFetchNewsDetailsEvent(news.serialNo!));
  }

  Future<void> _quoteNewsListener(QuoteNewsState state) async {
    if (state is! QuoteNewsProgressState) {
      stopLoader();
    }
    if (state is QuoteNewsProgressState) {
      startLoader();
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
    return Stack(
      children: [
        _buildContentWidget(context),
        _buildAppBar(context),
      ],
    );
  }

  Widget _buildContentWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_50,
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news.headline!,
              style: Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 5,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_10,
                bottom: AppWidgetSize.dimen_10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    AppUtils().getTimeDifferenceFromNow(news.date!),
                    style: Theme.of(context).primaryTextTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (news.caption != null)
              Text(
                news.caption!,
                style: Theme.of(context).primaryTextTheme.labelSmall!,
              ),
            _buildNewsDetailWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Positioned(
      top: AppWidgetSize.dimen_20,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: AppImages.closeIcon(
              context,
              width: AppWidgetSize.dimen_20,
              height: AppWidgetSize.dimen_20,
              color: Theme.of(context).primaryIconTheme.color,
              isColor: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsDetailWidget() {
    return BlocBuilder<QuoteNewsBloc, QuoteNewsState>(
      buildWhen: (QuoteNewsState prevState, QuoteNewsState currentState) {
        return currentState is QuoteNewsDataState ||
            currentState is QuoteNewsFailedState ||
            currentState is QuoteNewsServiceExceptionState;
      },
      builder: (BuildContext ctx, QuoteNewsState state) {
        if (state is QuoteNewsDataState) {
          if (state.quoteNewsDetailModel != null) {
            String memo = state.quoteNewsDetailModel!.corpNewsDetails![0].memo!
                .replaceAll('<P>', '\n\n')
                .replaceAll('<p>', '\n')
                .replaceAll('</p>', '\n')
                .replaceAll('<b>', '')
                .replaceAll('</b>', '')
                .replaceAll('<i>', '')
                .replaceAll('</i>', '');
            String powderedBy = '\nPowered by';

            if (memo.contains("Powered by")) {
              powderedBy = powderedBy + memo.split("Powered by")[1];
              memo = memo.split("Powered by")[0];
            } else {
              powderedBy = ' ';
            }

            return Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_10,
                bottom: AppWidgetSize.dimen_10,
              ),
              child: RichText(
                text: TextSpan(
                  text: memo,
                  style: Theme.of(context).primaryTextTheme.labelSmall,
                  children: [
                    TextSpan(
                      text: powderedBy,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }
        } else if (state is QuoteNewsFailedState ||
            state is QuoteNewsServiceExceptionState) {
          return Center(
            child: Text(
              state.errorMsg,
              style: Theme.of(context).primaryTextTheme.labelSmall,
            ),
          );
        }
        return Container();
      },
    );
  }
}
