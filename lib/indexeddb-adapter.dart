class IndexedDbAdapter<K, V> implements Adapter<K, V> {
  
  String dbName;
  String storeName;
  IDBDatabase _db;
  bool isReady = false;
  String version;
  
  IndexedDbAdapter(String this.dbName, String this.storeName,
    [String this.version = "1"]);
  
  String get adapter() => "indexeddb";
  
  bool get valid() {
    return window.webkitIndexedDB != null;
  }

  _throwNotReady() {
    throw "Database not opened or ready";
  }
  
  Future<bool> open() {
    Completer completer = new Completer();
    IDBRequest request = window.webkitIndexedDB.open(dbName);
    print('requested open');
    request.addEventListener('success', (e) {
      print('success');
      _db = e.target.result;
      _initDb(completer);
    });
    request.addEventListener('error', (e) {
      print('error');
      completer.completeException(e.result);
    });
    request.addEventListener('blocked', (e) {
      print('blocked');
      completer.completeException(e.result);
    });
    return completer.future;
  }
  
  void _initDb(Completer completer) {
    if (version != _db.version) {
      print('upgrading ${_db.version} to $version');
      IDBVersionChangeRequest versionChange = _db.setVersion(version);
      versionChange.addEventListener('success', (e) {
        _db.createObjectStore(storeName);
        isReady = true;
        completer.complete(true);
      });
      versionChange.addEventListener('error', (e) {
        completer.completeException(e);
      });
    } else {
      print('version good to go');
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
    var jsonObj = JSON.stringify(obj);
    
    IDBTransaction txn = _db.transaction(storeName, IDBTransaction.READ_WRITE);
    txn.addEventListener('complete', (e) => completer.complete(key));
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));

    IDBObjectStore objectStore = txn.objectStore(storeName);
    key = key == null ? _uuid() : key;
    IDBRequest addRequest = objectStore.put(jsonObj, key);
    
    return completer.future;
  }
  
  Future<V> getByKey(K key) {
    if (!isReady) _throwNotReady();
    
    Completer<V> completer = new Completer<V>();
    
    IDBTransaction txn = _db.transaction(storeName, IDBTransaction.READ_ONLY);
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));

    IDBObjectStore objectStore = txn.objectStore(storeName);
    IDBRequest getRequest = objectStore.getObject(key);
    getRequest.addEventListener('success', (e) {
      var jsonObj = e.target.result;
      var obj = (jsonObj == null) ? null : JSON.parse(jsonObj);
      completer.complete(obj);
    });
    
    return completer.future;
  }
  
  Future<bool> removeByKey(K key) {
    if (!isReady) _throwNotReady();
    
    Completer<bool> completer = new Completer<bool>();
    
    IDBTransaction txn = _db.transaction(storeName, IDBTransaction.READ_WRITE);
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));

    IDBObjectStore objectStore = txn.objectStore(storeName);
    IDBRequest removeRequest = objectStore.delete(key);
    removeRequest.addEventListener('success', (e) => completer.complete(true));
    
    return completer.future;
  }
  
  Future<bool> nuke() {
    if (!isReady) _throwNotReady();
    
    Completer<bool> completer = new Completer<bool>();
    
    IDBTransaction txn = _db.transaction(storeName, IDBTransaction.READ_WRITE);
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));

    IDBObjectStore objectStore = txn.objectStore(storeName);
    IDBRequest clearRequest = objectStore.clear();
    clearRequest.addEventListener('success', (e) => completer.complete(true));
    
    return completer.future;
  }
  
  Future<Collection<V>> all() {
    if (!isReady) _throwNotReady();
    
    Completer<Collection<V>> completer = new Completer<Collection<V>>();
    var values = <V>[];
    
    IDBTransaction txn = _db.transaction(storeName, IDBTransaction.READ_ONLY);
    txn.addEventListener('complete', (e) => completer.complete(values));
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));

    IDBObjectStore objectStore = txn.objectStore(storeName);
    IDBRequest cursorRequest = objectStore.openCursor();
    cursorRequest.addEventListener("success", (e) {
      var cursor = e.target.result;
      if (cursor != null) {
        values.add(JSON.parse(cursor.value));
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
    
    IDBTransaction txn = _db.transaction(storeName, IDBTransaction.READ_WRITE);
    txn.addEventListener('complete', (e) => completer.complete(newKeys));
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));
    
    IDBObjectStore objectStore = txn.objectStore(storeName);
    for (int i = 0; i < objs.length; i++) {
      V obj = objs[i];
      var jsonObj = JSON.stringify(obj);
      K key = _keys[i];
      key = key == null ? _uuid() : key;
      IDBRequest addRequest = objectStore.put(jsonObj, key);
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
    
    IDBTransaction txn = _db.transaction(storeName, IDBTransaction.READ_ONLY);
    txn.addEventListener('complete', (e) => completer.complete(values));
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));
    
    IDBObjectStore objectStore = txn.objectStore(storeName);
    _keys.forEach((key) {
      IDBRequest getRequest = objectStore.getObject(key);
      getRequest.addEventListener("success", (e) {
        var jsonObj = e.target.result;
        var obj = (jsonObj == null) ? null : JSON.parse(jsonObj);
        values.add(obj);
      });
    });
    
    return completer.future;
  }

  Future<bool> removeByKeys(Collection<K> _keys) {
    if (!isReady) _throwNotReady();
    
    Completer<bool> completer = new Completer<bool>();
    
    IDBTransaction txn = _db.transaction(storeName, IDBTransaction.READ_WRITE);
    txn.addEventListener('complete', (e) => completer.complete(true));
    txn.addEventListener('error', (e) => completer.completeException(e.target.error));
    txn.addEventListener('abort', (e) => completer.completeException("txn aborted"));
    
    IDBObjectStore objectStore = txn.objectStore(storeName);
    _keys.forEach((key) {
      print('removing $key');
      IDBRequest removeRequest = objectStore.delete(key);
      print('removed key');
    });
    
    return completer.future;
  }
  
  /*

  Future<bool> exists(K key);
  Future<Collection<K>> keys()
  
  */
}