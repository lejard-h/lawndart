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
  
  Future open() {
    var completer = new Completer();
    var request = window.indexedDB.open(dbName, version);
    request.onSuccess.listen((e) {
      _db = request.result;
      isReady = true;
      completer.complete(true);
    });
    request.onUpgradeNeeded.listen((e) {
      _db = request.result;
      _createObjectStoresForUpgrade();
    });
    request.onError.listen((e) => completer.completeError(e));
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

class _IndexedDbAdapter<K, V> extends Store<K, V> {
  
  idb.Database _db;
  String storeName;
  
  _IndexedDbAdapter(idb.Database this._db, String this.storeName);

  Future open() {
    _isOpen = true;
    return _results(true);
  }
  
  @override
  Future _removeByKey(K key) {
    return _doCommand((idb.ObjectStore store) => store.delete(key), (e) => true);
  }
  
  @override
  Future<K> _save(V obj, K key) {
    return _doCommand((idb.ObjectStore store) => store.put(obj, key),
        (e) => true);
  }
  
  @override
  Future<V> _getByKey(K key) {
    return _doCommand((idb.ObjectStore store) => store.getObject(key),
        (e) => e.target.result, 'readonly');
  }
  
  @override
  Future _nuke() {
    return _doCommand((idb.ObjectStore store) => store.clear(), (e) => true);
  }
  
  _doCommand(requestCommand(idb.ObjectStore store), onComplete(e),
             [String txnMode = 'readwrite']) {
    var completer = new Completer();
    var trans = _db.transaction(storeName, txnMode);
    var store = trans.objectStore(storeName);
    var request = requestCommand(store);
    request.onSuccess.listen((e) => completer.complete(onComplete(e)));
    request.onError.listen((e) => completer.completeError(e));
    return completer.future;
  }
  
  _doGetAll(dynamic onCursor(idb.CursorWithValue cursor)) {
    var completer = new Completer<Collection<V>>();
    var trans = _db.transaction(storeName, 'readonly');
    var store = trans.objectStore(storeName);
    var values = new Queue<V>();
    // Get everything in the store.
    var request = store.openCursor();
    request.onSuccess.listen((e) {
      var cursor = request.result;
      if (cursor != null && cursor.value != null) {
        values.add(onCursor(cursor));
        cursor.continueFunction();
      } else {
        completer.complete(values);
      }
    });
    request.onError.listen((e) => completer.completeError(e));
    return completer.future;
  }
  
  @override
  Future<Iterable<V>> _all() {
    return _doGetAll((idb.CursorWithValue cursor) => cursor.value);
  }

  @override
  Future _batch(Map<K, V> objs) {
    var futures = <Future>[];
    var completer = new Completer<Collection<V>>();
    
    for (var key in objs.keys) {
      var obj = objs[key];
      futures.add(save(obj, key));
    }
    
    return Future.wait(futures);
  }

  @override
  Future<Iterable<V>> _getByKeys(Iterable<K> keys) {
    return Future.wait(keys.mappedBy((key) => getByKey(key)))
        .then((values) => new Future.immediate(values.where((v) => v != null)));
  }

  @override
  Future<bool> _removeByKeys(Iterable<K> keys) {
    var completer = new Completer();
    Future.wait(keys.mappedBy((key) => removeByKey(key))).then((_) {
      completer.complete(true);
    });  
    return completer.future;
  }

  @override
  Future<bool> _exists(K key) {
    var completer = new Completer<bool>();
    getByKey(key).then((value) => completer.complete(value != null));
    return completer.future;
  }

  @override
  Future<Iterable<K>> _keys() {
    return _doGetAll((idb.CursorWithValue cursor) => cursor.key);
  }
}