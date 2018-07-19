//Copyright 2012 Google
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
class IndexedDbStore extends Store {
  static Map<String, idb.Database> _databases = new Map<String, idb.Database>();

  final String dbName;
  final String storeName;

  IndexedDbStore._(this.dbName, this.storeName) : super._();

  static Future<IndexedDbStore> open(String dbName, String storeName) async {
    var store = new IndexedDbStore._(dbName, storeName);
    await store._open();
    return store;
  }

  /// Returns true if IndexedDB is supported on this platform.
  static bool get supported => idb.IdbFactory.supported;

  Future _open() async {
    if (!supported) {
      throw new UnsupportedError('IndexedDB is not supported on this platform');
    }

    if (_db != null) {
      _db.close();
    }

    var db = await window.indexedDB.open(dbName);

    //print("Newly opened db $dbName has version ${db.version} and stores ${db.objectStoreNames}");
    if (!db.objectStoreNames.contains(storeName)) {
      db.close();
      //print('Attempting upgrading $storeName from ${db.version}');
      db = await window.indexedDB.open(dbName, version: db.version + 1,
          onUpgradeNeeded: (e) {
        //print('Upgrading db $dbName to ${db.version + 1}');
        idb.Database d = e.target.result;
        d.createObjectStore(storeName);
      });
    }

    _databases[dbName] = db;
    return true;
  }

  idb.Database get _db => _databases[dbName];

  @override
  Future removeByKey(String key) {
    return _runInTxn((store) => store.delete(key));
  }

  @override
  Future<String> save(String obj, String key) {
    return _runInTxn<String>(
        (store) async => (await store.put(obj, key)) as String);
  }

  @override
  Future<String> getByKey(String key) {
    return _runInTxn<String>(
        (store) async => (await store.getObject(key) as String), 'readonly');
  }

  @override
  Future nuke() {
    return _runInTxn((store) => store.clear());
  }

  Future<T> _runInTxn<T>(Future<T> requestCommand(idb.ObjectStore store),
      [String txnMode = 'readwrite']) async {
    var trans = _db.transaction(storeName, txnMode);
    var store = trans.objectStore(storeName);
    var result = await requestCommand(store);
    await trans.completed;
    return result;
  }

  Stream<String> _doGetAll(String onCursor(idb.CursorWithValue cursor)) async* {
    var trans = _db.transaction(storeName, 'readonly');
    var store = trans.objectStore(storeName);
    await for (var cursor in store.openCursor(autoAdvance: true)) {
      yield onCursor(cursor);
    }
  }

  @override
  Stream<String> all() {
    return _doGetAll((idb.CursorWithValue cursor) => cursor.value);
  }

  @override
  Future batch(Map<String, String> objs) {
    return _runInTxn((store) {
      objs.forEach((k, v) {
        store.put(v, k);
      });
    });
  }

  @override
  Stream<String> getByKeys(Iterable<String> keys) async* {
    for (var key in keys) {
      var v = await getByKey(key);
      if (v != null) yield v;
    }
  }

  @override
  Future<bool> removeByKeys(Iterable<String> keys) {
    return _runInTxn((store) {
      for (var key in keys) {
        store.delete(key);
      }
    });
  }

  @override
  Future<bool> exists(String key) async {
    var value = await getByKey(key);
    return value != null;
  }

  @override
  Stream<String> keys() {
    return _doGetAll((idb.CursorWithValue cursor) => cursor.key);
  }
}
