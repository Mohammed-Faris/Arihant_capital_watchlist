import '../../blocs/sessionvalidation/session_validation_bloc.dart';
import '../../blocs/tab/menu_bottom_tab_bloc.dart';
import '../../constants/app_constants.dart';
import '../../constants/keys/login_keys.dart';
import '../../constants/storage_constants.dart';
import '../../data/store/app_store.dart';
import '../../data/store/app_utils.dart';
import '../navigation/screen_routes.dart';
import '../screens/base/base_screen.dart';
import '../widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SessionValidationScreen extends BaseScreen {
  final dynamic arguments;

  const SessionValidationScreen(this.arguments, {Key? key}) : super(key: key);

  @override
  SessionValidationScreenState createState() => SessionValidationScreenState();
}

class SessionValidationScreenState
    extends BaseAuthScreenState<SessionValidationScreen> {
  late String clickAction;
  late bool isFreshLaunch;
  late SessionValidationBloc _sessionValidationBloc;

  @override
  void initState() {
    if (widget.arguments[AppConstants.pushClickAction] != null) {
      clickAction = widget.arguments[AppConstants.pushClickAction];
    }

    isFreshLaunch = widget.arguments[AppConstants.isFreshLaunch];

    _sessionValidationBloc = BlocProvider.of<SessionValidationBloc>(context);
    _sessionValidationBloc.add(ValidateSessionEvent());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<SessionValidationBloc, SessionValidationState>(
        listener: (_, SessionValidationState state) {
          if (state is SessionValidState) {
            _onSessionValid();
          } else if (state is SessionInValidState) {
            _onSessionInValid();
          }
        },
        builder: (_, state) {
          if (state is SessionValidationInitState ||
              state is SessionValidationProgressState) {
            return const LoaderWidget();
          } else {
            return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
            );
          }
        },
        buildWhen: (_, state) {
          return state is SessionValidationInitState ||
              state is SessionValidationProgressState;
        },
      ),
    );
  }

  void _onSessionValid() {
    MenuBottomTabBloc.pushNavigation = AppConstants.mnu_notification;
    pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen, arguments: {
      'pageName': ScreenRoutes.myAccount,
    });
  }

  void _onSessionInValid() {
    MenuBottomTabBloc.pushNavigation = AppConstants.mnu_notification;
    _moveToLoginScreen();
  }

  Future<void> _moveToLoginScreen() async {
    var getSmartLoginDetails = await AppUtils().getsmartDetails();
    if (getSmartLoginDetails == null) {
      pushAndRemoveUntilNavigation(ScreenRoutes.loginScreen);
    } else {
      final bool checkPin = getSmartLoginDetails != null &&
          (getSmartLoginDetails?['pin'] ?? false);
      final bool checkBiometric = getSmartLoginDetails != null &&
          (getSmartLoginDetails?['biometric'] ?? false);

      if (checkPin || checkBiometric) {
        if (getSmartLoginDetails != null) {
          AppStore().setUserName(getSmartLoginDetails["userName"]);
          AppUtils()
              .saveDataInAppStorage(userIdKey, getSmartLoginDetails["uid"]);

          AppStore().setAccountName(getSmartLoginDetails[accNameConstants]);
          if (getSmartLoginDetails['pinStatus'] == 'setPin') {
            pushAndRemoveUntilNavigation(ScreenRoutes.loginScreen);
          } else {
            pushAndRemoveUntilNavigation(
              ScreenRoutes.smartLoginScreen,
              arguments: {
                'loginPin': true,
              },
            );
          }
        } else {
          pushAndRemoveUntilNavigation(
            ScreenRoutes.smartLoginScreen,
            arguments: {
              'loginPin': true,
            },
          );
        }
      } else {
        pushAndRemoveUntilNavigation(ScreenRoutes.loginScreen);
      }
    }
  }
}
