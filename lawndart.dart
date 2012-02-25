#library('lawndart');

#import('dart:html');
#import('dart:dom', prefix:'dom');
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
  // TODO: what are the semantics of bool here?
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

// TODO: error handling
class LocalStorageAdapter<K extends String, V> implements Adapter<K, V> {
  static final INDEX_KEY = "__lawndart__keys";
  
  Storage storage;
  
  String get adapter() => 'local-storage';
  
  // Dart targets modern browsers, so this is assumed
  bool get valid() => true;
  
  LocalStorageAdapter() {
    storage = window.localStorage;
  }
  
  List<K> get _allKeys() => JSON.parse(storage.getItem(INDEX_KEY));
  
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

class IndexedDbAdapter<K, V> implements Adapter<K, V> {
  
  static final String VERSION = "1";
  
  String dbName;
  String storeName;
  dom.IDBDatabase _db;
  bool isReady = false;
  
  IndexedDbAdapter(this.dbName, this.storeName);
  
  String get adapter() => "indexeddb";
  
  bool get valid() {
    return dom.window.webkitIndexedDB != null;
  }
  
  Future<bool> open() {
    Completer completer = new Completer();
    dom.IDBRequest request = dom.window.webkitIndexedDB.open(dbName);
    print('requested open');
    request.addEventListener('success', (e) {
      print('success');
      _db = e.target.result;
      _initDb(completer);
    });
    request.addEventListener('error', (e) {
      print('error');
      completer.completeException(e.target.error);
    });
    return completer.future;
  }
  
  void _initDb(Completer completer) {
    if (VERSION != _db.version) {
      dom.IDBVersionChangeRequest versionChange = _db.setVersion(VERSION);
      versionChange.addEventListener('success', (e) {
        _db.createObjectStore(storeName);
        isReady = true;
        completer.complete(true);
      });
      versionChange.addEventListener('error', (e) {
        completer.completeException(e);
      });
    } else {
      isReady = true;
      completer.complete(true);
    }
  }
  
  /*
  Future<Collection<K>> keys();
  */
  
  Future<K> save(V obj, [K key]) {
    if (!isReady) throw "Database not opened";
    
    Completer<K> completer = new Completer<K>();
    
    dom.IDBTransaction txn = _db.transaction(storeName, dom.IDBTransaction.READ_WRITE);
    dom.IDBObjectStore objectStore = txn.objectStore(storeName);
    key = key == null ? _uuid() : key;
    dom.IDBRequest addRequest = objectStore.put(obj, key);
    addRequest.addEventListener("success", (e) {
      completer.complete(key);
    });
    addRequest.addEventListener("error", (e) => completer.completeException(e.target.error));
    
    return completer.future;
  }
  
  Future<V> getByKey(K key) {
    if (!isReady) throw "Database not opened";
    
    Completer<V> completer = new Completer<V>();
    
    dom.IDBTransaction txn = _db.transaction(storeName, dom.IDBTransaction.READ_ONLY);
    dom.IDBObjectStore objectStore = txn.objectStore(storeName);
    dom.IDBRequest getRequest = objectStore.getObject(key);
    getRequest.addEventListener("success", (e) {
      completer.complete(e.target.result);
    });
    getRequest.addEventListener("error", (e) => completer.completeException(e.target.error));
    
    return completer.future;
  }
  
  Future<bool> removeByKey(K key) {
    if (!isReady) throw "Database not opened";
    
    Completer<bool> completer = new Completer<bool>();
    
    dom.IDBTransaction txn = _db.transaction(storeName, dom.IDBTransaction.READ_WRITE);
    dom.IDBObjectStore objectStore = txn.objectStore(storeName);
    dom.IDBRequest getRequest = objectStore.delete(key);
    getRequest.addEventListener("success", (e) {
      completer.complete(true);
    });
    getRequest.addEventListener("error", (e) => completer.completeException(e.target.error));
    
    return completer.future;
  }
  
  Future<bool> nuke() {
    if (!isReady) throw "Database not opened";
    
    Completer<bool> completer = new Completer<bool>();
    
    dom.IDBTransaction txn = _db.transaction(storeName, dom.IDBTransaction.READ_WRITE);
    dom.IDBObjectStore objectStore = txn.objectStore(storeName);
    dom.IDBRequest getRequest = objectStore.clear();
    getRequest.addEventListener("success", (e) {
      completer.complete(true);
    });
    getRequest.addEventListener("error", (e) => completer.completeException(e.target.error));
    
    return completer.future;
  }
  
  Future<Collection<V>> all() {
    if (!isReady) throw "Database not opened";
    
    Completer<Collection<V>> completer = new Completer<Collection<V>>();
    var values = <V>[];
    
    dom.IDBTransaction txn = _db.transaction(storeName, dom.IDBTransaction.READ_ONLY);
    dom.IDBObjectStore objectStore = txn.objectStore(storeName);
    dom.IDBRequest cursorRequest = objectStore.openCursor();
    cursorRequest.addEventListener("success", (e) {
      var cursor = e.target.result;
      if (cursor != null) {
        values.add(cursor.value);
        cursor.continueFunction();
      } else {
        completer.complete(values);
      }
    });
    cursorRequest.addEventListener('error', (e) => completer.completeException(e.target.error));
    
    return completer.future;
  }
  
  Future<Collection<K>> batch(List<V> objs, [List<K> _keys]) {
    if (!isReady) throw "Database not opened";
    
    Completer<Collection<V>> completer = new Completer<Collection<V>>();
    var newKeys = <K>[];
    
    dom.IDBTransaction txn = _db.transaction(storeName, dom.IDBTransaction.READ_WRITE);
    txn.addEventListener('complete', (e) => completer.complete(newKeys));
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));
    
    dom.IDBObjectStore objectStore = txn.objectStore(storeName);
    for (int i = 0; i < objs.length; i++) {
      V obj = objs[i];
      K key = _keys[i];
      key = key == null ? _uuid() : key;
      dom.IDBRequest addRequest = objectStore.put(obj, key);
      addRequest.addEventListener("success", (e) {
        newKeys.add(key);
      });
      addRequest.addEventListener("error", (e) => completer.completeException(e.target.error));
    }
    
    return completer.future;
  }
  
  /*

  Future<Collection<V>> getByKeys(Collection<K> _keys);
  Future<bool> exists(K key);
  
  // TODO: what are the semantics of bool here?
  Future<bool> removeByKeys(Collection<K> _keys);
  
  */
}