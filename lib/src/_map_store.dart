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

abstract class _MapStore<V> extends Store<V> {
  Map<String, V> storage;
  
  _MapStore() : super._();

  Future<bool> open() {
    storage = _generateMap();
    _isOpen = true;
    return new Future.value(true);
  }

  Map<String, V> _generateMap();

  Stream<String> _keys() {
    return new Stream.fromIterable(storage.keys);
  }

  Future _save(V obj, String key) {
    storage[key] = obj;
    return new Future.value(key);
  }

  Future _batch(Map<String, V> objs) {
    for (var key in objs.keys) {
      storage[key] = objs[key];
    }
    return new Future.value(true);
  }

  Future<V> _getByKey(String key) {
    return new Future.value(storage[key]);
  }

  Stream<V> _getByKeys(Iterable<String> _keys) {
    var values = _keys.map((key) => storage[key]).where((v) => v != null);
    return new Stream.fromIterable(values);
  }

  Future<bool> _exists(String key) {
    return new Future.value(storage.containsKey(key));
  }

  Stream<V> _all() {
    return new Stream.fromIterable(storage.values);
  }

  Future _removeByKey(String key) {
    storage.remove(key);
    return new Future.value(true);
  }

  Future _removeByKeys(Iterable<String> _keys) {
    _keys.forEach((key) => storage.remove(key));
    return new Future.value(true);
  }

  Future _nuke() {
    storage.clear();
    return new Future.value(true);
  }
}