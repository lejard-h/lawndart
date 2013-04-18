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

/**
 * Wraps the IndexedDB API and exposes it as a [Store].
 * IndexedDB is generally the preferred API if it is available.
 */
class IndexedDbStore<V> extends Store<V> {

  String dbName;
  int version;
  idb.Database _db;
  String storeName;

  IndexedDbStore(this.dbName, this.storeName, {this.version: 1}) {
    if (version == null) {
      throw new ArgumentError("version must not be null");
    }
  }

  /// Returns true if IndexedDB is supported on this platform.
  static bool get supported => idb.IdbFactory.supported;

  Future open() {
    if (!supported) {
      return new Future.error(
        new UnsupportedError('IndexedDB is not supported on this platform'));
    }
    return window.indexedDB.open(dbName, version: version,
        onUpgradeNeeded: (e) {
          _db = e.target.result;
          if (!_db.objectStoreNames.contains(storeName)) {
            _db.createObjectStore(storeName);
          }
        })
        .then((db) {
          _db = db;
          _isOpen = true;
          return true;
        });
  }

  @override
  Future _removeByKey(String  key) {
    return _doCommand((idb.ObjectStore store) => store.delete(key));
  }

  @override
  Future _save(V obj, String key) {
    return _doCommand((idb.ObjectStore store) {
      return store.put(obj, key);
    });
  }

  @override
  Future<V> _getByKey(String key) {
    return _doCommand((idb.ObjectStore store) => store.getObject(key),
        'readonly');
  }

  @override
  Future _nuke() {
    return _doCommand((idb.ObjectStore store) => store.clear());
  }

  Future _doCommand(Future requestCommand(idb.ObjectStore store),
             [String txnMode = 'readwrite']) {
    var completer = new Completer();
    var trans = _db.transaction(storeName, txnMode);
    var store = trans.objectStore(storeName);
    var future = requestCommand(store);
    return trans.completed.then((_) => future);
  }

  Stream _doGetAll(dynamic onCursor(idb.CursorWithValue cursor)) {
    var controller = new StreamController<V>();
    var trans = _db.transaction(storeName, 'readonly');
    var store = trans.objectStore(storeName);
    // Get everything in the store.
    store.openCursor(autoAdvance: true).listen(
        (cursor) => controller.add(onCursor(cursor)),
        onDone: () => controller.close(),
        onError: (e) => controller.addError(e));
    return controller.stream;
  }

  @override
  Stream<V> _all() {
    return _doGetAll((idb.CursorWithValue cursor) => cursor.value);
  }

  @override
  Future _batch(Map<String, V> objs) {
    var futures = <Future>[];

    for (var key in objs.keys) {
      var obj = objs[key];
      futures.add(save(obj, key));
    }

    return Future.wait(futures);
  }

  @override
  Stream<V> _getByKeys(Iterable<String> keys) {
    var controller = new StreamController<V>();
    Future.forEach(keys, (key) {
      return getByKey(key).then((value) {
        if (value != null) {
          controller.add(value);
        }
      });
    })
    .then((_) => controller.close())
    .catchError((e) => controller.addError(e));
    return controller.stream;
  }

  @override
  Future<bool> _removeByKeys(Iterable<String> keys) {
    var completer = new Completer();
    Future.wait(keys.map((key) => removeByKey(key))).then((_) {
      completer.complete(true);
    });
    return completer.future;
  }

  @override
  Future<bool> _exists(String key) {
    return getByKey(key).then((value) => value != null);
  }

  @override
  Stream<String> _keys() {
    return _doGetAll((idb.CursorWithValue cursor) => cursor.key);
  }
}