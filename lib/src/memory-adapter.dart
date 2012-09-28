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

class MemoryAdapter<K extends Hashable, V> implements Store<K, V> {
  Map<K, V> storage;

  MemoryAdapter([Map options]) : storage = new Map<K, V>();

  Future<bool> open() {
    return new Future.immediate(true);
  }
  
  Future<Collection<K>> keys() {
    return _results(storage.getKeys());
  }
  
  Future<K> save(V obj, [K key]) {
    key = key == null ? _uuid() : key;
    storage[key] = obj;
    return _results(key);
  }
  
  Future<Collection<K>> batch(List<V> objs, [List<K> _keys]) {
    List<K> newKeys = <K>[];
    for (var i = 0; i < objs.length; i++) {
      K key = _keys[i];
      key = key == null ? _uuid() : key;
      newKeys.add(key);
      storage[key] = objs[i];
    }
    return _results(newKeys);
  }
  
  Future<V> getByKey(K key) {
    return _results(storage[key]);
  }
  
  Future<Collection<V>> getByKeys(Collection<K> _keys) {
    var values = _keys.map((key) => storage[key]);
    return _results(values);
  }
  
  Future<bool> exists(K key) {
    return _results(storage.containsKey(key));
  }
  
  Future<Collection<V>> all() {
    return _results(storage.getKeys());
  }
  
  Future<bool> removeByKey(K key) {
    storage.remove(key);
    return _results(true);
  }
  
  Future<bool> removeByKeys(Collection<K> _keys) {
    _keys.forEach((key) => storage.remove(key));
    return _results(true);
  }
  
  Future<bool> nuke() {
    storage.clear();
    return _results(true);
  }
}