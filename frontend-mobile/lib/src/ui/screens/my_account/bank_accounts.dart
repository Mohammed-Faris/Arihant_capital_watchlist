// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../blocs/my_accounts/client_details/clientdetails_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../data/repository/my_account/my_account_repository.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/card_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/list_tile_widget.dart';
import '../../widgets/refresh_widget.dart';
import '../../widgets/webview_widget.dart';
import '../base/base_screen.dart';
import '../route_generator.dart';

class BankAccount extends BaseScreen {
  const BankAccount({
    Key? key,
  }) : super(key: key);

  @override
  BankAccountState createState() => BankAccountState();
}

class BankAccountState extends BaseAuthScreenState<BankAccount> {
  late ClientdetailsBloc clientdetailsBloc;

  @override
  void initState() {
    super.initState();
    clientdetailsBloc = BlocProvider.of<ClientdetailsBloc>(context)
      ..stream.listen(_myaccountListener);
    BlocProvider.of<ClientdetailsBloc>(context).add(
      ClientdetailsFetchEvent(
        fetchApi: true,
      ),
    );
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.bankAccounts);
  }

  Future<void> _myaccountListener(ClientdetailsState state) async {
    if (state is! ClientdetailsProgressState) {
      stopLoader();
    }
    if (state is ClientdetailsProgressState) {
      startLoader();
    } else if (state is ClientdetailsErrorState) {
      handleError(state);
    } else if (state is ClientdetailsErrorState) {
      handleError(state);
    }
  }

  List<ListTileWidget> getBankAccountOptions(BuildContext context) {
    return [
      ListTileWidget(
          title: AppLocalizations().mtf,
          subtitle: AppLocalizations().inactive,
          leadingImage: AppImages.mtfIcon(context)),
      ListTileWidget(
          title: AppLocalizations().nominee,
          subtitle: AppLocalizations().younominee,
          leadingImage: AppImages.nominee(context)),
      ListTileWidget(
        title: AppLocalizations().mydoc,
        subtitle: AppLocalizations().accOpen,
        leadingImage: AppImages.mydoc(context),
        otherTitle: AppLocalizations().activate,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: Theme.of(context).iconTheme,
          title: topBar(context),
        ),
        body: RefreshWidget(
            onRefresh: () async {
              BlocProvider.of<ClientdetailsBloc>(context).add(
                ClientdetailsFetchEvent(fetchApi: true),
              );
            },
            child: SizedBox(
              height:
                  AppWidgetSize.screenHeight(context) - AppWidgetSize.dimen_60,
              width: AppWidgetSize.screenWidth(context),
              child: BlocBuilder<ClientdetailsBloc, ClientdetailsState>(
                  builder: (context, state) {
                if (state is ClientdetailsDoneState) {
                  return (state.clientDetails?.bankDtls.isNotEmpty ?? false)
                      ? bankAccountList(state)
                      : ListView(
                          children: [
                            SizedBox(
                              height: AppWidgetSize.screenHeight(context) -
                                  AppWidgetSize.dimen_120,
                              child: errorWithImageWidget(
                                context: context,
                                imageWidget: AppUtils()
                                    .getNoDateImageErrorWidget(context),
                                errorMessage: AppLocalizations()
                                    .noDataAvailableErrorMessage,
                                padding: EdgeInsets.only(
                                  left: 30.w,
                                  right: 30.w,
                                  bottom: 30.w,
                                ),
                              ),
                            ),
                          ],
                        );
                } else if (state is ClientdetailsFailedState) {
                  return ListView(children: [errorView(context, state)]);
                } else {
                  return Container();
                }
              }),
            )));
  }

  SizedBox errorView(BuildContext context, ClientdetailsFailedState state) {
    return SizedBox(
        height: AppWidgetSize.screenHeight(context) - AppWidgetSize.dimen_120,
        child: Center(
            child: CustomTextWidget(
                state.msg,
                Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error))));
  }

  bankAccountList(ClientdetailsDoneState state) {
    return Container(
      constraints: BoxConstraints(
          minHeight:
              AppWidgetSize.screenHeight(context) - AppWidgetSize.dimen_80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async {
                    startLoader();
                    try {
                      String? ssoUrl = await MyAccountRepository()
                          .getNomineeUrl("bank-account-details");
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
                                    WebviewWidget(
                                        "Edit Bank Account", ssoUrl)));
                      }
                    } catch (e) {
                      stopLoader();
                    }
                  },
                  child: CustomTextWidget(
                      AppLocalizations().reKyc,
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: AppWidgetSize.fontSize16.w,
                          color: Theme.of(context).primaryColor)),
                ),
                Padding(
                  padding: EdgeInsets.only(left: AppWidgetSize.dimen_5),
                  child: GestureDetector(
                      onTap: _showeditInfo,
                      child: AppImages.informationIcon(
                        context,
                        color: Theme.of(context).primaryIconTheme.color,
                        isColor: true,
                        height: AppWidgetSize.dimen_25,
                        width: AppWidgetSize.dimen_25,
                      )),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.clientDetails?.bankDtls.length ?? 0,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppWidgetSize.dimen_30,
                        vertical: AppWidgetSize.dimen_15),
                    child: CardWidget(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        //color: i == 0 ? Theme.of(context).primaryColor : null,
                        child: bankDetailView(state, i, context, i == 0)),
                  );
                }),
          ),
        ],
      ),
    );
  }

  void _showeditInfo() {
    showInfoBottomsheet(_buildeditinfoWidget(),
        horizontalMargin: false, topMargin: false);
  }

  Widget _buildeditinfoWidget() {
    return SizedBox(
      height: AppWidgetSize.dimen_160,
      child: Padding(
        padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_20,
            left: AppWidgetSize.dimen_20,
            right: AppWidgetSize.dimen_20),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations().reKyc,
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  InkWell(
                    child: AppImages.close(
                      context,
                      color: Theme.of(context).primaryIconTheme.color,
                      isColor: true,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations().editInfo,
                      style: Theme.of(context).textTheme.headlineSmall!,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: backIconButton(),
        ),
        Padding(
          padding: EdgeInsets.only(left: AppWidgetSize.dimen_25),
          child: CustomTextWidget(
            AppLocalizations().bankAccounts,
            Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }

  Padding bankDetailView(ClientdetailsDoneState state, int i,
      BuildContext context, bool isPrimary) {
    return Padding(
      padding: EdgeInsets.all(AppWidgetSize.dimen_20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bankNameAndStatus(state, i, context, isPrimary),
            ],
          ),
          accountDetails(context, state, i),
        ],
      ),
    );
  }

  Column accountDetails(
      BuildContext context, ClientdetailsDoneState state, int i) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          children: [
            TableRow(children: [
              columnText(context, AppLocalizations().accNo,
                  state.clientDetails?.bankDtls[i].bankAccNo ?? "-"),
              columnText(context, AppLocalizations().branchName,
                  state.clientDetails?.bankDtls[i].bankBranch ?? "-")
            ]),
          ],
        ),
        columnText(context, AppLocalizations().ifscCode,
            state.clientDetails?.bankDtls[i].ifsc ?? ""),
      ],
    );
  }

  Padding bankNameAndStatus(ClientdetailsDoneState state, int i,
      BuildContext context, bool isPrimary) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_15),
      child: Row(
        children: [
          AppUtils().buildBankLogo(AppUtils().getBankLogoName(
              state.clientDetails?.bankDtls[i].bankName ?? "")),
          Container(
            padding: EdgeInsets.only(left: AppWidgetSize.dimen_5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                    state.clientDetails?.bankDtls[i].bankName ?? "",
                    Theme.of(context).textTheme.headlineSmall),
                Padding(
                  padding: EdgeInsets.only(top: AppWidgetSize.dimen_4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppImages.verifiedAccount(context),
                      Padding(
                        padding: EdgeInsets.only(left: AppWidgetSize.dimen_5),
                        child: CustomTextWidget(AppLocalizations().verified,
                            Theme.of(context).textTheme.bodyLarge),
                      ),
                      if (isPrimary)
                        Container(
                          margin: EdgeInsets.only(left: AppWidgetSize.dimen_5),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .snackBarTheme
                                  .backgroundColor,
                              borderRadius: BorderRadius.circular(
                                  AppWidgetSize.dimen_20)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 20),
                          child: CustomTextWidget(
                              AppConstants.primary,
                              Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      fontSize: AppWidgetSize.fontSize14,
                                      color: Theme.of(context).primaryColor)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding columnText(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomTextWidget(title, Theme.of(context).textTheme.bodySmall),
        CustomTextWidget(subtitle, Theme.of(context).textTheme.titleLarge)
      ]),
    );
  }
}

class StackImageIconButton extends StatelessWidget {
  final SvgPicture image;
  final bool isActive;
  const StackImageIconButton({
    required this.image,
    this.isActive = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(AppWidgetSize.dimen_20),
      decoration: BoxDecoration(
          border: Border.all(
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(AppWidgetSize.dimen_10)),
      child: Stack(
        children: [
          Positioned(
            right: AppWidgetSize.dimen_1,
            top: AppWidgetSize.dimen_1,
            height: AppWidgetSize.dimen_10,
            child: isActive
                ? AppImages.readyInvest(context)
                : AppImages.checkDisable(context),
          ),
          Padding(
            padding: EdgeInsets.all(AppWidgetSize.dimen_10),
            child: image,
          ),
        ],
      ),
    );
  }
}
