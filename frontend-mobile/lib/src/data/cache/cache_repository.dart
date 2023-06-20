import 'package:acml/src/constants/app_constants.dart';

import '../../models/watchlist/symbol_watchlist_map_holder_model.dart';
import '../repository/watchlist/watchlist_repository.dart';
import '../store/app_storage.dart';
import '../store/app_store.dart';
import 'acml_cache.dart';
import 'cache.dart';

class CacheRepository {
  static final Cache corpSymListCache = ACMLCache();
  static final Cache watchlistCache = ACMLCache();
  static final Cache groupCache = ACMLCache();
  static final Cache holdingsCache = ACMLCache();
  static final Cache fundsCache = ACMLCache();
  static final Cache positions = ACMLCache();
  static final Cache orderbook = ACMLCache();
  static final Cache alerts = ACMLCache();

  clearCache({bool fromLogin = false}) {
    CacheRepository.positions.clearAll();
    CacheRepository.orderbook.clearAll();
    CacheRepository.holdingsCache.clearAll();
    CacheRepository.fundsCache.clearAll();
    CacheRepository.watchlistCache.clearAll();
    CacheRepository.corpSymListCache.clearAll();
    CacheRepository.alerts.clearAll();

    AppStore().setAccountStatus(AppConstants.activated);
    AppStore().setCurrencyAvailablity(false);
    AppStore().setFnoAvailability(false);
    SymbolWatchlistMapHolder().clearAll();
    AppConstants.connectedSocket = false;
    AppStore.isNomineeAvailable.value = true;

    WatchlistRepository().clearAllWatchlistGroups();
    AppStorage().removeData('getBankdetailkey');
    AppStorage().removeData('getPaymentOptionkey');
    AppStorage().removeData('getRecentFundTransaction');
    AppStorage().removeData('getFundHistorydata');
    AppStorage().removeData('getFundViewUpdatedModel');
    if (!fromLogin) {
      AppStore().setPushClicked(false);
    }
  }
}
