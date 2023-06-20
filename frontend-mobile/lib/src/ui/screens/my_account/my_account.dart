// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/my_accounts/client_details/clientdetails_bloc.dart';
import '../../../blocs/my_funds/funds/my_funds_bloc.dart' as my_fundsbloc;
import '../../../blocs/notification/notification_bloc.dart';
import '../../../blocs/tab/menu_bottom_tab_bloc.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_events.dart';
import '../../../constants/keys/widget_keys.dart';
import '../../../data/repository/my_account/my_account_repository.dart';
import '../../../data/store/app_storage.dart';
import '../../../data/store/app_store.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/my_funds/my_fund_view_updated_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/account_suspended.dart';
import '../../widgets/card_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/list_tile_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/market_indices_widget.dart';
import '../../widgets/refresh_widget.dart';
import '../../widgets/webview_widget.dart';
import '../base/base_screen.dart';
import '../login/smart_login/smart_login/switch_account.dart';
import '../route_generator.dart';

class MyAccount extends BaseScreen {
  const MyAccount({
    Key? key,
  }) : super(key: key);

  @override
  MyAccountState createState() => MyAccountState();
}

class MyAccountState extends BaseAuthScreenState<MyAccount> {
  @override
  void initState() {
    super.initState();
    fetchDetail();
    BlocProvider.of<my_fundsbloc.MyFundsBloc>(context).add(
      my_fundsbloc.GetFundsViewEvent(fetchApi: false),
    );
    BlocProvider.of<my_fundsbloc.MyFundsBloc>(context)
        .add(my_fundsbloc.GetFundsViewUpdatedEvent(fetchApi: false));

    getUnreadNotificationCount();

    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.myAccount);
    if (AppStore().isPushClicked()) {
      Future.delayed(const Duration(milliseconds: 100), () async {
        await pushNavigation(ScreenRoutes.notificationScreen);
      });

      AppStore().setPushClicked(false);
    }
  }

  refreshData() async {
    BlocProvider.of<my_fundsbloc.MyFundsBloc>(context)
        .add(my_fundsbloc.GetFundsViewEvent(fetchApi: true));

    BlocProvider.of<my_fundsbloc.MyFundsBloc>(context)
        .add(my_fundsbloc.GetFundsViewUpdatedEvent(fetchApi: true));
    await MyAccountRepository().getAccountInfo(fetchAgain: true);
  }

  void postSetState({Function()? function}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          if (function != null) {
            function();
          }
        });
      }
    });
  }

  void getUnreadNotificationCount() {
    BlocProvider.of<NotificationBloc>(context).add(
      GetUnreadNotificationCountEvent(),
    );
  }

  fetchDetail() async {
    await MyAccountRepository().getAccountInfo();
    postSetState();
  }

  List<Widget> getMyAccountOptions(BuildContext context) {
    return [
      ListTileWidget(
          title: AppLocalizations().bankAccounts,
          onTap: () {
            pushNavigation(ScreenRoutes.bankAccounts);
          },
          subtitle: AppLocalizations().bankandAutopay,
          leadingImage: AppImages.bankAccount(context)),
      ListTileWidget(
          title: AppLocalizations().reports,
          onTap: () {
            pushNavigation(ScreenRoutes.reports);
          },
          subtitle: AppLocalizations().yourTradingReports,
          leadingImage: AppImages.reports(context)),
      ListTileWidget(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => WebviewWidget(
                    AppLocalizations().refernNEarn, AppConfig.referUrl.trim()),
              ),
            );
          },
          title: AppLocalizations().referandEarn,
          subtitle: AppLocalizations().earnByreference,
          leadingImage: AppImages.referEarn(context)),
      ListTileWidget(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => WebviewWidget(
                    AppLocalizations().marginCalulator,
                    AppConfig.marginCalculatorUrl),
              ),
            );
          },
          title: AppLocalizations().calculator,
          subtitle: AppLocalizations().calculateTradeEarnings,
          leadingImage: AppImages.calculator(context)),
      ListTileWidget(
        title: AppLocalizations().marginPledge,
        subtitle: AppLocalizations().pledgeHoldings,
        leadingImage: AppImages.marginPledge(context),
        otherTitle: AppLocalizations().comingSoon,
        isBackgroundOther: true,
      ),
      if (Featureflag.alerts)
        ListTileWidget(
          title: AppLocalizations().myAlerts,
          subtitle: AppLocalizations().manageAlerts,
          onTap: () {
            pushNavigation(ScreenRoutes.alertsScreen);
          },
          leadingImage: AppImages.alertMyAccount(context),
        ),
      ListTileWidget(
        title: AppLocalizations().links,
        subtitle: '',
        onTap: () {
          pushNavigation(ScreenRoutes.links);
        },
        leadingImage: AppImages.helpSupport(context),
      ),
      ListTileWidget(
          onTap: () {
            pushNavigation(ScreenRoutes.settings);
          },
          title: AppLocalizations().settings,
          subtitle: AppLocalizations().profileSettings,
          leadingImage: AppImages.settings(context)),
      ListTileWidget(
          onTap: () {
            String? url = AppConfig.boUrls?.firstWhereOrNull(
                (element) => element["key"] == "myAccHelpAndSup")?["value"];
            if (url != null) {
              {
                Navigator.push(
                  context,
                  SlideRoute(
                      settings: const RouteSettings(
                        name: ScreenRoutes.inAppWebview,
                      ),
                      builder: (BuildContext context) =>
                          WebviewWidget("Need Help", url)),
                );
              }
            }
          },
          title: AppLocalizations().needHelp,
          subtitle: AppLocalizations().faq,
          leadingImage: AppImages.needHelp(context)),
      ListTileWidget(
          onTap: () {
            String? url = AppConfig.boUrls?.firstWhereOrNull(
                (element) => element["key"] == "myAccHelpAndSup")?["value"];
            if (url != null) {
              {
                Navigator.push(
                  context,
                  SlideRoute(
                      settings: const RouteSettings(
                        name: ScreenRoutes.inAppWebview,
                      ),
                      builder: (BuildContext context) => WebviewWidget(
                          AppLocalizations().escalationMatrix, url)),
                );
              }
            }
          },
          subtitle: "",
          title: AppLocalizations().escalationMatrix,
          leadingImage: AppImages.escalationmatrix(context)),
      ListTileWidget(
          title: AppLocalizations().switchAccount,
          subtitle: '',
          onTap: () async {
            await SwitchAccount.switchAccount(context, callback: () async {
              try {
                await onSwitchAccount();
                handleLogout("", false, true);
              } catch (e) {
                handleLogout("", false, true);
              }
            });
          },
          leadingImage: AppImages.switchAcc(context)),
      ListTileWidget(
          title: AppLocalizations().logout,
          subtitle: '',
          onTap: () {
            logoutButtonPressed();
          },
          leadingImage: AppImages.logout(context)),
    ];
  }

  onSwitchAccount() {
    BlocProvider.of<MenuBottomTabBloc>(context).add(
      LogoutEvent(false, true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(),
        body: bodyWidget(context),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      elevation: 0.0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
              margin: EdgeInsets.only(right: AppWidgetSize.dimen_10),
              child: const MarketIndicesTopWidget()),
          Container(
            margin: EdgeInsets.only(right: 10.w),
            child: _buildNotificationIconBloc(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIconBloc() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      buildWhen: (NotificationState previous, NotificationState current) {
        return current is UnreadUserNotificationCountState;
      },
      builder: (context, state) {
        if (state is UnreadUserNotificationCountState) {
          if (state.unreadCount.isNotEmpty &&
              AppUtils().intValue(state.unreadCount) > 0) {
            return GestureDetector(
              onTap: () async {
                pushNavigation(ScreenRoutes.notificationScreen);
                getUnreadNotificationCount();
              },
              child: AppImages.notificationNudgeIcon(
                context,
                height: 30.w,
                width: 30.w,
              ),
            );
          } else {
            return GestureDetector(
              onTap: () async {
                pushNavigation(ScreenRoutes.notificationScreen);
                getUnreadNotificationCount();
              },
              child: AppImages.notificationIcon(
                context,
                height: 30.w,
                width: 30.w,
              ),
            );
          }
        }
        return InkWell(
            onTap: () async {
              pushNavigation(ScreenRoutes.notificationScreen);
              getUnreadNotificationCount();
            },
            child: AppImages.notificationIcon(
              context,
              height: 30.w,
              width: 30.w,
            ));
      },
    );
  }

  Widget bodyWidget(BuildContext context) {
    return SafeArea(
      child: RefreshWidget(
          onRefresh: () async {
            await refreshData();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                userDetails(context),
                fundView(context),
                myAccountWidgets(context),
                appversionAndAboutUs(context)
              ],
            ),
          )),
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

  Padding appversionAndAboutUs(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        AppUtils.isTablet ? 25.w : AppWidgetSize.dimen_35,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              pushNavigation(ScreenRoutes.aboutUs);
            },
            child: Row(
              children: [
                CustomTextWidget(
                    AppLocalizations().aboutUs,
                    Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w500)),
                AppImages.rightArrowIos(context,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true,
                    height: AppUtils.isTablet ? 11.w : null)
              ],
            ),
          ),
          CustomTextWidget(
              "App v${AppConfig.displayVersion}",
              Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: AppWidgetSize.fontSize12))
        ],
      ),
    );
  }

  Padding myAccountWidgets(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppUtils.isTablet ? 20.w : AppWidgetSize.dimen_30,
        ),
        child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_1),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: getMyAccountOptions(context).length,
            itemBuilder: (context, index) {
              return getMyAccountOptions(context)[index];
            }));
  }

  Padding fundView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.w, right: 30.w, left: 30.w),
      child: CardWidget(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          padding: EdgeInsets.all(AppWidgetSize.dimen_20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BlocBuilder<my_fundsbloc.MyFundsBloc, my_fundsbloc.MyFundsState>(
                builder: (context, state) {
                  if (state is my_fundsbloc.BuyPowerandWithdrawcashDoneState) {
                    return _getLableWithRupeeSymbol(
                      state.buy_power,
                      Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: AppWidgetSize.fontSize22,
                            color: AppUtils()
                                    .doubleValue(state.buy_power)
                                    .isNegative
                                ? AppColors.negativeColor
                                : AppColors().positiveColor,
                            fontFamily: AppConstants.interFont,
                          ),
                      Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: AppWidgetSize.fontSize22,
                            color: AppUtils()
                                    .doubleValue(state.buy_power)
                                    .isNegative
                                ? AppColors.negativeColor
                                : AppColors().positiveColor,
                            fontFamily: AppConstants.interFont,
                          ),
                    );
                  }
                  if (state is my_fundsbloc.MyFundsErrorState) {
                    if (state.isInvalidException) {
                      handleError(state);
                    }
                  }
                  if (state is ClientdetailsProgressState) {
                    return const LoaderWidget();
                  } else {
                    return _getLableWithRupeeSymbol(
                      "--",
                      Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 22,
                            color: Theme.of(context).primaryColor,
                            fontFamily: AppConstants.interFont,
                          ),
                      Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 22,
                            color: Theme.of(context).primaryColor,
                            fontFamily: AppConstants.interFont,
                          ),
                    );
                  }
                },
              ),
              availableForInvestText(context),
              withDrawAndAddFund(context),
            ],
          ),
        ),
      ),
    );
  }

  Row withDrawAndAddFund(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        gradientButtonWidget(
          onTap: () async {
            if (AppStore().isAccountActivated) {
              sendEventToFirebaseAnalytics(
                AppEvents.withdrawfundsClick,
                ScreenRoutes.myAccount,
                'clicked withdraw button in myaccount screen',
              );
              await pushNavigation(ScreenRoutes.withdrawfundsScreen);
              Future.delayed(Duration.zero).then((_) {
                BlocProvider.of<my_fundsbloc.MyFundsBloc>(context)
                    .add(my_fundsbloc.GetFundsViewEvent());
              });
            } else {
              showInfoBottomsheet(suspendedAccount(context));
            }
          },
          width: 120.w,
          key: const Key(emptyWidgetButton1Key),
          context: context,
          bottom: 0,
          title: AppLocalizations().withDraw,
          isGradient: false,
        ),
        SizedBox(
          width: 15.w,
        ),
        gradientButtonWidget(
          onTap: () async {
            if (AppStore().isAccountActivated) {
              sendEventToFirebaseAnalytics(
                AppEvents.addfundsClick,
                ScreenRoutes.myAccount,
                'clicked add funds button in myaccount screen',
              );
              await pushNavigation(ScreenRoutes.addfundsScreen);
              Future.delayed(Duration.zero).then((_) {
                BlocProvider.of<my_fundsbloc.MyFundsBloc>(context)
                    .add(my_fundsbloc.GetFundsViewEvent());
              });
            } else {
              showInfoBottomsheet(suspendedAccount(context));
            }
          },
          width: 120.w,
          key: const Key(emptyWidgetButton1Key),
          context: context,
          bottom: 0,
          title: AppLocalizations().addFunds,
          isGradient: true,
        ),
      ],
    );
  }

  Padding availableForInvestText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.w, bottom: 30.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextWidget(AppLocalizations().buyingPower,
              Theme.of(context).textTheme.titleLarge),
          InkWell(
            onTap: () async {
              dynamic data =
                  await AppStorage().getData('getFundViewUpdatedModel');

              FundViewUpdatedModel fundViewUpdatedModel =
                  FundViewUpdatedModel.datafromJson(data);

              debugPrint(
                  'fundViewUpdatedModel.aLLFD -> ${fundViewUpdatedModel.aLLFD}');

              pushNavigation(
                ScreenRoutes.buyPowerInfoScreen,
                arguments: {"fundmodeldata": fundViewUpdatedModel},
              );
            },
            child: Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: AppImages.informationIcon(context,
                  color: Theme.of(context).primaryIconTheme.color,
                  isColor: true,
                  width: AppWidgetSize.dimen_24,
                  height: AppWidgetSize.dimen_24),
            ),
          )
        ],
      ),
    );
  }

  Widget userDetails(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.w, right: 30.w, left: 30.w),
      child: InkWell(
        onTap: () async {
          await pushNavigation(ScreenRoutes.myProfile, arguments: null);
        },
        child: Row(
          children: [
            BlocBuilder<ClientdetailsBloc, ClientdetailsState>(
              buildWhen: (previous, current) =>
                  current is ClientdetailsDoneState,
              builder: (context, state) {
                if (state is ClientdetailsDoneState) {
                  return profileImage(state, context);
                }
                if (state is ClientdetailsErrorState) {
                  if (state.isInvalidException) {
                    handleError(state);
                  }
                }
                return profileImage(null, context);
              },
            ),
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: AppWidgetSize.screenWidth(context) * 0.5),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomTextWidget(
                          AppStore().getAccDetails()?["accName"] ??
                              AppLocalizations().na,
                          Theme.of(context).textTheme.headlineMedium),
                    ),
                  ),
                  IntrinsicHeight(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AppStore().isActivatedAccount()
                              ? AppImages.readyInvest(context,
                                  width: 12.w, height: 12.w)
                              : AppImages.failImage(
                                  context,
                                  isColor: true,
                                  color: AppColors.negativeColor,
                                  width: 12.w,
                                  height: AppWidgetSize.dimen_12,
                                ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: AppWidgetSize.dimen_8),
                            child: CustomTextWidget(
                                AppStore().isActivatedAccount()
                                    ? AppLocalizations().readyToInvest
                                    : AppStore().getAccStatus(),
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: AppWidgetSize.fontSize12)),
                          ),
                        ],
                      ),
                      VerticalDivider(
                        color: Theme.of(context).colorScheme.primary,
                        thickness: 1,
                      ),
                      userIdDetail(context),
                    ],
                  ))
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(
                    Icons.arrow_forward_ios,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget userIdDetail(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
      child: CustomTextWidget(
          AppStore().getAccDetails()?["uid"] ?? AppLocalizations().na,
          Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontSize: AppWidgetSize.fontSize12)),
    );
  }

  void logoutButtonPressed() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.w),
      ),
      builder: (BuildContext bct) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(20.r),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
              AppWidgetSize.dimen_30,
              AppWidgetSize.dimen_30,
              AppWidgetSize.dimen_30,
              AppWidgetSize.dimen_30),
          child: Wrap(
            children: <Widget>[
              CustomTextWidget(
                AppLocalizations().logout,
                Theme.of(context).textTheme.displaySmall,
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: AppWidgetSize.dimen_20, bottom: 20.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CustomTextWidget(
                    AppLocalizations().logoutWarningMessage,
                    Theme.of(context).textTheme.headlineMedium!,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations().cancel,
                        style: Theme.of(context).textTheme.headlineMedium),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      BlocProvider.of<MenuBottomTabBloc>(context)
                          .add(LogoutEvent(true, false));
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.w),
                      child: Text(
                        AppLocalizations().proceed,
                        style:
                            Theme.of(context).primaryTextTheme.headlineMedium,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Container profileImage(ClientdetailsDoneState? state, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
        AppWidgetSize.dimen_30,
      )),
      height: AppWidgetSize.dimen_60,
      width: AppWidgetSize.dimen_60,
      child: AppImages.marketsPullDown(
        context,
        height: AppWidgetSize.dimen_60,
        width: AppWidgetSize.dimen_60,
      ),
    );
  }

  Widget _getLableWithRupeeSymbol(
    String value,
    TextStyle? rupeeStyle,
    TextStyle? textStyle,
  ) {
    return SizedBox(
      width: AppWidgetSize.screenWidth(context) * 0.7,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: CustomTextWidget(
          value,
          textStyle,
          isShowShimmer: true,
          isRupee: true,
        ),
      ),
    );
  }
}
