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

part of lawndart;

void _onError(Event e) {
  print('An error occurred: ${(e.target as IDBRequest).error.name}');
}

class IndexedDb<K, V> {
  String dbName;
  List<String> storeNames;  
  IDBDatabase _db;
  bool isReady = false;
  int version;
  
  IndexedDb(String this.dbName, List<String> this.storeNames, [int this.version = 1]) {
    if (version == null) {
      throw "version must not be null";
    }
  }
  
  Future<bool> open() {
    Completer completer = new Completer();
    var request = window.indexedDB.open(dbName, version);
    if (request is IDBOpenDBRequest) {
      request.on.success.add((e) {
        _db = request.result;
        isReady = true;
        completer.complete(true);
      });
      request.on.upgradeNeeded.add((e) {
        _db = request.result;
        _createObjectStoresForUpgrade();
      });
    } else {
      request.on.success.add((e) {
        _db = request.result;
        if (_db.version != '$version') {
          var setRequest = _db.setVersion('$version');
          setRequest.on.success.add((e) {
            _createObjectStoresForUpgrade();
            var transaction = e.target.result;
            transaction.on.complete.add((_) {
              isReady = true;
              completer.complete(true);
            });
            transaction.on.error.add(_onError);
          });
          setRequest.on.error.add(_onError);
        } else {
          isReady = true;
          completer.complete(true);
        }
      });
    }
    request.on.error.add(_onError);
    return completer.future;
  }
  
  void _createObjectStoresForUpgrade() {
    for (var storeName in storeNames) {
      if (_db.objectStoreNames.indexOf(storeName) == -1) {  
        _db.createObjectStore(storeName);
      }        
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
  
  Future<bool> removeByKey(K key) {
    return _doCommand((IDBObjectStore store) => store.delete(key), (e) => true);
  }

  Future<bool> open() {
    throw 'Unsupported operation';
  }
  
  Future<K> save(V obj, [K key]) {
    key = key == null ? _uuid() : key;
    return _doCommand((IDBObjectStore store) => store.put(obj,key), (e) => key);
  }
  
  Future<V> getByKey(K key) {
    return _doCommand((IDBObjectStore store) => store.getObject(key), (e) => e.target.result);    
  }
  
  Future<bool> nuke() {    
    Completer<bool> completer = new Completer<bool>();
    var trans = _db.transaction(storeName, 'readwrite');
    var store = trans.objectStore(storeName);    
    var request = store.clear();
    request.on.success.add((e) => completer.complete(true));
    request.on.error.add(_onError);
    return completer.future;    
  }
  
  _doCommand(requestCommand, onComplete) {
    Completer completer = new Completer();
    var trans = _db.transaction(storeName, 'readwrite');
    var store = trans.objectStore(storeName);
    var request = requestCommand(store);
    request.on.success.add((e) => completer.complete(onComplete(e)));
    request.on.error.add(_onError);
    return completer.future;
  }
  
  Future<Collection<V>> all() {
    Completer<Collection<V>> completer = new Completer<Collection<V>>();
    var trans = _db.transaction(storeName, 'readonly');
    var store = trans.objectStore(storeName);
    var values = <V>[];
    // Get everything in the store.
    var request = store.openCursor();
    request.on.success.add((e) {
      var cursor = request.result;
      if (cursor != null && cursor.value != null) {
        values.add(cursor.value);
        cursor.continueFunction();
      } else {
        completer.complete(values);
      }
    });
    request.on.error.add(_onError);
    return completer.future;
  }

  Future<Collection<K>> batch(List<V> objs, [List<K> keys]) {
    if (keys != null && objs.length != keys.length) {
      throw "length of keys must match length of objs";
    }
    List<Future> futures = [];
    Completer<Collection<V>> completer = new Completer<Collection<V>>();
    var newKeys = <K>[];
    
    for (int i = 0; i < objs.length; i++) {
      V obj = objs[i];      
      K key = keys[i];
      key = key == null ? _uuid() : key;
      futures.add(save(obj,key));      
    }
    return Futures.wait(futures);
  }

  Future<Collection<V>> getByKeys(Collection<K> keys) {
    Futures.wait(keys.map((key) => getByKey(key)));
  }

  Future<bool> removeByKeys(Collection<K> keys) {
    Completer completer = new Completer();
    Futures.wait(keys.map((key) => removeByKey(key))).then((_) {
      completer.complete(true);
    });  
    return completer.future;
  }

  Future<bool> exists(K key) {
    Completer<bool> completer = new Completer<bool>();
    getByKey(key).then((value) => completer.complete(value != null));
    return completer.future;
  }

  Future<Collection<K>> keys() {
    throw 'Not supported operation';
  }
}