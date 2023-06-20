import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';

import '../../../models/quote/corporate_action/quote_corporate_action_model.dart';
import '../../../models/quote/get_symbol_info_model.dart';
import '../../../models/quote/quote_analysis/pivot_points_model.dart';
import '../../../models/quote/quote_analysis/technical_model.dart';
import '../../../models/quote/quote_analysis/volume_analysis_model.dart';
import '../../../models/quote/quote_company_model.dart';
import '../../../models/quote/quote_deals_block/quote_block_deals_model.dart';
import '../../../models/quote/quote_deals_bulk/quote_deals_bulk_model.dart';
import '../../../models/quote/quote_expiry/quote_expiry.dart';
import '../../../models/quote/quote_financials/financials_model.dart';
import '../../../models/quote/quote_financials/financials_yearly_model.dart';
import '../../../models/quote/quote_financials/quote_financials_view_more/quote_financials_share_holidings_model.dart';
import '../../../models/quote/quote_financials/quote_financials_view_more/quote_quarterly_income_statements.dart';
import '../../../models/quote/quote_financials/quote_financials_view_more/quote_yearly_income_statement.dart';
import '../../../models/quote/quote_fundamentals/quote_financials_ratios.dart';
import '../../../models/quote/quote_fundamentals/quote_key_stats.dart';
import '../../../models/quote/quote_futures/quote_futures.dart';
import '../../../models/quote/quote_news_detail_model.dart';
import '../../../models/quote/quote_news_model.dart';
import '../../../models/quote/quote_options/quote_options.dart';
import '../../../models/quote/quote_peer_model.dart';
import '../../../models/quote/quote_performance/quote_contract_info.dart';
import '../../../models/quote/quote_performance/quote_delivery_data.dart';
import '../../../models/quote/sector_model.dart';
import '../../api_services_urls.dart';

class QuoteRepository {
  Future<GetSymbolModel> getSymbolInfoRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getSymbolInfo, data: request.getRequest());

    return GetSymbolModel.fromJson(resp);
  }

  Future<SectorModel> getSectorNameRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getSectorName, data: request.getRequest());

    return SectorModel.fromJson(resp);
  }

  Future<QuoteCompanyModel> getQuoteCompanyRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getQuoteCompany, data: request.getRequest());

    return QuoteCompanyModel.fromJson(resp);
  }

  Future<QuoteContractInfo> getContractInfoRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getPerformanceContractInfo,
        data: request.getRequest());

    return QuoteContractInfo.fromJson(resp);
  }

  Future<QuoteDeliveryData> getDeliveryDataRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getPerformanceDeliveyData,
        data: request.getRequest());

    return QuoteDeliveryData.fromJson(resp);
  }

  Future<QuoteKeyStats> getKeyStatsRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getFundamentalKeyStats,
        data: request.getRequest());

    return QuoteKeyStats.fromJson(resp);
  }

  Future<QuoteFinancialsRatios> getFinancialsRatiosRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getFundamentalFinancialRatios,
        data: request.getRequest());

    return QuoteFinancialsRatios.fromJson(resp);
  }

  Future<QuotePeerModel> getPeersRatioRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getPeersRatio, data: request.getRequest());

    return QuotePeerModel.fromJson(resp);
  }

  Future<QuoteFuturesModel> getQuoteFuturesExpiryRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getQuoteFuture, data: request.getRequest());

    return QuoteFuturesModel.fromJson(resp);
  }

  Future<OptionQuoteModel> getQuoteOptionsRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getQuoteOption, data: request.getRequest());

    return OptionQuoteModel.fromJson(resp);
  }

  Future<QuoteExpiry> getQuoteExpiryListRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getQuoteExpiryList, data: request.getRequest());

    return QuoteExpiry.fromJson(resp);
  }

  Future<QuoteNewsModel> getNewsRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getQuoteNews, data: request.getRequest());

    return QuoteNewsModel.fromJson(resp);
  }

  Future<QuoteNewsDetailModel> getNewsDetailRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getQuoteNewsDetail, data: request.getRequest());

    return QuoteNewsDetailModel.fromJson(resp);
  }

  Future<QuoteCorporateActionModel> getCorporateActionRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getCorporateAction, data: request.getRequest());

    return QuoteCorporateActionModel.fromJson(resp);
  }

  Future<QuoteBlockDealsModel> getQuoteBlockDealsRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getQuoteBlockDeals, data: request.getRequest());

    return QuoteBlockDealsModel.fromJson(resp);
  }

  Future<QuoteBlockDealsModel> getMarketBlockDealsRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getMarketBlockDeals, data: request.getRequest());

    return QuoteBlockDealsModel.fromJson(resp);
  }

  Future<QuotesBulkDealsModel> getMarketsBulkDealsRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getMarketBulkDeals, data: request.getRequest());

    return QuotesBulkDealsModel.fromJson(resp);
  }

  Future<QuotesBulkDealsModel> getQuoteBulkDealsRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getQuoteBulkDeals, data: request.getRequest());

    return QuotesBulkDealsModel.fromJson(resp);
  }

  Future<FinancialsModel> getQuoteFinancialQuarterRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getQuoteFinancialsQuarter,
        data: request.getRequest());

    return FinancialsModel.fromJson(resp);
  }

  Future<FinancialsYearly> getQuoteFinancialYearlyRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getQuoteFinancialsYearly,
        data: request.getRequest());

    return FinancialsYearly.fromJson(resp);
  }

  Future<FinancialsShareHoldings> getQuoteShareHoldingRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getQuoteFinancialsShareHolding,
        data: request.getRequest());

    return FinancialsShareHoldings.fromJson(resp);
  }

  Future<QuarterlyIncomeStatement> getQuoteQuarterlyIncomeStatementRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getQuoteFinancialsQuarter,
        data: request.getRequest());

    return QuarterlyIncomeStatement.fromJson(resp);
  }

  Future<YearlyIncomeStatement> getQuoteYearlyIncomeStatementRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getQuoteFinancialsIncomeStatements,
        data: request.getRequest());

    return YearlyIncomeStatement.fromJson(resp);
  }

  Future<Technical> getQuoteTechnicalAnalysisRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getTechnicalRatio, data: request.getRequest());

    return Technical.fromJson(resp);
  }

  Future<Technical> getQuoteMovingAveragesRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getMovingAverages, data: request.getRequest());

    return Technical.fromJson(resp);
  }

  Future<PivotPoints> getQuotePivotPointsRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getPivotsPoints, data: request.getRequest());

    return PivotPoints.fromJson(resp);
  }

  Future<VolumeAnalysis> getQuoteVolumeRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getVolumeAnalysis, data: request.getRequest());

    return VolumeAnalysis.fromJson(resp);
  }
}
