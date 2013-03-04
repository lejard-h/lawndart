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

library lawndart;

import 'dart:html';
import 'dart:indexed_db' as idb;
import 'dart:web_sql';
import 'dart:json' as JSON;
import 'dart:async';
import 'package:meta/meta.dart';
import 'dart:collection';

part 'src/indexeddb_adapter.dart';
part 'src/_map_adapter.dart';
part 'src/memory_adapter.dart';
part 'src/local_storage_adapter.dart';
part 'src/websql_adapter.dart';

abstract class Store<V> {
  bool _isOpen = false;
  
  bool get isOpen => _isOpen;
  
  _checkOpen() {
    if (!isOpen) throw new StateError('$runtimeType is not open');
  }
  
  Future open();
  
  /// Returns all the keys.
  Stream<String> keys() {
    _checkOpen();
    return _keys();
  }
  Stream<String> _keys();
  
  /// Stores an [obj] accessible by [key].
  Future save(V obj, String key) {
    _checkOpen();
    if (key == null) {
      throw new ArgumentError("key must not be null");
    }
    return _save(obj, key);
  }
  Future _save(V obj, String key);
  
  /// Stores all objects by their keys. This should happen in a single
  /// transaction if the underlying store supports it.
  Future batch(Map<String, V> objectsByKey) {
    _checkOpen();
    return _batch(objectsByKey);
  }
  Future _batch(Map<String, V> objectsByKey);
  
  /// Returns a value for a key, or null if the key does not exist.
  Future<V> getByKey(String key) {
    _checkOpen();
    return _getByKey(key);
  }
  Future<V> _getByKey(String key);
  
  /// Returns all values for the keys. If a particular key is not found,
  /// no value will be returned, not even null.
  Stream<V> getByKeys(Iterable<String> _keys) {
    _checkOpen();
    return _getByKeys(_keys);
  }
  Stream<V> _getByKeys(Iterable<String> _keys);
  
  /// Returns true if the key exists, or false.
  Future<bool> exists(String key) {
    _checkOpen();
    return _exists(key);
  }
  Future<bool> _exists(String key);
  
  /// Returns all values.
  Stream<V> all() {
    _checkOpen();
    return _all();
  }
  Stream<V> _all();
  
  /// Removes a value from storage, given a key. The value
  /// returned by the Future is undefined.
  Future removeByKey(String key) {
    _checkOpen();
    return _removeByKey(key);
  }
  Future _removeByKey(key);
  
  /// Removes all values from storage, given one or more keys. The value
  /// returned by the Future is undefined.
  Future removeByKeys(Iterable<String> _keys) {
    _checkOpen();
    return _removeByKeys(_keys);
  }
  Future _removeByKeys(Iterable<String> _keys);
  
  /// Removes all values from storage.
  /// The value returned by the Future is undefined.
  Future nuke() {
    _checkOpen();
    return _nuke();
  }
  Future _nuke();
}
