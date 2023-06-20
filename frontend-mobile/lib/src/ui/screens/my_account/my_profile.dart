// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../blocs/my_accounts/client_details/clientdetails_bloc.dart';
import '../../../data/repository/my_account/my_account_repository.dart';
import '../../../data/store/app_storage.dart';
import '../../../data/store/app_store.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
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

class MyProfile extends BaseScreen {
  const MyProfile({
    Key? key,
  }) : super(key: key);

  @override
  MyProfileState createState() => MyProfileState();
}

class MyProfileState extends BaseAuthScreenState<MyProfile> {
  late ClientdetailsBloc clientdetailsBloc;
  Map<String, dynamic>? accDetails;

  @override
  void initState() {
    super.initState();
    fetchDetail();

    BlocProvider.of<ClientdetailsBloc>(context).add(
      ClientdetailsFetchEvent(fetchApi: true),
    );
    clientdetailsBloc = BlocProvider.of<ClientdetailsBloc>(context)
      ..stream.listen(_myaccountListener);
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.myProfile);
  }

  fetchDetail() async {
    accDetails = await AppStorage().getData("userLoginDetailsKey");
    accDetails?["uid"] =
        await AppStore().getSavedDataFromAppStorage("userIdKey");
    setState(() {
      accDetails = accDetails;
    });
  }

  Future<void> _myaccountListener(ClientdetailsState state) async {
    if (state is! ClientdetailsProgressState) {
      stopLoader();
    }
    if (state is ClientdetailsProgressState) {
      startLoader();
    } else if (state is ClientdetailsErrorState) {
      handleError(state);
    }
  }

  List<ListTileWidget> getMyProfileOptions(
      BuildContext context, ClientdetailsDoneState state) {
    return [
      ListTileWidget(
          title: AppLocalizations().mtf,
          subtitle: state.clientDetails?.clientDtls.first.mtf ?? "-",
          texbuttonClick: () {},
          showArrow: false,
          leadingImage: AppImages.mtfIcon(context)),
      ListTileWidget(
          title: AppLocalizations().nominee,
          onTap: () {
            pushNavigation(ScreenRoutes.nomineeDetails);
          },
          subtitle: AppLocalizations().younominee,
          leadingImage: AppImages.nominee(context)),
      // ListTileWidget(
      //   title: AppLocalizations().mydoc,
      //   subtitle: AppLocalizations().accOpen,
      //   leadingImage: AppImages.mydoc(context),
      //   otherTitle: AppLocalizations().activate,
      // ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          title: topBar(context),
          toolbarHeight: AppWidgetSize.dimen_60,
        ),
        body: RefreshWidget(
          onRefresh: () async {
            BlocProvider.of<ClientdetailsBloc>(context).add(
              ClientdetailsFetchEvent(fetchApi: true),
            );
            await MyAccountRepository().getAccountInfo();
          },
          child: BlocBuilder<ClientdetailsBloc, ClientdetailsState>(
              builder: (context, state) {
            if (state is ClientdetailsDoneState) {
              return bodyWidget(context, state);
            } else if (state is ClientdetailsFailedState) {
              return SingleChildScrollView(
                  child: SizedBox(
                      height: AppWidgetSize.screenHeight(context) -
                          AppWidgetSize.dimen_60,
                      width: AppWidgetSize.screenWidth(context),
                      child: errorWithImageWidget(
                        context: context,
                        imageWidget:
                            AppUtils().getNoDateImageErrorWidget(context),
                        errorMessage: state.errorMsg,
                        padding: EdgeInsets.only(
                          left: 30.w,
                          right: 30.w,
                          bottom: 30.w,
                        ),
                      )));
            } else {
              return SizedBox(
                  height: AppWidgetSize.screenHeight(context) -
                      AppWidgetSize.dimen_60,
                  width: AppWidgetSize.screenWidth(context),
                  child: Container());
            }
          }),
        ));
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

  bodyWidget(BuildContext context, ClientdetailsDoneState state) {
    return SizedBox(
        height: AppWidgetSize.screenHeight(context) - AppWidgetSize.dimen_60,
        width: AppWidgetSize.screenWidth(context),
        child: SingleChildScrollView(
            child: Column(
          children: [
            (state.clientDetails?.clientDtls.isNotEmpty ?? false)
                ? Column(
                    children: [
                      userDetails(context),
                      contactDetails(context, state),
                      personalDetail(context, state),
                      dematAccountDetail(context, state),
                      tradingPreferences(context, state),
                      accountDetails(context, state),
                    ],
                  )
                : SingleChildScrollView(
                    child: errorWithImageWidget(
                      context: context,
                      height: AppWidgetSize.screenHeight(context) -
                          AppWidgetSize.dimen_60,
                      imageWidget:
                          AppUtils().getNoDateImageErrorWidget(context),
                      errorMessage:
                          AppLocalizations().noDataAvailableErrorMessage,
                      padding: EdgeInsets.only(
                        left: 30.w,
                        right: 30.w,
                        bottom: 30.w,
                      ),
                    ),
                  ),
          ],
        )));
  }

  Column accountDetails(BuildContext context, ClientdetailsDoneState state) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_35, bottom: AppWidgetSize.dimen_15),
          child: CustomTextWidget(
            AppLocalizations().accountDetails,
            Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: AppWidgetSize.fontSize16),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 20.w, left: AppWidgetSize.dimen_20),
          child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_10),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: getMyProfileOptions(context, state).length,
              itemBuilder: (context, index) {
                return getMyProfileOptions(context, state)[index];
              }),
        ),
      ],
    );
  }

  Container tradingPreferences(
      BuildContext context, ClientdetailsDoneState state) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_30,
          right: AppWidgetSize.dimen_30,
          bottom: AppWidgetSize.dimen_15),
      child: CardWidget(
        color: Theme.of(context).scaffoldBackgroundColor,
        title: AppLocalizations().tradingPreferences,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StackImageIconButton(
              image: AppImages.equity(context, width: 20.w),
              isActive: state.clientDetails?.clientDtls.first.exc
                      .contains(AppLocalizations().equity) ??
                  false,
              title: AppLocalizations().equityTitle,
            ),
            StackImageIconButton(
              image: AppImages.futureOption(context, width: 20.w),
              isActive: AppStore().isFnoAvailable,
              title: AppLocalizations().fandoTitle,
            ),
            StackImageIconButton(
              image: AppImages.commodity(context, width: 20.w),
              isActive: AppStore().isCommodityAvailable,
              title: AppLocalizations().commodityTitle,
            ),
            StackImageIconButton(
              image: AppImages.currency(context, width: 20.w),
              isActive: AppStore().isCurrencyAvailable,
              title: AppLocalizations().currencyTitle,
            ),
          ],
        ),
      ),
    );
  }

  Container dematAccountDetail(
      BuildContext context, ClientdetailsDoneState state) {
    return Container(
      margin: EdgeInsets.only(bottom: 30.w, right: 30.w, left: 30.w),
      child: CardWidget(
        color: Theme.of(context).scaffoldBackgroundColor,
        title: AppLocalizations().dematAccountDetails,
        child: Container(
          padding: EdgeInsets.all(AppWidgetSize.dimen_20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Table(
                children: [
                  TableRow(children: [
                    columnText(context, AppLocalizations().depositoryName,
                        state.clientDetails?.clientDtls.first.depoName ?? ""),
                    columnText(
                        context,
                        AppLocalizations().depositoryParticipant,
                        state.clientDetails?.clientDtls.first.depoParticipant ??
                            "")
                  ]),
                  TableRow(children: [
                    columnText(context, AppLocalizations().dpid,
                        state.clientDetails?.clientDtls.first.dpId ?? ""),
                    columnText(context, AppLocalizations().dematAccountNo,
                        state.clientDetails?.clientDtls.first.dematAccNo ?? "")
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container personalDetail(BuildContext context, ClientdetailsDoneState state) {
    return Container(
      margin: EdgeInsets.only(bottom: 30.w, right: 30.w, left: 30.w),
      child: CardWidget(
        color: Theme.of(context).scaffoldBackgroundColor,
        title: AppLocalizations().personDetail,
        child: Container(
          padding: EdgeInsets.all(AppWidgetSize.dimen_20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Table(
                children: [
                  TableRow(children: [
                    columnText(context, AppLocalizations().dateofbirth,
                        state.clientDetails?.clientDtls.first.dob ?? ""),
                    columnText(context, AppLocalizations().pan,
                        state.clientDetails?.clientDtls.first.panNumber ?? "")
                  ]),
                  TableRow(children: [
                    columnText(context, AppLocalizations().gender,
                        state.clientDetails?.clientDtls.first.gender ?? ""),
                    columnText(
                        context,
                        AppLocalizations().martialStatus,
                        state.clientDetails?.clientDtls.first.maritalStatus ??
                            "")
                  ]),
                  TableRow(children: [
                    columnText(
                        context,
                        AppLocalizations().fatherName,
                        state.clientDetails?.clientDtls.first.fathOrHusName ??
                            ""),
                    columnText(
                        context,
                        AppLocalizations().taxResidency,
                        state.clientDetails?.clientDtls.first.taxResidence ??
                            "-")
                  ])
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container contactDetails(BuildContext context, ClientdetailsDoneState state) {
    return Container(
      margin: EdgeInsets.only(bottom: 30.w, right: 30.w, left: 30.w),
      child: CardWidget(
        color: Theme.of(context).scaffoldBackgroundColor,
        title: AppLocalizations().contactDetails,
        subtitle: AppLocalizations().reKyc,
        subtitleColor: Theme.of(context).primaryColor,
        subtitleOntap: () async {
          startLoader();
          try {
            String? ssoUrl =
                await MyAccountRepository().getNomineeUrl("my-profile");
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
                          WebviewWidget("Edit Profile", ssoUrl)));
            }
          } catch (e) {
            stopLoader();
          }
        },
        infoOntap: _showeditInfo,
        child: Container(
            padding: EdgeInsets.all(AppWidgetSize.dimen_20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              columnText(context, AppLocalizations().email,
                  state.clientDetails?.clientDtls.first.email ?? ""),
              columnText(context, AppLocalizations().mobile,
                  state.clientDetails?.clientDtls.first.mobNo ?? ""),
              columnText(context, AppLocalizations().permanentAddress,
                  state.clientDetails?.clientDtls.first.permAddrs ?? ""),
              columnText(context, AppLocalizations().correspondenceAddress,
                  state.clientDetails?.clientDtls.first.corrAddrs ?? ""),
            ])),
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
            AppLocalizations().myProfile,
            Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
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

  Container profileImage(ClientdetailsDoneState state, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(
            AppWidgetSize.dimen_30,
          )),
      height: AppWidgetSize.dimen_60,
      width: AppWidgetSize.dimen_60,
      child: (state.clientDetails?.clientDtls.isNotEmpty ?? false)
          ? (state.clientDetails?.clientDtls.first.gender == "Male"
              ? AppImages.profileMen(context)
              : state.clientDetails?.clientDtls.first.gender == "Female"
                  ? AppImages.profileWomen(context)
                  : AppImages.marketsPullDown(
                      context,
                      height: AppWidgetSize.dimen_60,
                      width: AppWidgetSize.dimen_60,
                    ))
          : null,
    );
  }

  Widget userIdDetail(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
      child: CustomTextWidget(
          accDetails?["uid"] ?? AppLocalizations().na,
          Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontSize: AppWidgetSize.fontSize12)),
    );
  }

  Widget userDetails(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: AppWidgetSize.dimen_30, horizontal: AppWidgetSize.dimen_30),
      child: Row(
        children: [
          BlocBuilder<ClientdetailsBloc, ClientdetailsState>(
            buildWhen: (previous, current) {
              return current is ClientdetailsDoneState;
            },
            builder: (context, state) {
              if (state is ClientdetailsDoneState) {
                return profileImage(state, context);
              }
              return Container(
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(
                      AppWidgetSize.dimen_30,
                    )),
                height: AppWidgetSize.dimen_60,
                width: AppWidgetSize.dimen_60,
                child: null,
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: AppWidgetSize.screenWidth(context) * 0.60,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: CustomTextWidget(
                        accDetails?["accName"] ?? AppLocalizations().na,
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
                            ? AppImages.readyInvest(context)
                            : AppImages.failImage(
                                context,
                                isColor: true,
                                color: AppColors.negativeColor,
                                height: AppWidgetSize.dimen_12,
                              ),
                        Padding(
                          padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
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
        ],
      ),
    );
  }

  Padding columnText(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: AppWidgetSize.dimen_15, horizontal: AppWidgetSize.dimen_2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomTextWidget(title, Theme.of(context).textTheme.bodySmall),
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: CustomTextWidget(
              subtitle, Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.justify),
        )
      ]),
    );
  }
}

class StackImageIconButton extends BaseScreen {
  final Widget image;
  final bool isActive;
  final String title;
  const StackImageIconButton({
    required this.image,
    this.isActive = false,
    this.title = '',
    Key? key,
  }) : super(key: key);

  @override
  State<StackImageIconButton> createState() => _StackImageIconButtonState();
}

class _StackImageIconButtonState extends BaseScreenState<StackImageIconButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isActive
          ? null
          : () async {
              startLoader();
              try {
                String? ssoUrl = await MyAccountRepository()
                    .getNomineeUrl("segment-brokerage");
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
                              WebviewWidget("Edit Segments", ssoUrl)));
                }
              } catch (e) {
                stopLoader();
              }
            },
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: AppWidgetSize.dimen_15,
            horizontal: AppWidgetSize.dimen_9),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: widget.isActive
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(AppWidgetSize.dimen_10)),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: AppWidgetSize.dimen_2,
                    height: AppWidgetSize.dimen_10,
                    child: widget.isActive
                        ? AppImages.readyInvest(context)
                        : AppImages.checkDisable(context,
                            isColor: true,
                            color: Theme.of(context).dividerColor),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppWidgetSize.dimen_14),
                    child: widget.image,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
              child: CustomTextWidget(
                  widget.title, Theme.of(context).textTheme.titleLarge),
            )
          ],
        ),
      ),
    );
  }
}
