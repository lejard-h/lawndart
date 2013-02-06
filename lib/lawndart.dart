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
import 'dart:json' as JSON;
import 'dart:async';
import 'package:meta/meta.dart';

part 'indexeddb_adapter.dart';
part '_map_adapter.dart';
part 'memory_adapter.dart';
part 'local_storage_adapter.dart';
part 'websql_adapter.dart';

_results(obj) => new Future.immediate(obj);

abstract class Store<K, V> {
  bool _isOpen = false;
  
  bool get isOpen => _isOpen;
  
  _checkOpen() {
    if (!isOpen) throw new StateError('not open');
  }
  
  Future open();
  
  Future<Iterable<K>> keys() {
    _checkOpen();
    return _keys();
  }
  Future<Iterable<K>> _keys();
  
  Future save(V obj, K key) {
    _checkOpen();
    if (key == null) {
      throw new ArgumentError("key must not be null");
    }
    return _save(obj, key);
  }
  Future _save(V obj, K key);
  
  Future batch(Map<K, V> objectsByKey) {
    _checkOpen();
    return _batch(objectsByKey);
  }
  Future _batch(Map<K, V> objectsByKey);
  
  Future<V> getByKey(K key) {
    _checkOpen();
    return _getByKey(key);
  }
  Future<V> _getByKey(K key);
  
  Future<Iterable<V>> getByKeys(Iterable<K> _keys) {
    _checkOpen();
    return _getByKeys(_keys);
  }
  Future<Iterable<V>> _getByKeys(Iterable<K> _keys);
  
  Future<bool> exists(K key) {
    _checkOpen();
    return _exists(key);
  }
  Future<bool> _exists(K key);
  
  Future<Iterable<V>> all() {
    _checkOpen();
    return _all();
  }
  Future<Iterable<V>> _all();
  
  /// Removes a value from storage, given a key. The value
  /// returned by the Future is undefined.
  Future removeByKey(K key) {
    _checkOpen();
    return _removeByKey(key);
  }
  Future _removeByKey(key);
  
  /// Removes all values from storage, given one or more keys. The value
  /// returned by the Future is undefined.
  Future removeByKeys(Iterable<K> _keys) {
    _checkOpen();
    return _removeByKeys(_keys);
  }
  Future _removeByKeys(Iterable<K> _keys);
  
  /// Removes all values from storage.
  /// The value returned by the Future is undefined.
  Future nuke() {
    _checkOpen();
    return _nuke();
  }
  Future _nuke();
}
