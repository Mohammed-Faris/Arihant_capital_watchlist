import 'symbols_model.dart';
import 'package:msil_library/models/base/base_model.dart';
import 'package:rxdart/rxdart.dart';

class StreamModel<T extends Symbols> extends BaseModel {
  late List<BehaviorSubject<T>> symbolSubjects;

  StreamModel(this.symbolSubjects);

  StreamModel.fromJson(
      T Function() object, Map<String, dynamic> json, String rootJsonKey)
      : super.fromJSON(json) {
    if (data[rootJsonKey] != null) {
      symbolSubjects = <BehaviorSubject<T>>[];
      data[rootJsonKey].forEach((v) {
        symbolSubjects.add(BehaviorSubject<T>.seeded(object()..fromJson(v)));
      });
    }
  }

  StreamModel.copyModel(T Function() object, StreamModel<T> watchlistSymbol) {
    symbolSubjects = <BehaviorSubject<T>>[];
    for (final BehaviorSubject<T> symbol in watchlistSymbol.symbolSubjects) {
      final BehaviorSubject<T> newSymbols = BehaviorSubject.seeded(
        object()..copyModel(symbol.value),
      );
      symbolSubjects.add(newSymbols);
    }
  }

  /// Setter which converts [List<WatchlistSymbolsModel>] into [List<BehaviorSubject<WatchlistSymbolsModel>>]
  /// and updates [symbolSubjects]
  set streamSymbolss(List<T> symbols) {
    symbolSubjects =
        symbols.map((T symbol) => BehaviorSubject<T>.seeded(symbol)).toList();
  }

  /// Getter which converts [List<BehaviorSubject<WatchlistSymbolsModel>>] into [List<WatchlistSymbolsModel>]
  /// and returns the converted one
  List<T> get streamSymbolss =>
      symbolSubjects.map((BehaviorSubject<T> symbol) => symbol.value).toList();

  void notifyListItem(int index) {
    symbolSubjects[index].add(symbolSubjects[index].value);
  }
}
