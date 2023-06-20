import 'package:acml/src/blocs/common/screen_state.dart';
import 'package:msil_library/utils/config/infoIDConfig.dart';

import '../../api_services_urls.dart';
import '../../../models/login/change_password_model.dart';
import '../../../models/login/forget_password_model.dart';
import '../../../models/login/reset_password_model.dart';
import '../../../models/login/login_biometric_model.dart';
import '../../../models/login/login_pin_model.dart';
import '../../../models/login/register_biometric_model.dart';
import '../../../models/login/register_pin_model.dart';
import '../../../models/login/generate_otp_model.dart';
import '../../../models/login/retrive_user_type.dart';
import '../../../models/login/trading_login_model.dart';
import '../../../models/login/unblock_account_model.dart';
import '../../../models/login/validate_otp_model.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';

class LoginRepository {
  Future<RetriveUser> retriveUser(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.retriveUser, data: request.getRequest());

    return RetriveUser.fromJson(resp);
  }

  Future<GenerateOtpModel> sendOTP(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.sendSMS, data: request.getRequest());

    return GenerateOtpModel.fromJson(resp);
  }

  Future<dynamic> validateSession() async {
    final HTTPClient httpClient = HTTPClient();
    final BaseRequest request = BaseRequest();
    final resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.validateSession, data: request.getRequest());
    if (resp["response"]["infoID"] == InfoIDConfig.invalidSessionCode) {
      return ScreenState()
        ..errorCode = InfoIDConfig.invalidSessionCode
        ..errorMsg = resp["response"]["infoMsg"];
    }
    return true;
  }

  Future<ValidateOtpModel> verifyOtp(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.validateOTP, data: request.getRequest());

    return ValidateOtpModel.fromJson(resp);
  }

  Future<TradingLoginModel> sendLoginRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.login2fa, data: request.getRequest());

    return TradingLoginModel.fromJson(resp);
  }

  Future<TradingLoginModel> sendLogoutRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.logout, data: request.getRequest());

    return TradingLoginModel.fromJson(resp);
  }

  Future<RegisterPINModel> registerPINRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.registerPIN, data: request.getRequest());

    return RegisterPINModel.fromJson(resp);
  }

  Future<LoginPINModel> loginPINRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.loginPIN, data: request.getRequest());

    return LoginPINModel.fromJson(resp);
  }

  Future<UnblockAccountModel> unBlockAccountRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.unBlockAccount, data: request.getRequest());

    return UnblockAccountModel.fromJson(resp);
  }

  Future<ChangePasswordModel> changePasswordRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.changePassword, data: request.getRequest());

    return ChangePasswordModel.fromJson(resp);
  }

  Future<RegisterBiometricModel> registerBiometricRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.registerBiometric, data: request.getRequest());

    return RegisterBiometricModel.fromJson(resp);
  }

  Future<LoginBiometricModel> loginBiometricRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.loginBiometric, data: request.getRequest());

    return LoginBiometricModel.fromJson(resp);
  }

  Future<GenerateOtpModel> genertateOtpRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.generateOtp, data: request.getRequest());

    return GenerateOtpModel.fromJson(resp);
  }

  Future<ValidateOtpModel> validateOtpRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.validateOtp, data: request.getRequest());

    return ValidateOtpModel.fromJson(resp);
  }

  Future<ResetPasswordModel> resetPasswordRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.resetPassword, data: request.getRequest());

    return ResetPasswordModel.fromJson(resp);
  }

  Future<ForgetPasswordModel> forgetPasswordRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.forgetPassword, data: request.getRequest());

    return ForgetPasswordModel.fromJson(resp);
  }
}
