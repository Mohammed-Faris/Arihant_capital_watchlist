part of 'login_bloc.dart';

abstract class LoginState extends ScreenState {}

class LoginInitState extends LoginState {}

class LoginProgressState extends LoginState {}

class LoginFailedState extends LoginState {}

class LoginDoneState extends LoginState {
  TradingLoginModel tradingLoginModel;

  LoginDoneState(this.tradingLoginModel);
}

class RetrivingUser extends LoginState {}

class RetriveUserDoneState extends LoginState {
  RetriveUser retriveUser;

  RetriveUserDoneState(this.retriveUser);
}

class RegisterPinDoneState extends LoginState {
  RegisterPINModel registerPINModel;
  RegisterPinDoneState(this.registerPINModel);
}

class LoginPinDoneState extends LoginState {
  LoginPINModel? loginPINModel;
  LoginPinDoneState([this.loginPINModel]);
}

class UnBlockAccountDoneState extends LoginState {
  UnblockAccountModel unblockAccountModel;
  UnBlockAccountDoneState(this.unblockAccountModel);
}

class ChangePasswordDoneState extends LoginState {
  ChangePasswordModel changePasswordModel;
  ChangePasswordDoneState(this.changePasswordModel);
}

class GenerateOtpDoneState extends LoginState {
  GenerateOtpModel generateOtpModel;
  GenerateOtpDoneState(this.generateOtpModel);
}

class ValidateOtpDoneState extends LoginState {
  ValidateOtpModel validateOtpModel;
  ValidateOtpDoneState(this.validateOtpModel);
}

class ForgetPasswordDoneState extends LoginState {
  ForgetPasswordModel forgetPasswordModel;
  ForgetPasswordDoneState(this.forgetPasswordModel);
}

class ResetPasswordDoneState extends LoginState {
  ResetPasswordModel resetPasswordModel;
  ResetPasswordDoneState(this.resetPasswordModel);
}

class RegisterBiometricDoneState extends LoginState {
  RegisterBiometricModel registerBiometricModel;
  RegisterBiometricDoneState(this.registerBiometricModel);
}

class LoginBiometricDoneState extends LoginState {
  LoginBiometricModel loginBiometricModel;
  LoginBiometricDoneState(this.loginBiometricModel);
}
