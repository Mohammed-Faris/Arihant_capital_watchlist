import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/app_config.dart';
import '../../../../constants/app_constants.dart';
import '../../../../localization/app_localization.dart';
import '../../../../models/config/config_model.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/card_widget.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../base/base_screen.dart';

class AddFundsIMPSScreen extends BaseScreen {
  final dynamic arguments;
  const AddFundsIMPSScreen({Key? key, this.arguments}) : super(key: key);

  @override
  AddFundsIMPSScreenState createState() => AddFundsIMPSScreenState();
}

class AddFundsIMPSScreenState extends BaseAuthScreenState<AddFundsIMPSScreen> {
  late AppLocalizations _appLocalizations;
  List<Map<String, dynamic>> resultdata = [];
  String userID = '';

  @override
  void initState() {
    super.initState();
    resultdata = widget.arguments['resultbanklist'];
    userID = widget.arguments['userID'];
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        appBar: _buildAppBar(),
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
          left: AppWidgetSize.dimen_15,
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
                _appLocalizations.addmoneyNEFTandIMPS,
                Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }

  Widget _buildIconandDescription(Widget icon, String description) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            icon,
            Padding(
              padding: EdgeInsets.only(
                  left: AppWidgetSize.dimen_10, right: AppWidgetSize.dimen_10),
              child: SizedBox(
                width: AppWidgetSize.halfWidth(context) +
                    AppWidgetSize.halfWidth(context) / 2,
                child: CustomTextWidget(
                    description,
                    Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.left),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
          child: Divider(
            thickness: 1.0,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_20,
            right: AppWidgetSize.dimen_20,
            top: AppWidgetSize.dimen_20),
        child: Column(
          children: [
            _buildIconandDescription(
              AppImages.bankAccount(context),
              AppLocalizations().addFundsImpsTransaction1,
            ),
            _buildBanklistView(),
            _builddescriptionwidget(),
            _buildIconandDescription(
              AppImages.bankAccount(context),
              AppLocalizations().addFundsImpsTransaction2,
            ),
            _buildbankdetailWidget(
                bankdetails: AppConfig.arhtBnkDtls!.banks!.first,
                isSecondWidgetPresent:
                    (AppConfig.arhtBnkDtls!.banks!.length > 1) ? true : false),
            if (AppConfig.arhtBnkDtls!.banks!.length > 1)
              _buildbankdetailWidget(
                  bankdetails: AppConfig.arhtBnkDtls!.banks!.last,
                  isSecondWidget: true,
                  isSecondWidgetPresent: true),
            _buildIconandDescription(
              AppImages.bankAccount(context),
              AppLocalizations().addFundsImpsTransaction3,
            ),
            _buildcontactdescriptionwidget(),
            SizedBox(
              height: AppWidgetSize.dimen_20,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildbankdetailWidget({
    Banks? bankdetails,
    bool isSecondWidget = false,
    bool isSecondWidgetPresent = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: isSecondWidget == false
            ? AppWidgetSize.dimen_20
            : AppWidgetSize.dimen_5,
        bottom: isSecondWidget == false
            ? isSecondWidgetPresent == true
                ? AppWidgetSize.dimen_10
                : AppWidgetSize.dimen_30
            : AppWidgetSize.dimen_30,
      ),
      child: CardWidget(
        width: AppWidgetSize.screenWidth(context),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_20,
              left: AppWidgetSize.dimen_5,
              right: AppWidgetSize.dimen_5,
              bottom: AppWidgetSize.dimen_20),
          child: Column(
            children: [
              _buildBankNameDataWidget(bankdetails!.bankName ?? ""),
              _buildAccountnumberDataWidget(bankdetails.accNo ?? ""),
              _buildAccountTypeDataWidget(bankdetails.accType ?? ""),
              _buildIFSCcodeDataWidget(bankdetails.ifscCode ?? ""),
              _buildBeneficiaryDataWidget(bankdetails.benefName ?? ""),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBeneficiaryDataWidget(String beneficeryName) {
    return _buildRowData(
      AppLocalizations().addFundsImpsTransaction4,
      beneficeryName,
      false,
    );
  }

  Widget _buildBankNameDataWidget(String bankname) {
    return _buildRowData(
      AppLocalizations().addFundsImpsTransaction5,
      bankname,
      false,
    );
  }

  Widget _buildAccountnumberDataWidget(String accountnum) {
    return _buildRowData(
      AppLocalizations().addFundsImpsTransaction6,
      accountnum + userID,
      true,
    );
  }

  Widget _buildAccountTypeDataWidget(String accType) {
    return _buildRowData(
      AppLocalizations().addFundsImpsTransaction7,
      accType,
      false,
    );
  }

  Widget _buildIFSCcodeDataWidget(String ifsccode) {
    return _buildRowData(
      AppLocalizations().addFundsImpsTransaction8,
      ifsccode,
      true,
    );
  }

  Widget _buildRowData(String key, String value, bool iscopy) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_10,
        left: AppWidgetSize.dimen_5,
        right: AppWidgetSize.dimen_5,
        bottom: AppWidgetSize.dimen_10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Row(
            children: [
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              if (iscopy)
                Padding(
                  padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_3,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      showToast(
                        message: AppLocalizations().addFundsImpsTransaction9,
                        context: context,
                      );
                    },
                    child: AppImages.copyIcon(
                      context,
                      color: Theme.of(context).textTheme.labelSmall!.color,
                      isColor: true,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Padding _buildcontactdescriptionwidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_10),
      child: SizedBox(
        width: AppWidgetSize.fullWidth(context),
        child: Text(
          '${_appLocalizations.addFundsImpsTransaction10} ${AppConfig.arhtBnkDtls!.contact ?? ""}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }

  Padding _builddescriptionwidget() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_10, bottom: AppWidgetSize.dimen_30),
      child: SizedBox(
        width: AppWidgetSize.fullWidth(context),
        child: RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            text: _appLocalizations.note,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600),
            children: [
              TextSpan(
                text: _appLocalizations.addFundsImpsTransaction11,
                style: Theme.of(context).textTheme.titleLarge,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanklistView() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
        bottom: AppWidgetSize.dimen_30,
      ),
      child: CardWidget(
        width: AppWidgetSize.screenWidth(context),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_20,
              left: AppWidgetSize.dimen_5,
              right: AppWidgetSize.dimen_5),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_10),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: resultdata.length,
            itemBuilder: (context, index) {
              return _buildBankListRow(
                  index, resultdata.elementAt(index), resultdata.length);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBankListRow(
      int index, Map<String, dynamic> data, int arraylength) {
    return Column(
      children: [
        _buildBankDetails(data, index),
        _buildSeperatorWidget(index, arraylength),
      ],
    );
  }

  Row _buildBankDetails(Map<String, dynamic> data, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildBankLogo(data['bankLogo']),
            Padding(
              padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
              child: _buildBankNameandAccountNumber(data, index),
            ),
          ],
        ),
        if (index == 0) _buildPrimaryCustomTextWidget(),
      ],
    );
  }

  Widget _buildPrimaryCustomTextWidget() {
    return Container(
      margin: EdgeInsets.only(
          left: AppWidgetSize.dimen_5, bottom: AppWidgetSize.dimen_10),
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
            width: (index == 0)
                ? AppWidgetSize.halfWidth(context) - AppWidgetSize.dimen_60
                : AppWidgetSize.fullWidth(context) - AppWidgetSize.dimen_150,
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

  Widget _buildBankLogo(String bankLogo) {
    Map<String, dynamic> banklogomap = {
      AppConstants.AXIS_BANK: AppImages.axis_bank(),
      AppConstants.AU_SMALL_BANK: AppImages.au_small_finance(),
      AppConstants.BOB_BANK: AppImages.bob_bank(),
      AppConstants.BOB_BANK_CORPORATE: AppImages.bob_bank(),
      AppConstants.BOI_BANK: AppImages.boi_bank(),
      AppConstants.BOM_BANK: AppImages.bom_bank(),
      AppConstants.CITI_BANK: AppImages.citi_bank(),
      AppConstants.CSB_BANK: AppImages.csb_bank(),
      AppConstants.CUB_BANK: AppImages.cub_bank(),
      AppConstants.DEFAULT_BANK: AppImages.default_bank(),
      AppConstants.DEUTSCHE_BANK: AppImages.deutsche_bank(),
      AppConstants.HDFC_BANK: AppImages.hdfc_bank(),
      AppConstants.ICICI_BANK: AppImages.icici_bank(),
      AppConstants.IDBI_BANK: AppImages.idbi_bank(),
      AppConstants.INDIAN_BANK: AppImages.indian_bank(),
      AppConstants.INDIAN_OVERSEAS_BANK: AppImages.indian_overseas(),
      AppConstants.INDUSIND_BANK: AppImages.indusind_bank(),
      AppConstants.SARASWAT_BANK: AppImages.saraswat_bank(),
      AppConstants.KARNATAKA_BANK: AppImages.karnataka_bank(),
      AppConstants.LVB_BANK: AppImages.lvb_bank(),
      AppConstants.KMB_BANK: AppImages.kmb_bank(),
      AppConstants.SBI_BANK: AppImages.sbi_bank(),
      AppConstants.KVB_BANK: AppImages.kvb_bank(),
      AppConstants.DHANLAXMI_BANK: AppImages.dhanlaxmi_bank(),
      AppConstants.TMB_BANK: AppImages.tmb_bank(),
      AppConstants.IDFC_FIRST_BANK: AppImages.ifdc_first_bank(),
      AppConstants.FEDERAL_BANK: AppImages.federal_bank(),
      AppConstants.JK_BANK: AppImages.jk_bank(),
      AppConstants.YES_BANK: AppImages.yes_bank(),
      AppConstants.RBL_BANK: AppImages.rbl_bank(),
      AppConstants.UNION_BANK: AppImages.union_bank(),
      AppConstants.PNB_BANK: AppImages.pnb_bank(),
      AppConstants.PNB_BANK_CORPORATE: AppImages.pnb_bank(),
    };

    AssetImage logo = banklogomap[bankLogo];

    return Padding(
      padding: EdgeInsets.only(right: AppWidgetSize.dimen_5),
      child: SizedBox(
        height: AppWidgetSize.dimen_40,
        width: AppWidgetSize.dimen_40,
        child: Image(image: logo),
      ),
    );
  }

  Padding _buildSeperatorWidget(int index, int arraylength) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_5,
        top: AppWidgetSize.dimen_5,
      ),
      child: (index < (arraylength - 1))
          ? Divider(
              thickness: 1.0,
              color: Theme.of(context).dividerColor,
            )
          : SizedBox(
              height: AppWidgetSize.dimen_10,
            ),
    );
  }
}
