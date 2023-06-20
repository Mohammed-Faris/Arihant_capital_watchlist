import 'package:acml/src/data/store/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/my_funds/choose_bank_list/choose_bank_list_bloc.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/my_funds/bank_details_model.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../base/base_screen.dart';

class ChooseBankListScreen extends BaseScreen {
  final dynamic arguments;
  const ChooseBankListScreen({Key? key, this.arguments}) : super(key: key);

  @override
  ChooseBankListScreenState createState() => ChooseBankListScreenState();
}

class ChooseBankListScreenState
    extends BaseAuthScreenState<ChooseBankListScreen> {
  late AppLocalizations _appLocalizations;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<ChooseBankListBloc>(context)
          .add(DispayBankDetailsandShowTickMarkEvent()
            ..bankDetailsModel = widget.arguments['banklistmodel']
            ..resultDataList = widget.arguments['resultbanklist']
            ..selectedRowIndex = widget.arguments['selectedRow']);

      BlocProvider.of<ChooseBankListBloc>(context)
          .stream
          .listen(chooseBankListBlocListner);
    });
  }

  Future<void> chooseBankListBlocListner(ChooseBankListState state) async {
    if (state is ChooseBankListsScreenPopState) {
      Future.delayed(const Duration(seconds: 1), () {
        popNavigation(
          arguments: {'bankdatamodel': state.bankDetailsModel},
        );
      });
    }
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.chooseBanklistScreen;
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
                _appLocalizations.chooseBankList,
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
        children: [
          _buildBankListdetails(),
          _buildNeedHelpWidget(),
        ],
      ),
    );
  }

  Widget _buildNeedHelpWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_15, bottom: AppWidgetSize.dimen_15),
      child: InkWell(
        onTap: () {
          pushNavigation(ScreenRoutes.chooseBanklistHelpScreen);
        },
        child: CustomTextWidget(
            AppLocalizations.of(context)!.generalNeedHelp,
            Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w400)),
      ),
    );
  }

  BlocBuilder<ChooseBankListBloc, ChooseBankListState> _buildBankListdetails() {
    return BlocBuilder<ChooseBankListBloc, ChooseBankListState>(
      buildWhen: (previous, current) {
        return current is DisplayandUpdateChooseBankListselectionState;
      },
      builder: (context, state) {
        if (state is DisplayandUpdateChooseBankListselectionState) {
          return Padding(
            padding: EdgeInsets.all(AppWidgetSize.dimen_10),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_10),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.bankDetailsModel!.banks!.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    BlocProvider.of<ChooseBankListBloc>(context)
                        .add(DispayBankDetailsandShowTickMarkEvent()
                          ..bankDetailsModel = state.bankDetailsModel!
                          ..resultDataList = state.resultDatalist
                          ..selectedRowIndex = index);

                    BlocProvider.of<ChooseBankListBloc>(context)
                        .add(ChooseBankScreenPopEvent());
                  },
                  child: _buildBankListRow(
                    index,
                    state.resultDatalist!.elementAt(index),
                    state.bankDetailsModel!.banks!.elementAt(index),
                  ),
                );
              },
            ),
          );
        }

        return Container();
      },
    );
  }

  Widget _buildBankListRow(
      int index, Map<String, dynamic> data, Banks bankmodelData) {
    return Column(
      children: [
        _buildBankDetails(bankmodelData, data, index),
        _buildSeperatorWidget(),
      ],
    );
  }

  Row _buildBankDetails(
      Banks bankmodelData, Map<String, dynamic> data, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            AppUtils().buildBankLogo(data['bankLogo']),
            _buildBankNameandAccountNumber(data, index),
            if (index == 0) _buildPrimaryCustomTextWidget(),
          ],
        ),
        if (bankmodelData.isBankChoosen == true) _buildTickMarkWidget()
      ],
    );
  }

  Padding _buildSeperatorWidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_10),
      child: Divider(
        thickness: 1.0,
        color: Theme.of(context).dividerColor,
      ),
    );
  }

  Widget _buildTickMarkWidget() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
      child: SizedBox(
        child: AppImages.greenTickIcon(
          context,
          width: AppWidgetSize.dimen_25,
          height: AppWidgetSize.dimen_25,
        ),
      ),
    );
  }

  Widget _buildPrimaryCustomTextWidget() {
    return Container(
      margin: EdgeInsets.only(
          left: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_10),
      decoration: BoxDecoration(
          color: Theme.of(context).snackBarTheme.backgroundColor,
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20)),
      padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 20.w),
      child: CustomTextWidget(
          "Primary",
          Theme.of(context).textTheme.displayMedium?.copyWith(
              fontSize: AppWidgetSize.dimen_15,
              color: Theme.of(context).primaryColor)),
    );
  }

  Widget _buildBankNameandAccountNumber(Map<String, dynamic> data, int index) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
        left: AppWidgetSize.dimen_5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            /*  width: (index == 0)
                ? AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_50
                : AppWidgetSize.fullWidth(context) - AppWidgetSize.dimen_150, */
            child: Text(
              data['bankName'],
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            data['accountno'],
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontSize: AppWidgetSize.fontSize12),
          ),
        ],
      ),
    );
  }
}
