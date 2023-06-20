// import 'package:acml/firebase/remote_config.dart';
// import 'package:acml/src/blocs/common/screen_state.dart';
// import 'package:acml/src/ui/screens/acml_app.dart';
// import 'package:acml/src/ui/screens/base/base_screen.dart';
// import 'package:acml/src/ui/styles/app_images.dart';
// import 'package:acml/src/ui/styles/app_widget_size.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:msil_library/utils/exception/service_exception.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:url_launcher/url_launcher_string.dart';

// import '../../../constants/keys/quote_keys.dart';
// import '../../../data/repository/my_account/my_account_repository.dart';
// import '../../navigation/screen_routes.dart';
// import '../../widgets/custom_text_widget.dart';
// import '../../widgets/gradient_button_widget.dart';
// import '../../widgets/webview_widget.dart';
// import '../route_generator.dart';

// class Campaign extends BaseScreen {
//   const Campaign({super.key});

//   @override
//   State<Campaign> createState() => _CampaignState();
// }

// class _CampaignState extends BaseAuthScreenState<Campaign> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: _buildPresistentFooterWidget(),
//       appBar: AppBar(
//         toolbarHeight: 0.w,
//         backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
//       ),
//       body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Container(
//           alignment: Alignment.centerRight,
//           width: AppWidgetSize.screenWidth(context),
//           padding: EdgeInsets.only(right: 20.w, top: 20.w),
//           color: Theme.of(context).snackBarTheme.backgroundColor,
//           child: InkWell(
//             onTap: () {
//               navigatorKey.currentState?.pop();
//             },
//             child: AppImages.closeIcon(
//               context,
//               width: 40.w,
//               height: 20.w,
//               color: Theme.of(context).primaryIconTheme.color,
//               isColor: true,
//             ),
//           ),
//         ),
//         Container(
//           alignment: Alignment.center,
//           padding: EdgeInsets.only(bottom: 30.w, top: 30.w),
//           color: Theme.of(context).snackBarTheme.backgroundColor,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [SvgPicture.string(RemoteConfigService.getCampaignImage)],
//           ),
//         ),
//         Expanded(
//           child: Container(
//             alignment: Alignment.centerLeft,
//             padding: EdgeInsets.only(top: 20.w, left: 20.w, right: 20.w),
//             child: ListView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               shrinkWrap: true,
//               children: [
//                 Container(
//                   alignment: Alignment.centerLeft,
//                   child: AppImages.arihantpluslogo(
//                     context,
//                     height: 40.w,
//                     width: AppWidgetSize.dimen_280,
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(top: 30.w, bottom: 10.h),
//                   child: CustomTextWidget(
//                       RemoteConfigService.getCampaign["campaignHeading"],
//                       Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.w500,
//                           fontSize: AppWidgetSize.fontSize18),
//                       textAlign: TextAlign.justify),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(top: 10.w, bottom: 10.h),
//                   child: CustomTextWidget(
//                       RemoteConfigService.getCampaign["campaignBody"],
//                       Theme.of(context)
//                           .textTheme
//                           .titleLarge
//                           ?.copyWith(fontSize: AppWidgetSize.fontSize16),
//                       textAlign: TextAlign.justify),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(top: 30.w, bottom: 0.h),
//                   child: CustomTextWidget(
//                       RemoteConfigService.getCampaign["campaignNote"],
//                       Theme.of(context)
//                           .textTheme
//                           .bodySmall
//                           ?.copyWith(fontSize: AppWidgetSize.fontSize16),
//                       textAlign: TextAlign.justify),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ]),
//     );
//   }

//   Widget _buildPresistentFooterWidget() {
//     return SafeArea(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           gradientButtonWidget(
//             key: const Key(addNominee),
//             title: RemoteConfigService.getCampaign["button1Campaign"],
//             width: AppWidgetSize.fullWidth(context) /
//                 (RemoteConfigService.getCampaign["button2Campaign"] != ""
//                     ? 2.3
//                     : 1.2),
//             isGradient: false,
//             context: context,
//             fontsize: 16.w,
//             bottom: 20.w,
//             onTap: () async {
//               startLoader();
//               if (RemoteConfigService.getCampaign["button1Link"] != "") {
//                 launchUrlString(RemoteConfigService.getCampaign["button1Link"]);
//                 stopLoader();

//                 return;
//               }
//               try {
//                 String? ssoUrl = await MyAccountRepository()
//                     .getNomineeUrl("nominee-details");
//                 stopLoader();

//                 await Permission.microphone.request();
//                 await Permission.camera.request();
//                 await Permission.location.request();
//                 await Permission.locationWhenInUse.request();
//                 await Permission.accessMediaLocation.request();
//                 if (mounted) {
//                   Navigator.push(
//                     context,
//                     SlideRoute(
//                       settings: const RouteSettings(
//                         name: ScreenRoutes.inAppWebview,
//                       ),
//                       builder: (BuildContext context) => WebviewWidget(
//                         RemoteConfigService.getCampaign["button1Campaign"],
//                         ssoUrl,
//                         key: const Key("Add Nominee"),
//                       ),
//                     ),
//                   );
//                 }
//               } on ServiceException catch (ex) {
//                 stopLoader();
//                 handleError(ScreenState()
//                   ..errorCode = ex.code
//                   ..errorMsg = ex.msg);
//               } catch (e) {
//                 stopLoader();
//               }
//             },
//           ),
//           SizedBox(width: AppWidgetSize.dimen_32),
//           if (RemoteConfigService.getCampaign["button2Campaign"] != "")
//             gradientButtonWidget(
//               key: const Key(optoutNominee),
//               title: RemoteConfigService.getCampaign["button2Campaign"],
//               width: AppWidgetSize.fullWidth(context) /
//                   (RemoteConfigService.getCampaign["button2Campaign"] != ""
//                       ? 2.3
//                       : 1.2),
//               isGradient: true,
//               fontsize: 16.w,
//               bottom: 20.w,
//               context: context,
//               onTap: () async {
//                 startLoader();
//                 if (RemoteConfigService.getCampaign["button2Link"] != "") {
//                   launchUrlString(
//                       RemoteConfigService.getCampaign["button2Link"]);
//                   stopLoader();

//                   return;
//                 }

//                 try {
//                   String? ssoUrl =
//                       await MyAccountRepository().getNomineeUrl("optin-out");
//                   stopLoader();

//                   await Permission.microphone.request();
//                   await Permission.camera.request();
//                   await Permission.location.request();
//                   await Permission.locationWhenInUse.request();
//                   await Permission.accessMediaLocation.request();
//                   if (mounted) {
//                     Navigator.push(
//                       context,
//                       SlideRoute(
//                         settings: const RouteSettings(
//                           name: ScreenRoutes.inAppWebview,
//                         ),
//                         builder: (BuildContext context) => WebviewWidget(
//                           RemoteConfigService.getCampaign["button2Campaign"],
//                           ssoUrl,
//                           key: const Key("optoutNomineew"),
//                         ),
//                       ),
//                     );
//                   }
//                 } on ServiceException catch (ex) {
//                   stopLoader();
//                   handleError(ScreenState()
//                     ..errorCode = ex.code
//                     ..errorMsg = ex.msg);
//                 } catch (e) {
//                   stopLoader();
//                 }
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }
