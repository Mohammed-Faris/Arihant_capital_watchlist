// ignore_for_file: non_constant_identifier_names
import 'package:acml/src/data/store/app_store.dart';
import 'package:acml/src/data/store/app_utils.dart';
import 'package:acml/src/ui/styles/app_widget_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants/app_constants.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon(this.icon, {Key? key, this.color, this.height, this.width})
      : super(key: key);
  final String icon;
  final Color? color;
  final dynamic height;
  final dynamic width;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(icon),
        builder: (context, snapshot) {
          return snapshot.data == null
              ? SvgPicture.asset(
                  icon,
                  color: color,
                  height: height,
                  width: width,
                )
              : SvgPicture.string(
                  (snapshot.data!)
                      .replaceAll("#00C802",
                          AppUtils().isLightTheme() ? "#35B350" : "#00C802")
                      .replaceAll("#3F3F3F",
                          AppUtils().isLightTheme() ? "#3F3F3F" : "#F9F9F9"),
                  color: color,
                  height: height,
                  width: width,
                );
        });
  }
}

class AppImages {
  static Color getColor(BuildContext context, Color? color) {
    return (color != null) ? color : Theme.of(context).primaryColor;
  }

  static Widget getSVGImage(
    String url,
    BuildContext context, {
    Color? color,
    dynamic width,
    dynamic height,
    String? iconName,
    bool isColor = true,
  }) {
    return SvgIcon(
      url,
      color: isColor ? color : null,
      height: height,
      width: width,
    );
  }

  static Widget addAlertFill(
    BuildContext context, {
    bool? isColor,
    double? width,
    double? height,
  }) {
    return getSVGImage('lib/assets/images/add_alert_fill.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "add_alert_fill");
  }

  static Widget noBasketOrders(
    BuildContext context, {
    bool? isColor,
    double? width,
    double? height,
  }) {
    return getSVGImage('lib/assets/images/no_basket_orders.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "no_basket_orders.svg");
  }

  static Widget weeklyBackground(BuildContext context,
      {bool? isColor, double? width, double? height, Color? color}) {
    return getSVGImage('lib/assets/images/weekly_back.svg', context,
        isColor: isColor ?? false,
        width: width,
        height: height,
        color: color,
        iconName: "weekly_back");
  }

  static Widget createBasketIcon(BuildContext context,
      {bool? isColor, double? width, double? height, Color? color}) {
    return getSVGImage('lib/assets/images/create_basket_icon.svg', context,
        isColor: isColor ?? false,
        width: width,
        height: height,
        color: color,
        iconName: "create_basket_icon");
  }

  static Widget basketIcon(BuildContext context,
      {bool? isColor, double? width, double? height, Color? color}) {
    return getSVGImage('lib/assets/images/basket_icon.svg', context,
        isColor: isColor ?? false,
        width: width,
        // color: color,
        height: height,
        iconName: "basket_icon");
  }

  static Widget maintanence(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/time.svg', context,
        isColor: false, width: width, height: height, iconName: "arihant_logo");
  }

  static Widget applogo(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/arihant_logo.svg', context,
        isColor: false, width: width, height: height, iconName: "arihant_logo");
  }

  static Widget editIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/edit_icon.svg', context,
        isColor: false, width: width, height: height, iconName: "edit_icon");
  }

  static Widget countIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/count_icon.svg', context,
        isColor: false, width: width, height: height, iconName: "count_icon");
  }

  static Widget noDataAlerts(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/nodata_alerts.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "no_data_alerts");
  }

  static Widget alertMyAccount(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/alert_myaccount_dark.svg'
            : 'lib/assets/images/alert_myaccount.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "arihant_logo");
  }

  static Widget history(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/history_dark.svg'
            : 'lib/assets/images/history.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "history");
  }

  static Widget arihantpluslogo(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/arihant_plus.svg', context,
        isColor: false, width: width, height: height, iconName: "arihant_plus");
  }

  static Widget arihantlaunchlogo(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/arihant_launch.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "arihant_launch");
  }

  static Widget timerUpiLogo(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/upi_transfer.svg', context,
        isColor: false, width: width, height: height, iconName: "upi_transfer");
  }

  static Widget neftRtgs(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/neft_rtgs.svg', context,
        isColor: false, width: width, height: height, iconName: "neft_rtgs");
  }

  static Widget sortArrow(BuildContext context,
      {Color? color, bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/sort_arrow.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "sort_arrow");
  }

  static Widget offline(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/offline_icon.svg', context,
        isColor: false, width: width, height: height, iconName: "offline_icon");
  }

  static Widget netBanking(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/net_banking.svg', context,
        isColor: false, width: width, height: height, iconName: "net_banking");
  }

  static Widget netBankingError(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/net_banking_error.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "netBankingError");
  }

  static Widget netBankingFund(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/netbanking.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "netBankingFund");
  }

  static Widget paymentMode(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/payment_modes.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "payment_modes");
  }

  static DecorationImage splashBackground = DecorationImage(
    image: AppStore().getThemeData() == AppConstants.darkMode
        ? const AssetImage('lib/assets/images/splash_dark.png')
        : const AssetImage('lib/assets/images/splash.png'),
    fit: BoxFit.cover,
  );

  static Widget positionnavigateinfo = Image.asset(
    'lib/assets/images/positionnavigateinfo.png',
    height: 80,
  );

  static Widget nodatawatchlist = Image.asset(
    'lib/assets/images/watchlistnodata.png',
    width: 230.w,
  );

  static Widget networkIssueImage({double? height}) {
    return Image.asset(
      "lib/assets/images/network_issue.png",
      height: height,
    );
  }

  static AssetImage appIconImage() {
    return const AssetImage('lib/assets/images/app_icon.png');
  }

  static AssetImage topLosers() {
    return const AssetImage('lib/assets/images/top_losers.png');
  }

  static AssetImage hand_point() {
    return const AssetImage('lib/assets/images/hand_icon.png');
  }

  static AssetImage money_bag() {
    return const AssetImage('lib/assets/images/money_bag.png');
  }

  static AssetImage au_small_finance() {
    return const AssetImage('lib/assets/images/au_small.png');
  }

  static AssetImage axis_bank() {
    return const AssetImage('lib/assets/images/axis.png');
  }

  static AssetImage bob_bank() {
    return const AssetImage('lib/assets/images/bob.png');
  }

  static AssetImage boi_bank() {
    return const AssetImage('lib/assets/images/boi.png');
  }

  static AssetImage bom_bank() {
    return const AssetImage('lib/assets/images/bom.png');
  }

  static AssetImage canara_bank() {
    return const AssetImage('lib/assets/images/canara_bank.png');
  }

  static AssetImage citi_bank() {
    return const AssetImage('lib/assets/images/default_bank.png');
  }

  static AssetImage csb_bank() {
    return const AssetImage('lib/assets/images/csb.png');
  }

  static AssetImage cub_bank() {
    return const AssetImage('lib/assets/images/cub.png');
  }

  static AssetImage dcb_bank() {
    return const AssetImage('lib/assets/images/dcb.png');
  }

  static AssetImage default_bank() {
    return const AssetImage('lib/assets/images/default_bank.png');
  }

  static AssetImage deutsche_bank() {
    return const AssetImage('lib/assets/images/deutsche_bank.png');
  }

  static AssetImage dhanlaxmi_bank() {
    return const AssetImage('lib/assets/images/dhanlaxmi_bank.png');
  }

  static AssetImage federal_bank() {
    return const AssetImage('lib/assets/images/federal_bank.png');
  }

  static AssetImage hdfc_bank() {
    return const AssetImage('lib/assets/images/hdfc.png');
  }

  static AssetImage icici_bank() {
    return const AssetImage('lib/assets/images/icici.png');
  }

  static AssetImage idbi_bank() {
    return const AssetImage('lib/assets/images/idbi.png');
  }

  static AssetImage idfc_bank() {
    return const AssetImage('lib/assets/images/idfc.png');
  }

  static AssetImage ifdc_first_bank() {
    return const AssetImage('lib/assets/images/idfc_first_bank.png');
  }

  static AssetImage indian_overseas() {
    return const AssetImage('lib/assets/images/indian_overseas.png');
  }

  static AssetImage indian_bank() {
    return const AssetImage('lib/assets/images/indian_bank.png');
  }

  static AssetImage indusind_bank() {
    return const AssetImage('lib/assets/images/indusind_bank.png');
  }

  static AssetImage janata_sahakari_bank() {
    return const AssetImage('lib/assets/images/janata_sahakari_bank.png');
  }

  static AssetImage jk_bank() {
    return const AssetImage('lib/assets/images/jk.png');
  }

  static AssetImage karnataka_bank() {
    return const AssetImage('lib/assets/images/karnataka_bank.png');
  }

  static AssetImage kmb_bank() {
    return const AssetImage('lib/assets/images/kmb.png');
  }

  static AssetImage kvb_bank() {
    return const AssetImage('lib/assets/images/kvb.png');
  }

  static AssetImage lvb_bank() {
    return const AssetImage('lib/assets/images/lvb.png');
  }

  static AssetImage aboutUsimage() {
    return const AssetImage('lib/assets/images/about_us_image.png');
  }

  static AssetImage pnb_bank() {
    return const AssetImage('lib/assets/images/pnb.png');
  }

  static AssetImage punjab_sind_bank() {
    return const AssetImage('lib/assets/images/punjab_sind.png');
  }

  static AssetImage rbl_bank() {
    return const AssetImage('lib/assets/images/rbl.png');
  }

  static AssetImage saraswat_bank() {
    return const AssetImage('lib/assets/images/saraswat_bank.png');
  }

  static AssetImage sbi_bank() {
    return const AssetImage('lib/assets/images/sbi.png');
  }

  static AssetImage tmb_bank() {
    return const AssetImage('lib/assets/images/tmb.png');
  }

  static AssetImage uco_bank() {
    return const AssetImage('lib/assets/images/uco.png');
  }

  static AssetImage union_bank() {
    return const AssetImage('lib/assets/images/union_bank.png');
  }

  static AssetImage yes_bank() {
    return const AssetImage('lib/assets/images/yes_bank.png');
  }

  static AssetImage success() {
    return const AssetImage('lib/assets/images/succcess.png');
  }

  static AssetImage holdingsImage() {
    return const AssetImage('lib/assets/images/Holdings.png');
  }

  static AssetImage holdingDescimg() {
    return const AssetImage("lib/assets/images/holdings_description.png");
  }

  static AssetImage tradeOrders() {
    return const AssetImage("lib/assets/images/orders.png");
  }

  static AssetImage aboutUsBanner() {
    return const AssetImage("lib/assets/images/about_us_banner.png");
  }

  static AssetImage posDescimg() {
    return const AssetImage("lib/assets/images/position_description.png");
  }

  static Widget marketsPullDown(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/markets_down.svg', context,
        isColor: false, width: width, height: height, iconName: "markets_down");
  }

  static Widget settingsBanner(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/settings_banner.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "settingsBanner");
  }

  static Widget reportsBanner(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/reports_banner.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "reportsBanner");
  }

  static Widget atoz(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/a_z.svg', context,
        isColor: false, width: width, height: height, iconName: "bording_logo");
  }

  static Widget dragDrop(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/drag_drop.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "dragDrop");
  }

  static Widget settingsMarkets(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/settings_markets.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "settingsMarkets");
  }

  static Widget cancelMarkets(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/cancel_icon.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "cancelMarkets");
  }

  static Widget ztoa(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/z_a.svg', context,
        isColor: false, width: width, height: height, iconName: "bording_logo");
  }

  static Widget htol(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/h_l.svg', context,
        isColor: false, width: width, height: height, iconName: "bording_logo");
  }

  static Widget ltoh(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/l_h.svg', context,
        isColor: false, width: width, height: height, iconName: "bording_logo");
  }

  static Widget bordingImage1(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/image_1.svg', context,
        isColor: false, width: width, height: height, iconName: "bording_logo");
  }

  static Widget biometric(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/biometric_dark.svg'
            : 'lib/assets/images/biometric.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "biometric");
  }

  static Widget biometricAuth(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/biometric_auth.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "biometric_auth");
  }

  static Widget rotate(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/rotate.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "rotate");
  }

  static Widget changePasswordd(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/change_password_dark.svg'
            : 'lib/assets/images/change_password.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "change_password");
  }

  static Widget helpSupport(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/help_support_dark.svg'
            : 'lib/assets/images/help_support.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "help_support");
  }

  static Widget privacyPolicy(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/privacy_policy_dark.svg'
            : 'lib/assets/images/privacy_policy.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "privacy_policy");
  }

  static Widget pushNotification(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/push_notification_dark.svg'
            : 'lib/assets/images/push_notification.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "push_notification");
  }

  static Widget termsandCondition(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/terms_condition_dark.svg'
            : 'lib/assets/images/terms_condition.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "terms_condition");
  }

  static Widget themesettings(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/theme_settings_dark.svg'
            : 'lib/assets/images/theme_settings.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "theme_settings");
  }

  static Widget verifiedAccount(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/verified_icon.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "verified_icon");
  }

  static Widget bordingImage2(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/image_2.svg', context,
        isColor: false, width: width, height: height, iconName: "bording_logo");
  }

  static Widget bordingImage3(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/image_3.svg', context,
        isColor: false, width: width, height: height, iconName: "bording_logo");
  }

  static Widget backButtonIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/back_icon.svg', context,
        color: color,
        isColor: isColor,
        width: width,
        height: height,
        iconName: "back_icon");
  }

  static Widget eyeOpenIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/eye_open.svg', context,
        color: color, width: width, height: height, iconName: "eye_open");
  }

  static Widget eyeClosedIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/eye_closed.svg', context,
        color: color, width: width, height: height, iconName: "eye_closed");
  }

  static Widget pinDot(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/password_dot.svg', context,
        color: color, width: width, height: height, iconName: "pinDot");
  }

  static Widget mtfIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/mtf_icon_dark.svg'
            : 'lib/assets/images/mtf_icon.svg',
        context,
        color: color,
        width: width,
        height: height,
        iconName: "mtf_icon");
  }

  static Widget nominee(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/nominee_details_dark.svg'
            : 'lib/assets/images/nominee_details.svg',
        context,
        color: color,
        width: width,
        height: height,
        iconName: "nominee_details");
  }

  static Widget nomineeBanner(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/Nominee_banner.svg', context,
        color: color,
        width: width,
        height: height,
        iconName: "nominee_details");
  }

  static Widget mydoc(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/my_documents.svg', context,
        color: color, width: width, height: height, iconName: "my_documents");
  }

  static Widget commodity(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/commodity_dark.svg'
            : 'lib/assets/images/commodity.svg',
        context,
        color: color,
        width: width,
        height: height,
        iconName: "commodity");
  }

  static Widget currency(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/currency_dark.svg'
            : 'lib/assets/images/currency.svg',
        context,
        color: color,
        width: width,
        height: height,
        iconName: "currency");
  }

  static Widget futureOption(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/future_option_dark.svg'
            : 'lib/assets/images/future_option.svg',
        context,
        width: width,
        height: height,
        iconName: "futureOption");
  }

  static Widget calendarIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/calendar.svg', context,
        color: color, width: width, height: height, iconName: "calendar");
  }

  static Widget fingerPrintIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/fingerprint.svg', context,
        color: color, width: width, height: height, iconName: "fingerprint");
  }

  static Widget faceIdIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/face_id.svg', context,
        color: color, width: width, height: height, iconName: "face_id");
  }

  static Widget greenTickIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/green_tick.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "greenTickIcon");
  }

  static Widget equity(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/equity_dark.svg'
            : 'lib/assets/images/equity.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "equity");
  }

  static Widget checkDisable(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/check_disable.svg', context,
        isColor: isColor ?? false,
        width: width,
        color: color,
        height: height,
        iconName: "check_disable");
  }

  static Widget addUnfilledIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/add_list.svg', context,
        color: color,
        isColor: isColor,
        width: width,
        height: height,
        iconName: "addUnfilledIcon");
  }

  static Widget addFilledIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage(
      'lib/assets/images/add.svg',
      context,
      isColor: isColor,
      color: color,
      width: width,
      height: height,
      iconName: "addFilledIcon",
    );
  }

  static Widget airplaneIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/airplane.svg', context,
        isColor: false, width: width, height: height, iconName: "airplaneIcon");
  }

  static Widget bellIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/bell.svg', context,
        isColor: false, width: width, height: height, iconName: "bellIcon");
  }

  static Widget bicycleIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/bicycle.svg', context,
        isColor: false, width: width, height: height, iconName: "bicycleIcon");
  }

  static Widget infoIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/info_icon.svg', context,
        width: width ?? 15.w,
        height: height ?? 15.w,
        isColor: isColor,
        color: color,
        iconName: "info_icon");
  }

  static Widget crystalballIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/crystal_ball.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "crystalballIcon");
  }

  static Widget fireIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/fire.svg', context,
        isColor: false, width: width, height: height, iconName: "fireIcon");
  }

  static Widget gemstoneIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/gemstone.svg', context,
        isColor: false, width: width, height: height, iconName: "gemstoneIcon");
  }

  static Widget heartIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/heart.svg', context,
        isColor: false, width: width, height: height, iconName: "heartIcon");
  }

  static Widget highvoltageIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage(
      'lib/assets/images/high_voltage.svg',
      context,
      isColor: false,
      width: width,
      height: height,
      iconName: "highvoltageIcon",
    );
  }

  static Widget houseIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/house.svg', context,
        isColor: false, width: width, height: height, iconName: "houseIcon");
  }

  static Widget rainbowIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/rainbow.svg', context,
        isColor: false, width: width, height: height, iconName: "rainbowIcon");
  }

  static Widget recycleIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/recycle.svg', context,
        isColor: false, width: width, height: height, iconName: "recycleIcon");
  }

  static Widget rocketIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/rocket.svg', context,
        isColor: false, width: width, height: height, iconName: "rocketicon");
  }

  static Widget starIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/star.svg', context,
        isColor: false, width: width, height: height, iconName: "starIcon");
  }

  static Widget niftyFiftyIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/nifty_50.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "niftyFiftyIcon");
  }

  static Widget bankNiftyIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/bank_nifty.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "bankNiftyIcon");
  }

  static Widget niftyMidcapIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/nifty_midcap.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "niftyMidcapIcon");
  }

  // static Widget sensexIcon(BuildContext context,
  //     {Color? color, double? width, double? height}) {
  //   return getSVGImage('lib/assets/images/nifty_midcap.svg', context,
  //       isColor: false,
  //       width: width,
  //       height: height,
  //       iconName: "sensexIcon");
  // }

  static Widget itServicesIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/it_service.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "itServicesIcon");
  }

  static Widget financeIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/finance.svg', context,
        isColor: false, width: width, height: height, iconName: "financeIcon");
  }

  static Widget pharmaIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/pharma.svg', context,
        isColor: false, width: width, height: height, iconName: "pharmaIcon");
  }

  static Widget metalIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/metal.svg', context,
        isColor: false, width: width, height: height, iconName: "metalIcon");
  }

  static Widget fmcgIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/fmcg.svg', context,
        isColor: false, width: width, height: height, iconName: "fmcgIcon");
  }

  static Widget niftyIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/nifty.svg', context,
        isColor: false, width: width, height: height, iconName: "niftyIcon");
  }

  static Widget sensexIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/sensex.svg', context,
        isColor: false, width: width, height: height, iconName: "sensexIcon");
  }

  static Widget marketDepth(BuildContext context,
      {Color? color, bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/depth_icon.svg', context,
        color: color,
        isColor: isColor ?? false,
        width: width,
        height: height,
        iconName: "depthIcon");
  }

  static Widget automobileIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/automobile.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "automobileIcon");
  }

  static Widget bearIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/bear.svg', context,
        isColor: false, width: width, height: height, iconName: "bearIcon");
  }

  static Widget upGraph(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/up_graph.svg', context,
        isColor: false, width: width, height: height, iconName: "upGraph");
  }

  static Widget downGraph(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/down_graph.svg', context,
        isColor: false, width: width, height: height, iconName: "downGraph");
  }

  static Widget priceUpArrow(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/priceUp.svg', context,
        isColor: false, width: width, height: height, iconName: "priceUpArrow");
  }

  static Widget priceDownArrow(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/priceDown.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "priceDownArrow");
  }

  static Widget bullIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/bull.svg', context,
        isColor: false, width: width, height: height, iconName: "bullIcon");
  }

  static Widget psuIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/psu.svg', context,
        isColor: false, width: width, height: height, iconName: "psuIcon");
  }

  static Widget informationIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/information.svg', context,
        isColor: isColor,
        color: color,
        width: width ?? 15.w,
        height: height ?? 15.w,
        iconName: "informationicon");
  }

  static Widget informationImage(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/search_info.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "informationImage");
  }

  static Widget closeIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/close_icon.svg', context,
        color: color,
        isColor: isColor,
        width: width,
        height: height,
        iconName: "closeIcon");
  }

  static Widget futureLosers(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/future_losers.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "future_gainers");
  }

  static Widget futureGainers(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/future_gainers.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "future_losers");
  }

  static Widget downArrow(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/down_arrow.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "downArrow");
  }

  static Widget rightArrow(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/right_arrow.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "downArrow");
  }

  static Widget rightArrowIos(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/right_arrow_ios.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "right_arrow_ios");
  }

  static Widget sortDisable(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/sort_disable.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "sortDisable");
  }

  static Widget emptyStocks(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/empty_stocks.svg', context,
        isColor: false, width: width, height: height, iconName: "emptyStocks");
  }

  static Widget paymentFailed(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/payment_failed.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "paymentFailed");
  }

  static Widget emptyManageWatchlist(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
      'lib/assets/images/manage_watchlist.svg',
      context,
      isColor: false,
      width: width,
      height: height,
      iconName: "emptyManageWatchlist",
    );
  }

  static Widget globeIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/globe.svg', context,
        isColor: false, width: width, height: height, iconName: "globeIcon");
  }

  static Widget viewWatchlistIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/view_watchlist.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        iconName: "viewWatchlistIcon");
  }

  static Widget predefinedIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/predefined.svg', context,
        color: color, width: width, height: height, iconName: "predefinedIcon");
  }

  static Widget search(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/search.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "search");
  }

  static Widget deleteIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/delete.svg', context,
        color: color, width: width, height: height, iconName: "deleteIcon");
  }

  static Widget dragIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/drag.svg', context,
        color: color, width: width, height: height, iconName: "dragIcon");
  }

  static Widget filterSelectedIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/filter_selected.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "filterSelectedIcon");
  }

  static Widget filterUnSelectedIcon(BuildContext context,
      {bool? isColor, double? width, double? height, Color? color}) {
    return getSVGImage('lib/assets/images/checkbox_disable.svg', context,
        isColor: isColor ?? false,
        width: width,
        color: color,
        height: height,
        iconName: "filterUnSelectedIcon");
  }

  static Widget positionsIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/positions.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "positionsIcon");
  }

  static Widget positionsRedIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/portfolio_red.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "positionsRedIcon");
  }

  static Widget markerIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/marker.svg', context,
        isColor: false, width: width, height: height, iconName: "markerIcon");
  }

  static Widget fiftyWlowIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/52w_low.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "fiftyWlowIcon");
  }

  static Widget fiftyWhighIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/52w_high.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "fiftyWhighIcon");
  }

  static Widget leftSwipeEnabledIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/swipe_left_enable.svg', context,
        color: color,
        isColor: isColor,
        width: width,
        height: height,
        iconName: "leftSwipeEnabledIcon");
  }

  static Widget leftSwipeDisabledIcon(BuildContext context,
      {bool isColor = true, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/swipe_left_disable.svg', context,
        color: color,
        isColor: isColor,
        width: width,
        height: height,
        iconName: "leftSwipeDisabledIcon");
  }

  static Widget rightSwipeEnabledIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/swipe_right_enable.svg', context,
        color: color,
        isColor: isColor,
        width: width,
        height: height,
        iconName: "rightSwipeEnabledIcon");
  }

  static Widget tradeDisable(BuildContext context,
      {bool isColor = false, double? width, double? height, Color? color}) {
    return getSVGImage('lib/assets/images/trade_disable1.svg', context,
        isColor: isColor,
        width: width,
        height: height,
        color: color,
        iconName: "trade_disable1");
  }

  static Widget tradeEnabled(BuildContext context,
      {bool isColor = false, double? width, double? height, Color? color}) {
    return getSVGImage('lib/assets/images/trade_enable.svg', context,
        isColor: isColor,
        width: width,
        height: height,
        color: color,
        iconName: "trade_enable");
    // getSVGImage('lib/assets/images/trade_enable.svg', context,
    //     isColor: false, width: width, height: height, iconName: "trade_enable");
  }

  static Widget fundsDisable(BuildContext context,
      {bool isColor = false, double? width, double? height, Color? color}) {
    return getSVGImage('lib/assets/images/funds_disable1.svg', context,
        isColor: isColor,
        width: width,
        height: height,
        color: color,
        iconName: "funds_disable1");
  }

  static Widget fundsEnabled(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/funds_enable.svg', context,
        isColor: false, width: width, height: height, iconName: "funds_enable");
  }

  static Widget exploreDisable(BuildContext context,
      {bool isColor = false, double? width, double? height, Color? color}) {
    return getSVGImage('lib/assets/images/explore_disable1.svg', context,
        isColor: isColor,
        width: width,
        height: height,
        color: color,
        iconName: "explore_disable1");
  }

  static Widget exploreEnabled(BuildContext context,
      {bool? isColor, double? width, double? height, Color? color}) {
    return getSVGImage('lib/assets/images/explore_enable.svg', context,
        isColor: false,
        width: width,
        height: height,
        color: color,
        iconName: "explore_enable");
  }

  static Widget watchListDisable(BuildContext context,
      {bool isColor = false, double? width, double? height, Color? color}) {
    return getSVGImage('lib/assets/images/watchlist_disable.svg', context,
        isColor: isColor,
        width: width,
        height: height,
        color: color,
        iconName: "watchlist_disable");
  }

  static Widget watchListEnabled(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/wathlist_enable.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "watchlist_enable");
  }

  static Widget stocks(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/stocks_dark.svg'
            : 'lib/assets/images/stocks.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "stocks");
  }

  static Widget rewards(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/rewards_dark.svg'
            : 'lib/assets/images/rewards.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "rewards");
  }

  static Widget ipo(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/ipo_dark.svg'
            : 'lib/assets/images/ipo.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "ipo");
  }

  static Widget readBlog(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/read_blog_dark.svg'
            : 'lib/assets/images/read_blog.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "read_blog");
  }

  static Widget userGuide(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/user_guide_dark.svg'
            : 'lib/assets/images/user_guide.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "user_guide");
  }

  static Widget reportsProblem(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/reports_problem_dark.svg'
            : 'lib/assets/images/reports_problem.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "reports_problem");
  }

  static Widget payments(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/payments_dark.svg'
            : 'lib/assets/images/payments.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "payments");
  }

  static Widget otherInvestments(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/other_investments_dark.svg'
            : 'lib/assets/images/other_investments.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "other_investments");
  }

  static Widget myAccout(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/my_account_dark.svg'
            : 'lib/assets/images/my_accounts.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "my_accounts");
  }

  static Widget myAccoutdisable(BuildContext context,
      {bool isColor = false, double? width, double? height, Color? color}) {
    return getSVGImage('lib/assets/images/my_account_disable.svg', context,
        isColor: isColor,
        width: width,
        height: height,
        color: color,
        iconName: "my_account_disable");
  }

  static Widget myAccoutEnable(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/my_account_enable.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "my_account_enable");
  }

  static Widget bankAccount(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/bank_accounts_dark.svg'
            : 'lib/assets/images/bank_accounts.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "bank_accounts");
  }

  static Widget accountDetails(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/account_details.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "account_details");
  }

  static Widget arihantBalance(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/arihant_balance.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "arihant_balance");
  }

  static Widget funddetails(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/fund_details_dark.svg'
            : 'lib/assets/images/fund_details.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "fund_details");
  }

  static Widget fundhistory(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/fund_history_dark.svg'
            : 'lib/assets/images/fund_history.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "fund_history");
  }

  static Widget calculator(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/calculator_dark.svg'
            : 'lib/assets/images/calculator.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "calculator");
  }

  static Widget logout(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/logout_dark.svg'
            : 'lib/assets/images/logout.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "logout");
  }

  static Widget marginPledge(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/margin_pledge_dark.svg'
            : 'lib/assets/images/margin_pledge.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "margin_pledge");
  }

  static Widget needHelp(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/need_help_dark.svg'
            : 'lib/assets/images/need_help.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "need_help");
  }

  static Widget profileMen(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/profile_men.svg', context,
        isColor: false, width: width, height: height, iconName: "profile_men");
  }

  static Widget profileWomen(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/profile_women.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "profile_women");
  }

  static Widget referEarn(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/refer_earn_dark.svg'
            : 'lib/assets/images/refer_earn.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "refer_earn");
  }

  static Widget reports(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/reports_dark.svg'
            : 'lib/assets/images/reports.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "reports");
  }

  static Widget settings(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/settings_dark.svg'
            : 'lib/assets/images/settings.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "settings");
  }

  static Widget rightArrowSmall(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/right_arrow_small.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "right_arrow_small");
  }

  static Widget readyInvest(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/ready_invest.svg', context,
        isColor: false, width: width, height: height, iconName: "ready_invest");
  }

  static Widget rightSwipeDisabledIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/swipe_right_disable.svg', context,
        color: color,
        isColor: isColor,
        width: width,
        height: height,
        iconName: "rightSwipeDisabledIcon");
  }

  static Widget expandIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/expand.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "expandIcon");
  }

  static Widget collapseIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/collapse.svg', context,
        isColor: false, width: width, height: height, iconName: "collapseIcon");
  }

  static Widget peersSortIcon(BuildContext context,
      {Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/sort.svg', context,
        color: color, width: width, height: height, iconName: "peersSortIcon");
  }

  static Widget bonusIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/bonus_dark.svg'
            : 'lib/assets/images/bonus.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "bonusIcon");
  }

  static Widget rightsIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/rights_dark.svg'
            : 'lib/assets/images/rights.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "rightsIcon");
  }

  static Widget splitIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/split_dark.svg'
            : 'lib/assets/images/split.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "splitIcon");
  }

  static Widget dividendIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/dividend_dark.svg'
            : 'lib/assets/images/dividend.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "dividendIcon");
  }

  static Widget emptyCorporateAction(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/empty_corporate_actions.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "emptyCorporateAction");
  }

  static Widget noDataAction(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/no_data.svg', context,
        isColor: false, width: width, height: height, iconName: "noDataAction");
  }

  static Widget highDisable(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/discovery_high_disable.svg', context,
        isColor: false, width: width, height: height, iconName: "highDisable");
  }

  static Widget highEnable(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/discovery_high_enable.svg', context,
        isColor: false, width: width, height: height, iconName: "highEnable");
  }

  static Widget lowDisable(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/discovery_low_disable.svg', context,
        isColor: false, width: width, height: height, iconName: "lowDisable");
  }

  static Widget lowEnable(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/discovery_low_enable.svg', context,
        isColor: false, width: width, height: height, iconName: "lowEnable");
  }

  static Widget upDownDisable(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        'lib/assets/images/discovery_updown_disable.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "upDownDisable");
  }

  static Widget upDownEnable(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/discovery_updown_enable.svg', context,
        isColor: false, width: width, height: height, iconName: "upDownEnable");
  }

  static Widget sameDisable(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/discovery_same_disable.svg', context,
        isColor: false, width: width, height: height, iconName: "sameDisable");
  }

  static Widget sameEnable(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/discovery_same_enable.svg', context,
        isColor: false, width: width, height: height, iconName: "sameEnable");
  }

  static Widget noDealsImage(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/no_deals.svg', context,
        isColor: false, width: width, height: height, iconName: "noDealsImage");
  }

  static Widget settingsEnable(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/settings_enable.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "settingsEnable");
  }

  static Widget settingsDisable(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/settings_disable.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "settingsDisable");
  }

  static Widget analyticsIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/analytics.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "analyticsIcon");
  }

  static Widget upArrowIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/up_arrow.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "upArrowIcon");
  }

  static Widget greenRadioEnableIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/radio_enable.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "greenRadioEnableIcon");
  }

  static Widget greenRadioDisableIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/radio_disable.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "greenRadioDisableIcon");
  }

  static Widget redRadioEnableIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/checkboc_enable_red.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "redRadioEnableIcon");
  }

  static Widget redRadioDisableIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/checkboc_disable_red.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "redRadioDisableIcon");
  }

  static Widget greenCheckboxEnableIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/checkbox_enable.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "greenCheckboxEnableIcon");
  }

  static Widget redCheckboxEnableIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/checkbox_enable_red.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "redCheckboxEnableIcon");
  }

  static Widget downArrowCircleIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/down_arrow_circle.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "downArrowCircleIcon");
  }

  static Widget upArrowCircleIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/up_arrow_circle.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "upArrowCircleIcon");
  }

  static Widget refreshIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/refresh_icon.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "refreshIcon");
  }

  static Widget qtyIncreaseIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/add_icon.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "qtyIncreaseIcon");
  }

  static Widget addIconMarkets(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/add_icon_markets.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "addIconMarkets");
  }

  static Widget addAlert(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/add_alert.svg', context,
        isColor: false, width: width, height: height, iconName: "add_alert");
  }

  static Widget qtyDecreaseIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/minus_icon.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "qtyDecreaseIcon");
  }

  static Widget tradeHistory(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/trade_history.svg', context,
        isColor: false, width: width, height: height, iconName: "tradeHistory");
  }

  static Widget pendingStatus(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/pending_status.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "pendingStatus");
  }

  static Widget rejectedStatus(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/rejected_status.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "rejectedStatus");
  }

  static Widget executedStatus(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/executed_status.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "executedStatus");
  }

  static Widget close(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/close.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "close");
  }

  static Widget moneyAdded(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/money_added_dark.svg'
            : 'lib/assets/images/money_added.svg',
        context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "moneyAdded");
  }

  static Widget moneyWithdraw(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/money_withdrawan_dark.svg'
            : 'lib/assets/images/money_withdraw.svg',
        context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "moneyWithdraw");
  }

  static Widget closeCross(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/cross_circle.svg', context,
        isColor: false, width: width, height: height, iconName: "close");
  }

  static Widget orderPending(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/order_pending.svg', context,
        isColor: false, width: width, height: height, iconName: "orderPending");
  }

  static Widget orderPlaced(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/order_placed.svg', context,
        isColor: false, width: width, height: height, iconName: "orderPlaced");
  }

  static Widget orderRejected(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/order_rejected.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "orderRejected");
  }

  static Widget successImage(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
      'lib/assets/images/order_confirmed.svg',
      context,
      isColor: false,
      width: width,
      height: height,
      iconName: "successImage",
    );
  }

  static Widget failureImage(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
      'lib/assets/images/order_failed.svg',
      context,
      isColor: false,
      width: width,
      height: height,
      iconName: "failureImage",
    );
  }

  static Widget failImage(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage(
      'lib/assets/images/cancel.svg',
      context,
      isColor: isColor ?? false,
      width: width,
      color: color,
      height: height,
      iconName: "failureImage",
    );
  }

  static Widget noSearchResults(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/no_search_results.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "noSearchResults");
  }

  static Widget swapIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/swap.svg', context,
        isColor: false, width: width, height: height, iconName: "swapIcon");
  }

  static Widget switchAcc(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/switch_dark.svg'
            : 'lib/assets/images/switch account.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "switchacc");
  }

  static Widget escalationmatrix(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/escalation_d.svg'
            : 'lib/assets/images/esclation.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "esclation");
  }

  static Widget copyIcon(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/copy.svg', context,
        isColor: isColor,
        color: color,
        width: width,
        height: height,
        iconName: "copyIcon");
  }

  static Widget axisBanklogo(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/axis.svg', context,
        isColor: false, width: width, height: height, iconName: "axisBanklogo");
  }

  static Widget hdfcBanklogo(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/hdfc.svg', context,
        isColor: false, width: width, height: height, iconName: "hdfcBanklogo");
  }

  static Widget defaultBanklogo(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/banking_icon.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "defaultBanklogo");
  }

  static Widget impsLogo(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/money_icon_dark.svg'
            : 'lib/assets/images/money_icon.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "impsLogo");
  }

  static Widget upiLogo(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/upi_dark.svg'
            : 'lib/assets/images/upi.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "upiLogo");
  }

  static Widget otherupiLogo(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/upi_1.svg', context,
        isColor: false, width: width, height: height, iconName: "otherupiLogo");
  }

  static Widget otherupiLogo_dup(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/upi_2.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "otherupiLogo_dup");
  }

  static Widget upiMoneyLogo(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/upi_icon_dark.svg'
            : 'lib/assets/images/upi_icon.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "upiMoneyLogo");
  }

  static Widget netBankinglogo(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage(
        AppStore().getThemeData() == AppConstants.darkMode
            ? 'lib/assets/images/net_banking_icon_dark.svg'
            : 'lib/assets/images/net_banking_icon.svg',
        context,
        isColor: false,
        width: width,
        height: height,
        iconName: "netBankinglogo");
  }

  static Widget bankNotificationBadgelogo(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/notification_badge.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "bankNotificationBadgelogo");
  }

  static Widget neftIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/timer_badge.svg', context,
        isColor: false, width: width, height: height, iconName: "neftlogo");
  }

  static Widget withdrawalConfirmation(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/withdrawal_confirm.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "withdrawalConfirmation");
  }

  static Widget authorizationLockIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/authorization_lock.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "authorizationLockIcon");
  }

  static Widget authorizationSuccess(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/authorization_green.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "authorizationSuccessIcon");
  }

  static Widget authorizationFail(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/authorization_red.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "authorizationFailIcon");
  }

  static Widget authorizeImageIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/authorize_image.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "authorizeImageIcon");
  }

  static Widget tpinIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/tpin_icon.svg', context,
        isColor: false, width: width, height: height, iconName: "tpinIcon");
  }

  static Widget tickEnable(BuildContext context,
      {bool isColor = false, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/tick_enable.svg', context,
        isColor: false, width: width, height: height, iconName: "tickEnable");
  }

  static Widget tickDisable(BuildContext context,
      {bool? isColor, double? width, double? height, Color? color}) {
    return getSVGImage('lib/assets/images/tick_disable.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "tpinDisable");
  }

  static Widget crossButton(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/cross_red.svg', context,
        isColor: false, width: width, height: height, iconName: "crossButton");
  }

  static Widget notificationIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/notification.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "notificationIcon");
  }

  static Widget notificationNudgeIcon(BuildContext context,
      {bool? isColor, double? width, double? height}) {
    return getSVGImage('lib/assets/images/notification_nudge.svg', context,
        isColor: false,
        width: width,
        height: height,
        iconName: "notificationNudgeIcon");
  }

  static Widget playIcon(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/play_icon.svg', context,
        isColor: isColor!,
        color: color,
        width: width,
        height: height,
        iconName: "playIcon");
  }

  static Widget searchIcon(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/search_icon.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "searchIcon");
  }

  static Widget filterIcon(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/filter_icon.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "filterIcon");
  }

  static Widget buysellIcon(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/buy_icon.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "filterIcon");
  }

  static Widget stopIcon(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/stop.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "stopIcon");
  }

  static Widget stoplossIcon(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/stopLossImage.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "stoplossIcon");
  }

  static Widget liveIcon(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/live.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "liveIcon");
  }

  static Widget watchlist_52high(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/52w_high_info.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "liveIcon");
  }

  static Widget watchlist_52low(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/52w_low_info.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "liveIcon");
  }

  static Widget watchlist_bonus(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/bonus_info.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "watchlist_bonus");
  }

  static Widget watchlist_split(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/split_info.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "watchlist_split");
  }

  static Widget watchlist_exdividend(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/ex_dividend_info.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "watchlist_exdividend");
  }

  static Widget watchlist_cumdividend(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/cum_dividend_info.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "watchlist_cumdividend");
  }

  static Widget watchlist_holding(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/portfolio_info.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "watchlist_holding");
  }

  static Widget watchlist_nse(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/nse_info.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "watchlist_nse");
  }

  static Widget watchlist_bse(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/bse_info.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "watchlist_bse");
  }

  static Widget watchlist_nfo(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/nfo_info.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "watchlist_nfo");
  }

  static Widget watchlist_fando(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/fo_bse_info.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "watchlist_fando");
  }

  static Widget watchlist_cds(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/cds_info.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "watchlist_cds");
  }

  static Widget market_note(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/caution_icon.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "market_note");
  }

  static Widget empty_holdings(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/empty_holdings.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "empty_holdings");
  }

  static Widget transaction(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/transaction.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "transaction");
  }

  static Widget atmTransaction(BuildContext context,
      {bool? isColor, Color? color, double? width, double? height}) {
    return getSVGImage('lib/assets/images/atm_transaction.svg', context,
        isColor: isColor ?? false,
        color: color,
        width: width,
        height: height,
        iconName: "atmTransaction");
  }
}

/// A [ChangeNotifier] that holds the svg text data.
class SVGData with ChangeNotifier {
  /// Holds the `SVG` Formatted Code.
  String code = '';

  SVGData(this.code);

  void updateCode(String previousColor, String newColor) {
    code = code.replaceAll(previousColor, newColor);
    notifyListeners();
  }

  @override
  String toString() => 'SVGData(code:$code)';
}
