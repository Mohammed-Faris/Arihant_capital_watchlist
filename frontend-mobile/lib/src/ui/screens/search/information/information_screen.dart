import "dart:ui" as ui;

import 'package:acml/src/data/store/app_utils.dart';
import 'package:flutter/material.dart';

import '../../../../localization/app_localization.dart';
import '../../../styles/app_color.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';

// ignore: must_be_immutable
class SearchInformationScreen extends StatelessWidget {
  SearchInformationScreen({Key? key}) : super(key: key);

  final ScrollController _scrollControllerForTopContent = ScrollController();
  late AppLocalizations _appLocalizations;

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Scaffold(
          body: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        NestedScrollView(
          controller: _scrollControllerForTopContent,
          headerSliverBuilder: (BuildContext ctext, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctext),
                sliver: SliverAppBar(
                  titleSpacing: 0,
                  automaticallyImplyLeading: false,
                  expandedHeight:
                      AppWidgetSize.getSize(AppUtils.isTablet ? 360.w : 270.w),
                  pinned: false,
                  toolbarHeight: 0,
                  forceElevated: innerBoxIsScrolled,
                  backgroundColor: AppUtils.isTablet
                      ? const Color(0Xffd4fcdd)
                      : Colors.transparent,
                  flexibleSpace: SizedBox(
                    child: FlexibleSpaceBar(
                      background: _buildTopAppBarContent(ctext),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: _buildBottomContent(context),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.only(
              top: 10.w,
              right: 30.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppImages.closeIcon(
                  context,
                  width: 20.w,
                  height: 20.w,
                  color: Theme.of(context).primaryIconTheme.color,
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTopAppBarContent(BuildContext context) {
    return AppImages.informationImage(
      context,
      height: AppWidgetSize.fullWidth(context),
      width: AppWidgetSize.fullWidth(context),
    );
  }

  Widget _buildBottomContent(BuildContext context) {
    List<Widget> informationWidgetList = [
      Padding(
        padding: EdgeInsets.only(top: AppWidgetSize.dimen_20),
        child: CustomTextWidget(
          _appLocalizations.searchInfoDescrptiontext,
          Theme.of(context).primaryTextTheme.labelSmall,
        ),
      ),
      _buildExpansionRow(
        context,
        _appLocalizations.searchInfotitletext,
        _appLocalizations.searchInfoDescriptiontext1,
        true,
      ),
      Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
      _buildExpansionRow(
        context,
        _appLocalizations.explore,
        _appLocalizations.exploreInfoDescription,
        false,
      ),
      Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      )
    ];
    return Container(
      padding: EdgeInsets.only(
        left: 30.w,
        right: 30.w,
      ),
      color: Theme.of(context).scaffoldBackgroundColor,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
            _appLocalizations.searchInfotext,
            Theme.of(context).textTheme.displayMedium,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    primary: false,
                    shrinkWrap: true,
                    itemCount: informationWidgetList.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return informationWidgetList[index];
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildExpansionRow(
    BuildContext context,
    String title,
    String description,
    bool isRichText,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(
            right: 0,
            left: 0,
            bottom: 5.w,
          ),
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: CustomTextWidget(
            title,
            Theme.of(context).textTheme.displaySmall,
          ),
          iconColor: Theme.of(context).primaryIconTheme.color,
          children: <Widget>[
            isRichText
                ? RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      text: _appLocalizations.searchInfoDescriptiontext1,
                      style: Theme.of(context).primaryTextTheme.labelSmall,
                      children: [
                        TextSpan(
                          text: _appLocalizations.recentSearch,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        TextSpan(
                          text: _appLocalizations.searchInfoDescriptiontext2,
                          style: Theme.of(context).primaryTextTheme.labelSmall,
                        ),
                        TextSpan(
                          text: _appLocalizations.searchInfoDescriptiontext3,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelSmall!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        TextSpan(
                          text: _appLocalizations.searchInfoDescriptiontext4,
                          style: Theme.of(context).primaryTextTheme.labelSmall,
                        ),
                        WidgetSpan(
                          alignment: ui.PlaceholderAlignment.middle,
                          child: AppImages.addUnfilledIcon(
                            context,
                            isColor: true,
                            color: AppColors().positiveColor,
                            width: AppWidgetSize.dimen_18,
                            height: AppWidgetSize.dimen_18,
                          ),
                        ),
                        TextSpan(
                          text: _appLocalizations.searchInfoDescriptiontext5,
                          style: Theme.of(context).primaryTextTheme.labelSmall,
                        ),
                        WidgetSpan(
                          alignment: ui.PlaceholderAlignment.middle,
                          child: AppImages.addFilledIcon(
                            context,
                            width: AppWidgetSize.dimen_18,
                            height: AppWidgetSize.dimen_18,
                          ),
                        ),
                        TextSpan(
                          text: _appLocalizations.searchInfoDescriptiontext6,
                          style: Theme.of(context).primaryTextTheme.labelSmall,
                        ),
                      ],
                    ),
                  )
                : CustomTextWidget(
                    description,
                    Theme.of(context).primaryTextTheme.labelSmall,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 20.w,
        top: 20.w,
      ),
      child: Center(
        child: CustomTextWidget(
          _appLocalizations.searchInfoFooterText,
          Theme.of(context).primaryTextTheme.labelSmall!,
        ),
      ),
    );
  }
}
