import 'dart:collection';

import 'cache.dart';

class ACMLCache extends Cache {
  static ACMLCache? _instance;
  factory ACMLCache() => _instance ??= ACMLCache._();
  ACMLCache._();

  final map = HashMap<String, dynamic>();

  @override
  Future<dynamic> get(String id) {
    return Future.value(map[id]);
  }

  @override
  put(String id, object) {
    map[id] = object;
  }

  @override
  clear(String id) {
    map.removeWhere((key, value) => key == id);
  }

  @override
  clearAll() {
    map.clear();
    _instance = null;
  }
}
