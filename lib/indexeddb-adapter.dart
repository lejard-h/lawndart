//Copyright 2012 Seth Ladd
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

class IndexedDb<K, V> {
  String dbName;
  List<String> storeNames;
  String version;
  IDBDatabase _db;
  bool isReady = false;
  
  IndexedDb(String this.dbName, List<String> this.storeNames, String this.version);
  
  Future<bool> open() {
    Completer completer = new Completer();
    IDBRequest request = window.webkitIndexedDB.open(dbName);
    print('requested open for $dbName');
    request.on.success.add((e) {
      print('success');
      _db = e.target.result;
      _initDb(completer);
    });
    request.on.error.add((e) {
      print('error');
      completer.completeException(e.result);
    });
    return completer.future;
  }
  
  void _initDb(Completer completer) {
    if (version != _db.version) {
      print('upgrading ${_db.version} to $version for $dbName');
      IDBVersionChangeRequest versionChange = _db.setVersion(version);
      versionChange.on.success.add((e) {
        storeNames.forEach((storeName) {
          if (_db.objectStoreNames.indexOf(storeName) == -1) {
            print('creating $storeName');
            _db.createObjectStore(storeName);
          }
        });
        isReady = true;
        completer.complete(true);
      });
      versionChange.on.error.add((e) {
        completer.completeException(e);
      });
    } else {
      print('version good to go for $dbName');
      isReady = true;
      completer.complete(true);
    }
  }
  
  Store<K, V> store(String storeName) {
    if (!isReady) {
      throw "Database not opened or ready";
    }
    if (storeNames.indexOf(storeName) == -1) {
      throw "Store name $storeName is unknown to database $dbName";
    }
    return new _IndexedDbAdapter<K, V>(_db, storeName);
  }
}

class _IndexedDbAdapter<K, V> implements Store<K, V> {
  
  IDBDatabase _db;
  String storeName;
  
  _IndexedDbAdapter(IDBDatabase this._db, String this.storeName);
  
  IDBTransaction _createTxn(String type, Completer completer, onComplete(e)) {
//    int mode = (type == "readwrite") ? IDBTransaction.READ_WRITE : IDBTransaction.READ_ONLY;
    print("opening $type txn for store $storeName");
    IDBTransaction txn = _db.transaction(storeName, type);
    txn.on.complete.add((e) {
      print('txn completed');
      completer.complete(onComplete(e));
    });
    txn.on.error.add((e) {
      print('I here in OnError');
      print("txn error: $e");
      completer.completeException(e.target/*.error*/);
    });
    txn.on.abort.add((e) {
      print("txn aborted: $e");
      completer.completeException("txn aborted");
    });
    return txn;
  }
  
  Future<K> save(V obj, [K key]) {
    Completer<K> completer = new Completer<K>();
    var jsonObj = JSON.stringify(obj);
    
    IDBTransaction txn = _createTxn("readwrite", completer, (e) => key);
    IDBObjectStore objectStore = txn.objectStore(storeName);
    key = key == null ? _uuid() : key;
    print("Saving $jsonObj with key $key");
    objectStore.put(jsonObj, key);
    
    return completer.future;
  }
  
  Future<V> getByKey(K key) {
    Completer<V> completer = new Completer<V>();
    var obj;
    
    IDBTransaction txn = _createTxn("readonly", completer, (e) => obj);

    IDBObjectStore objectStore = txn.objectStore(storeName);
    IDBRequest request = objectStore.getObject(key);
    request.on.success.add((e) {
      var jsonObj = e.target.result;
      obj = (jsonObj == null) ? null : JSON.parse(jsonObj);
    });
    
    return completer.future;
  }
  
  Future<bool> removeByKey(K key) {
    Completer<bool> completer = new Completer<bool>();
    
    IDBTransaction txn = _createTxn("readwrite", completer, (e) => true);
    IDBObjectStore objectStore = txn.objectStore(storeName);
    objectStore.delete(key);
    
    return completer.future;
  }
  
  Future<bool> nuke() {
    Completer<bool> completer = new Completer<bool>();
    
    IDBTransaction txn = _createTxn("readwrite", completer, (e) => true);
    IDBObjectStore objectStore = txn.objectStore(storeName);
    objectStore.clear();
    
    return completer.future;
  }
  
  Future<Collection<V>> all() {
    Completer<Collection<V>> completer = new Completer<Collection<V>>();
    var values = <V>[];
    
    IDBTransaction txn = _createTxn("readonly", completer, (e) => values);

    IDBObjectStore objectStore = txn.objectStore(storeName);
    IDBRequest cursorRequest = objectStore.openCursor();
    cursorRequest.on.success.add((e) {
      var cursor = e.target.result;
      if (cursor != null) {
        values.add(JSON.parse(cursor.value));
        cursor.continueFunction();
      }
    });
    
    return completer.future;
  }
  
  Future<Collection<K>> batch(List<V> objs, [List<K> keys]) {
    if (keys != null && objs.length != keys.length) {
      throw "length of keys must match length of objs";
    }
    
    Completer<Collection<V>> completer = new Completer<Collection<V>>();
    var newKeys = <K>[];
    
    IDBTransaction txn = _createTxn("readwrite", completer, (e) => newKeys);
    
    IDBObjectStore objectStore = txn.objectStore(storeName);
    for (int i = 0; i < objs.length; i++) {
      V obj = objs[i];
      var jsonObj = JSON.stringify(obj);
      K key = keys[i];
      key = key == null ? _uuid() : key;
      IDBRequest addRequest = objectStore.put(jsonObj, key);
      addRequest.on.success.add((e) => newKeys.add(key));
    }
    
    return completer.future;
  }

  Future<Collection<V>> getByKeys(Collection<K> _keys) {
    Completer<Collection<V>> completer = new Completer<Collection<V>>();
    var values = <V>[];
    
    IDBTransaction txn = _createTxn("readonly", completer, (e) => values);
    
    IDBObjectStore objectStore = txn.objectStore(storeName);
    _keys.forEach((key) {
      IDBRequest getRequest = objectStore.getObject(key);
      getRequest.on.success.add((e) {
        var jsonObj = e.target.result;
        var obj = (jsonObj == null) ? null : JSON.parse(jsonObj);
        values.add(obj);
      });
    });
    
    return completer.future;
  }

  Future<bool> removeByKeys(Collection<K> _keys) {
    Completer<bool> completer = new Completer<bool>();
    
    IDBTransaction txn = _createTxn("readwrite", completer, (e) => true);
    
    IDBObjectStore objectStore = txn.objectStore(storeName);
    _keys.forEach((key) {
      objectStore.delete(key);
    });
    
    return completer.future;
  }

  Future<bool> exists(K key) {
    Completer<bool> completer = new Completer<bool>();
    getByKey(key).then((value) => completer.complete(value != null));
    return completer.future;
  }

  Future<Collection<K>> keys() {
    Completer completer = new Completer();
    List<K> _keys = new List<K>();
    
    IDBTransaction txn = _createTxn("readonly", completer, (e) => _keys);
    
    IDBObjectStore objectStore = txn.objectStore(storeName);
    IDBRequest allObjects = objectStore.openCursor();
    allObjects.on.success.add((e) {
      IDBCursor cursor = e.target.result;
      if (cursor != null) {
        _keys.add(cursor.key);
        cursor.continueFunction();
      }
    });
    
    return completer.future;
  }

}