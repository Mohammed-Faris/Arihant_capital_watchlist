abstract class Cache {
  Future<dynamic> get(String id);
  put(String id, dynamic object);
  clear(String id);
  clearAll();
}
