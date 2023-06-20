import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';

import '../../constants/keys/login_keys.dart';
import '../../constants/storage_constants.dart';
import '../../data/repository/login/login_repository.dart';
import '../../data/store/app_storage.dart';
import '../../data/store/app_store.dart';
import '../../data/store/app_utils.dart';
import '../../models/login/change_password_model.dart';
import '../../models/login/forget_password_model.dart';
import '../../models/login/generate_otp_model.dart';
import '../../models/login/login_biometric_model.dart';
import '../../models/login/login_pin_model.dart';
import '../../models/login/register_biometric_model.dart';
import '../../models/login/register_pin_model.dart';
import '../../models/login/reset_password_model.dart';
import '../../models/login/retrive_user_type.dart';
import '../../models/login/trading_login_model.dart';
import '../../models/login/unblock_account_model.dart';
import '../../models/login/validate_otp_model.dart';
import '../common/base_bloc.dart';
import '../common/screen_state.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends BaseBloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitState());

  late String username;
  late String password;

  @override
  Future<void> eventHandlerMethod(
      LoginEvent event, Emitter<LoginState> emit) async {
    if (event is LoginSubmitEvent) {
      await _handleloginSubmitEvent(event, emit);
    } else if (event is RegisterPinEvent) {
      await _handleRegisterPinEvent(event, emit);
    } else if (event is LoginPinEvent) {
      await _handleLoginPinEvent(event, emit);
    } else if (event is TwoFOTPGenerate) {
      await _handle2FOTP(event, emit);
    } else if (event is RetriveUserEvent) {
      await _handleRetriveUser(event, emit);
    } else if (event is UnBlockAccountEvent) {
      await _handleUnBlockAccountEvent(event, emit);
    } else if (event is ChangePasswordEvent) {
      await _handleChangePasswordEvent(event, emit);
    } else if (event is RegisterBiometricEvent) {
      await _handleRegisterBiometricEvent(event, emit);
    } else if (event is LoginBiometricEvent) {
      await _handleLoginBiometricEvent(event, emit);
    } else if (event is GenerateOtpEvent) {
      await _handleGenerateOtpEvent(event, emit);
    } else if (event is ValidateOtpEvent) {
      await _handleValidateOtpEvent(event, emit);
    } else if (event is Validate2FOtpEvent) {
      await _handleValidate2FOtpEvent(event, emit);
    } else if (event is ResetPasswordEvent) {
      await _handleResetPasswordEvent(event, emit);
    } else if (event is UpdateIsForgotPinForUserEvent) {
      await updatePinStatusForUser(
          event.userId, isForgotPinConstants, event.isForgotPin);
    }
  }

  _handleRetriveUser(RetriveUserEvent event, Emitter<LoginState> emit) async {
    emit(RetrivingUser());
    final BaseRequest request = BaseRequest();
    if (event.enteredUidKey == emailIdKey) {
      request.addToData('email', event.enteredUidValue);
    } else if (event.enteredUidKey == mobileNumKey) {
      request.addToData('mobNo', event.enteredUidValue);
    } else {
      request.addToData('uid', event.enteredUidValue);
    }

    final RetriveUser retriveUser =
        await LoginRepository().retriveUser(request);
    AppStore().setUserName(retriveUser.uName);
    AppUtils().saveDataInAppStorage(userIdKey, event.enteredUidValue);

    emit(RetriveUserDoneState(retriveUser));
  }

  Future<void> _handleloginSubmitEvent(
    LoginSubmitEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginProgressState());
    final BaseRequest request = BaseRequest();
    if (event.enteredUidKey == emailIdKey) {
      request.addToData('email', event.enteredUidValue);
      request.addToData('pwd', event.password);
    } else if (event.enteredUidKey == mobileNumKey) {
      request.addToData('mobNo', event.enteredUidValue);
      request.addToData('pwd', event.password);
    } else {
      request.addToData('uid', event.enteredUidValue);
      request.addToData('pwd', event.password);
    }
    request.addToData('pinStatus', event.pinStatus);
    final TradingLoginModel tradingLoginModel =
        await LoginRepository().sendLoginRequest(request);
    if (event.pinStatus == 'forgotPin') {
      tradingLoginModel.data[isForgotPinConstants] = 'true';
    }

    AppStore().setAccountName(tradingLoginModel.data[accNameConstants]);
    AppStorage().setData(userLoginDetailsKey, tradingLoginModel.data);
    AppUtils().saveLastThreeUserData(
      data: tradingLoginModel.data,
    );

    username = tradingLoginModel.data[uidConstants];
    password = event.password;

    AppUtils().saveDataInAppStorage(userIdKey, username);
    AppUtils().saveDataInAppStorage(passwordKey, password);

    emit(LoginDoneState(tradingLoginModel));
  }

  Future<void> _handleRegisterPinEvent(
    RegisterPinEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginProgressState());

    final BaseRequest request = BaseRequest();

    request.addToData(
        'uid', await AppStore().getSavedDataFromAppStorage(userIdKey));
    request.addToData('pin', event.pin);
    request.addToData(
        'pwd', await AppStore().getSavedDataFromAppStorage(passwordKey));

    final RegisterPINModel registerPINModel =
        await LoginRepository().registerPINRequest(request);

    if (registerPINModel.isSuccess()) {
      updatePinStatusForUser(
          await AppStore().getSavedDataFromAppStorage(userIdKey),
          'pinStatus',
          'enterPin');
      updatePinStatusForUser(
          await AppStore().getSavedDataFromAppStorage(userIdKey),
          isForgotPinConstants,
          'false');
      emit(RegisterPinDoneState(registerPINModel));
    }
  }

  //Pin status in login pin API can be ,
  //enterPin - traditional login
  //loginPin - smart login
  Future<void> _handleLoginPinEvent(
    LoginPinEvent event,
    Emitter<LoginState> emit,
  ) async {
    try {
      emit(LoginProgressState());
      final BaseRequest request = BaseRequest();
      request.addToData(
          'uid', await AppStore().getSavedDataFromAppStorage(userIdKey));
      request.addToData('pin', event.pin);
      request.addToData(
          'pinStatus', event.isLoginPin ? 'loginPin' : 'enterPin');
      final LoginPINModel loginPINModel =
          await LoginRepository().loginPINRequest(request);
      if (loginPINModel.isSuccess() && event.isLoginPin) {
        AppStore().setAccountName(loginPINModel.data[accNameConstants]);
        Future.wait(<Future<dynamic>>[
          AppStorage().setData(userLoginDetailsKey, loginPINModel.data),
        ]);
        await AppUtils().saveLastThreeUserData(
          data: loginPINModel.data,
        );
        emit(LoginPinDoneState(loginPINModel));
      } else {
        emit(LoginPinDoneState());
      }
    } on FailedException catch (e) {
      emit(LoginFailedState()
        ..errorCode = e.code
        ..errorMsg = e.msg);
    }
  }

  Future<void> _handleUnBlockAccountEvent(
    UnBlockAccountEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginProgressState());

    final BaseRequest request = BaseRequest();

    if (event.enteredUidKey == emailIdKey) {
      request.addToData('email', event.enterUidValue);
    } else if (event.enteredUidKey == mobileNumKey) {
      request.addToData('mobNo', event.enterUidValue);
    } else {
      request.addToData('uid', event.enterUidValue);
    }

    request.addToData('panNumber', event.panNumber);

    final UnblockAccountModel unblockAccountModel =
        await LoginRepository().unBlockAccountRequest(request);

    if (unblockAccountModel.isSuccess()) {
      emit(UnBlockAccountDoneState(unblockAccountModel));
    }
  }

  Future<void> _handleChangePasswordEvent(
    ChangePasswordEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginProgressState());

    final BaseRequest request = BaseRequest();

    request.addToData('newPwd', event.newPwd);
    request.addToData('pwd', event.pwd);

    final ChangePasswordModel changePasswordModel =
        await LoginRepository().changePasswordRequest(request);

    final dynamic userLoginDetails =
        await AppStorage().getData(userLoginDetailsKey);
    if (userLoginDetails != null) {
      updatePinStatusForUser(
          await AppStore().getSavedDataFromAppStorage(userIdKey),
          'pinStatus',
          'setPin');
    }

    emit(ChangePasswordDoneState(changePasswordModel));
  }

  Future<void> _handleGenerateOtpEvent(
    GenerateOtpEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginProgressState());

    final BaseRequest request = BaseRequest();

    if (event.enteredUidKey == emailIdKey) {
      request.addToData('email', event.enterUidValue);
    } else if (event.enteredUidKey == mobileNumKey) {
      request.addToData('mobNo', event.enterUidValue);
    } else {
      request.addToData('uid', event.enterUidValue);
    }
    request.addToData('panNumber', event.panNumber);

    final GenerateOtpModel generateOtpModel =
        await LoginRepository().genertateOtpRequest(request);

    if (generateOtpModel.isSuccess()) {
      emit(GenerateOtpDoneState(generateOtpModel));
    }
  }

  Future<void> _handleValidateOtpEvent(
    ValidateOtpEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginProgressState());

    final BaseRequest request = BaseRequest();

    request.addToData('uid', event.uid);
    request.addToData('otp', event.otp);

    final ValidateOtpModel validateOtpModel =
        await LoginRepository().validateOtpRequest(request);

    if (validateOtpModel.isSuccess()) {
      emit(ValidateOtpDoneState(validateOtpModel));
    }
  }

  Future<void> _handleResetPasswordEvent(
    ResetPasswordEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginProgressState());
    final BaseRequest request = BaseRequest();
    request.addToData('uid', event.uuid);
    request.addToData('pwd', event.pwd);
    final ResetPasswordModel resetPasswordModel =
        await LoginRepository().resetPasswordRequest(request);
    await AppUtils().removeCurrentUser(uid: event.uuid);
    if (resetPasswordModel.isSuccess()) {
      emit(ResetPasswordDoneState(resetPasswordModel));
    }
  }

  Future<void> _handleRegisterBiometricEvent(
    RegisterBiometricEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginProgressState());

    final BaseRequest request = BaseRequest();

    request.addToData(
        'uid', await AppStore().getSavedDataFromAppStorage(userIdKey));
    request.addToData(
        'pwd', await AppStore().getSavedDataFromAppStorage(passwordKey));

    final RegisterBiometricModel registerBiometricModel =
        await LoginRepository().registerBiometricRequest(request);

    if (registerBiometricModel.isSuccess()) {
      AppUtils().saveLastThreeUserData(
        biometric: true,
        token: registerBiometricModel.data["bioToken"],
      );
      emit(RegisterBiometricDoneState(registerBiometricModel));
    }
  }

  Future<void> _handleLoginBiometricEvent(
    LoginBiometricEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginProgressState());
    final BaseRequest request = BaseRequest();
    request.addToData(
        'uid', await AppStore().getSavedDataFromAppStorage(userIdKey));
    request.addToData('bioToken', event.biometricToken);

    final LoginBiometricModel loginBiometricModel =
        await LoginRepository().loginBiometricRequest(request);

    if (loginBiometricModel.isSuccess()) {
      AppStore().setAccountName(loginBiometricModel.data[accNameConstants]);
      Future.wait(<Future<dynamic>>[
        AppStorage().setData(userLoginDetailsKey, loginBiometricModel.data),
      ]);

      AppUtils().saveLastThreeUserData(
          data: loginBiometricModel.data,
          biometric: true,
          token: event.biometricToken);
      emit(LoginBiometricDoneState(loginBiometricModel));
    }
  }

//update pinStatus in AppStorage  & userlogindetails as enterPin once pin is set.
  Future<void> updatePinStatusForUser(
    String uid,
    String key,
    String value,
  ) async {
    AppUtils().saveLastThreeUserData(
      uid: uid,
      key: key,
      value: value,
    );
  }

  @override
  LoginState getErrorState() {
    return LoginFailedState();
  }

  _handle2FOTP(TwoFOTPGenerate event, Emitter<LoginState> emit) async {
    emit(LoginProgressState());

    final BaseRequest request = BaseRequest();
    String uid = await AppStore().getSavedDataFromAppStorage(userIdKey);

    request.addToData('uid', uid);

    final GenerateOtpModel generateOtpModel =
        await LoginRepository().sendOTP(request);

    if (generateOtpModel.isSuccess()) {
      emit(GenerateOtpDoneState(generateOtpModel));
    }
  }

  _handleValidate2FOtpEvent(
      Validate2FOtpEvent event, Emitter<LoginState> emit) async {
    emit(LoginProgressState());

    final BaseRequest request = BaseRequest();
    String uid = await AppStore().getSavedDataFromAppStorage(userIdKey);

    request.addToData('uid', uid);
    request.addToData('otp', event.otp);

    final ValidateOtpModel validateOtpModel =
        await LoginRepository().verifyOtp(request);

    if (validateOtpModel.isSuccess()) {
      emit(ValidateOtpDoneState(validateOtpModel));
    }
  }
}
