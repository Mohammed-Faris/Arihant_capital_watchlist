// ignore_for_file: override_on_non_overriding_member

import 'package:acml/src/config/app_config.dart';
import 'package:acml/src/localization/app_localization.dart';

import '../../../../blocs/my_funds/choose_bank_list/choose_bank_list_bloc.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/webview_widget.dart';
import '../../route_generator.dart';

class AddfundPaymentModeHelp extends StatefulWidget {
  const AddfundPaymentModeHelp({Key? key}) : super(key: key);

  @override
  AddfundPaymentModeHelpState createState() => AddfundPaymentModeHelpState();
}

class AddfundPaymentModeHelpState extends State<AddfundPaymentModeHelp>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    BlocProvider.of<ChooseBankListBloc>(context)
        .add(ChooseBankPaymentModeHelpEvent()..indexvalue = 0);

    _tabController = TabController(length: 4, vsync: this);
    _tabController!.animation!.addListener(() {
      BlocProvider.of<ChooseBankListBloc>(context).add(
          ChooseBankPaymentModeHelpEvent()..indexvalue = _tabController!.index);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: _buildAppBar(),
          leadingWidth: AppWidgetSize.dimen_35,
          toolbarHeight: AppWidgetSize.dimen_300,
          backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildBGView(),
            stretchModes: const [StretchMode.zoomBackground],
          ),
        ),
        body: DefaultTabController(
          length: _tabController!.length,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.zero,
                background: MyTab(_tabController),
                stretchModes: const [StretchMode.zoomBackground],
              ),
              automaticallyImplyLeading: false,
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildPaymentMode(),
                _buildUPITransfer(),
                _buildNetBankingTransfer(),
                _buildNEFTandRTGS(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_10,
            left: AppWidgetSize.dimen_5,
            bottom: AppWidgetSize.dimen_25,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: AppImages.backButtonIcon(
              context,
              color: Theme.of(context).primaryIconTheme.color,
              isColor: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMode() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_20,
            right: AppWidgetSize.dimen_20,
            top: AppWidgetSize.dimen_20,
            bottom: AppWidgetSize.dimen_20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextWidget(AppLocalizations().paymentmodes,
                Theme.of(context).textTheme.displayMedium),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            CustomTextWidget(AppLocalizations().paymentmodesNeedhelp,
                Theme.of(context).textTheme.headlineSmall),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildLogoWidget(AppImages.upiLogo(context)),
                Expanded(
                    child: _buildPaymodeAndDescription(
                        AppLocalizations().upi,
                        AppLocalizations().upiSubtitle,
                        AppLocalizations().free)),
              ],
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildLogoWidget(AppImages.netBankinglogo(context)),
                Expanded(
                    child: _buildPaymodeAndDescription(
                        AppLocalizations().netBanking,
                        AppLocalizations().netBankingSubtitle,
                        AppLocalizations().free)),
              ],
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildLogoWidget(AppImages.defaultBanklogo(context)),
                Expanded(
                    child: _buildPaymodeAndDescription(AppLocalizations().neft,
                        AppLocalizations().neftSubtitle, '')),
              ],
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildLogoWidget(AppImages.offline(context)),
                Expanded(
                    child: _buildPaymodeAndDescription(
                        AppLocalizations().throughOffline, '', '')),
              ],
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            /*  RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Learn ',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  TextSpan(
                      text: 'How to transfer funds using UPI?',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap = () async {}),
                ],
              ),
            ), */
          ],
        ),
      ),
    );
  }

  Widget _buildPaymodeAndDescription(String title, String subtile, String sub) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (sub.isNotEmpty) _buildFreeCustomTextWidget(sub),
            ],
          ),
          if (subtile.isNotEmpty)
            Text(
              subtile,
              overflow: TextOverflow.clip,
              maxLines: 1,
              softWrap: false,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: AppWidgetSize.fontSize12),
            ),
          if (subtile.isEmpty)
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: AppLocalizations().throughOfflineSubtitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: AppWidgetSize.fontSize12),
                  ),
                  TextSpan(
                      text: AppLocalizations().branchLocator,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          Navigator.push(
                            context,
                            SlideRoute(
                              settings: const RouteSettings(
                                name: ScreenRoutes.inAppWebview,
                              ),
                              builder: (BuildContext context) => WebviewWidget(
                                "Contact Us",
                                AppConfig.boUrls![7]["value"],
                              ),
                            ),
                          );
                        }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFreeCustomTextWidget(String value) {
    return Container(
      margin: EdgeInsets.only(
          left: AppWidgetSize.dimen_5, bottom: AppWidgetSize.dimen_5),
      decoration: BoxDecoration(
          color: Theme.of(context).snackBarTheme.backgroundColor,
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20)),
      padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 20.w),
      child: CustomTextWidget(
          value,
          Theme.of(context).textTheme.displayMedium?.copyWith(
              fontSize: AppWidgetSize.fontSize12,
              color: Theme.of(context).primaryColor)),
    );
  }

  Widget _buildLogoWidget(Widget logo) {
    return Padding(
      padding: EdgeInsets.only(right: AppWidgetSize.dimen_5),
      child: logo,
    );
  }

  Widget _buildUPITransfer() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_20,
            right: AppWidgetSize.dimen_15,
            top: AppWidgetSize.dimen_20,
            bottom: AppWidgetSize.dimen_20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextWidget(AppLocalizations().upitransfer,
                Theme.of(context).textTheme.displayMedium),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            CustomTextWidget(AppLocalizations().upitransferContent,
                Theme.of(context).textTheme.headlineSmall),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            _buildStepsWidget(AppLocalizations().upitransferStep1,
                AppLocalizations().upitransferStep1Info),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            _buildStepsWidget(AppLocalizations().upitransferStep2,
                AppLocalizations().upitransferStep2Info),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            _buildStepsWidget(AppLocalizations().upitransferStep3,
                AppLocalizations().upitransferStep3Info),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            _buildStepsWidget(AppLocalizations().upitransferStep4,
                AppLocalizations().upitransferStep4Info),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsWidget(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(
            title,
            Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.left),
        Padding(
          padding: EdgeInsets.only(
              right: AppWidgetSize.dimen_10, top: AppWidgetSize.dimen_20),
          child: Container(
            height: AppWidgetSize.dimen_1,
            color: Theme.of(context).dividerColor,
          ),
        ),
        SizedBox(
          height: AppWidgetSize.dimen_20,
        ),
        CustomTextWidget(subtitle, Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.justify),
      ],
    );
  }

  Widget _buildNetBankingTransfer() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_15,
          top: AppWidgetSize.dimen_20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextWidget(AppLocalizations().netBanking,
                Theme.of(context).textTheme.displayMedium),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            CustomTextWidget(
              AppLocalizations().addFundsPaymentModeHelp1,
              Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            _buildStepsWidget(
              AppLocalizations().addFundsPaymentModeHelp2,
              AppLocalizations().addFundsPaymentModeHelp3,
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            _buildStepsWidget(
              AppLocalizations().addFundsPaymentModeHelp4,
              AppLocalizations().addFundsPaymentModeHelp5,
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            _buildStepsWidget(
              AppLocalizations().addFundsPaymentModeHelp6,
              AppLocalizations().addFundsPaymentModeHelp7,
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            _buildStepsWidget(
              AppLocalizations().addFundsPaymentModeHelp8,
              AppLocalizations().addFundsPaymentModeHelp9,
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image(image: AppImages.hand_point()),
                SizedBox(
                  width: AppWidgetSize.dimen_10,
                ),
                SizedBox(
                  width: AppWidgetSize.halfWidth(context) +
                      AppWidgetSize.halfWidth(context) / 2 -
                      10,
                  child: CustomTextWidget(
                      AppLocalizations().addFundsPaymentModeHelp10,
                      Theme.of(context).textTheme.headlineSmall),
                ),
                SizedBox(
                  height: AppWidgetSize.dimen_100,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNEFTandRTGS() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_20,
                right: AppWidgetSize.dimen_20,
              ),
              child: CustomTextWidget(
                AppLocalizations().addFundsPaymentModeHelp11,
                Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_20,
                right: AppWidgetSize.dimen_20,
              ),
              child: CustomTextWidget(
                AppLocalizations().addFundsPaymentModeHelp12,
                Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: AppWidgetSize.dimen_20, right: AppWidgetSize.dimen_20),
              child: _buildStepsWidget(
                AppLocalizations().upitransferStep1,
                AppLocalizations().addFundsPaymentModeHelp13,
              ),
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_20,
                right: AppWidgetSize.dimen_20,
              ),
              child: _buildStepsWidget(
                AppLocalizations().upitransferStep2,
                AppLocalizations().addFundsPaymentModeHelp14,
              ),
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_20,
                right: AppWidgetSize.dimen_20,
              ),
              child: _buildStepsWidget(
                AppLocalizations().upitransferStep3,
                AppLocalizations().addFundsPaymentModeHelp15,
              ),
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_20,
                right: AppWidgetSize.dimen_20,
              ),
              child: _buildStepsWidget(
                AppLocalizations().upitransferStep4,
                AppLocalizations().addFundsPaymentModeHelp16,
              ),
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_20,
                right: AppWidgetSize.dimen_20,
              ),
              child: _buildStepsWidget(
                AppLocalizations().addFundsPaymentModeHelp17,
                AppLocalizations().addFundsPaymentModeHelp18,
              ),
            ),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            ),
            _buildFooterDescriptionWidget(),
            Padding(
              padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_20,
                right: AppWidgetSize.dimen_20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image(image: AppImages.money_bag()),
                  SizedBox(
                    width: AppWidgetSize.dimen_10,
                  ),
                  SizedBox(
                    width: AppWidgetSize.halfWidth(context),
                    child: CustomTextWidget(
                      AppLocalizations().addFundsPaymentModeHelp19,
                      Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_20,
                right: AppWidgetSize.dimen_20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image(image: AppImages.hand_point()),
                  SizedBox(
                    width: AppWidgetSize.dimen_10,
                  ),
                  SizedBox(
                    width: AppWidgetSize.halfWidth(context) +
                        AppWidgetSize.halfWidth(context) / 2 -
                        10,
                    child: CustomTextWidget(
                      AppLocalizations().addFundsPaymentModeHelp20,
                      Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  SizedBox(
                    height: AppWidgetSize.dimen_100,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFooterDescriptionWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_25, bottom: AppWidgetSize.dimen_25),
      child: Container(
        height: AppWidgetSize.dimen_100,
        color: Theme.of(context).snackBarTheme.backgroundColor,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_20,
            right: AppWidgetSize.dimen_20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppImages.neftIcon(context, isColor: true),
              Padding(
                padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
                child: SizedBox(
                  width:
                      AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_80,
                  child: Text(
                    AppLocalizations().addFundsPaymentModeHelp21,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBGView() {
    return BlocBuilder<ChooseBankListBloc, ChooseBankListState>(
      buildWhen: (previous, current) {
        return current is ChooseBankPaymentModeDoneState;
      },
      builder: (context, state) {
        if (state is ChooseBankPaymentModeDoneState) {
          if (state.indexvalue == 0) {
            return _buildImageWidget(AppImages.paymentMode(context));
          } else if (state.indexvalue == 1) {
            return _buildImageWidget(AppImages.timerUpiLogo(context));
          } else if (state.indexvalue == 2) {
            return _buildImageWidget(AppImages.netBankingFund(context));
          } else if (state.indexvalue == 3) {
            return _buildImageWidget(AppImages.neftRtgs(context));
          }
        }
        return Container();
      },
    );
  }

  Widget _buildImageWidget(dynamic childWidget) {
    return SizedBox(
      child: childWidget,
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}

class MyTab extends StatefulWidget {
  final dynamic tabcontroller;
  const MyTab(this.tabcontroller, {Key? key}) : super(key: key);

  @override
  State<MyTab> createState() => _MyTabState();
}

class _MyTabState extends State<MyTab> {
  @override
  // ignore: avoid_renaming_method_parameters
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: Theme.of(context).snackBarTheme.backgroundColor),
      child: TabBar(
        labelColor: Theme.of(context).primaryColor,
        labelStyle: Theme.of(context)
            .primaryTextTheme
            .titleLarge!
            .copyWith(fontWeight: FontWeight.w600),
        unselectedLabelColor: Theme.of(context).textTheme.bodySmall!.color,
        unselectedLabelStyle: Theme.of(context).textTheme.bodySmall!,
        indicatorColor: Theme.of(context).primaryColor,
        controller: widget.tabcontroller,
        isScrollable: true,
        tabs: [
          Tab(
            text: AppLocalizations().paymentmodes,
          ),
          Tab(
            text: AppLocalizations().upitransfer,
          ),
          Tab(
            text: AppLocalizations().netBanking1,
          ),
          Tab(
            text: AppLocalizations().transferText,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  double maxExtent = 60;

  @override
  double minExtent = 50;
}
