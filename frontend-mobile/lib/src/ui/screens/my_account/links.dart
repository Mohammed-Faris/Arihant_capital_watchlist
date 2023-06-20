// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../base/base_screen.dart';

import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';

import '../../../config/app_config.dart';

import '../../widgets/list_tile_widget.dart';

class Links extends BaseScreen {
  const Links({
    Key? key,
  }) : super(key: key);

  @override
  LinksState createState() => LinksState();
}

class LinksState extends BaseAuthScreenState<Links> {
  late AppLocalizations appLocalizations;

  List<ListTileWidget> getSettingsOptions(BuildContext context) {
    return [
      ListTileWidget(
        title: AppLocalizations().ipo,
        subtitle: '',
        onTap: () async {
          String? url = AppConfig.boUrls?.firstWhereOrNull(
              (element) => element["key"] == "ipoLink")?["value"];
          AppUtils().launchBrowser(url);
        },
        leadingImage: CustomTextWidget(
          "01.",
          Theme.of(context).textTheme.labelSmall!.copyWith(
                color: Theme.of(context).primaryTextTheme.titleSmall!.color,
              ),
        ),
      ),
      ListTileWidget(
        title: AppLocalizations().tradetron,
        subtitle: '',
        onTap: () async {
          String? url = AppConfig.boUrls?.firstWhereOrNull(
              (element) => element["key"] == "tradetronLink")?["value"];
          AppUtils().launchBrowser(url);
        },
        leadingImage: CustomTextWidget(
          "02.",
          Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).primaryTextTheme.titleSmall!.color),
        ),
      ),
      ListTileWidget(
        title: AppLocalizations().wealth4me,
        subtitle: '',
        onTap: () async {
          String? url = AppConfig.boUrls?.firstWhereOrNull(
              (element) => element["key"] == "wlth4MeLink")?["value"];
          AppUtils().launchBrowser(url);
        },
        leadingImage: CustomTextWidget(
          "03.",
          Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).primaryTextTheme.titleSmall!.color),
        ),
      ),
      ListTileWidget(
        onTap: () async {
          String? url = AppConfig.boUrls?.firstWhereOrNull(
              (element) => element["key"] == "wlthDeskLink")?["value"];
          await InAppBrowser.openWithSystemBrowser(url: Uri.parse(url ?? ""));
        },
        title: AppLocalizations().wealthdesk,
        subtitle: '',
        leadingImage: CustomTextWidget(
          "04.",
          Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).primaryTextTheme.titleSmall!.color),
        ),
      ),
      ListTileWidget(
        onTap: () async {
          String? url = AppConfig.boUrls?.firstWhereOrNull(
              (element) => element["key"] == "wlthDeskStkBasketLink")?["value"];
          AppUtils().launchBrowser(url);
        },
        title: AppLocalizations().wealthdeskwithbasket,
        subtitle: '',
        leadingImage: CustomTextWidget(
          "05.",
          Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).primaryTextTheme.titleSmall!.color),
        ),
      ),
      ListTileWidget(
        title: AppLocalizations().whatsappreport,
        subtitle: '',
        onTap: () async {
          String? url = AppConfig.boUrls?.firstWhereOrNull(
              (element) => element["key"] == "whatsappReportLink")?["value"];
          await InAppBrowser.openWithSystemBrowser(url: Uri.parse(url ?? ""));
        },
        leadingImage: CustomTextWidget(
          "06.",
          Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).primaryTextTheme.titleSmall!.color),
        ),
      ),
      ListTileWidget(
        title: AppLocalizations().pledgewhatsapp,
        subtitle: '',
        onTap: () async {
          String? url = AppConfig.boUrls?.firstWhereOrNull(
              (element) => element["key"] == "pledgeWhatsappLink")?["value"];
          await InAppBrowser.openWithSystemBrowser(url: Uri.parse(url ?? ""));
        },
        leadingImage: CustomTextWidget(
          "07.",
          Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).primaryTextTheme.titleSmall!.color),
        ),
      ),
      ListTileWidget(
        title: AppLocalizations().socialmediaLink,
        subtitle: '',
        onTap: () async {
          String? url = AppConfig.boUrls?.firstWhereOrNull(
              (element) => element["key"] == "socialMediaLink")?["value"];
          await InAppBrowser.openWithSystemBrowser(url: Uri.parse(url ?? ""));
        },
        leadingImage: CustomTextWidget(
          "08.",
          Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).primaryTextTheme.titleSmall!.color),
        ),
      ),
      ListTileWidget(
        title: AppLocalizations().monthlyNewsletter,
        subtitle: '',
        onTap: () async {
          String? url = AppConfig.boUrls?.firstWhereOrNull(
              (element) => element["key"] == "monthlyNewsletter")?["value"];
          AppUtils().launchBrowser(url);
        },
        leadingImage: CustomTextWidget(
          "09.",
          Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).primaryTextTheme.titleSmall!.color),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
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
                AppLocalizations().links,
                Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        toolbarHeight: AppWidgetSize.dimen_60,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_15),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding:
                      EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_10),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: getSettingsOptions(context).length,
                  itemBuilder: (context, index) {
                    return getSettingsOptions(context)[index];
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
