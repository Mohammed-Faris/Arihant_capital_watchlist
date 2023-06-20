import '../../../../localization/app_localization.dart';
import '../../../navigation/screen_routes.dart';
import '../../base/base_screen.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';

class AddFundsNetBankingErrorScreen extends BaseScreen {
  final dynamic arguments;
  const AddFundsNetBankingErrorScreen({Key? key, this.arguments})
      : super(key: key);

  @override
  AddFundsNetBankingErrorScreenState createState() =>
      AddFundsNetBankingErrorScreenState();
}

class AddFundsNetBankingErrorScreenState
    extends BaseScreenState<AddFundsNetBankingErrorScreen> {
  @override
  String getScreenRoute() {
    return ScreenRoutes.netBankingErrorScreen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        appBar: _buildAppBar(),
        resizeToAvoidBottomInset: true,
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      toolbarHeight: AppWidgetSize.dimen_60,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Column(
        children: [
          _buildAppBarContent(),
        ],
      ),
    );
  }

  Widget _buildAppBarContent() {
    return Container(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_10,
      ),
      width: AppWidgetSize.fullWidth(context),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_30,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _getAppBarLeftContent(),
          ],
        ),
      ),
    );
  }

  Widget _getAppBarLeftContent() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
      ),
      child: Row(
        children: [
          backIconButton(
              onTap: () {
                popNavigation();
              },
              customColor: Theme.of(context).textTheme.displayMedium!.color),
          Padding(
            padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_5,
            ),
            child: CustomTextWidget(
              '',
              Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildErrorImageWidget(),
          _buildUpperCustomTextWidget(),
          _buildLowerCustomTextWidget(),
          _buildNeedHelpWidget()
        ],
      ),
    );
  }

  Widget _buildErrorImageWidget() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_20),
      child: Center(
        child: AppImages.netBankingError(
          context,
          isColor: false,
        ),
      ),
    );
  }

  Widget _buildUpperCustomTextWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_15,
          left: AppWidgetSize.dimen_10,
          right: AppWidgetSize.dimen_10),
      child: Center(
        child: Text(
          AppLocalizations().addFundsNetBankingError1,
          maxLines: 3,
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLowerCustomTextWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_10,
          right: AppWidgetSize.dimen_10),
      child: Center(
        child: Text(
          AppLocalizations().addFundsNetBankingError2,
          maxLines: 5,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildNeedHelpWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_25, bottom: AppWidgetSize.dimen_25),
      child: InkWell(
        onTap: () {
          pushNavigation(ScreenRoutes.addFundHelpNetbankingErrorContentScreen);
        },
        child: Center(
          child: CustomTextWidget(
              AppLocalizations.of(context)!.generalNeedHelp,
              Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w400)),
        ),
      ),
    );
  }
}
