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

/**
A unified, asynchronous, easy-to-use library for offline-enabled
browser-based web apps. Kinda sorta a port of Lawnchair to Dart,
but with Futures and Streams.

Lawndart uses Futures to provide an asynchronous, yet consistent,
interface to local storage, indexed db, and websql. This library is designed
for simple key-value usage, and is not designed for complex transactional
queries. This library prefers simplicity and uniformity over expressiveness.

You can use this library to help deal with the wide array of client-side
storage options. You should be able to write your code against the Lawndart
interface and have it work across browsers that support at least one of the
following: local storage, indexed db, and websql.

# Example

    var db = new IndexedDbStore('simple-run-through', 'test');
    db.open()
      .then((_) => db.nuke())
      .then((_) => db.save("world", "hello"))
      .then((_) => db.save("is fun", "dart"))
      .then((_) => db.getByKey("hello"))
      .then((value) => query('#text').text = value);

See the `example/` directory for more sample code.

*/
library lawndart;

import 'dart:html';
import 'dart:indexed_db' as idb;
import 'dart:web_sql';
import 'dart:async';

part 'src/indexeddb_store.dart';
part 'src/_map_store.dart';
part 'src/memory_store.dart';
part 'src/local_storage_store.dart';
part 'src/websql_store.dart';

/**
 * Represents a Store that can hold key/value pairs. No order
 * is guaranteed for either keys or values. You must
 * [open] a store before you can use it.
 */
abstract class Store<V> {
  bool _isOpen = false;

  bool get isOpen => _isOpen;

  // For subclasses
  Store._();

  /**
   * Finds the best implementation. In order: IndexedDB, WebSQL, LocalStorage.
   */
  factory Store(String dbName, String storeName, [Map options]) {
    if (IndexedDbStore.supported) {
      return new IndexedDbStore(dbName, storeName);
    } else if (WebSqlStore.supported) {
      if (options != null && options['estimatedSize']) {
        return new WebSqlStore(dbName, storeName, estimatedSize: options['estimatedSize']);
      } else {
        return new WebSqlStore(dbName, storeName);
      }
    } else {
      return new LocalStorageStore();
    }
  }

  _checkOpen() {
    if (!isOpen) throw new StateError('$runtimeType is not open');
  }

  /// Returns a Future that completes when the store is opened.
  /// You must call this method before using
  /// the store.
  Future open();

  /// Returns all the keys as a stream. No order is guaranteed.
  Stream<String> keys() {
    _checkOpen();
    return _keys();
  }
  Stream<String> _keys();

  /// Stores an [obj] accessible by [key].
  /// The returned Future completes with the key when the objects
  /// is saved in the store.
  Future<String> save(V obj, String key) {
    _checkOpen();
    if (key == null) {
      throw new ArgumentError("key must not be null");
    }
    return _save(obj, key);
  }
  Future _save(V obj, String key);

  /// Stores all objects by their keys. This should happen in a single
  /// transaction if the underlying store supports it.
  /// The returned Future completes when all objects have been added
  /// to the store.
  Future batch(Map<String, V> objectsByKey) {
    _checkOpen();
    return _batch(objectsByKey);
  }
  Future _batch(Map<String, V> objectsByKey);

  /// Returns a Future that completes with the value for a key,
  /// or null if the key does not exist.
  Future<V> getByKey(String key) {
    _checkOpen();
    return _getByKey(key);
  }
  Future<V> _getByKey(String key);

  /// Returns a Stream of all values for the keys.
  /// If a particular key is not found,
  /// no value will be returned, not even null.
  Stream<V> getByKeys(Iterable<String> _keys) {
    _checkOpen();
    return _getByKeys(_keys);
  }
  Stream<V> _getByKeys(Iterable<String> _keys);

  /// Returns a Future that completes with true if the key exists, or false.
  Future<bool> exists(String key) {
    _checkOpen();
    return _exists(key);
  }
  Future<bool> _exists(String key);

  /// Returns a Stream of all values in no particular order.
  Stream<V> all() {
    _checkOpen();
    return _all();
  }
  Stream<V> _all();

  /// Returns a Future that completes when the key's value is removed.
  Future removeByKey(String key) {
    _checkOpen();
    return _removeByKey(key);
  }
  Future _removeByKey(key);

  /// Returns a Future that completes when all the keys' values are removed.
  Future removeByKeys(Iterable<String> _keys) {
    _checkOpen();
    return _removeByKeys(_keys);
  }
  Future _removeByKeys(Iterable<String> _keys);

  /// Returns a Future that completes when all values and keys
  /// are removed.
  Future nuke() {
    _checkOpen();
    return _nuke();
  }
  Future _nuke();
}
