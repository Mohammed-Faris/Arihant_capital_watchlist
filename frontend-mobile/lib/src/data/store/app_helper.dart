import '../../models/common/symbols_model.dart';
import 'package:msil_library/streamer/models/id_properties_model.dart';
import 'package:msil_library/streamer/models/stream_details_model.dart';
import 'package:msil_library/streamer/models/streaming_symbol_model.dart';
import 'package:rxdart/rxdart.dart';

class AppHelper {
  Future<dynamic> getStreamDetails(String screenName, dynamic streamsymbols,
      List<String> streamingKeys, Function responseCallback) async {
    // ignore: unnecessary_null_comparison
    if (streamsymbols != null && responseCallback != null) {
      final List<StreamingSymbolModel> symbols = <StreamingSymbolModel>[];
      await streamsymbols.forEach((data) {
        StreamingSymbolModel symbol;
        if (data is BehaviorSubject) {
          symbol = StreamingSymbolModel.fromJson(
            <String, String>{'symbol': data.value.sym.streamSym},
          );
        } else {
          if (data is Symbols) {
            String streamSym = data.sym?.streamSym ?? "";
            symbol = StreamingSymbolModel.fromJson(
              <String, String>{'symbol': streamSym},
            );
          } else {
            symbol = StreamingSymbolModel.fromJson(
              <String, String>{'symbol': data.symbol},
            );
          }
        }

        symbols.add(symbol);
      });

      IdPropertiesModel idProperties =
          IdPropertiesModel(screenName: '', streamingKeys: []);
      if (symbols.isNotEmpty) {
        idProperties = IdPropertiesModel.fromJson(<String, dynamic>{
          'screenName': screenName,
          'streamingKeys': streamingKeys,
          'callBack': responseCallback,
        });
      }
      return StreamDetailsModel.fromJson(
          <String, dynamic>{'idProperties': idProperties, 'symbols': symbols});
    } else {
      return StreamDetailsModel.fromJson(
          <String, dynamic>{'idProperties': '', 'symbols': []});
    }
  }

  Map streamDetails(dynamic streamsymbols, List<String>? streamingKeys) {
    return {
      'streamsymbols': streamsymbols,
      'streamingKeys': streamingKeys,
    };
  }
}
