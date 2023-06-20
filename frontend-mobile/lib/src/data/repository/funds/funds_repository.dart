import '../../../models/my_funds/fund_view_limit_model.dart';
import '../../../models/my_funds/my_fund_view_updated_model.dart';

import '../../api_services_urls.dart';
import '../../../models/funds/available_funds_model.dart';
import '../../../models/my_funds/funds_transaction_status_model.dart';
import '../../../models/my_funds/my_funds_view_model.dart';
import '../../../models/my_funds/withdraw_funds_max_payout_model.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';

import '../../cache/cache_repository.dart';

class FundsRepository {
  Future<AvailableFundsModel> getAvailableFunds(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getAvailableFunds, data: request.getRequest());

    return AvailableFundsModel.fromJson(resp);
  }

  Future<WithdrawCashMaxPayoutModel> getMaxpayoutWithdrawCash(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    request.addToData("segment", ["ALL"]);
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getMaxPayoutWithdrawCash,
        data: request.getRequest());

    CacheRepository.fundsCache.put('getMaxpayoutWithdrawCash', resp);

    return WithdrawCashMaxPayoutModel.fromJson(resp);
  }

  Future<FundViewModel> getFundViewModel(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.fundsView, data: request.getRequest());
    return FundViewModel.fromJson(resp);
  }

  Future<FundViewUpdatedModel> getFundViewUpdatedModel(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.fundsViewUpdated, data: request.getRequest());
    FundViewUpdatedModel fundViewUpdatedModel =
        FundViewUpdatedModel.fromJson(resp);
    CacheRepository.groupCache
        .put('fundViewUpdatedModel', fundViewUpdatedModel);

    return fundViewUpdatedModel;
  }

  Future<FundViewLimitModel> getFundViewLimitModel(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.fundsViewLimit, data: request.getRequest());
    FundViewLimitModel getFundViewLimitModel =
        FundViewLimitModel.fromJson(resp);
    CacheRepository.groupCache
        .put('getFundViewLimitModel', getFundViewLimitModel);

    return getFundViewLimitModel;
  }

  Future<FundsTransactionStatusUPIModel> getFundTransactionStausModel(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getFundsTransactionUPIStatus,
        data: request.getRequest());

    return FundsTransactionStatusUPIModel.fromJson(resp);
  }
}
