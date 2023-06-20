import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';

import '../../../models/common/message_model.dart';
import '../../../models/search/search_model.dart';
import '../../../models/watchlist/watchlist_group_model.dart';
import '../../api_services_urls.dart';
import '../../cache/cache_repository.dart';
import '../../store/app_storage.dart';

class SearchRepository {
  Future<SearchSymbolsModel> searchSymbolRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.search,
        data: request.getRequest(),
        isEncryption: false);

    return SearchSymbolsModel.fromJson(resp);
  }

  Future<MessageModel> addSymbolInGroups(BaseRequest request) async {
    final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
      url: ApiServicesUrls.addSymbols,
      data: request.getRequest(),
    );

    return MessageModel.fromJson(resp);
  }

  Future<void> updateWatchlistGroup(Groups group) async {
    final groupCacheModel = await CacheRepository.groupCache.get('getGroup');
    if (groupCacheModel != null) {
      if (groupCacheModel is WatchlistGroupModel) {
        if (groupCacheModel.groups?.isNotEmpty ?? false) {
          if (groupCacheModel.groups!
              .where((element) => element.defaultMarketWatch == true)
              .toList()
              .isNotEmpty) {
            groupCacheModel.groups!
                .firstWhere((element) => element.defaultMarketWatch == true)
                .defaultMarketWatch = false;
          }
        }
      }
    }
    groupCacheModel.groups!.add(group);
    CacheRepository.groupCache.put('getGroup', groupCacheModel);
    var accDetails = await AppStorage().getData("userLoginDetailsKey");

    await AppStorage().setData("selcetedWatchlist",
        {"accName": accDetails["accName"], "selcetedWatchlist": group.wName});
  }

  Future<MessageModel> deleteSymbolInGroups(BaseRequest request) async {
    final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
      url: ApiServicesUrls.deletegroupSymbols,
      data: request.getRequest(),
    );

    return MessageModel.fromJson(resp);
  }

  Future<MessageModel> addSymbolsToNewGroup(BaseRequest request) async {
    final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
      url: ApiServicesUrls.addGroup,
      data: request.getRequest(),
    );
    return MessageModel.fromJson(resp);
  }
}
