// ignore_for_file: unnecessary_null_comparison

import '../../utils/config/infoIDConfig.dart';
import '../../utils/exception/failed_exception.dart';
import '../../utils/exception/invalid_exception.dart';

class BaseModel {
  late Map<String, dynamic> response;

  late Map<String, dynamic> data;

  late String infoID;

  late String infoMsg;

  BaseModel();

  BaseModel.fromJSON(Map<String, dynamic> json) {
    if (json.containsKey('response'))
      response = json['response'] as Map<String, dynamic>;

    if (response.containsKey('data'))
      data = response['data'] as Map<String, dynamic>;

    if (response.containsKey('infoID')) {
      infoID = response['infoID'] as String;
    }

    if (response.containsKey('infoMsg')) {
      infoMsg = response['infoMsg'] as String;
    }

    if (isInvalidSession() || isInvalidAPPID()) {
      //LogConfig().printLog('invalid session base model $infoMsg');
      throw InvalidException(infoID, infoMsg);
    } else if (!isSuccess()) {
      throw FailedException(infoID, infoMsg, data);
    }
  }

  bool hasInfoMsg() {
    return infoMsg != null && infoMsg.isNotEmpty;
  }

  bool isInvalidSession() {
    return infoID.compareTo(InfoIDConfig.invalidSessionCode) == 0;
  }

  bool isInvalidAPPID() {
    return infoID.compareTo(InfoIDConfig.invalidAppIDCode) == 0;
  }

  bool isSuccess() {
    return infoID.compareTo(InfoIDConfig.success) == 0;
  }
}
