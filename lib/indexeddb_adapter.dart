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

class IndexedDb<K, V> {
  String dbName;
  List<String> storeNames;  
  idb.Database _db;
  bool isReady = false;
  int version;
  
  IndexedDb(String this.dbName, List<String> this.storeNames, [int this.version = 1]) {
    if (version == null) {
      throw new ArgumentError("version must not be null");
    }
  }
  
  Future<bool> open() {
    var completer = new Completer();
    var request = window.indexedDB.open(dbName, version);
    request.on.success.add((e) {
      _db = request.result;
      isReady = true;
      completer.complete(true);
    });
    request.on.upgradeNeeded.add((e) {
      _db = request.result;
      _createObjectStoresForUpgrade();
    });
    request.on.error.add((e) => completer.completeError(e));
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
      throw new StateError("Database not opened or ready");
    }
    if (storeNames.indexOf(storeName) == -1) {
      throw "Store name $storeName is unknown to database $dbName";
    }
    return new _IndexedDbAdapter<K, V>(_db, storeName);
  }
}

class _IndexedDbAdapter<K, V> implements Store<K, V> {
  
  idb.Database _db;
  String storeName;
  
  _IndexedDbAdapter(idb.Database this._db, String this.storeName);
  
  Future<bool> removeByKey(K key) {
    return _doCommand((idb.ObjectStore store) => store.delete(key), (e) => true);
  }

  Future<bool> open() {
    return _results(true);
  }
  
  Future<K> save(V obj, K key) {
    if (key == null) {
      throw new ArgumentError("key must not be null");
    }
    return _doCommand((idb.ObjectStore store) => store.put(obj, key), (e) => key);
  }
  
  Future<V> getByKey(K key) {
    return _doCommand((idb.ObjectStore store) => store.getObject(key), (e) => e.target.result);    
  }
  
  Future<bool> nuke() {    
    var completer = new Completer<bool>();
    var trans = _db.transaction(storeName, 'readwrite');
    var store = trans.objectStore(storeName);    
    var request = store.clear();
    request.on.success.add((e) => completer.complete(true));
    request.on.error.add((e) => completer.completeError(e));
    return completer.future;    
  }
  
  _doCommand(requestCommand, onComplete) {
    var completer = new Completer();
    var trans = _db.transaction(storeName, 'readwrite');
    var store = trans.objectStore(storeName);
    var request = requestCommand(store);
    request.on.success.add((e) => completer.complete(onComplete(e)));
    request.on.error.add((e) => completer.completeError(e));
    return completer.future;
  }
  
  Future<Iterable<V>> all() {
    var completer = new Completer<Collection<V>>();
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
    request.on.error.add((e) => completer.completeError(e));
    return completer.future;
  }

  Future batch(Map<K, V> objs) {
    var futures = <Future>[];
    var completer = new Completer<Collection<V>>();
    
    for (var key in objs.keys) {
      var obj = objs[key];
      futures.add(save(obj, key));
    }
    
    return Future.wait(futures);
  }

  Future<Iterable<V>> getByKeys(Iterable<K> keys) {
    return Future.wait(keys.mappedBy((key) => getByKey(key)));
  }

  Future<bool> removeByKeys(Iterable<K> keys) {
    var completer = new Completer();
    Future.wait(keys.mappedBy((key) => removeByKey(key))).then((_) {
      completer.complete(true);
    });  
    return completer.future;
  }

  Future<bool> exists(K key) {
    Completer<bool> completer = new Completer<bool>();
    getByKey(key).then((value) => completer.complete(value != null));
    return completer.future;
  }

  Future<Iterable<K>> keys() {
    throw new UnsupportedError("keys is not supprted");
  }
}