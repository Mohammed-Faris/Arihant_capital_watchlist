import 'package:flutter/foundation.dart';

import '../../../constants/app_constants.dart';
import '../../store/app_store.dart';
import '../../../ui/screens/base/base_screen.dart';
import 'package:msil_library/utils/config/infoIDConfig.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../models/my_account/account_info.dart';
import '../../../models/my_account/client_details.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';

import '../../api_services_urls.dart';
import '../../cache/cache_repository.dart';

class MyAccountRepository {
  Future<ClientDetails> getClientDetails() async {
    final BaseRequest request = BaseRequest();

    final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
      url: ApiServicesUrls.getClientDetails,
      data: request.getRequest(),
    );
    final ClientDetails clientDetails =
        ClientDetails.fromJson(resp["response"]["data"]);
    CacheRepository.groupCache.put('getClientDetails', clientDetails);

    AppStore.isNomineeAvailable.value =
        (((clientDetails.nomineeContactDtls.isNotEmpty) ||
            (clientDetails.nomineeNsdl.isNotEmpty) ||
            (clientDetails.nomineeCdsl.isNotEmpty)));

    return clientDetails;
  }

  Future<void> getAccountInfo({bool fetchAgain = true}) async {
    try {
      final accountInfoDetails =
          await CacheRepository.groupCache.get('accountInfoDetails');
      late AccountInfo accountInfo;
      if (fetchAgain || accountInfoDetails == null) {
        final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
          url: ApiServicesUrls.accountInfo,
          data: BaseRequest().getRequest(),
        );
        CacheRepository.groupCache.put('accountInfoDetails', resp);

        accountInfo = AccountInfo.fromJson(resp);
      } else {
        accountInfo = AccountInfo.fromJson(accountInfoDetails);
      }
      AppStore()
          .setisActivated(accountInfo.accountStatus == AppConstants.activated);
      AppStore().setAccountStatus(accountInfo.accountStatus);

      // return accountInfo;
    } catch (e) {
      debugPrint('');
    }
  }

  Future<String> getNomineeUrl(String type) async {
    BaseRequest request = BaseRequest();
    request.addToData("type", type);
    try {
      final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
        url: ApiServicesUrls.addNomineeUrl,
        data: request.getRequest(),
      );
      if (resp["response"]["infoID"] == InfoIDConfig.invalidSessionCode) {
        throw ServiceException(
            InfoIDConfig.invalidSessionCode, resp["response"]["infoMsg"]);
      }
      return resp["response"]["data"]["ssoURL"];
    } catch (e) {
      var error = e as ServiceException;
      showToast(message: error.msg, isError: true);
      throw ServiceException(e.code, e.msg);
    }
  }

  Future<String> getSSO() async {
    BaseRequest request = BaseRequest();
    try {
      final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
        url: ApiServicesUrls.ssoLoginUrl,
        data: request.getRequest(),
      );
      if (resp["response"]["infoID"] == InfoIDConfig.invalidSessionCode) {
        throw ServiceException(
            InfoIDConfig.invalidSessionCode, resp["response"]["infoMsg"]);
      }
      return resp["response"]["data"]["ssoURL"];
    } catch (e) {
      var error = e as ServiceException;
      showToast(message: error.msg, isError: true);
      throw ServiceException(e.code, e.msg);
    }
  }
}
