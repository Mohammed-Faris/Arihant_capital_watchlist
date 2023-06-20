import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/edis/edis_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/keys/edis_keys.dart';
import '../../../localization/app_localization.dart';
import '../../../models/edis/verify_edis_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/edis_web_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../base/base_screen.dart';
import 'uri_parser/uri_parser.dart';

class EdisTpinScreen extends BaseScreen {
  final dynamic arguments;
  const EdisTpinScreen(
  {
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<EdisTpinScreen> createState() => _EdisTpinScreenState();
}

class _EdisTpinScreenState extends BaseAuthScreenState<EdisTpinScreen> {
  late EdisBloc edisBloc;
  late AppLocalizations _appLocalizations;

  String status = '';

  late Edis edisData;

  @override
  void initState() {
    edisData = widget.arguments['edis'];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      edisBloc = BlocProvider.of<EdisBloc>(context)
        ..stream.listen(edisListener);
      edisBloc.add(GenerateTpinEvent(
        edisData.reqTime!,
        edisData.reqId!,
      ));
    });
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.edisTpinScreen);
  }

  Future<void> edisListener(EdisState state) async {
    if (state is! EdisProgressState) {
      if (mounted) {
        stopLoader();
      }
    }
    if (state is EdisProgressState) {
      if (mounted) {
        startLoader();
      }
    } else if (state is GenerateTpinDoneState) {
      status = state.messageModel!;
      setState(() {});
    } else if (state is GenerateTpinFailedState ||
        state is GenerateTpinServiceExceptionState) {
      setState(() {});
      showToast(
        message: state.errorMsg,
        context: context,
        isError: true,
      );
    } else if (state is EdisErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
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
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            status.isNotEmpty ? _buildStatusWidget() : Container(),
            _buildFooterWidget(),
          ],
        ),
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
          AppImages.informationIcon(context),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      height: AppWidgetSize.fullHeight(context),
      padding: EdgeInsets.only(
        left: 30.w,
        right: 30.w,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorizeImageWidget(),
            _buildContainerWithBackground(),
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
            top: 20.w,
            bottom: 20.w,
          ),
          child: Center(
            child: AppImages.authorizeImageIcon(
              context,
              width: AppWidgetSize.dimen_150,
              height: AppWidgetSize.dimen_150,
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
            top: 20.w,
            bottom: 20.w,
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: _appLocalizations.authorizeStatement2,
              style: Theme.of(context).textTheme.labelSmall,
              children: [
                TextSpan(
                  text: _appLocalizations.learnMore,
                  style:
                      Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                          ),
                  // recognizer: TapGestureRecognizer()
                  //   ..onTap = () {
                  //     _showDownloadPoa();
                  //   }
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContainerWithBackground() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 20.w,
      ),
      child: Container(
        width: AppWidgetSize.fullWidth(context) - 60,
        height: AppWidgetSize.dimen_60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            AppWidgetSize.dimen_8,
          ),
          color:
              Theme.of(context).snackBarTheme.backgroundColor!.withOpacity(0.5),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 10.w,
            left: 10.w,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 5.w,
                  right: 10.w,
                ),
                child: AppImages.tpinIcon(context),
              ),
              SizedBox(
                width: AppWidgetSize.dimen_250,
                child: CustomTextWidget(
                  _appLocalizations.tpinStatement,
                  Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusWidget() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 10.w,
      ),
      child: Container(
        width: AppWidgetSize.fullWidth(context),
        height: AppWidgetSize.dimen_120,
        color: Theme.of(context).dividerColor.withOpacity(0.3),
        child: Padding(
          padding: EdgeInsets.only(
            top: 10.w,
            right: 30.w,
            left: 30.w,
            bottom: 10.w,
          ),
          child: SizedBox(
            width: AppWidgetSize.dimen_250,
            child: CustomTextWidget(
              status,
              Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterWidget() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 10.w,
      ),
      child: Center(
        child: gradientButtonWidget(
          onTap: () {
            _showInAppWebView(true);
          },
          width: AppWidgetSize.fullWidth(context) / 1.6,
          key: const Key(continueToCdslKey),
          context: context,
          title: _appLocalizations.continueToCDSL,
          isGradient: true,
          bottom: 0,
        ),
      ),
    );
  }

  Future<void> _showInAppWebView(bool isCdsl) async {
    await showDialog(
      useSafeArea: true,
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return edisWebViewWidget(
          context,
          edisData,isCdsl,
          (Uri url) {
            final UriParser uriParser = UriParser(url);

            Navigator.of(context).pop();
            Navigator.of(context).pop();
            final Map<String, dynamic> returnGroupMapObj = <String, dynamic>{
              'isNsdlAckNeeded': 'false',
            };
            popNavigation(arguments: returnGroupMapObj);

            if (uriParser.getTitle().toLowerCase() ==
                AppConstants.authorizationSuccessful.toLowerCase()) {
              showToast(
                context: context,
                message: uriParser.getMsg(),
              );
            } else if (uriParser.getTitle() ==
                AppConstants.authorizationFailed) {
              showToast(
                context: context,
                message: uriParser.getMsg(),
                isError: true,
              );
            }
          },
          () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            final Map<String, dynamic> returnGroupMapObj = <String, dynamic>{
              'isNsdlAckNeeded': 'false',
            };
            popNavigation(arguments: returnGroupMapObj);
          },
          isTpinScreen: true,
        );
      },
    );
  }
}
