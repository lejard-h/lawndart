// TODO: error handling
class LocalStorageAdapter<K extends String, V> implements Adapter<K, V> {
  static final INDEX_KEY = "__lawndart__keys";
  
  Storage storage;
  
  String get adapter() {
    return 'local-storage';
  }
  
  bool get valid() {
    return true;
  }
  
  LocalStorageAdapter([Map options]) {
    storage = window.localStorage;
  }
  
  List<K> get _allKeys() => JSON.parse(storage.getItem(INDEX_KEY));

  Future<bool> open() {
    return new Future.immediate(true);
  }
  
  Future<Collection<K>> keys() {
    return _results(_allKeys);
  }
  
  Future<K> save(V obj, [K key]) {
    key = key == null ? _uuid() : key;
    storage.setItem(key, JSON.stringify(obj));
    return _results(key);
  }
  
  Future<Collection<K>> batch(List<V> objs, [List<K> _keys]) {
    var newKeys = <K>[];
    for (var i = 0; i < objs.length; i++) {
      K key = _keys[i];
      key = key == null ? _uuid() : key;
      storage.setItem(key, JSON.stringify(objs[i]));
    }
    return _results(newKeys);
  }
  
  Future<V> getByKey(K key) {
    return _results(storage.getItem(key));
  }
  
  Future<Collection<V>> getByKeys(Collection<K> _keys) {
    var values = _keys.map((key) => storage.getItem(key));
    return _results(values);
  }
  
  Future<bool> exists(K key) {
    return _results(storage.getItem(key) != null);
  }
  
  Future<Collection<V>> all() {
    var values = _allKeys.map((key) => storage.getItem(key));
    return _results(values);
  }
  
  Future<bool> removeByKey(K key) {
    List<K> _keys = _allKeys;
    _keys.removeRange(_keys.indexOf(key), 1);
    storage.removeItem(key);
    storage.setItem(INDEX_KEY, JSON.stringify(_keys));
    return _results(true);
  }
  
  Future<bool> removeByKeys(Collection<K> _keys) {
    _keys.forEach((key) => removeByKey(key));
    return _results(true);
  }
  
  Future<bool> nuke() {
    storage.removeItem(INDEX_KEY);
    storage.clear();
    return _results(true);
  }
}