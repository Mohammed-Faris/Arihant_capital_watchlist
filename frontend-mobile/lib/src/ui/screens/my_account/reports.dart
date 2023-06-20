import 'package:acml/src/data/store/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:msil_library/utils/config/infoIDConfig.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../blocs/common/screen_state.dart';
import '../../../blocs/my_accounts/client_details/clientdetails_bloc.dart';
import '../../../data/repository/my_account/my_account_repository.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/list_tile_widget.dart';
import '../base/base_screen.dart';

class Reports extends BaseScreen {
  const Reports({
    Key? key,
  }) : super(key: key);

  @override
  ReportsState createState() => ReportsState();
}

class ReportsState extends BaseAuthScreenState<Reports> {
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        allowFileAccess: true,
        allowContentAccess: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));
  List<Widget> getReportsOptions(BuildContext context) {
    return [
      ListTileWidget(
        title: AppLocalizations().arihantLedger,
        subtitle: '',
        onTap: () async {
          await reportOntap();
        },
      ),
      ListTileWidget(
        title: AppLocalizations().fundsHistory,
        subtitle: '',
        onTap: () async {
          await reportOntap();
        },
      ),
      ListTileWidget(
        title: AppLocalizations().cashplreport,
        subtitle: '',
        onTap: () async {
          await reportOntap();
        },
      ),
      ListTileWidget(
        title: AppLocalizations().foplReports,
        subtitle: '',
        onTap: () async {
          await reportOntap();
        },
      ),
      ListTileWidget(
        title: AppLocalizations().holdings,
        subtitle: '',
        onTap: () async {
          await reportOntap();
        },
      ),
      ListTileWidget(
        title: AppLocalizations().dpholdings,
        subtitle: '',
        onTap: () async {
          await reportOntap();
        },
      ),
      ListTileWidget(
        title: AppLocalizations().tradeHistory,
        subtitle: '',
        onTap: () async {
          await reportOntap();
        },
      ),
      ListTileWidget(
        title: AppLocalizations().contractNote,
        subtitle: '',
        onTap: () async {
          await reportOntap();
        },
      ),
    ];
  }

  Future<void> reportOntap() async {
    try {
      String? ssoUrl = await MyAccountRepository().getSSO();
      AppUtils().launchBrowser(ssoUrl);
    } on ServiceException catch (e) {
      if (e.code == InfoIDConfig.invalidSessionCode) {
        handleError(ScreenState()
          ..isInvalidException = true
          ..errorMsg = e.msg
          ..errorCode = e.code);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.reports);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        /* appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: backIconButton(),
              ),
              Padding(
                padding: EdgeInsets.only(left: AppWidgetSize.dimen_25),
                child: CustomTextWidget(
                  AppLocalizations().reports,
                  Theme.of(context).textTheme.headline5,
                ),
              ),
            ],
          ),
          toolbarHeight: AppWidgetSize.dimen_60,
        ), */
        body: SafeArea(
      child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            AppImages.reportsBanner(context,
                width: AppWidgetSize.screenWidth(context)),
            topBar(context),
          ],
        ),
        bodyView(context)
      ])),
    ));
  }

  Container topBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_18, left: 30.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: backIconButton(),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.w),
            child: CustomTextWidget(
                AppLocalizations().reports,
                Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  SizedBox errorView(BuildContext context, ClientdetailsFailedState state) {
    return SizedBox(
        height: AppWidgetSize.screenHeight(context),
        child: Center(
            child: CustomTextWidget(
                state.msg,
                Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error))));
  }

  Widget bodyView(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_15),
        child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_1),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: getReportsOptions(context).length,
            itemBuilder: (context, index) {
              return getReportsOptions(context)[index];
            }));
  }
}
