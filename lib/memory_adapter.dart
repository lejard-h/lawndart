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

class MemoryAdapter<K, V> implements Store<K, V> {
  bool isOpen = false;
  Map<K, V> storage = new Map<K, V>();
  
  _checkOpen() {
    if (!isOpen) throw new StateError('not open');
  }

  Future<bool> open() {
    isOpen = true;
    return new Future.immediate(true);
  }
  
  Future<Iterable<K>> keys() {
    _checkOpen();
    return _results(storage.keys);
  }
  
  Future save(V obj, K key) {
    _checkOpen();
    if (key == null) {
      throw new ArgumentError("key must not be null");
    }
    storage[key] = obj;
    return _results(true);
  }
  
  Future batch(Map<K, V> objs) {
    _checkOpen();
    for (var key in objs.keys) {
      storage[key] = objs[key];
    }
    return _results(true);
  }
  
  Future<V> getByKey(K key) {
    _checkOpen();
    return _results(storage[key]);
  }
  
  Future<Iterable<V>> getByKeys(Iterable<K> _keys) {
    _checkOpen();
    var values = _keys.mappedBy((key) => storage[key]);
    return _results(values);
  }
  
  Future<bool> exists(K key) {
    _checkOpen();
    return _results(storage.containsKey(key));
  }
  
  Future<Iterable<V>> all() {
    _checkOpen();
    return _results(storage.keys);
  }
  
  Future<bool> removeByKey(K key) {
    _checkOpen();
    storage.remove(key);
    return _results(true);
  }
  
  Future<bool> removeByKeys(Iterable<K> _keys) {
    _checkOpen();
    _keys.forEach((key) => storage.remove(key));
    return _results(true);
  }
  
  Future<bool> nuke() {
    _checkOpen();
    storage.clear();
    return _results(true);
  }
}