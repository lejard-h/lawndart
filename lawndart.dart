#library('lawndart');

#import('dart:html');
#import('dart:json');

_uuid() {
  return "RANDOM STRING";
}

_results(obj) {
  var completer = new Completer();
  completer.complete(obj);
  return completer.future;
}

interface Store<K, V> {
  Future<Collection<K>> keys();
  Future<K> save(V obj, [K key]);
  Future<Collection<K>> batch(List<V> objs, [List<K> _keys]);
  Future<V> getByKey(K key);
  Future<Collection<V>> getByKeys(Collection<K> _keys);
  Future<bool> exists(K key);
  Future<Collection<V>> all();
  Future<bool> removeByKey(K key);
  Future<bool> removeByKeys(Collection<K> _keys);
  Future<bool> nuke();
}

interface Adapter<K, V> extends Store<K, V> {
  String get adapter();
  bool get valid();
}

class MemoryAdapter<K extends Hashable, V> implements Adapter<K, V> {
  Map<K, V> storage;
  
  MemoryAdapter() : storage = new Map<K, V>();
  
  String get adapter() => 'memory';
  
  bool get valid() => true;
  
  Future<Collection<K>> keys() {
    return _results(storage.getKeys());
  }
  
  Future<K> save(V obj, [K key]) {
    key = key == null ? _uuid() : key;
    storage[key] = obj;
    return _results(key);
  }
  
  Future<Collection<K>> batch(List<V> objs, [List<K> _keys]) {
    List<K> newKeys = <K>[];
    for (var i = 0; i < objs.length; i++) {
      K key = _keys[i];
      key = key == null ? _uuid() : key;
      newKeys.add(key);
      storage[key] = objs[i];
    }
    return _results(newKeys);
  }
  
  Future<V> getByKey(K key) {
    return _results(storage[key]);
  }
  
  Future<Collection<V>> getByKeys(Collection<K> _keys) {
    var values = _keys.map((key) => storage[key]);
    return _results(values);
  }
  
  Future<bool> exists(K key) {
    return _results(storage.containsKey(key));
  }
  
  Future<Collection<V>> all() {
    return _results(storage.getKeys());
  }
  
  Future<bool> removeByKey(K key) {
    storage.remove(key);
    return _results(true);
  }
  
  Future<bool> removeByKeys(Collection<K> _keys) {
    _keys.forEach((key) => storage.remove(key));
    return _results(true);
  }
  
  Future<bool> nuke() {
    storage.clear();
    return _results(true);
  }
}

class LocalStorageAdapter<K extends String, V> implements Adapter<K, V> {
  static final INDEX_KEY = "__lawndart__keys";
  
  Storage storage;
  
  String get adapter() => 'local-storage';
  
  // Dart targets modern browsers, so this is assumed
  bool get valid() => true;
  
  LocalStorageAdapter() {
    storage = window.localStorage;
  }
  
  Future<Collection<K>> keys() {
    return _results(JSON.parse(storage.getItem(INDEX_KEY)));
  }
  
  Future<K> save(V obj, [K key]) {
    key = key == null ? _uuid() : key;
    storage.setItem(key, JSON.stringify(data));
    return _results(key);
  }
  
  Future<Collection<K>> batch(List<V> objs, [List<K> _keys]) {
    var newKeys = <K>[];
    for (var i = 0; i < objs.length; i++) {
      K key = _keys[i];
      key = key == null ? _uuid() : key;
      storage.setItem(key, JSON.stringify(obj));
    }
    return _result(newKeys);
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
    var values = keys().map((key) => storage.getItem(key));
    return _results(values);
  }
  
  Future<bool> removeByKey(K key) {
    List<K> _keys = keys();
    if (_keys.indexOf(key) > -1) {
      return _results(true);
    } else {
      return _results(false);
    }
  }
  
  Future<bool> removeByKeys(Collection<K> _keys);
  Future<bool> nuke();
}