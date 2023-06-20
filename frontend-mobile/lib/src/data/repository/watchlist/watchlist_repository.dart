import '../../../models/watchlist/crop_symbol_list_model.dart';
import '../../api_services_urls.dart';
import '../../cache/cache_repository.dart';
import '../../../models/common/message_model.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/watchlist/watchlist_delete_group_model.dart';
import '../../../models/watchlist/watchlist_group_model.dart';
import '../../../models/watchlist/watchlist_rename_watchlist_model.dart';
import '../../../models/watchlist/watchlist_symbols_model.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';

class WatchlistRepository {
  Future<CorpSymList> getCorpSymListRequest(
    BaseRequest request,
  ) async {
    final corpSymListCache =
        await CacheRepository.corpSymListCache.get('corpSymList');
    if (corpSymListCache != null) {
      return corpSymListCache;
    } else {
      final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
        url: ApiServicesUrls.getCorpSymList,
        data: request.getRequest(),
      );
      final CorpSymList corpSymList = CorpSymList.fromJson(resp);
      CacheRepository.corpSymListCache.put('corpSymList', corpSymList);
      return corpSymList;
    }
  }

  Future<WatchlistGroupModel> getWatchlistGroupsRequest(
      BaseRequest request) async {
    final groupCacheModel = await CacheRepository.groupCache.get('getGroup');
    if (groupCacheModel != null) {
      return groupCacheModel;
    } else {
      final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
        url: ApiServicesUrls.getWatchlistGroups,
        data: request.getRequest(),
      );
      final WatchlistGroupModel groupResponse =
          WatchlistGroupModel.fromJson(resp);
      CacheRepository.groupCache.put('getGroup', groupResponse);
      return groupResponse;
    }
  }

  Future<WatchlistSymbolsModel?> getWatchlistSymbolsRequest(BaseRequest request,
      {required String wId}) async {
    final symbolCacheModel = await CacheRepository.watchlistCache.get(wId);
    if (symbolCacheModel != null) {
      if (symbolCacheModel is WatchlistSymbolsModel) {
        return WatchlistSymbolsModel(
          symbolCacheModel
              .getSymbols()
              .map((symbol) => Symbols.copyModel(symbol))
              .toList(),
        );
      }
    } else {
      final HTTPClient httpClient = HTTPClient();
      final Map<String, dynamic> resp = await httpClient.postJSONRequest(
          url: ApiServicesUrls.getSymbols, data: request.getRequest());
      CacheRepository.watchlistCache
          .put(wId, WatchlistSymbolsModel.fromJson(resp));

      final WatchlistSymbolsModel groupSymbolResponse =
          WatchlistSymbolsModel.fromJson(resp);

      return groupSymbolResponse;
    }
    return null;
  }

  Future<WatchlistDeleteGroupModel> deleteWatchlistGroup(
      BaseRequest request) async {
    final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
      url: ApiServicesUrls.deleteWatchlist,
      data: request.getRequest(),
    );

    return WatchlistDeleteGroupModel.fromJson(resp);
  }

  Future<WatchlistRenameWatchlistModel> renameWatchlistGroup(
      BaseRequest request) async {
    final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
      url: ApiServicesUrls.renameWatchlistGroup,
      data: request.getRequest(),
    );

    return WatchlistRenameWatchlistModel.fromJson(resp);
  }

  Future<MessageModel> reArrangeSymbolInWatchlist(BaseRequest request) async {
    final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
      url: ApiServicesUrls.rearrangeSymbolsInWatchlist,
      data: request.getRequest(),
    );

    return MessageModel.fromJson(resp);
  }

  Future<MessageModel> deleteSymbolInWatchlist(BaseRequest request) async {
    final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
      url: ApiServicesUrls.deleteSymbolsInWatchlist,
      data: request.getRequest(),
    );

    return MessageModel.fromJson(resp);
  }

  Future<WatchlistGroupModel?> updateGroup(String wName, String wId) async {
    final groupCacheModel = await CacheRepository.groupCache.get('getGroup');
    if (groupCacheModel != null) {
      if (groupCacheModel is WatchlistGroupModel) {
        groupCacheModel.groups!
            .firstWhere((element) => element.wId == wId)
            .wName = wName;
        groupCacheModel.groups!
            .firstWhere((element) => element.wId == wId)
            .wId = wName;

        return groupCacheModel;
      }
    }
    return null;
  }

  Future<int> getSymbolCountFromCacheForGroup(String wId) async {
    final symbolCacheModel = await CacheRepository.watchlistCache.get(wId);
    if (symbolCacheModel != null) {
      if (symbolCacheModel is WatchlistSymbolsModel) {
        return WatchlistSymbolsModel(symbolCacheModel
                .getSymbols()
                .map((symbol) => Symbols.copyModel(symbol))
                .toList())
            .symbols
            .length;
      }
    }
    return 0;
  }

  void removeWatchlistItem(String id) {
    CacheRepository.watchlistCache.clear(id);
  }

  void clearAllWatchlistGroups() {
    CacheRepository.groupCache.clearAll();
  }
}
