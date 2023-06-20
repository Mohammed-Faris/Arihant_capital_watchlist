import 'dart:async';

import 'package:acml/src/constants/app_constants.dart';
import 'package:acml/src/screen_util/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/stream/streaming_manager.dart';
import 'package:msil_library/utils/config/errorMsgConfig.dart';
import 'package:msil_library/utils/config/infoIDConfig.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/invalid_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';
import '../../data/store/app_store.dart';
import '../../data/utility/invalid_session_validator.dart';
import '../../ui/screens/acml_app.dart';
import '../../ui/screens/base/base_screen.dart';
import '../../ui/screens/connectivity.dart';
import '../../ui/styles/app_images.dart';
import 'screen_state.dart';

abstract class BaseBloc<E, S extends ScreenState> extends Bloc<E, S> {
  BaseBloc(S initialState) : super(initialState) {
    on<E>(
      eventHandler,
    );
  }

  Future<void> eventHandler(E event, Emitter<S> emit) async {
    try {
      await eventHandlerMethod(event, emit);
    } on ServiceException catch (ex) {
      if (ex.code == AppConstants.noNetworkExceptionErrorCode) {
        connectivity.initialise();
      }
      emit(getErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg.replaceAll(
            ErrorMsgConfig.not_able_to_resolve_service +
                AppConstants.noNetworkExceptionErrorCode,
            ErrorMsgConfig.not_able_to_resolve_service));
    } on InvalidException catch (ex) {
      if (!InvalidSession.isInvalidsession ||
          ex.code == InfoIDConfig.invalidSessionCode) {
        InvalidSession.isInvalidsession = false;
        showSessionExpired(ex);
        try {
          StreamingManager().streamClose();
          // ignore: empty_catches
        } catch (e) {}
        if (ex.code == AppConstants.invalidAppInDErrorCode) {
          handleInvalidAppID();
        } else if (ex.code == AppConstants.invalidSessionErrorCode) {
          //check invalid seesion error.
          handleLogout(
            ex.msg,
            false,
            false,
            isInvalidSession: true,
          );
        }
        emit(getErrorState()
          ..isInvalidException = true
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
      }
    } on FailedException catch (ex) {
      emit(getErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  void showSessionExpired(InvalidException ex) {
    scaffoldkey.currentState?.showMaterialBanner(MaterialBanner(
      backgroundColor: Theme.of(navigatorKey.currentContext!).colorScheme.error,
      content: Text(
        ex.msg,
        style: TextStyle(
          fontSize: 16.w,
          fontFamily: "futura",
          color: AppStore().getThemeData() == AppConstants.darkMode
              ? const Color(0xFFFBF2F4)
              : const Color(0xFFB00020),
        ),
      ),
      leading: AppImages.bankNotificationBadgelogo(navigatorKey.currentContext!,
          height: 25.w, isColor: true),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          color:
              Theme.of(navigatorKey.currentContext!).textTheme.bodySmall?.color,
          onPressed: () {
            scaffoldkey.currentState?.hideCurrentMaterialBanner();
            scaffoldkey.currentState?.clearMaterialBanners();

            scaffoldkey.currentState?.removeCurrentMaterialBanner();
          },
        ),
      ],
    ));
    Future.delayed(const Duration(seconds: 3), () {
      scaffoldkey.currentState?.hideCurrentMaterialBanner();
      scaffoldkey.currentState?.clearMaterialBanners();

      scaffoldkey.currentState?.removeCurrentMaterialBanner();
    });
  }

  Future<void> eventHandlerMethod(E event, Emitter<S> emit);

  S getErrorState();
}
