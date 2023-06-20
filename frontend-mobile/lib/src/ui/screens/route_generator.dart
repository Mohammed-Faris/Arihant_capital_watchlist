import 'dart:io';

import 'package:acml/src/blocs/basket_order/basket_bloc.dart';
import 'package:acml/src/blocs/orderpad_ui/orderpad_ui_bloc.dart';
import 'package:acml/src/models/basket_order/basket_model.dart';
import 'package:acml/src/ui/screens/alerts/my_alerts.dart';
import 'package:acml/src/ui/screens/basket_order/add_basket.dart';
import 'package:acml/src/ui/screens/basket_order/edit_basket.dart';
import 'package:acml/src/ui/screens/campaign/campaign.dart';
import 'package:acml/src/ui/screens/campaign/nominee_campaign.dart';
import 'package:acml/src/ui/screens/markets/bulk_blockdeals.dart';
import 'package:acml/src/ui/screens/markets/markets_fii_dii_screen.dart';
import 'package:acml/src/ui/screens/my_account/t_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/alert_settings/alert_settings_bloc.dart';
import '../../blocs/alerts/alerts_bloc.dart';
import '../../blocs/edis/edis_bloc.dart';
import '../../blocs/holdings/holdings/holdings_bloc.dart';
import '../../blocs/holdings/holdings_detail/holdings_detail_bloc.dart';
import '../../blocs/indices/indices_bloc.dart';
import '../../blocs/init/init_bloc.dart';
import '../../blocs/login/login_bloc.dart';
import '../../blocs/market_status/market_status_bloc.dart';
import '../../blocs/markets/markets_bloc.dart';
import '../../blocs/my_accounts/client_details/clientdetails_bloc.dart';
import '../../blocs/my_funds/add_funds/add_funds_bloc.dart';
import '../../blocs/my_funds/buy_power_info/buy_power_info_bloc.dart';
import '../../blocs/my_funds/choose_bank_list/choose_bank_list_bloc.dart';
import '../../blocs/my_funds/fund_details/fund_details_bloc.dart';
import '../../blocs/my_funds/fund_history/fund_history_bloc.dart';
import '../../blocs/my_funds/funds/my_funds_bloc.dart';
import '../../blocs/my_funds/other_upi/other_upi_bloc.dart';
import '../../blocs/my_funds/withdraw_cash_info/withdraw_cash_info_bloc.dart';
import '../../blocs/my_funds/withdraw_funds/withdraw_funds_bloc.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/order_pad/order_pad_bloc.dart';
import '../../blocs/orders/order_log/order_log_bloc.dart';
import '../../blocs/orders/orders_bloc.dart';
import '../../blocs/orders/trade_history/tradehistory_bloc.dart';
import '../../blocs/positions/position_conversion/position_convertion_bloc.dart';
import '../../blocs/positions/positions_detail/positions_detail_bloc.dart';
import '../../blocs/quote/analysis/quote_analysis_bloc.dart';
import '../../blocs/quote/chart/chart_bloc.dart';
import '../../blocs/quote/corporate_action/quote_corporate_action_bloc.dart';
import '../../blocs/quote/deals/deals_bloc.dart';
import '../../blocs/quote/financials/financials_bloc.dart';
import '../../blocs/quote/financials/financials_view_more/financials_view_more_bloc.dart';
import '../../blocs/quote/futures_option/common_quote/quote_futures_options_bloc.dart';
import '../../blocs/quote/main_quote/quote_bloc.dart';
import '../../blocs/quote/news/quote_news_bloc.dart';
import '../../blocs/quote/overview/quote_overview_bloc.dart';
import '../../blocs/quote/peer/quote_peer_bloc.dart';
import '../../blocs/quote/pivot_points/pivot_points_bloc.dart';
import '../../blocs/quote/technical/technical_bloc.dart';
import '../../blocs/rollover/rollover_bloc.dart';
import '../../blocs/search/search_bloc.dart';
import '../../blocs/sessionvalidation/session_validation_bloc.dart';
import '../../blocs/tab/menu_bottom_tab_bloc.dart';
import '../../blocs/watchlist/watchlist_bloc.dart';
import '../../data/store/app_store.dart';
import '../../data/store/app_utils.dart';
import '../logs/logs.dart';
import '../navigation/menu_bottom_tab_navigation.dart';
import '../navigation/screen_routes.dart';
import '../sessionvalidation/session_validation.dart';
import 'alerts/alert_history.dart';
import 'alerts/alert_settings.dart';
import 'alerts/create_alert.dart';
import 'back_office/arihant_ledger/arihant_ledger_screen.dart';
import 'back_office/contract_note/contract_note_screen.dart';
import 'back_office/pl_cash/pl_cash_screen.dart';
import 'back_office/pl_fo/pl_fo_screen.dart';
import 'basket_order/my_basket.dart';
import 'bording/bording_screen.dart';
import 'edis/edis_screen.dart';
import 'edis/edis_tpin_screen.dart';
import 'holdings/holdings_details_screen.dart';
import 'init/init_config_screen.dart';
import 'login/change_password/change_password_screen.dart';
import 'login/forgot_password/forgot_password_screen.dart';
import 'login/forgot_password/otp_screen_forgetpassword.dart';
import 'login/forgot_password/set_new_password.dart';
import 'login/login_needhelp.dart';
import 'login/login_screen.dart';
import 'login/smart_login/biometric/set_biometric.dart';
import 'login/smart_login/mpin_login_registration/confirm_pin.dart';
import 'login/smart_login/mpin_login_registration/confrimation_screen.dart';
import 'login/smart_login/mpin_login_registration/create_pin.dart';
import 'login/smart_login/smart_login/smart_login.dart';
import 'login/support.dart';
import 'login/unblock_account/unblock_account_screen.dart';
import 'markets/markets_cash/market_movers_detail.dart';
import 'markets/markets_cash/markets_rollover_screen.dart';
import 'my_account/about_us.dart';
import 'my_account/bank_accounts.dart';
import 'my_account/help_and_support.dart';
import 'my_account/links.dart';
import 'my_account/my_account.dart';
import 'my_account/my_profile.dart';
import 'my_account/nominee_details.dart';
import 'my_account/notification_screen.dart';
import 'my_account/reports.dart';
import 'my_account/settings.dart';
import 'my_funds/add_funds/add_fund_help_content_error.dart';
import 'my_funds/add_funds/add_fund_netbanking_error_details.dart';
import 'my_funds/add_funds/add_fund_netbanking_error_help_details.dart';
import 'my_funds/add_funds/add_fund_payment_mode_help.dart';
import 'my_funds/add_funds/add_funds.dart';
import 'my_funds/add_funds/add_funds_imps_transaction.dart';
import 'my_funds/add_funds/other_upi.dart';
import 'my_funds/buy_power_info/buy_power_help_section.dart';
import 'my_funds/buy_power_info/buy_power_info.dart';
import 'my_funds/choose_bank_list/choose_bank_help_section.dart';
import 'my_funds/choose_bank_list/choose_bank_list.dart';
import 'my_funds/fund_details/funds_details.dart';
import 'my_funds/fund_history/fund_history.dart';
import 'my_funds/widgets/timer.dart';
import 'my_funds/withdraw_cash_info/withdrawal_cash_help_section.dart';
import 'my_funds/withdraw_cash_info/withdrawal_cash_info.dart';
import 'my_funds/withdrawal/withdraw_funds.dart';
import 'my_funds/withdrawal/withdraw_funds_confirmation.dart';
import 'order_pad/order_pad_screen.dart';
import 'orders/order_need_help_screen.dart';
import 'orders/orders_detail_screen.dart';
import 'orders/tradehistory.dart';
import 'positions/positions_convert_sheet.dart';
import 'positions/positions_detail_screen.dart';
import 'quote/quote_chart.dart';
import 'quote/quote_financials/view_more/quote_financials_view_more.dart';
import 'quote/quote_option_chain.dart';
import 'quote/quote_screen.dart';
import 'quote/widgets/news_details.dart';
import 'quote/widgets/tradeviewchart.dart';
import 'search/information/information_screen.dart';
import 'search/search_screen.dart';
import 'trades/trades_screen.dart';
import 'watchlist/edit_watchlist/edit_watchlist.dart';
import 'watchlist/manage_watchlist/watchlist_manage.dart';
import 'watchlist/watchlist_infoscreen.dart';
import 'watchlist/watchlist_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  AppStore.currentRoute = settings.name ?? "";
  AppStore.currentArgs = settings.arguments;

  switch (settings.name) {
    case ScreenRoutes.initConfig:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.initConfig,
        ),
        builder: (BuildContext context) {
          return BlocProvider<InitBloc>(
            create: (context) => InitBloc(),
            child: const InitConfigScreen(),
          );
        },
      );
    case ScreenRoutes.onBoardingScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.onBoardingScreen,
        ),
        builder: (BuildContext context) {
          return const BordingScreen();
        },
      );
    case ScreenRoutes.tradeHistory:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.tradeHistory,
        ),
        builder: (BuildContext context) {
          return BlocProvider<TradehistoryBloc>(
              create: (BuildContext context) => TradehistoryBloc(),
              child: const TradeHistoryScreen());
        },
      );
    case ScreenRoutes.myBasket:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.myBasket,
        ),
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => BasketBloc(),
            child: const MyBasket(),
          );
        },
      );
    case ScreenRoutes.addBasket:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.addBasket,
        ),
        builder: (BuildContext context) {
          return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => OrderPadBloc(),
                ),
                BlocProvider(
                  create: (context) => BasketBloc(),
                ),
                BlocProvider(
                  create: (context) => OrdersBloc(),
                ),
                BlocProvider(
                  create: (context) => WatchlistBloc(),
                ),
                BlocProvider(
                  create: (context) => MarketStatusBloc(),
                ),
                BlocProvider(
                  create: (context) => OrderLogBloc(),
                ),
                BlocProvider(
                  create: (context) => AddFundsBloc(),
                ),
              ],
              child: AddBasket(
                settings.arguments as Baskets,
              ));
        },
      );

    case ScreenRoutes.rollOverScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.rollOverScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => RollOverBloc(),
            child: MarketsRollOver(settings.arguments as MarketsRollOverArgs),
          );
        },
      );
    case ScreenRoutes.editBasket:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.editBasket,
        ),
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => BasketBloc(),
            child: EditBasketScreen(arguments: settings.arguments as dynamic),
          );
        },
      );
    case ScreenRoutes.tradesScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.tradesScreen,
        ),
        builder: (BuildContext context) {
          return TradesScreen(
            arguments: settings.arguments as dynamic,
          );
        },
      );
    case ScreenRoutes.tradingViewChart:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.tradingViewChart,
        ),
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => ChartBloc(),
            child: TraddingViewChart(
              settings.arguments as TradingViewChartArgs,
            ),
          );
        },
      );
    case ScreenRoutes.loginScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.loginScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(),
            child: LoginScreen(
              settings.arguments as LoginScreenArgs?,
            ),
          );
        },
      );

    case ScreenRoutes.loginNeedhelp:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.infoScreen,
        ),
        builder: (BuildContext context) {
          return const LoginNeedHelp();
        },
      );
    case ScreenRoutes.setPinScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.setPinScreen,
        ),
        builder: (BuildContext context) {
          return const CreatePinScreen();
        },
      );
    case ScreenRoutes.confirmPinScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.confirmPinScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(),
            child: ConfirmPinScreen(
              arguments: settings.arguments,
            ),
          );
        },
      );
    case ScreenRoutes.confirmationScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.confirmationScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(),
            child: const ConfirmationScreen(),
          );
        },
      );
    case ScreenRoutes.fiidiiScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.fiidiiScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<MarketsBloc>(
            create: (BuildContext context) => MarketsBloc(),
            child: MarketsFIIDII(settings.arguments as MarketFiiDiiArguments),
          );
        },
      );
    case ScreenRoutes.marketsBulkandBlockDeal:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.marketsBulkandBlockDeal,
        ),
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => QuotesDealsBloc(),
            child: MarketsBulkandBlock(
                settings.arguments as MarketsBulkAndBlockDealsArgs),
          );
        },
      );
    case ScreenRoutes.unBlockAccountScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.unBlockAccountScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(),
            child: UnBlockAccountScreen(arguments: settings.arguments),
          );
        },
      );
    case ScreenRoutes.smartLoginScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.smartLoginScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(),
            child: SmartLoginScreen(arguments: settings.arguments),
          );
        },
      );
    case ScreenRoutes.aboutUs:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.aboutUs,
        ),
        builder: (BuildContext context) {
          return const AboutUs();
        },
      );
    // case ScreenRoutes.campaign:
    //   return SlideRoute(
    //     settings: const RouteSettings(
    //       name: ScreenRoutes.campaign,
    //     ),
    //     builder: (BuildContext context) {
    //       return const Campaign();
    //     },
    //   );
    case ScreenRoutes.nomineeCampagin:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.nomineeCampagin,
        ),
        builder: (BuildContext context) {
          return const NomineeCampaign();
        },
      );
    case ScreenRoutes.quoteChart:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.quoteChart,
        ),
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => QuoteBloc(),
            child: QuoteChart(settings.arguments as QuoteChartArgs),
          );
        },
      );
    case ScreenRoutes.changePasswordScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.changePasswordScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(),
            child: ChangePasswordScreen(
                args: settings.arguments as ChangePasswordScreenArgs?),
          );
        },
      );

    case ScreenRoutes.tOtpscreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.tOtpscreen,
        ),
        builder: (BuildContext context) {
          return const Totp();
        },
      );
    case ScreenRoutes.setBiometricScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.setBiometricScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(),
            child: const SetBiometricScreen(),
          );
        },
      );
    case ScreenRoutes.forgetPasswordScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.forgetPasswordScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(),
            child: ForgotPasswordScreen(
              arguments: settings.arguments,
            ),
          );
        },
      );
    case ScreenRoutes.confirmOtpScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.confirmOtpScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(),
            child: ConfirmOtpScreen(arguments: settings.arguments),
          );
        },
      );
    case ScreenRoutes.setNewPasswordScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.setNewPasswordScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(),
            child: NewPasswordScreen(arguments: settings.arguments),
          );
        },
      );
    case ScreenRoutes.reports:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.reports,
        ),
        builder: (BuildContext context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<ClientdetailsBloc>(
                create: (BuildContext context) =>
                    ClientdetailsBloc()..add(ClientdetailsFetchEvent()),
              ),
            ],
            child: const Reports(),
          );
        },
      );
    case ScreenRoutes.settings:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.reports,
        ),
        builder: (BuildContext context) {
          return const Settings();
        },
      );
    case ScreenRoutes.helpAndSupport:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.reports,
        ),
        builder: (BuildContext context) {
          return const HelpAndSupport();
        },
      );

    case ScreenRoutes.alertsScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.alertsScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => AlertsBloc(),
            child: const MyAlerts(),
          );
        },
      );

    case ScreenRoutes.alertHistory:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.alertHistory,
        ),
        builder: (BuildContext context) {
          return BlocProvider(
              create: (context) => AlertsBloc(), child: const AlertsHistory());
        },
      );

    case ScreenRoutes.alertSettings:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.alertSettings,
        ),
        builder: (BuildContext context) {
          return BlocProvider(
              create: (context) => AlertSettingsBloc(),
              child: const AlertSettings());
        },
      );

    case ScreenRoutes.links:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.links,
        ),
        builder: (BuildContext context) {
          return const Links();
        },
      );
    case ScreenRoutes.support:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.support,
        ),
        builder: (BuildContext context) {
          return const SupportPage();
        },
      );
    case ScreenRoutes.homeScreen:
      AppUtils.setAccDetails();

      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.homeScreen,
        ),
        builder: (BuildContext context) {
          final dynamic arguments = settings.arguments;
          return BlocProvider<MenuBottomTabBloc>(
            create: (BuildContext context) => MenuBottomTabBloc(),
            child: BlocProvider<WatchlistBloc>(
              create: (BuildContext context) => WatchlistBloc(),
              child: MenuBottomTabNavigation(arguments: arguments),
            ),
          );
        },
      );
    case ScreenRoutes.watchlistScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.watchlistScreen,
        ),
        builder: (BuildContext context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<WatchlistBloc>(
                create: (BuildContext context) => WatchlistBloc(),
              ),
              BlocProvider<HoldingsBloc>(
                create: (BuildContext context) => HoldingsBloc(),
              ),
              BlocProvider<IndicesBloc>(
                create: (BuildContext context) => IndicesBloc(),
              ),
              BlocProvider<ClientdetailsBloc>(
                create: (BuildContext context) => ClientdetailsBloc(),
              ),
            ],
            child: const WatchlistScreen(),
          );
        },
      );
    case ScreenRoutes.myAccount:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.myAccount,
        ),
        builder: (BuildContext context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => ClientdetailsBloc(),
              ),
              BlocProvider(
                create: (context) => MyFundsBloc(),
              ),
              BlocProvider(
                create: (context) => NotificationBloc(),
              )
            ],
            child: const MyAccount(),
          );
        },
      );
    case ScreenRoutes.myProfile:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.myProfile,
        ),
        builder: (BuildContext context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<ClientdetailsBloc>(
                create: (BuildContext context) =>
                    ClientdetailsBloc()..add(ClientdetailsFetchEvent()),
              ),
            ],
            child: const MyProfile(),
          );
        },
      );
    case ScreenRoutes.nomineeDetails:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.nomineeDetails,
        ),
        builder: (BuildContext context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<ClientdetailsBloc>(
                create: (BuildContext context) =>
                    ClientdetailsBloc()..add(ClientdetailsFetchEvent()),
              ),
            ],
            child: const NomineeDetails(),
          );
        },
      );
    case ScreenRoutes.bankAccounts:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.bankAccounts,
        ),
        builder: (BuildContext context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<ClientdetailsBloc>(
                create: (BuildContext context) =>
                    ClientdetailsBloc()..add(ClientdetailsFetchEvent()),
              ),
            ],
            child: const BankAccount(),
          );
        },
      );
    case ScreenRoutes.watchlistManageScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.watchlistScreen,
        ),
        builder: (BuildContext context) {
          final dynamic arguments = settings.arguments;
          return BlocProvider<WatchlistBloc>.value(
            value: arguments['watchlistBloc'],
            child: BlocProvider<IndicesBloc>.value(
              value: arguments['indicesBloc'],
              child: const WatchlistManageScreen(),
            ),
          );
        },
      );
    case ScreenRoutes.editWatchlistScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.watchlistScreen,
        ),
        builder: (BuildContext context) {
          final dynamic arguments = settings.arguments;
          return BlocProvider<WatchlistBloc>.value(
            value: arguments['watchlistBloc'],
            child: BlocProvider<IndicesBloc>.value(
              value: arguments['indicesBloc'],
              child: EditWatchlistScreen(
                arguments: settings.arguments,
              ),
            ),
          );
        },
      );
    case ScreenRoutes.searchScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.searchScreen,
        ),
        builder: (BuildContext context) {
          final dynamic arguments = settings.arguments;
          return BlocProvider<SearchBloc>(
            create: (BuildContext context) => SearchBloc(),
            child: BlocProvider<WatchlistBloc>.value(
              value: arguments['watchlistBloc'] ?? WatchlistBloc(),
              child: SearchScreen(arguments: settings.arguments ?? {}),
            ),
          );
        },
      );
    case ScreenRoutes.infoScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.infoScreen,
        ),
        builder: (BuildContext context) {
          return SearchInformationScreen();
        },
      );
    case ScreenRoutes.watchlistinfoScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.infoScreen,
        ),
        builder: (BuildContext context) {
          return WatchlistInformationScreen();
        },
      );
    case ScreenRoutes.quoteScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.quoteScreen,
        ),
        builder: (BuildContext context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<QuoteAnalysisBloc>(
                create: (context) => QuoteAnalysisBloc(),
              ),
              BlocProvider<TechnicalBloc>(
                create: (context) => TechnicalBloc(),
              ),
              BlocProvider<QuoteFuturesOptionsBloc>(
                create: (context) => QuoteFuturesOptionsBloc(),
              ),
              BlocProvider<PivotPointsBloc>(
                create: (context) => PivotPointsBloc(),
              ),
              BlocProvider<QuoteBloc>(
                create: (context) => QuoteBloc(),
              ),
              BlocProvider<QuoteFinancialsBloc>(
                create: (context) => QuoteFinancialsBloc(),
              ),
              BlocProvider<QuoteNewsBloc>(
                create: (context) => QuoteNewsBloc(),
              ),
              BlocProvider<QuotesDealsBloc>(
                create: (context) => QuotesDealsBloc(),
              ),
              BlocProvider<MarketsBloc>(
                create: (context) => MarketsBloc(),
              ),
              BlocProvider<QuotePeerBloc>(
                create: (context) => QuotePeerBloc(),
              ),
              BlocProvider<QuoteCorporateActionBloc>(
                create: (context) => QuoteCorporateActionBloc(),
              ),
              BlocProvider<SearchBloc>(
                create: (context) => SearchBloc(),
              ),
              BlocProvider<WatchlistBloc>(
                create: (context) => WatchlistBloc(),
              ),
              BlocProvider<MarketStatusBloc>(
                create: (context) => MarketStatusBloc(),
              ),
              BlocProvider<HoldingsBloc>(
                create: (context) => HoldingsBloc(),
              ),
              BlocProvider<QuoteOverviewBloc>(
                create: (BuildContext context) => QuoteOverviewBloc(),
              ),
              BlocProvider<QuotePeerBloc>(
                create: (BuildContext context) => QuotePeerBloc(),
              ),
              BlocProvider<IndicesBloc>(
                create: (context) => IndicesBloc(),
              ),
            ],
            child: QuoteScreen(
              arguments: settings.arguments,
            ),
          );
        },
      );

    case ScreenRoutes.createAlert:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.createAlert,
        ),
        builder: (BuildContext context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<QuoteBloc>(
                create: (context) => QuoteBloc(),
              ),
              BlocProvider<SearchBloc>(
                create: (context) => SearchBloc(),
              ),
              BlocProvider<WatchlistBloc>(
                create: (context) => WatchlistBloc(),
              ),
              BlocProvider<MarketStatusBloc>(
                create: (context) => MarketStatusBloc(),
              ),
            ],
            child: CreateAlert(
              arguments: settings.arguments,
            ),
          );
        },
      );
    case ScreenRoutes.quoteNewsDetail:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.quoteNewsDetail,
        ),
        builder: (BuildContext context) {
          return BlocProvider<QuoteNewsBloc>(
            create: (context) => QuoteNewsBloc(),
            child: QuoteNewsDetail(
              arguments: settings.arguments,
            ),
          );
        },
      );

    case ScreenRoutes.orderDetailScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.orderDetailScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<OrderLogBloc>(
            create: (context) => OrderLogBloc(),
            child: BlocProvider<OrdersBloc>(
              create: (context) => OrdersBloc(),
              child: BlocProvider<MarketStatusBloc>(
                create: (context) => MarketStatusBloc(),
                child: OrdersDetailScreen(
                  arguments: settings.arguments,
                ),
              ),
            ),
          );
        },
      );
    case ScreenRoutes.orderHelpScreen:
      return SlideRoute(
        settings: const RouteSettings(name: ScreenRoutes.orderHelpScreen),
        builder: (BuildContext context) {
          return NeedHelp(settings.arguments as String);
        },
      );
    case ScreenRoutes.quoteFinancialsViewMore:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.quoteFinancialsViewMore,
        ),
        builder: (BuildContext context) {
          return MultiBlocProvider(
              providers: [
                BlocProvider<QuoteBloc>(
                  create: (context) => QuoteBloc(),
                  child: QuoteFinancialsViewMore(
                    arguments: settings.arguments,
                  ),
                ),
                BlocProvider<WatchlistBloc>(
                  create: (context) => WatchlistBloc(),
                  child: QuoteFinancialsViewMore(
                    arguments: settings.arguments,
                  ),
                ),
                BlocProvider<FinancialsViewMoreBloc>(
                  create: (context) => FinancialsViewMoreBloc(),
                  child: QuoteFinancialsViewMore(
                    arguments: settings.arguments,
                  ),
                ),
              ],
              child: QuoteFinancialsViewMore(
                arguments: settings.arguments,
              ));
        },
      );
    case ScreenRoutes.quoteOptionChain:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.quoteOptionChain,
        ),
        builder: (BuildContext context) {
          return BlocProvider<QuoteBloc>(
            create: (context) => QuoteBloc(),
            child: BlocProvider<QuoteFuturesOptionsBloc>(
              create: (context) => QuoteFuturesOptionsBloc(),
              child: QuoteOptionChain(
                arguments: settings.arguments,
              ),
            ),
          );
        },
      );
    case ScreenRoutes.timerPage:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.timerPage,
        ),
        builder: (BuildContext context) {
          return BlocProvider<OtherUPIBloc>(
            create: (context) => OtherUPIBloc(),
            child: TimerwithLoader(
              arguments: settings.arguments,
            ),
          );
          //return TimerwithLoader(settings.arguments as TimerwithLoaderArgs?);
        },
      );
    case ScreenRoutes.otherUpi:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.otherUpi,
        ),
        builder: (BuildContext context) {
          return BlocProvider<OtherUPIBloc>(
            create: (context) => OtherUPIBloc(),
            child: OtherUPI(
              arguments: settings.arguments,
            ),
          );
        },
      );
    case ScreenRoutes.orderPadScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.orderPadScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => OrderpadUiBloc(),
            child: MultiBlocProvider(
                providers: <BlocProvider<dynamic>>[
                  BlocProvider<AddFundsBloc>(
                    create: (context) => AddFundsBloc(),
                  ),
                  BlocProvider<EdisBloc>(create: (context) => EdisBloc()),
                  BlocProvider<MarketStatusBloc>(
                    create: (context) => MarketStatusBloc(),
                  ),
                  BlocProvider<HoldingsBloc>(
                    create: (context) => HoldingsBloc(),
                  ),
                  BlocProvider<OrderPadBloc>(
                    create: (context) => OrderPadBloc(),
                  ),
                  BlocProvider<OrderpadUiBloc>(
                    create: (context) => OrderpadUiBloc(),
                  ),
                  BlocProvider<QuoteBloc>(
                      create: (BuildContext context) => QuoteBloc())
                ],
                child: OrderPadScreen(
                  arguments: settings.arguments,
                )),
          );
        },
      );

    case ScreenRoutes.positionsConvertScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.positionsConvertScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<PositionConvertionBloc>(
            create: (context) => PositionConvertionBloc(),
            child: PositionsConvertSheet(
              arguments: settings.arguments,
            ),
          );
        },
      );
    case ScreenRoutes.positionsDetailsScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.positionsDetailsScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<QuoteBloc>(
            create: (context) => QuoteBloc(),
            child: BlocProvider<PositionsDetailBloc>(
              create: (context) => PositionsDetailBloc(),
              child: BlocProvider<WatchlistBloc>(
                create: (context) => WatchlistBloc(),
                child: PositionsDetailsScreen(
                  arguments: settings.arguments,
                ),
              ),
            ),
          );
        },
      );

    case ScreenRoutes.holdingsDetailsScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.holdingsDetailsScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<QuoteBloc>(
            create: (context) => QuoteBloc(),
            child: BlocProvider<HoldingsDetailBloc>(
              create: (context) => HoldingsDetailBloc(),
              child: BlocProvider<MarketStatusBloc>(
                create: (context) => MarketStatusBloc(),
                child: BlocProvider<WatchlistBloc>(
                  create: (context) => WatchlistBloc(),
                  child: HoldingsDetailsScreen(
                    arguments: settings.arguments,
                  ),
                ),
              ),
            ),
          );
        },
      );

    case ScreenRoutes.addfundsScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.addfundsScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<AddFundsBloc>(
            create: (context) => AddFundsBloc(),
            child: const AddFundsScreen(),
          );
        },
      );

    case ScreenRoutes.edisScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.edisScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<EdisBloc>(
            create: (context) => EdisBloc(),
            child: EdisScreen(
              arguments: settings.arguments,
            ),
          );
        },
      );

    case ScreenRoutes.chooseBanklistScreen:
      return SlideRoute(
          settings: const RouteSettings(
            name: ScreenRoutes.chooseBanklistScreen,
          ),
          builder: (BuildContext context) {
            return BlocProvider<ChooseBankListBloc>(
              create: (context) => ChooseBankListBloc(),
              child: ChooseBankListScreen(
                arguments: settings.arguments,
              ),
            );
          });

    case ScreenRoutes.chooseBanklistHelpScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.chooseBanklistScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<ChooseBankListBloc>(
            create: (context) => ChooseBankListBloc(),
            child: const ChooseBankListHelpScreen(),
          );
        },
      );

    case ScreenRoutes.buyPowerInfoHelpScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.buyPowerInfoHelpScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<ChooseBankListBloc>(
            create: (context) => ChooseBankListBloc(),
            child: const BuyPowerInfoHelpScreen(),
          );
        },
      );

    case ScreenRoutes.withdrawalCashInfoHelpScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.withdrawalCashInfoHelpScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<ChooseBankListBloc>(
            create: (context) => ChooseBankListBloc(),
            child: const WithdrawalCashInfoHelpScreen(),
          );
        },
      );

    case ScreenRoutes.fundhistoryScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.fundhistoryScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<FundhistoryBloc>(
            create: (context) => FundhistoryBloc(),
            child: const FundsHistoryScreen(),
          );
        },
      );

    case ScreenRoutes.netBankingErrorScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.netBankingErrorScreen,
        ),
        builder: (BuildContext context) {
          return AddFundsNetBankingErrorScreen(
            arguments: settings.arguments,
          );
        },
      );

    case ScreenRoutes.addFundHelpNetbankingErrorContentScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.addFundHelpNetbankingErrorContentScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<ChooseBankListBloc>(
            create: (context) => ChooseBankListBloc(),
            child: const AddFundHelpNetbankingErrorContentScreen(),
          );
        },
      );

    case ScreenRoutes.addfundIMPSScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.addfundIMPSScreen,
        ),
        builder: (BuildContext context) {
          return AddFundsIMPSScreen(
            arguments: settings.arguments,
          );
        },
      );

    case ScreenRoutes.addFundPaymentModeHelpContentScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.addFundPaymentModeHelpContentScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<ChooseBankListBloc>(
            create: (context) => ChooseBankListBloc(),
            child: const AddfundPaymentModeHelp(),
          );
        },
      );

    case ScreenRoutes.logs:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.logs,
        ),
        builder: (BuildContext context) {
          return const Logs();
        },
      );

    case ScreenRoutes.buyPowerInfoScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.buyPowerInfoScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<BuyPowerInfoBloc>(
            create: (context) => BuyPowerInfoBloc(),
            child: BuyPowerInfoScreen(arguments: settings.arguments),
          );
        },
      );

    case ScreenRoutes.withdrawalCashinfoScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.withdrawalCashinfoScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<WithdrawCashInfoBloc>(
            create: (context) => WithdrawCashInfoBloc(),
            child: WithdrawalCashInfoScreen(
              arguments: settings.arguments,
            ),
          );
        },
      );

    case ScreenRoutes.addfundHelpErrorContentScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.addfundHelpErrorContentScreen,
        ),
        builder: (BuildContext context) {
          return AddFundHelpErrorContentScreen(
            arguments: settings.arguments,
          );
        },
      );

    case ScreenRoutes.marketMoversDetailsScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.marketMoversDetailsScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<MarketsBloc>(
            create: (context) => MarketsBloc(),
            child: MarketMoversDetailScreen(
              arguments: settings.arguments,
            ),
          );
        },
      );

    case ScreenRoutes.funddetailsScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.funddetailsScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<FunddetailsBloc>(
            create: (context) => FunddetailsBloc(),
            child: FundsDetailsScreen(
              arguments: settings.arguments,
            ),
          );
        },
      );

    case ScreenRoutes.withdrawfundsScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.withdrawfundsScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<WithdrawFundsBloc>(
            create: (context) => WithdrawFundsBloc(),
            child: WithdrawFundsScreen(
              arguments: settings.arguments,
            ),
          );
        },
      );

    case ScreenRoutes.edisTpinScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.edisTpinScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<EdisBloc>(
            create: (context) => EdisBloc(),
            child: EdisTpinScreen(
              arguments: settings.arguments,
            ),
          );
        },
      );

    case ScreenRoutes.withdrawfundsConfirmationScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.withdrawfundsConfirmationScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<WithdrawFundsBloc>(
            create: (context) => WithdrawFundsBloc(),
            child: WithdrawFundsConfirmationScreen(
              arguments: settings.arguments,
            ),
          );
        },
      );
    case ScreenRoutes.notificationScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.notificationScreen,
        ),
        builder: (BuildContext context) {
          return BlocProvider<NotificationBloc>(
            create: (context) => NotificationBloc(),
            child: const NotificationScreen(),
          );
        },
      );
    case ScreenRoutes.sessionValidation:
      return SlideRoute(
        settings: const RouteSettings(name: ScreenRoutes.sessionValidation),
        builder: (BuildContext context) {
          return MultiBlocProvider(
              providers: <BlocProvider<dynamic>>[
                BlocProvider<SessionValidationBloc>(
                    create: (BuildContext context) => SessionValidationBloc()),
                BlocProvider<QuoteBloc>(
                    create: (BuildContext context) => QuoteBloc())
              ],
              child: SessionValidationScreen(
                settings.arguments,
              ));
        },
      );
    case ScreenRoutes.arihantLedger:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.arihantLedger,
        ),
        builder: (BuildContext context) {
          return const ArihantLedgerScreen();
        },
      );
    case ScreenRoutes.plCashreport:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.plCashreport,
        ),
        builder: (BuildContext context) {
          return const PlCashScreen();
        },
      );

    case ScreenRoutes.plFOreport:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.plFOreport,
        ),
        builder: (BuildContext context) {
          return const PlFOScreen();
        },
      );

    case ScreenRoutes.contractNote:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.contractNote,
        ),
        builder: (BuildContext context) {
          return const ContractNoteScreen();
        },
      );
    default:
      return SlideRoute(
        settings: const RouteSettings(name: ScreenRoutes.initConfig),
        builder: (BuildContext context) {
          return BlocProvider<InitBloc>(
            create: (BuildContext context) => InitBloc(),
            child: const InitConfigScreen(),
          );
        },
      );
  }
}

class SlideRoute extends PageRouteBuilder {
  final Widget Function(BuildContext) builder;
  @override
  final RouteSettings settings;
  SlideRoute({required this.settings, required this.builder})
      : super(
            settings: settings,
            barrierDismissible: true,
            transitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) =>
                builder(context),
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              const begin = Offset(1, 0);
              const end = Offset.zero;
              final tween = Tween(begin: begin, end: end);
              final offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: GestureDetector(
                    onHorizontalDragEnd: (dragEndDetails) {
                      if (Navigator.canPop(context) &&
                          (dragEndDetails.primaryVelocity ?? 0) > 1000 &&
                          Platform.isIOS) {
                        Navigator.pop(context);
                      }
                    },
                    child: child),
              );
            });
}
