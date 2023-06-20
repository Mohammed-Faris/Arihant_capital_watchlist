import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../blocs/my_accounts/client_details/clientdetails_bloc.dart';
import '../../../constants/keys/quote_keys.dart';
import '../../../data/repository/my_account/my_account_repository.dart';
import '../../../localization/app_localization.dart';
import '../../../models/my_account/client_details.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/card_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/list_tile_widget.dart';
import '../../widgets/webview_widget.dart';
import '../base/base_screen.dart';
import '../route_generator.dart';

class NomineeDetails extends BaseScreen {
  const NomineeDetails({
    Key? key,
  }) : super(key: key);

  @override
  NomineeDetailsState createState() => NomineeDetailsState();
}

class NomineeDetailsState extends BaseAuthScreenState<NomineeDetails> {
  late ClientdetailsBloc clientdetailsBloc;
  Map<String, dynamic>? accDetails;

  @override
  void initState() {
    super.initState();
    clientdetailsBloc = BlocProvider.of<ClientdetailsBloc>(context)
      ..stream.listen(_myaccountListener);
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.nomineeDetails);
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

  List<ListTileWidget> getNomineeDetailsOptions(BuildContext context) {
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
    return BlocBuilder<ClientdetailsBloc, ClientdetailsState>(
        builder: (context, state) {
      if (state is ClientdetailsDoneState) {
        return bodyWidget(context, state);
      } else if (state is ClientdetailsFailedState) {
        return errorView(context, state);
      } else {
        return Container();
      }
    });
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

  Widget _buildPresistentFooterWidget() {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          gradientButtonWidget(
            key: const Key(addNominee),
            title: AppLocalizations().addNominee,
            width: AppWidgetSize.fullWidth(context) / 2.3,
            isGradient: false,
            context: context,
            fontsize: 16.w,
            bottom: 20.w,
            onTap: () async {
              startLoader();
              try {
                String? ssoUrl = await MyAccountRepository()
                    .getNomineeUrl("nominee-details");
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
                              WebviewWidget("Add Nominee", ssoUrl)));
                }
              } catch (e) {
                stopLoader();
              }
            },
          ),
          SizedBox(width: AppWidgetSize.dimen_32),
          gradientButtonWidget(
            key: const Key(optoutNominee),
            title: AppLocalizations().optoutOfNominee,
            width: AppWidgetSize.fullWidth(context) / 2.3,
            isGradient: true,
            fontsize: 16.w,
            bottom: 20.w,
            context: context,
            onTap: () async {
              startLoader();
              try {
                String? ssoUrl =
                    await MyAccountRepository().getNomineeUrl("optin-out");
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
                          builder: (BuildContext context) => WebviewWidget(
                              AppLocalizations().optoutOfNominee, ssoUrl)));
                }
              } catch (e) {
                stopLoader();
              }
            },
          ),
        ],
      ),
    );
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

  Scaffold bodyWidget(BuildContext context, ClientdetailsDoneState state) {
    return Scaffold(
        appBar: AppBar(
          title: topBar(context),
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        bottomNavigationBar:
            ((state.clientDetails?.nomineeContactDtls.isEmpty ?? true) &&
                    (state.clientDetails?.nomineeNsdl.isEmpty ?? true) &&
                    (state.clientDetails?.nomineeCdsl.isEmpty ?? true))
                ? _buildPresistentFooterWidget()
                : null,
        body: SafeArea(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              if ((state.clientDetails?.nomineeContactDtls.isEmpty ?? true) &&
                  (state.clientDetails?.nomineeNsdl.isEmpty ?? true) &&
                  (state.clientDetails?.nomineeCdsl.isEmpty ?? true))
                errorWithImageWidget(
                  height: AppWidgetSize.screenHeight(context) -
                      AppWidgetSize.dimen_200,
                  context: context,
                  imageWidget: AppImages.nomineeBanner(context),
                  childErrorMsg: "Please add a new nominee.",
                  errorMessage: "You don't have any nominee yet.",
                  padding: EdgeInsets.only(
                    left: 30.w,
                    right: 30.w,
                    bottom: 30.w,
                  ),
                ),
              if (!((state.clientDetails?.nomineeContactDtls.isEmpty ?? true) &&
                  (state.clientDetails?.nomineeNsdl.isEmpty ?? true) &&
                  (state.clientDetails?.nomineeCdsl.isEmpty ?? true)))
                Container(
                  padding: EdgeInsets.only(right: 40.w, bottom: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          startLoader();
                          try {
                            String? ssoUrl = await MyAccountRepository()
                                .getNomineeUrl("nominee-details");
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
                                              "Edit Nominee", ssoUrl)));
                            }
                          } catch (e) {
                            stopLoader();
                          }
                        },
                        child: CustomTextWidget(
                            AppLocalizations().edit,
                            Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                    fontSize: AppWidgetSize.fontSize16,
                                    color: Theme.of(context).primaryColor)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: AppWidgetSize.dimen_5),
                        child: GestureDetector(
                            onTap: () {
                              showInfoBottomsheet(_buildeditinfoWidget(),
                                  horizontalMargin: false, topMargin: false);
                            },
                            child: AppImages.informationIcon(context,
                                color: Theme.of(context).primaryIconTheme.color,
                                isColor: true,
                                height: AppWidgetSize.dimen_25,
                                width: AppWidgetSize.dimen_25)),
                      ),
                    ],
                  ),
                ),
              if (state.clientDetails?.nomineeContactDtls.isNotEmpty ?? false)
                Column(
                  children: [
                    nomineeDetails(context, state),
                  ],
                ),
              if (state.clientDetails?.nomineeNsdl.isNotEmpty ?? false)
                Column(
                  children: [
                    nomineeNSDLDetails(context, state),
                  ],
                ),
              if (state.clientDetails?.nomineeCdsl.isNotEmpty ?? false)
                Column(
                  children: [
                    nomineeCdslDetails(context, state),
                  ],
                ),
            ],
          ),
        ));
  }

  String ordinal(int number) {
    if (!(number >= 1 && number <= 100)) {
      //here you change the range
      throw Exception('Invalid number');
    }

    if (number >= 11 && number <= 13) {
      return 'th';
    }

    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Widget nomineeNSDLDetails(
      BuildContext context, ClientdetailsDoneState state) {
    return ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(height: AppWidgetSize.dimen_30);
        },
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.clientDetails?.nomineeNsdl.length ?? 0,
        itemBuilder: (context, index) {
          NomineeNsdl nominee = state.clientDetails!.nomineeNsdl[index];
          return Container(
            margin: EdgeInsets.only(bottom: 30.w, right: 30.w, left: 30.w),
            child: CardWidget(
              title: " ${'${index + 1}${ordinal(index + 1)}'} Nominee",
              child: Container(
                padding: EdgeInsets.all(AppWidgetSize.dimen_20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Table(
                      children: [
                        TableRow(children: [
                          columnText(context, AppLocalizations().nomineeName,
                              nominee.nomineeName),
                          columnText(context, AppLocalizations().pan,
                              nominee.nomineePan)
                        ]),
                        TableRow(children: [
                          columnText(
                              context,
                              AppLocalizations().permanentAddress,
                              nominee.nomineeAddrs),
                          columnText(context, AppLocalizations().pinCode,
                              nominee.nomineePinCode),
                        ])
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget nomineeCdslDetails(
      BuildContext context, ClientdetailsDoneState state) {
    return ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(height: AppWidgetSize.dimen_30);
        },
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: state.clientDetails?.nomineeCdsl.length ?? 0,
        itemBuilder: (context, index) {
          NomineeCdsl nominee = state.clientDetails!.nomineeCdsl[index];
          return Container(
            margin: EdgeInsets.only(bottom: 30.w, right: 30.w, left: 30.w),
            child: CardWidget(
              title: " ${'${index + 1}${ordinal(index + 1)}'} Nominee",
              child: Container(
                padding: EdgeInsets.all(AppWidgetSize.dimen_20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Table(
                      children: [
                        TableRow(children: [
                          columnText(context, AppLocalizations().nomineeName,
                              nominee.nomineeName),
                          columnText(context, AppLocalizations().pan,
                              nominee.nomineePan)
                        ]),
                        TableRow(children: [
                          columnText(
                              context,
                              AppLocalizations().permanentAddress,
                              nominee.nomineeAddrs),
                          columnText(context, AppLocalizations().state,
                              nominee.nomineeState),
                        ])
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget nomineeDetails(BuildContext context, ClientdetailsDoneState state) {
    return ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(height: AppWidgetSize.dimen_30);
        },
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.clientDetails?.nomineeContactDtls.length ?? 0,
        itemBuilder: (context, index) {
          NomineeContactDtls nominee =
              state.clientDetails!.nomineeContactDtls[index];
          return Container(
            margin: EdgeInsets.only(bottom: 30.w, right: 30.w, left: 30.w),
            child: CardWidget(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Container(
                padding: EdgeInsets.all(AppWidgetSize.dimen_20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Table(
                      children: [
                        TableRow(children: [
                          columnText(context, AppLocalizations().nomineeName,
                              nominee.nomineeName),
                          columnText(context, AppLocalizations().relationship,
                              nominee.relationship)
                        ]),
                        TableRow(children: [
                          columnText(context, AppLocalizations().dateofbirth,
                              nominee.dob),
                          Container()
                        ])
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Padding topBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_18, left: 30.w, bottom: 20.h),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15.w),
            child: CustomTextWidget(AppLocalizations().nominee,
                Theme.of(context).textTheme.headlineSmall),
          )
        ],
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
              : AppImages.profileWomen(context))
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
                CustomTextWidget(
                    accDetails?["accName"] ?? AppLocalizations().na,
                    Theme.of(context).textTheme.headlineMedium),
                IntrinsicHeight(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AppImages.readyInvest(context),
                        Padding(
                          padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                          child: CustomTextWidget(
                              AppLocalizations().readyToInvest,
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
      padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_15, left: 10.w),
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
  final String title;
  const StackImageIconButton({
    required this.image,
    this.isActive = false,
    this.title = '',
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(AppWidgetSize.dimen_20),
      child: Column(
        children: [
          Container(
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
          ),
          Padding(
            padding: EdgeInsets.only(top: AppWidgetSize.dimen_10),
            child:
                CustomTextWidget(title, Theme.of(context).textTheme.titleLarge),
          )
        ],
      ),
    );
  }
}
