import 'dart:convert';

import '../../utils/config/log_config.dart';

class JsonParser {
  Function cb;
  String jsonDataString = '';

  JsonParser(this.cb);
  void setJsonData(List<int> data) {
    final String newJsonDataString = utf8.decode(data);
    jsonDataString = jsonDataString + newJsonDataString;
    process();
  }

  void process() {
    final int alignDataIndex = jsonDataString.lastIndexOf('\n');
    if (alignDataIndex != -1) {
      final String alignData = jsonDataString.substring(0, alignDataIndex);
      jsonDataString = jsonDataString.substring(alignDataIndex + 1);
      final List<String> splitAlignData = alignData.split('\n');
      splitAlignData.forEach((String splitAlignString) async {
        if (splitAlignString != '') {
          try {
            final Map<String, dynamic> jsonsDataDecode =
                await json.decode(splitAlignString);
            cb(jsonsDataDecode);
          } catch (e) {
            LogConfig().printLog('onData Error: $e');
          }
        }
      });
    }
  }

  void resetJsonString() {
    jsonDataString = '';
  }
}
