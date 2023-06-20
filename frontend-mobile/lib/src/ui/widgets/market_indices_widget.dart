// import 'package:acml/src/constants/app_constants.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../blocs/markets/markets_bloc.dart';
// import '../../localization/app_localization.dart';
// import '../screens/markets/markets_cash/market_indices_screen.dart';
// import '../styles/app_images.dart';
// import '../styles/app_widget_size.dart';
// import 'custom_text_widget.dart';

// Future<Object?> onMarketIndicesTap(
//     BuildContext context, MarketsBloc marketbloc) async {
//   return await showGeneralDialog(
//     context: context,
//     barrierDismissible: true,
//     transitionDuration: const Duration(milliseconds: 500),
//     barrierLabel: MaterialLocalizations.of(context).dialogLabel,
//     barrierColor: Colors.black.withOpacity(0.8),
//     pageBuilder: (ct, _, __) {
//       return StatefulBuilder(
//           builder: (BuildContext ctx, StateSetter updateState) {
//         return Container(
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).copyWith().size.height * 0.75,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             // mainAxisAlignment: MainAxisAlignment.start,
//             children: <Widget>[
//               AnimatedSize(
//                 curve: Curves.linear,
//                 duration: const Duration(milliseconds: 400),
//                 child: Container(
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(5.w),
//                           bottomRight: Radius.circular(5.w)),
//                       color: Theme.of(context).scaffoldBackgroundColor),
//                   width: MediaQuery.of(context).size.width,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SafeArea(
//                         top: true,
//                         bottom: false,
//                         child: Container(
//                           padding: EdgeInsets.only(
//                             left: 24.w,
//                             top: 10.w,
//                             bottom: 20.w,
//                             right: 24.w,
//                           ),
//                           child:
//                               showSettingsCloseContainer(updateState, context),
//                         ),
//                       ),
//                       showIndicesContainer(false, marketbloc),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       });
//     },
//     transitionBuilder: (context, animation, secondaryAnimation, child) {
//       return SlideTransition(
//         position: CurvedAnimation(
//           parent: animation,
//           curve: Curves.linear,
//         ).drive(Tween<Offset>(
//           begin: const Offset(0, -1.0),
//           end: Offset.zero,
//         )),
//         child: child,
//       );
//     },
//   );
// }

// Widget showSettingsCloseContainer(
//     StateSetter updateState, BuildContext context) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       CustomTextWidget(
//           AppLocalizations().customizeIndices,
//           Theme.of(context).textTheme.titleLarge!.copyWith(
//               fontSize: AppWidgetSize.fontSize16.w,
//               fontWeight: FontWeight.w500)),
//       Row(
//         children: [
//           SizedBox(
//             width: AppWidgetSize.dimen_8,
//           ),
//           GestureDetector(
//             child: AppImages.close(
//               context,
//               height: 20.w,
//               color: Theme.of(context).primaryIconTheme.color,
//               isColor: true,
//             ),
//             onTap: () {
//               Navigator.pop(context);
//             },
//           )
//         ],
//       )
//     ],
//   );
// }

// Widget showIndicesContainer(bool showIndicesSheet, MarketsBloc marketBloc) {
//   return MultiBlocProvider(
//       providers: [
//         BlocProvider<MarketsBloc>.value(
//           value: marketBloc,
//         )
//       ],
//       child: const MarketIndicesScreen(
//         arguments: {
//           'screenName': "TopIndicesEditor",
//         },
//       ));
// }

// class MarketIndicesTopWidget extends StatefulWidget {
//   const MarketIndicesTopWidget({Key? key}) : super(key: key);

//   @override
//   State<MarketIndicesTopWidget> createState() => _MarketIndicesTopWidgetState();
// }

// class _MarketIndicesTopWidgetState extends State<MarketIndicesTopWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         if (AppConstants.materialbannerisopen.value) {
//           AppConstants.materialbannerisopen.value = false;
//           return;
//         }
//         AppConstants.materialbannerisopen.value = true;

//         // await _onMarketIndicesTap();
//       },
//       child: ValueListenableBuilder(
//           valueListenable: AppConstants.materialbannerisopen,
//           builder: (context, value, d) {
//             return RotatedBox(
//               quarterTurns: AppConstants.materialbannerisopen.value ? 2 : 0,
//               child: AppImages.marketsPullDown(
//                 context,
//                 isColor: true,
//                 width: 25.w,
//                 height: 25.w,
//               ),
//             );
//           }),
//     );
//   }
// }

// class MarketScaffold extends StatefulWidget {
//   final Widget body;

//   const MarketScaffold({Key? key, required this.body}) : super(key: key);
//   @override
//   State<MarketScaffold> createState() => _MarketScaffoldState();
// }

// class _MarketScaffoldState extends State<MarketScaffold> {
//   MarketsBloc marketbloc = MarketsBloc();
//   @override
//   void dispose() {
//     marketbloc.close();
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<bool>(
//         valueListenable: AppConstants.materialbannerisopen,
//         builder: (context, _, data) {
//           return Scaffold(
//             appBar: AppConstants.materialbannerisopen.value
//                 ? AppBar(
//                     toolbarHeight: 120.w,
//                     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//                     title: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.only(right: 8.0.w),
//                               child: GestureDetector(
//                                 onTap: () async {
//                                   AppConstants.animateBanner.value =
//                                       !AppConstants.animateBanner.value;
//                                   marketbloc.add(MarketIndicesAnimate(
//                                       AppConstants.animateBanner.value));
//                                 },
//                                 child: ValueListenableBuilder<bool>(
//                                     valueListenable: AppConstants.animateBanner,
//                                     builder: (context, value, _) {
//                                       return Container(
//                                         alignment: Alignment.centerRight,
//                                         padding:
//                                             EdgeInsets.symmetric(vertical: 8.w),
//                                         child: Icon(
//                                           AppConstants.animateBanner.value
//                                               ? Icons.pause_sharp
//                                               : Icons.play_arrow,
//                                           size: 25.w,
//                                           color: Theme.of(context)
//                                               .primaryIconTheme
//                                               .color,
//                                         ),
//                                       );
//                                     }),
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () async {
//                                 AppConstants.materialbannerisopen.value = false;
//                                 await onMarketIndicesTap(context, marketbloc);
//                                 marketbloc = MarketsBloc();
//                                 AppConstants.materialbannerisopen.value = true;
//                               },
//                               child: Container(
//                                 alignment: Alignment.centerRight,
//                                 padding: EdgeInsets.symmetric(vertical: 8.w),
//                                 child: AppImages.settingsMarkets(context,
//                                     height: 25.w,
//                                     color: Theme.of(context)
//                                         .primaryIconTheme
//                                         .color,
//                                     isColor: true),
//                               ),
//                             ),
//                           ],
//                         ),
//                         BlocProvider.value(
//                             value: marketbloc,
//                             child: const MarketIndicesScreen(
//                               arguments: {
//                                 'screenName': "TopIndices",
//                               },
//                             )),
//                       ],
//                     ))
//                 : null,
//             body: widget.body,
//           );
//         });
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/markets/markets_bloc.dart';
import '../../localization/app_localization.dart';
import '../screens/markets/markets_cash/market_indices_screen.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import 'custom_text_widget.dart';

class MarketIndicesTopWidget extends StatefulWidget {
  const MarketIndicesTopWidget({Key? key}) : super(key: key);

  @override
  State<MarketIndicesTopWidget> createState() => _MarketIndicesTopWidgetState();
}

class _MarketIndicesTopWidgetState extends State<MarketIndicesTopWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _onMarketIndicesTap();
      },
      child: AppImages.marketsPullDown(
        context,
        isColor: true,
        width: 25.w,
        height: 25.w,
      ),
    );
  }

  bool showIndicesSheet = true;
  Future<Object?> _onMarketIndicesTap() async {
    showIndicesSheet = false;
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 500),
      barrierLabel: MaterialLocalizations.of(context).dialogLabel,
      barrierColor: Colors.black.withOpacity(0.8),
      pageBuilder: (ct, _, __) {
        return StatefulBuilder(
            builder: (BuildContext ctx, StateSetter updateState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).copyWith().size.height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                AnimatedSize(
                  curve: Curves.linear,
                  duration: !showIndicesSheet
                      ? const Duration(milliseconds: 400)
                      : const Duration(milliseconds: 1),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5.w),
                            bottomRight: Radius.circular(5.w)),
                        color: Theme.of(context).scaffoldBackgroundColor),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: !showIndicesSheet
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.start,
                      children: [
                        SafeArea(
                          top: true,
                          bottom: false,
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 24.w,
                              top: 10.w,
                              bottom: 20.w,
                              right: 24.w,
                            ),
                            child: showSettingsCloseContainer(updateState),
                          ),
                        ),
                        showIndicesContainer(showIndicesSheet),
                        !showIndicesSheet
                            ? Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      Theme.of(context).primaryColor
                                    ]),
                                    borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5))),
                                height: AppWidgetSize.dimen_8,
                                // color: Theme.of(context).bottomAppBarColor,
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: CurvedAnimation(
            parent: animation,
            curve: Curves.linear,
          ).drive(Tween<Offset>(
            begin: const Offset(0, -1.0),
            end: Offset.zero,
          )),
          child: child,
        );
      },
    );
  }

  Widget showSettingsCloseContainer(StateSetter updateState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextWidget(
            !showIndicesSheet
                ? AppLocalizations().marketIndices
                : AppLocalizations().customizeIndices,
            Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: AppWidgetSize.fontSize16.w,
                fontWeight: FontWeight.w500)),
        Row(
          children: [
            !showIndicesSheet
                ? GestureDetector(
                    child: AppImages.settingsMarkets(context,
                        height: 25.w,
                        color: Theme.of(context).primaryIconTheme.color,
                        isColor: true),
                    onTap: () {
                      updateState(() {
                        showIndicesSheet = true;
                      });
                    },
                  )
                : Container(),
            SizedBox(
              width: AppWidgetSize.dimen_8,
            ),
            GestureDetector(
              child: AppImages.close(
                context,
                height: 20.w,
                color: Theme.of(context).primaryIconTheme.color,
                isColor: true,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            )
          ],
        )
      ],
    );
  }

  Widget showIndicesContainer(bool showIndicesSheet) {
    if (!showIndicesSheet) {
      return MultiBlocProvider(
          providers: [
            BlocProvider<MarketsBloc>(
              create: (BuildContext context) => MarketsBloc(),
            )
          ],
          child: const MarketIndicesScreen(
            arguments: {
              'screenName': "TopIndices",
            },
          ));
    } else {
      return MultiBlocProvider(
          providers: [
            BlocProvider<MarketsBloc>(
              create: (BuildContext context) => MarketsBloc(),
            )
          ],
          child: const MarketIndicesScreen(
            arguments: {
              'screenName': "TopIndicesEditor",
            },
          ));
    }
  }
}
