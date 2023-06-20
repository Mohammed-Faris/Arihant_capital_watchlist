part of 'login_bloc.dart';

abstract class LoginEvent {}

class LoginInitEvent extends LoginEvent {}

class LoginSubmitEvent extends LoginEvent {
  final String enteredUidKey;
  final String enteredUidValue;
  final String password;
  final String pinStatus;
  LoginSubmitEvent(
    this.enteredUidKey,
    this.enteredUidValue,
    this.password,
    this.pinStatus,
  );
}

class RegisterPinEvent extends LoginEvent {
  final String pin;
  RegisterPinEvent(this.pin);
}

class RetriveUserEvent extends LoginEvent {
  final String enteredUidKey;
  final String enteredUidValue;
  RetriveUserEvent(
    this.enteredUidKey,
    this.enteredUidValue,
  );
}

class LoginPinEvent extends LoginEvent {
  final String pin;
  final bool isLoginPin;
  LoginPinEvent(
    this.pin,
    this.isLoginPin,
  );
}

class TwoFOTPGenerate extends LoginEvent {}

class UnBlockAccountEvent extends LoginEvent {
  final String enteredUidKey;
  final String enterUidValue;
  final String panNumber;
  UnBlockAccountEvent(
    this.enteredUidKey,
    this.enterUidValue,
    this.panNumber,
  );
}

class ChangePasswordEvent extends LoginEvent {
  final String newPwd;
  final String pwd;
  ChangePasswordEvent(this.newPwd, this.pwd);
}

class GenerateOtpEvent extends LoginEvent {
  final String enteredUidKey;
  final String enterUidValue;
  final String panNumber;
  GenerateOtpEvent(
    this.enteredUidKey,
    this.enterUidValue,
    this.panNumber,
  );
}

class ValidateOtpEvent extends LoginEvent {
  final String uid;
  final String otp;
  ValidateOtpEvent(this.uid, this.otp);
}

class Validate2FOtpEvent extends LoginEvent {
  final String otp;
  Validate2FOtpEvent(this.otp);
}

class ResetPasswordEvent extends LoginEvent {
  final String uuid;
  final String pwd;
  ResetPasswordEvent(this.uuid, this.pwd);
}

class RegisterBiometricEvent extends LoginEvent {
  RegisterBiometricEvent();
}

class LoginBiometricEvent extends LoginEvent {
  String biometricToken;
  LoginBiometricEvent(this.biometricToken);
}

class UpdateIsForgotPinForUserEvent extends LoginEvent {
  String userId;
  String isForgotPin;
  UpdateIsForgotPinForUserEvent(
    this.userId,
    this.isForgotPin,
  );
}
