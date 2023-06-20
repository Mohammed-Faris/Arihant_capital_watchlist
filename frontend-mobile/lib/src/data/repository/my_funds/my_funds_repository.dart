import '../../api_services_urls.dart';
import '../../../models/my_funds/bank_details_model.dart';
import '../../../models/my_funds/check_upi_vpa_model.dart';
import '../../../models/my_funds/get_payments_option_model.dart';
import '../../../models/my_funds/net_bank_data_model.dart';
import '../../../models/my_funds/transaction_history_model.dart';
import '../../../models/my_funds/upi_data_model.dart';
import '../../../models/my_funds/upi_init_process_model.dart';
import '../../../models/my_funds/upi_transaction_status_model.dart';
import 'package:flutter/material.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';

class MyFundsRepository {
  Future<BankDetailsModel> getBankDetailsRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getBankDetails, data: request.getRequest());
    return BankDetailsModel.fromJson(resp);
  }

  Future<GetPaymentOptionModel> getPaymentOptionsModeDetailsRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getPaymentOptionsModeDetails,
        data: request.getRequest());

    return GetPaymentOptionModel.fromJson(resp);
  }

  Future<NetBankingDataModel> getNetBankingDetailsRequest(
      BaseRequest request, String url) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp =
        await httpClient.postJSONRequest(url: url, data: request.getRequest());

    return NetBankingDataModel.fromJson(resp);
  }

  Future<UPIBankingDataModel> getUPIDetailsRequest(
      BaseRequest request, String url) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp =
        await httpClient.postJSONRequest(url: url, data: request.getRequest());

    return UPIBankingDataModel.fromJson(resp);
  }

  Future<TransactionHistoryModel> getTransactionHistoryRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.transactionhistory, data: request.getRequest());

    return TransactionHistoryModel.fromJson(resp);
  }

  Future<Map<String, dynamic>> getTransactionHistoryCancelRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.transactioncancelhistory,
        data: request.getRequest());

    debugPrint('resp data is $resp');
    return resp;
    //return MessageModel.fromJson(resp);
  }

  /*Future<WithdrawFundsModel> getWithdrawFunds(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.withdrawfunds, data: request.getRequest());

    //debugPrint('resp -> $resp');
    return WithdrawFundsModel.fromJson(resp);
  }*/

  Future<Map<String, dynamic>> getWithdrawFunds(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.withdrawfunds, data: request.getRequest());

    //debugPrint('resp -> $resp');
    return resp;
  }

  Future<Map<String, dynamic>> getTransactionHistoryModifyRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.transactionmodifyhistory,
        data: request.getRequest());

    //debugPrint('resp -> $resp');
    return resp;
  }

  Future<CheckUPIVPAModel> checkVpa(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.verifyUPIVPA, data: request.getRequest());

    //debugPrint('resp -> $resp');
    return CheckUPIVPAModel.fromJson(resp);
  }

  Future<UPIInitProcessModel> getUpiInitprocess(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getUPIInitProcess, data: request.getRequest());

    //debugPrint('resp -> $resp');
    return UPIInitProcessModel.fromJson(resp);
  }

  Future<UPITransactionStatusModel> getUpiTransStatus(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getUPITransactionStatus,
        data: request.getRequest());

    //debugPrint('resp -> $resp');
    return UPITransactionStatusModel.fromJson(resp);
  }
}
