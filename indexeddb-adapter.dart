class IndexedDbAdapter<K, V> implements Adapter<K, V> {
  
  static final String VERSION = "1";
  
  String dbName;
  String storeName;
  dom.IDBDatabase _db;
  bool isReady = false;
  
  IndexedDbAdapter([Map options]) {
    this.dbName = options['dbName'];
    this.storeName = options['storeName'];
  }
  
  String get adapter() => "indexeddb";
  
  bool get valid() {
    return dom.window.webkitIndexedDB != null;
  }

  _throwNotReady() {
    throw "Database not opened or ready";
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
    if (!isReady) _throwNotReady();
    
    Completer<K> completer = new Completer<K>();
    
    dom.IDBTransaction txn = _db.transaction(storeName, dom.IDBTransaction.READ_WRITE);
    txn.addEventListener('complete', (e) => completer.complete(key));
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));

    dom.IDBObjectStore objectStore = txn.objectStore(storeName);
    key = key == null ? _uuid() : key;
    dom.IDBRequest addRequest = objectStore.put(obj, key);
    
    return completer.future;
  }
  
  Future<V> getByKey(K key) {
    if (!isReady) _throwNotReady();
    
    Completer<V> completer = new Completer<V>();
    
    dom.IDBTransaction txn = _db.transaction(storeName, dom.IDBTransaction.READ_ONLY);
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));

    dom.IDBObjectStore objectStore = txn.objectStore(storeName);
    dom.IDBRequest getRequest = objectStore.getObject(key);
    getRequest.addEventListener('success', (e) => completer.complete(e.target.result));
    
    return completer.future;
  }
  
  Future<bool> removeByKey(K key) {
    if (!isReady) _throwNotReady();
    
    Completer<bool> completer = new Completer<bool>();
    
    dom.IDBTransaction txn = _db.transaction(storeName, dom.IDBTransaction.READ_WRITE);
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));

    dom.IDBObjectStore objectStore = txn.objectStore(storeName);
    dom.IDBRequest removeRequest = objectStore.delete(key);
    removeRequest.addEventListener('success', (e) => completer.complete(true));
    
    return completer.future;
  }
  
  Future<bool> nuke() {
    if (!isReady) _throwNotReady();

    print('nuke called');
    
    Completer<bool> completer = new Completer<bool>();
    
    dom.IDBTransaction txn = _db.transaction(storeName, dom.IDBTransaction.READ_WRITE);
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));

    dom.IDBObjectStore objectStore = txn.objectStore(storeName);
    dom.IDBRequest clearRequest = objectStore.clear();
    clearRequest.addEventListener('success', (e) => completer.complete(true));
    
    return completer.future;
  }
  
  Future<Collection<V>> all() {
    if (!isReady) _throwNotReady();
    
    Completer<Collection<V>> completer = new Completer<Collection<V>>();
    var values = <V>[];
    
    dom.IDBTransaction txn = _db.transaction(storeName, dom.IDBTransaction.READ_ONLY);
    txn.addEventListener('complete', (e) => completer.complete(values));
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));

    dom.IDBObjectStore objectStore = txn.objectStore(storeName);
    dom.IDBRequest cursorRequest = objectStore.openCursor();
    cursorRequest.addEventListener("success", (e) {
      var cursor = e.target.result;
      if (cursor != null) {
        values.add(cursor.value);
        cursor.continueFunction();
      }
    });
    
    return completer.future;
  }
  
  Future<Collection<K>> batch(List<V> objs, [List<K> _keys]) {
    if (!isReady) _throwNotReady();
    if (_keys != null && objs.length != _keys.length) {
      throw "length of _keys must match length of objs";
    }
    
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
    }
    
    return completer.future;
  }

  Future<Collection<V>> getByKeys(Collection<K> _keys) {
    if (!isReady) _throwNotReady();

    Completer<Collection<V>> completer = new Completer<Collection<V>>();
    var values = <V>[];
    
    dom.IDBTransaction txn = _db.transaction(storeName, dom.IDBTransaction.READ_ONLY);
    txn.addEventListener('complete', (e) => completer.complete(values));
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));
    
    dom.IDBObjectStore objectStore = txn.objectStore(storeName);
    _keys.forEach((key) {
      dom.IDBRequest getRequest = objectStore.getObject(key);
      getRequest.addEventListener("success", (e) {
        values.add(e.target.result);
      });
    });
    
    return completer.future;
  }

  Future<bool> removeByKeys(Collection<K> _keys) {
    if (!isReady) _throwNotReady();
    
    Completer<bool> completer = new Completer<bool>();
    
    dom.IDBTransaction txn = _db.transaction(storeName, dom.IDBTransaction.READ_WRITE);
    txn.addEventListener('complete', (e) => completer.complete(true));
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));
    
    dom.IDBObjectStore objectStore = txn.objectStore(storeName);
    _keys.forEach((key) {
      print('removing $key');
      dom.IDBRequest removeRequest = objectStore.delete(key);
      print('removed key');
    });
    
    return completer.future;
  }
  
  /*

  Future<bool> exists(K key);
  Future<Collection<K>> keys()
  
  */
}