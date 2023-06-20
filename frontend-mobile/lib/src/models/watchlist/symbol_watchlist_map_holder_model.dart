class SymbolWatchlistMapHolder {
  static final SymbolWatchlistMapHolder _holder = SymbolWatchlistMapHolder._();

  factory SymbolWatchlistMapHolder() => _holder;

  SymbolWatchlistMapHolder._();

  static Map<String, Set<String>> symbolWatchlistMapping = {};

  add(String symbolId, String watchlist) {
    if (symbolWatchlistMapping.containsKey(symbolId)) {
      symbolWatchlistMapping[symbolId]!.add(watchlist);
    } else {
      Set<String> watchlists = {};
      watchlists.add(watchlist);
      symbolWatchlistMapping.putIfAbsent(symbolId, () => watchlists);
    }
  }

  remove(String symbolId, String watchlist) {
    if (symbolWatchlistMapping.containsKey(symbolId)) {
      symbolWatchlistMapping[symbolId]!.remove(watchlist);
      if (symbolWatchlistMapping[symbolId]!.isEmpty) {
        symbolWatchlistMapping.remove(symbolId);
      }
    }
  }

  updateWatchlist(String oldWatchlist, String newWatchList) {
    symbolWatchlistMapping.forEach((key, value) {
      if (value.contains(oldWatchlist)) {
        value.remove(oldWatchlist);
        value.add(newWatchList);
      }
    });
  }

  removeWatchlist(String watchlist) {
    Set<String> keysToRemove = {};
    symbolWatchlistMapping.forEach((key, value) {
      if (value.contains(watchlist)) {
        value.remove(watchlist);
      }
      if (value.isEmpty) {
        keysToRemove.add(key);
      }
    });
    for (var key in keysToRemove) {
      symbolWatchlistMapping.remove(key);
    }
  }

  clearAll() {
    symbolWatchlistMapping.clear();
  }

  Map<String, Set<String>> getMappedData() {
    return symbolWatchlistMapping;
  }

  Set<String> getWatchlist(String symbolId) {
    return symbolWatchlistMapping[symbolId]!;
  }

  bool isSymbolIdAvailble(String symbolId) {
    return symbolWatchlistMapping.containsKey(symbolId);
  }

  bool isSymbolIdAvailableInGivenWatchlist(String symbolId, String watchlist) {
    return symbolWatchlistMapping.containsKey(symbolId) &&
        symbolWatchlistMapping[symbolId]!.contains(watchlist);
  }
}
