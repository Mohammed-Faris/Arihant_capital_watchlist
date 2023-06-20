import '../../../../blocs/my_funds/choose_bank_list/choose_bank_list_bloc.dart';
import '../../../../localization/app_localization.dart';
import '../../../navigation/screen_routes.dart';
import '../../base/base_screen.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddFundHelpNetbankingErrorContentScreen extends BaseScreen {
  final dynamic arguments;
  const AddFundHelpNetbankingErrorContentScreen({Key? key, this.arguments})
      : super(key: key);

  @override
  AddFundHelpNetbankingErrorContentScreenState createState() =>
      AddFundHelpNetbankingErrorContentScreenState();
}

class AddFundHelpNetbankingErrorContentScreenState
    extends BaseAuthScreenState<AddFundHelpNetbankingErrorContentScreen> {
  late AppLocalizations _appLocalizations;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChooseBankListBloc>(context)
        .add(NetBankListLoadHelpEvent()..isexpanded = false);
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.addFundHelpNetbankingErrorContentScreen;
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _buildBody(context),
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
                _appLocalizations.generalNeedHelp,
                Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildExpansionWidget(),
        ],
      ),
    );
  }

  final ValueNotifier<bool> help1 = ValueNotifier<bool>(false);
  final ValueNotifier<bool> help2 = ValueNotifier<bool>(false);

  Widget _buildExpansionWidget() {
    return Padding(
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_20, right: AppWidgetSize.dimen_5),
      child: Column(
        children: [
          ValueListenableBuilder<bool>(
              valueListenable: help1,
              builder: (context, value, _) {
                return _buildExpansionDataWidget(
                    _appLocalizations.addFundsNetBankingHelpError1,
                    _appLocalizations.addFundsNetBankingHelpError2,
                    false,
                    value);
              }),
          _buildSeperator(),
          ValueListenableBuilder<bool>(
              valueListenable: help2,
              builder: (context, value, _) {
                return _buildExpansionDataWidget(
                    _appLocalizations.addFundsNetBankingHelpError3,
                    '',
                    true,
                    value);
              }),
          _buildSeperator(),
          Padding(
            padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_10,
                right: AppWidgetSize.dimen_20,
                bottom: AppWidgetSize.dimen_10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    help1.value = !help1.value;
                    help2.value = !help2.value;
                  },
                  child: CustomTextWidget(
                      _appLocalizations.viewMore,
                      Theme.of(context)
                          .primaryTextTheme
                          .labelLarge!
                          .copyWith(color: Theme.of(context).primaryColor)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildExpansionDataWidget(
      String headerdata, String bodydata, bool isvalue, bool isExpand) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey("${DateTime.now().millisecondsSinceEpoch}"),
        initiallyExpanded: isExpand,
        collapsedIconColor: Theme.of(context).primaryIconTheme.color,
        title: _buildHeaderWidget(headerdata),
        children: [
          if (isvalue == false) _buildValueWidget(bodydata),
          if (isvalue == true) _buildShowMoreViewWidget(),
        ],
      ),
    );
  }

  Widget _buildHeaderWidget(String value) {
    return CustomTextWidget(
      value,
      Theme.of(context)
          .primaryTextTheme
          .labelSmall!
          .copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildValueWidget(String data) {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_20,
          bottom: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_20,
          right: AppWidgetSize.dimen_20),
      child: Text(
        data,
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildShowMoreViewWidget() {
    return BlocBuilder<ChooseBankListBloc, ChooseBankListState>(
      buildWhen: (previous, current) {
        return current is NetBankListLoadHelpState;
      },
      builder: (context, state) {
        if (state is NetBankListLoadHelpState) {
          return Padding(
            padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_20,
                bottom: AppWidgetSize.dimen_20,
                left: AppWidgetSize.dimen_20,
                right: AppWidgetSize.dimen_20),
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _appLocalizations.addFundsNetBankingHelpError4,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextSpan(
                    text: _appLocalizations.addFundsNetBankingHelpError5,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (state.isexpanded == true)
                    TextSpan(
                      text: _appLocalizations.addFundsNetBankingHelpError6,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  if (state.isexpanded == false) const TextSpan(text: '\n'),
                  TextSpan(
                      text: state.isexpanded == false
                          ? _appLocalizations.showMore
                          : _appLocalizations.showLess,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.none),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          BlocProvider.of<ChooseBankListBloc>(context).add(
                              NetBankListLoadHelpEvent()
                                ..isexpanded = !state.isexpanded);
                        }),
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildSeperator() {
    return Padding(
      padding: EdgeInsets.only(
          right: AppWidgetSize.dimen_20,
          left: AppWidgetSize.dimen_10,
          top: AppWidgetSize.dimen_5),
      child: Container(
        height: 1,
        width: AppWidgetSize.fullWidth(context),
        color: Theme.of(context).dividerColor,
      ),
    );
  }
}
