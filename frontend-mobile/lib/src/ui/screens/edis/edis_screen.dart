import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:msil_library/utils/exception/service_exception.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../blocs/common/screen_state.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/keys/edis_keys.dart';
import '../../../data/repository/my_account/my_account_repository.dart';
import '../../../localization/app_localization.dart';
import '../../../models/edis/verify_edis_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/edis_web_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/webview_widget.dart';
import '../base/base_screen.dart';
import '../route_generator.dart';
import 'uri_parser/uri_parser.dart';

class EdisScreen extends BaseScreen {
  final dynamic arguments;
  const EdisScreen({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<EdisScreen> createState() => _EdisScreenState();
}

class _EdisScreenState extends BaseAuthScreenState<EdisScreen> {
  late AppLocalizations _appLocalizations;

  late Edis edisData;

  late String segment;

  @override
  void initState() {
    edisData = widget.arguments['edis'];
    segment = widget.arguments['segment'];
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.edisScreen);
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton:
            segment == AppConstants.nsdl ? _buildFooterWidget() : Container(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      elevation: 0.0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: _buildAppBarTitle(),
    );
  }

  Widget _buildAppBarTitle() {
    return Padding(
      padding: EdgeInsets.only(
        left: 10.w,
        right: 10.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              backIconButton(
                customColor: Theme.of(context).textTheme.displayLarge!.color,
                onTap: () {
                  final Map<String, dynamic> returnGroupMapObj =
                      <String, dynamic>{
                    'isNsdlAckNeeded': 'false',
                  };
                  popNavigation(arguments: returnGroupMapObj);
                },
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 10.w,
                ),
                child: CustomTextWidget(
                  _appLocalizations.authorizeTransaction,
                  Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      alignment: segment == AppConstants.nsdl ? null : Alignment.center,
      //  height: AppWidgetSize.screenHeight(context) - 75.w,
      padding: EdgeInsets.only(
        left: 30.w,
        right: 30.w,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAuthorizeImageWidget(),
            if (segment == AppConstants.cdsl)
              Column(
                children: [
                  _buildContainerWithBackground(
                      _appLocalizations.haveTpin,
                      _appLocalizations.verifyTpinAndOtp,
                      _appLocalizations.continueToCDSL,
                      const Key(continueToCdslKey),
                      height: 124.w),
                  _buildContainerWithBackground(
                      _appLocalizations.noTpin,
                      _appLocalizations.noTpinStatement,
                      _appLocalizations.generateTpin,
                      const Key(generateTpinKey),
                      height: 149.w),
                  _buildFooterWidget(),
                ],
              ),
            if (segment == AppConstants.nsdl)
              Padding(
                padding: EdgeInsets.only(top: 15.w),
                child: _buildContainerWithBackground(
                    _appLocalizations.needVerification,
                    _appLocalizations.ndslStatement,
                    _appLocalizations.continueToNSDL,
                    const Key(continueToNdslKey),
                    height: 130.w),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorizeImageWidget() {
    return Wrap(
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: 8.w,
          ),
          child: Center(
            child: AppImages.transaction(
              context,
              width: 210.w,
              height: 170.w,
            ),
          ),
        ),
        Center(
          child: CustomTextWidget(
            _appLocalizations.authorizeStatement1,
            Theme.of(context).primaryTextTheme.titleSmall,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 5.w,
            bottom: 15.w,
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text:
                  '${_appLocalizations.authorizeStatement2}${segment == AppConstants.cdsl ? _appLocalizations.cdsl : _appLocalizations.nsdl}${_appLocalizations.authorizeStatement3}',
              style: Theme.of(context).textTheme.labelSmall,
              children: [
                TextSpan(
                    text: _appLocalizations.learnMore,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .labelSmall!
                        .copyWith(
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                            color: Theme.of(context).primaryColor),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _acknowledgeInfoBottomsheet();
                      }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContainerWithBackground(
    String header,
    String subHeader,
    String buttonTitle,
    Key buttonKey, {
    required double? height,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 15.w,
      ),
      child: Container(
        alignment: Alignment.center,
        width: AppWidgetSize.fullWidth(context) - 60,
        //  height: height ?? 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            AppWidgetSize.dimen_8,
          ),
          color: Theme.of(context).snackBarTheme.backgroundColor,
        ),
        child: Padding(
          padding:
              EdgeInsets.only(left: 10.w, right: 10.w, top: 8.w, bottom: 8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                header,
                Theme.of(context).textTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 5.w,
                  bottom: 10.w,
                ),
                child: CustomTextWidget(
                  subHeader,
                  Theme.of(context).textTheme.labelSmall,
                ),
              ),
              Center(
                child: gradientButtonWidget(
                  onTap: () {
                    if (buttonTitle == _appLocalizations.generateTpin) {
                      pushNavigation(
                        ScreenRoutes.edisTpinScreen,
                        arguments: {
                          'edis': widget.arguments['edis'],
                        },
                      );
                    } else {
                      _showInAppWebView();
                    }
                  },
                  height: 55.w,
                  width: AppWidgetSize.fullWidth(context) / 1.6,
                  key: buttonKey,
                  context: context,
                  title: buttonTitle,
                  isGradient: true,
                  bottom: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterWidget() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5.w,
        left: 30.w,
        right: 30.w,
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: _appLocalizations.authorizeFooter,
          style: Theme.of(context).textTheme.labelSmall,
          children: [
            TextSpan(
              text: _appLocalizations.clickForrekyc,
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                  ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  startLoader();

                  try {
                    String? ssoUrl =
                        await MyAccountRepository().getNomineeUrl("");
                    stopLoader();
                    await Permission.microphone.request();
                    await Permission.camera.request();
                    await Permission.location.request();
                    await Permission.locationWhenInUse.request();
                    await Permission.accessMediaLocation.request();
                    if (mounted) {
                      Navigator.push(
                          context,
                          SlideRoute(
                              settings: const RouteSettings(
                                name: ScreenRoutes.inAppWebview,
                              ),
                              builder: (BuildContext context) =>
                                  WebviewWidget("Re-Kyc", ssoUrl)));
                    }
                  } on ServiceException catch (ex) {
                    stopLoader();
                    handleError(ScreenState()
                      ..errorCode = ex.code
                      ..errorMsg = ex.msg);
                  } catch (e) {
                    stopLoader();
                  }
                },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showInAppWebView() async {
    await showDialog(
      useSafeArea: true,
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return edisWebViewWidget(
          context,
          edisData,
          false,
          (Uri url) {
            final UriParser uriParser = UriParser(url);
            if (segment == AppConstants.cdsl) Navigator.of(context).pop();

            Future.delayed(
                Duration(seconds: segment == AppConstants.nsdl ? 5 : 1), () {
              final Map<String, dynamic> returnGroupMapObj = <String, dynamic>{
                'isNsdlAckNeeded':
                    segment == AppConstants.nsdl ? 'true' : 'false',
              };
              popNavigation(arguments: returnGroupMapObj);

              if (uriParser.getTitle().toLowerCase() ==
                  AppConstants.authorizationSuccessful.toLowerCase()) {
                showToast(
                  context: context,
                  message: uriParser.getMsg(),
                );
              } else {
                showToast(
                  context: context,
                  message: uriParser.getMsg(),
                  isError: true,
                );
              }
            });
          },
          () {
            Future.delayed(
                Duration(seconds: segment == AppConstants.nsdl ? 5 : 0), () {
              Navigator.of(context).pop();
              final Map<String, dynamic> returnGroupMapObj = <String, dynamic>{
                'isNsdlAckNeeded':
                    segment == AppConstants.nsdl ? 'true' : 'false',
              };
              popNavigation(arguments: returnGroupMapObj);
            });
          },
        );
      },
    );
  }

  void _acknowledgeInfoBottomsheet() {
    showInfoBottomsheet(
      _acknowledgeInfoContent(),
      horizontalMargin: false,
      topMargin: false,
    );
  }

  Widget _acknowledgeInfoContent() {
    return SizedBox(
      child: Container(
        height: AppWidgetSize.screenHeight(context) * 0.75,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 32.w,
                left: 24.w,
                right: 24.w,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextWidget(
                    _appLocalizations.authorizeTransaction,
                    Theme.of(context).primaryTextTheme.titleMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: AppImages.closeIcon(
                      context,
                      width: 20.w,
                      height: 20.w,
                      color: Theme.of(context).primaryIconTheme.color,
                      isColor: true,
                    ),
                  )
                ],
              ),
            ),
            Divider(
              thickness: 1,
              color: Theme.of(context).dividerColor,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 20.w,
                      bottom: 8.w,
                      left: AppWidgetSize.dimen_25,
                      right: AppWidgetSize.dimen_25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppImages.atmTransaction(context),
                      Theme(
                        data: ThemeData()
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          expandedAlignment: Alignment.centerLeft,
                          initiallyExpanded: true,
                          tilePadding: EdgeInsets.only(
                            left: 0,
                            right: 0,
                            bottom: 5.w,
                          ),
                          collapsedIconColor:
                              Theme.of(context).primaryIconTheme.color,
                          title: CustomTextWidget(
                            _appLocalizations.edisInfo1,
                            Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.left,
                          ),
                          iconColor: Theme.of(context).primaryIconTheme.color,
                          children: <Widget>[
                            Padding(
                              padding:
                                  EdgeInsets.only(top: AppWidgetSize.dimen_10),
                              child: CustomTextWidget(
                                _appLocalizations.edisInfo2,
                                Theme.of(context).primaryTextTheme.labelSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                      Theme(
                        data: ThemeData()
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          expandedAlignment: Alignment.centerLeft,
                          initiallyExpanded: false,
                          // onExpansionChanged: (bool val) {
                          //   regordExp = false;
                          //   updateState(() {});
                          // },
                          tilePadding: EdgeInsets.only(
                            left: 0,
                            right: 0,
                            bottom: 5.w,
                          ),
                          collapsedIconColor:
                              Theme.of(context).primaryIconTheme.color,
                          title: Padding(
                            padding: EdgeInsets.only(
                              top: AppWidgetSize.dimen_15,
                            ),
                            child: CustomTextWidget(
                              _appLocalizations.edisInfo3,
                              Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          iconColor: Theme.of(context).primaryIconTheme.color,
                          children: <Widget>[
                            Padding(
                              padding:
                                  EdgeInsets.only(top: AppWidgetSize.dimen_5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: CustomTextWidget(
                                  _appLocalizations.edisInfo4,
                                  Theme.of(context).primaryTextTheme.labelSmall,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: AppWidgetSize.dimen_10),
                              child: RichText(
                                textAlign: TextAlign.justify,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: _appLocalizations.edisInfo5,
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .labelSmall!
                                            .copyWith(
                                                fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text: _appLocalizations.edisInfo6,
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .labelSmall!)
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: AppWidgetSize.dimen_10),
                              child: RichText(
                                textAlign: TextAlign.justify,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: _appLocalizations.edisInfo7,
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .labelSmall!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: _appLocalizations.edisInfo8,
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .labelSmall!,
                                    ),
                                    TextSpan(
                                      text: _appLocalizations.edisInfo9,
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .labelSmall!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text: _appLocalizations.edisInfo10,
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .labelSmall!)
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: AppWidgetSize.dimen_10),
                              child: RichText(
                                textAlign: TextAlign.justify,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: _appLocalizations.edisInfo11,
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .labelSmall!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: _appLocalizations.edisInfo12,
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .labelSmall!,
                                    ),
                                    TextSpan(
                                      text: _appLocalizations.edisInfo13,
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .labelSmall!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                      Theme(
                        data: ThemeData()
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          expandedAlignment: Alignment.centerLeft,
                          initiallyExpanded: false,
                          tilePadding: EdgeInsets.only(
                            left: 0,
                            right: 0,
                            bottom: 5.w,
                          ),
                          collapsedIconColor:
                              Theme.of(context).primaryIconTheme.color,
                          title: Padding(
                            padding:
                                EdgeInsets.only(top: AppWidgetSize.dimen_15),
                            child: CustomTextWidget(
                              _appLocalizations.edisInfo14,
                              Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          iconColor: Theme.of(context).primaryIconTheme.color,
                          children: <Widget>[
                            Padding(
                              padding:
                                  EdgeInsets.only(top: AppWidgetSize.dimen_10),
                              child: Padding(
                                padding:
                                    EdgeInsets.only(top: AppWidgetSize.dimen_5),
                                child: RichText(
                                  textAlign: TextAlign.justify,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: _appLocalizations.edisInfo15,
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .labelSmall,
                                      ),
                                      TextSpan(
                                          text: _appLocalizations.edisInfo16,
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .labelSmall!
                                              .copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              await InAppBrowser
                                                  .openWithSystemBrowser(
                                                      url: Uri.parse(
                                                          AppConfig.boUrls![8]
                                                              ["value"]));
                                            }),
                                      TextSpan(
                                        text: _appLocalizations.edisInfo17,
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .labelSmall,
                                      ),
                                      TextSpan(
                                          text: _appLocalizations.edisInfo18,
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .labelSmall!
                                              .copyWith(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.push(
                                                context,
                                                SlideRoute(
                                                    settings:
                                                        const RouteSettings(
                                                      name: ScreenRoutes
                                                          .inAppWebview,
                                                    ),
                                                    builder: (BuildContext
                                                            context) =>
                                                        WebviewWidget(
                                                            "Contact Us",
                                                            AppConfig.boUrls![7]
                                                                ["value"])),
                                              );
                                            }),
                                      TextSpan(
                                          text: ".",
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .labelSmall)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                      Theme(
                        data: ThemeData()
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          expandedAlignment: Alignment.centerLeft,
                          initiallyExpanded: false,
                          // onExpansionChanged: (bool val) {
                          //   regordExp = false;
                          //   updateState(() {});
                          // },
                          tilePadding: EdgeInsets.only(
                            left: 0,
                            right: 0,
                            bottom: 5.w,
                          ),
                          collapsedIconColor:
                              Theme.of(context).primaryIconTheme.color,
                          title: Padding(
                            padding:
                                EdgeInsets.only(top: AppWidgetSize.dimen_15),
                            child: CustomTextWidget(
                              _appLocalizations.edisInfo19,
                              Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          iconColor: Theme.of(context).primaryIconTheme.color,
                          children: <Widget>[
                            Padding(
                              padding:
                                  EdgeInsets.only(top: AppWidgetSize.dimen_5),
                              child: CustomTextWidget(
                                  _appLocalizations.edisInfo20,
                                  Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                      Theme(
                        data: ThemeData()
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          expandedAlignment: Alignment.centerLeft,
                          initiallyExpanded: false,
                          // onExpansionChanged: (bool val) {
                          //   regordExp = false;
                          //   updateState(() {});
                          // },
                          tilePadding: EdgeInsets.only(
                            left: 0,
                            right: 0,
                            bottom: 5.w,
                          ),
                          collapsedIconColor:
                              Theme.of(context).primaryIconTheme.color,
                          title: Padding(
                            padding:
                                EdgeInsets.only(top: AppWidgetSize.dimen_15),
                            child: CustomTextWidget(
                              _appLocalizations.edisInfo21,
                              Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          iconColor: Theme.of(context).primaryIconTheme.color,
                          children: <Widget>[
                            Padding(
                              padding:
                                  EdgeInsets.only(top: AppWidgetSize.dimen_5),
                              child: CustomTextWidget(
                                  _appLocalizations.edisInfo22,
                                  Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                      Theme(
                        data: ThemeData()
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          expandedAlignment: Alignment.centerLeft,
                          initiallyExpanded: false,
                          // onExpansionChanged: (bool val) {
                          //   regordExp = false;
                          //   updateState(() {});
                          // },
                          tilePadding: EdgeInsets.only(
                            left: 0,
                            right: 0,
                            bottom: 5.w,
                          ),
                          collapsedIconColor:
                              Theme.of(context).primaryIconTheme.color,
                          title: Padding(
                            padding:
                                EdgeInsets.only(top: AppWidgetSize.dimen_15),
                            child: CustomTextWidget(
                              _appLocalizations.edisInfo23,
                              Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          iconColor: Theme.of(context).primaryIconTheme.color,
                          children: <Widget>[
                            Padding(
                              padding:
                                  EdgeInsets.only(top: AppWidgetSize.dimen_5),
                              child: CustomTextWidget(
                                  _appLocalizations.edisInfo24,
                                  Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: AppWidgetSize.dimen_15),
                              child: CustomTextWidget(
                                  _appLocalizations.edisInfo25,
                                  Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
