import '../../utils/lib_store.dart';

class BaseRequest {
  late Map<String, dynamic> _entireReq;

  late Map<String, dynamic> _request;

  late Map<String, dynamic> _data;

  BaseRequest({Map<String, dynamic>? data}) {
    _entireReq = Map<String, dynamic>();
    _request = Map<String, dynamic>();

    _data = Map<String, dynamic>();

    _entireReq['request'] = _request;
    _request['data'] = data ?? _data;

    appID = LibStore().getAppID();
  }

  set appID(String? appID) {
    _request['appID'] = appID;
  }

  void addToData(String key, dynamic value) {
    _data[key] = value;
  }

  Map<String, dynamic> getData() {
    return _data;
  }

  Map<String, dynamic> getRequest() {
    return _entireReq;
  }
}
