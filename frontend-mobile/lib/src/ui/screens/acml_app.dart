import 'package:acml/src/data/store/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:msil_library/utils/config/log_config.dart' as log;
import '../../blocs/tab/menu_bottom_tab_bloc.dart';
import '../../blocs/themebloc/theme_bloc.dart';
import '../../config/app_config.dart';
import '../../constants/app_constants.dart';
import '../../data/store/app_store.dart';
import '../../localization/app_localization_delegate.dart';
import '../navigation/screen_routes.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import '../theme/dark_theme.dart';
import '../theme/light_theme.dart';
import '../widgets/custom_error.dart';
import 'connectivity.dart';
import 'route_generator.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
final scaffoldkey = GlobalKey<ScaffoldMessengerState>();

class ACMLApp extends StatelessWidget {
  const ACMLApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (BuildContext context) => ThemeBloc()..add(ThemeInitEvent()),
      child: const _ACMLApp(),
    );
  }
}

class _ACMLApp extends StatefulWidget {
  const _ACMLApp({Key? key}) : super(key: key);

  @override
  _ACMLAppState createState() => _ACMLAppState();
}

class _ACMLAppState extends State<_ACMLApp> {
  static const MethodChannel platform = MethodChannel('ACMLFlutterChannel');

  @override
  void initState() {
    AppStore.currentRoute = "";
    connectivity.initialise();
    connectivity.myStream.listen((event) {
      onConnectionResult(event);
    });
    // checkForUpdate();

    _initiateMethodCallHandler();
    super.initState();
  }

  void _initiateMethodCallHandler() {
    platform.setMethodCallHandler(
      (MethodCall call) async {
        switch (call.method) {
          case 'handleNotificationClick':
            if (call.arguments != null) {
              _handleNotificationClick(
                clickAction: call.arguments[AppConstants.pushClickAction],
                isFreshLaunch: call.arguments[AppConstants.isFreshLaunch],
              );
            } else {
              MenuBottomTabBloc.pushNavigation = AppConstants.mnu_notification;
            }
            break;
          default:
            break;
        }
      },
    );
  }

  void _handleNotificationClick(
      {required String clickAction, required bool isFreshLaunch}) {
    AppStore().setPushClicked(true);
    if (isFreshLaunch) {
      MenuBottomTabBloc.pushNavigation = AppConstants.mnu_notification;
      Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
          .pushNamed(ScreenRoutes.homeScreen, arguments: {
        'pageName': ScreenRoutes.myAccount,
      });
    } else {
      Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
          .pushNamed(ScreenRoutes.sessionValidation, arguments: {
        AppConstants.pushClickAction: clickAction,
        AppConstants.isFreshLaunch: isFreshLaunch,
      });
    }
  }

  @override
  void dispose() {
    debugPrint("Connection Subscribe  Disposed");
    connectivity.disposeStream();
    super.dispose();
  }

  static bool firstLaunch = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (
        BuildContext context,
        ThemeState state,
      ) {
        AppStore().setThemeData(state.themeType);
        SystemChrome.setSystemUIOverlayStyle(
            AppStore.themeType == AppConstants.lightMode
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light);

        return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (!FocusScope.of(context).hasPrimaryFocus &&
                  FocusScope.of(context).focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: ScreenUtilInit(
                //minTextAdapt: true,
                scale: AppUtils.isTablet ? 0.85 : 1.05,
                designSize: const Size(414, 896),
                builder: (BuildContext context, Widget? child) {
                  AppConfig.orientation = ScreenUtil().orientation;
                  return FutureBuilder(
                      future: AppWidgetSize().initSize(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return bodyWidget(state);
                        }
                        return bodyWidget(state);
                      });
                }));
      },
    );
  }

  MaterialApp bodyWidget(ThemeState state) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      builder: (BuildContext context, Widget? child) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return CustomError(errorDetails: errorDetails);
        };
        if (firstLaunch) {
          firstLaunch = false;
        }
        return Stack(
          children: [
            MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                child: child!),
            if (log.LogConfig.showLog)
              Positioned(
                bottom: 100.w,
                left: 10.w,
                child: SizedBox(
                    height: 30.w,
                    width: 30.w,
                    child: GestureDetector(
                        onDoubleTap: () {
                          Navigator.of(navigatorKey.currentContext!).pushNamed(
                            ScreenRoutes.logs,
                          );
                        },
                        onLongPress: () {
                          Navigator.of(navigatorKey.currentContext!).pushNamed(
                            ScreenRoutes.logs,
                          );
                        },
                        onTap: () {},
                        child: Opacity(
                          opacity: 0.05,
                          child: AppImages.arihantlaunchlogo(context),
                        ))),
              ),
            // Positioned(
            //   bottom: 0,
            //   right: 25.w,
            //   child: SizedBox(
            //       height: 30.w,
            //       width: 50.w,
            //       child: Opacity(
            //         opacity: 0.05,
            //         child: Text(
            //           AppConfig.appVersion,
            //           style: Theme.of(context).textTheme.headline5,
            //         ),
            //       )),
            // )
          ],
        );
        // });
      },
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      scaffoldMessengerKey: scaffoldkey,
      supportedLocales: const [Locale('en')],
      initialRoute: ScreenRoutes.initConfig,
      navigatorKey: navigatorKey,
      themeMode: state.themeType == AppConstants.darkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      darkTheme: darkTheme(),
      onGenerateRoute: generateRoute,
      theme: lightTheme(),
    );
  }
}
